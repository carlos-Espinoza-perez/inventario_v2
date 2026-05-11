# Plan 03 - Cliente OpenAI con Streaming

---

## Objetivo

Implementar el cliente HTTP para OpenAI con soporte de streaming SSE (Server-Sent Events). Este cliente es la única pieza del sistema que sabe sobre OpenAI. Todo lo demás habla con interfaces abstractas para que cambiar de modelo o proveedor no toque más de un archivo.

**Modelo:** `gpt-4o-mini`
**Temperatura:** `0.2` (preciso, no creativo)
**Streaming:** obligatorio para experiencia conversacional fluida

---

## Cómo funciona el streaming de OpenAI

OpenAI devuelve los tokens como un stream de eventos SSE:

```
data: {"choices":[{"delta":{"content":"Tenés"},"index":0}]}
data: {"choices":[{"delta":{"content":" 48"},"index":0}]}
data: {"choices":[{"delta":{"content":" unidades"},"index":0}]}
data: [DONE]
```

Dart puede consumir esto con `http` estándar leyendo el body como `Stream<List<int>>`. No se necesita ningún paquete adicional.

---

## Paso 1 — Modelos de OpenAI

```dart
// lib/features/assistant/data/openai/openai_models.dart

class OpenAIMessage {
  final String role;    // 'system' | 'user' | 'assistant'
  final String content;

  const OpenAIMessage({required this.role, required this.content});

  Map<String, String> toJson() => {'role': role, 'content': content};

  factory OpenAIMessage.system(String content) =>
      OpenAIMessage(role: 'system', content: content);
  factory OpenAIMessage.user(String content) =>
      OpenAIMessage(role: 'user', content: content);
  factory OpenAIMessage.assistant(String content) =>
      OpenAIMessage(role: 'assistant', content: content);
}

class OpenAIRequest {
  final String model;
  final List<OpenAIMessage> messages;
  final double temperature;
  final int maxTokens;
  final bool stream;
  final Map<String, dynamic>? responseFormat; // para structured outputs

  const OpenAIRequest({
    required this.model,
    required this.messages,
    this.temperature = 0.2,
    this.maxTokens = 1024,
    this.stream = true,
    this.responseFormat,
  });

  Map<String, dynamic> toJson() => {
        'model': model,
        'messages': messages.map((m) => m.toJson()).toList(),
        'temperature': temperature,
        'max_tokens': maxTokens,
        'stream': stream,
        if (responseFormat != null) 'response_format': responseFormat,
      };
}

class OpenAIStreamChunk {
  final String? content;  // null en el último chunk [DONE]
  final bool isDone;

  const OpenAIStreamChunk({this.content, this.isDone = false});
}

class OpenAIResponse {
  final String content;
  final int promptTokens;
  final int completionTokens;

  const OpenAIResponse({
    required this.content,
    required this.promptTokens,
    required this.completionTokens,
  });

  int get totalTokens => promptTokens + completionTokens;

  /// Costo estimado en USD para gpt-4o-mini
  /// Input: $0.150 / 1M tokens, Output: $0.600 / 1M tokens
  double get estimatedCostUsd =>
      (promptTokens * 0.150 / 1_000_000) +
      (completionTokens * 0.600 / 1_000_000);
}
```

---

## Paso 2 — Cliente OpenAI con streaming

