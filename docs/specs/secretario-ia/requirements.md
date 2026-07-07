# Requerimientos (EARS) — Secretario con IA

**Tarea:** SEC-IA-001 · **Fecha:** 2026-07-05

El "Secretario con IA" reemplaza al asistente actual (`lib/features/assistant/`) con un rediseño total que agrega historial persistente, memoria de largo plazo y personalización, reutilizando la infraestructura existente (proxy OpenAI, STT/TTS, DAOs, tools, sync offline-first).

---

## 1. Chat conversacional

- **[Req-01]** El sistema deberá ofrecer una pantalla de chat donde el usuario pueda conversar en lenguaje natural (español) con el secretario IA.
- **[Req-02]** Cuando el usuario envíe un mensaje, el sistema deberá responder usando el LLM (gpt-4o-mini vía Edge Function `openai-proxy`) con streaming de texto en la UI.
- **[Req-03]** El sistema deberá persistir cada mensaje (usuario y asistente) en la base local Drift de forma inmediata; al cerrar y reabrir la app, la conversación deberá seguir disponible.
- **[Req-04]** Cuando el LLM necesite datos del negocio, el sistema deberá usar function calling nativo de OpenAI (no JSON libre) sobre las herramientas existentes (stock, precios, ventas, deudas, caja, resolución de entidades).

## 2. Consultas de inventario y negocio

- **[Req-05]** El sistema deberá responder consultas de inventario por chat o voz, como mínimo: stock por producto y bodega, precio de producto, ventas del día, deuda de cliente, resumen de fiados y estado de caja.
- **[Req-06]** Mientras el dispositivo esté offline, el sistema deberá resolver las consultas de datos locales (Drift) mediante el handler offline, indicando al usuario que opera sin conexión; la conversación libre con LLM podrá quedar deshabilitada offline.

## 3. Modo voz (baja latencia)

- **[Req-07]** El sistema deberá ofrecer modo voz manos libres con ciclo: escuchar → pensar → hablar → escuchar, usando STT nativo del dispositivo (`speech_to_text`, es_ES) con resultados parciales visibles en tiempo real.
- **[Req-08]** Cuando el usuario hable mientras el TTS está reproduciendo (barge-in), el sistema deberá detener el TTS y volver a escuchar.
- **[Req-09]** En modo voz, el sistema deberá generar respuestas cortas (máx. 2 frases habladas); resultados extensos (tablas, listados) se mostrarán en pantalla y solo se leerá un resumen.

## 4. Dictado acumulativo con tablas temporales (borradores)

- **[Req-10]** El sistema deberá soportar un modo dictado continuo para cargar ítems a un borrador (tabla temporal) de tipo: entrada de productos, venta, y extensible a ajustes/transferencias sin modificar el motor.
- **[Req-11]** Cuando el usuario dicte un ítem (ej. "12 pantalones a 10 dólares"), el sistema deberá agregarlo al borrador con feedback inmediato (fila visible + confirmación TTS corta) en menos de ~500 ms usando un parser local determinista; los segmentos no parseables localmente deberán procesarse por LLM en batch (fila en estado `pending`).
- **[Req-12]** Cuando un producto dictado sea ambiguo (múltiples candidatos), el sistema deberá marcar la fila como `needs_review` con los candidatos, sin detener el dictado.
- **[Req-13]** El borrador deberá mostrarse en el chat como una tabla editable: el usuario podrá corregir cantidad, precio, producto y eliminar filas de forma manual, y esos cambios convergen con el dictado en el mismo estado.
- **[Req-14]** El sistema deberá reconocer comandos reservados de voz en modo dictado: "listo/confirmar", "borra el último", "cancela todo".
- **[Req-15]** El sistema nunca deberá ejecutar una transacción real (movimiento, venta) sin confirmación explícita del usuario (tap o "sí" verbal tras el resumen); al confirmar, deberá invocar los use cases existentes (`registrarEntrada`, `RegistrarVentaUseCase`) y registrar la referencia del documento creado en el borrador y en el chat.
- **[Req-16]** Los borradores deberán persistir localmente (sobrevivir cierre de app) pero NO sincronizarse a Supabase; la transacción resultante se sincroniza por las tablas de negocio existentes.

