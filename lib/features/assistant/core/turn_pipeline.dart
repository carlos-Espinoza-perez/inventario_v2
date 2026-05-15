import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/constants/app_constants.dart';
import '../data/connectivity/connectivity_checker.dart';
import '../data/context/assistant_context_builder.dart';
import '../data/entry/assistant_entry_workflow_service.dart';
import '../data/offline/offline_query_handler.dart';
import '../domain/models/assistant_operational_context.dart';
import '../domain/models/conversation_state.dart';
import '../domain/models/paused_workflow.dart';
import '../domain/models/workflow_state.dart';
import '../data/knowledge/knowledge_models.dart';
import 'semantic_router.dart';
import 'reasoning_engine.dart';
import 'stepwise_orchestrator.dart';

export 'stepwise_orchestrator.dart' show TurnResult;

// Máximo de niveles de interrupción anidados.
const _kMaxPausedWorkflows = 3;
const _selectedWarehouseIdKey = '_assistantSelectedWarehouseId';
const _pendingWarehouseSelectionKey = '_pendingWarehouseSelection';
const _pendingWarehouseMessageKey = '_pendingWarehouseMessage';
const _clarificationOptionsKey = '_clarificationOptions';

class TurnPipeline {
  final AssistantContextBuilder _contextBuilder;
  final SemanticRouter _semanticRouter;
  final ReasoningEngine _reasoningEngine;
  final StepwiseOrchestrator _orchestrator;
  final ConnectivityChecker _connectivityChecker;
  final OfflineQueryHandler _offlineQueryHandler;
  final AssistantEntryWorkflowService _entryWorkflowService;
  final AppDatabase _db;

  TurnPipeline({
    required AssistantContextBuilder contextBuilder,
    required SemanticRouter semanticRouter,
    required ReasoningEngine reasoningEngine,
    required StepwiseOrchestrator orchestrator,
    required ConnectivityChecker connectivityChecker,
    required OfflineQueryHandler offlineQueryHandler,
    required AssistantEntryWorkflowService entryWorkflowService,
    required AppDatabase db,
  }) : _contextBuilder = contextBuilder,
       _semanticRouter = semanticRouter,
       _reasoningEngine = reasoningEngine,
       _orchestrator = orchestrator,
       _connectivityChecker = connectivityChecker,
       _offlineQueryHandler = offlineQueryHandler,
       _entryWorkflowService = entryWorkflowService,
       _db = db;

