# Plan 07 - Streaming UI y AssistantProvider

---

## Objetivo

Implementar la capa de presentación del asistente: el `AssistantNotifier` (Riverpod) que orquesta todo el flujo, la UI de chat con burbujas de mensaje, y el efecto de cursor parpadeante mientras el LLM está generando la respuesta en streaming.

---

## Estado de UI

```
AssistantUiState
├── messages: List<ChatMessage>       ← historial visible en pantalla
├── isStreaming: bool                 ← true mientras llegan tokens
├── streamingBuffer: String           ← texto acumulado del stream actual
├── pendingQuestion: String?          ← pregunta del orchestrator al usuario
├── clarificationOptions: List<String>? ← opciones de ambigüedad
├── hasDraft: bool                    ← mostrar botón de borrador
├── draftData: Map<String, dynamic>?  ← datos del borrador
├── isLoading: bool                   ← spinner inicial (antes del stream)
└── error: String?                    ← error crítico
```

---

## Paso 1 — Modelos de UI

```dart
// lib/features/assistant/presentation/models/chat_message.dart

enum ChatMessageType { user, assistant, system }

class ChatMessage {
  final String id;
  final String content;
  final ChatMessageType type;
  final DateTime timestamp;
  final bool isStreaming; // true = este mensaje está siendo construido

  const ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isStreaming = false,
  });

  ChatMessage copyWith({String? content, bool? isStreaming}) => ChatMessage(
        id: id,
        content: content ?? this.content,
        type: type,
        timestamp: timestamp,
        isStreaming: isStreaming ?? this.isStreaming,
      );

  factory ChatMessage.user(String content) => ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        content: content,
        type: ChatMessageType.user,
        timestamp: DateTime.now(),
      );

  factory ChatMessage.assistant(String content, {bool isStreaming = false}) =>
      ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        content: content,
        type: ChatMessageType.assistant,
        timestamp: DateTime.now(),
        isStreaming: isStreaming,
      );

  factory ChatMessage.system(String content) => ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        content: content,
        type: ChatMessageType.system,
        timestamp: DateTime.now(),
      );
}
```

```dart
// lib/features/assistant/presentation/models/assistant_ui_state.dart

import 'chat_message.dart';

class AssistantUiState {
  final List<ChatMessage> messages;
  final bool isStreaming;
  final bool isLoading;
  final String? pendingQuestion;
  final List<String>? clarificationOptions;
  final bool hasDraft;
  final Map<String, dynamic>? draftData;
  final String? error;

  const AssistantUiState({
    this.messages = const [],
    this.isStreaming = false,
    this.isLoading = false,
    this.pendingQuestion,
    this.clarificationOptions,
    this.hasDraft = false,
    this.draftData,
    this.error,
  });

  AssistantUiState copyWith({
    List<ChatMessage>? messages,
    bool? isStreaming,
    bool? isLoading,
    Object? pendingQuestion = _sentinel,
    Object? clarificationOptions = _sentinel,
    bool? hasDraft,
    Object? draftData = _sentinel,
    Object? error = _sentinel,
  }) =>
      AssistantUiState(
        messages: messages ?? this.messages,
        isStreaming: isStreaming ?? this.isStreaming,
        isLoading: isLoading ?? this.isLoading,
        pendingQuestion: pendingQuestion == _sentinel
            ? this.pendingQuestion
            : pendingQuestion as String?,
        clarificationOptions: clarificationOptions == _sentinel
            ? this.clarificationOptions
            : clarificationOptions as List<String>?,
        hasDraft: hasDraft ?? this.hasDraft,
        draftData: draftData == _sentinel ? this.draftData : draftData as Map<String, dynamic>?,
        error: error == _sentinel ? this.error : error as String?,
      );

  static const _sentinel = Object();
}
```

---

## Paso 2 — TurnResult completo

`TurnResult` es el contrato entre el `StepwiseOrchestrator` y el `AssistantNotifier`.

```dart
// lib/features/assistant/presentation/providers/assistant_provider.dart
// (parte superior — definición de TurnResult)

class TurnResult {
  final String responseText;           // texto directo (sin streaming)
  final Stream<String>? responseStream; // stream de tokens (con streaming)
  final ConversationState updatedState;
  final bool requiresConfirmation;
  final Map<String, dynamic>? draft;
  final List<String>? clarificationOptions;

  const TurnResult({
    this.responseText = '',
    this.responseStream,
    required this.updatedState,
    this.requiresConfirmation = false,
    this.draft,
    this.clarificationOptions,
  });

  bool get isStreaming => responseStream != null;
}
```

---

## Paso 3 — AssistantNotifier

