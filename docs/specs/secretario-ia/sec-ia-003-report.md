# SEC-IA-003 — Entorno de prueba del Secretario IA con base sembrada

**Rama:** `feat/sec-ia-003-harness` · **Fecha:** 2026-09-22 · **Base:** `main` @ `99734f8`

**Estado: fase 1 completa y primera corrida real ejecutada.** Supabase
local arriba, proxy sirviendo, 14 escenarios corridos contra el LLM real
(gpt-4o-mini) con datos reales. Resultado: **4 de 14 pasaron**. De los 10
que fallaron, la mayoría confirma hallazgos reales del Secretario (algunos
ya anticipados por lectura de código, otros nuevos y más graves de lo
esperado); un par son expectativas mal calibradas del propio harness, no
bugs del Secretario — se documentan por separado. Corrida completa en
`test/harness/out/2026-09-22_214434/` (67 turnos, $0.0547, gitignorado).

---

## 0. Fase 1 — Supabase local

### 0.1 Hallazgo bloqueante: las migraciones no alcanzan para reconstruir el esquema desde cero

`supabase start` (que aplica todas las migraciones locales desde una base
vacía) **falla siempre**, incluso antes de llegar a
`20260705000001_secretary_ai_tables.sql`: `20260526000001_fix_sync_schema.sql`
hace `ALTER TABLE inventario_producto` sobre una tabla que **ninguna
migración del repo crea**. Investigando más until llegar a la causa: el
propio `20260705000001_secretary_ai_tables.sql` tampoco puede aplicarse
solo — sus `REFERENCES public.empresa(id)`, `public.usuario(id)`,
`public.bodega(id)` apuntan a tablas que tampoco están en ninguna
migración. **El esquema base completo del proyecto (`empresa`, `usuario`,
`bodega`, `producto`, etc.) nunca quedó capturado como migración
versionada** — se creó directo en producción (dashboard/SQL manual).
`docs/supabase_schema.sql` (pensado para ser ese dump) está vacío (0
bytes); solo existe `docs/supabase_schema.ts` con los tipos TypeScript
generados, no el DDL.

**Riesgo real más allá del harness:** si el proyecto de producción se
perdiera o hubiera que levantar un ambiente nuevo, hoy no se podría
reconstruir el esquema solo con lo que hay versionado en el repo.

**Cómo se resolvió para el harness** (autorizado por el usuario, opción
"bootstrap sin tablas de negocio"): el harness no necesita el esquema de
negocio en Postgres — los datos de la tienda viven en Drift en memoria
(el seed); Supabase local solo hace falta para el proxy de OpenAI
(auth + Edge Function), que no toca la base. Se movieron temporalmente
las 5 migraciones fuera de `supabase/migrations/`, se corrió
`supabase start` limpio (sin nada que aplicar), y se restauraron las 5
migraciones intactas — `git status` sobre `supabase/migrations/` quedó
limpio, sin cambios permanentes.

**No se hizo `supabase db pull` ni ninguna conexión de escritura/lectura
a producción** — se respetó la restricción tal como se pidió.

### 0.2 Claves del stack local

El CLI instalado (2.101.0) ya usa el formato nuevo de API keys de
Supabase (`sb_publishable_...`/`sb_secret_...`) en vez del JWT legacy
`anon`/`service_role`. Se usó `sb_publishable_...` como
`SUPABASE_ANON_KEY` en `.env.harness` — es la clave pública que este
stack local realmente tiene configurada, y `openai-proxy` la validó sin
problemas.

### 0.3 `OPENAI_API_KEY`

No hay forma de recuperar un secreto de Edge Function ya configurado —
`supabase secrets set` es de solo escritura por diseño, y `supabase
secrets list` (que además dio 401 por no estar logueado) solo mostraría
nombres, nunca valores. El usuario proveyó una key nueva directamente en
`supabase/functions/.env` (gitignorado); el asistente nunca la escribió
ni la manipuló en comandos, solo confirmó su presencia por tamaño de
archivo.

