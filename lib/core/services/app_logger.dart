import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

enum LogLevel { debug, info, warn, error }

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  File? _logFile;
  final int _maxFileSize = 5 * 1024 * 1024; // 5 MB max

  Future<void> init() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _logFile = File(p.join(directory.path, 'app_logs.txt'));
      if (!await _logFile!.exists()) {
        await _logFile!.create(recursive: true);
        _writeHeader();
      } else {
        // Rotación si excede tamaño
        final size = await _logFile!.length();
        if (size > _maxFileSize) {
          final backup = File(p.join(directory.path, 'app_logs_backup.txt'));
          if (await backup.exists()) await backup.delete();
          await _logFile!.rename(backup.path);
          _logFile = File(p.join(directory.path, 'app_logs.txt'));
          await _logFile!.create(recursive: true);
          _writeHeader();
        }
      }
    } catch (e) {
      debugPrint('[AppLogger] Error al inicializar archivo de logs: $e');
    }
  }

  void _writeHeader() {
    final now = DateTime.now().toIso8601String();
    _logFile?.writeAsStringSync('=== INVENTARIO V2 LOGS INICIADOS: $now ===\n', mode: FileMode.append);
  }

  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _instance._log(LogLevel.debug, message, error, stackTrace);
  }

  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    _instance._log(LogLevel.info, message, error, stackTrace);
  }

  static void warn(String message, [Object? error, StackTrace? stackTrace]) {
    _instance._log(LogLevel.warn, message, error, stackTrace);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _instance._log(LogLevel.error, message, error, stackTrace);
  }

  void _log(LogLevel level, String message, Object? error, StackTrace? stackTrace) {
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase().padRight(5);
    final logLine = StringBuffer('[$timestamp] [$levelStr] $message');

    if (error != null) {
      logLine.write(' | ERROR: $error');
    }
    if (stackTrace != null) {
      logLine.write('\n$stackTrace');
    }

    final formattedLine = logLine.toString();
    debugPrint(formattedLine);

    _writeToFile('$formattedLine\n');
  }

  Future<void> _writeToFile(String line) async {
    if (_logFile == null) {
      await init();
    }
    try {
      if (_logFile != null && await _logFile!.exists()) {
        await _logFile!.writeAsString(line, mode: FileMode.append);
      }
    } catch (e) {
      debugPrint('[AppLogger] Fallo al escribir en log file: $e');
    }
  }

  Future<String> getLogs() async {
    if (_logFile == null) await init();
    if (_logFile != null && await _logFile!.exists()) {
      try {
        return await _logFile!.readAsString();
      } catch (e) {
        return 'Error leyendo archivo de logs: $e';
      }
    }
    return 'Archivo de logs vacío o no inicializado.';
  }

  Future<void> clearLogs() async {
    if (_logFile == null) await init();
    if (_logFile != null && await _logFile!.exists()) {
      try {
        await _logFile!.writeAsString('=== LOGS LIMPIADOS: ${DateTime.now().toIso8601String()} ===\n');
      } catch (e) {
        debugPrint('[AppLogger] Fallo al limpiar logs: $e');
      }
    }
  }
}
