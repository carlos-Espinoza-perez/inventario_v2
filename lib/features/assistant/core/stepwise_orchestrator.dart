import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/constants/app_constants.dart';
import '../data/openai/openai_client.dart';
import '../data/openai/openai_models.dart';
import '../data/openai/openai_providers.dart';
import '../data/knowledge/knowledge_models.dart';
import '../data/knowledge/workflow_loader.dart';
import '../data/tools/tool_executor.dart';
import '../domain/models/conversation_state.dart';
import '../domain/models/workflow_state.dart';
import '../domain/models/assistant_operational_context.dart';

// ── Modelos del ciclo ReAct ──────────────────────────────────────────────────

enum ReactAction { useTool, askUser, showDraft, answer, error }

class ReactDecision {
  final ReactAction action;
  final String? toolId;
  final Map<String, dynamic>? toolParams;
  final String? userQuestion;
  final String? fieldName;
  final String? answerText;
  final String reasoning;

  const ReactDecision({
    required this.action,
    this.toolId,
    this.toolParams,
    this.userQuestion,
    this.fieldName,
    this.answerText,
    required this.reasoning,
  });

  factory ReactDecision.fromJson(Map<String, dynamic> j) {
    final actionStr = j['action'] as String? ?? 'error';
    final action = switch (actionStr) {
      'use_tool' => ReactAction.useTool,
      'ask_user' => ReactAction.askUser,
      'show_draft' => ReactAction.showDraft,
      'answer' => ReactAction.answer,
      _ => ReactAction.error,
    };
    return ReactDecision(
      action: action,
      toolId: j['tool'] as String?,
      toolParams: (j['params'] as Map?)?.cast<String, dynamic>(),
      userQuestion: j['question'] as String?,
      fieldName: j['field_name'] as String?,
      answerText: j['answer'] as String?,
      reasoning: j['reasoning'] as String? ?? '',
    );
  }
}

// ── TurnResult (definido aquí, re-exportado desde turn_pipeline) ─────────────

class TurnResult {
  final String responseText;
  final Stream<String>? responseStream;
  final ConversationState updatedState;
  final bool requiresConfirmation;
  final bool isOffline;
  final dynamic draft;
  final String? resumeHint;

  const TurnResult({
    required this.responseText,
    required this.updatedState,
    this.responseStream,
    this.requiresConfirmation = false,
    this.isOffline = false,
    this.draft,
    this.resumeHint,
  });

  TurnResult copyWith({
    String? responseText,
    Stream<String>? responseStream,
    ConversationState? updatedState,
    bool? requiresConfirmation,
    bool? isOffline,
    String? resumeHint,
  }) =>
      TurnResult(
        responseText: responseText ?? this.responseText,
        responseStream: responseStream ?? this.responseStream,
        updatedState: updatedState ?? this.updatedState,
        requiresConfirmation: requiresConfirmation ?? this.requiresConfirmation,
        isOffline: isOffline ?? this.isOffline,
        draft: draft,
        resumeHint: resumeHint ?? this.resumeHint,
      );
}

// ── StepwiseOrchestrator ─────────────────────────────────────────────────────

class StepwiseOrchestrator {
  final LLMClient _llm;
  final ToolExecutor _toolExecutor;
  final WorkflowLoader _workflowLoader;
  final int _maxIterations;

  static const _orchestratorSystemPrompt = '''
Eres el Secretario IA de un sistema de inventario. Tienes acceso a herramientas para consultar datos reales.

FECHA Y HORA: {datetime}
EMPRESA: {empresaNombre}
USUARIO: {usuarioNombre}
BODEGA ACTIVA: {bodegaNombre}
CAJA: {cajaStatus}

OBJETIVO ACTUAL: {workflowNombre}
HISTORIAL DE LA CONVERSACIÓN:
{messageHistory}

DATOS RECOLECTADOS HASTA AHORA:
{collectedData}

OBSERVACIONES DE PASOS ANTERIORES:
{observations}

HERRAMIENTAS DISPONIBLES:
{toolsCatalog}

INSTRUCCIONES:
Analiza la situación y decide la siguiente acción. Las opciones son:
1. "use_tool" — usar una herramienta para obtener datos. Solo cuando necesitas datos reales.
2. "ask_user" — hacer UNA pregunta específica al usuario para obtener un dato faltante.
3. "show_draft" — mostrar borrador de confirmación (solo para acciones de escritura).
4. "answer" — generar la respuesta final para el usuario usando los datos recolectados.

REGLAS IMPORTANTES:
- Nunca inventes datos. Si no tienes un dato, usa una tool o pregunta al usuario.
- Si ya tienes todos los datos necesarios, responde directamente con "answer".
- La respuesta en "answer" debe ser en lenguaje natural, clara y concisa.
- Para acciones (entrada, venta, etc.), SIEMPRE usar "show_draft" antes de ejecutar.
- Cuando uses datos del sistema en la respuesta, preséntalo de forma amigable.

FORMATO DE RESPUESTA (JSON):
{"action":"use_tool | ask_user | show_draft | answer","tool":"tool_id si action==use_tool","params":{},"question":"pregunta si action==ask_user","field_name":"nombre_variable si action==ask_user","answer":"texto de respuesta si action==answer","reasoning":"por qué elegiste esta acción"}
''';