```dart
// lib/features/assistant/data/openai/openai_client.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'openai_models.dart';

abstract class LLMClient {
  Stream<OpenAIStreamChunk> streamChat(OpenAIRequest request);
  Future<OpenAIResponse> chat(OpenAIRequest request);
}

class OpenAIClient implements LLMClient {
  static const _baseUrl = 'https://api.openai.com/v1/chat/completions';

  String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  String get _model => dotenv.env['OPENAI_MODEL'] ?? 'gpt-4o-mini';

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      };

  /// Streaming: devuelve tokens conforme llegan
  @override
  Stream<OpenAIStreamChunk> streamChat(OpenAIRequest request) async* {
    final req = http.Request('POST', Uri.parse(_baseUrl));
    req.headers.addAll(_headers);
    req.body = jsonEncode(request.toJson());

    final response = await http.Client().send(req);

    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      throw OpenAIException(
        statusCode: response.statusCode,
        message: body,
      );
    }

    // Leer el stream SSE línea por línea
    final buffer = StringBuffer();
    await for (final chunk in response.stream.transform(utf8.decoder)) {
      buffer.write(chunk);
      final raw = buffer.toString();

      // Procesar líneas completas
      final lines = raw.split('\n');
      // Conservar la última línea si está incompleta
      buffer.clear();
      buffer.write(lines.last);

      for (final line in lines.sublist(0, lines.length - 1)) {
        if (!line.startsWith('data: ')) continue;
        final data = line.substring(6).trim();

        if (data == '[DONE]') {
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
            yield OpenAIStreamChunk(content: content);
          }
        } catch (_) {
          // Ignorar líneas malformadas
        }
      }
    }
  }

  /// Non-streaming: útil para el router semántico (structured outputs)
  @override
  Future<OpenAIResponse> chat(OpenAIRequest request) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers,
      body: jsonEncode(request.copyWith(stream: false).toJson()),
    );

    if (response.statusCode != 200) {
      throw OpenAIException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final content = json['choices'][0]['message']['content'] as String;
    final usage = json['usage'] as Map<String, dynamic>;

    return OpenAIResponse(
      content: content,
      promptTokens: usage['prompt_tokens'] as int,
      completionTokens: usage['completion_tokens'] as int,
    );
  }
}

class OpenAIException implements Exception {
  final int statusCode;
  final String message;

  const OpenAIException({required this.statusCode, required this.message});

  @override
  String toString() => 'OpenAIException($statusCode): $message';
}

// Extensión para copiar con stream=false
extension on OpenAIRequest {
  OpenAIRequest copyWith({bool? stream}) => OpenAIRequest(
        model: model,
        messages: messages,
        temperature: temperature,
        maxTokens: maxTokens,
        stream: stream ?? this.stream,
        responseFormat: responseFormat,
      );
}
```

---

## Paso 3 — Provider del cliente

```dart
// En assistant_provider.dart o en un archivo de providers separado

final openAIClientProvider = Provider<LLMClient>((ref) {
  return OpenAIClient();
});
```

Usar la interfaz `LLMClient` en todos los lugares para facilitar mocking en tests.

---

## Paso 4 — Structured Outputs para el router

El router semántico necesita una respuesta JSON garantizada, no texto libre. Usar `response_format` de OpenAI:

```dart
final routerRequest = OpenAIRequest(
  model: _model,
  messages: messages,
  stream: false,             // el router no necesita streaming
  temperature: 0.1,          // máxima precisión para routing
  maxTokens: 256,            // el JSON de routing es pequeño
  responseFormat: {
    'type': 'json_object',   // garantiza que la respuesta sea JSON válido
  },
);
```

El router espera esta estructura del LLM:

```json
{
  "intent": "query_stock_product",
  "score": 0.92,
  "workflow_id": "wf_query_stock",
  "intent_description": "consultar stock de producto",
  "entities": {
    "productQuery": "coca cola 500",
    "warehouseQuery": null
  },
  "reasoning": "El usuario pregunta por la cantidad disponible de un producto específico"
}
```

---

## Gestión de costos ($10/mes)

Con gpt-4o-mini y los parámetros configurados:

| Tipo de llamada | Tokens aprox. | Costo aprox. |
|---|---|---|
| Router semántico (non-stream) | ~800 input + ~150 output | $0.00021 |
| Respuesta streaming (simple) | ~1200 input + ~200 output | $0.00030 |
| Respuesta streaming (con contexto) | ~2000 input + ~400 output | $0.00054 |
| ReAct iteración | ~1500 input + ~100 output | $0.00029 |

**Estimado real con 1-2 usuarios y uso moderado (50 turnos/día):**
- 50 turnos × $0.0008 promedio = $0.04/día = **~$1.20/mes**
- Margen amplio dentro del presupuesto de $10

El límite de costo se gestiona con `ASSISTANT_HISTORY_TURNS=12` — más historial = más tokens = más costo.

---

## Criterio de cierre

- [ ] `OpenAIClient.streamChat()` emite tokens en tiempo real
- [ ] `OpenAIClient.chat()` devuelve `OpenAIResponse` con conteo de tokens
- [ ] Errores HTTP se lanzan como `OpenAIException` con status code
- [ ] Router usa `response_format: json_object` para structured outputs
- [ ] API key viene de `.env`, no hardcodeada
- [ ] `LLMClient` es una interfaz abstracta (facilita mocking en tests)
