// Uso puntual de diagnóstico: lee chat_turn_traces de una DB extraída del
// dispositivo. dart run tool/dump_traces.dart <ruta.sqlite> [limit]
import 'dart:ffi';
import 'dart:io';

import 'package:sqlite3/open.dart' as sqlite_open;
import 'package:sqlite3/sqlite3.dart';

void main(List<String> args) {
  sqlite_open.open.overrideFor(sqlite_open.OperatingSystem.windows, () {
    try {
      return DynamicLibrary.open('sqlite3.dll');
    } catch (_) {
      return DynamicLibrary.open('winsqlite3.dll');
    }
  });

  final path = args.isNotEmpty ? args[0] : 'device_db.sqlite';
  final limit = args.length > 1 ? int.parse(args[1]) : 5;
  final db = sqlite3.open(path, mode: OpenMode.readOnly);

  final rows = db.select(
    'SELECT created_at, model, latency_ms, tokens_in, tokens_out, '
    'error_text, tool_calls_json, tool_results_json, request_json '
    'FROM chat_turn_traces ORDER BY created_at DESC LIMIT ?',
    [limit],
  );
  for (final row in rows) {
    stdout.writeln('=' * 70);
    stdout.writeln('fecha: ${row['created_at']}  modelo: ${row['model']}  '
        'lat: ${row['latency_ms']}ms  tok: ${row['tokens_in']}/${row['tokens_out']}');
    if (row['error_text'] != null) {
      stdout.writeln('ERROR: ${row['error_text']}');
    }
    stdout.writeln('TOOL CALLS: ${row['tool_calls_json']}');
    final results = row['tool_results_json']?.toString() ?? '';
    stdout.writeln(
      'TOOL RESULTS: ${results.length > 1200 ? '${results.substring(0, 1200)}…' : results}',
    );
    final request = row['request_json']?.toString() ?? '';
    // Los mensajes user van al final del payload: mostrar la cola.
    stdout.writeln(
      'REQUEST (cola): …${request.length > 800 ? request.substring(request.length - 800) : request}',
    );
  }
  db.dispose();
}
