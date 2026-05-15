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
  final double? depositAmount;
  final String? bodegaId;
  final String? cajaSesionId;

  const AssistantDraft({
    required this.type,
    required this.items,
    this.clientName,
    this.saleType,
    this.description,
    this.depositAmount,
    this.bodegaId,
    this.cajaSesionId,
  });

  double get total => items.fold(0, (sum, i) => sum + i.subtotal);

  bool get isEmpty => items.isEmpty;

  AssistantDraft copyWith({
    List<DraftItem>? items,
    String? clientName,
    String? saleType,
    String? description,
    double? depositAmount,
    String? bodegaId,
    String? cajaSesionId,
  }) =>
      AssistantDraft(
        type: type,
        items: items ?? this.items,
        clientName: clientName ?? this.clientName,
        saleType: saleType ?? this.saleType,
        description: description ?? this.description,
        depositAmount: depositAmount ?? this.depositAmount,
        bodegaId: bodegaId ?? this.bodegaId,
        cajaSesionId: cajaSesionId ?? this.cajaSesionId,
      );

  factory AssistantDraft.fromMap(Map<String, dynamic> data) {
    final typeStr = _readString(data, [
      'draft_type',
      '__draft_type',
      'draftType',
      'type',
    ]);
    final type = typeStr == 'inventory_entry' ||
            typeStr == 'entry' ||
            typeStr == 'inventoryEntry'
        ? DraftType.inventoryEntry
        : DraftType.sale;

    final rawItems = data['items'] as List? ?? const [];
    final items = rawItems
        .map((e) => _itemFromMap(e as Map<String, dynamic>, type))
        .toList();

    final depositAmount = _readDouble(data, [
      'deposit_amount',
      'depositAmount',
      'abono',
      'montoAbonado',
      'paidAmount',
    ]);

    return AssistantDraft(
      type: type,
      items: items,
      clientName: _readString(data, [
        'client_name',
        'clientName',
        'clientQuery',
        'nombreCliente',
      ]),
      saleType: _readString(data, ['sale_type', 'saleType', 'tipoVenta']) ??
          _inferSaleType(depositAmount, items),
      description: _readString(data, ['description', 'descripcion']),
      depositAmount: depositAmount,
      bodegaId: _readString(data, ['bodegaId', 'bodega_id', 'warehouseId']),
      cajaSesionId: _readString(data, [
        'cajaSesionId',
        'caja_sesion_id',
        'openCashSessionId',
      ]),
    );
  }

  static DraftItem _itemFromMap(Map<String, dynamic> m, DraftType type) {
    return DraftItem(
      productId: _readString(m, ['product_id', 'productoId', 'productId']) ?? '',
      productName:
          _readString(m, ['product_name', 'productoNombre', 'productName']) ??
              'Producto',
      quantity: _readDouble(m, ['quantity', 'cantidad', 'qty']) ?? 1.0,
      unitPrice: _readDouble(m, ['unit_price', 'precio', 'price']) ?? 0.0,
      unitCost: _readDouble(m, ['unit_cost', 'costo', 'cost']),
      variantId: _readString(m, ['variant_id', 'varianteId', 'variantId']),
    );
  }

  static String? _readString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  static double? _readDouble(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value.replaceAll(',', '.'));
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static String? _inferSaleType(double? depositAmount, List<DraftItem> items) {
    if (depositAmount == null) return null;
    final total = items.fold(0.0, (sum, item) => sum + item.subtotal);
    if (depositAmount < total) return 'Fiado';
    return 'Contado';
  }
}
