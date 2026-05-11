class OpenAIMessage {
  final String role;
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
  final Map<String, dynamic>? responseFormat;

  const OpenAIRequest({
    required this.model,
    required this.messages,
    this.temperature = 0.2,
    this.maxTokens = 1024,
    this.stream = true,
    this.responseFormat,
  });

  OpenAIRequest copyWith({bool? stream}) => OpenAIRequest(
        model: model,
        messages: messages,
        temperature: temperature,
        maxTokens: maxTokens,
        stream: stream ?? this.stream,
        responseFormat: responseFormat,
      );

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
  final String? content;
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

  /// Input: $0.150/1M tokens, Output: $0.600/1M tokens (gpt-4o-mini)
  double get estimatedCostUsd =>
      (promptTokens * 0.150 / 1000000) + (completionTokens * 0.600 / 1000000);
}
