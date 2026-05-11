import 'package:flutter/material.dart';
import '../models/assistant_ui_state.dart';
import '../models/chat_message.dart';
import 'assistant_voice_button.dart';
import 'voice_sphere.dart';

class VoiceModeOverlay extends StatelessWidget {
  final AssistantUiState state;
  final VoidCallback onExit;
  final VoidCallback onScanBarcode;

  const VoiceModeOverlay({
    super.key,
    required this.state,
    required this.onExit,
    required this.onScanBarcode,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final statusLabel = switch (state.voiceState) {
      VoiceButtonState.idle => 'Toca el micrófono para empezar',
      VoiceButtonState.recording => 'Escuchando...',
      VoiceButtonState.processing => 'Procesando...',
      VoiceButtonState.speaking => 'Respondiendo...',
    };

    return Column(
      children: [
        // Área principal: esfera + estado
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              VoiceSphere(voiceState: state.voiceState),
              const SizedBox(height: 32),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  statusLabel,
                  key: ValueKey(state.voiceState),
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Transcripción en tiempo real
              AnimatedOpacity(
                opacity: state.liveTranscript.isNotEmpty ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    state.liveTranscript,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.45),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Último mensaje del asistente
        if (_lastAssistantMessage(state).isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _lastAssistantMessage(state),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Botones inferiores
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Row(
            children: [
              // Botón escanear QR (solo visible con sesión activa)
              if (state.hasActiveSession) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onScanBarcode,
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    label: const Text('Escanear'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              // Botón salir modo voz
              Expanded(
                child: FilledButton.icon(
                  onPressed: onExit,
                  icon: const Icon(Icons.keyboard_rounded),
                  label: const Text('Volver al chat'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _lastAssistantMessage(AssistantUiState state) {
    final assistantMessages = state.messages
        .where((m) => m.type == ChatMessageType.assistant && m.content.isNotEmpty)
        .toList();
    if (assistantMessages.isEmpty) return '';
    return assistantMessages.last.content;
  }
}
