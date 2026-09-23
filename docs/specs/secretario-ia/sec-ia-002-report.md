# SEC-IA-002 — Mejoras de captura por voz del Secretario IA

**Rama:** `feat/sec-ia-002-voz` · **Fecha:** 2026-09-22 · **Base:** `main` @ `99734f8`

Implementa los 5 puntos pedidos sobre el Secretario IA (`lib/features/secretary/`),
uno por commit, respetando las restricciones: sin migraciones remotas
ejecutadas, sin tool `draft.confirm` para el LLM, toda mejora nueva detrás
de una preferencia en `/secretary/prefs`, herramientas del LLM siempre de
solo lectura.

---

## 1. Qué se implementó

### Punto 1 — Push-to-talk
- Preferencia **"Modo de escucha"** (`AiPreferences.extraJson.listenMode`:
  `handsFree` | `pushToTalk`, default `handsFree`).
- `VoiceSessionController.beginHold()` / `endHold()` en
  [voice_session_controller.dart](../../../lib/features/secretary/voice/voice_session_controller.dart):
  en modo push-to-talk, `start()` ya no auto-escucha; mantener presionado
  el círculo del HUD llama a `speech_to_text` con `pauseFor`/`listenFor` de
  2 minutos (el fin de turno lo decide soltar, no una pausa de silencio).
- Soltar fuera del círculo cancela; soltar en menos de 400 ms sin texto
  también. La decisión se extrajo a una función pura y testeable:
  [push_to_talk.dart](../../../lib/features/secretary/voice/push_to_talk.dart)
  (`shouldDiscardHold`).
- [voice_hud.dart](../../../lib/features/secretary/presentation/widgets/voice_hud.dart):
  gestos `onTap` (manos libres) vs `onPanDown/onPanUpdate/onPanEnd/onPanCancel`
  (push-to-talk), detectando "fuera del botón" comparando
  `details.localPosition` contra el radio del círculo (132px), sin
  `RenderBox`/`GlobalKey`. Textos de estado por modo. El texto parcial en
  vivo ya existía y se reutilizó tal cual.
- Refactor interno: la lógica de turno (mandar al motor, hablar la
  respuesta, armar la ventana de confirmación del punto 4) se extrajo a
  `_runTurn`/`_maybeHandleAsConfirmation`, compartida por el loop de manos
  libres y por `endHold` — un solo camino, no dos implementaciones del
  mismo flujo.

### Punto 2 — Autocorrecciones en el dictado
- [dictation_parser.dart](../../../lib/features/secretary/voice/dictation_parser.dart):
  nueva función privada `_applyCorrections` que detecta marcadores
  ("no", "perdón", "digo", "corrijo", "mejor dicho") seguidos de un valor
  numérico y reescribe la frase para que solo quede el último valor, antes
  de que el resto del parser (sin cambios) la interprete.
- Evita falsos positivos exigiendo que lo siguiente al marcador sea, en
  efecto, un número: "no hay" o "no" dentro de otra palabra (nogal, nota)
  no disparan nada.
- Comando nuevo: **"corrige/cambia lo último a X"** (con o sin campo
  explícito: cantidad/costo/precio) para ajustar la última fila del
  borrador sin borrarla, vía `DraftEngine.updateItem`.
- La misma regla se agregó al prompt del fallback LLM
  ([dictation_fallback.dart](../../../lib/features/secretary/voice/dictation_fallback.dart)).

### Punto 3 — `normalizeSpokenQuery`
- [entity_resolver.dart](../../../lib/features/secretary/data/entity_resolver.dart):
  `EntityResolver.normalizeSpokenQuery` (función pura, estática) convierte
  letras deletreadas en español ("eme seis" → "m6", "equis ele" → "xl") y
  números en palabras a dígitos antes de resolver, tanto por el atajo de
  código exacto como por la búsqueda por nombre/fuzzy existente.
- Deliberadamente conservadora: una letra suelta ("ese", "de", "a"...) solo
  se convierte si aparece junto a otro token-código (dígito u otra letra)
  o después de una palabra guía ("talla", "modelo", "número"...); nunca
  rompe búsquedas normales como "gorra de fútbol".