```dart
// lib/features/assistant/presentation/providers/assistant_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/turn_pipeline.dart';
import '../../data/context/assistant_context_builder.dart';
import '../../domain/models/conversation_state.dart';
import '../models/assistant_ui_state.dart';
import '../models/chat_message.dart';

part 'assistant_provider.g.dart';

@riverpod
class AssistantNotifier extends _$AssistantNotifier {
  StreamSubscription<String>? _streamSubscription;

  @override
  AssistantUiState build() => const AssistantUiState();

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (state.isStreaming || state.isLoading) return;

    // 1. Mostrar mensaje del usuario inmediatamente
    final userMsg = ChatMessage.user(text);
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      pendingQuestion: null,
      clarificationOptions: null,
      hasDraft: false,
      draftData: null,
      error: null,
    );

    try {
      // 2. Construir contexto operativo
      final context = await ref.read(assistantContextBuilderProvider).build(ref);
      final pipeline = ref.read(turnPipelineProvider);

      // 3. Ejecutar el pipeline
      final result = await pipeline.process(
        userMessage: text,
        conversationState: _currentConversationState,
        operationalContext: context,
      );

      // 4. Actualizar estado de conversación interno
      _currentConversationState = result.updatedState;

      // 5. Manejar el resultado
      if (result.requiresConfirmation && result.draft != null) {
        _handleDraftResult(result);
      } else if (result.clarificationOptions != null) {
        _handleClarificationResult(result);
      } else if (result.isStreaming) {
        await _handleStreamingResult(result);
      } else {
        _handleDirectResult(result);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isStreaming: false,
        error: 'Error inesperado. Intentá de nuevo.',
      );
    }
  }

  // ── Handlers de resultado ────────────────────────────────────────────────

  Future<void> _handleStreamingResult(TurnResult result) async {
    // Crear burbuja vacía con isStreaming=true
    final streamingMsg = ChatMessage.assistant('', isStreaming: true);
    state = state.copyWith(
      messages: [...state.messages, streamingMsg],
      isLoading: false,
      isStreaming: true,
    );

    final buffer = StringBuffer();

    _streamSubscription = result.responseStream!.listen(
      (token) {
        buffer.write(token);
        // Actualizar el último mensaje con el texto acumulado
        final updatedMessages = List<ChatMessage>.from(state.messages);
        updatedMessages[updatedMessages.length - 1] =
            streamingMsg.copyWith(content: buffer.toString(), isStreaming: true);
        state = state.copyWith(messages: updatedMessages);
      },
      onDone: () {
        // Finalizar: marcar isStreaming=false en el último mensaje
        final updatedMessages = List<ChatMessage>.from(state.messages);
        updatedMessages[updatedMessages.length - 1] =
            streamingMsg.copyWith(content: buffer.toString(), isStreaming: false);
        state = state.copyWith(
          messages: updatedMessages,
          isStreaming: false,
        );
      },
      onError: (_) {
        state = state.copyWith(
          isStreaming: false,
          error: 'Error en la respuesta del asistente.',
        );
      },
    );
  }

  void _handleDirectResult(TurnResult result) {
    if (result.responseText.isEmpty) return;
    final assistantMsg = ChatMessage.assistant(result.responseText);
    state = state.copyWith(
      messages: [...state.messages, assistantMsg],
      isLoading: false,
      pendingQuestion: result.responseText, // el texto es la pregunta al usuario
    );
  }

  void _handleClarificationResult(TurnResult result) {
    if (result.responseText.isEmpty) return;
    final assistantMsg = ChatMessage.assistant(result.responseText);
    state = state.copyWith(
      messages: [...state.messages, assistantMsg],
      isLoading: false,
      pendingQuestion: result.responseText,
      clarificationOptions: result.clarificationOptions,
    );
  }

  void _handleDraftResult(TurnResult result) {
    final assistantMsg = ChatMessage.assistant('Revisá el borrador antes de confirmar.');
    state = state.copyWith(
      messages: [...state.messages, assistantMsg],
      isLoading: false,
      hasDraft: true,
      draftData: result.draft,
    );
  }

  // ── Estado de conversación interno ───────────────────────────────────────

  ConversationState _currentConversationState = ConversationState.initial();

  void clearError() => state = state.copyWith(error: null);

  void resetConversation() {
    _streamSubscription?.cancel();
    _currentConversationState = ConversationState.initial();
    state = const AssistantUiState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
```

---

## Paso 4 — Pantalla principal del asistente

