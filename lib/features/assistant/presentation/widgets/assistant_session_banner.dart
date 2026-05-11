import 'package:flutter/material.dart';
import '../../domain/models/assistant_session.dart';

class AssistantSessionBanner extends StatelessWidget {
  final AssistantSession session;
  final VoidCallback onCancel;

  const AssistantSessionBanner({
    super.key,
    required this.session,
    required this.onCancel,
  });

  String get _modeLabel => switch (session.type) {
        AssistantSessionType.registerEntry => 'Entrada de inventario',
        AssistantSessionType.registerSale => 'Venta',
        AssistantSessionType.registerOutputAdjustment => 'Salida / Ajuste',
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final items = session.draft.items;

    return Container(
      color: colorScheme.primaryContainer,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.playlist_add_check_rounded,
                size: 18,
                color: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Modo: $_modeLabel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Cancelar'),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          if (session.state == AssistantSessionState.awaitingQuantity &&
              session.pendingProduct != null)
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 2),
              child: Text(
                '⏳ Esperando cantidad para: ${session.pendingProduct!.nombre}',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onPrimaryContainer,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...items.map(
              (i) => Text(
                '• ${i.productName} × ${i.quantity.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
