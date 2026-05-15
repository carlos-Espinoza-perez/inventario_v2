import 'package:flutter/material.dart';
import 'package:inventario_v2/features/assistant/domain/models/assistant_draft.dart';

class DraftCard extends StatelessWidget {
  final AssistantDraft draft;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final void Function(int index, {double? quantity, double? unitPrice})
  onUpdateItem;
  final bool isLoading;

  const DraftCard({
    super.key,
    required this.draft,
    required this.onConfirm,
    required this.onCancel,
    required this.onUpdateItem,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? colorScheme.surfaceContainerHigh
        : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(draft: draft, colorScheme: colorScheme),
          const Divider(height: 1),
          _ItemList(items: draft.items, onUpdateItem: onUpdateItem),
          const Divider(height: 1),
          _Footer(
            draft: draft,
            colorScheme: colorScheme,
            onConfirm: onConfirm,
            onCancel: onCancel,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AssistantDraft draft;
  final ColorScheme colorScheme;

  const _Header({required this.draft, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final label = draft.type == DraftType.sale
        ? 'Borrador de venta'
        : 'Borrador de entrada';
    final icon = draft.type == DraftType.sale
        ? Icons.shopping_cart_outlined
        : Icons.inventory_2_outlined;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: colorScheme.primary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${draft.items.length} ítem${draft.items.length != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemList extends StatelessWidget {
  final List<DraftItem> items;
  final void Function(int index, {double? quantity, double? unitPrice})
  onUpdateItem;

  const _ItemList({required this.items, required this.onUpdateItem});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, indent: 14),
      itemBuilder: (context, i) => _ItemRow(
        item: items[i],
        onEdit: () => _showEditItemDialog(
          context,
          item: items[i],
          onSave: ({quantity, unitPrice}) =>
              onUpdateItem(i, quantity: quantity, unitPrice: unitPrice),
        ),
      ),
    );
  }

  Future<void> _showEditItemDialog(
    BuildContext context, {
    required DraftItem item,
    required void Function({double? quantity, double? unitPrice}) onSave,
  }) async {
    final quantityController = TextEditingController(
      text: _formatNumber(item.quantity),
    );
    final priceController = TextEditingController(
      text: _formatNumber(item.unitPrice),
    );

    final result = await showDialog<({double quantity, double unitPrice})>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item.productName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  prefixIcon: Icon(Icons.numbers_rounded),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Precio unitario',
                  prefixIcon: Icon(Icons.sell_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final quantity = _parseNumber(quantityController.text);
                final price = _parseNumber(priceController.text);
                if (quantity == null || quantity <= 0 || price == null) {
                  return;
                }
                Navigator.of(
                  context,
                ).pop((quantity: quantity, unitPrice: price));
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    quantityController.dispose();
    priceController.dispose();

    if (result != null) {
      onSave(quantity: result.quantity, unitPrice: result.unitPrice);
    }
  }

  String _formatNumber(double value) =>
      value == value.truncateToDouble() ? value.toInt().toString() : '$value';

  double? _parseNumber(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }
}

class _ItemRow extends StatelessWidget {
  final DraftItem item;
  final VoidCallback onEdit;

  const _ItemRow({required this.item, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'x${_formatQty(item.quantity)}  ·  \$${_formatPrice(item.unitPrice)} c/u',
                  style: textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${_formatPrice(item.subtotal)}',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Editar',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }

  String _formatQty(double qty) =>
      qty == qty.truncateToDouble() ? qty.toInt().toString() : qty.toString();

  String _formatPrice(double price) => price.toStringAsFixed(2);
}

class _Footer extends StatelessWidget {
  final AssistantDraft draft;
  final ColorScheme colorScheme;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isLoading;

  const _Footer({
    required this.draft,
    required this.colorScheme,
    required this.onConfirm,
    required this.onCancel,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Column(
        children: [
          if (draft.type == DraftType.sale) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${draft.total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            if (draft.depositAmount != null &&
                draft.depositAmount! < draft.total)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Abono', style: Theme.of(context).textTheme.bodySmall),
                    Text(
                      '\$${draft.depositAmount!.toStringAsFixed(2)} · Saldo \$${(draft.total - draft.depositAmount!).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            if (draft.clientName != null && draft.clientName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      draft.clientName!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      draft.saleType ?? 'Contado',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(
                      color: colorScheme.error.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: isLoading ? null : onConfirm,
                  icon: isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 18),
                  label: Text(isLoading ? 'Registrando...' : 'Confirmar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