  StepwiseOrchestrator({
    required LLMClient llm,
    required ToolExecutor toolExecutor,
    required WorkflowLoader workflowLoader,
    int? maxIterations,
  })  : _llm = llm,
        _toolExecutor = toolExecutor,
        _workflowLoader = workflowLoader,
        _maxIterations = maxIterations ?? AppConstants.assistantMaxReactIterations;

  Future<TurnResult> execute({
    required String userMessage,
    required WorkflowState workflowState,
    required ConversationState conversationState,
    required AssistantOperationalContext operationalContext,
  }) async {
    final workflowDef = await _workflowLoader.load(workflowState.workflowId);
    final toolsCatalog = await _workflowLoader.loadToolsCatalog();

    var currentCollectedData = Map<String, CollectedVariable>.from(
      conversationState.collectedData,
    );
    final observations = <Map<String, dynamic>>[
      ...workflowState.stepHistory,
    ];

    for (int i = 0; i < _maxIterations; i++) {
      // ── PIENSA ──────────────────────────────────────────────────────────────
      final systemPrompt = _buildOrchestratorPrompt(
        workflowNombre: workflowDef.nombre,
        conversationState: conversationState.copyWith(
          collectedData: currentCollectedData,
        ),
        operationalContext: operationalContext,
        observations: observations,
        toolsCatalog: toolsCatalog,
      );

      final request = OpenAIRequest(
        model: AppConstants.openAiModel,
        messages: [
          OpenAIMessage.system(systemPrompt),
          OpenAIMessage.user(userMessage),
        ],
        stream: false,
        temperature: 0.2,
        maxTokens: 512,
        responseFormat: {'type': 'json_object'},
      );

      OpenAIResponse decisionResponse;
      try {
        decisionResponse = await _llm
            .chat(request)
            .timeout(const Duration(seconds: 4));
      } on OpenAIException catch (e) {
        if (e.statusCode == 429) {
          // Rate limit — esperar 2s y reintentar una vez
          await Future.delayed(const Duration(seconds: 2));
          try {
            decisionResponse = await _llm
                .chat(request)
                .timeout(const Duration(seconds: 4));
          } catch (_) {
            return _buildFinalResult(
              'El servicio está ocupado. Esperá un momento e intentá de nuevo.',
              conversationState,
              currentCollectedData,
            );
          }
        } else {
          rethrow;
        }
      } on Object {
        return _buildFinalResult(
          'La consulta tardó demasiado. Intentá con una pregunta más específica.',
          conversationState,
          currentCollectedData,
        );
      }

      ReactDecision decision;
      try {
        decision = ReactDecision.fromJson(
          jsonDecode(decisionResponse.content) as Map<String, dynamic>,
        );
      } catch (_) {
        return _buildFinalResult(
          'Recibí una respuesta inesperada. Intentá de nuevo.',
          conversationState,
          currentCollectedData,
        );
      }

      // ── ACTÚA ────────────────────────────────────────────────────────────────
      switch (decision.action) {
        case ReactAction.useTool:
          if (decision.toolId == null) continue;

          final toolResult = await _toolExecutor.execute(
            toolId: decision.toolId!,
            params: decision.toolParams ?? {},
            operationalContext: operationalContext,
            collectedData: currentCollectedData,
          );

          // ¿La tool requiere borrador?
          if (toolResult.isSuccess &&
              (toolResult.data as Map?)?['__requires_draft'] == true) {
            return _buildDraftResult(
              toolResult.data as Map<String, dynamic>,
              conversationState,
              currentCollectedData,
              workflowState,
            );
          }

          // ¿La tool pide un dato al usuario?
          if (toolResult.needsUserInput) {
            return _buildAskUserResult(
              toolResult.userQuestion!,
              null,
              conversationState,
              currentCollectedData,
              workflowState,
            );
          }

          // ¿Resultado ambiguo? (ej: múltiples productos con ese nombre)
          if (!toolResult.isSuccess &&
              !toolResult.isAmbiguous &&
              toolResult.errorMessage != null) {
            return _buildFinalResult(
              toolResult.errorMessage!,
              conversationState,
              currentCollectedData,
            );
          }

          if (toolResult.isAmbiguous) {
            final candidateNames = (toolResult.candidates ?? [])
                .map(_extractDisplayName)
                .toList();
            return _buildClarifyResult(
              '¿Cuál de estos querés consultar?',
              candidateNames,
              conversationState,
              currentCollectedData,
              workflowState,
            );
          }

          // ── OBSERVA: guardar resultado ─────────────────────────────────────
          if (toolResult.isSuccess) {
            final varName = decision.toolId!.split('.').last;
            currentCollectedData = {
              ...currentCollectedData,
              varName: CollectedVariable(
                value: toolResult.data,
                type: CollectedVariable.inferType(varName),
              ),
            };
          }

          observations.add({
            'step': i,
            'tool': decision.toolId,
            'status': toolResult.status.name,
            'result': toolResult.toContext(),
            'reasoning': decision.reasoning,
          });

          continue;

        case ReactAction.askUser:
          return _buildAskUserResult(
            decision.userQuestion ?? '¿Podés darme más detalles?',
            decision.fieldName,
            conversationState,
            currentCollectedData,
            workflowState,
          );

        case ReactAction.showDraft:
          return _buildDraftResult(
            {'__draft_type': 'generic', ...?decision.toolParams},
            conversationState,
            currentCollectedData,
            workflowState,
          );

        case ReactAction.answer:
          final finalStream = _generateStreamingAnswer(
            answerInstruction: decision.answerText ?? userMessage,
            collectedData: currentCollectedData,
            operationalContext: operationalContext,
            conversationState: conversationState,
          );

          final updatedState = conversationState
              .copyWith(collectedData: currentCollectedData)
              .addTurn(
                ConversationTurn(
                  role: 'user',
                  content: userMessage,
                  timestamp: DateTime.now(),
                ),
              );

          return TurnResult(
            responseText: '',
            responseStream: finalStream,
            updatedState: updatedState.copyWith(
              clearActiveWorkflow: workflowDef.type == 'query',
            ),
          );

        case ReactAction.error:
          return _buildFinalResult(
            'No pude completar esa acción. Intentá de nuevo.',
            conversationState,
            currentCollectedData,
          );
      }
    }

    // Máximo de iteraciones alcanzado
    return _buildFinalResult(
      'No pude completar la consulta en el tiempo esperado. '
      'Intentá con una pregunta más específica.',
      conversationState,
      currentCollectedData,
    );
  }

