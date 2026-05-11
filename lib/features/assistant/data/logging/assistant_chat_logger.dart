import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class AssistantChatLogger {
  static const _logFolderName = 'assistant_logs';

  Future<void> _writeQueue = Future.value();

  Future<void> logEvent(
    String event, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final payload = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'event': event,
      if (data != null) 'data': _sanitize(data),
      if (error != null) 'error': error.toString(),
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
    };

    final line = '${jsonEncode(payload)}\n';
    debugPrint('[AssistantLog] $event ${error ?? ''}'.trim());

    _writeQueue = _writeQueue.then((_) => _appendLine(line));
    return _writeQueue;
  }

  Future<String> logDirectoryPath() async {
    final dir = await _logDirectory();
    return dir.path;
  }

  Future<void> _appendLine(String line) async {
    try {
      final dir = await _logDirectory();
      final fileName = _fileNameFor(DateTime.now());
      final file = File('${dir.path}${Platform.pathSeparator}$fileName');
      await file.writeAsString(line, mode: FileMode.append, flush: true);
    } catch (e) {
      debugPrint('[AssistantLog] No se pudo escribir el log: $e');
    }
  }

  Future<Directory> _logDirectory() async {
    final baseDir = await getApplicationSupportDirectory();
    final dir =
        Directory('${baseDir.path}${Platform.pathSeparator}$_logFolderName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String _fileNameFor(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return 'assistant_chat_$y-$m-$d.jsonl';
  }

  dynamic _sanitize(dynamic value) {
    if (value is Map) {
      return value.map((key, val) {
        final keyText = key.toString();
        final lowerKey = keyText.toLowerCase();
        if (lowerKey.contains('api_key') ||
            lowerKey.contains('apikey') ||
            lowerKey.contains('authorization') ||
            lowerKey == 'token' ||
            lowerKey == 'access_token' ||
            lowerKey == 'refresh_token' ||
            lowerKey == 'id_token' ||
            lowerKey.contains('password')) {
          return MapEntry(keyText, '[redacted]');
        }
        return MapEntry(keyText, _sanitize(val));
      });
    }
    if (value is Iterable) return value.map(_sanitize).toList();
    return value;
  }
}
