# Observabilidad del Secretario IA — qué se registra y cómo analizar casos

**Tarea:** SEC-IA-001 · Documento de referencia para depurar conversaciones y entender qué pasa "de fondo" en cada turno.

## 1. Qué se registra HOY y dónde

| Qué | Dónde | Contenido | Retención | ¿Sincroniza? |
|---|---|---|---|---|
| Mensajes del chat | Drift `chat_messages` → Supabase `chat_messages` | role, content, contentType, seq, sesión | Local: archivo a 90 días. Remoto: indefinido | Sí |
| Traza técnica por turno | Drift `chat_turn_traces` (solo local) | tools llamadas (nombre + argumentos), resultados crudos de cada tool, latencia ms, tokens in/out, modelo | 14 días (limpieza al arranque) | No (por diseño: volumen) |
| Errores de la app | Drift `app_logs` vía `AppLogger`/`RemoteLogger` | nivel, módulo, mensaje, stack, metadata | según política de AppLogs | Parcial (RemoteLogger) |
| Borradores | Drift `secretary_drafts` + `secretary_draft_items` | tipo, estado (`active/executed/discarded`), ítems con estados y candidatos, `resultRefId` de la transacción creada | permanente local | No (la transacción resultante sí, por sus tablas de negocio) |
| Errores del proxy | Supabase Edge Function logs (dashboard → Functions → openai-proxy → Logs) | status, errores de OpenAI | según plan Supabase | — |

## 2. Flujo de un turno (qué pasa de fondo)

```
Usuario envía texto
 → chat_messages (role=user)                       [queda registrado]
 → SystemPromptBuilder (persona+prefs+contexto)     [no se registra: reconstruible]
 → Loop SecretaryEngine (máx 6 iteraciones):
     → POST openai-proxy (streaming)
     → si el modelo pide tools → ToolExecutor / DraftToolHandler
       · cada llamada y su resultado se acumulan   [→ chat_turn_traces]
 → respuesta final → chat_messages (role=assistant)
 → chat_turn_traces: toolCallsJson, toolResultsJson,
   latencyMs, tokensIn, tokensOut, model            [queda registrado]
```

## 3. Cómo analizar un caso hoy

1. **En el dispositivo (SQL sobre la DB local)** — la DB está en `app_database.sqlite` (documents del app). Consultas útiles:
   ```sql
   -- Últimos turnos con su costo y latencia
   SELECT created_at, latency_ms, tokens_in, tokens_out, model
   FROM chat_turn_traces ORDER BY created_at DESC LIMIT 20;

   -- Qué tools llamó el último turno y qué devolvieron
   SELECT tool_calls_json, tool_results_json
   FROM chat_turn_traces ORDER BY created_at DESC LIMIT 1;
   ```
2. **Errores**: revisar `app_logs` local (módulo con prefijo `[Secretary]`) o el visor de logs de la app si está disponible en `/sync`.
3. **Fallas del proxy/OpenAI**: dashboard de Supabase → Edge Functions → `openai-proxy` → Logs (ej.: el caso "OPENAI_API_KEY no configurada" del 2026-07-05 se veía ahí como 500).
4. **Reproducir el proxy desde PC**: POST a `{SUPABASE_URL}/functions/v1/openai-proxy` con el anon key y un body igual al de la app (ver `SecLlmRequest.toJson()`).

## 4. Estado F8 (implementado 2026-07-06)

- ✅ **Payload exacto al LLM**: columna `requestJson` en `chat_turn_traces` (truncado 16k chars); los turnos fallidos guardan `errorText`.
- ✅ **Pantalla de diagnóstico**: `/secretary/diagnostics` (Preferencias → Soporte): métricas del día (turnos, tokens, costo estimado, latencia, errores, fallbacks) + trazas con detalle seleccionable.
- ✅ **Errores categorizados**: el chat distingue key faltante / sesión (401) / saturación (429) / servidor (5xx) / sin red, con `ref` de traza de 8 chars para buscar en diagnóstico.
- ✅ **Fallbacks de dictado registrados**: trazas `model='dictation_fallback'` con el segmento crudo — insumo para iterar la gramática del parser.
- ⏸ Pendiente (F8.5, pospuesto): resumen por turno a `app_logs` remoto para análisis de flota (sin contenido del usuario).