  Future<TurnResult> process(
    String userMessage,
    ConversationState state,
  ) async {
    var context = await _contextBuilder.build(
      selectedWarehouseId: _selectedWarehouseIdFrom(state),
    );
    if (!context.isValid) {
      return TurnResult(
        responseText:
            'No hay sesión activa. Iniciá sesión antes de usar el Secretario.',
        updatedState: state,
      );
    }

    var currentState = state.applyDecay();

    if (context.allowedWarehouses.isEmpty) {
      return TurnResult(
        responseText:
            'No tenes bodegas asignadas para usar el asistente. Pedi a un administrador que revise tus accesos.',
        updatedState: currentState,
      );
    }

    if (_isAwaitingWarehouseSelection(currentState)) {
      return _handleWarehouseSelectionAnswer(
        userMessage: userMessage,
        state: currentState,
        context: context,
      );
    }

    if (_isWarehouseChangeRequest(userMessage) &&
        context.allowedWarehouses.length > 1) {
      return _buildWarehouseSelectionResult(
        originalMessage: '',
        state: currentState.addTurn(
          ConversationTurn(
            role: 'user',
            content: userMessage,
            timestamp: DateTime.now(),
          ),
          maxTurns: AppConstants.assistantHistoryTurns,
        ),
        context: context,
      );
    }

    if (_isSalesHistoryQuery(userMessage)) {
      return _handleSalesHistoryQuery(userMessage, currentState);
    }

    // ── Verificar conectividad ─────────────────────────────────────────────
    final online = await _connectivityChecker.isOnline();
    if (!online) {
      if (context.selectedWarehouseId == null &&
          _messageLikelyNeedsWarehouse(userMessage)) {
        return _buildWarehouseSelectionResult(
          originalMessage: userMessage,
          state: currentState.addTurn(
            ConversationTurn(
              role: 'user',
              content: userMessage,
              timestamp: DateTime.now(),
            ),
            maxTurns: AppConstants.assistantHistoryTurns,
          ),
          context: context,
        );
      }
      final offlineResponse = await _offlineQueryHandler.handle(
        userMessage,
        context,
      );
      return TurnResult(
        responseText: offlineResponse,
        updatedState: currentState,
        isOffline: true,
      );
    }

    final mentionedWarehouse = _findMentionedWarehouse(userMessage, context);
    if (mentionedWarehouse != null &&
        mentionedWarehouse.id != context.selectedWarehouseId) {
      currentState = _withSelectedWarehouse(
        currentState,
        mentionedWarehouse.id,
      );
      context = await _contextBuilder.build(
        selectedWarehouseId: mentionedWarehouse.id,
      );
    }

    currentState = currentState.addTurn(
      ConversationTurn(
        role: 'user',
        content: userMessage,
        timestamp: DateTime.now(),
      ),
      maxTurns: AppConstants.assistantHistoryTurns,
    );

    // ── 1. Desambiguar referencias contextuales ────────────────────────────
    final clarifiedMessage = await _reasoningEngine.clarifyIfNeeded(
      userMessage,
      currentState,
    );

    // ── 2. Clasificar intención ────────────────────────────────────────────
    final routerResult = await _semanticRouter.route(
      clarifiedMessage,
      currentState,
      context,
    );
    currentState = _withRouterEntities(currentState, routerResult.entities);

    final hasActiveEntrySession = await _entryWorkflowService.hasActiveSession(
      context,
    );
    if (routerResult.intent == 'action_register_entry' ||
        (hasActiveEntrySession &&
            routerResult.intent != 'action_register_sale')) {
      final entryResult = await _entryWorkflowService.process(
        message: clarifiedMessage,
        context: context,
        forceStart: routerResult.intent == 'action_register_entry',
      );
      if (entryResult.handled) {
        return TurnResult(
          responseText: entryResult.responseText,
          updatedState: currentState,
        );
      }
    }

    // ── 3. Routing por banda de confianza ──────────────────────────────────
    if (routerResult.shouldReject) {
      return _orchestrator.executeDirectAnswer(
        userMessage: clarifiedMessage,
        conversationState: currentState,
        operationalContext: context,
      );
    }

    if (routerResult.needsMoreInfo) {
      return TurnResult(
        responseText:
            'No estoy seguro de entender lo que necesitás. ¿Podés ser más específico?',
        updatedState: currentState,
      );
    }

    // ── 4. Detectar interrupción de un workflow activo ─────────────────────
    if (routerResult.requiresWarehouse && context.selectedWarehouseId == null) {
      return _buildWarehouseSelectionResult(
        originalMessage: clarifiedMessage,
        state: currentState,
        context: context,
      );
    }

    if (_isInterruption(
      routerResult: routerResult,
      activeWorkflow: currentState.activeWorkflow,
      pausedCount: currentState.pausedWorkflowStack.length,
    )) {
      return await _handleInterruption(
        userMessage: clarifiedMessage,
        routerResult: routerResult,
        conversationState: currentState,
        operationalContext: context,
      );
    }

    // ── 5. Continuar workflow activo si está esperando respuesta ───────────
    if (currentState.hasActiveWorkflow &&
        currentState.activeWorkflow!.isAwaitingUser) {
      final existingWorkflow = currentState.activeWorkflow!;
      final fieldName = existingWorkflow.pendingField!;

      final updatedCollected = {
        ...currentState.collectedData,
        fieldName: CollectedVariable(
          value: clarifiedMessage,
          type: CollectedVariable.inferType(fieldName),
        ),
      };

      final resumedWorkflow = existingWorkflow.copyWith(
        clearPendingField: true,
      );
      final resumedState = currentState.copyWith(
        activeWorkflow: resumedWorkflow,
        collectedData: updatedCollected,
      );

      return _orchestrator.execute(
        userMessage: clarifiedMessage,
        workflowState: resumedWorkflow,
        conversationState: resumedState,
        operationalContext: context,
      );
    }

    // ── 6. Iniciar workflow detectado ──────────────────────────────────────
    final workflowId = routerResult.workflowId;

    if (workflowId == 'wf_direct_answer' || workflowId.isEmpty) {
      return _orchestrator.executeDirectAnswer(
        userMessage: clarifiedMessage,
        conversationState: currentState,
        operationalContext: context,
      );
    }

    final workflowState = WorkflowState(
      workflowId: workflowId,
      intentType: routerResult.intent,
    );

    final updatedStateWithWorkflow = currentState.copyWith(
      activeWorkflow: workflowState,
    );

    return _orchestrator.execute(
      userMessage: clarifiedMessage,
      workflowState: workflowState,
      conversationState: updatedStateWithWorkflow,
      operationalContext: context,
    );
  }