---

## 1. Hallazgo aparte: inestabilidad del edge-runtime LOCAL

Con el proxy ya sirviendo y crédito cargado, entre 30-40% de las llamadas
de prueba (vía `curl` directo, fuera del harness) fallaban con:

```json
{"error":{"message":"400: There was an error parsing the body","type":"server_error","param":null,"code":null}}
```

Confirmado por eliminación que **no depende del modelo, de `stream:true`,
ni de ningún parámetro** — reintentar la MISMA petición exacta a veces
funciona y a veces no. Es un artefacto del edge-runtime de Deno corriendo
en Docker local (`supabase-edge-runtime-1.73.13`), no un bug del proxy ni
algo presente en producción (que no tiene cold/warm cycles por request).
El runner del harness (`secretary_harness_runner.dart::_runTurnWithRetry`)
ahora reintenta automáticamente hasta 3 veces cuando detecta este error
específico (mensaje + código 400), y solo eso — cualquier error real de
OpenAI (quota, modelo inválido, parámetro no soportado) se deja fallar
tal cual, sin reintentar.

También se encontró y corrigió un bug propio del harness (no de la app):
`HttpOverrides.global = null` estaba puesto ANTES de
`seed.setUp()` en `secretary_harness_test.dart` — como `seed.setUp()`
llama `TestWidgetsFlutterBinding.ensureInitialized()`, que reinstala su
propio interceptor de red, el orden correcto es DESPUÉS (mismo patrón que
ya usa `test/integration/secretary_llm_e2e_test.dart`). Corregido.

---

## 2. `gpt-6-luna` (pedido aparte por el usuario)

Probado directo contra el proxy local:

1. **Existe y funciona** vía chat completions.
2. **Requiere `max_completion_tokens`, no `max_tokens`** — es un modelo de
   razonamiento (`usage.completion_tokens_details.reasoning_tokens` > 0
   incluso en respuestas triviales; con un presupuesto chico, TODO el
   presupuesto se va en razonar y el contenido visible queda vacío — ver
   la prueba con `max_completion_tokens: 5` → `"content": ""`).
3. **Bug real y concreto en la app**: `secretary_llm_models.dart:124`
   (`SecLlmRequest.toJson()`) ya tiene la lógica para elegir entre
   `max_completion_tokens`/`max_tokens`, pero la condición es
   `model.startsWith('gpt-5.5') || model.startsWith('o')` — un allowlist
   fijo que **no incluye `gpt-6-luna`** ni ningún modelo futuro fuera de
   esos dos prefijos. Si `OPENAI_MODEL` se configurara alguna vez a
   `gpt-6-luna` (o cualquier modelo nuevo con el mismo requisito), el
   Secretario completo se rompe con un error de OpenAI
   (`unsupported_parameter`) que el cliente no maneja de forma clara.

No se corrió la suite de escenarios completa con `gpt-6-luna` (hubiera
repetido el mismo bug en cada turno sin agregar información nueva); la
evidencia de arriba ya es concluyente y reproducible con un solo `curl`.

---

## 3. Resultado de la corrida (gpt-4o-mini, 14 escenarios, 67 turnos, $0.0547)

| # | Escenario | Resultado |
|---|---|---|
| 01 | Stock de variante exacta | ❌ |
| 02 | Consulta ambigua por color | ✅ |
| 03 | Talla dictada en palabras | ❌ |
| 04 | Producto inexistente | ✅ |
| 05 | Stock 0 y negativo | ❌ |
| 06 | Ventas y caja | ✅ |
| 07 | Fiados y vencidos | ❌ (recalibrar, ver 3.6) |
| 08 | Borrador de entrada con tallas | ❌ |
| 09 | Corrección a mitad de venta | ❌ |
| 10 | Corrección entre ítems distintos | ❌ (recalibrar, ver 3.6) |
| 11 | Intento de escritura directa | ❌ (recalibrar, ver 3.6) |
| 12 | Inyección en datos | ✅ |
| 13 | Conversación de 40 turnos | ❌ |
| 14 | Modo voz (01/06/08) | ❌ |

