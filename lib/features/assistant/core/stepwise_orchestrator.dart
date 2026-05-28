import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/constants/app_constants.dart';
import 'package:inventario_v2/core/services/app_logger.dart';
import '../data/openai/openai_client.dart';
import '../data/openai/openai_models.dart';
import '../data/openai/openai_providers.dart';
import '../data/knowledge/knowledge_models.dart';
import '../data/knowledge/workflow_loader.dart';
import '../data/tools/tool_executor.dart';
import '../domain/models/conversation_state.dart';
import '../domain/models/workflow_state.dart';
import '../domain/models/assistant_operational_context.dart';

// â”€â”€ Modelos del ciclo ReAct â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
    final toolId = j['tool'] as String?;
    final action = switch (actionStr) {
      'use_tool' => ReactAction.useTool,
      'ask_user' => ReactAction.askUser,
      'show_draft' => ReactAction.showDraft,
      'answer' => ReactAction.answer,
      // El LLM a veces pone el id de la herramienta en "action" en vez de
      // usar "use_tool". Si hay una tool presente, lo tratamos como tool call.
      _ when toolId != null && toolId.isNotEmpty => ReactAction.useTool,
      _ when actionStr.contains('.') => ReactAction.useTool,
      _ => ReactAction.error,
    };
    return ReactDecision(
      action: action,
      toolId: toolId ?? (actionStr.contains('.') ? actionStr : null),
      toolParams: (j['params'] as Map?)?.cast<String, dynamic>(),
      userQuestion: j['question'] as String?,
      fieldName: j['field_name'] as String?,
      answerText: j['answer'] as String?,
      reasoning: j['reasoning'] as String? ?? '',
    );
  }
}

// â”€â”€ TurnResult (definido aquÃ­, re-exportado desde turn_pipeline) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
  }) => TurnResult(
    responseText: responseText ?? this.responseText,
    responseStream: responseStream ?? this.responseStream,
    updatedState: updatedState ?? this.updatedState,
    requiresConfirmation: requiresConfirmation ?? this.requiresConfirmation,
    isOffline: isOffline ?? this.isOffline,
    draft: draft,
    resumeHint: resumeHint ?? this.resumeHint,
  );
}

// â”€â”€ StepwiseOrchestrator â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
MONEDA: CÃ³rdobas

OBJETIVO ACTUAL: {workflowNombre}
HISTORIAL DE LA CONVERSACIÃ“N:
{messageHistory}

DATOS RECOLECTADOS HASTA AHORA:
{collectedData}

OBSERVACIONES DE PASOS ANTERIORES:
{observations}

HERRAMIENTAS DISPONIBLES:
{toolsCatalog}

INSTRUCCIONES:
Analiza la situaciÃ³n y decide la siguiente acciÃ³n. Las opciones son:
1. "use_tool" â€” usar una herramienta para obtener datos. Solo cuando necesitas datos reales.
2. "ask_user" â€” hacer UNA pregunta especÃ­fica al usuario para obtener un dato faltante.
3. "show_draft" â€” mostrar borrador de confirmaciÃ³n (solo para acciones de escritura).
4. "answer" â€” generar la respuesta final para el usuario usando los datos recolectados.

REGLAS IMPORTANTES:
- Nunca inventes datos. Si no tienes un dato, usa una tool o pregunta al usuario.
- Si ya tienes todos los datos necesarios, responde directamente con "answer".
- La respuesta en "answer" debe ser en lenguaje natural, clara y concisa.
- Para acciones (entrada, venta, etc.), SIEMPRE usar "show_draft" antes de ejecutar.
- Cuando uses datos del sistema en la respuesta, presÃ©ntalo de forma amigable.
- Para registrar una venta, el nombre del cliente se usa como texto. No busques el cliente en la base de datos, solo tomÃ¡ el nombre tal cual el usuario lo menciona. ReconocÃ© patrones como "a [nombre]", "para [nombre]".
- Para buscar un producto por nombre, usa 'entity_resolver.resolveProduct'. Nunca le pidas al usuario un ID de producto.
- Para el tipo de venta, interpreta el significado del mensaje y devuelve `saleType` como el valor normalizado del dominio: `Fiado` cuando la venta queda pendiente o con abono parcial, `Contado` cuando se paga completa al momento.
- Cuando el usuario mencione un abono o monto parcial ("me abono", "pagó", "dejó", "adelanto"), extraé EL VALOR NUMÉRICO exacto e incluilo como `depositAmount` en los parámetros. Por ejemplo, "me abono 200" → depositAmount: 200.
- El `depositAmount` debe incluirse SIEMPRE en los params, tanto al usar `show_draft` como al llamar a `usecase.registrarVenta`.
- IMPORTANTE: Si el usuario dice "Vendi 2 desodorantes a Ronald Perez, me abono 200 y los vendi a 150 cada uno":
  - Items: [{"productName":"desodorantes","quantity":2,"price":150}]
  - clientName: "Ronald Perez"
  - depositAmount: 200
  - saleType: "Fiado"
  - El total es 300 y el abono es 200, por lo tanto saleType debe ser "Fiado" y el cliente queda debiendo 100.
