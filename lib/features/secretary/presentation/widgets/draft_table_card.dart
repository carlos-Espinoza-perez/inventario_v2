import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/app_database.dart';

import '../providers/draft_provider.dart';
import '../providers/secretary_chat_provider.dart';

/// Tabla temporal del borrador, embebida en el chat. Editable: corregir
/// cantidad/costo/precio, resolver candidatos y eliminar filas. La edición
/// manual y el dictado convergen en el mismo estado Drift.
class DraftTableCard extends ConsumerWidget {
  final String draftId;

  const DraftTableCard({super.key, required this.draftId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftAsync = ref.watch(draftProvider(draftId));
    final itemsAsync = ref.watch(draftItemsProvider(draftId));
    final draft = draftAsync.value;
    final items = itemsAsync.value ?? const <SecretaryDraftItem>[];
    if (draft == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final isActive = draft.status == 'active';
    final total = items.fold<double>(
      0,
      (sum, i) => sum + i.quantity * (i.unitPrice ?? i.unitCost ?? 0),
    );
    final pendientes =
        items.where((i) => i.status != 'ready' || i.productId == null).length;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                draft.draftType == 'venta'
                    ? Icons.point_of_sale
                    : Icons.move_to_inbox,
                size: 18,
                color: scheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                draft.draftType == 'venta'
                    ? 'Borrador de venta'
                    : 'Borrador de entrada',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              _StatusChip(status: draft.status),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Sin ítems todavía.'),
            )
          else
            ...items.map(
              (item) => _DraftItemRow(
                item: item,
                editable: isActive,
                isVenta: draft.draftType == 'venta',
              ),
            ),
          const Divider(height: 16),
          Row(
            children: [
              if (pendientes > 0)
                Text(
                  '$pendientes por revisar',
                  style: TextStyle(color: scheme.error, fontSize: 12),
                ),
              const Spacer(),
              Text(
                'Total: \$${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => ref
                      .read(secretaryChatProvider.notifier)
                      .discardDraft(draftId),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: items.isEmpty || pendientes > 0
                      ? null
                      : () => ref
                          .read(secretaryChatProvider.notifier)
                          .confirmDraft(draftId),
                  icon: const Icon(Icons.check),
                  label: const Text('Confirmar'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, color) = switch (status) {
      'executed' => ('Registrado', Colors.green),
      'discarded' => ('Descartado', scheme.outline),
      'active' => ('En edición', scheme.primary),
      _ => (status, scheme.outline),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color)),
    );
  }
}

class _DraftItemRow extends ConsumerWidget {
  final SecretaryDraftItem item;
  final bool editable;
  final bool isVenta;

  const _DraftItemRow({
    required this.item,
    required this.editable,
    required this.isVenta,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final needsReview = item.status != 'ready' || item.productId == null;
    final monto = isVenta ? item.unitPrice : (item.unitCost ?? item.unitPrice);

    return InkWell(
      onTap: editable ? () => _edit(context, ref) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              needsReview ? Icons.warning_amber_rounded : Icons.check_circle,
              size: 16,
              color: needsReview ? scheme.error : Colors.green,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                item.resolvedName ?? item.proposedName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${_qty(item.quantity)} × \$${(monto ?? 0).toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (editable)
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, size: 16),
                tooltip: 'Quitar',
                onPressed: () => ref
                    .read(draftEngineProvider)
                    .removeItem(item.id),
              ),
          ],
        ),
      ),
    );
  }

  String _qty(double q) =>
      q == q.roundToDouble() ? q.toInt().toString() : q.toString();

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    // Si hay candidatos, primero resolver la ambigüedad.
    if (item.productId == null && item.candidatesJson != null) {
      final candidatos = (jsonDecode(item.candidatesJson!) as List)
          .whereType<Map>()
          .toList();
      if (candidatos.isNotEmpty && context.mounted) {
        final elegido = await showDialog<Map>(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text('¿Cuál es "${item.proposedName}"?'),
            children: [
              for (final c in candidatos)
                SimpleDialogOption(
                  onPressed: () => Navigator.of(context).pop(c),
                  child: Text(c['nombre']?.toString() ?? ''),
                ),
            ],
          ),
        );
        if (elegido != null) {
          await ref.read(draftEngineProvider).updateItem(
                item.id,
                productoId: elegido['id']?.toString(),
                resolvedName: elegido['nombre']?.toString(),
              );
        }
        return;
      }
    }

    if (!context.mounted) return;
    final qtyCtrl = TextEditingController(text: _qty(item.quantity));
    final costCtrl =
        TextEditingController(text: item.unitCost?.toString() ?? '');
    final priceCtrl =
        TextEditingController(text: item.unitPrice?.toString() ?? '');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.resolvedName ?? item.proposedName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cantidad'),
            ),
            TextField(
              controller: costCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Costo unitario'),
            ),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Precio de venta'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(draftEngineProvider).updateItem(
            item.id,
            cantidad: double.tryParse(qtyCtrl.text.replaceAll(',', '.')),
            costoUnitario:
                double.tryParse(costCtrl.text.replaceAll(',', '.')),
            precioUnitario:
                double.tryParse(priceCtrl.text.replaceAll(',', '.')),
          );
    }
    qtyCtrl.dispose();
    costCtrl.dispose();
    priceCtrl.dispose();
  }
}
