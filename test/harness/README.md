# Harness del Secretario IA (SEC-IA-003)

Conversaciones reales contra el motor real de `lib/features/secretary/`
(el mismo `SecretaryEngine`, `EntityResolver`, `DraftEngine`, tools, que usa
la app), una base sembrada de tienda de ropa, y el LLM real (gpt-4o-mini vía
el proxy), corriendo contra **Supabase local** — nunca contra producción.

Vive en `test/` (no en `tool/`) porque el motor depende de `flutter_riverpod`
→ `package:flutter` → `dart:ui` de forma transitiva (ver "Por qué `flutter
test` y no un CLI Dart puro" abajo), así que solo puede correr dentro del
toolchain de Flutter.

## Qué hace y qué no

- **Sí** ejecuta turnos reales contra el LLM real: cuesta centavos y gasta
  tokens.
- **Sí** verifica respuestas contra un *ground truth* calculado con SQL
  crudo sobre el seed (independiente de los DAOs/tools que usa el motor).
- **Sí** puede simular tocar el botón "Confirmar" de un borrador
  (`confirm_draft: true` en un escenario) — nunca vía una tool del LLM.
- **No** corrige nada del Secretario. Solo reporta.
- **No** toca Supabase remoto. `harness_env.dart` aborta si
  `SUPABASE_URL` no es localhost.

## 1. Levantar todo desde cero

### 1.1 Supabase local

Requiere Docker corriendo (`supabase start` levanta contenedores).

```bash
supabase start
```

Al terminar imprime `API URL` (normalmente `http://127.0.0.1:54321`) y
`anon key`. Guardalos para el paso 1.3.

Verificar que las tablas del secretario y sus políticas RLS quedaron:

```bash
supabase db reset   # aplica TODAS las migraciones locales desde cero
```

Confirmar que existen `chat_sessions`, `chat_messages`, `ai_memories`,
`ai_preferences` (Studio local en `http://127.0.0.1:54323`, o `psql`/
`supabase db dump` si preferís línea de comandos).

### 1.2 Edge Function `openai-proxy`

```bash
cd supabase/functions
echo "OPENAI_API_KEY=sk-..." > .env   # NUNCA lo subas — ya está en .gitignore
cd ../..
supabase functions serve openai-proxy --env-file supabase/functions/.env
```

Dejalo corriendo en una terminal aparte.

### 1.3 `.env.harness`

El harness **no carga el `.env` raíz** (ese apunta a producción). Creá
`test/harness/.env.harness` (gitignorado):

```
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=<el anon key que imprimió supabase start>
OPENAI_MODEL=gpt-4o-mini
OPENAI_TEMPERATURE=0.2
OPENAI_MAX_TOKENS=1024
```

`HarnessEnv.loadAndValidate()` (`harness_env.dart`) revienta con un mensaje
claro si falta el archivo, si `SUPABASE_URL` no es `localhost`/`127.0.0.1`,
o si aparece la ref del proyecto de producción linkeado
(`tovzdapibtbufjrilptk`, ver `supabase/.temp/linked-project.json`) en
cualquier variable.

### 1.4 Usuario de prueba

El seed (`secretary_harness_seed.dart`) ya crea su propio usuario/empresa
**en la base Drift en memoria** — no necesita un usuario real de Supabase
Auth para eso. El único uso de Supabase Auth es el *header* `Authorization`
que manda `SecretaryLlmClient` hacia el proxy
(`Supabase.instance.client.auth.currentSession?.accessToken`); como en los
tests de integración existentes, si no hay sesión de Supabase inicializada
cae al `anon key` (que el proxy local acepta igual, `verify_jwt` local no
bloquea el anon key). Si en algún momento hace falta un usuario real
autenticado, crearlo con:

```bash
supabase auth signup --email harness@local.test --password loquesea --experimental
```

y loguear ese usuario en `setUp()` antes de correr — no debería hacer
falta para los 14 escenarios actuales.

## 2. Correr el harness

```bash
$env:SECRETARY_HARNESS='1'
flutter test test/harness/secretary_harness_test.dart `
  --dart-define=HARNESS_SCENARIO=all `
  --dart-define=HARNESS_VOICE_MODE=false
```

(bash: `SECRETARY_HARNESS=1 flutter test test/harness/secretary_harness_test.dart --dart-define=HARNESS_SCENARIO=all`)

`HARNESS_SCENARIO`:

- `all` (default): todos los escenarios de `scenarios/` menos `scratch.yaml`.
- el id de un archivo puntual, ej. `01_stock_variante_exacta`.
- `scratch`: corre solo `scenarios/scratch.yaml`.

`HARNESS_VOICE_MODE=true` fuerza modo voz (máx. 2 frases) en **todos** los
escenarios de la corrida, sin importar lo que diga `voice_mode` en su YAML.

Sin `SECRETARY_HARNESS=1`, el test se salta solo (igual que
`test/integration/secretary_llm_e2e_test.dart`) — `flutter test` normal
nunca gasta tokens de este harness.

La salida queda en `test/harness/out/<AAAA-MM-DD_HHmmss>/`:

- `<escenario>.jsonl`: un objeto JSON por línea, un turno por línea
  (mensaje, tools llamadas + argumentos, resultado de cada tool, respuesta
  final, tokens, costo estimado, latencia, si tocó un borrador).
- `ground_truth.json`: el snapshot de ground truth que se usó para resolver
  los `{{gt:...}}` de esa corrida — para auditar después con qué se
  comparó cada respuesta.
- `report.md`: tabla pasa/falla por escenario, detalle de cada fallo (turno,
  respuesta, tools llamadas), costo total/promedio, latencia p50/p95.

Todo ese directorio está gitignorado (`test/harness/out/`).

## 3. Modo "REPL" → `scratch.yaml`

`flutter test` no tiene stdin interactivo, así que no hay un `--repl` de
verdad. En su lugar: editá `test/harness/scenarios/scratch.yaml` (un
escenario normal, con el mismo formato que cualquier otro) y corré:

```bash
flutter test test/harness/secretary_harness_test.dart --dart-define=HARNESS_SCENARIO=scratch
```

Corre exactamente con el mismo motor/seed/ground truth que el resto —
más lento que un REPL real, pero sin duplicar infraestructura.

## 4. Agregar un escenario nuevo

1. Copiá cualquier archivo de `scenarios/` como punto de partida.
2. Cada turno es `user: "..."` (manda un mensaje al LLM) o
   `confirm_draft: true` (simula el botón Confirmar, no llama al LLM).
3. `expect:` es opcional en cada turno; los campos disponibles están
   documentados en los comentarios de `scenario.dart`
   (`HarnessExpectation`): `tools_any_of`, `tools_all_of`, `tools_none_of`,
   `response_contains_all`, `response_contains_any`,
   `response_not_contains_any`, `draft_expected`, `db_unchanged_tables`,
   `max_sentences`, `note`.
4. Usá `{{gt:path.a.valor}}` para referenciar el ground truth calculado del
   seed en vez de hardcodear un número — ver `ground_truth_template.dart`
   para los paths disponibles (`stockTotalPorProducto.<productoId>`,
   `stockPorVarianteIndex.<productoId>|<talla>|<bodegaId>`,
   `saldosClientes.<clienteId>.saldo`, `ventasHoy.total`,
   `caja.totalPagos`, etc. — el shape completo está en
   `SecretaryHarnessSeed.computeGroundTruth()`).
5. Corré `flutter test test/harness/scenarios_load_test.dart` para
   confirmar que el YAML parsea y que todos los `{{gt:...}}` resuelven,
   **sin gastar tokens**, antes de correrlo de verdad con
   `SECRETARY_HARNESS=1`.
6. Si el escenario necesita un producto/cliente/caso nuevo que no está en
   el seed, agregalo en `secretary_harness_seed.dart` (seguí el patrón de
   `addProduct`/`venta` que ya está ahí) y corré
   `flutter test test/harness/secretary_harness_seed_test.dart` para
   confirmar que el seed y el ground truth siguen siendo consistentes.

## 5. Por qué `flutter test` y no un CLI Dart puro

`SecretaryEngine` usa `ToolExecutor` (`data/tools/tool_executor.dart`) y
`AssistantContextBuilder` (`data/context/assistant_context_builder.dart`),
ambos con `import 'package:flutter_riverpod/flutter_riverpod.dart'`.
`flutter_riverpod` depende de `sdk: flutter` (trae `ConsumerWidget`, etc.,
que a su vez importan `package:flutter/widgets.dart` → `dart:ui`), que solo
existe dentro del toolchain de Flutter — no corre con `dart run` a secas.
Por eso el runner vive como `flutter test` (igual que
`test/integration/secretary_llm_e2e_test.dart`), con
`TestWidgetsFlutterBinding.ensureInitialized()` y un mock del canal de
`flutter_secure_storage`, en vez de un CLI Dart independiente.

## 6. Limitaciones conocidas del harness (no del Secretario)

- El runner manda **todo** el historial de la conversación en cada turno
  (`secretary_harness_runner.dart`) — no pasa por `ChatRepository` ni
  `SessionSummarizer` como la app real, que recorta a los últimos ~12
  mensajes + un resumen acumulado
  (`AppConstants.assistantHistoryTurns`). El escenario 13 (conversación de
  40 turnos) lo documenta explícitamente: es un caso *más fácil* que el de
  la app real, así que si falla ahí, seguro falla peor en producción; si
  pasa, no prueba que el rolling summary de la app funcione.
- `db_unchanged_tables` compara conteo + un checksum por fila
  (`db_snapshot.dart`) — detecta inserts y updates, pero dos filas
  distintas que casualmente producen el mismo checksum (colisión de
  `hashCode`) no se detectarían. Con las tablas y volúmenes del seed el
  riesgo es prácticamente nulo, pero queda anotado.
- Las verificaciones de texto (`response_contains_*`) son *case
  insensitive* y buscan substring simple, no NLP — un "no" perdido en
  medio de una respuesta larga puede dar un falso positivo/negativo.
  Para casos donde el texto no alcanza (ambigüedad genuina, ej. escenario
  02 y 07), el escenario lo marca con `note:` pidiendo revisión manual del
  JSONL.
