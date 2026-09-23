# SEC-IA-003 — Entorno de prueba del Secretario IA con base sembrada

**Rama:** `feat/sec-ia-003-harness` · **Fecha:** 2026-09-22 · **Base:** `main` @ `99734f8`

**Estado: bloqueado en la fase 1 (Supabase local).** Docker está instalado
pero el daemon no llegó a levantar durante esta sesión
(`docker ps` → `failed to connect to the docker API at
npipe:////./pipe/docker_engine`). Todo lo que no depende de eso —seed,
ground truth, runner, verificador, 14 escenarios— está construido, probado
(sin LLM) y comiteado. **Ningún turno se corrió contra el LLM real
todavía.** Este documento reporta lo investigado y construido hasta acá;
la "primera corrida con reporte" que pedía el spec original queda
pendiente de que Supabase local esté arriba.

---

## 0. Respuestas a lo que pediste verificar antes de tocar código

**¿El proxy fija el modelo o usa el que manda el cliente?**
`supabase/functions/openai-proxy/index.ts` hace **passthrough puro**: reenvía
`req.body` tal cual a `https://api.openai.com/v1/chat/completions`, sin tocar
ningún campo. El servidor **no** fija el modelo — usa literalmente el
`model` que mande el cliente (`AppConstants.openAiModel`).

**¿`OPENAI_MODEL` en el `.env` raíz es `gpt-4o-mini`?**
**Sí.** (No se imprimió el resto del archivo.)

Esto importa porque `AppConstants.openAiModel` cae a `'gpt-5.5'` si la
variable faltara — con el `.env` raíz esto no pasa, pero el harness usa su
**propio** `.env.harness` (aislado a propósito, ver más abajo), así que hay
que asegurarse de poner `OPENAI_MODEL=gpt-4o-mini` ahí también o se corre
el riesgo real de costo que señalaste. El README ya lo deja explícito en
el ejemplo de `.env.harness`.

**¿`precioEspecifico` o `Inventarios.precioVenta`?**
Investigué el código real y **ninguno de los dos** es lo que usa el flujo
de venta por defecto:

| Flujo | Campo que usa |
|---|---|
| `VentaDraftAdapter.defaultUnitPrice` (precio por defecto al confirmar una venta sin precio dictado) | `Producto.ultimoPrecioVenta`, con fallback a `Producto.precioBase` |
| `EntradaDraftAdapter.defaultUnitPrice`/`defaultUnitCost` | Igual, a nivel `Producto` |
| Tool `inventory.getPrecioProducto` (lo que contesta el LLM si preguntás "¿cuánto cuesta?") | `Inventarios.precioVenta` de la bodega, con fallback a `Producto.precioBase` |
| `ProductoVariantes.precioEspecifico`/`costoEspecifico` | **No lo lee ningún flujo del Secretario.** |

