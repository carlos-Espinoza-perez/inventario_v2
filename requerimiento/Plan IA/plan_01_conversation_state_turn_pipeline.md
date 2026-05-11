# Plan 01 - ConversationState y TurnPipeline

---

## Objetivo

Implementar la memoria de la conversación (`ConversationState`) y el orquestador central de cada turno (`TurnPipeline`). Estos son los cimientos sobre los que se construye todo lo demás. Sin estado persistente entre turnos no hay contexto, sin `TurnPipeline` no hay flujo coordinado.

---

## ConversationState — Qué se persiste por sesión

```dart
// lib/features/assistant/domain/models/conversation_state.dart

import 'package:inventario_v2/core/db/app_database.dart';
import 'workflow_state.dart';
import 'paused_workflow.dart';

class ConversationState {
  // ── Workflow activo ─────────────────────────────────────────────────────
  final WorkflowState? activeWorkflow;

  // ── Stack de workflows pausados ─────────────────────────────────────────
  // Cuando el usuario interrumpe un workflow con una pregunta, el workflow
  // se apila aquí y se retoma automáticamente al responder.
  final List<PausedWorkflow> pausedWorkflowStack;

  // ── Variables recolectadas en la sesión ─────────────────────────────────
  // Clave: nombre de variable (ej: "productoId", "bodegaId")
  // Valor: CollectedVariable con el dato, tipo y relevancia
  final Map<String, CollectedVariable> collectedData;

  // ── Historial de mensajes ────────────────────────────────────────────────
  // Solo se guardan los últimos N turnos (configurable por ASSISTANT_HISTORY_TURNS)
  final List<ConversationTurn> messageHistory;

  // ── Última lista mostrada al usuario ────────────────────────────────────
  // Para resolver referencias como "el primero", "ese", "el de arriba"
  final List<NamedEntity> lastShownList;

  // ── Memoria de hechos ────────────────────────────────────────────────────
  // Datos permanentes de la sesión: empresa, bodega preferida, etc.
  final Map<String, String> factMemory;

  const ConversationState({
    this.activeWorkflow,
    this.pausedWorkflowStack = const [],
    this.collectedData = const {},
    this.messageHistory = const [],
    this.lastShownList = const [],
    this.factMemory = const {},
  });

  bool get hasActiveWorkflow => activeWorkflow != null;
  bool get hasPausedWorkflows => pausedWorkflowStack.isNotEmpty;

  ConversationState copyWith({
    WorkflowState? activeWorkflow,
    bool clearActiveWorkflow = false,
    List<PausedWorkflow>? pausedWorkflowStack,
    Map<String, CollectedVariable>? collectedData,
    List<ConversationTurn>? messageHistory,
    List<NamedEntity>? lastShownList,
    Map<String, String>? factMemory,
  }) =>
      ConversationState(
        activeWorkflow:
            clearActiveWorkflow ? null : (activeWorkflow ?? this.activeWorkflow),
        pausedWorkflowStack:
            pausedWorkflowStack ?? this.pausedWorkflowStack,
        collectedData: collectedData ?? this.collectedData,
        messageHistory: messageHistory ?? this.messageHistory,
        lastShownList: lastShownList ?? this.lastShownList,
        factMemory: factMemory ?? this.factMemory,
      );

  /// Agrega un turno al historial y lo trunca si supera el límite
  ConversationState addTurn(ConversationTurn turn, {int maxTurns = 12}) {
    final updated = [...messageHistory, turn];
    return copyWith(
      messageHistory: updated.length > maxTurns
          ? updated.sublist(updated.length - maxTurns)
          : updated,
    );
  }

  /// Aplica decay de relevancia a las variables recolectadas
  ConversationState applyDecay() {
    final decayed = collectedData.map((key, variable) =>
        MapEntry(key, variable.withReducedRelevance()));
    // Eliminar variables con relevancia menor al umbral (excepto permanentes)
    final pruned = Map.fromEntries(
      decayed.entries.where((e) =>
          e.value.type == VariableType.permanent || e.value.relevance > 0.1),
    );
    return copyWith(collectedData: pruned);
  }
}

// ── Modelos auxiliares ──────────────────────────────────────────────────────

enum VariableType {
  transient,  // Se elimina al completar el workflow
  session,    // Dura toda la sesión (timeout)
  permanent,  // Nunca se elimina (empresa, usuario)
}

class CollectedVariable {
  final dynamic value;
  final VariableType type;
  final double relevance; // 0.0 – 1.0

  const CollectedVariable({
    required this.value,
    required this.type,
    this.relevance = 1.0,
  });

  CollectedVariable withReducedRelevance() => CollectedVariable(
        value: value,
        type: type,
        relevance: (relevance * 0.85).clamp(0.0, 1.0),
      );

  // Auto-detectar tipo por nombre de variable (convención)
  static VariableType inferType(String key) {
    if (key.endsWith('Id') || key.startsWith('selected')) {
      return VariableType.session;
    }
    if (key.startsWith('_search') || key.startsWith('_temp')) {
      return VariableType.transient;
    }
    return VariableType.session;
  }
}

class ConversationTurn {
  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime timestamp;

  const ConversationTurn({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, String> toOpenAIMessage() => {
        'role': role,
        'content': content,
      };
}

class NamedEntity {
  final String id;
  final String displayName;
  final String type; // 'product' | 'client' | 'warehouse'

  const NamedEntity({
    required this.id,
    required this.displayName,
    required this.type,
  });
}
```