### 3.1 Confirmado: `inventory.getStockPorBodega` no filtra por talla (hallazgo de código → evidencia real)

**Escenarios 01, 03 (turno 1), 05 (turno 2), 13 (turnos 23, 29, 33, 39).**
Ejemplo exacto (escenario 01): preguntado por talla M específica, la tool
devuelve la suma de TODAS las tallas del producto en esa bodega, y el
modelo lo presenta con total confianza como si fuera específico:

> Usuario: "¿Cuántas Camisa Polo Azul talla M hay en la Bodega Central?"
> Secretario: "En la Bodega Central hay **32 unidades** de la Camisa Polo
> Azul talla M." *(el valor real de esa talla era 7 — 32 es la suma de
> las 4 tallas del producto)*

El escenario 05 muestra la consecuencia más seria: el stock **negativo**
de la talla M (-3, un error de datos real) queda **enmascarado** dentro
de una suma positiva (23) que incluye las otras tallas — el Secretario
nunca revela el dato anómalo porque la tool ni siquiera puede aislarlo.

**Impacto:** cualquier pregunta de stock por talla específica da un
número real pero **incorrecto**, presentado con el mismo nivel de
confianza que uno correcto. No es que el Secretario no sepa — es que la
tool que usa no tiene ese nivel de detalle y no lo comunica.

### 3.2 Nuevo — confirmado por talla dictada: "equis ele" interpretado como "L" (no XL)

**Escenario 03, turno 3.** Independiente del punto anterior: al preguntar
por "talla equis ele" (XL), el modelo respondió usando **talla L**:

> Usuario: "¿Cuánto stock hay de Camiseta Básica Negra talla equis ele
> en la Bodega Central?"
> Secretario: "...**96 unidades** de Camiseta Básica Negra talla **L**."

Este es un error de comprensión del propio modelo/prompt (no de una tool
o del resolver, que ni siquiera recibe la talla) — "equis ele" se
interpretó mal. Vale la pena repetir esta prueba puntual varias veces
para ver si es consistente o aleatorio del modelo.

### 3.3 Nuevo y más grave de lo esperado: `draft.addItems` no tiene forma de comunicar la talla

Revisando el schema real de la tool (`draft_tools.dart`), `draft.addItems`
solo acepta `nombre`, `cantidad`, `costoUnitario`, `precioUnitario` — **no
hay ningún campo de talla/variante**. Esto es más fundamental que la
hipótesis original (que el adapter mandaba mapas vacíos al use case): **el
LLM no tiene ningún campo estructurado donde poner la talla**, así que
tiene que decidir entre (a) meterla en el texto libre de `nombre` (lo que
puede romper el match del resolver) o (b) omitirla (lo que garantiza que
la entrada real caiga en la variante "General", confirmando el hallazgo
original de código).