El seed sembró un producto (`prd-precio-divergente`, "Vestido Elegante
Rojo", talla M) con `precioEspecifico` deliberadamente distinto
(`precioBase + 954`) de `Inventarios.precioVenta`/`Producto.precioBase`
(iguales entre sí) para demostrarlo con un test
(`secretary_harness_seed_test.dart`, ya en verde). Consecuencia práctica:
si alguien llena `precioEspecifico` en el catálogo esperando que afecte
precios, no pasa nada — es un campo del esquema que el Secretario ignora
por completo.

---

## 1. Hallazgos de código (por revisión, antes de correr nada)

Estos se confirman leyendo el código fuente real, no son suposiciones.
Se van a poder validar/reforzar con evidencia empírica (números reales de
una respuesta del LLM) en cuanto Supabase local esté arriba — los
escenarios 01, 05, 08 y 14 están diseñados específicamente para eso.

### 1.1 `inventory.getStockPorBodega` no filtra por talla/variante
`tool_registry.dart`: cuando se pasa `productoId`, la tool suma
**todas** las variantes (tallas) de ese producto en la bodega y devuelve
un solo número. No existe parámetro de talla. Cualquier pregunta tipo
"¿cuánta talla M hay?" estructuralmente no puede responderse bien con esta
tool — el LLM va a reportar el total de todas las tallas, no el de la
talla pedida.

### 1.2 El borrador de entrada ignora la talla dictada (crea/usa "General")
`entrada_draft_adapter.dart::execute()` arma cada línea de `orderLines`
con `items: List.generate(cantidad, (_) => <String,dynamic>{})` — mapas
**vacíos**. `RegistrarEntradaUseCase._mapOrderLinesToRequestItems` lee
`size`/`sku`/`color` de esos mapas (todos `null`) y
`InventoryDao.resolveVariantForEntry` normaliza `talla ?? 'General'`. En
la práctica: dictar "10 camisas polo talla M" por el Secretario crea o
engorda una variante **"General"**, nunca la M. Esto es exactamente el
riesgo que ya señala `requirements.md` §11 ("no asumir que 'General' es
siempre correcto"), confirmado en código, no solo en la especificación.

### 1.3 `sales.getEstadoCaja.ventasCredito` siempre da 0
`SalesDao.getVentasCreditoPendienteSesion` filtra
`ventas.tipoVenta.equals('credito')` (minúscula, sin tilde). El sistema
real guarda `'Fiado'` (`RegistrarVentaUseCase._normalizeSaleType` siempre
normaliza a `'Fiado'`/`'Contado'`). Ese filtro nunca matchea ninguna fila
→ `ventasCredito` reporta 0 sin importar cuánto fiado pendiente haya en la
sesión. Es un bug de comparación de strings, no de lógica de negocio.

### 1.4 `ventasEfectivo` de `getEstadoCaja` suma TODOS los métodos de pago
`getVentasEfectivoSesion` suma `pagos_ventas.monto_pagado` de la sesión
**sin filtrar por `metodo_pago`** — el nombre sugiere solo efectivo, pero
incluye tarjeta y transferencia también. No es necesariamente un bug (tal
vez sea intencional para el "efectivo esperado" de un cierre de caja
contable), pero el nombre es engañoso y vale la pena confirmarlo con
alguien que conozca el flujo de cierre de caja real.

### 1.5 Ninguna tool expone `fecha_vencimiento`
`sales.getDeudaCliente` y `sales.getResumenDeudas` devuelven
`totalDeuda`/`cantidadFacturas`/`totalFiados`, nunca la fecha de
vencimiento de una venta al fiado. Preguntas como "¿cuál cliente está
vencido?" no tienen forma correcta de responderse con datos reales —el
escenario 07 existe justamente para ver si el modelo lo admite (bien) o
inventa una respuesta (mal).

### 1.6 `getPreciosProductoPorBodega` + `.firstOrNull` puede perder la talla
`inventory.getPrecioProducto` con `bodegaId` busca en
`getPreciosProductoPorBodega(productoId)` y toma
`.where(bodegaId==X).firstOrNull` — si el producto tiene varias variantes
(tallas) en la misma bodega con precios distintos, toma la primera fila
que encuentre en un orden no garantizado por talla. Mismo síntoma que
1.1: la tool no tiene granularidad de variante.

---

## 2. Decisiones de diseño del harness

1. **Runner en `test/harness/`, como `flutter test`, no un CLI Dart puro.**
   Confirmado por código: `ToolExecutor` y `AssistantContextBuilder`
   (dependencias obligatorias de `SecretaryEngine`) importan
   `flutter_riverpod`, que depende de `sdk: flutter` (trae `dart:ui`
   transitivamente) — no corre con `dart run` fuera del toolchain de
   Flutter. Mismo patrón que `test/integration/secretary_llm_e2e_test.dart`.

2. **Aislamiento total del `.env` raíz.** `harness_env.dart` exige
   `test/harness/.env.harness` (gitignorado) y aborta si `SUPABASE_URL` no
   es `localhost`/`127.0.0.1`, o si aparece la ref del proyecto linkeado
   (`tovzdapibtbufjrilptk`) en cualquier variable — con 6 tests que cubren
   cada caso de aborto.

3. **`--dart-define` en vez de flags de CLI.** `flutter test` no acepta
   argumentos arbitrarios ni tiene stdin interactivo, así que
   `HARNESS_SCENARIO` (id | `all` | `scratch`) y `HARNESS_VOICE_MODE` se
   leen con `String.fromEnvironment`/`bool.fromEnvironment`. `scratch.yaml`
   reemplaza el `--repl` pedido originalmente.

4. **Ground truth por SQL crudo (`customSelect`), nunca por DAOs.** Cubre
   stock por variante+bodega, stock total por producto, ventas/métodos de
   pago de hoy, saldo de caja, saldo+vencimiento por cliente, y la
   divergencia de precio de variante. Encontré y corregí un bug real
   propio (no de la app) durante esta etapa: comparar `date('now')` sin el
   modificador `'localtime'` compara contra la fecha UTC, no la fecha
   local — con la máquina en UTC-6 y corriendo de noche, eso desalinea
   "hoy" en varias horas. Se corrigió a `date(x, 'localtime')` en todo el
   ground truth. (La app real no tiene este problema: sus DAOs comparan
   con objetos `DateTime` de Dart, no con `date('now')` de SQLite.)

5. **`confirm_draft: true` en vez de una tool `draft.confirm`.** Simula
   tocar el botón Confirmar llamando `DraftEngine.execute()` directo — el
   mismo camino que usa `SecretaryChatNotifier.confirmDraft()` en la app.
   Esto respeta la restricción de no agregar una tool de confirmación y a
   la vez permite probar el ciclo completo borrador→confirmación→stock
   real en los escenarios 08, 09 y 14.

6. **Verificación en capas, cada una testeada por separado con fixtures
   sintéticos** (sin LLM): `verifyTurn` (texto/tools/borrador — 13 tests),
   `db_snapshot` (conteo + checksum por tabla — 5 tests),
   `ground_truth_template` (placeholders `{{gt:...}}` — 8 tests),
   `scenario` (parseo YAML — 2 tests + carga de los 14 reales), `harness_env`
   (guardas — 6 tests), `harness_report` (JSONL/markdown — 5 tests). Total:
   **41 tests nuevos**, todos en verde, cero llamadas al LLM.

---

## 3. Qué falta (bloqueado en Docker/Supabase local)

- [ ] `supabase start` + verificar migraciones/RLS (`chat_sessions`,
      `chat_messages`, `ai_memories`, `ai_preferences`).
- [ ] `supabase functions serve openai-proxy` con la key real en
      `supabase/functions/.env` (gitignorado).
- [ ] Crear `test/harness/.env.harness` con la URL/anon key locales reales.
- [ ] Primera corrida real: `SECRETARY_HARNESS=1 flutter test
      test/harness/secretary_harness_test.dart --dart-define=HARNESS_SCENARIO=all`.
- [ ] Reporte final con resultados reales (`test/harness/out/<fecha>/report.md`),
      costo total, latencia p50/p95, y diagnóstico de cada fallo.
- [ ] Confirmar o descartar con evidencia real los hallazgos 1.1–1.6 de
      arriba (hoy son de lectura de código; los escenarios 01/05/06/07/08/14
      están armados para volverlos evidencia empírica).

## 4. Cómo seguir

Apenas `docker ps` responda, seguí exactamente
[`test/harness/README.md`](../../../test/harness/README.md) sección 1
(Supabase local) y 2 (correr el harness). Todo el código ya está listo
para esa corrida — no hace falta tocar nada más en `test/harness/` para
la primera pasada, salvo lo que el reporte real termine pidiendo ajustar
en los escenarios (umbrales de texto demasiado estrictos/laxos, etc.).
