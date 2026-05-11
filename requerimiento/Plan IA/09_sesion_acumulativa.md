# Sesión acumulativa — Estado de implementación IA

**Última actualización:** 2026-05-07

---

## Estado de los planes (E00–E10)

| Plan | Estado | % |
|------|--------|---|
| Plan 00 — Estructura del módulo | ✅ Completo | 100% |
| Plan 01 — ConversationState + TurnPipeline | ✅ Completo | 100% |
| Plan 02 — Knowledge Base (Supabase) | ✅ Completo | 100% |
| Plan 03 — Cliente OpenAI + Streaming | ✅ Completo | 100% |
| Plan 04 — SemanticRouter + ReasoningEngine | ✅ Completo | 100% |
| Plan 05 — ToolExecutor | ✅ Completo | 100% |
| Plan 06 — StepwiseOrchestrator (ReAct) | ✅ Completo | 100% |
| Plan 07 — Streaming UI | ⚠️ Parcial | ~50% |
| Plan 08 — Borrador y Confirmación | ❌ Pendiente | 0% |
| Plan 09 — PausedWorkflowStack | ⚠️ Parcial | ~40% |
| Plan 10 — Offline Fallback | ❌ Pendiente | 0% |

**Avance total: ~70%**

---

## Detalle de lo que falta

### Plan 07 — Streaming UI (~50%)

Lo implementado: burbujas de chat, cursor parpadeante, input bar, screen con ListView + scroll automático.

**Falta:**
- `AssistantUiState`: agregar campos `pendingQuestion`, `clarificationOptions`, `hasDraft`, `draftData`
- Widget `ClarificationOptionsRow` — chips para que el usuario elija entre candidatos ambiguos
- Widget `DraftCard` — muestra el borrador antes de confirmar (Confirmar / Cancelar)
- Widget `PausedWorkflowBanner` — banner que indica workflow interrumpido activo
- `AssistantNotifier.sendMessage()`: manejar `TurnResult.requiresConfirmation` y `TurnResult.draft`

---

### Plan 08 — Borrador y Confirmación (0%)

**Falta todo:**
- `lib/features/assistant/domain/models/assistant_draft.dart`
  - `enum DraftType { entradaInventario, venta, transferencia }`
  - `class DraftItem { final String label; final String value; }`
  - `class AssistantDraft { final DraftType type; final List<DraftItem> items; final Map<String,dynamic> rawData; }`
- `lib/features/assistant/core/draft_executor.dart`
  - Clase `DraftExecutor` — recibe un `AssistantDraft` y llama al UseCase real correspondiente
  - Integración con `RegistrarEntradaUseCase` y `RegistrarVentaUseCase`
- `lib/features/assistant/presentation/widgets/draft_card.dart`
  - Widget visual con lista de `DraftItem` + botones Confirmar / Cancelar
- Lógica en `TurnPipeline.process()`:
  - Detectar confirmación (`"sí"`, `"confirmar"`, `"ok"`) cuando hay draft activo
  - Detectar cancelación (`"no"`, `"cancelar"`) cuando hay draft activo
  - Llamar `DraftExecutor.execute()` al confirmar

---

### Plan 09 — PausedWorkflowStack (~40%)

Lo implementado: modelos `PausedWorkflow`, `pausedWorkflowStack` en `ConversationState`, getters `hasActiveWorkflow`/`hasPausedWorkflows`.

**Falta:**
- `TurnPipeline._isInterruption()`: detectar si el router devuelve intención distinta con score ≥ 0.65 mientras hay un workflow activo
- `TurnPipeline._handleInterruption()`: pausa workflow actual (push a `pausedWorkflowStack`) e inicia el nuevo
- Widget `PausedWorkflowBanner` en `presentation/widgets/`
- Campo `pausedWorkflowNames` en `AssistantUiState`
- `AssistantNotifier`: exponer `pausedWorkflowNames` en el estado de UI cuando `hasPausedWorkflows == true`

---

### Plan 10 — Offline Fallback (0%)

**Falta todo:**
- `lib/features/assistant/data/connectivity/connectivity_checker.dart`
  - Clase `ConnectivityChecker` con método `isOnline()` (usar `connectivity_plus` o HTTP probe)
- `lib/features/assistant/data/offline/offline_query_handler.dart`
  - Clase `OfflineQueryHandler` con queries directas a Drift (sin OpenAI):
    - stock de producto por bodega
    - precio de producto
    - ventas del día
    - estado de caja
- `lib/features/assistant/presentation/widgets/offline_banner.dart`
  - Banner rojo/naranja en la parte superior del chat cuando `isOffline == true`
- Campo `isOffline` en `AssistantUiState`
- En `TurnPipeline.process()`: verificar `ConnectivityChecker.isOnline()` al inicio y derivar a `OfflineQueryHandler` si no hay red

---

## Orden de ejecución para la próxima sesión

1. **Plan 07 UX restante** — completa la interfaz para que Draft y opciones se muestren
2. **Plan 08 Draft** — crítico para que las acciones de escritura (entradas, ventas) funcionen
3. **Plan 09 Interrupciones** — `_isInterruption()` + `_handleInterruption()` en TurnPipeline + banner
4. **Plan 10 Offline** — independiente, puede ir al final

---

## Archivos clave del módulo (referencia rápida)

```
lib/features/assistant/
├── core/
│   ├── turn_pipeline.dart          ← pipeline principal (E01+E07 completo)
│   ├── semantic_router.dart        ← router de intenciones (E04 completo)
│   ├── reasoning_engine.dart       ← desambiguación de referencias (E04 completo)
│   └── stepwise_orchestrator.dart  ← ciclo ReAct (E06 completo)
├── data/
│   ├── openai/                     ← cliente HTTP + modelos + provider (E03 completo)
│   ├── knowledge/                  ← WorkflowLoader + modelos Supabase (E02 completo)
│   ├── tools/                      ← ToolRegistry + ToolExecutor + ToolResult (E05 completo)
│   ├── context/                    ← AssistantContextBuilder (E03 completo)
│   └── entity_resolver.dart        ← resolución fuzzy de productos/clientes (E05 completo)
├── domain/models/
│   ├── conversation_state.dart     ← estado inmutable + decay (E01 completo)
│   ├── workflow_state.dart         ← estado del workflow activo (E01 completo)
│   ├── paused_workflow.dart        ← modelo de workflow pausado (E09 parcial)
│   └── assistant_operational_context.dart ← contexto empresa/bodega/caja
└── presentation/
    ├── providers/assistant_provider.dart  ← StateNotifier + TurnPipeline
    ├── screens/assistant_screen.dart
    ├── widgets/
    │   ├── chat_message_bubble.dart
    │   ├── chat_input_bar.dart
    │   └── blinking_cursor.dart
    └── models/
        ├── chat_message.dart
        └── assistant_ui_state.dart
```
