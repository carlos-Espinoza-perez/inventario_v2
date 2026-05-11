import 'package:flutter/material.dart';
import 'assistant_voice_button.dart';

class ChatInputBar extends StatefulWidget {
  final bool enabled;
  final void Function(String) onSend;
  final VoiceButtonState voiceState;
  final VoidCallback? onVoiceTap;
  final VoidCallback? onVoiceModeTap;
  final bool sessionActive;
  final VoidCallback? onScanBarcode;

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.enabled = true,
    this.voiceState = VoiceButtonState.idle,
    this.onVoiceTap,
    this.onVoiceModeTap,
    this.sessionActive = false,
    this.onScanBarcode,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Botón scanner — solo cuando hay sesión activa
          if (widget.sessionActive && widget.onScanBarcode != null)
            IconButton(
              onPressed: widget.onScanBarcode,
              icon: const Icon(Icons.qr_code_scanner_rounded),
              tooltip: 'Escanear producto',
              color: colorScheme.primary,
            ),

          // Campo de texto
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: widget.enabled,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submit(),
              maxLines: null,
              decoration: InputDecoration(
                hintText: widget.sessionActive
                    ? 'Cantidad, "listo" o "cancelar"...'
                    : widget.enabled
                        ? 'Escribí tu consulta...'
                        : 'Esperando respuesta...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Botón push-to-talk (micrófono)
          if (widget.onVoiceTap != null)
            AssistantVoiceButton(
              state: widget.voiceState,
              onTap: widget.onVoiceTap!,
            ),

          // Botón activar modo voz inmersivo
          if (widget.onVoiceModeTap != null)
            IconButton(
              onPressed: widget.onVoiceModeTap,
              icon: const Icon(Icons.spatial_audio_off_rounded),
              tooltip: 'Modo voz',
              color: colorScheme.primary,
            ),

          const SizedBox(width: 4),

          // Botón enviar
          IconButton.filled(
            onPressed: widget.enabled ? _submit : null,
            icon: const Icon(Icons.send_rounded),
            style: IconButton.styleFrom(
              backgroundColor: widget.enabled
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
