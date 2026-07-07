import 'dart:convert';

/// Mensaje del protocolo de chat de OpenAI, con soporte de tool calling.
class SecMessage {
  final String role; // 'system' | 'user' | 'assistant' | 'tool'
  final String? content;
  final List<SecToolCall>? toolCalls;
  final String? toolCallId;

  const SecMessage({
    required this.role,
    this.content,
    this.toolCalls,
    this.toolCallId,
  });

  factory SecMessage.system(String content) =>
      SecMessage(role: 'system', content: content);
  factory SecMessage.user(String content) =>
      SecMessage(role: 'user', content: content);
  factory SecMessage.assistant(String content) =>
      SecMessage(role: 'assistant', content: content);
  factory SecMessage.assistantToolCalls(List<SecToolCall> calls) =>
      SecMessage(role: 'assistant', toolCalls: calls);
  factory SecMessage.toolResult({
    required String toolCallId,
    required Map<String, dynamic> result,
  }) =>
      SecMessage(
        role: 'tool',
        toolCallId: toolCallId,
        content: jsonEncode(result),
      );

  Map<String, dynamic> toJson() => {
        'role': role,
        if (content != null || toolCalls == null) 'content': content,
        if (toolCalls != null)
          'tool_calls': toolCalls!.map((c) => c.toJson()).toList(),
        if (toolCallId != null) 'tool_call_id': toolCallId,
      };
}

/// Llamada a herramienta emitida por el modelo.
class SecToolCall {
  final String id;

  /// Nombre en formato API de OpenAI (sin puntos, ej. inventory__getStock).
  final String apiName;
  final String argumentsJson;

  const SecToolCall({
    required this.id,
    required this.apiName,
    required this.argumentsJson,
  });

  /// Id interno del registry (con puntos): inventory.getStockPorBodega.
  String get toolId => apiName.replaceAll('__', '.');

  Map<String, dynamic> get arguments {
    if (argumentsJson.trim().isEmpty) return {};
    try {
      final decoded = jsonDecode(argumentsJson);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (_) {
      return {};
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': 'function',
        'function': {'name': apiName, 'arguments': argumentsJson},
      };
}

/// Definición de una herramienta expuesta al modelo.
class SecToolDef {
  /// Id interno con puntos (inventory.getStockPorBodega).
  final String toolId;
  final String description;
  final Map<String, dynamic> parameters;

  const SecToolDef({
    required this.toolId,
    required this.description,
    required this.parameters,
  });

  /// OpenAI no admite puntos en nombres de función.
  String get apiName => toolId.replaceAll('.', '__');

  Map<String, dynamic> toJson() => {
        'type': 'function',
        'function': {
          'name': apiName,
          'description': description,
          'parameters': parameters,
        },
      };
}

class SecLlmRequest {
  final String model;
  final List<SecMessage> messages;
  final List<SecToolDef> tools;
  final double temperature;
  final int maxTokens;

  const SecLlmRequest({
    required this.model,
    required this.messages,
    this.tools = const [],
    this.temperature = 0.2,
    this.maxTokens = 1024,
  });

  Map<String, dynamic> toJson() => {
        'model': model,
        'messages': messages.map((m) => m.toJson()).toList(),
        if (tools.isNotEmpty) 'tools': tools.map((t) => t.toJson()).toList(),
        'temperature': temperature,
        'max_tokens': maxTokens,
        'stream': true,
        'stream_options': {'include_usage': true},
      };
}

/// Eventos emitidos durante el streaming de una respuesta.
sealed class SecLlmEvent {
  const SecLlmEvent();
}

/// Fragmento de texto de la respuesta final.
class SecLlmDelta extends SecLlmEvent {
  final String content;
  const SecLlmDelta(this.content);
}

/// Fin de la respuesta del modelo para esta llamada.
class SecLlmCompleted extends SecLlmEvent {
  final String content;
  final List<SecToolCall> toolCalls;
  final String? finishReason; // 'stop' | 'tool_calls' | ...
  final int? promptTokens;
  final int? completionTokens;

  const SecLlmCompleted({
    required this.content,
    required this.toolCalls,
    this.finishReason,
    this.promptTokens,
    this.completionTokens,
  });

  bool get wantsTools => toolCalls.isNotEmpty;
}