  /// Respuesta directa sin workflow (saludos, preguntas generales, unsupported).
  Future<TurnResult> executeDirectAnswer({
    required String userMessage,
    required ConversationState conversationState,
    required AssistantOperationalContext operationalContext,
  }) async {
    final stream = _generateStreamingAnswer(
      answerInstruction: userMessage,
      collectedData: conversationState.collectedData,
      operationalContext: operationalContext,
      conversationState: conversationState,
    );

    return TurnResult(
      responseText: '',
      responseStream: stream,
      updatedState: conversationState,
    );
  }

  // ── Helpers privados ─────────────────────────────────────────────────────────

  Stream<String> _generateStreamingAnswer({
    required String answerInstruction,
    required Map<String, CollectedVariable> collectedData,
    required AssistantOperationalContext operationalContext,
    required ConversationState conversationState,
  }) {
    final dataSummary = collectedData.entries
        .where((e) => e.value.relevance > 0.3 && !e.key.startsWith('_'))
        .map((e) => '${e.key}: ${_serializeValue(e.value.value)}')
        .join('\n');

    final recentHistory = conversationState.messageHistory
        .reversed
        .take(4)
        .toList()
        .reversed
        .map((t) => '${t.role}: ${t.content}')
        .join('\n');

    final systemPrompt = '''
Eres el Secretario IA de un sistema de inventario. Respondé de forma natural, clara y concisa.
Usá los datos del sistema para respaldar tu respuesta. No inventes información.

EMPRESA: ${operationalContext.empresaId}
BODEGA: ${operationalContext.selectedWarehouseId ?? 'no seleccionada'}

DATOS DEL SISTEMA PARA ESTA RESPUESTA:
${dataSummary.isEmpty ? 'ninguno' : dataSummary}

HISTORIAL RECIENTE:
${recentHistory.isEmpty ? 'ninguno' : recentHistory}
''';

    final request = OpenAIRequest(
      model: AppConstants.openAiModel,
      messages: [
        OpenAIMessage.system(systemPrompt),
        OpenAIMessage.user(answerInstruction),
      ],
      stream: true,
      temperature: 0.3,
      maxTokens: AppConstants.openAiMaxTokens,
    );

    return _llm
        .streamChat(request)
        .where((chunk) => !chunk.isDone && chunk.content != null)
        .map((chunk) => chunk.content!);
  }

