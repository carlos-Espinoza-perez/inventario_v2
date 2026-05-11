# Plan 00 - Estructura del módulo Secretario IA v2

---

## Objetivo

Definir la estructura completa de carpetas del módulo `features/assistant` con la arquitectura nueva. Identificar qué se conserva de la planificación v1, qué se reemplaza y qué es completamente nuevo.

---

## Estructura de carpetas completa

```text
lib/features/assistant/
│
├── data/
│   ├── openai/
│   │   ├── openai_client.dart              ← cliente HTTP con streaming (plan_03)
│   │   └── openai_models.dart              ← tipos de request/response OpenAI
│   │
│   ├── knowledge/
│   │   ├── workflow_loader.dart            ← carga workflows desde Supabase + caché (plan_02)
│   │   └── knowledge_models.dart           ← WorkflowDefinition, IntentCatalog, ToolDefinition
│   │
│   ├── tools/
│   │   ├── tool_executor.dart              ← ejecuta tools (DAOs) (plan_05)
│   │   ├── tool_registry.dart              ← catálogo de tools disponibles
│   │   └── tool_result.dart                ← resultado tipado de una tool
│   │
│   ├── assistant_context_builder.dart      ← CONSERVADO de v1 (sin cambios)
│   └── entity_resolver.dart               ← CONSERVADO de v1 (ahora es una tool)
│
├── domain/
│   ├── models/
│   │   ├── assistant_message.dart          ← CONSERVADO (se agrega campo streaming)
│   │   ├── assistant_response.dart         ← CONSERVADO
│   │   ├── assistant_draft.dart            ← CONSERVADO
│   │   ├── assistant_draft_item.dart       ← CONSERVADO
│   │   ├── assistant_operational_context.dart  ← CONSERVADO
│   │   │
│   │   ├── conversation_state.dart         ← NUEVO: historial, variables, stack (plan_01)
│   │   ├── workflow_state.dart             ← NUEVO: estado del workflow activo
│   │   ├── collected_data.dart             ← NUEVO: variables recolectadas en sesión
│   │   └── paused_workflow.dart            ← NUEVO: workflow pausado en stack (plan_09)
│   │
│   └── utils/
│       └── text_normalizer.dart            ← CONSERVADO
│
├── core/
│   ├── turn_pipeline.dart                  ← NUEVO: orquestador principal (plan_01)
│   ├── semantic_router.dart                ← NUEVO: router con LLM (plan_04)
│   ├── reasoning_engine.dart               ← NUEVO: reescribe mensajes ambiguos (plan_04)
│   └── stepwise_orchestrator.dart          ← NUEVO: ciclo ReAct (plan_06)
│
└── presentation/
    ├── providers/
    │   └── assistant_provider.dart         ← MODIFICADO: streaming + ConversationState
    │
    ├── screens/
    │   └── assistant_screen.dart           ← CONSERVADO (ajuste menor para streaming)
    │
    └── widgets/
        ├── assistant_message_bubble.dart   ← CONSERVADO (agrega efecto cursor streaming)
        ├── assistant_input_bar.dart        ← CONSERVADO
        ├── assistant_draft_sheet.dart      ← CONSERVADO
        └── assistant_session_banner.dart   ← CONSERVADO
```

---

## Nueva carpeta `core/`

En v1 toda la lógica vivía en `domain/services/`. Con la arquitectura Arel se agrega una carpeta `core/` dentro del módulo para los componentes de orquestación que no son ni modelos de dominio ni acceso a datos:

- `TurnPipeline` — el coordinador principal de cada mensaje
- `SemanticRouter` — detecta intenciones con LLM
- `ReasoningEngine` — desambigua referencias antes del router
- `StepwiseOrchestrator` — ejecuta el ciclo ReAct

Estos componentes coordinan entre capas pero no pertenecen a ninguna en particular.

---

## Variables de entorno requeridas

Agregar al `.env` del proyecto:

```env
OPENAI_API_KEY=sk-...
OPENAI_MODEL=gpt-4o-mini
OPENAI_MAX_TOKENS=1024
OPENAI_TEMPERATURE=0.2
ASSISTANT_MAX_REACT_ITERATIONS=6
ASSISTANT_HISTORY_TURNS=12
```

Y al `.env.example`:

```env
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_MODEL=gpt-4o-mini
OPENAI_MAX_TOKENS=1024
OPENAI_TEMPERATURE=0.2
ASSISTANT_MAX_REACT_ITERATIONS=6
ASSISTANT_HISTORY_TURNS=12
```

`OPENAI_TEMPERATURE=0.2` es bajo a propósito: el Secretario debe ser preciso y predecible, no creativo.

---

## Dependencias a agregar en pubspec.yaml

```yaml
dependencies:
  # HTTP client para OpenAI (ya tiene el proyecto http o dio?)
  # Verificar si ya existe antes de agregar
  http: ^1.2.0          # si no hay cliente HTTP ya
  
  # Para parsear SSE (Server-Sent Events) del streaming de OpenAI
  # No hay paquete oficial — implementar manualmente con http streams (ver plan_03)
```

No se necesitan paquetes adicionales especializados. El streaming de OpenAI se implementa con `http` nativo de Dart parseando el formato SSE manualmente. Es simple y evita dependencias innecesarias.

---

## Tablas nuevas en Supabase

Se detallan en plan_02. A modo de resumen:

```
assistant_intent_catalog     ← catálogo de intenciones
assistant_workflows          ← definiciones de workflows JSON
assistant_tools_catalog      ← catálogo de tools disponibles
```

---

## Lo que NO cambia en el router ni en la UI

La ruta `/assistant` va dentro del `ShellRoute` exactamente como estaba en v1.
El botón "IA" en `BottomAppBarDashboard` se conecta con `context.push('/assistant')` igual.
La `AssistantScreen` es prácticamente la misma — el único cambio es el efecto de cursor parpadeante durante el streaming.

---

## Criterio de cierre

- [ ] Estructura de carpetas creada (archivos stub)
- [ ] `.env` y `.env.example` con variables de OpenAI
- [ ] Ruta `/assistant` dentro del `ShellRoute`
- [ ] Botón "IA" en `BottomAppBarDashboard` conectado
- [ ] Tablas de Supabase creadas (ver plan_02)
