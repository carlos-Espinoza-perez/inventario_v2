import 'package:flutter/material.dart';

enum VoiceButtonState { idle, recording, processing, speaking }

class AssistantVoiceButton extends StatelessWidget {
  final VoiceButtonState state;
  final VoidCallback onTap;

  const AssistantVoiceButton({
    super.key,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final color = switch (state) {
      VoiceButtonState.idle => colorScheme.primary,
      VoiceButtonState.recording => Colors.red,
      VoiceButtonState.processing => Colors.orange,
      VoiceButtonState.speaking => colorScheme.primary,
    };

    final icon = switch (state) {
      VoiceButtonState.idle => Icons.mic_none_rounded,
      VoiceButtonState.recording => Icons.mic_rounded,
      VoiceButtonState.processing => Icons.hourglass_top_rounded,
      VoiceButtonState.speaking => Icons.volume_up_rounded,
    };

    final tooltip = switch (state) {
      VoiceButtonState.idle => 'Hablar',
      VoiceButtonState.recording => 'Grabando...',
      VoiceButtonState.processing => 'Procesando...',
      VoiceButtonState.speaking => 'Respondiendo...',
    };

    final bgColor = switch (state) {
      VoiceButtonState.recording => Colors.red.withValues(alpha: 0.12),
      VoiceButtonState.speaking => colorScheme.primary.withValues(alpha: 0.12),
      _ => Colors.transparent,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
      ),
      child: IconButton(
        onPressed: (state == VoiceButtonState.processing ||
                state == VoiceButtonState.speaking)
            ? null
            : onTap,
        icon: Icon(icon, color: color),
        tooltip: tooltip,
      ),
    );
  }
}