  // ── Lógica de interrupción ───────────────────────────────────────────────

  Future<TurnResult> _handleWarehouseSelectionAnswer({
    required String userMessage,
    required ConversationState state,
    required AssistantOperationalContext context,
  }) async {
    final selectedWarehouse = _resolveWarehouse(userMessage, context);
    final stateWithTurn = state.addTurn(
      ConversationTurn(
        role: 'user',
        content: userMessage,
        timestamp: DateTime.now(),
      ),
      maxTurns: AppConstants.assistantHistoryTurns,
    );

    if (selectedWarehouse == null) {
      return TurnResult(
        responseText:
            'No encontre esa bodega entre tus accesos. Elegi una de estas bodegas:',
        updatedState: _withWarehousePromptData(
          stateWithTurn,
          pendingMessage:
              state.collectedData[_pendingWarehouseMessageKey]?.value
                  as String?,
          context: context,
        ),
      );
    }

    final selectedState = _withSelectedWarehouse(
      stateWithTurn,
      selectedWarehouse.id,
    );
    final pendingMessage =
        state.collectedData[_pendingWarehouseMessageKey]?.value as String?;

    if (pendingMessage == null || pendingMessage.trim().isEmpty) {
      return TurnResult(
        responseText: 'Listo, usare ${selectedWarehouse.nombre} para el chat.',
        updatedState: selectedState,
      );
    }

    return process(pendingMessage, selectedState);
  }

  TurnResult _buildWarehouseSelectionResult({
    required String originalMessage,
    required ConversationState state,
    required AssistantOperationalContext context,
  }) {
    return TurnResult(
      responseText: 'En que bodega queres trabajar?',
      updatedState: _withWarehousePromptData(
        state,
        pendingMessage: originalMessage,
        context: context,
      ),
    );
  }

  ConversationState _withWarehousePromptData(
    ConversationState state, {
    required String? pendingMessage,
    required AssistantOperationalContext context,
  }) {
    final options = context.allowedWarehouses.map((b) => b.nombre).toList();
    return state.copyWith(
      collectedData: {
        ...state.collectedData,
        _pendingWarehouseSelectionKey: const CollectedVariable(
          value: true,
          type: VariableType.session,
        ),
        if (pendingMessage != null)
          _pendingWarehouseMessageKey: CollectedVariable(
            value: pendingMessage,
            type: VariableType.session,
          ),
        _clarificationOptionsKey: CollectedVariable(
          value: options,
          type: VariableType.transient,
        ),
      },
    );
  }

