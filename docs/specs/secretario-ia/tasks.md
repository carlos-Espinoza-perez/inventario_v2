# Lista de Tareas (Implementación) — Secretario con IA

**Tarea:** SEC-IA-001 · Ejecutar secuencialmente por fase. Cada fase termina con `flutter analyze` limpio y su validación manual.

---

## F0 — Cimientos de datos (sin UI)

- [x] F0.1 Crear `lib/core/db/tables/secretary_tables.dart`: `ChatSessions`, `ChatMessages`, `AiMemories`, `AiPreferences` (con mixin `SyncTable`) + `ChatTurnTraces`, `SecretaryDrafts`, `SecretaryDraftItems` (solo locales).
- [x] F0.2 Migración Drift v7→v8 en `lib/core/db/app_database.dart` (`onUpgrade` crea las tablas; no tocar `AssistantEntry*`).
- [x] F0.3 Crear `SecretaryDao` en `lib/core/db/daos/` con CRUD + `getPending*()` por tabla sincronizada.
- [x] F0.4 Migración SQL Supabase creada (`supabase/migrations/20260705000001_secretary_ai_tables.sql`). **PENDIENTE: aplicar en remoto — requiere autorización del usuario.**
- [x] F0.5 Wiring en `SyncRepository`: 4 push (sesiones antes que mensajes; prefs con `onConflict`) + pull con `_pullSecretary()`; pull inicial de chat limitado a 20 sesiones (`_pullChatInicial`).
- [x] F0.6 Job de limpieza al arranque (`SecretaryDao.runMaintenance()` desde `AutoSync.build()`): trazas > 14 días, sesiones > 90 días → archivadas.
- [ ] **Validar F0:** migración v7→v8 sin pérdida; insertar sesión/mensaje/memoria local → aparece en Supabase → reinstalar/segundo dispositivo la recibe por pull. *(Bloqueado hasta aplicar la migración SQL remota.)*

## F1 — Motor nuevo con consultas (solo lectura)

- [x] F1.1 Proxy `openai-proxy`: verificado que ya reenvía el body tal cual (incluye `tools`/`tool_choice`) y hace passthrough del SSE. **No requirió cambios ni deploy.**
- [x] F1.2 `data/llm/secretary_llm_client.dart` + `secretary_llm_models.dart` (tools, agregación de tool_call deltas, usage vía stream_options) y `function_schemas.dart` (9 tools read-only; nombres API sin puntos: `__`).
- [x] F1.3 `engine/secretary_engine.dart`: loop function calling máx 6 iter (última iteración sin tools fuerza respuesta final), reutiliza `ToolExecutor` del assistant.
- [x] F1.4 `engine/system_prompt_builder.dart` v1 (persona + reglas + estilo por prefs + contexto operativo; hooks para memorias/summary listos). *context_window_manager se pospone a F7 (con 14 mensajes el recorte del DAO basta).*
- [x] F1.5 Pre-filtro de tools: con 9 tools read-only no hace falta filtrar; el filtro por grupos se implementa en F3 cuando se sumen las tools `draft.*`. *(Ajuste respecto al diseño: SemanticRouter requiere una llamada LLM extra por turno; se usará filtro por grupos estático.)*
- [x] F1.6 `data/repositories/chat_repository.dart` + persistencia de mensajes y trazas con tokens/latencia.
- [x] F1.7 UI: `secretary_chat_screen.dart` + `secretary_chat_provider.dart`, ruta `/secretary` tras flag `SECRETARY_ENABLED` (default true); botón "IA" del bottom bar apunta al secretario con el flag activo.
- [ ] **Validar F1:** "¿cuánto stock hay de X?" y "¿cuánto vendí hoy?" con tool calls reales; mensajes persisten tras matar la app; trazas registran tokens. *(Pendiente: prueba en dispositivo por el usuario.)*

## F2 — Historial de conversaciones

- [x] F2.1 `chat_sessions_provider.dart` (stream desde Drift) + `chat_sessions_screen.dart` (lista por actividad, archivar con confirmación, ruta `/secretary/history`, botón Historial en el AppBar del chat).
- [x] F2.2 Títulos autogenerados (primeras 6 palabras del primer mensaje) y `lastMessageAt`/`messageCount` actualizados por turno en `SecretaryDao.appendMessage`.
- [x] F2.3 Retomar sesión: `openSession()` carga los mensajes vía stream y el motor arma el contexto con los últimos 14 + summary (cuando exista, F7).
- [ ] **Validar F2:** retomar una conversación de ayer con contexto correcto; crear nueva sesión desde el historial. *(Pendiente: prueba en dispositivo por el usuario.)*

## F3 — Borrador genérico + transacciones (por texto)

