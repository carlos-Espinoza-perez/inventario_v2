# Plan 09 - PausedWorkflowStack — Interrupción y Reanudación

---

## Objetivo

Implementar la capacidad de interrumpir un workflow en curso, responder la consulta del usuario, y reanudar automáticamente el workflow pausado. Es el mecanismo que hace que el Secretario parezca verdaderamente inteligente en conversaciones multi-turno.

---

## El problema que resuelve

Sin `PausedWorkflowStack`:
```
Usuario: "vamos a hacer una entrada"
Secretario: "¿Qué producto?"
Usuario: "espera, cuánto stock hay de camisa?"   ← interrumpe el workflow
Secretario: responde el stock → PIERDE el contexto de la entrada
Usuario tiene que empezar de cero la entrada 😤
```

Con `PausedWorkflowStack`:
```
Usuario: "vamos a hacer una entrada"
Secretario: "¿Qué producto?"
Usuario: "espera, cuánto stock hay de camisa?"   ← interrupción
Secretario: "Tenés 48 unidades de camisa talla M."
            "Por cierto, seguimos con la entrada — ¿qué producto querés ingresar?"
```

---

## Paso 1 — Modelos (ya definidos en plan_01, aquí el detalle de uso)

```dart
// lib/features/assistant/domain/models/workflow_state.dart
// (referencia — ya definido en plan_01)

class PausedWorkflow {
  final WorkflowState workflowState;           // estado pausado
  final Map<String, CollectedVariable> collectedDataSnapshot; // datos del momento

  const PausedWorkflow({
    required this.workflowState,
    required this.collectedDataSnapshot,
  });
}
```

`ConversationState.pausedWorkflowStack` es una `List<PausedWorkflow>` — permite interrupciones anidadas (aunque en práctica raramente hay más de 1 nivel).

---

## Paso 2 — Lógica de interrupción en TurnPipeline

```dart
// lib/features/assistant/core/turn_pipeline.dart
// Sección: detección de interrupción

/// Determina si el mensaje del usuario es una interrupción de un workflow activo.
/// Una interrupción ocurre cuando:
/// 1. Hay un workflow activo con pendingField
/// 2. El mensaje NO responde al pendingField (el router detecta una intención diferente)
bool _isInterruption({
  required RouterResult routerResult,
  required WorkflowState? activeWorkflow,
}) {
  if (activeWorkflow == null) return false;
  if (activeWorkflow.pendingField == null) return false;

  // Si el intent del router es el mismo workflow, no es interrupción
  if (routerResult.workflowId == activeWorkflow.workflowId) return false;

  // Si el router detecta alta confianza en una intención diferente, es interrupción
  return routerResult.score >= 0.65;
}
```

```dart
// En TurnPipeline.process(), después del SemanticRouter:

final routerResult = await _semanticRouter.route(clarifiedMessage, state, context);

if (_isInterruption(routerResult: routerResult, activeWorkflow: state.activeWorkflow)) {
  return await _handleInterruption(
    userMessage: clarifiedMessage,
    routerResult: routerResult,
    conversationState: state,
    operationalContext: context,
  );
}

Future<TurnResult> _handleInterruption({
  required String userMessage,
  required RouterResult routerResult,
  required ConversationState conversationState,
  required AssistantOperationalContext operationalContext,
}) async {
  // 1. Pausar el workflow activo
  final pausedWorkflow = PausedWorkflow(
    workflowState: conversationState.activeWorkflow!,
    collectedDataSnapshot: Map.from(conversationState.collectedData),
  );

  // 2. Estado temporal sin workflow activo para responder la interrupción
  final stateForInterruption = conversationState.copyWith(
    pausedWorkflowStack: [
      ...conversationState.pausedWorkflowStack,
      pausedWorkflow,
    ],
    clearActiveWorkflow: true,
  );

  // 3. Ejecutar el orchestrator para la consulta de interrupción
  final orchestrator = ref.read(stepwiseOrchestratorProvider);
  final interruptionResult = await orchestrator.execute(
    userMessage: userMessage,
    workflowState: WorkflowState(
      workflowId: routerResult.workflowId,
      currentStepIndex: 0,
      pendingField: null,
      stepHistory: [],
    ),
    conversationState: stateForInterruption,
    operationalContext: operationalContext,
  );

  // 4. Después de la interrupción, reanudar el workflow pausado
  final resumePrompt = _buildResumePrompt(pausedWorkflow.workflowState);

  // Adjuntar mensaje de reanudación al resultado
  return interruptionResult.copyWith(
    updatedState: interruptionResult.updatedState.copyWith(
      activeWorkflow: pausedWorkflow.workflowState,
      collectedData: {
        // Fusionar: datos de la interrupción + snapshot del workflow pausado
        ...pausedWorkflow.collectedDataSnapshot,
        ...interruptionResult.updatedState.collectedData,
      },
      pausedWorkflowStack: conversationState.pausedWorkflowStack, // restaurar stack anterior
    ),
    resumeHint: resumePrompt,
  );
}

String _buildResumePrompt(WorkflowState pausedWorkflow) {
  if (pausedWorkflow.pendingField == null) return '';
  return 'Continuemos con lo anterior — '
      '${_getPendingFieldQuestion(pausedWorkflow.pendingField!)}';
}
```

---

## Paso 3 — TurnResult con resumeHint

