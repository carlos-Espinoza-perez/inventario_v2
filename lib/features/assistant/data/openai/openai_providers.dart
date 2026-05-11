import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logging/assistant_chat_logger.dart';
import 'openai_client.dart';

final assistantChatLoggerProvider = Provider<AssistantChatLogger>((ref) {
  return AssistantChatLogger();
});

final llmClientProvider = Provider<LLMClient>((ref) {
  return OpenAIClient(logger: ref.watch(assistantChatLoggerProvider));
});