- [x] F3.1 `drafts/draft_engine.dart` + `adapters/draft_type_adapter.dart`; CRUD de borradores en `SecretaryDao` (la capa repository quedó en el DAO+engine, sin archivo extra).
- [x] F3.2 `EntradaDraftAdapter` (→ `RegistrarEntradaUseCase`) y `VentaDraftAdapter` (→ `RegistrarVentaUseCase`; el stock/caja los valida el use case existente en la transacción).
- [x] F3.3 Tools `draft.create/addItems/updateItem/removeItem/setHeader/getState` (`drafts/draft_tools.dart`) vía `localToolHandler` del motor. *Sin tool `draft.confirm`: la ejecución SOLO ocurre con el botón Confirmar de la tarjeta (Req-15).*
- [x] F3.4 `draft_table_card.dart`: tabla editable inline (corregir cantidad/costo/precio, resolver candidatos con diálogo, eliminar fila) sobre `draftProvider`/`draftItemsProvider`.
- [x] F3.5 Confirmación explícita desde la tarjeta → `DraftEngine.execute()` → adapter → `resultRefId` + mensaje de resultado en el chat. *(Pendiente F6: respetar el toggle `confirmBeforeExecute` de preferencias — hoy siempre pide confirmación, el default seguro.)*
- [ ] **Validar F3:** por texto: dictar 3 productos de entrada, editar uno a mano, confirmar → `movimiento_producto` real y sincronizado; venta análoga descuenta stock. *(Pendiente: prueba en dispositivo; requiere OPENAI_API_KEY configurada.)*

## F4 — Voz conversacional

- [x] F4.1 `secretary/voice/secretary_transcriber.dart`: STT propio con pausa de fin de frase configurable (1.8 s en conversación vs 5.5 s del viejo), partials y nivel de sonido. TTS: se reutiliza `FlutterTtsService` del assistant tal cual (se moverá en F7 al retirar el feature viejo).
- [x] F4.2 `voice_session_controller.dart`: máquina de estados idle→listening→thinking→speaking, loop manos libres (toggle), pausa tras silencio, guard por generación para cierres limpios.
- [x] F4.3 `presentation/widgets/voice_hud.dart`: overlay a pantalla completa con círculo animado por nivel de sonido, partials en vivo, estado y errores; botón mic en el input del chat.
- [x] F4.4 Directiva de brevedad en modo voz (`SystemPromptBuilder(voiceMode)`: máx 2 frases, sin listas; borradores se resumen hablados). *Ajuste:* TTS habla al completar el turno (no con la primera frase del stream — el turno con tools no emite texto hasta el final; se reevalúa en F8 con métricas). *Barge-in:* por tap en el círculo (no por detección de voz: el STT nativo no puede escuchar mientras suena el TTS sin cancelación de eco).
- [ ] **Validar F4:** consulta de stock por voz punta a punta; latencia fin-de-habla → primer audio < 3.5 s; tap interrumpe el TTS y vuelve a escuchar; dictar entrada por voz muestra la tarjeta y el resumen hablado. Probar en Android de gama baja. *(Pendiente: prueba en dispositivo.)*

## F5 — Dictado continuo (tablas temporales por voz)

- [x] F5.1 `voice/dictation_parser.dart`: gramática es (dígitos/palabras hasta 999, docenas, decimales "con", "a/en X" según tipo, "costo X precio Y") con **16 tests unitarios** (`test/secretary_dictation_parser_test.dart`). Frases con montos sin interpretar (ej. dos ítems juntos) caen al fallback en vez de perder datos.
- [x] F5.2 `voice/dictation_controller.dart`: segmentación por pausa de 1.2 s, vía rápida (parser + resolver local + ack TTS inmediato) y fallback LLM asíncrono por segmento (`voice/dictation_fallback.dart`, llamada mínima sin tools que devuelve JSON; si tampoco entiende, fila `needs_review` con el texto crudo — nunca se pierde lo dictado). Entrada por botón "playlist_add" del chat (elegir entrada/venta); al finalizar la tarjeta queda como mensaje del chat.
- [x] F5.3 Ambigüedades → `needs_review` con candidatos sin frenar el dictado; resolución por tap en la tabla (por voz: F6+).
- [x] F5.4 Comandos: "listo/eso es todo/confirmar", "borra/quita/elimina lo último", "cancela todo/el dictado". *"Cambia a venta" pospuesto:* con ítems acumulados es destructivo; se reevalúa con feedback real.
- [x] F5.5 Log local de segmentos que caen a fallback (trazas `model='dictation_fallback'`, visibles en `/secretary/diagnostics`).
- [ ] **Validar F5:** dictar 10 ítems seguidos; ≥8 por vía rápida < 500 ms; ambigüedades quedan marcadas y el flujo confirma y ejecuta bien. *(Pendiente: prueba en dispositivo.)*

## F6 — Memoria y personalización

