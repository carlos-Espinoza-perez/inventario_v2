# Plan 11 - Roadmap de Entregas

---

## Visión general

12 entregas incrementales. Cada entrega produce algo que funciona y se puede demostrar. Las entregas 1-4 son el núcleo — sin ellas nada del resto funciona.

**Estimado total:** 8-10 semanas de desarrollo (1 persona, tiempo parcial)

---

## Mapa de dependencias

```
E01 → E02 → E03 → E04 (núcleo — bloquea todo)
                    │
            ┌───────┼───────────┐
            ▼       ▼           ▼
           E05     E06         E07
            │       │           │
            ▼       ▼           │
           E08     E09          │
            │                   │
            └─────────┬─────────┘
                       ▼
                      E10 → E11 → E12
```

---

## Las 12 entregas

### Entrega 01 — Estructura base y pantalla de chat vacía
**Archivos a crear:**
- `lib/features/assistant/` (estructura completa de carpetas del plan_00)
- `lib/features/assistant/presentation/screens/assistant_screen.dart`
- `lib/features/assistant/presentation/widgets/chat_message_bubble.dart`
- `lib/features/assistant/presentation/widgets/chat_input_bar.dart`
- `lib/features/assistant/presentation/widgets/blinking_cursor.dart`
- `lib/features/assistant/presentation/models/chat_message.dart`
- `lib/features/assistant/presentation/models/assistant_ui_state.dart`
- Agregar ruta `/assistant` dentro del `ShellRoute` en `app_router.dart`
- Conectar botón IA en `BottomAppBarDashboard` → `context.push('/assistant')`

**Criterio:** Puedo navegar al asistente desde el BottomBar. Aparece la pantalla con input. Escribir algo y enviar muestra el mensaje del usuario en la lista. Sin backend aún.

---

### Entrega 02 — ConversationState y TurnPipeline (esqueleto)
**Archivos a crear:**
- `lib/features/assistant/domain/models/conversation_state.dart`
- `lib/features/assistant/domain/models/workflow_state.dart`
- `lib/features/assistant/domain/models/assistant_operational_context.dart`
- `lib/features/assistant/data/context/assistant_context_builder.dart`
- `lib/features/assistant/core/turn_pipeline.dart` (sin LLM todavía — devuelve eco)
- `lib/features/assistant/presentation/providers/assistant_provider.dart`

**Criterio:** El asistente responde con eco del mensaje del usuario. `ConversationState` se actualiza con cada turno. `AssistantContextBuilder` construye el contexto desde los providers de auth.

---

### Entrega 03 — Cliente OpenAI con streaming
**Archivos a crear:**
- `lib/features/assistant/data/openai/openai_models.dart`
- `lib/features/assistant/data/openai/openai_client.dart`
- `.env` — agregar `OPENAI_API_KEY`, `OPENAI_MODEL=gpt-4o-mini`

**Criterio:** El asistente responde con streaming real de GPT-4o-mini. Ver el cursor parpadeante y los tokens llegando. Respuestas genéricas (sin contexto de inventario todavía).

---

### Entrega 04 — Knowledge Base en Supabase + WorkflowLoader
**Archivos a crear:**
- `lib/features/assistant/data/knowledge/knowledge_models.dart`
- `lib/features/assistant/data/knowledge/workflow_loader.dart`

**Supabase — tablas a crear:**
- `assistant_intent_catalog` con mínimo 7 intents
- `assistant_workflows` con workflows para: query_stock, query_price, query_ventas_dia, query_estado_caja, action_register_entry, action_register_sale, greeting
- `assistant_tools_catalog` con todas las tools del plan_05

**Criterio:** `WorkflowLoader.loadIntentCatalog()` devuelve los intents. `loadToolsCatalog()` devuelve las tools. Caché funciona (segunda llamada no va a Supabase).

---

### Entrega 05 — SemanticRouter + ReasoningEngine
**Archivos a crear:**
- `lib/features/assistant/core/semantic_router.dart`
- `lib/features/assistant/core/reasoning_engine.dart`

**Requiere:** E03 (OpenAI client), E04 (WorkflowLoader)

**Criterio:** Escribir "cuánto stock hay de coca cola" → router devuelve `intent: query_stock_product, score > 0.85, entities: {productQuery: "coca cola"}`. Escribir "ese mismo" después → ReasoningEngine reescribe a "cuánto stock hay de coca cola".

---

### Entrega 06 — ToolExecutor + ToolRegistry
**Archivos a crear:**
- `lib/features/assistant/data/tools/tool_result.dart`
- `lib/features/assistant/data/tools/tool_registry.dart`
- `lib/features/assistant/data/tools/tool_executor.dart`
- `lib/features/assistant/data/entity_resolver.dart`

**Requiere:** E02 (ConversationState), DAOs de inventario y ventas ya existentes

**Criterio:** `ToolExecutor.execute(toolId: 'inventory.getStockPorBodega', params: {...})` devuelve el stock real de Drift. `entity_resolver.resolveProduct("coca cola")` encuentra el producto correcto.

---

### Entrega 07 — StepwiseOrchestrator (ReAct loop)
**Archivos a crear:**
- `lib/features/assistant/core/stepwise_orchestrator.dart`

**Requiere:** E03, E05, E06

**Criterio:** Preguntar "cuánto stock hay de coca cola 500ml?" desencadena el ciclo: router → orchestrator → resolveProduct → getStockPorBodega → respuesta final con streaming. Verificar que el flujo completo funciona end-to-end.