  TurnResult _buildFinalResult(
    String text,
    ConversationState state,
    Map<String, CollectedVariable> collectedData,
  ) =>
      TurnResult(
        responseText: text,
        updatedState: state.copyWith(collectedData: collectedData),
      );

  TurnResult _buildAskUserResult(
    String question,
    String? fieldName,
    ConversationState state,
    Map<String, CollectedVariable> collectedData,
    WorkflowState workflowState,
  ) =>
      TurnResult(
        responseText: question,
        updatedState: state.copyWith(
          collectedData: collectedData,
          activeWorkflow: workflowState.copyWith(pendingField: fieldName),
        ),
      );

  TurnResult _buildClarifyResult(
    String question,
    List<String> options,
    ConversationState state,
    Map<String, CollectedVariable> collectedData,
    WorkflowState workflowState,
  ) =>
      TurnResult(
        responseText: question,
        updatedState: state.copyWith(
          collectedData: {
            ...collectedData,
            '_clarificationOptions': CollectedVariable(
              value: options,
              type: VariableType.transient,
            ),
          },
          activeWorkflow: workflowState.copyWith(pendingField: '_selection'),
        ),
      );

  TurnResult _buildDraftResult(
    Map<String, dynamic> draftData,
    ConversationState state,
    Map<String, CollectedVariable> collectedData,
    WorkflowState workflowState,
  ) =>
      TurnResult(
        responseText: 'Revisá el borrador antes de confirmar.',
        updatedState: state.copyWith(collectedData: collectedData),
        requiresConfirmation: true,
        draft: draftData,
      );

  String _buildOrchestratorPrompt({
    required String workflowNombre,
    required ConversationState conversationState,
    required AssistantOperationalContext operationalContext,
    required List<Map<String, dynamic>> observations,
    required List<ToolDefinition> toolsCatalog,
  }) {
    final history = conversationState.messageHistory
        .reversed
        .take(6)
        .toList()
        .reversed
        .map((t) => '${t.role}: ${t.content}')
        .join('\n');

    final collected = conversationState.collectedData.entries
        .where((e) => e.value.relevance > 0.2)
        .map((e) => '${e.key}: ${_serializeValue(e.value.value)}')
        .join('\n');

    final obs = observations.isEmpty
        ? 'Ninguna'
        : observations
            .map((o) => 'Step ${o['step']}: ${o['tool']} → ${o['status']}')
            .join('\n');

    final tools = toolsCatalog.map((t) => t.toPromptEntry()).join('\n');

    return _orchestratorSystemPrompt
        .replaceAll('{datetime}', DateTime.now().toIso8601String())
        .replaceAll('{empresaNombre}', operationalContext.empresaId)
        .replaceAll('{usuarioNombre}', operationalContext.usuarioId)
        .replaceAll(
            '{bodegaNombre}', operationalContext.selectedWarehouseId ?? 'ninguna')
        .replaceAll(
            '{cajaStatus}', operationalContext.hasCashOpen ? 'abierta' : 'cerrada')
        .replaceAll('{workflowNombre}', workflowNombre)
        .replaceAll('{messageHistory}', history.isEmpty ? 'ninguno' : history)
        .replaceAll('{collectedData}', collected.isEmpty ? 'ninguno' : collected)
        .replaceAll('{observations}', obs)
        .replaceAll('{toolsCatalog}', tools);
  }

  String _extractDisplayName(dynamic entity) {
    if (entity is Map) {
      return (entity['nombre'] ?? entity['name'] ?? entity.toString()) as String;
    }
    try {
      return (entity as dynamic).nombre as String;
    } catch (_) {}
    return entity.toString();
  }

  String _serializeValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String || value is num || value is bool) return value.toString();
    if (value is Map || value is List) return jsonEncode(value);
    try {
      return jsonEncode((value as dynamic).toJson());
    } catch (_) {}
    return value.toString();
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────

final stepwiseOrchestratorProvider = Provider<StepwiseOrchestrator>((ref) {
  return StepwiseOrchestrator(
    llm: ref.watch(llmClientProvider),
    toolExecutor: ref.watch(toolExecutorProvider),
    workflowLoader: ref.watch(workflowLoaderProvider),
  );
});