- [x] F6.1 `engine/memory_extractor.dart`: extracción cada 8 mensajes (asíncrona, best-effort), dedupe/supersede vía LLM (recibe memorias existentes y puede marcar `supersedesId`); marcador `memUpTo` en `metadataJson` de la sesión.
- [x] F6.2 Inyección de memorias en el prompt (top 12 por confianza × uso reciente desde `getActiveMemories`; `lastUsedAt` se actualiza sin disparar sync).
- [x] F6.3 `secretary_prefs_screen.dart` (ruta `/secretary/prefs`, botón en el AppBar): tono, verbosidad, bodega default, voz on/off, auto-lectura, velocidad TTS, confirmación previa. *(La capa repository quedó en DAO, sin archivo aparte.)*
- [x] F6.4 Curación de memorias en la misma pantalla (listar con categoría/alcance, "olvidar" = soft-delete sincronizado).
- [x] F6.5 Prefs aplicadas: estilo y bodega preferida en el prompt, bodega preferida en `draft.create` y dictado, `ttsRate` en voz/dictado/auto-lectura (`voice/secretary_tts.dart` propio con rate configurable), `voiceEnabled` bloquea el modo voz, `confirmBeforeExecute=false` → el "listo" del dictado ejecuta directo si no hay ítems por revisar.
- [ ] **Validar F6:** decir "siempre trabajo en bodega central" → cerrar sesión → nueva sesión: una entrada dictada usa esa bodega sin preguntar; cambiar tono se refleja en respuestas. *(Pendiente: prueba en dispositivo.)*

## F7 — Resumen, límites y retirada del assistant viejo

- [x] F7.1 `engine/session_summarizer.dart`: rolling summary asíncrono cada 12 mensajes (fusión summary previo + últimos 24 mensajes, ≤250 palabras, conserva operaciones/entidades/pendientes); marcador `sumUpTo` en `metadataJson`; el prompt ya lo inyecta al retomar.
- [x] F7.2 Telemetría: `secretary_diagnostics_screen.dart` en `/secretary/diagnostics` (acceso desde Preferencias → Soporte): métricas del día (turnos, tokens, costo estimado, latencia promedio, errores, fallbacks de dictado) + lista de trazas con detalle completo.
- [x] F7.3 `/assistant` redirige a `/secretary`; feature flag `SECRETARY_ENABLED` retirado (rutas incondicionales, botón IA directo).
- [x] F7.4 `lib/features/assistant/` eliminado (2026-07-06, autorizado por el usuario tras validar el chat en dispositivo). Las piezas reutilizadas se movieron a `secretary/`: `data/context/assistant_context_builder.dart`, `data/entity_resolver.dart`, `data/tools/{tool_registry,tool_result,tool_executor}.dart` (executor simplificado: sin `collectedData` del ReAct viejo) y `domain/models/assistant_operational_context.dart` — mismos nombres de clase para minimizar el diff. Drift v10 dropea `assistant_entry_sessions/items`; tests del assistant eliminados.
- [ ] **Validar F7:** conversación de 40 turnos mantiene coherencia con entrada acotada (~5.2k tok); `flutter analyze` y build limpios ✓ (falta la prueba de 40 turnos en dispositivo).

## F8 — Observabilidad y diagnóstico (ver `observabilidad.md`)

Base actual: `chat_turn_traces` (tools, resultados, tokens, latencia; 14 días, solo local) + `app_logs`. Brechas a cubrir:

- [x] F8.1 La traza guarda el **payload exacto enviado al LLM** (`requestJson`, truncado a 16k chars) — Drift v9 agrega `requestJson` y `errorText` a `chat_turn_traces`.
- [x] F8.2 Pantalla de diagnóstico `/secretary/diagnostics`: lista de turnos con latencia/tokens, detalle (tool calls, resultados, request, error) en texto seleccionable. *(Filtro por sesión: si hace falta, se agrega con feedback real.)*
- [x] F8.3 Errores categorizados en el chat: key faltante en el proxy, 401/403 (sesión), 429 (saturado), 5xx, sin red — cada uno con mensaje accionable + `ref` corto de traza; los turnos fallidos también dejan traza con `errorText`.
- [x] F8.4 Métricas del día en diagnóstico (turnos, tokens in/out, costo estimado, latencia promedio, errores) + registro de cada segmento de dictado que cae al fallback (trazas `model='dictation_fallback'` — cierra F5.5).
- [ ] F8.5 Resumen por turno a `app_logs` remoto (sin contenido del usuario) — **decisión: pospuesto**; primero validar en un solo dispositivo, el diagnóstico local cubre la necesidad actual.
- [ ] **Validar F8:** ante un fallo simulado (key inválida), el chat muestra la categoría + ref y el diagnóstico muestra la traza con su error. *(Pendiente: prueba en dispositivo.)*
