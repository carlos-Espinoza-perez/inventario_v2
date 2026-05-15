import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/assistant_provider.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/draft_card.dart';
import '../widgets/clarification_options_row.dart';
import '../widgets/offline_banner.dart';
import '../widgets/paused_workflow_banner.dart';
import '../widgets/assistant_session_banner.dart';
import '../widgets/voice_mode_overlay.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleScanBarcode() async {
    final notifier = ref.read(assistantProvider.notifier);
    final barcode = await context.push<String>('/barcode-scanner');
    if (barcode != null && mounted) {
      await notifier.handleBarcode(barcode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assistantProvider);
    final notifier = ref.read(assistantProvider.notifier);

    ref.listen(assistantProvider, (prev, next) {
      if (!next.isVoiceMode) _scrollToBottom();
    });

    final inputBlocked =
        state.isLoading ||
        state.isStreaming ||
        state.isConfirming ||
        state.isRecording;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: state.isVoiceMode
          ? _VoiceModeView(
              key: const ValueKey('voice'),
              state: state,
              notifier: notifier,
              onScanBarcode: _handleScanBarcode,
            )
          : _ChatModeView(
              key: const ValueKey('chat'),
              state: state,
              notifier: notifier,
              scrollController: _scrollController,
              inputBlocked: inputBlocked,
              onScanBarcode: _handleScanBarcode,
            ),
    );
  }
}

// ── Vista modo chat ──────────────────────────────────────────────────────────

class _ChatModeView extends StatelessWidget {
  final dynamic state;
  final dynamic notifier;
  final ScrollController scrollController;
  final bool inputBlocked;
  final VoidCallback onScanBarcode;

  const _ChatModeView({
    super.key,
    required this.state,
    required this.notifier,
    required this.scrollController,
    required this.inputBlocked,
    required this.onScanBarcode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (state.hasActiveSession)
          AssistantSessionBanner(
            session: state.activeSession!,
            onCancel: notifier.cancelSession,
          ),

        Expanded(
          child: state.messages.isEmpty
              ? _EmptyState(onVoiceTap: notifier.toggleVoiceMode)
              : ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  itemCount: state.messages.length,
                  itemBuilder: (_, i) =>
                      ChatMessageBubble(message: state.messages[i]),
                ),
        ),

        if (state.isOffline) const OfflineBanner(),
        if (state.isLoading)
          const LinearProgressIndicator(
            minHeight: 2,
            backgroundColor: Colors.transparent,
          ),
        if (state.hasPausedWorkflows)
          PausedWorkflowBanner(workflowName: state.pausedWorkflowNames.last),
        if (state.hasClarificationOptions)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ClarificationOptionsRow(
              options: state.clarificationOptions,
              onSelected: (opt) => notifier.sendMessage(opt),
            ),
          ),
        if (state.hasPendingDraft)
          DraftCard(
            draft: state.pendingDraft!,
            isLoading: state.isConfirming,
            onConfirm: notifier.confirmDraft,
            onCancel: notifier.cancelDraft,
            onUpdateItem: notifier.updateDraftItem,
          ),

        ChatInputBar(
          enabled: !inputBlocked,
          onSend: notifier.sendMessage,
          voiceState: state.voiceState,
          onVoiceTap: notifier.startVoiceInput,
          onVoiceModeTap: notifier.toggleVoiceMode,
          sessionActive: state.hasActiveSession,
          onScanBarcode: state.hasActiveSession ? onScanBarcode : null,
        ),
      ],
    );
  }
}

// ── Vista modo voz ───────────────────────────────────────────────────────────

class _VoiceModeView extends StatelessWidget {
  final dynamic state;
  final dynamic notifier;
  final VoidCallback onScanBarcode;

  const _VoiceModeView({
    super.key,
    required this.state,
    required this.notifier,
    required this.onScanBarcode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (state.hasActiveSession)
          AssistantSessionBanner(
            session: state.activeSession!,
            onCancel: notifier.cancelSession,
          ),
        Expanded(
          child: VoiceModeOverlay(
            state: state,
            onExit: notifier.toggleVoiceMode,
            onScanBarcode: onScanBarcode,
          ),
        ),
      ],
    );
  }
}

// ── Estado vacío ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onVoiceTap;

  const _EmptyState({required this.onVoiceTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 48,
            color: colorScheme.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'Asistente IA',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Preguntá sobre stock, precios o ventas',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onVoiceTap,
            icon: const Icon(Icons.mic_rounded),
            label: const Text('Activar modo voz'),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
