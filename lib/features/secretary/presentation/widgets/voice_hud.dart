import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../voice/voice_session_controller.dart';
import '../providers/secretary_chat_provider.dart';

/// Overlay del modo voz: círculo central animado por fase, transcripción
/// parcial en vivo y controles (manos libres, cerrar). Tap en el círculo:
/// escucha → cerrar frase ya; hablando → barge-in; pausa → retomar.
class VoiceHud extends ConsumerWidget {
  const VoiceHud({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voice = ref.watch(voiceSessionProvider);
    final chat = ref.watch(secretaryChatProvider);
    final scheme = Theme.of(context).colorScheme;

    final (icon, label, color) = switch (voice.phase) {
      VoicePhase.listening => (
          Icons.mic,
          'Escuchando… tocá el círculo para enviar ya',
          scheme.primary,
        ),
      VoicePhase.thinking => (
          Icons.more_horiz,
          chat.runningTool != null ? 'Consultando datos…' : 'Pensando…',
          scheme.tertiary,
        ),
      VoicePhase.speaking => (
          Icons.volume_up,
          'Hablando (tocá para interrumpir)',
          scheme.secondary,
        ),
      VoicePhase.idle => (
          Icons.mic_off,
          'En pausa. Tocá el micrófono para hablar.',
          scheme.outline,
        ),
    };

    final displayText = switch (voice.phase) {
      VoicePhase.listening =>
        voice.partialText.isEmpty ? '…' : voice.partialText,
      VoicePhase.thinking => voice.partialText,
      _ => '',
    };

    return Material(
      color: scheme.surface.withValues(alpha: 0.96),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Cerrar modo voz',
                  icon: const Icon(Icons.keyboard_arrow_down),
                  onPressed: () =>
                      ref.read(voiceSessionProvider.notifier).stop(),
                ),
                const Spacer(),
                IconButton(
                  tooltip: voice.handsFree
                      ? 'Manos libres: activado'
                      : 'Manos libres: desactivado',
                  icon: Icon(
                    voice.handsFree ? Icons.all_inclusive : Icons.touch_app,
                    color: voice.handsFree ? scheme.primary : scheme.outline,
                  ),
                  onPressed: () =>
                      ref.read(voiceSessionProvider.notifier).toggleHandsFree(),
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => ref.read(voiceSessionProvider.notifier).tapMic(),
              child: _PulsingCircle(
                color: color,
                level: voice.phase == VoicePhase.listening
                    ? voice.soundLevel
                    : 0,
                animate: voice.phase == VoicePhase.listening ||
                    voice.phase == VoicePhase.speaking,
                child: voice.phase == VoicePhase.thinking
                    ? SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: color,
                        ),
                      )
                    : Icon(icon, size: 44, color: color),
              ),
            ),
            const SizedBox(height: 20),
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                voice.error ?? displayText,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: voice.error != null
                          ? scheme.error
                          : scheme.onSurfaceVariant,
                    ),
              ),
            ),
            const Spacer(),
            if (chat.streamingText.isNotEmpty &&
                voice.phase == VoicePhase.thinking)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Text(
                  chat.streamingText,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PulsingCircle extends StatefulWidget {
  final Color color;
  final double level;
  final bool animate;
  final Widget child;

  const _PulsingCircle({
    required this.color,
    required this.level,
    required this.animate,
    required this.child,
  });

  @override
  State<_PulsingCircle> createState() => _PulsingCircleState();
}

class _PulsingCircleState extends State<_PulsingCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = widget.animate ? _controller.value * 0.15 : 0.0;
        final levelBoost = widget.level * 0.25;
        final scale = 1.0 + pulse + levelBoost;
        return Container(
          width: 132,
          height: 132,
          alignment: Alignment.center,
          child: Container(
            width: 108 * scale,
            height: 108 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withValues(alpha: 0.12),
              border: Border.all(
                color: widget.color.withValues(alpha: 0.6),
                width: 2,
              ),
            ),
            child: Center(child: child),
          ),
        );
      },
      child: widget.child,
    );
  }
}
