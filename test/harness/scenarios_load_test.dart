import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'scenario.dart';
import 'secretary_harness_seed.dart';

/// Carga los 14 escenarios "oficiales" (todo menos scratch.yaml) contra el
/// ground truth REAL del seed, para detectar errores de sintaxis YAML o
/// placeholders `{{gt:...}}` que no resuelven — sin gastar un solo token.
void main() {
  late SecretaryHarnessSeed seed;

  setUp(() async {
    seed = SecretaryHarnessSeed();
    await seed.setUp();
  });

  tearDown(() => seed.tearDown());

  test('los 14 escenarios cargan y todos los {{gt:...}} resuelven', () async {
    final groundTruth = await seed.computeGroundTruth();
    final dir = Directory('test/harness/scenarios');

    final scenarios = HarnessScenario.loadDirectory(dir, groundTruth);

    expect(
      scenarios.length,
      greaterThanOrEqualTo(14),
      reason: 'Se esperaban al menos 14 escenarios en test/harness/scenarios/ '
          '(sin contar scratch.yaml).',
    );
    for (final s in scenarios) {
      expect(s.turns, isNotEmpty, reason: '${s.id} no tiene turnos.');
      for (final t in s.turns) {
        expect(
          t.user != null || t.confirmDraft,
          isTrue,
          reason: '${s.id}: un turno no trae ni "user" ni "confirm_draft".',
        );
      }
    }
  });

  test('scratch.yaml también carga (aunque no entra en HARNESS_SCENARIO=all)',
      () async {
    final groundTruth = await seed.computeGroundTruth();
    final scratch = HarnessScenario.loadFile(
      File('test/harness/scenarios/scratch.yaml'),
      groundTruth,
    );
    expect(scratch.turns, isNotEmpty);
  });

  test('scenario 13 tiene exactamente 40 turnos', () async {
    final groundTruth = await seed.computeGroundTruth();
    final scenario = HarnessScenario.loadFile(
      File('test/harness/scenarios/13_conversacion_larga.yaml'),
      groundTruth,
    );
    expect(scenario.turns, hasLength(40));
  });

  test('scenario 14 es voice_mode y sus turnos piden max_sentences', () async {
    final groundTruth = await seed.computeGroundTruth();
    final scenario = HarnessScenario.loadFile(
      File('test/harness/scenarios/14_modo_voz.yaml'),
      groundTruth,
    );
    expect(scenario.voiceMode, isTrue);
    final conMaxSentences =
        scenario.turns.where((t) => t.expect.maxSentences != null);
    expect(conMaxSentences, isNotEmpty);
  });
}