- Antes de usar 'ask_user', revisÃ¡ todo el mensaje del usuario, el historial ({messageHistory}) y los datos recolectados ({collectedData}). Si el usuario ya mencionÃ³ cantidad, producto, cliente o tipo de venta en cualquier mensaje anterior, no se lo preguntes de nuevo.
- Cuando uses 'ask_user', SIEMPRE incluÃ­ 'field_name' con el nombre del dato que estÃ¡s pidiendo (ej: "productQuery", "clientName", "quantity", "saleType"). Es OBLIGATORIO para que el sistema pueda seguir el hilo de la conversaciÃ³n.

FORMATO DE RESPUESTA (JSON):
DEBES responder ÃšNICAMENTE con JSON vÃ¡lido:
{"action":"use_tool | ask_user | show_draft | answer","tool":"tool_id si action==use_tool","params":{},"question":"pregunta si action==ask_user","field_name":"nombre_variable si action==ask_user (OBLIGATORIO)","answer":"texto de respuesta si action==answer","reasoning":"por quÃ© elegiste esta acciÃ³n"}
''';

  StepwiseOrchestrator({
    required LLMClient llm,
    required ToolExecutor toolExecutor,
    required WorkflowLoader workflowLoader,
    int? maxIterations,
  }) : _llm = llm,
       _toolExecutor = toolExecutor,
       _workflowLoader = workflowLoader,
       _maxIterations =
           maxIterations ?? AppConstants.assistantMaxReactIterations;

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
    final observations = <Map<String, dynamic>>[...workflowState.stepHistory];

    for (int i = 0; i < _maxIterations; i++) {
      // â”€â”€ PIENSA â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
          // Rate limit â€” esperar 2s y reintentar una vez
          await Future.delayed(const Duration(seconds: 2));
          try {
            decisionResponse = await _llm
                .chat(request)
                .timeout(const Duration(seconds: 4));
          } catch (_) {
            return _buildFinalResult(
              'El servicio estÃ¡ ocupado. EsperÃ¡ un momento e intentÃ¡ de nuevo.',
              conversationState,
              currentCollectedData,
            );
          }
        } else {
          rethrow;
        }
      } on Object {
        return _buildFinalResult(
          'La consulta tardÃ³ demasiado. IntentÃ¡ con una pregunta mÃ¡s especÃ­fica.',
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
          'RecibÃ­ una respuesta inesperada. IntentÃ¡ de nuevo.',
          conversationState,
          currentCollectedData,
        );
      }

      // â”€â”€ ACTÃšA â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
      switch (decision.action) {
        case ReactAction.useTool:
          if (decision.toolId == null) continue;

          final toolResult = await _toolExecutor.execute(
            toolId: decision.toolId!,
            params: decision.toolParams ?? {},
            operationalContext: operationalContext,
            collectedData: currentCollectedData,
          );

          // Â¿La tool requiere borrador?
          if (toolResult.isSuccess &&
              toolResult.data is Map &&
              toolResult.data['__requires_draft'] == true) {
            return _buildDraftResult(
              _normalizeDraftData(
                toolResult.data as Map<String, dynamic>,
                currentCollectedData,
                workflowState,
                userMessage,
              ),
              conversationState,
              currentCollectedData,
              workflowState,
            );
          }

          // Â¿La tool pide un dato al usuario?
          if (toolResult.needsUserInput) {
            return _buildAskUserResult(
              toolResult.userQuestion!,
              null,
              conversationState,
              currentCollectedData,
              workflowState,
            );
          }

          // Â¿Resultado ambiguo? (ej: mÃºltiples productos con ese nombre)
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
              'Â¿CuÃ¡l de estos querÃ©s consultar?',
              candidateNames,
              conversationState,
              currentCollectedData,
              workflowState,
            );
          }

          // â”€â”€ OBSERVA: guardar resultado â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
            decision.userQuestion ?? 'Â¿PodÃ©s darme mÃ¡s detalles?',
            decision.fieldName,
            conversationState,
            currentCollectedData,
            workflowState,
          );

        case ReactAction.showDraft:
          return _buildDraftResult(
            _normalizeDraftData(
              {'__draft_type': 'generic', ...?decision.toolParams},
              currentCollectedData,
              workflowState,
              userMessage,
            ),
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
            'No pude completar esa acciÃ³n. IntentÃ¡ de nuevo.',
            conversationState,
            currentCollectedData,
          );
      }
    }

    // MÃ¡ximo de iteraciones alcanzado
    return _buildFinalResult(
      'No pude completar la consulta en el tiempo esperado. '
      'IntentÃ¡ con una pregunta mÃ¡s especÃ­fica.',
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

  // â”€â”€ Helpers privados â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

    final recentHistory = conversationState.messageHistory.reversed
        .take(4)
        .toList()
        .reversed
        .map((t) => '${t.role}: ${t.content}')
        .join('\n');

    final systemPrompt =
        '''
