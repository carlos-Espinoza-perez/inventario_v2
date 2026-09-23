import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'harness_report.dart';
import 'scenario.dart';
import 'secretary_harness_runner.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('harness_report_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  ScenarioRunResult buildResult({
    required String id,
    required bool passing,
  }) {
    final scenario = HarnessScenario(
      id: id,
      title: 'Escenario $id',
      voiceMode: false,
      turns: const [],
    );
    final turn = TurnRunResult(
      user: '¿Cuánto stock hay?',
      response: passing ? 'Hay 22 unidades.' : 'Hay 100 unidades.',
      toolCallsLog: const [
        {'id': '1', 'tool': 'inventory.getStockPorBodega', 'arguments': {}},
      ],
      toolResultsLog: const [],
      promptTokens: 500,
      completionTokens: 50,
      latencyMs: 1200,
      draftActive: false,
      draftId: null,
      unexpectedDbChanges: const [],
      failures: passing ? const [] : const ['La respuesta contiene "100"'],
    );
    return ScenarioRunResult(scenario: scenario, turns: [turn]);
  }

  test('writeScenarioJsonl escribe un JSON por línea', () {
    final result = buildResult(id: 'esc-1', passing: true);
    writeScenarioJsonl(tempDir, result);

    final file = File('${tempDir.path}/esc-1.jsonl');
    expect(file.existsSync(), isTrue);
    final lines = file
        .readAsLinesSync()
        .where((l) => l.trim().isNotEmpty)
        .toList();
    expect(lines, hasLength(1));
    final decoded = jsonDecode(lines.first) as Map;
    expect(decoded['user'], '¿Cuánto stock hay?');
    expect(decoded['passed'], isTrue);
  });

  test('writeGroundTruthJson escribe JSON válido e indentado', () {
    writeGroundTruthJson(tempDir, {'a': 1, 'b': 'x'});
    final file = File('${tempDir.path}/ground_truth.json');
    expect(file.existsSync(), isTrue);
    final decoded = jsonDecode(file.readAsStringSync()) as Map;
    expect(decoded['a'], 1);
    expect(decoded['b'], 'x');
  });

  test('writeReportMarkdown incluye escenarios que pasan y que fallan', () {
    final results = [
      buildResult(id: 'esc-ok', passing: true),
      buildResult(id: 'esc-mal', passing: false),
    ];
    writeReportMarkdown(tempDir, results);

    final file = File('${tempDir.path}/report.md');
    expect(file.existsSync(), isTrue);
    final text = file.readAsStringSync();

    expect(text, contains('esc-ok'));
    expect(text, contains('✅ pasó'));
    expect(text, contains('esc-mal'));
    expect(text, contains('❌ falló'));
    expect(text, contains('La respuesta contiene "100"'));
    expect(text, contains('Costo total estimado'));
    expect(text, contains('Latencia p50'));
  });

  test('writeReportMarkdown no revienta con una lista vacía', () {
    writeReportMarkdown(tempDir, const []);
    final file = File('${tempDir.path}/report.md');
    expect(file.existsSync(), isTrue);
    expect(file.readAsStringSync(), contains('Turnos ejecutados: 0'));
  });

  test('prepareOutDir crea un directorio nuevo con timestamp', () {
    final dir = prepareOutDir();
    expect(dir.existsSync(), isTrue);
    final normalizedPath = dir.path.replaceAll(r'\', '/');
    expect(normalizedPath, contains('test/harness/out/'));
    dir.deleteSync(recursive: true);
  });
}
