import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/constants/app_constants.dart';
import '../data/openai/openai_client.dart';
import '../data/openai/openai_models.dart';
import '../data/openai/openai_providers.dart';
import '../domain/models/conversation_state.dart';

class ReasoningEngine {
  final LLMClient _llm;

  static const _referenceWords = [
    'ese', 'esa', 'esos', 'esas', 'el mismo', 'la misma',
    'el primero', 'el segundo', 'el tercero', 'el último',
    'ese producto', 'ese cliente', 'esa bodega',
    'anterior', 'el de antes', 'el mencionado',
  ];

  ReasoningEngine({required LLMClient llm}) : _llm = llm;

  Future<String> clarifyIfNeeded(
    String message,
    ConversationState state,
  ) async {
    if (!_isAmbiguous(message)) return message;
    if (state.messageHistory.isEmpty && state.lastShownList.isEmpty) {
      return message;
    }

    final context = _buildContext(state);
    if (context.isEmpty) return message;

    final systemPrompt = '''
Eres un asistente que reescribe mensajes ambiguos de forma explícita.

CONTEXTO DE LA CONVERSACIÓN:
$context

MENSAJE ORIGINAL DEL USUARIO:
"$message"

Si el mensaje hace referencia a algo del contexto (con palabras como "ese", "el mismo", "el primero", etc.),
reescríbelo de forma explícita reemplazando las referencias con los valores concretos.
Si no hay referencia ambigua, devuelve el mensaje original sin cambios.
Devuelve SOLO el mensaje reescrito, sin explicación ni comillas.
''';

    try {
      final response = await _llm.chat(OpenAIRequest(
        model: AppConstants.openAiModel,
        messages: [
          OpenAIMessage.system(systemPrompt),
          OpenAIMessage.user(message),
        ],
        stream: false,
        temperature: 0.0,
        maxTokens: 128,
      ));
      return response.content.trim();
    } catch (_) {
      return message;
    }
  }

  bool _isAmbiguous(String message) {
    final lower = message.toLowerCase().trim();
    if (message.trim().split(' ').length <= 3) return true;
    return _referenceWords.any((word) => lower.contains(word));
  }

  String _buildContext(ConversationState state) {
    final parts = <String>[];

    if (state.messageHistory.isNotEmpty) {
      final recent = state.messageHistory.reversed.take(4).toList().reversed;
      parts.add(
        'Conversación reciente:\n${recent.map((t) => '${t.role}: ${t.content}').join('\n')}',
      );
    }

    if (state.lastShownList.isNotEmpty) {
      final lista = state.lastShownList
          .asMap()
          .entries
          .map((e) => '${e.key + 1}. ${e.value.displayName}')
          .join('\n');
      parts.add('Última lista mostrada:\n$lista');
    }

    final vars = state.collectedData.entries
        .where((e) => e.value.relevance > 0.5)
        .map((e) => '${e.key}: ${e.value.value}')
        .join(', ');
    if (vars.isNotEmpty) parts.add('Datos conocidos: $vars');

    return parts.join('\n\n');
  }
}

final reasoningEngineProvider = Provider<ReasoningEngine>((ref) {
  return ReasoningEngine(llm: ref.watch(llmClientProvider));
});