  ConversationState _withSelectedWarehouse(
    ConversationState state,
    String warehouseId,
  ) {
    final updated = Map<String, CollectedVariable>.from(state.collectedData);
    updated[_selectedWarehouseIdKey] = CollectedVariable(
      value: warehouseId,
      type: VariableType.permanent,
    );
    updated.remove(_pendingWarehouseSelectionKey);
    updated.remove(_pendingWarehouseMessageKey);
    updated.remove(_clarificationOptionsKey);
    return state.copyWith(collectedData: updated);
  }

  ConversationState _withRouterEntities(
    ConversationState state,
    Map<String, dynamic> entities,
  ) {
    final updated = Map<String, CollectedVariable>.from(state.collectedData);
    for (final entry in entities.entries) {
      final value = entry.value;
      if (value == null) continue;
      if (value is String && value.trim().isEmpty) continue;
      updated[entry.key] = CollectedVariable(
        value: value,
        type: CollectedVariable.inferType(entry.key),
      );
    }
    return state.copyWith(collectedData: updated);
  }

  String? _selectedWarehouseIdFrom(ConversationState state) {
    final value = state.collectedData[_selectedWarehouseIdKey]?.value;
    return value is String && value.isNotEmpty ? value : null;
  }

  bool _isAwaitingWarehouseSelection(ConversationState state) {
    return state.collectedData[_pendingWarehouseSelectionKey]?.value == true;
  }

  AssistantWarehouse? _resolveWarehouse(
    String input,
    AssistantOperationalContext context,
  ) {
    final normalizedInput = _normalize(input);
    if (normalizedInput.isEmpty) return null;
    for (final warehouse in context.allowedWarehouses) {
      if (warehouse.id == input.trim()) return warehouse;
      final normalizedName = _normalize(warehouse.nombre);
      if (normalizedInput == normalizedName ||
          normalizedInput.contains(normalizedName) ||
          normalizedName.contains(normalizedInput)) {
        return warehouse;
      }
    }
    return null;
  }

  AssistantWarehouse? _findMentionedWarehouse(
    String message,
    AssistantOperationalContext context,
  ) {
    final normalized = _normalize(message);
    if (!normalized.contains('bodega')) return null;
    for (final warehouse in context.allowedWarehouses) {
      final normalizedName = _normalize(warehouse.nombre);
      if (normalizedName.isNotEmpty && normalized.contains(normalizedName)) {
        return warehouse;
      }
    }
    return null;
  }

  bool _messageLikelyNeedsWarehouse(String message) {
    return RegExp(
      r'stock|inventario|cu[aá]nto hay|cu[aá]ntos hay|disponib|quedan?|entrada|ingresar|recib[ií]|precio|ventas?',
      caseSensitive: false,
    ).hasMatch(message);
  }

  bool _isWarehouseChangeRequest(String message) {
    return RegExp(
      r'otra bodega|cambiar (de )?bodega|usar (otra )?bodega|seleccionar bodega',
      caseSensitive: false,
    ).hasMatch(message);
  }

  bool _isSalesHistoryQuery(String message) {
    return RegExp(
      r'historial de ventas|listado de ventas|ventas recientes|ultimas ventas|últimas ventas',
      caseSensitive: false,
    ).hasMatch(message);
  }

  Future<TurnResult> _handleSalesHistoryQuery(
    String userMessage,
    ConversationState state,
  ) async {
    final updatedState = state.addTurn(
      ConversationTurn(
        role: 'user',
        content: userMessage,
        timestamp: DateTime.now(),
      ),
      maxTurns: AppConstants.assistantHistoryTurns,
    );

    final sales = await _db.salesDao.getSalesList();
    if (sales.isEmpty) {
      return TurnResult(
        responseText: 'No encontre ventas registradas todavia.',
        updatedState: updatedState,
      );
    }

    final lines = sales
        .take(5)
        .map((sale) {
          final date =
              '${sale.date.day.toString().padLeft(2, '0')}/${sale.date.month.toString().padLeft(2, '0')}';
          return '- ${sale.client}: C\$${sale.total.toStringAsFixed(2)} ($date, ${sale.status})';
        })
        .join('\n');

    return TurnResult(
      responseText: 'Estas son las ultimas ventas registradas:\n$lines',
      updatedState: updatedState,
    );
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .trim();
  }