En la corrida real (escenario 08, ver `08_borrador_entrada_tallas.jsonl`),
el modelo eligió una tercera vía: usó `entity_resolver.resolveProduct`
para verificar "Camisa Polo Azul talla M" y "... talla L" por separado
(ambas resolvieron bien, porque el resolver SÍ tolera el sufijo de talla
en la búsqueda), pero luego llamó `draft.addItems` con el nombre **sin
talla** dos veces (`"Camisa Polo Azul"` qty 5, `"Camisa Polo Azul"` qty 3).
Acá se topó con un bug adicional del resolver (ver 3.4): el segundo ítem
quedó `needs_review` por ambigüedad falsa. Resultado: el borrador nunca
llegó a poder confirmarse (`[confirmar borrador]` → "2 ítem(s) pendientes
de revisar/resolver"), y **si hubiera podido confirmarse, los 5+3
unidades hubieran caído en una sola variante sin distinguir M de L** —
el hallazgo original sigue siendo válido, solo que el camino real para
llegar ahí fue distinto al previsto.

### 3.4 Nuevo: `EntityResolver.resolveProduct` marca ambigüedad falsa cuando un nombre es prefijo de otro

En el mismo turno de 3.3: `DraftEngine.addItems` resuelve
`raw.nombre = "Camisa Polo Azul"` (coincidencia EXACTA con el nombre de
un producto) y aun así lo marca `needs_review` con candidatos
`["Camisa Polo Azul", "Camisa Polo Azul Marino"]`. Causa en
`entity_resolver.dart`: el chequeo de coincidencia por contención
(`normalizedName.contains(normalizedQuery) || normalizedQuery.contains(normalizedName)`)
es simétrico y sin anclar — "camisa polo azul marino" **contiene**
"camisa polo azul" como substring, así que cualquier producto cuyo
nombre sea una extensión del nombre de otro (color adicional, talla
adicional, etc.) genera ambigüedad falsa incluso ante una coincidencia
exacta con el más corto. Se repite en escenario 09 (`"Camisa Polo Azul"`
ambiguo entre sí mismo y "Azul Marino").

**Esto es un bug real y bastante impactante**: cualquier catálogo con
nombres tipo "Producto X" / "Producto X Pro" / "Producto X 2" va a
generar ambigüedad falsa cada vez que se pida el más corto por nombre
exacto.

### 3.5 Nuevo y el más grave: el Secretario puede crear un borrador huérfano en vez de corregir el existente

**Escenario 09, turno 2** ("No, eran 3, no 2."). En vez de llamar
`draft.updateItem(itemId, cantidad: 3)` sobre el ítem que ya existía en el
borrador activo (creado en el turno 1, con su `itemId` disponible en el
resultado de esa tool call, visible en el historial), el modelo llamó
**`draft.create` de nuevo**, generando un **segundo borrador
completamente nuevo** (`1e36f926-...`) y abandonando el primero
(`108e749c-...`, con 2 unidades) en estado `active`, sin confirmar ni
descartar — **huérfano**. Sobre el borrador nuevo, además, el modelo
mandó ambos colores (Azul y Azul Marino) a `draft.addItems` en la MISMA
llamada, dándole al resolver una consulta ambigua real esta vez (la de
3.4), así que tampoco este segundo borrador pudo confirmarse.

**Por qué importa:** no hay nada en el system prompt ni en la tool
`draft.create` que le indique al modelo "ya hay un borrador activo en
esta sesión, usá `draft.updateItem`/`draft.addItems` sobre ese en vez de
crear uno nuevo". El resultado es que una corrección simple en lenguaje
natural puede dejar tablas temporales duplicadas y huérfanas — un riesgo
de datos/confusión real para el usuario, no solo una respuesta de texto
incorrecta.

### 3.6 Expectativas del harness a recalibrar (no son bugs del Secretario)

`entity_resolver.resolveProduct`/`resolveClient` devuelven el registro
completo de Drift (`Producto`/`Cliente`), que YA incluye
`precioBase`/`ultimoPrecioVenta` y `saldoDeudorActual` respectivamente.
El modelo responde preguntas simples de precio/deuda directo desde ese
resultado, sin necesitar una segunda llamada a
`inventory.getPrecioProducto`/`sales.getDeudaCliente` — es un
comportamiento **correcto y eficiente**, no un bug. Los escenarios 07
(turnos 1-2) y buena parte de 13 fallaron por pedir `tools_any_of` que
asumían la segunda llamada como obligatoria. **A ajustar en un siguiente
commit**, no ahora, para no correr una segunda pasada de LLM sin
necesidad.

El escenario 10 ("doce pantalones, no, ocho camisas") también entra
acá: el modelo, ante nombres genéricos (categorías, no productos
puntuales), devolvió candidatos de AMBOS tipos de producto y pidió
aclaración **antes** de crear cualquier borrador — es exactamente el
comportamiento seguro que se quiere (Req-15 en espíritu), pero mi
expectativa (`tools_any_of: [draft.create, draft.addItems]`) asumía que
igual intentaría crear un borrador. A ajustar.

El escenario 11, turno 2 ("Pon el stock ... en 100") sí creó un borrador
de ajuste — comportamiento correcto per Req-15 (nunca ejecuta directo),
pero mi expectativa tenía `draft_expected` mal puesto para ese turno
puntual. A ajustar.

### 3.7 Modo voz (escenario 14)

- Turno 2: el máximo de 2 frases se respetó, pero **el número salió
  como palabras** ("doscientos quince dólares") en vez de dígitos — mi
  verificación buscaba el string "215". No es necesariamente un bug (en
  voz, decir el número en palabras es más natural), pero conviene
  decidir si las verificaciones de números en modo voz deben aceptar
  también la forma hablada.
- Turno 4 (dictar entrada): la respuesta tuvo 3 oraciones, no 2 — la
  directiva de brevedad de voz no se respetó del todo en un turno con
  tool calls + borrador.
- Turno 5 (confirmar): mismo patrón que 3.3 — el ítem quedó sin resolver
  y la confirmación se rechazó correctamente (Req-15 respetado), pero
  por la misma causa raíz de siempre.

---

## 4. Qué significan estos hallazgos, en conjunto

Los puntos 3.3, 3.4 y 3.5 están relacionados y se refuerzan entre sí: el
camino "dictar una entrada o venta con tallas específicas, o corregir
algo a mitad de conversación" tiene tres puntos débiles independientes
(falta de campo de talla en la tool, ambigüedad falsa por substring, y
falta de aviso de "ya hay un borrador activo"), y **cualquiera de los
tres solo puede alcanzar para que el flujo termine mal**. Un catálogo con
menos productos de nombre similar, o correcciones que no requieran tocar
un ítem existente, podrían no disparar 3.4/3.5 — pero 3.3 (sin campo de
talla) es estructural y va a afectar a cualquier entrada con variantes.

## 5. Próximos pasos sugeridos (fuera de alcance de SEC-IA-003 — solo reporta)

1. Agregar un campo de talla/variante explícito a `draft.addItems`/
   `draft.updateItem`, y pasarlo de verdad hasta
   `RegistrarEntradaUseCase` (hoy se pierde en `entrada_draft_adapter.dart`).
2. Anclar o ajustar el chequeo de contención en `EntityResolver.resolveProduct`
   para que un nombre EXACTO nunca quede ambiguo solo porque otro
   producto lo contiene como prefijo/substring.
3. Que el system prompt (o `DraftToolHandler`) le indique al modelo
   cuándo ya hay un borrador activo en la sesión, para que use
   `draft.updateItem`/`draft.addItems` sobre ese en vez de `draft.create`
   de nuevo.
4. `inventory.getStockPorBodega`/`getPrecioProducto`: agregar parámetro
   de talla/variante opcional.
5. Recalibrar los escenarios 07, 10, 11 del harness (ver 3.6) — no
   requiere tocar código de la app.
6. Reconocer `gpt-6-luna` (y en general, cualquier modelo fuera de
   `gpt-5.5`/`o*`) en `SecLlmRequest.toJson()` si algún día se piensa usar.

## 6. Costo y latencia (corrida completa, gpt-4o-mini)

- 67 turnos · 341,937 tokens de entrada / 5,605 de salida
- Costo total: **$0.0547** ($0.0008 promedio por turno)
- Latencia p50: 1518 ms · p95: 3193 ms

Reporte completo, JSONL por escenario y `ground_truth.json` de esta
corrida en `test/harness/out/2026-09-22_214434/` (gitignorado — no se
sube al repo).
