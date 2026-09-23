import 'dart:convert';
import 'dart:io';

import 'secretary_harness_runner.dart';

/// Escribe `<outDir>/<escenario.id>.jsonl` — un objeto JSON por línea, un
/// turno por línea, tal como pide el spec (mensaje del usuario, tools
/// llamadas con argumentos, resultado de cada tool, respuesta final,
/// tokens, costo estimado, latencia, y si el turno tocó un borrador).
void writeScenarioJsonl(Directory outDir, ScenarioRunResult result) {
  final file = File('${outDir.path}/${result.scenario.id}.jsonl');
  final buffer = StringBuffer();
  for (final turn in result.turns) {
    buffer.writeln(jsonEncode(turn.toJsonl()));
  }
  file.writeAsStringSync(buffer.toString());
}

/// Escribe `<outDir>/ground_truth.json` — el snapshot de ground truth que
/// se usó para resolver los `{{gt:...}}` de los escenarios de esta corrida,
/// para poder auditar después con qué valores se comparó cada respuesta.
void writeGroundTruthJson(Directory outDir, Map<String, dynamic> groundTruth) {
  File(
    '${outDir.path}/ground_truth.json',
  ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(groundTruth));
}

/// Arma `<outDir>/report.md`: tabla por escenario, detalle de cada fallo,
/// costo total/promedio y latencia p50/p95.
void writeReportMarkdown(
  Directory outDir,
  List<ScenarioRunResult> results, {
  String? supabaseLocalNote,
}) {
  final buffer = StringBuffer();
  buffer.writeln('# Reporte del harness del Secretario IA — SEC-IA-003');
  buffer.writeln();
  buffer.writeln('Corrida: ${DateTime.now().toIso8601String()}');
  buffer.writeln();

  if (supabaseLocalNote != null) {
    buffer.writeln('## Supabase local');
    buffer.writeln();
    buffer.writeln(supabaseLocalNote);
    buffer.writeln();
  }

  buffer.writeln('## Resumen por escenario');
  buffer.writeln();
  buffer.writeln('| Escenario | Resultado | Turnos | Fallo |');
  buffer.writeln('|---|---|---|---|');
  for (final r in results) {
    final estado = r.passed ? '✅ pasó' : '❌ falló';
    final primerFallo = r.turns
        .expand((t) => t.failures)
        .cast<String?>()
        .firstWhere((f) => f != null, orElse: () => null);
    buffer.writeln(
      '| ${r.scenario.id} — ${r.scenario.title} | $estado | ${r.turns.length} '
      '| ${primerFallo ?? '—'} |',
    );
  }
  buffer.writeln();

  final fallidos = results.where((r) => !r.passed).toList();
  if (fallidos.isNotEmpty) {
    buffer.writeln('## Detalle de fallos');
    buffer.writeln();
    for (final r in fallidos) {
      buffer.writeln('### ${r.scenario.id} — ${r.scenario.title}');
      buffer.writeln();
      for (var i = 0; i < r.turns.length; i++) {
        final t = r.turns[i];
        if (t.passed) continue;
        buffer.writeln('**Turno ${i + 1}** — usuario: "${t.user}"');
        buffer.writeln();
        buffer.writeln('- Respuesta: "${t.response}"');
        buffer.writeln(
          '- Tools llamadas: ${[for (final c in t.toolCallsLog) c['tool']]}',
        );
        buffer.writeln('- Fallos:');
        for (final f in t.failures) {
          buffer.writeln('  - $f');
        }
        buffer.writeln();
        buffer.writeln(
          '  _Diagnóstico (completar a mano tras leer la traza): ¿falló el '
          'resolver, la tool, el prompt o el modelo?_',
        );
        buffer.writeln();
      }
    }
  }

  final allTurns = [for (final r in results) ...r.turns];
  final totalPrompt = allTurns.fold(0, (s, t) => s + t.promptTokens);
  final totalCompletion = allTurns.fold(0, (s, t) => s + t.completionTokens);
  final totalCost = allTurns.fold(0.0, (s, t) => s + t.estimatedCostUsd);
  final latencies = allTurns.map((t) => t.latencyMs).toList()..sort();

  buffer.writeln('## Costo y latencia');
  buffer.writeln();
  buffer.writeln('- Turnos ejecutados: ${allTurns.length}');
  buffer.writeln('- Tokens: $totalPrompt entrada / $totalCompletion salida');
  buffer.writeln('- Costo total estimado: \$${totalCost.toStringAsFixed(4)}');
  buffer.writeln(
    '- Costo promedio por turno: '
    '\$${allTurns.isEmpty ? 0 : (totalCost / allTurns.length).toStringAsFixed(4)}',
  );
  if (latencies.isNotEmpty) {
    buffer.writeln('- Latencia p50: ${_percentile(latencies, 0.5)} ms');
    buffer.writeln('- Latencia p95: ${_percentile(latencies, 0.95)} ms');
  }
  buffer.writeln();

  File('${outDir.path}/report.md').writeAsStringSync(buffer.toString());
}

int _percentile(List<int> sortedValues, double p) {
  if (sortedValues.isEmpty) return 0;
  final index = (sortedValues.length * p).floor().clamp(
        0,
        sortedValues.length - 1,
      );
  return sortedValues[index];
}

/// Directorio de salida `test/harness/out/<AAAA-MM-DD_HHmmss>/`, creado si
/// no existe.
Directory prepareOutDir() {
  final now = DateTime.now();
  String two(int n) => n.toString().padLeft(2, '0');
  final stamp =
      '${now.year}-${two(now.month)}-${two(now.day)}_${two(now.hour)}${two(now.minute)}${two(now.second)}';
  final dir = Directory('test/harness/out/$stamp');
  dir.createSync(recursive: true);
  return dir;
}
