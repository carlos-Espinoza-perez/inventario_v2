import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/models/inventory_requests.dart';
import 'package:inventario_v2/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/inventario_provider.dart';
import 'package:inventario_v2/features/inventory/presentation/providers/warehouse_inventory_provider.dart'
    hide inventarioRepositoryProvider;

final registrarEntradaUseCaseProvider = Provider((ref) {
  return RegistrarEntradaUseCase(ref);
});

class RegistrarEntradaUseCase {
  final Ref _ref;

  RegistrarEntradaUseCase(this._ref);

  Future<void> ejecutar({
    required String bodegaId,
    required String descripcion,
    required List<Map<String, dynamic>> orderLines,
  }) async {
    if (descripcion.trim().isEmpty) {
      throw ArgumentError(
        'Por favor ingresa una descripción o referencia para este movimiento.',
      );
    }

    if (orderLines.isEmpty) {
      throw ArgumentError('La orden de entrada está vacía.');
    }

    final repository = _ref.read(inventarioRepositoryProvider);

    final request = InventoryEntryRequest(
      destinationWarehouseId: bodegaId,
      descripcion: descripcion.trim(),
      items: await _mapOrderLinesToRequestItems(orderLines),
    );

    try {
      await repository.registrarEntrada(request);
    } catch (e, st) {
      Error.throwWithStackTrace(
        Exception('Error al registrar entrada de inventario: $e'),
        st,
      );
    }

    _ref.invalidate(warehouseInventoryProvider(bodegaId));
    _ref.invalidate(dashboardProvider);
  }

  Future<List<InventoryEntryItem>> _mapOrderLinesToRequestItems(
    List<Map<String, dynamic>> orderLines,
  ) async {
    final repository = _ref.read(inventarioRepositoryProvider);
    final requestItems = <InventoryEntryItem>[];

    for (final line in orderLines) {
      final productId = line['productId'] as String;
      final cost = (line['cost'] as num?)?.toDouble() ?? 0.0;
      final basePrice = (line['price'] as num?)?.toDouble();
      final items = (line['items'] as List?) ?? const [];
      final grouped = <String, List<Map<String, dynamic>>>{};

      for (final rawItem in items) {
        final item = Map<String, dynamic>.from(rawItem as Map);
        final sku = item['qr']?.toString().trim();
        final size = item['size']?.toString().trim();
        final price = _readDouble(item['price']) ?? basePrice ?? 0.0;
        final key = '${sku ?? ''}|${size ?? ''}|$price';
        grouped.putIfAbsent(key, () => []).add(item);
      }

      for (final group in grouped.values) {
        final first = group.first;
        final sku = first['qr']?.toString().trim();
        final size = first['size']?.toString().trim();
        final price = _readDouble(first['price']) ?? basePrice ?? 0.0;
        final variant = await repository.resolveVariantForEntry(
          productId: productId,
          sku: sku,
          talla: size,
          color: first['color']?.toString(),
          precioVenta: price,
          costo: cost,
        );

        requestItems.add(
          InventoryEntryItem(
            productId: productId,
            productVariantId: variant.id,
            cantidad: group.length.toDouble(),
            costoProveedor: cost,
            costoUnitarioFinal: cost,
            precioVenta: price,
            sku: variant.sku,
            talla: variant.talla,
            color: variant.color,
            variantesJson: jsonEncode([
              {
                'sku': variant.sku,
                'talla': variant.talla,
                'color': variant.color,
                'cantidad': group.length.toDouble(),
                'precio': price,
              },
            ]),
          ),
        );
      }
    }

    return requestItems;
  }

  double? _readDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