---

### Entrega 08 — Borrador y confirmación
**Archivos a crear:**
- `lib/features/assistant/domain/models/assistant_draft.dart`
- `lib/features/assistant/core/draft_executor.dart`
- `lib/features/assistant/presentation/widgets/draft_card.dart`

**Requiere:** E07

**Criterio:** Decir "vender 3 camisas" → aparece `DraftCard` con el borrador. Tocar "Confirmar" → se ejecuta `RegistrarVentaUseCase`. Tocar "Cancelar" → se descarta sin cambios.

---

### Entrega 09 — PausedWorkflowStack
**Archivos a crear:** (modificaciones en TurnPipeline + TurnResult)
- `lib/features/assistant/presentation/widgets/paused_workflow_banner.dart`

**Requiere:** E07, E08

**Criterio:** Iniciar una entrada de inventario → preguntar el stock de un producto durante el proceso → el asistente responde el stock y vuelve a preguntar por los items de la entrada. El banner de workflow pausado es visible durante la interrupción.

---

### Entrega 10 — Modo offline
**Archivos a crear:**
- `lib/features/assistant/data/connectivity/connectivity_checker.dart`
- `lib/features/assistant/data/offline/offline_query_handler.dart`
- `lib/features/assistant/presentation/widgets/offline_banner.dart`

**Requiere:** E02, E06 (DAOs)

**Criterio:** Desactivar WiFi → el banner offline aparece → consultar stock de un producto → respuesta básica sin LLM. Reactivar WiFi → siguiente consulta usa LLM normalmente.

---

### Entrega 11 — Pulido de UX y manejo de errores
**Mejoras a implementar:**
- Timeout en `StepwiseOrchestrator` si una iteración supera 4s
- Reintentar automáticamente si la API de OpenAI devuelve 429 (rate limit) — espera 2s y reintenta una vez
- Mensaje de error amigable cuando el LLM devuelve JSON malformado
- Scroll automático al último mensaje
- Soporte para mensajes vacíos (el input no envía si está en blanco)
- `ClarificationOptionsRow` con chips scrollables horizontalmente

**Criterio:** El asistente nunca se queda colgado. Todos los errores producen un mensaje amigable. La UX se siente fluida.

---

### Entrega 12 — Intents adicionales y calibración
**Intents a agregar en Supabase (sin cambios de código):**
- `query_historial_producto` — historial de movimientos de un producto
- `query_deuda_cliente` — cuánto debe un cliente específico
- `query_resumen_deudas` — resumen de todos los fiados
- `action_registrar_entrada` — flujo completo de entrada con borrador
- `query_top_productos` — productos más vendidos

**Calibración:**
- Ajustar las descripciones de intents según falsos positivos observados en uso real
- Revisar `_referenceWords` en ReasoningEngine con frases reales de los usuarios
- Ajustar `ASSISTANT_MAX_REACT_ITERATIONS` si el tiempo de respuesta supera 6s en promedio

**Criterio:** El asistente responde correctamente al menos el 90% de las consultas de prueba del conjunto de 20 queries definidas en la calibración.

---

## Criterios de avance entre entregas

| Entrega | No puedo empezar la siguiente hasta que... |
|---|---|
| E01 | La ruta `/assistant` funciona y el BottomBar navega a ella |
| E02 | `ConversationState` es inmutable, `copyWith` funciona, `AssistantContextBuilder` lee los providers de auth |
| E03 | Un mensaje de prueba hardcodeado llega a GPT-4o-mini y la respuesta aparece con streaming en pantalla |
| E04 | `WorkflowLoader` carga los 7 intents desde Supabase en < 2s |
| E05 | `SemanticRouter` clasifica correctamente 10 queries de prueba con score > 0.8 |
| E06 | `entity_resolver.resolveProduct` encuentra productos reales de Drift |
| E07 | El flujo query_stock end-to-end funciona: mensaje → router → orchestrator → Drift → respuesta streaming |
| E08 | DraftCard aparece y desaparece correctamente; Use Case se ejecuta al confirmar |
| E09 | Interrupción y reanudación funciona sin pérdida de contexto |
| E10 | Modo offline activa el banner y responde sin LLM |
| E11 | Ningún flujo de usuario puede colgar el asistente indefinidamente |
| E12 | Calibración completada, entrega a producción |

---

## Variables de entorno necesarias (`.env`)

```
# OpenAI
OPENAI_API_KEY=sk-...
OPENAI_MODEL=gpt-4o-mini
OPENAI_TEMPERATURE=0.2
OPENAI_MAX_TOKENS=1024

# Comportamiento del asistente
ASSISTANT_MAX_REACT_ITERATIONS=6
ASSISTANT_HISTORY_TURNS=12
```

---

## Estimado de tiempos

| Entregas | Semanas estimadas | Complejidad |
|---|---|---|
| E01 + E02 | 1 semana | Baja — solo estructura y modelos |
| E03 + E04 | 1 semana | Media — HTTP + Supabase |
| E05 + E06 | 2 semanas | Alta — integración LLM + DAOs |
| E07 | 1-2 semanas | Alta — ciclo ReAct completo |
| E08 + E09 | 1 semana | Media — flujos de confirmación |
| E10 + E11 | 1 semana | Baja — modo offline + pulido |
| E12 | 1 semana | Media — calibración + nuevos intents |
| **Total** | **8-10 semanas** | |
