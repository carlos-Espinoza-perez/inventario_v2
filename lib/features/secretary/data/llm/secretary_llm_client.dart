import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:inventario_v2/core/constants/app_constants.dart';
import 'package:inventario_v2/core/services/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'secretary_llm_models.dart';

/// Cliente de chat con function calling nativo de OpenAI, vía la Edge
/// Function openai-proxy (la API key vive en el servidor; el proxy reenvía el
/// body tal cual, incluidos `tools` y los deltas de `tool_calls` del SSE).
class SecretaryLlmClient {
  static String get _baseUrl => AppConstants.openAiProxyUrl;

  Map<String, String> get _headers {
    final accessToken =
        Supabase.instance.client.auth.currentSession?.accessToken ??
            AppConstants.supabaseAnonKey;
    return {
      'Authorization': 'Bearer $accessToken',
      'apikey': AppConstants.supabaseAnonKey,
      'Content-Type': 'application/json',
    };
  }

  /// Envía la petición en streaming. Emite [SecLlmDelta] por cada fragmento
  /// de texto y cierra con un único [SecLlmCompleted] que incluye los
  /// tool_calls agregados (si el modelo decidió usar herramientas) y el usage.
  Stream<SecLlmEvent> streamChat(SecLlmRequest request) async* {
    final req = http.Request('POST', Uri.parse(_baseUrl));
    req.headers.addAll(_headers);
    req.body = jsonEncode(request.toJson());

    final response = await http.Client().send(req);
    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      throw SecretaryLlmException(
        statusCode: response.statusCode,
        message: body,
      );
    }

    final contentBuffer = StringBuffer();
    // Los tool_calls llegan fragmentados por index: {index, id?, function:
    // {name?, arguments?}}. Se acumulan hasta el cierre del stream.
    final toolCallIds = <int, String>{};
    final toolCallNames = <int, String>{};
    final toolCallArgs = <int, StringBuffer>{};
    String? finishReason;
    int? promptTokens;
    int? completionTokens;

    final lineBuffer = StringBuffer();
    await for (final chunk in response.stream.transform(utf8.decoder)) {
      lineBuffer.write(chunk);
      final raw = lineBuffer.toString();
      final lines = raw.split('\n');
      lineBuffer.clear();
      lineBuffer.write(lines.last);

      for (final line in lines.sublist(0, lines.length - 1)) {
        if (!line.startsWith('data: ')) continue;
        final data = line.substring(6).trim();
        if (data == '[DONE]') continue;

        Map<String, dynamic> json;
        try {
          json = jsonDecode(data) as Map<String, dynamic>;
        } catch (e) {
          AppLogger.warn('[Secretary][LLM] Chunk SSE no parseable: $data');
          continue;
        }

        final usage = json['usage'] as Map<String, dynamic>?;
        if (usage != null) {
          promptTokens = usage['prompt_tokens'] as int?;
          completionTokens = usage['completion_tokens'] as int?;
        }

        final choices = json['choices'] as List?;
        if (choices == null || choices.isEmpty) continue;
        final choice = choices[0] as Map<String, dynamic>;
        finishReason = choice['finish_reason'] as String? ?? finishReason;

        final delta = choice['delta'] as Map<String, dynamic>?;
        if (delta == null) continue;

        final content = delta['content'] as String?;
        if (content != null && content.isNotEmpty) {
          contentBuffer.write(content);
          yield SecLlmDelta(content);
        }

        final toolCalls = delta['tool_calls'] as List?;
        if (toolCalls != null) {
          for (final tc in toolCalls) {
            final map = tc as Map<String, dynamic>;
            final index = (map['index'] as num?)?.toInt() ?? 0;
            final id = map['id'] as String?;
            if (id != null) toolCallIds[index] = id;
            final fn = map['function'] as Map<String, dynamic>?;
            if (fn != null) {
              final name = fn['name'] as String?;
              if (name != null) {
                toolCallNames[index] =
                    (toolCallNames[index] ?? '') + name;
              }
              final args = fn['arguments'] as String?;
              if (args != null) {
                toolCallArgs
                    .putIfAbsent(index, () => StringBuffer())
                    .write(args);
              }
            }
          }
        }
      }
    }

    final calls = <SecToolCall>[];
    final indices = toolCallNames.keys.toList()..sort();
    for (final index in indices) {
      calls.add(
        SecToolCall(
          id: toolCallIds[index] ?? 'call_$index',
          apiName: toolCallNames[index] ?? '',
          argumentsJson: toolCallArgs[index]?.toString() ?? '{}',
        ),
      );
    }

    yield SecLlmCompleted(
      content: contentBuffer.toString(),
      toolCalls: calls,
      finishReason: finishReason,
      promptTokens: promptTokens,
      completionTokens: completionTokens,
    );
  }
}

class SecretaryLlmException implements Exception {
  final int statusCode;
  final String message;

  const SecretaryLlmException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => 'SecretaryLlmException($statusCode): $message';
}
