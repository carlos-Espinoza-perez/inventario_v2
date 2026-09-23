import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness_env.dart';
import 'harness_report.dart';
import 'scenario.dart';
import 'secretary_harness_runner.dart';
import 'secretary_harness_seed.dart';

/// Harness del Secretario IA (SEC-IA-003): conversaciones reales contra el
/// LLM real (gpt-4o-mini vía el proxy) y una base sembrada de tienda de
/// ropa, para verificar respuestas contra ground truth calculado por SQL.
///
/// Usa red, gasta tokens reales y necesita Supabase LOCAL corriendo
/// (`supabase start` + `supabase functions serve openai-proxy`), así que
/// vive tras una compuerta — nunca corre con `flutter test` a secas:
///
///   $env:SECRETARY_HARNESS='1'
///   flutter test test/harness/secretary_harness_test.dart `
///     --dart-define=HARNESS_SCENARIO=all `
///     --dart-define=HARNESS_VOICE_MODE=false
///
/// `HARNESS_SCENARIO`:
///   - "all" (default): todos los escenarios en test/harness/scenarios/
///     (excluye scratch.yaml).
///   - el id de un archivo puntual, ej. "01_stock_variante_exacta".
///   - "scratch": corre solo test/harness/scenarios/scratch.yaml — el
///     escenario "de borrador" que editás vos y volvés a correr sin tener
///     que craft un archivo nuevo cada vez (reemplaza el modo --repl que
///     pedía el spec original: `flutter test` no tiene stdin interactivo).
///
/// `HARNESS_VOICE_MODE=true` fuerza modo voz en TODOS los escenarios de
/// la corrida, sin importar lo que diga `voice_mode` en su YAML.
void main() {
  final habilitado = Platform.environment['SECRETARY_HARNESS'] == '1';
  final skip = habilitado
      ? null
      : 'Harness del Secretario IA: correr con SECRETARY_HARNESS=1 (usa '
          'red, LLM real y Supabase local). Ver test/harness/README.md.';

  test(
    'harness del Secretario IA sobre la tienda de ropa sembrada',
    () async {
      // 1. Aísla el harness del .env raíz (que apunta a producción) y
      //    valida que .env.harness apunte solo a un Supabase local.
      final harnessEnv = HarnessEnv.loadAndValidate();
      dotenv.testLoad(
        fileInput: File('test/harness/.env.harness').readAsStringSync(),
      );
      // flutter_test intercepta HttpClient por defecto (devuelve 400
      // vacío); el harness necesita red real hacia el proxy local.
      HttpOverrides.global = null;

      final scenarioArg = const String.fromEnvironment(
        'HARNESS_SCENARIO',
        defaultValue: 'all',
      );
      final forceVoiceMode = const bool.fromEnvironment(
        'HARNESS_VOICE_MODE',
        defaultValue: false,
      );

      final seed = SecretaryHarnessSeed();
      await seed.setUp();
      try {
        final groundTruth = await seed.computeGroundTruth();
        final scenarioDir = Directory('test/harness/scenarios');

        final scenarios = switch (scenarioArg) {
          'all' => HarnessScenario.loadDirectory(scenarioDir, groundTruth),
          'scratch' => [
              HarnessScenario.loadFile(
                File('${scenarioDir.path}/scratch.yaml'),
                groundTruth,
              ),
            ],
          final id => [
              HarnessScenario.loadFile(
                File('${scenarioDir.path}/$id.yaml'),
                groundTruth,
              ),
            ],
        };

        // ignore: avoid_print
        print(
          '[harness] Supabase local: ${harnessEnv.supabaseUrl} · '
          '${scenarios.length} escenario(s): '
          '${scenarios.map((s) => s.id).join(', ')}',
        );

        final runner = SecretaryHarnessRunner(seed: seed);
        final results = <ScenarioRunResult>[];
        for (final scenario in scenarios) {
          // ignore: avoid_print
          print('[harness] corriendo ${scenario.id}...');
          final result = await runner.run(
            scenario,
            forceVoiceMode: forceVoiceMode ? true : null,
          );
          results.add(result);
          // ignore: avoid_print
          print(
            '[harness]   ${result.passed ? "OK" : "FALLÓ"} — '
            '\$${result.costUsd.toStringAsFixed(4)}, '
            '${result.turns.length} turno(s)',
          );
        }

        final outDir = prepareOutDir();
        for (final result in results) {
          writeScenarioJsonl(outDir, result);
        }
        writeGroundTruthJson(outDir, groundTruth);
        writeReportMarkdown(outDir, results);

        // ignore: avoid_print
        print('[harness] Reporte en ${outDir.path}/report.md');

        final fallidos = results.where((r) => !r.passed).length;
        if (fallidos > 0) {
          fail(
            '$fallidos de ${results.length} escenario(s) fallaron. '
            'Ver ${outDir.path}/report.md para el detalle.',
          );
        }
      } finally {
        await seed.tearDown();
      }
    },
    skip: skip,
    timeout: const Timeout(Duration(minutes: 30)),
  );
}
