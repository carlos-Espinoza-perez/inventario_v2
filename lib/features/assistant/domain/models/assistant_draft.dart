import 'package:flutter/foundation.dart';

enum DraftType { sale, inventoryEntry }

@immutable
class DraftItem {
  final String productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double? unitCost;
  final String? variantId;

  const DraftItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.unitCost,
    this.variantId,
  });

  double get subtotal => quantity * unitPrice;

  DraftItem copyWith({
    double? quantity,
    double? unitPrice,
    double? unitCost,
  }) =>
      DraftItem(
        productId: productId,
        productName: productName,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        unitCost: unitCost ?? this.unitCost,
        variantId: variantId,
      );

  Map<String, dynamic> toSaleCartItem() => {
        'id': productId,
        'qty': quantity,
        'price': unitPrice,
        if (variantId != null) 'variantId': variantId,
      };

  Map<String, dynamic> toEntryOrderLine() => {
        'productId': productId,
        'cost': unitCost ?? unitPrice,
        'price': unitPrice,
        'items': List.generate(
          quantity.toInt(),
          (_) => <String, dynamic>{},
        ),
      };
}

@immutable
class AssistantDraft {
  final DraftType type;
  final List<DraftItem> items;
  final String? clientName;
  final String? saleType;
  final String? description;

  const AssistantDraft({
    required this.type,
    required this.items,
    this.clientName,
    this.saleType,
    this.description,
  });

  double get total => items.fold(0, (sum, i) => sum + i.subtotal);

  bool get isEmpty => items.isEmpty;

  AssistantDraft copyWith({
    List<DraftItem>? items,
    String? clientName,
    String? saleType,
    String? description,
  }) =>
      AssistantDraft(
        type: type,
        items: items ?? this.items,
        clientName: clientName ?? this.clientName,
        saleType: saleType ?? this.saleType,
        description: description ?? this.description,
      );

  factory AssistantDraft.fromMap(Map<String, dynamic> data) {
    final typeStr = data['draft_type'] as String? ?? 'sale';
    final type = typeStr == 'inventory_entry' ? DraftType.inventoryEntry : DraftType.sale;

    final rawItems = data['items'] as List? ?? const [];
    final items = rawItems
        .map((e) => _itemFromMap(e as Map<String, dynamic>, type))
        .toList();

    return AssistantDraft(
      type: type,
      items: items,
      clientName: data['client_name'] as String?,
      saleType: data['sale_type'] as String?,
      description: data['description'] as String?,
    );
  }

  static DraftItem _itemFromMap(Map<String, dynamic> m, DraftType type) {
    return DraftItem(
      productId: m['product_id'] as String? ?? '',
      productName: m['product_name'] as String? ?? 'Producto',
      quantity: (m['quantity'] as num?)?.toDouble() ?? 1.0,
      unitPrice: (m['unit_price'] as num?)?.toDouble() ?? 0.0,
      unitCost: (m['unit_cost'] as num?)?.toDouble(),
      variantId: m['variant_id'] as String?,
    );
  }
}
