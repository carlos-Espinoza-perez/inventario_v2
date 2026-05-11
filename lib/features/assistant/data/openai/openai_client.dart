import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventario_v2/core/constants/app_constants.dart';
import '../logging/assistant_chat_logger.dart';
import 'openai_models.dart';

abstract class LLMClient {
  Stream<OpenAIStreamChunk> streamChat(OpenAIRequest request);
  Future<OpenAIResponse> chat(OpenAIRequest request);
}

class OpenAIClient implements LLMClient {
  static const _baseUrl = 'https://api.openai.com/v1/chat/completions';
  final AssistantChatLogger? _logger;

  OpenAIClient({AssistantChatLogger? logger}) : _logger = logger;

  Map<String, String> get _headers => {
        'Authorization': 'Bearer ${AppConstants.openAiApiKey}',
        'Content-Type': 'application/json',
      };

  @override
  Stream<OpenAIStreamChunk> streamChat(OpenAIRequest request) async* {
    final callId = DateTime.now().microsecondsSinceEpoch.toString();
    final startedAt = DateTime.now();
    final responseText = StringBuffer();
    await _logger?.logEvent(
      'openai.stream.request',
      data: {
        'callId': callId,
        'request': request.toJson(),
      },
    );

    final req = http.Request('POST', Uri.parse(_baseUrl));
    req.headers.addAll(_headers);
    req.body = jsonEncode(request.toJson());

    try {
      final response = await http.Client().send(req);

      if (response.statusCode != 200) {
        final body = await response.stream.bytesToString();
        await _logger?.logEvent(
          'openai.stream.error',
          data: {
            'callId': callId,
            'statusCode': response.statusCode,
            'body': body,
            'durationMs': DateTime.now().difference(startedAt).inMilliseconds,
          },
        );
        throw OpenAIException(statusCode: response.statusCode, message: body);
      }

      final buffer = StringBuffer();
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        buffer.write(chunk);
        final raw = buffer.toString();
        final lines = raw.split('\n');
        buffer.clear();
        buffer.write(lines.last);

        for (final line in lines.sublist(0, lines.length - 1)) {
          if (!line.startsWith('data: ')) continue;
          final data = line.substring(6).trim();

          if (data == '[DONE]') {
            await _logger?.logEvent(
              'openai.stream.response',
              data: {
                'callId': callId,
                'statusCode': response.statusCode,
                'content': responseText.toString(),
                'durationMs':
                    DateTime.now().difference(startedAt).inMilliseconds,
              },
            );
            yield const OpenAIStreamChunk(isDone: true);
            return;
          }

          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final choices = json['choices'] as List?;
            if (choices == null || choices.isEmpty) continue;
            final delta = choices[0]['delta'] as Map<String, dynamic>?;
            final content = delta?['content'] as String?;
            if (content != null && content.isNotEmpty) {
              responseText.write(content);
              yield OpenAIStreamChunk(content: content);
            }
          } catch (e, st) {
            await _logger?.logEvent(
              'openai.stream.chunk_parse_error',
              data: {
                'callId': callId,
                'rawData': data,
              },
              error: e,
              stackTrace: st,
            );
          }
        }
      }
      await _logger?.logEvent(
        'openai.stream.response',
        data: {
          'callId': callId,
          'statusCode': response.statusCode,
          'content': responseText.toString(),
          'endedWithoutDone': true,
          'durationMs': DateTime.now().difference(startedAt).inMilliseconds,
        },
      );
    } catch (e, st) {
      await _logger?.logEvent(
        'openai.stream.exception',
        data: {
          'callId': callId,
          'durationMs': DateTime.now().difference(startedAt).inMilliseconds,
          'partialContent': responseText.toString(),
        },
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<OpenAIResponse> chat(OpenAIRequest request) async {
    final callId = DateTime.now().microsecondsSinceEpoch.toString();
    final startedAt = DateTime.now();
    final requestForApi = request.copyWith(stream: false);
    await _logger?.logEvent(
      'openai.chat.request',
      data: {
        'callId': callId,
        'request': requestForApi.toJson(),
      },
    );

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: jsonEncode(requestForApi.toJson()),
      );

      if (response.statusCode != 200) {
        await _logger?.logEvent(
          'openai.chat.error',
          data: {
            'callId': callId,
            'statusCode': response.statusCode,
            'body': response.body,
            'durationMs': DateTime.now().difference(startedAt).inMilliseconds,
          },
        );
        throw OpenAIException(
          statusCode: response.statusCode,
          message: response.body,
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final content = json['choices'][0]['message']['content'] as String;
      final usage = json['usage'] as Map<String, dynamic>;
      final openAiResponse = OpenAIResponse(
        content: content,
        promptTokens: usage['prompt_tokens'] as int,
        completionTokens: usage['completion_tokens'] as int,
      );

      await _logger?.logEvent(
        'openai.chat.response',
        data: {
          'callId': callId,
          'statusCode': response.statusCode,
          'content': openAiResponse.content,
          'promptTokens': openAiResponse.promptTokens,
          'completionTokens': openAiResponse.completionTokens,
          'totalTokens': openAiResponse.totalTokens,
          'estimatedCostUsd': openAiResponse.estimatedCostUsd,
          'durationMs': DateTime.now().difference(startedAt).inMilliseconds,
        },
      );

      return openAiResponse;
    } catch (e, st) {
      await _logger?.logEvent(
        'openai.chat.exception',
        data: {
          'callId': callId,
          'durationMs': DateTime.now().difference(startedAt).inMilliseconds,
        },
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}

class OpenAIException implements Exception {
  final int statusCode;
  final String message;

  const OpenAIException({required this.statusCode, required this.message});

  @override
  String toString() => 'OpenAIException($statusCode): $message';
}