---

## WorkflowState — Estado del workflow activo

```dart
// lib/features/assistant/domain/models/workflow_state.dart

class WorkflowState {
  final String workflowId;       // ID del workflow en Supabase
  final String intentType;       // intent que activó este workflow
  final int currentStepIndex;    // paso actual en ejecución
  final String? pendingField;    // campo esperando respuesta del usuario (ask_user)
  final List<Map<String, dynamic>> stepHistory; // observaciones de pasos anteriores

  const WorkflowState({
    required this.workflowId,
    required this.intentType,
    this.currentStepIndex = 0,
    this.pendingField,
    this.stepHistory = const [],
  });

  bool get isAwaitingUser => pendingField != null;

  WorkflowState copyWith({
    int? currentStepIndex,
    String? pendingField,
    bool clearPendingField = false,
    List<Map<String, dynamic>>? stepHistory,
  }) =>
      WorkflowState(
        workflowId: workflowId,
        intentType: intentType,
        currentStepIndex: currentStepIndex ?? this.currentStepIndex,
        pendingField: clearPendingField ? null : (pendingField ?? this.pendingField),
        stepHistory: stepHistory ?? this.stepHistory,
      );
}
```

---

## PausedWorkflow — Para el stack de interrupciones

```dart
// lib/features/assistant/domain/models/paused_workflow.dart

class PausedWorkflow {
  final WorkflowState state;
  final Map<String, CollectedVariable> collectedDataSnapshot;
  final DateTime pausedAt;
  final String pauseReason;

  const PausedWorkflow({
    required this.state,
    required this.collectedDataSnapshot,
    required this.pausedAt,
    required this.pauseReason,
  });
}
```

---

## TurnPipeline — El orquestador de cada mensaje