  bool _isInterruption({
    required RouterResult routerResult,
    required WorkflowState? activeWorkflow,
    required int pausedCount,
  }) {
    if (activeWorkflow == null) return false;
    if (activeWorkflow.pendingField == null) return false;
    if (pausedCount >= _kMaxPausedWorkflows) return false;

    // Mismo workflow → no es interrupción, el usuario está respondiendo al pendingField
    if (routerResult.workflowId == activeWorkflow.workflowId) return false;

    // Alta confianza en una intención diferente → interrupción
    return routerResult.score >= 0.65;
  }

  Future<TurnResult> _handleInterruption({
    required String userMessage,
    required RouterResult routerResult,
    required ConversationState conversationState,
    required AssistantOperationalContext operationalContext,
  }) async {
    // 1. Pausar el workflow activo guardando su snapshot
    final paused = PausedWorkflow(
      state: conversationState.activeWorkflow!,
      collectedDataSnapshot: Map.unmodifiable(conversationState.collectedData),
      pausedAt: DateTime.now(),
      pauseReason: userMessage,
    );

    // 2. Estado temporal para responder la interrupción (sin workflow activo)
    final stateForInterruption = conversationState.copyWith(
      clearActiveWorkflow: true,
      pausedWorkflowStack: [...conversationState.pausedWorkflowStack, paused],
    );

    // 3. Ejecutar el orchestrator para la consulta de interrupción
    final interruptionWorkflow = WorkflowState(
      workflowId: routerResult.workflowId,
      intentType: routerResult.intent,
    );

    final interruptionResult = await _orchestrator.execute(
      userMessage: userMessage,
      workflowState: interruptionWorkflow,
      conversationState: stateForInterruption,
      operationalContext: operationalContext,
    );

    // 4. Restaurar el workflow pausado después de responder
    final restoredState = interruptionResult.updatedState.copyWith(
      activeWorkflow: paused.state,
      collectedData: {
        ...paused.collectedDataSnapshot,
        // Datos nuevos de la interrupción tienen prioridad sobre el snapshot
        ...interruptionResult.updatedState.collectedData,
      },
      pausedWorkflowStack: conversationState
          .pausedWorkflowStack, // quitar el que acaba de resolverse
    );

    // 5. Construir hint de reanudación
    final resumeHint = _buildResumeHint(paused.state);

    return interruptionResult.copyWith(
      updatedState: restoredState,
      resumeHint: resumeHint,
    );
  }

  String _buildResumeHint(WorkflowState pausedWorkflow) {
    final field = pausedWorkflow.pendingField;
    if (field == null) return '';
    return 'Continuemos con lo anterior — ${_questionForField(field)}';
  }

  String _questionForField(String fieldName) {
    return switch (fieldName) {
      'items' ||
      'product' ||
      'productQuery' => '¿qué producto querés ingresar?',
      'quantity' || 'cantidad' => '¿cuántas unidades?',
      'clientName' || 'client' => '¿a nombre de quién es la venta?',
      'saleType' => '¿es al contado o al fiado?',
      'description' || 'descripcion' => '¿cuál es la referencia o descripción?',
      '_draft_confirmation' => 'tenés un borrador pendiente de confirmar.',
      _ => '¿podés continuar con lo que estábamos haciendo?',
    };
  }

  /// Actualiza el historial con la respuesta completa cuando termina el stream.
  ConversationState addAssistantTurn(
    String fullResponse,
    ConversationState state,
  ) {
    return state.addTurn(
      ConversationTurn(
        role: 'assistant',
        content: fullResponse,
        timestamp: DateTime.now(),
      ),
      maxTurns: AppConstants.assistantHistoryTurns,
    );
  }
}
