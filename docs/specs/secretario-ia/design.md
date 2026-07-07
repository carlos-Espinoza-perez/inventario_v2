# Diseño Técnico — Secretario con IA

**Tarea:** SEC-IA-001 · Cubre los requerimientos de `requirements.md`.

## 1. Decisión de arquitectura

Nuevo feature **`lib/features/secretary/`** que reemplaza a `lib/features/assistant/`. El viejo se mantiene tras un feature flag hasta paridad (F7 lo elimina). Motivo: el rediseño toca orquestador, estado y persistencia; mezclar produciría un híbrido inestable.

### Qué se reutiliza tal cual

| Componente | Ruta actual | Nota |
|---|---|---|
| Edge Function proxy | `supabase/functions/openai-proxy/index.ts` | Único cambio backend: passthrough de `tools`/`tool_choice` y deltas `tool_calls` en SSE (~15 líneas) |
| STT nativo | `lib/features/assistant/data/speech_to_text_transcriber.dart` | Se mueve a `secretary/voice/`, lógica intacta (partials es_ES) |
| TTS | `lib/features/assistant/data/flutter_tts_service.dart` | Ídem |
| Resolución de entidades | `lib/features/assistant/data/entity_resolver.dart` | Pieza central del dictado (usa `producto.embedding` local) |
| Tools (38+) | `lib/features/assistant/data/tools/tool_registry.dart` | Se conservan; cambia solo su declaración al LLM (JSON Schema) |
| Handler offline | `lib/features/assistant/data/offline/offline_query_handler.dart` | Consultas sin red |
| DAOs / use cases | `InventoryDao`, `SalesDao`, `AuthDao`, `RegistrarVentaUseCase`, `registrarEntrada` | Sin cambios |
| Contexto operativo | `AssistantContextBuilder`, `ConnectivityChecker` | Renombrados |

### Qué se reescribe y por qué

- `StepwiseOrchestrator` + `ReasoningEngine` → **`SecretaryEngine`**: el ReAct casero parsea JSON libre con parches para errores de formato; function calling nativo elimina esa fragilidad y habilita tool calls paralelos + streaming en la misma llamada.
- `ConversationState` (RAM) → **`ChatRepository`** sobre Drift: la persistencia es requerimiento; el estado en RAM queda como caché del turno.
- `DraftExecutor` + `AssistantEntrySessions` → **`DraftEngine`** genérico con adapters por tipo.
- `SemanticRouter`: se conserva degradado a **pre-filtro de tools** (no router de intents).

## 2. Estructura de directorios

```
lib/features/secretary/
├── domain/
│   ├── models/           # chat_models, draft_models, memory_models, secretary_prefs
│   └── services/         # interfaces (SpeechTranscriber, TtsService reexportadas)
├── data/
│   ├── repositories/     # chat_repository, memory_repository, prefs_repository, draft_repository
│   └── llm/              # llm_client (tools + SSE tool_calls), function_schemas
├── engine/
│   ├── secretary_engine.dart         # loop function calling (reemplaza StepwiseOrchestrator)
│   ├── system_prompt_builder.dart    # persona + prefs + memorias + contexto + resumen
│   ├── context_window_manager.dart   # ventana de mensajes + presupuesto tokens
│   ├── session_summarizer.dart       # rolling summary asíncrono
│   └── memory_extractor.dart         # extracción de hechos post-conversación
├── voice/
│   ├── voice_session_controller.dart # idle→listening→thinking→speaking, barge-in
│   ├── dictation_controller.dart     # modo dictado continuo
│   └── dictation_parser.dart         # parser local rápido por segmento
├── drafts/
│   ├── draft_engine.dart             # motor genérico de borradores
│   └── adapters/                     # entrada_draft_adapter, venta_draft_adapter, ajuste_draft_adapter
└── presentation/
    ├── providers/   # secretary_chat, chat_sessions, voice_session, draft (family), secretary_prefs
    ├── screens/     # secretary_chat_screen, chat_sessions_screen, secretary_prefs_screen
    └── widgets/     # draft_table_card (tabla editable), message_bubble, voice_hud
```

## 3. Modelo de datos

### 3.1 Tablas Drift nuevas — `lib/core/db/tables/secretary_tables.dart` (schemaVersion 7 → 8)

Sincronizadas (con mixin `SyncTable` de `lib/core/db/tables/sync_table.dart`):

**`ChatSessions`**: `empresaId` FK, `usuarioId` FK, `title` (autogenerado del primer mensaje), `summary` nullable (rolling), `status` (`active|archived`), `lastMessageAt`, `messageCount`, `metadataJson` nullable.

**`ChatMessages`**: `sessionId` FK cascade, `empresaId`, `usuarioId` (desnormalizado para RLS/push), `role` (`user|assistant`), `content`, `contentType` (`text|draft_card|query_result`), `draftId` nullable, `seq` (orden en la sesión).

**`AiMemories`**: `empresaId`, `usuarioId`, `scope` (`user|business`), `category` (`preference|fact|rule|correction`), `content` (1 frase), `sourceSessionId` nullable, `confidence` real default 1.0, `isActive` bool default true, `lastUsedAt` nullable.