- El ranking por similitud (Levenshtein) **ya existía** en el resolver; no
  se reescribió, solo se le da texto mejor normalizado como entrada.

### Punto 4 — Confirmación y ambigüedad por voz
- Preferencia **"Confirmar por voz"** (`extraJson.voiceConfirm`, default
  **desactivada**).
- [voice_confirmation.dart](../../../lib/features/secretary/voice/voice_confirmation.dart):
  `VoiceConfirmationMatcher`, coincidencia determinista y estricta sobre el
  **enunciado completo** normalizado — nunca por contención parcial. "sí
  pero cambia el precio" no confirma nada.
- Solo se arma la ventana (15 s) **después** de que el TTS termina de leer
  la respuesta del turno, y solo si ese turno dejó un borrador `active`
  (`SecretaryChatState.pendingDraftId`, nuevo).
- La confirmación reutiliza `SecretaryChatNotifier.confirmDraft` (el mismo
  camino que el botón Confirmar de la tarjeta → `DraftEngine.execute`);
  el rechazo reutiliza `discardDraft`. **No se agregó ninguna tool
  `draft.confirm`** para el LLM.
- Elegir candidato ambiguo por voz ("el uno", "el segundo"...) llama a
  `DraftEngine.updateItem(productoId: ...)` sobre la primera fila
  `needs_review` — el mismo camino que elegir en la tabla.

### Punto 5 — Acuse inmediato en turnos con tools
- Preferencia **"Aviso al consultar"** (`extraJson.toolAnnounce`, default
  **activada**).