```dart
// Agregar a TurnResult en assistant_provider.dart:

class TurnResult {
  final String responseText;
  final Stream<String>? responseStream;
  final ConversationState updatedState;
  final bool requiresConfirmation;
  final Map<String, dynamic>? draft;
  final List<String>? clarificationOptions;
  final String? resumeHint; // ← NUEVO: texto que recuerda al usuario dónde estaba

  const TurnResult({
    this.responseText = '',
    this.responseStream,
    required this.updatedState,
    this.requiresConfirmation = false,
    this.draft,
    this.clarificationOptions,
    this.resumeHint,
  });

  TurnResult copyWith({
    String? responseText,
    Stream<String>? responseStream,
    ConversationState? updatedState,
    bool? requiresConfirmation,
    Map<String, dynamic>? draft,
    List<String>? clarificationOptions,
    String? resumeHint,
  }) => TurnResult(
    responseText: responseText ?? this.responseText,
    responseStream: responseStream ?? this.responseStream,
    updatedState: updatedState ?? this.updatedState,
    requiresConfirmation: requiresConfirmation ?? this.requiresConfirmation,
    draft: draft ?? this.draft,
    clarificationOptions: clarificationOptions ?? this.clarificationOptions,
    resumeHint: resumeHint ?? this.resumeHint,
  );

  bool get isStreaming => responseStream != null;
}
```

---

## Paso 4 — Indicador de workflow pausado en la UI

Cuando hay un workflow en `pausedWorkflowStack`, mostrar un banner sutil que avisa al usuario.

```dart
// lib/features/assistant/presentation/widgets/paused_workflow_banner.dart

import 'package:flutter/material.dart';

class PausedWorkflowBanner extends StatelessWidget {
  final String workflowName;

  const PausedWorkflowBanner({super.key, required this.workflowName});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.pause_circle_outline,
            size: 14,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          const SizedBox(width: 6),
          Text(
            'Workflow pausado: $workflowName',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}
```

En `AssistantUiState` agregar:
```dart
final List<String> pausedWorkflowNames; // nombres de workflows pausados
```

En `AssistantScreen` mostrar el banner cuando hay workflows pausados:
```dart
if (state.pausedWorkflowNames.isNotEmpty)
  PausedWorkflowBanner(workflowName: state.pausedWorkflowNames.last),
```

---

## Paso 5 — `ConversationState.copyWith` para el stack

```dart
// En ConversationState (plan_01):

ConversationState copyWith({
  List<ConversationTurn>? messageHistory,
  WorkflowState? activeWorkflow,
  bool clearActiveWorkflow = false,
  Map<String, CollectedVariable>? collectedData,
  List<PausedWorkflow>? pausedWorkflowStack,
  List<NamedEntity>? lastShownList,
  Map<String, dynamic>? factMemory,
}) =>
    ConversationState(
      messageHistory: messageHistory ?? this.messageHistory,
      activeWorkflow: clearActiveWorkflow ? null : (activeWorkflow ?? this.activeWorkflow),
      collectedData: collectedData ?? this.collectedData,
      pausedWorkflowStack: pausedWorkflowStack ?? this.pausedWorkflowStack,
      lastShownList: lastShownList ?? this.lastShownList,
      factMemory: factMemory ?? this.factMemory,
    );
```

---

## Casos de uso cubiertos

### Caso 1: Interrupción simple

```
Workflow activo: wf_register_entry, pendingField: 'items'
Usuario: "antes de continuar, cuánto stock hay de camisa?"

→ PausedWorkflowStack: [wf_register_entry (pausado)]
→ Responde: "Tenés 48 unidades de camisa talla M."
→ resumeHint: "Continuemos con lo anterior — ¿qué productos querés ingresar?"
→ Workflow activo restaurado: wf_register_entry, pendingField: 'items'
```

### Caso 2: Continuación natural

```
Workflow activo: wf_register_entry, pendingField: 'items'
Usuario: "camisa talla M, 10 unidades"

→ No es interrupción (router detecta misma intención con alta confianza)
→ Resuelve el campo 'items' directamente
→ Continúa el workflow
```

### Caso 3: Interrupción durante borrador

```
Workflow en espera de confirmación (pendingField: '_draft_confirmation')
Usuario: "espera, el precio de la camisa era 15 o 18?"

→ PausedWorkflowStack: [wf_register_sale con draft]
→ Responde: "El precio configurado de Camisa Talla M es $15.00"
→ resumeHint: "Continuemos — tenés el borrador de venta pendiente de confirmar."
→ DraftCard reaparece en UI
```

---

## Criterio de cierre

- [ ] `PausedWorkflowStack` persiste el estado completo del workflow pausado (WorkflowState + CollectedData snapshot)
- [ ] `TurnPipeline._isInterruption()` detecta correctamente cuando el router identifica una intención diferente con score >= 0.65
- [ ] Al responder la interrupción, se restaura el workflow pausado automáticamente
- [ ] `resumeHint` aparece al final de la respuesta de la interrupción recordando al usuario dónde estaba
- [ ] `PausedWorkflowBanner` visible en la UI cuando hay workflows pausados
- [ ] Interrupción durante espera de confirmación de borrador restaura el `DraftCard`
- [ ] Máximo 3 niveles de interrupción para evitar confusión (si hay más de 3, ignorar y continuar)