**`AiPreferences`** (única por usuario, unique index `empresaId+usuarioId`): `tone` default `'neutral'`, `verbosity` default `'concise'`, `defaultBodegaId` nullable FK, `voiceEnabled` default true, `autoReadResponses` default false, `ttsRate` default 1.0, `confirmBeforeExecute` default true, `extraJson` nullable.

Solo locales (sin mixin, NO sincronizan):

**`ChatTurnTraces`**: `id, messageId, toolCallsJson, toolResultsJson, latencyMs, tokensIn, tokensOut, model, createdAt`. Limpieza al arranque: borrar > 14 días.

**`SecretaryDrafts`**: `id, empresaId, usuarioId, sessionId, draftType` (`entrada|venta|ajuste|transferencia`), `status` (`active|confirmed|discarded|executed`), `bodegaId`, `bodegaDestinoId` nullable, `clienteId` nullable, `resultRefId` nullable (id del movimiento/venta creada), `metaJson, createdAt, updatedAt`.

**`SecretaryDraftItems`**: hereda el diseño de `AssistantEntrySessionItems` (`productId` nullable, `proposedName`, `resolvedName`, `quantity`, `unitCost`, `unitPrice`, `status` incl. `pending|needs_review|ready`, `candidatesJson`, `isNewProduct`) + `metaJson`.

Migración Drift v8 en `onUpgrade`: crea las 6 tablas. Las `AssistantEntry*` se mantienen hasta F7.

### 3.2 Tablas Supabase (nueva migración SQL)

`chat_sessions`, `chat_messages`, `ai_memories`, `ai_preferences` con: `id uuid pk`, `empresa_id`, `usuario_id`, columnas snake_case equivalentes, `created_at/updated_at`, **`server_updated_at timestamptz default now()` + trigger** (mismo patrón que `20260704000001_server_updated_at.sql`).

RLS (más estricta que el patrón empresa-wide):

```sql
-- chat_sessions, chat_messages, ai_preferences:
USING (empresa_id = get_mi_empresa_id() AND usuario_id = auth.uid())
-- ai_memories:
USING (empresa_id = get_mi_empresa_id() AND (usuario_id = auth.uid() OR scope = 'business'))
```

Índices: `chat_messages(session_id, seq)`, `chat_sessions(usuario_id, last_message_at desc)`, `ai_memories(usuario_id, is_active)`, unique `ai_preferences(empresa_id, usuario_id)`.

### 3.3 Integración al sync

1. Nuevo `SecretaryDao` en `lib/core/db/daos/` con `getPending*()` por tabla (patrón `syncStatus != 'synced'`).
2. `SyncRepository.pushCambiosLocales()` (`lib/core/repositories/sync_repository_drift.dart`): 4 `_push(...)` nuevos. Orden: sesiones antes que mensajes (FK). `ai_preferences` con `onConflict: 'empresa_id, usuario_id'` (last-write-wins, conflicto benigno).
3. Pull: 4 cursores nuevos en `SyncCursorStore`; **pull inicial de chat limitado a últimas 20 sesiones** (`order by last_message_at desc limit 20` + sus mensajes), resto paginado bajo demanda. Verificar que el pull no asuma visibilidad empresa-wide para estas 4 tablas (RLS por usuario).
4. Archivado local: sesiones > 90 días → `status='archived'` y elegibles para purga local.

## 4. Memoria en 3 niveles

| Nivel | Vive en | Ciclo de vida | Contenido |
|---|---|---|---|
| Trabajo | RAM (`TurnContext` en `SecretaryEngine`) | 1 turno | tool results, entidades resueltas, draft activo |
| Sesión | `ChatMessages` + `ChatSessions.summary` | 1 conversación | mensajes + rolling summary |
| Largo plazo | `AiMemories` | permanente (soft-delete) | hechos/reglas usuario y negocio |

**Extracción (`memory_extractor.dart`)**: al cerrar/abandonar sesión (background o navegación) con ≥4 turnos nuevos, o cada 10 turnos. 1 llamada a gpt-4o-mini con function `extract_memories` → `[{content, scope, category, confidence, supersedes_id?}]`, pasándole las memorias existentes (dedupe por LLM). Asíncrono, con reintento en el próximo cierre.

**Inyección (`system_prompt_builder.dart` + `context_window_manager.dart`)** — presupuesto por turno:

| Bloque | Budget | Fuente |
|---|---|---|
| Persona + reglas | ~800 tok | estático (cacheable) |
| Contexto operativo | ~200 tok | fecha, bodega activa, caja, usuario |
| Preferencias | ~100 tok | `AiPreferences` como directivas |
| Memorias | ~500 tok | top ~12 por `confidence × recencia`; marca `lastUsedAt` |
| Resumen sesión | ~400 tok | `ChatSessions.summary` |
| Historial verbatim | ~2 000 tok | últimos 10–14 mensajes |
| Tools filtradas | ~1 200 tok | subconjunto por grupo |
| **Total** | **~5 200 tok** | ≈ $0.0008 entrada/turno |