- [tool_announcements.dart](../../../lib/features/secretary/voice/tool_announcements.dart):
  mapea el prefijo del `toolId` a una frase local corta ("Revisando el
  stock…", "Consultando ventas y caja…", "Actualizando el borrador…"), sin
  llamada extra al LLM.
- `SecretaryChatNotifier.sendMessage` dispara `onToolAnnounce` una sola vez
  (la primera tool call del turno) y mide el tiempo hasta ese momento por
  separado del tiempo hasta la respuesta final.
- **Migración Drift local v10 → v11**: nueva columna `firstAudioMs` en
  `chat_turn_traces` (tabla 100% local, nunca se sincroniza — ver
  `requirements.md` Req-19/Req-31). El diagnóstico
  (`/secretary/diagnostics`) muestra el promedio del día y el valor por
  turno junto a la latencia de respuesta final.

---

## 2. Archivos tocados (por commit)

| Commit | Archivos principales |
|---|---|
| `45e1ea6` punto 2 | `dictation_parser.dart`, `dictation_controller.dart`, `dictation_fallback.dart`, `test/secretary_dictation_parser_test.dart` |
| `e6dc63e` punto 3 | `entity_resolver.dart`, `test/secretary_entity_resolver_test.dart`, `test/integration/secretary_test_env.dart`, `test/integration/secretary_engine_integration_test.dart` |
| `2b7021e` punto 5 | `lib/core/db/tables/secretary_tables.dart`, `lib/core/db/app_database.dart` (+ `.g.dart` generado), `tool_announcements.dart` (nuevo), `voice_session_controller.dart`, `secretary_chat_provider.dart`, `chat_repository.dart`, `secretary_prefs_screen.dart`, `secretary_diagnostics_screen.dart`, `test/secretary_tool_announcements_test.dart` |
| `a8c1042` punto 4 | `voice_confirmation.dart` (nuevo), `voice_session_controller.dart`, `secretary_chat_provider.dart`, `secretary_prefs_screen.dart`, `test/secretary_voice_confirmation_test.dart` |
| `1dbbd97` punto 1 | `push_to_talk.dart` (nuevo), `voice_session_controller.dart`, `voice_hud.dart`, `test/secretary_push_to_talk_test.dart` |

Total: ~14 archivos de código tocados/creados en `lib/`, 7 archivos de
test nuevos o extendidos, 1 migración Drift local.

---

## 3. Tests agregados y resultado

| Archivo | Casos | Qué cubre |
|---|---|---|
| `test/secretary_dictation_parser_test.dart` | +18 | Autocorrecciones (7), 3 falsos positivos, `parseCorrectLastCommand` (5), regresión de los casos previos |
| `test/secretary_entity_resolver_test.dart` (nuevo) | 11 | `normalizeSpokenQuery` unitario |
| `test/integration/secretary_engine_integration_test.dart` | +5 | `normalizeSpokenQuery` contra productos sembrados parecidos (M6/M8, talla S/XS) |
| `test/secretary_tool_announcements_test.dart` (nuevo) | 5 | `toolAnnouncementFor` por grupo |
| `test/secretary_voice_confirmation_test.dart` (nuevo) | 12 | `VoiceConfirmationMatcher`, incluidos rechazos |
| `test/secretary_push_to_talk_test.dart` (nuevo) | 5 | `shouldDiscardHold` (cancelar por deslizar, toque accidental) |

**Resultado tras el último commit:** `flutter analyze` → 0 hallazgos.
`flutter test` → **99 tests pasan**, 5 se saltan (E2E con LLM real,
compuerta `SECRETARY_LLM_TESTS=1`, no se corrieron para no gastar tokens).
`flutter build apk --debug` → build exitoso.

No se tocaron los tests E2E con LLM real (`secretary_llm_e2e_test.dart`)
ni se corrieron con el gate activado.

---

## 4. Decisiones tomadas donde el spec era ambiguo

1. **Punto 1 — alcance del press-and-hold.** El spec dice "en
   `voice_hud.dart` y en el chat". El botón de micrófono del chat
   (`secretary_chat_screen.dart`) sigue abriendo el overlay de voz con un
   tap simple; el gesto de mantener presionado vive en el círculo central
   del HUD, que es donde ya se mostraba el estado y el texto parcial en
   ambos modos. Cablear el press-and-hold directo en el ícono chico del
   chat (que además tendría que disparar `start()` async antes de poder
   escuchar) agregaba una carrera de estados para un beneficio marginal —
   se puede revisar con feedback real de uso.
2. **Punto 1 — duración de "el máximo que acepte el plugin".** El paquete
   `speech_to_text` no documenta un máximo formal para `pauseFor`/`listenFor`;
   se usó 2 minutos como "razonablemente largo sin arriesgar que algún
   motor Android lo trunque antes". Si en dispositivo se corta antes,
   ajustar esta constante es un cambio de una línea
   (`_pushToTalkListenDuration` en `voice_session_controller.dart`).
3. **Punto 2 — a qué campo corrige un "no X" sin cláusula de monto.**
   Cuando no hay "a/costo/precio" cerca del marcador, se asume que corrige
   la **cantidad inicial** (ej. "quince tornillos no cincuenta" → 50
   tornillos), porque es el campo que se dicta primero y el que con más
   frecuencia se corrige a mitad de frase. Si la corrección no matchea
   ningún patrón reconocido, se decidió **no tocar el texto** (mejor
   perder la corrección puntual y caer al fallback LLM, que no romper un
   ítem válido).
4. **Punto 3 — tope de candidatos.** El spec pide "hasta 3 candidatos";
   se dejó el `take(5)` que ya existía en el resolver (no se tocó ese
   número) porque cambiarlo es una decisión de UX independiente de
   `normalizeSpokenQuery` y no hay evidencia de que 5 esté causando
   problemas.
5. **Punto 4 — ventana expirada.** El spec dice "fuera de ella, pedir de
   nuevo". Se implementó de forma conservadora: al expirar, el estado
   pendiente simplemente se limpia y el siguiente enunciado se manda como
   mensaje libre (nunca ejecuta nada en silencio). No se agregó un
   re-prompt automático porque hubiera requerido inventar un mensaje del
   asistente fuera del turno normal del LLM; el usuario puede simplemente
   volver a pedir la operación.
6. **Punto 4 — ambigüedad por voz, qué fila.** El spec no dice qué fila
   ambigua resolver si hay varias; se eligió la **primera** `needs_review`
   del borrador (mismo criterio que usaría un usuario mirando la tabla de
   arriba hacia abajo).
7. **Punto 5 — cuándo se dispara el acuse.** "Cuando el motor detecte que
   el LLM llamó una herramienta" se interpretó como la **primera** tool
   call del turno (no una por cada tool, que en un turno con 2-3 llamadas
   sería ruidoso y se pisaría con el TTS de la respuesta final).

---

## 5. Riesgos / pendientes

- Todo lo de arriba está **validado con `flutter analyze` + `flutter test`
  + `flutter build apk --debug`, no en un dispositivo real**. STT/TTS y
  gestos táctiles necesitan la prueba manual de la checklist abajo.
- La migración Drift local (v10→v11, columna `firstAudioMs`) se aplica
  sola la primera vez que la app abra con esta rama — no requiere acción
  del usuario, pero conviene confirmarlo en la prueba de dispositivo (que
  no se pierdan trazas viejas, que la columna nueva no rompa nada).
- El modo confirmar-por-voz y el push-to-talk son preferencias
  **desactivadas/en su default seguro** salvo push-to-talk que reemplaza
  la interacción de escucha visible en el HUD apenas se activa — conviene
  probarlos explícitamente, no asumir que como están "apagados" no hace
  falta.

---

## 6. Checklist de pruebas manuales en dispositivo

**Punto 1 — Push-to-talk**
- [ ] Activar "Mantener para hablar" en Preferencias.
- [ ] Abrir modo voz: el círculo debe quedar en pausa (no escuchando solo).
- [ ] Mantener presionado, decir algo, soltar dentro del círculo → se
      procesa como turno normal.
- [ ] Mantener presionado, deslizar el dedo fuera del círculo, soltar
      fuera → se cancela, no se envía nada.
- [ ] Tocar y soltar muy rápido (toque accidental) → no se envía nada.
- [ ] Mientras habla el asistente, mantener presionado interrumpe (barge-in)
      y empieza a escuchar.

**Punto 2 — Autocorrecciones**
- [ ] Dictar "quince tornillos, no, cincuenta tornillos" → fila con 50.
- [ ] Dictar "dos camisas a diez dólares, digo doce" → costo 12.
- [ ] Decir "corrige lo último a veinte" tras dictar un ítem → cantidad/costo
      de la última fila cambia sin duplicar la fila.
- [ ] Dictar algo con "no hay stock" en medio de una frase de otro tipo →
      confirmar que NO dispara una corrección accidental.

**Punto 3 — normalizeSpokenQuery**
- [ ] Con productos de talla/código parecidos en el catálogo real, dictar
      "eme seis" / "eme ocho" (o el código real del negocio) y confirmar
      que resuelve el producto correcto sin preguntar.
- [ ] Dictar "talla ese" vs "talla equis ele" (o los códigos reales) y
      confirmar que no se confunden.

**Punto 4 — Confirmación por voz**
- [ ] Activar "Confirmar por voz". Dictar una entrada completa, esperar a
      que el asistente lea el resumen, decir "confirmar" → se registra.
- [ ] Repetir y decir "sí pero cambia el precio" → NO debe registrar nada,
      debe tratarse como mensaje normal.
- [ ] Repetir y esperar más de 15 s antes de decir "sí" → no debe
      confirmar solo (ventana expirada).
- [ ] Con un ítem ambiguo, decir "el segundo" tras escuchar los candidatos
      → elige el candidato correcto.

**Punto 5 — Acuse al consultar**
- [ ] Con "Aviso al consultar" activado, preguntar algo que dispare una
      tool (ej. stock de un producto) en modo voz → se escucha un aviso
      corto antes de la respuesta final.
- [ ] Revisar `/secretary/diagnostics`: el turno debe mostrar "Primer aviso
      hablado" además de la latencia total.
- [ ] Desactivar la preferencia y repetir → no debe sonar el aviso.