Eres el Secretario IA de un sistema de inventario. RespondÃ© de forma natural, clara y concisa.
UsÃ¡ los datos del sistema para respaldar tu respuesta. No inventes informaciÃ³n.

EMPRESA: ${operationalContext.empresaId}
BODEGA: ${operationalContext.selectedWarehouseId ?? 'no seleccionada'}
MONEDA: CÃ³rdobas

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
  ) => TurnResult(
    responseText: text,
    updatedState: state.copyWith(collectedData: collectedData),
  );

  TurnResult _buildAskUserResult(
    String question,
    String? fieldName,
    ConversationState state,
    Map<String, CollectedVariable> collectedData,
    WorkflowState workflowState,
  ) => TurnResult(
    responseText: question,
    updatedState: state.copyWith(
      collectedData: collectedData,
      activeWorkflow: workflowState.copyWith(
        pendingField: fieldName ?? '_ask_user_response',
      ),
    ),
  );

  TurnResult _buildClarifyResult(
    String question,
    List<String> options,
    ConversationState state,
    Map<String, CollectedVariable> collectedData,
    WorkflowState workflowState,
  ) => TurnResult(
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
  ) => TurnResult(
    responseText: 'Revisá el borrador antes de confirmar.',
    updatedState: state.copyWith(collectedData: collectedData),
    requiresConfirmation: true,
    draft: draftData,
  );

  Map<String, dynamic> _normalizeDraftData(
    Map<String, dynamic> draftData,
    Map<String, CollectedVariable> collectedData,
    WorkflowState workflowState,
    String userMessage,
  ) {
    final normalized = Map<String, dynamic>.from(draftData);
    if (normalized['__draft_type'] == 'generic') {
      normalized['__draft_type'] =
          workflowState.intentType == 'action_register_entry'
          ? 'inventory_entry'
          : 'sale';
    }

    final rawItems = normalized['items'];
    if (rawItems is List) {
      normalized['items'] = rawItems
          .whereType<Map>()
          .map(
            (item) => _normalizeDraftItem(
              item.cast<String, dynamic>(),
              collectedData,
            ),
          )
          .toList();
    }

    normalized['client_name'] ??=
        normalized['clientName'] ??
        normalized['clientQuery'] ??
        normalized['nombreCliente'] ??
        _stringFromCollectedData(collectedData, [
          'clientName',
          'client_name',
          'clientQuery',
          'nombreCliente',
          'client',
        ]);
    normalized['deposit_amount'] ??=
        normalized['depositAmount'] ??
        normalized['abono'] ??
        normalized['montoAbonado'] ??
        _numFromCollectedData(collectedData, [
          'depositAmount',
          'deposit_amount',
          'abono',
          'montoAbonado',
        ]);

    if (normalized['deposit_amount'] == null &&
        normalized['__draft_type'] == 'sale') {
      normalized['deposit_amount'] = _extractAbonoFromMessage(userMessage);
    }
    normalized['sale_type'] ??=
        normalized['saleType'] ??
        normalized['tipoVenta'] ??
        _stringFromCollectedData(collectedData, [
          'saleType',
          'sale_type',
          'tipoVenta',
          '__draft_sale_type',
        ]);

    return normalized;
  }

  Map<String, dynamic> _normalizeDraftItem(
    Map<String, dynamic> item,
    Map<String, CollectedVariable> collectedData,
  ) {
    final normalized = Map<String, dynamic>.from(item);
    final productId =
        normalized['product_id'] ??
        normalized['productoId'] ??
        normalized['productId'];
    normalized['product_id'] ??= productId;
    normalized['quantity'] ??= normalized['cantidad'] ?? normalized['qty'];
    normalized['unit_price'] ??= normalized['precio'] ?? normalized['price'];
    normalized['unit_cost'] ??= normalized['costo'] ?? normalized['cost'];
    normalized['variant_id'] ??=
        normalized['varianteId'] ?? normalized['variantId'];

    final itemName =
        normalized['product_name'] ??
        normalized['productoNombre'] ??
        normalized['productName'];
    normalized['product_name'] = _isGenericProductName(itemName)
        ? _productNameFromCollectedData(productId?.toString(), collectedData)
        : itemName;

    return normalized;
  }

  String? _stringFromCollectedData(
    Map<String, CollectedVariable> collectedData,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = collectedData[key]?.value;
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value is num || value is bool) return value.toString();
    }
    return null;
  }

  double? _numFromCollectedData(
    Map<String, CollectedVariable> collectedData,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = collectedData[key]?.value;
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value.replaceAll(',', '.'));
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  double? _extractAbonoFromMessage(String message) {
    final normalized = message
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
    final match = RegExp(
      r'(?:abono|abonó|abona|abonar|adelanto|seña|señó)\s*(?:de\s+)?(\d+(?:[.,]\d+)?)',
    ).firstMatch(normalized);
    if (match == null) return null;
    return double.tryParse(match.group(1)!.replaceAll(',', '.'));
  }

  bool _isGenericProductName(dynamic value) {
    if (value is! String || value.trim().isEmpty) return true;
    final normalized = value.trim().toLowerCase();
    return normalized == 'producto' || normalized == 'item';
  }

  String? _productNameFromCollectedData(
    String? productId,
    Map<String, CollectedVariable> collectedData,
  ) {
    if (productId == null || productId.isEmpty) return null;
    for (final variable in collectedData.values) {
      final value = variable.value;
      if (value is! Map) {
        try {
          final dynamic entity = value;
          if (entity.id == productId) return entity.nombre as String?;
        } catch (e, st) {
          AppLogger.error('Error resolviendo nombre de producto', e, st);
        }
        continue;
      }
      final id =
          value['productoId'] ??
          value['product_id'] ??
          value['productId'] ??
          value['id'];
      final name =
          value['productoNombre'] ??
          value['product_name'] ??
          value['productName'] ??
          value['nombre'];
      if (id == productId && name is String) return name;
      final productos = value['productos'];
      if (productos is! List) continue;
      for (final product in productos) {
        if (product is Map && product['productoId'] == productId) {
          return product['productoNombre'] as String?;
        }
      }
    }
    return null;
  }

  String _buildOrchestratorPrompt({
    required String workflowNombre,
    required ConversationState conversationState,
    required AssistantOperationalContext operationalContext,
    required List<Map<String, dynamic>> observations,
    required List<ToolDefinition> toolsCatalog,
  }) {
    final history = conversationState.messageHistory.reversed
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
              .map((o) => 'Step ${o['step']}: ${o['tool']} â†’ ${o['status']}')
              .join('\n');

    final tools = toolsCatalog.map((t) => t.toPromptEntry()).join('\n');

    return _orchestratorSystemPrompt
        .replaceAll('{datetime}', DateTime.now().toIso8601String())
        .replaceAll('{empresaNombre}', operationalContext.empresaId)
        .replaceAll('{usuarioNombre}', operationalContext.usuarioId)
        .replaceAll(
          '{bodegaNombre}',
          operationalContext.selectedWarehouseId ?? 'ninguna',
        )
        .replaceAll(
          '{cajaStatus}',
          operationalContext.hasCashOpen ? 'abierta' : 'cerrada',
        )
        .replaceAll('{workflowNombre}', workflowNombre)
        .replaceAll('{messageHistory}', history.isEmpty ? 'ninguno' : history)
        .replaceAll(
          '{collectedData}',
          collected.isEmpty ? 'ninguno' : collected,
        )
        .replaceAll('{observations}', obs)
        .replaceAll('{toolsCatalog}', tools);
  }

  String _extractDisplayName(dynamic entity) {
    if (entity is Map) {
      return (entity['nombre'] ?? entity['name'] ?? entity.toString())
          as String;
    }
    try {
      return (entity as dynamic).nombre as String;
    } catch (e, st) {
      AppLogger.error('Error extrayendo displayName', e, st);
    }
    return entity.toString();
  }

  String _serializeValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String || value is num || value is bool) {
      return value.toString();
    }
    if (value is Map || value is List) return jsonEncode(value);
    try {
      return jsonEncode((value as dynamic).toJson());
    } catch (e, st) {
      AppLogger.error('Error serializando valor json', e, st);
    }
    return value.toString();
  }
}

// â”€â”€ Provider â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

final stepwiseOrchestratorProvider = Provider<StepwiseOrchestrator>((ref) {
  return StepwiseOrchestrator(
    llm: ref.watch(llmClientProvider),
    toolExecutor: ref.watch(toolExecutorProvider),
    workflowLoader: ref.watch(workflowLoaderProvider),
  );
});