## 5. Historial de conversaciones

- **[Req-17]** El sistema deberá organizar el chat en sesiones con título autogenerado, fecha del último mensaje y contador de mensajes, listadas en una pantalla de historial ordenada por actividad reciente.
- **[Req-18]** Cuando el usuario seleccione una sesión pasada, el sistema deberá retomarla con contexto (resumen acumulado + últimos mensajes), permitiendo continuar la conversación.
- **[Req-19]** Las sesiones y mensajes deberán sincronizarse a Supabase siguiendo el patrón offline-first existente (mixin `SyncTable`, `server_updated_at`, push/pull del `SyncRepository`); las trazas técnicas (tool calls, tokens) NO se sincronizan.
- **[Req-20]** En un dispositivo nuevo, el pull inicial deberá limitarse a las últimas 20 sesiones del usuario; localmente, las sesiones con más de 90 días se archivan.

## 6. Memoria en 3 niveles

- **[Req-21]** El sistema deberá manejar memoria de trabajo (RAM, un turno: tool results, entidades resueltas, borrador activo), memoria de sesión (mensajes + resumen acumulado en Drift) y memoria de largo plazo (hechos persistentes en `AiMemories`).
- **[Req-22]** Cuando una sesión supere la ventana de contexto (>12 mensajes fuera de ventana), el sistema deberá generar de forma asíncrona un rolling summary (~300 palabras) que conserve entidades, transacciones ejecutadas (con IDs) y pendientes.
- **[Req-23]** Al cerrar o abandonar una sesión con ≥4 turnos nuevos (o cada 10 turnos en sesiones largas), el sistema deberá extraer hechos de largo plazo con el LLM (contenido, alcance `user|business`, categoría `preference|fact|rule|correction`, confianza), deduplicando contra memorias existentes (supersede).
- **[Req-24]** El sistema deberá inyectar al system prompt las ~12 memorias más relevantes (confianza × recencia de uso), y actualizar `lastUsedAt` de las inyectadas.
- **[Req-25]** El usuario deberá poder ver, desactivar y eliminar memorias desde una pantalla de curación (transparencia y control).

## 7. Personalización

- **[Req-26]** El sistema deberá persistir preferencias por usuario (una fila por usuario, sincronizada): tono (`formal|neutral|casual`), verbosidad (`concise|normal|detailed`), bodega por defecto, voz habilitada, lectura automática de respuestas, velocidad TTS, y confirmación previa a ejecutar transacciones.
- **[Req-27]** Las preferencias deberán aplicarse en el system prompt (tono/verbosidad), en el motor (confirmación) y en la capa de voz (TTS) en cada turno.

## 8. Seguridad y multi-tenant

- **[Req-28]** Las tablas remotas nuevas (`chat_sessions`, `chat_messages`, `ai_memories`, `ai_preferences`) deberán tener RLS: `empresa_id = get_mi_empresa_id() AND usuario_id = auth.uid()`; las memorias con `scope='business'` serán visibles a toda la empresa.
- **[Req-29]** La API key de OpenAI deberá permanecer solo en el servidor (Edge Function con JWT); ningún secreto viaja en el APK.

## 9. No funcionales

- **[Req-30]** Latencia: feedback de dictado local < 500 ms; primera palabra hablada de una respuesta de voz < 3.5 s (streaming + TTS por frases).
- **[Req-31]** Costo: presupuesto de contexto ≈ 5.2k tokens de entrada por turno (objetivo $0.001–0.002/turno); el sistema deberá registrar tokens y latencia por turno en trazas locales (`ChatTurnTraces`, retención 14 días) para telemetría.
- **[Req-32]** El envío de schemas de tools deberá filtrarse por grupo semántico (~8–12 tools por turno, no las 38).
- **[Req-33]** Prohibido texto de negocio hardcoded en widgets; strings de UI centralizados según el patrón del proyecto.
- **[Req-34]** El feature nuevo (`lib/features/secretary/`) deberá convivir con el actual tras un feature flag hasta alcanzar paridad; la retirada de `lib/features/assistant/` es la última fase.
