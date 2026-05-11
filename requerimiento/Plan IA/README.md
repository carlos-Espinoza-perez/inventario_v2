# Planes de acción — Secretario IA v2
**Arquitectura: Arel-pattern adaptado a Flutter + Drift + GPT-4o-mini**
**Revisión: Mayo 2026 — Reescritura completa**

---

## Cambio de arquitectura respecto a v1

La v1 usaba un parser de reglas (palabras clave). Esta versión usa un **LLM como cerebro**:
el LLM detecta intenciones, razona, decide qué datos pedir, y genera la respuesta en lenguaje natural usando información real del sistema. Los DAOs de Drift son las "herramientas" que el LLM puede invocar. El LLM nunca toca la base de datos directamente.

---

## Índice

| Plan | Contenido |
|---|---|
| [plan_00](plan_00_estructura_modulo.md) | Nueva estructura de carpetas, qué se conserva de v1, qué es nuevo |
| [plan_01](plan_01_conversation_state_turn_pipeline.md) | `ConversationState` (historial, variables, stack de workflows), `TurnPipeline` |
| [plan_02](plan_02_knowledge_base_supabase.md) | Tablas en Supabase, JSON de workflows e intents, `WorkflowLoader` con caché local |
| [plan_03](plan_03_openai_client_streaming.md) | Cliente OpenAI en Dart, streaming SSE, structured outputs |
| [plan_04](plan_04_semantic_router.md) | Router semántico con LLM — reemplaza el parser de reglas. Bandas de confianza, ReasoningEngine |
| [plan_05](plan_05_tool_executor.md) | Catálogo de herramientas (DAOs como tools), `ToolExecutor` |
| [plan_06](plan_06_stepwise_orchestrator_react.md) | Ciclo ReAct: PIENSA → ACTÚA → OBSERVA. Máx. 6 iteraciones |
| [plan_07](plan_07_streaming_ui.md) | Streaming en la UI de Flutter, `AssistantProvider` con estado de stream |
| [plan_08](plan_08_draft_confirmacion.md) | Borrador y confirmación activados por ReAct, unchanged Use Cases |
| [plan_09](plan_09_paused_workflow_stack.md) | Interrupción de workflows, `PausedWorkflowStack`, reanudación automática |
| [plan_10](plan_10_offline_fallback.md) | Modo offline: consultas básicas sin LLM usando solo Drift |
| [plan_11](plan_11_roadmap.md) | Roadmap de 12 entregas con criterios de avance y dependencias reales |

---

## Arquitectura en una imagen

```
[Usuario escribe / habla]
         │
         ▼
   [TurnPipeline]
     │
     ├─ Carga ConversationState (Riverpod)
     │
     ├─ [SemanticRouter] ──── GPT-4o-mini ────▶ { intent, score, entities }
     │       └─ ReasoningEngine (si ambiguo)
     │
     ├─ ¿Score bajo? → pide confirmación
     │
     ├─ Routing:
     │   ├─ ¿Paso pendiente del usuario? → resuelve
     │   ├─ ¿Workflow activo? → continúa
     │   └─ ¿Nuevo intent? → carga workflow de Supabase
     │
     ├─ [StepwiseOrchestrator] — ciclo ReAct (máx. 6 iteraciones)
     │       ├─ PIENSA: GPT-4o-mini con todo el contexto
     │       ├─ ACTÚA: ToolExecutor → DAO de Drift
     │       └─ OBSERVA: guarda resultado en CollectedData
     │
     ├─ Guarda ConversationState
     └─ Streaming de respuesta al usuario
```

---

## Componentes que se conservan de v1

- UI: `AssistantScreen`, burbujas, `AssistantInputBar` — sin cambios
- `AssistantContextBuilder` — sin cambios
- `AssistantDraft` + bottom sheet de confirmación — sin cambios
- `EntityResolver` — ahora funciona como tool del ToolExecutor
- Todos los DAOs de Drift — son las herramientas del agente

## Componentes nuevos o reemplazados

| Componente v1 | Componente v2 | Estado |
|---|---|---|
| `AssistantParser` (reglas) | `SemanticRouter` (LLM) | Reemplazado |
| `AssistantOrchestrator` (lineal) | `StepwiseOrchestrator` (ReAct) | Reemplazado |
| `AssistantState` simple | `ConversationState` completo | Expandido |
| Sin memoria entre turnos | `CollectedData` + `MessageHistory` | Nuevo |
| Sin interrupciones | `PausedWorkflowStack` | Nuevo |
| Sin streaming | Stream SSE de OpenAI | Nuevo |
| Workflows en código Dart | Workflows JSON en Supabase | Nuevo |