**Rolling summary (`session_summarizer.dart`)**: cuando `messageCount - summarizedUpTo >= 12` (o el verbatim excede budget), fusiona summary anterior + mensajes salientes → nuevo summary (~300 palabras: entidades, transacciones con IDs, pendientes). Retomar sesión = summary + últimos 10 mensajes.

## 5. Motor conversacional

`SecretaryEngine.runTurn()`:

```
1. SystemPromptBuilder.build(prefs, memorias, contexto, summary)
2. ContextWindowManager.window(mensajes)
3. Loop (máx 6 iteraciones):
   POST /openai-proxy con messages + tools (JSON Schema)
   ├─ finish_reason == 'tool_calls' → ToolExecutor (reutilizado), en paralelo si son varias
   └─ finish_reason == 'stop' → stream de texto a UI → persistir mensaje
4. Persistir turno en ChatMessages + traza en ChatTurnTraces
```

- **Filtrado de tools**: `SemanticRouter` clasifica el turno en grupo (`consulta_inventario|ventas_caja|draft_ops|general`) y se envía solo ese grupo (~8–12 tools) + siempre `draft.*` si hay borrador activo.
- **Offline**: sin red → turno al `offline_query_handler`; dictado sigue por vía rápida local.

## 6. Voz y dictado

**Máquina de estados** (`voice_session_controller.dart`): `idle → listening → thinking → speaking → listening` con barge-in (voz detectada corta TTS). STT: `speech_to_text` nativo, `pauseFor ~1.8s` en conversación. TTS: respuestas cortas por directiva del prompt; tablas no se leen, se resume.

**Dictado continuo — doble vía**:

1. **Vía rápida local (<300 ms)** — `dictation_parser.dart`: al cierre de segmento (`pauseFor ~1.2s`), gramática determinista en español extrae `(cantidad, descripción, precio?)` — dígitos y palabras ("doce"), unidades ("cajas de"), "a/en X". Luego `entity_resolver.resolveProduct()` local. Confianza alta → `DraftEngine.addItem()` + ack TTS + fila instantánea.
2. **Vía LLM (fallback)**: segmentos no parseados en batch con tool `draft.addItems`; fila `pending` hasta respuesta. Registrar segmentos que caen a fallback para iterar la gramática.

Ambigüedad → fila `needs_review` con `candidatesJson`; el dictado no se detiene. Comandos reservados interceptados antes del parser: "listo/confirmar", "borra el último", "cancela todo", "cambia a venta".

## 7. Borradores genéricos

```dart
abstract class DraftTypeAdapter {
  DraftType get type;
  List<DraftFieldSpec> get headerFields;               // venta: cliente, método pago
  Future<DraftItem> resolveItem(RawDictatedItem raw);  // usa entity_resolver
  List<String> validate(SecretaryDraft draft);         // stock, precios
  Future<String> execute(SecretaryDraft draft);        // → use case real, devuelve id
}
```

- `EntradaDraftAdapter` → `registrarEntrada`; `VentaDraftAdapter` → `RegistrarVentaUseCase` (valida stock antes de confirmar); ajustes/transferencias después sin tocar el motor.
- Tools LLM: `draft.create(type)`, `draft.addItems`, `draft.updateItem`, `draft.removeItem`, `draft.setHeader`, `draft.confirm`. `draft.confirm` respeta `confirmBeforeExecute` — nunca ejecuta sin confirmación explícita.
- UI: `draft_table_card.dart` = mensaje `contentType: 'draft_card'` que renderiza tabla editable desde `draftProvider(draftId)`; edición manual y dictado convergen en Drift.
- Post-ejecución: `status='executed'`, `resultRefId`, mensaje de confirmación con enlace al documento.

## 8. Consideraciones arquitectónicas

- Estado con Riverpod (AsyncNotifier para turno, StreamProvider para sesiones/borradores desde Drift).
- Offline-first: todo escribe primero en Drift; sync bidireccional existente.
- Sin texto de negocio hardcoded en widgets.
- Feature flag para convivencia con `assistant/`; ruta go_router nueva `/secretary`, redirect del viejo en F7.

## 9. Riesgos y mitigaciones

- **Costo tokens**: ventana fija + rolling summary + filtro de tools + telemetría (`ChatTurnTraces`) desde F1. Estimado ~$0.001–0.002/turno; 100 turnos/día ≈ $0.15/día.
- **Latencia voz**: LLM 1–3 s es el cuello; vía rápida local del dictado lo esquiva; en conversación, TTS arranca con la primera frase completa del stream. `speech_to_text` varía por fabricante Android → probar en gama baja en F4.
- **Parser español coloquial** ("dos con cincuenta"): fallback LLM siempre activo + log de fallos.
- **Volumen `chat_messages`**: sin trazas en sync, pull inicial 20 sesiones, archivado 90 días.
- **Migración**: sin datos de usuario que migrar (estado viejo era RAM); borradores activos del sistema viejo se terminan en el sistema viejo.
