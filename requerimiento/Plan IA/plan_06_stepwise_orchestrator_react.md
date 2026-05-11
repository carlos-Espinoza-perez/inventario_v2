# Plan 06 - StepwiseOrchestrator — Ciclo ReAct

---

## Objetivo

Implementar el ciclo ReAct (Reasoning + Acting + Observing): el corazón del agente. En cada iteración el LLM recibe todo el contexto y decide qué hacer: usar una tool, pedir un dato al usuario, o responder. El sistema ejecuta la decisión y vuelve a pasar el resultado al LLM. Máximo 6 iteraciones por turno para garantizar el límite de 10 segundos.

---

## El loop ReAct

```
Estado inicial: mensaje del usuario + workflow + CollectedData + historial
      │
      ▼
┌─────────────────────────────────────────────┐
│  PIENSA (LLM)                               │
│  "¿Qué datos tengo? ¿Qué herramienta uso?" │
│  Devuelve: { action, tool, params, reason } │
└─────────────────┬───────────────────────────┘
                  ▼
        ┌─────────────────────┐
        │  ¿Qué action?       │
        ├─────────────────────┤
        │  use_tool           │ → ToolExecutor → DAO → resultado
        │  ask_user           │ → pausa, devuelve pregunta
        │  show_draft         │ → genera borrador, muestra confirmación
        │  answer             │ → LLM genera respuesta final con streaming
        └─────────┬───────────┘
                  ▼
┌─────────────────────────────────────────────┐
│  OBSERVA                                    │
│  Guarda resultado en CollectedData          │
│  Actualiza LastShownList si aplica          │
└─────────────────┬───────────────────────────┘
                  ▼
     ¿action == answer? → FIN
     ¿iteraciones >= 6? → FIN (respuesta de fallback)
                  │
                  └──▶ Vuelve a PIENSA
```

---

## Paso 1 — Modelos del ciclo ReAct

```dart
// lib/features/assistant/core/stepwise_orchestrator.dart (parte superior)

enum ReactAction { useTool, askUser, showDraft, answer, error }

class ReactDecision {
  final ReactAction action;
  final String? toolId;
  final Map<String, dynamic>? toolParams;
  final String? userQuestion;   // si action == askUser
  final String? fieldName;      // nombre de la variable que espera
  final String? answerText;     // si action == answer (texto final)
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
      'use_tool'   => ReactAction.useTool,
      'ask_user'   => ReactAction.askUser,
      'show_draft' => ReactAction.showDraft,
      'answer'     => ReactAction.answer,
      _            => ReactAction.error,
    };
    return ReactDecision(
      action: action,
      toolId: j['tool'] as String?,
      toolParams: j['params'] as Map<String, dynamic>?,
      userQuestion: j['question'] as String?,
      fieldName: j['field_name'] as String?,
      answerText: j['answer'] as String?,
      reasoning: j['reasoning'] as String? ?? '',
    );
  }
}
```

---

## Paso 2 — Prompt del StepwiseOrchestrator

```dart
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
{
  "action": "use_tool | ask_user | show_draft | answer",
  "tool": "tool_id si action==use_tool",
  "params": {} si action==use_tool,
  "question": "pregunta si action==ask_user",
  "field_name": "nombre_variable si action==ask_user",
  "answer": "texto de respuesta si action==answer",
  "reasoning": "por qué elegiste esta acción"
}
''';
```

---

## Paso 3 — StepwiseOrchestrator completo

