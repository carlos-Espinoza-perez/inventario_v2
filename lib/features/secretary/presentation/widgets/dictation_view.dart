import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../voice/dictation_controller.dart';
import 'draft_table_card.dart';

/// Vista del modo dictado: la tabla temporal crece en vivo arriba mientras
/// abajo se ve el micrófono, la transcripción parcial y el último ack.
class DictationView extends ConsumerWidget {
  const DictationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dictation = ref.watch(dictationProvider);
    final scheme = Theme.of(context).colorScheme;

    final (micIcon, micColor, statusLabel) = switch (dictation.phase) {
      DictationPhase.listening => (
        Icons.mic,
        scheme.primary,
        'Escuchando… decí "listo" para terminar',
      ),
      DictationPhase.processing => (
        Icons.more_horiz,
        scheme.tertiary,
        'Procesando…',
      ),
      DictationPhase.paused => (
        Icons.mic_off,
        scheme.outline,
        'En pausa. Tocá el micrófono para seguir.',
      ),
    };

    // Sin AppBar propio: esta vista reemplaza el body dentro de la misma
    // ruta /secretary, así que el header compartido (MainLayout) ya está
    // arriba. El cierre se hace con un control propio (ícono "X"), no con
    // el back del header, porque cerrar acá descarta el borrador dictado.
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Cerrar (descarta el dictado)',
                    icon: const Icon(Icons.close),
                    onPressed: () => ref
                        .read(dictationProvider.notifier)
                        .stop(discardDraft: true),
                  ),
                  Expanded(
                    child: Text(
                      dictation.draftType == 'venta'
                          ? 'Dictando venta'
                          : 'Dictando entrada',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: dictation.draftId == null
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: DraftTableCard(draftId: dictation.draftId!),
                    ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                border: Border(top: BorderSide(color: scheme.outlineVariant)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (dictation.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          dictation.error!,
                          style: TextStyle(color: scheme.error),
                        ),
                      )
                    else if (dictation.phase == DictationPhase.listening &&
                        dictation.partialText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          dictation.partialText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      )
                    else if (dictation.lastAck.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          dictation.lastAck,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: scheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Text(
                          statusLabel,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        if (dictation.pendingFallbacks > 0) ...[
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.tertiary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${dictation.pendingFallbacks}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          onPressed: () => ref
                              .read(dictationProvider.notifier)
                              .stop(discardDraft: true),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Cancelar'),
                        ),
                        GestureDetector(
                          onTap: () =>
                              ref.read(dictationProvider.notifier).tapMic(),
                          child: CircleAvatar(
                            radius: 34,
                            backgroundColor: micColor.withValues(alpha: 0.15),
                            child: Icon(micIcon, size: 32, color: micColor),
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () =>
                              ref.read(dictationProvider.notifier).finish(),
                          icon: const Icon(Icons.check),
                          label: const Text('Listo'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
