import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/models/inventory_requests.dart';
import 'package:inventario_v2/features/inventory/data/providers/inventario_provider.dart';

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

    final repository = await _ref.read(inventarioRepositoryProvider.future);
    
    final request = InventoryEntryRequest(
      destinationWarehouseId: bodegaId,
      descripcion: descripcion.trim(),
      items: orderLines.map(_mapOrderLineToRequest).toList(),
    );

    await repository.registrarEntrada(request);
  }

  InventoryEntryItem _mapOrderLineToRequest(Map<String, dynamic> line) {
    final items = (line['items'] as List?) ?? const [];
    return InventoryEntryItem(
      productId: line['productId'] as String,
      cantidad: items.length.toDouble(),
      costoProveedor: (line['cost'] as num?)?.toDouble() ?? 0.0,
      costoUnitarioFinal: (line['cost'] as num?)?.toDouble() ?? 0.0,
      precioVenta: (line['price'] as num?)?.toDouble(),
      variantesJson: jsonEncode(
        items
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList(growable: false),
      ),
    );
  }
}