```dart
// lib/features/assistant/core/stepwise_orchestrator.dart

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../data/openai/openai_client.dart';
import '../data/openai/openai_models.dart';
import '../data/knowledge/workflow_loader.dart';
import '../data/tools/tool_executor.dart';
import '../data/tools/tool_result.dart';
import '../domain/models/conversation_state.dart';
import '../domain/models/workflow_state.dart';
import '../domain/models/assistant_operational_context.dart';
import '../domain/models/assistant_draft.dart';
import '../presentation/providers/assistant_provider.dart'; // TurnResult

class StepwiseOrchestrator {
  final LLMClient _llm;
  final ToolExecutor _toolExecutor;
  final WorkflowLoader _workflowLoader;
  final int _maxIterations;

  StepwiseOrchestrator({
    required LLMClient llm,
    required ToolExecutor toolExecutor,
    required WorkflowLoader workflowLoader,
    int? maxIterations,
  })  : _llm = llm,
        _toolExecutor = toolExecutor,
        _workflowLoader = workflowLoader,
        _maxIterations = maxIterations ??
            int.tryParse(dotenv.env['ASSISTANT_MAX_REACT_ITERATIONS'] ?? '6') ??
            6;

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

    // Loop ReAct
    for (int i = 0; i < _maxIterations; i++) {
      // ── PIENSA ────────────────────────────────────────────────────────────
      final systemPrompt = _buildOrchestratorPrompt(
        workflowNombre: workflowDef.nombre,
        conversationState: conversationState.copyWith(
          collectedData: currentCollectedData,
        ),
        operationalContext: operationalContext,
        observations: observations,
        toolsCatalog: toolsCatalog,
      );

      final decisionResponse = await _llm.chat(OpenAIRequest(
        model: dotenv.env['OPENAI_MODEL'] ?? 'gpt-4o-mini',
        messages: [
          OpenAIMessage.system(systemPrompt),
          OpenAIMessage.user(userMessage),
        ],
        stream: false,
        temperature: 0.2,
        maxTokens: 512,
        responseFormat: {'type': 'json_object'},
      ));

      ReactDecision decision;
      try {
        decision = ReactDecision.fromJson(
          jsonDecode(decisionResponse.content) as Map<String, dynamic>,
        );
      } catch (_) {
        // Si el LLM devuelve JSON inválido, terminar con error
        return _buildFinalResult(
          'Ocurrió un error procesando tu solicitud. Intentá de nuevo.',
          conversationState,
          currentCollectedData,
          workflowState,
        );
      }

      // ── ACTÚA ─────────────────────────────────────────────────────────────
      switch (decision.action) {
        case ReactAction.useTool:
          if (decision.toolId == null) continue;

          // ── OBSERVA ─────────────────────────────────────────────────────
          final toolResult = await _toolExecutor.execute(
            toolId: decision.toolId!,
            params: decision.toolParams ?? {},
            operationalContext: operationalContext,
            collectedData: currentCollectedData,
          );

          // ¿La tool requiere borrador? (usecase.registrarEntrada, etc.)
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

          // Guardar resultado en CollectedData
          if (decision.toolId != null && toolResult.isSuccess) {
            final varName = decision.toolId!.split('.').last; // naming convention
            currentCollectedData = {
              ...currentCollectedData,
              varName: CollectedVariable(
                value: toolResult.data,
                type: CollectedVariable.inferType(varName),
              ),
            };
          }

          // Guardar observación para siguiente iteración
          observations.add({
            'step': i,
            'tool': decision.toolId,
            'status': toolResult.status.name,
            'result': toolResult.toContext(),
            'reasoning': decision.reasoning,
          });

          // Si la tool devolvió ambigüedad, pedir selección al usuario
          if (toolResult.isAmbiguous) {
            final candidateNames = (toolResult.candidates ?? [])
                .map((c) => _extractDisplayName(c))
                .toList();
            return _buildClarifyResult(
              '¿Cuál de estos querés consultar?',
              candidateNames,
              conversationState,
              currentCollectedData,
              workflowState,
            );
          }

          continue; // Siguiente iteración del loop

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
          // ── Respuesta final con streaming ────────────────────────────────
          final finalStream = _generateStreamingAnswer(
            answerInstruction: decision.answerText ?? '',
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
            workflowState,
          );
      }
    }

    // Máximo de iteraciones alcanzado
    return _buildFinalResult(
      'No pude completar la consulta en el tiempo esperado. '
      'Intentá con una pregunta más específica.',
      conversationState,
      currentCollectedData,
      workflowState,
    );
  }

  /// Respuesta directa (saludos, unsupported) — sin workflow
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

  // ── Helpers ──────────────────────────────────────────────────────────────

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

    final systemPrompt = '''
Eres el Secretario IA de un sistema de inventario. Responde de forma natural, clara y concisa.
Usa los datos del sistema para respaldar tu respuesta. No inventes información.

DATOS DEL SISTEMA PARA ESTA RESPUESTA:
$dataSummary

HISTORIAL RECIENTE:
${conversationState.messageHistory.reversed.take(4).toList().reversed.map((t) => '${t.role}: ${t.content}').join('\n')}
''';

    final request = OpenAIRequest(
      model: dotenv.env['OPENAI_MODEL'] ?? 'gpt-4o-mini',
      messages: [
        OpenAIMessage.system(systemPrompt),
        OpenAIMessage.user(answerInstruction),
      ],
      stream: true,
      temperature: 0.3, // un poco más cálido para respuestas al usuario
      maxTokens: int.tryParse(dotenv.env['OPENAI_MAX_TOKENS'] ?? '1024') ?? 1024,
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
    WorkflowState workflowState,
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
          activeWorkflow: workflowState.copyWith(
            pendingField: fieldName,
          ),
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
    required List toolsCatalog,
  }) {
    final history = conversationState.messageHistory
        .reversed.take(6).toList().reversed
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

    final tools = toolsCatalog
        .map((t) => t.toPromptEntry())
        .join('\n');

    return _orchestratorSystemPrompt
        .replaceAll('{datetime}', DateTime.now().toString())
        .replaceAll('{empresaNombre}', operationalContext.empresaId)
        .replaceAll('{usuarioNombre}', operationalContext.usuarioId)
        .replaceAll('{bodegaNombre}', operationalContext.selectedWarehouseId ?? 'ninguna')
        .replaceAll('{cajaStatus}',
            operationalContext.hasCashOpen ? 'abierta' : 'cerrada')
        .replaceAll('{workflowNombre}', workflowNombre)
        .replaceAll('{messageHistory}', history.isEmpty ? 'ninguno' : history)
        .replaceAll('{collectedData}', collected.isEmpty ? 'ninguno' : collected)
        .replaceAll('{observations}', obs)
        .replaceAll('{toolsCatalog}', tools);
  }

  String _extractDisplayName(dynamic entity) {
    try { return (entity as dynamic).nombre as String; } catch (_) {}
    try { return (entity as Map)['nombre'] as String; } catch (_) {}
    return entity.toString();
  }

  String _serializeValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String || value is num || value is bool) return value.toString();
    if (value is Map || value is List) return jsonEncode(value);
    try { return jsonEncode((value as dynamic).toJson()); } catch (_) {}
    return value.toString();
  }
}
```

---

## Garantía de tiempo de respuesta

Con `ASSISTANT_MAX_REACT_ITERATIONS=6` y gpt-4o-mini:
- Cada iteración: ~500ms (decisión) + ~100ms (DAO) = ~600ms
- 6 iteraciones: ~3.6s para la lógica
- Respuesta final con streaming: primeros tokens en ~300ms
- **Total peor caso: ~4.5s** — bien dentro del límite de 10s

---

## Criterio de cierre

- [ ] Loop ReAct con máximo configurable de iteraciones
- [ ] `use_tool` ejecuta el DAO y guarda resultado en `CollectedData`
- [ ] `ask_user` pausa el workflow con `pendingField`
- [ ] `show_draft` activa el flujo de confirmación (plan_08)
- [ ] `answer` inicia streaming de respuesta final
- [ ] Ambigüedad de tool devuelve opciones al usuario
- [ ] Máximo de iteraciones alcanzado devuelve mensaje útil, no crash
