import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// Keep log levels compact because they are rendered in a dense mobile log view.
enum LogLevel { debug, info, warn, error }

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  File? _logFile;
  Object? _lastInitError;
  bool _isInitializing = false;
  final int _maxFileSize = 5 * 1024 * 1024;
  final Queue<String> _memoryBuffer = Queue<String>();
  static const int _maxMemoryLines = 500;

  Future<void> init() async {
    if (_isInitializing) return;
    _isInitializing = true;

    try {
      final directory = await _resolveLogDirectory();
      await directory.create(recursive: true);
      _logFile = File(p.join(directory.path, 'app_logs.txt'));

      if (!await _logFile!.exists()) {
        await _logFile!.create(recursive: true);
        await _writeHeader();
      } else {
        final size = await _logFile!.length();
        if (size > _maxFileSize) {
          final backup = File(p.join(directory.path, 'app_logs_backup.txt'));
          if (await backup.exists()) await backup.delete();
          await _logFile!.rename(backup.path);
          _logFile = File(p.join(directory.path, 'app_logs.txt'));
          await _logFile!.create(recursive: true);
          await _writeHeader();
        }
      }

      _lastInitError = null;
      await _flushMemoryBuffer();
    } catch (e, st) {
      _lastInitError = e;
      debugPrint('[AppLogger] Error al inicializar archivo de logs: $e');
      debugPrint(st.toString());
    } finally {
      _isInitializing = false;
    }
  }

  Future<Directory> _resolveLogDirectory() async {
    try {
      return await getApplicationDocumentsDirectory();
    } catch (_) {
      return getApplicationSupportDirectory();
    }
  }

  Future<void> _writeHeader() async {
    final now = DateTime.now().toIso8601String();
    await _logFile?.writeAsString(
      '=== INVENTARIO V2 LOGS INICIADOS: $now ===\n',
      mode: FileMode.append,
    );
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

  void _log(
    LogLevel level,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
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
    _appendMemory('$formattedLine\n');
    _writeToFile('$formattedLine\n');
  }

  void _appendMemory(String line) {
    _memoryBuffer.add(line);
    while (_memoryBuffer.length > _maxMemoryLines) {
      _memoryBuffer.removeFirst();
    }
  }

  Future<void> _writeToFile(String line) async {
    if (_logFile == null || !await _logFile!.exists()) {
      await init();
    }

    try {
      if (_logFile != null) {
        await _logFile!.writeAsString(line, mode: FileMode.append);
      }
    } catch (e) {
      _lastInitError = e;
      debugPrint('[AppLogger] Fallo al escribir en log file: $e');
    }
  }

  Future<void> _flushMemoryBuffer() async {
    if (_logFile == null || _memoryBuffer.isEmpty) return;
    final pending = _memoryBuffer.join();
    await _logFile!.writeAsString(pending, mode: FileMode.append);
    _memoryBuffer.clear();
  }

  Future<String> getLogs() async {
    if (_logFile == null || !await _logFile!.exists()) {
      await init();
    }

    final buffer = StringBuffer();
    if (_logFile != null) {
      buffer.writeln('Archivo: ${_logFile!.path}');
      try {
        final content = await _readLogFileContent(_logFile!);
        if (content.trim().isNotEmpty) {
          buffer.writeln(content.trimRight());
        }
      } catch (e) {
        buffer.writeln('No se pudo leer el archivo de logs: $e');
      }
    }

    if (buffer.isEmpty && _memoryBuffer.isNotEmpty) {
      buffer.writeln('Logs en memoria temporal:');
      buffer.write(_memoryBuffer.join());
    }

    if (_lastInitError != null) {
      buffer.writeln(
        'Aviso: no se pudo preparar el archivo de logs: $_lastInitError',
      );
    }

    if (buffer.isEmpty) {
      return 'Todavia no hay logs registrados.';
    }

    return buffer.toString();
  }

  Future<String> _readLogFileContent(File file) async {
    final bytes = await file.readAsBytes();
    try {
      return utf8.decode(bytes);
    } on FormatException {
      // Older builds wrote logs with a platform/default encoding. Keep the
      // viewer useful instead of failing with "Failed to decode utf-8".
      return latin1.decode(bytes);
    }
  }

  Future<void> clearLogs() async {
    _memoryBuffer.clear();
    if (_logFile == null || !await _logFile!.exists()) await init();
    if (_logFile != null) {
      try {
        await _logFile!.writeAsString(
          '=== LOGS LIMPIADOS: ${DateTime.now().toIso8601String()} ===\n',
        );
      } catch (e) {
        _lastInitError = e;
        debugPrint('[AppLogger] Fallo al limpiar logs: $e');
      }
    }
  }
}