```dart
// lib/features/assistant/presentation/screens/assistant_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/assistant_provider.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/clarification_options_row.dart';
import '../widgets/draft_card.dart';

class AssistantScreen extends ConsumerWidget {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assistantNotifierProvider);
    final notifier = ref.read(assistantNotifierProvider.notifier);

    return Scaffold(
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.messages.length,
              itemBuilder: (_, i) => ChatMessageBubble(message: state.messages[i]),
            ),
          ),

          // Indicador de carga inicial
          if (state.isLoading && !state.isStreaming)
            const _ThinkingIndicator(),

          // Borrador pendiente
          if (state.hasDraft && state.draftData != null)
            DraftCard(
              draftData: state.draftData!,
              onConfirm: () => notifier.sendMessage('confirmar'),
              onCancel: () => notifier.sendMessage('cancelar'),
            ),

          // Opciones de clarificación
          if (state.clarificationOptions != null)
            ClarificationOptionsRow(
              options: state.clarificationOptions!,
              onSelected: (option) => notifier.sendMessage(option),
            ),

          // Error
          if (state.error != null)
            _ErrorBanner(
              message: state.error!,
              onDismiss: notifier.clearError,
            ),

          // Input
          ChatInputBar(
            enabled: !state.isStreaming && !state.isLoading,
            onSend: notifier.sendMessage,
          ),
        ],
      ),
    );
  }
}

class _ThinkingIndicator extends StatelessWidget {
  const _ThinkingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text('Secretario está pensando...', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(child: Text(message, style: Theme.of(context).textTheme.bodySmall)),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}
```

---

## Paso 5 — ChatMessageBubble con cursor parpadeante

```dart
// lib/features/assistant/presentation/widgets/chat_message_bubble.dart

import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import 'blinking_cursor.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.type == ChatMessageType.user;
    final theme = Theme.of(context);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.80,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: message.isStreaming
            ? _StreamingText(text: message.content)
            : Text(
                message.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isUser ? theme.colorScheme.onPrimary : null,
                ),
              ),
      ),
    );
  }
}

class _StreamingText extends StatelessWidget {
  final String text;

  const _StreamingText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
        const BlinkingCursor(),
      ],
    );
  }
}
```

```dart
// lib/features/assistant/presentation/widgets/blinking_cursor.dart

import 'package:flutter/material.dart';

class BlinkingCursor extends StatefulWidget {
  const BlinkingCursor({super.key});

  @override
  State<BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 530),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2,
        height: 16,
        margin: const EdgeInsets.only(left: 2, bottom: 1),
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
```

---

## Paso 6 — ChatInputBar

```dart
// lib/features/assistant/presentation/widgets/chat_input_bar.dart

import 'package:flutter/material.dart';

class ChatInputBar extends StatefulWidget {
  final bool enabled;
  final void Function(String) onSend;

  const ChatInputBar({
    super.key,
    required this.enabled,
    required this.onSend,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    widget.onSend(text);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: widget.enabled
                      ? 'Escribí tu consulta...'
                      : 'Secretario está respondiendo...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: widget.enabled ? _send : null,
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Paso 7 — ClarificationOptionsRow

```dart
// lib/features/assistant/presentation/widgets/clarification_options_row.dart

import 'package:flutter/material.dart';

class ClarificationOptionsRow extends StatelessWidget {
  final List<String> options;
  final void Function(String) onSelected;

  const ClarificationOptionsRow({
    super.key,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: options
            .map((opt) => ActionChip(
                  label: Text(opt),
                  onPressed: () => onSelected(opt),
                ))
            .toList(),
      ),
    );
  }
}
```

---

## Flujo completo del streaming

```
Usuario toca "Enviar"
        │
        ▼
AssistantNotifier.sendMessage()
  ├─ Agrega ChatMessage.user a la lista
  ├─ state.isLoading = true
  │
  ▼
TurnPipeline.process()   ← async, ~300ms antes del primer token
        │
        ▼
TurnResult.responseStream != null
        │
        ▼
_handleStreamingResult()
  ├─ Agrega ChatMessage.assistant(content:'', isStreaming:true)
  ├─ state.isStreaming = true
  │
  ▼
Stream<String>.listen()
  ├─ Cada token: buffer.write(token) → actualiza el último mensaje
  │                                  → UI reconstruye ChatMessageBubble
  │                                  → BlinkingCursor visible
  ▼
onDone:
  ├─ Marca último mensaje isStreaming=false
  ├─ BlinkingCursor desaparece
  └─ state.isStreaming = false → input habilitado otra vez
```

---

## Criterio de cierre

- [ ] `AssistantUiState` con todos los campos necesarios para UI reactiva
- [ ] `ChatMessage.isStreaming` controla visibilidad del cursor
- [ ] `BlinkingCursor` parpadea a 530ms con `AnimationController`
- [ ] Tokens llegan token a token y se acumulan en el último mensaje
- [ ] Al finalizar el stream el cursor desaparece y el input se habilita
- [ ] `ClarificationOptionsRow` muestra chips para opciones de desambiguación
- [ ] `DraftCard` aparece cuando `hasDraft == true`
- [ ] Input deshabilitado mientras `isStreaming || isLoading`
- [ ] Error se muestra como banner dismissible, no interrumpe el flujo
