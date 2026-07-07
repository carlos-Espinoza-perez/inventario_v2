import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/presentation/mixins/app_bar_config_mixin.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';

import '../../voice/dictation_controller.dart';
import '../../voice/secretary_tts.dart';
import '../../voice/voice_session_controller.dart';
import '../providers/secretary_chat_provider.dart';
import '../widgets/dictation_view.dart';
import '../widgets/draft_table_card.dart';
import '../widgets/voice_hud.dart';

class SecretaryChatScreen extends ConsumerStatefulWidget {
  const SecretaryChatScreen({super.key});

  @override
  ConsumerState<SecretaryChatScreen> createState() =>
      _SecretaryChatScreenState();
}

class _SecretaryChatScreenState extends ConsumerState<SecretaryChatScreen>
    with AppBarConfigMixin {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final _tts = SecretaryTts();

  @override
  void configureAppBar() {
    ref
        .read(appBarProvider.notifier)
        .setOptions(
          title: 'Secretario IA',
          showBackButton: true,
          actions: [
            IconButton(
              tooltip: 'Preferencias',
              icon: const Icon(Icons.tune),
              onPressed: () => context.push('/secretary/prefs'),
            ),
            IconButton(
              tooltip: 'Historial',
              icon: const Icon(Icons.history),
              onPressed: () => context.push('/secretary/history'),
            ),
            IconButton(
              tooltip: 'Nueva conversación',
              icon: const Icon(Icons.add_comment_outlined),
              onPressed: () =>
                  ref.read(secretaryChatProvider.notifier).startNewSession(),
            ),
          ],
        );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(configureAppBar);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _tts.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _inputController.text;
    if (text.trim().isEmpty) return;
    _inputController.clear();
    final reply = await ref
        .read(secretaryChatProvider.notifier)
        .sendMessage(text);

    // Preferencia "leer respuestas": lee la respuesta también en texto.
    if (reply == null || !mounted) return;
    try {
      final prefs = await ref
          .read(chatRepositoryProvider)
          .getOrCreatePreferences();
      if (prefs.autoReadResponses) {
        await _tts.setRate(prefs.ttsRate);
        await _tts.speak(reply);
      }
    } catch (_) {
      // Sin sesión activa: no hay prefs que aplicar.
    }
  }

  void _pickDictationType(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.move_to_inbox),
              title: const Text('Dictar entrada de productos'),
              subtitle: const Text('Ej.: "12 pantalones a 10 dólares"'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                ref.read(dictationProvider.notifier).start('entrada');
              },
            ),
            ListTile(
              leading: const Icon(Icons.point_of_sale),
              title: const Text('Dictar venta'),
              subtitle: const Text('Requiere caja abierta para confirmar'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                ref.read(dictationProvider.notifier).start('venta');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(secretaryChatProvider);
    final voiceActive = ref.watch(voiceSessionProvider.select((v) => v.active));
    final dictationActive = ref.watch(
      dictationProvider.select((d) => d.active),
    );
    final sessionId = chatState.sessionId;
    final messagesAsync = sessionId != null
        ? ref.watch(secretaryMessagesProvider(sessionId))
        : const AsyncValue<List<ChatMessage>>.data([]);

    if (dictationActive) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            ref.read(dictationProvider.notifier).stop(discardDraft: true);
          }
        },
        child: const DictationView(),
      );
    }

    if (voiceActive) {
      // Modo voz: el HUD reemplaza la vista; PopScope cierra la sesión de
      // voz con el gesto de volver en lugar de salir de la pantalla.
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) ref.read(voiceSessionProvider.notifier).stop();
        },
        child: const Scaffold(body: VoiceHud()),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (messages) {
                _scrollToBottom();
                final showStreaming = chatState.streamingText.isNotEmpty;
                final showThinking = chatState.isSending && !showStreaming;
                final itemCount =
                    messages.length +
                    (showStreaming ? 1 : 0) +
                    (showThinking ? 1 : 0);

                if (itemCount == 0) {
                  return const _EmptyChatHint();
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    if (index < messages.length) {
                      final m = messages[index];
                      if (m.contentType == 'draft_card' && m.draftId != null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (m.content.trim().isNotEmpty)
                              _MessageBubble(content: m.content, isUser: false),
                            DraftTableCard(draftId: m.draftId!),
                          ],
                        );
                      }
                      return _MessageBubble(
                        content: m.content,
                        isUser: m.role == 'user',
                      );
                    }
                    if (showStreaming) {
                      return _MessageBubble(
                        content: chatState.streamingText,
                        isUser: false,
                      );
                    }
                    return _ThinkingIndicator(tool: chatState.runningTool);
                  },
                );
              },
            ),
          ),
          if (chatState.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                chatState.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Preguntá por stock, precios, ventas…',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Dictar entrada o venta',
                    onPressed: chatState.isSending
                        ? null
                        : () => _pickDictationType(context),
                    icon: const Icon(Icons.playlist_add),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Modo voz',
                    onPressed: chatState.isSending
                        ? null
                        : () => ref
                              .read(voiceSessionProvider.notifier)
                              .start(handsFree: true),
                    icon: const Icon(Icons.mic),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: chatState.isSending ? null : _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String content;
  final bool isUser;

  const _MessageBubble({required this.content, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isUser ? scheme.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: SelectableText(
          content,
          style: TextStyle(color: isUser ? scheme.onPrimary : scheme.onSurface),
        ),
      ),
    );
  }
}

class _ThinkingIndicator extends StatelessWidget {
  final String? tool;

  const _ThinkingIndicator({this.tool});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(
              tool != null ? 'Consultando datos…' : 'Pensando…',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChatHint extends StatelessWidget {
  const _EmptyChatHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.support_agent,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Hola, soy tu secretario.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              'Preguntame por stock, precios, ventas del día,\n'
              'deudas de clientes o el estado de la caja.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