```dart
// lib/features/assistant/core/turn_pipeline.dart

import 'package:inventario_v2/features/assistant/data/assistant_context_builder.dart';
import 'package:inventario_v2/features/assistant/data/knowledge/workflow_loader.dart';
import '../domain/models/conversation_state.dart';
import '../domain/models/workflow_state.dart';
import '../domain/models/paused_workflow.dart';
import 'semantic_router.dart';
import 'stepwise_orchestrator.dart';

enum TurnRouting {
  resolvePendingField,   // hay un campo esperando respuesta del usuario
  continueWorkflow,      // hay un workflow activo, continuar
  pauseAndAnswer,        // interrumpir workflow activo para responder consulta
  startNewWorkflow,      // nuevo intent, cargar workflow
  directAnswer,          // consulta simple sin workflow (greeting, unsupported)
}

class TurnResult {
  final String responseText;          // texto final para mostrar al usuario
  final Stream<String>? responseStream; // stream si hay streaming activo
  final ConversationState updatedState;
  final bool requiresConfirmation;    // si hay borrador pendiente
  final dynamic draft;                // AssistantDraft si aplica

  const TurnResult({
    required this.responseText,
    required this.updatedState,
    this.responseStream,
    this.requiresConfirmation = false,
    this.draft,
  });
}

class TurnPipeline {
  final SemanticRouter _router;
  final StepwiseOrchestrator _orchestrator;
  final WorkflowLoader _workflowLoader;
  final AssistantContextBuilder _contextBuilder;

  const TurnPipeline({
    required SemanticRouter router,
    required StepwiseOrchestrator orchestrator,
    required WorkflowLoader workflowLoader,
    required AssistantContextBuilder contextBuilder,
  });

  Future<TurnResult> process(
    String userMessage,
    ConversationState state,
  ) async {
    // 1. Cargar contexto operativo (empresa, permisos, bodega, caja)
    final context = await _contextBuilder.build();
    if (!context.isValid) {
      return TurnResult(
        responseText: 'No hay sesión activa. Iniciá sesión antes de usar el Secretario.',
        updatedState: state,
      );
    }

    // 2. Aplicar decay de relevancia a variables antiguas
    var currentState = state.applyDecay();

    // 3. Detectar routing
    final routing = _decideRouting(userMessage, currentState);

    // 4. Ejecutar según routing
    switch (routing) {
      case TurnRouting.resolvePendingField:
        return _resolvePendingField(userMessage, currentState, context);

      case TurnRouting.pauseAndAnswer:
        return _pauseAndAnswer(userMessage, currentState, context);

      case TurnRouting.continueWorkflow:
      case TurnRouting.startNewWorkflow:
        // Ambos casos pasan por el router semántico y el orquestador
        final routeResult = await _router.route(userMessage, currentState);

        // Si confianza baja, pedir confirmación al usuario
        if (routeResult.score < 0.40) {
          return TurnResult(
            responseText: 'No entendí bien eso. ¿Podés reformularlo?',
            updatedState: currentState,
          );
        }
        if (routeResult.score < 0.65) {
          return TurnResult(
            responseText: 'Creo que querés ${routeResult.intentDescription}. '
                '¿Es correcto?',
            updatedState: currentState.copyWith(
              collectedData: {
                ...currentState.collectedData,
                '_pendingConfirmation': CollectedVariable(
                  value: routeResult.toJson(),
                  type: VariableType.transient,
                ),
              },
            ),
          );
        }

        // Cargar workflow
        WorkflowState workflowState;
        if (routing == TurnRouting.continueWorkflow) {
          workflowState = currentState.activeWorkflow!;
        } else {
          final workflowDef =
              await _workflowLoader.load(routeResult.workflowId);
          workflowState = WorkflowState(
            workflowId: workflowDef.id,
            intentType: routeResult.intent,
          );
          // Agregar entidades detectadas a CollectedData
          for (final entry in routeResult.entities.entries) {
            currentState = currentState.copyWith(
              collectedData: {
                ...currentState.collectedData,
                entry.key: CollectedVariable(
                  value: entry.value,
                  type: CollectedVariable.inferType(entry.key),
                ),
              },
            );
          }
        }

        return _orchestrator.execute(
          userMessage: userMessage,
          workflowState: workflowState,
          conversationState: currentState,
          operationalContext: context,
        );

      case TurnRouting.directAnswer:
        // Saludos, unsupported, etc. — el orquestador responde sin workflow
        return _orchestrator.executeDirectAnswer(
          userMessage: userMessage,
          conversationState: currentState,
          operationalContext: context,
        );
    }
  }

  TurnRouting _decideRouting(String message, ConversationState state) {
    // 1. Si hay un campo pendiente del usuario, tiene prioridad absoluta
    if (state.activeWorkflow?.isAwaitingUser == true) {
      return TurnRouting.resolvePendingField;
    }

    // 2. Si hay un workflow activo, verificar si el mensaje es una interrupción
    if (state.hasActiveWorkflow) {
      // Heurística simple: si el mensaje parece una consulta distinta al workflow,
      // pausar y responder. El router semántico confirma en el step.
      return TurnRouting.pauseAndAnswer;
    }

    // 3. Si hay workflows pausados y el mensaje retoma la conversación
    // (el orquestador maneja la reanudación automática)
    if (state.hasPausedWorkflows) {
      return TurnRouting.startNewWorkflow;
    }

    return TurnRouting.startNewWorkflow;
  }

  Future<TurnResult> _resolvePendingField(
    String message,
    ConversationState state,
    dynamic context,
  ) async {
    final workflow = state.activeWorkflow!;
    final field = workflow.pendingField!;

    final updatedState = state.copyWith(
      collectedData: {
        ...state.collectedData,
        field: CollectedVariable(
          value: message.trim(),
          type: CollectedVariable.inferType(field),
        ),
      },
      activeWorkflow: workflow.copyWith(clearPendingField: true),
    );

    // Retomar el workflow desde donde quedó
    return _orchestrator.execute(
      userMessage: message,
      workflowState: updatedState.activeWorkflow!,
      conversationState: updatedState,
      operationalContext: context,
    );
  }

  Future<TurnResult> _pauseAndAnswer(
    String message,
    ConversationState state,
    dynamic context,
  ) async {
    // Pausar workflow activo
    final paused = PausedWorkflow(
      state: state.activeWorkflow!,
      collectedDataSnapshot: Map.from(state.collectedData),
      pausedAt: DateTime.now(),
      pauseReason: message,
    );

    var stateWithPause = state.copyWith(
      clearActiveWorkflow: true,
      pausedWorkflowStack: [...state.pausedWorkflowStack, paused],
    );

    // Procesar como nuevo turno
    final routeResult = await _router.route(message, stateWithPause);
    final workflowDef = await _workflowLoader.load(routeResult.workflowId);

    final result = await _orchestrator.execute(
      userMessage: message,
      workflowState: WorkflowState(
        workflowId: workflowDef.id,
        intentType: routeResult.intent,
      ),
      conversationState: stateWithPause,
      operationalContext: context,
    );

    // Si el workflow de interrupción terminó, retomar el pausado automáticamente
    final finalState = result.updatedState;
    if (!finalState.hasActiveWorkflow && finalState.hasPausedWorkflows) {
      final resuming = finalState.pausedWorkflowStack.last;
      final newStack = finalState.pausedWorkflowStack
          .sublist(0, finalState.pausedWorkflowStack.length - 1);

      final resumeMessage =
          'Retomando lo que estabas haciendo: ${resuming.state.intentType}';

      return TurnResult(
        responseText: '${result.responseText}\n\n↩️ $resumeMessage',
        responseStream: result.responseStream,
        updatedState: finalState.copyWith(
          activeWorkflow: resuming.state,
          pausedWorkflowStack: newStack,
          collectedData: {
            ...finalState.collectedData,
            ...resuming.collectedDataSnapshot,
          },
        ),
      );
    }

    return result;
  }
}
```

---

## Provider de estado en Riverpod

```dart
// En assistant_provider.dart

class AssistantUiState {
  final List<AssistantMessage> messages;
  final bool isLoading;
  final bool isStreaming;
  final ConversationState conversationState;
  final AssistantDraft? pendingDraft;

  const AssistantUiState({
    this.messages = const [],
    this.isLoading = false,
    this.isStreaming = false,
    this.conversationState = const ConversationState(),
    this.pendingDraft,
  });
}
```

---

## Criterio de cierre

- [ ] `ConversationState` serializable con `copyWith` completo
- [ ] `messageHistory` se trunca a `ASSISTANT_HISTORY_TURNS` turnos
- [ ] `applyDecay()` reduce relevancia de variables en cada turno
- [ ] `TurnPipeline.process()` enruta correctamente los 5 tipos de routing
- [ ] Workflow pausado se retoma automáticamente al completar la interrupción
- [ ] Variables se auto-tipan por nombre (convención `*Id` → session, `_temp*` → transient)
