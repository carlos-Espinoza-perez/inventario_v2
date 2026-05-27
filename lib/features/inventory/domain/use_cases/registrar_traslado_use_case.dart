import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/models/inventory_requests.dart';
import 'package:inventario_v2/core/services/remote_logger.dart';
import 'package:inventario_v2/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/inventario_provider.dart';
import 'package:inventario_v2/features/inventory/presentation/providers/warehouse_inventory_provider.dart'
    hide inventarioRepositoryProvider;

final registrarTrasladoUseCaseProvider = Provider((ref) {
  return RegistrarTrasladoUseCase(ref);
});

class RegistrarTrasladoUseCase {
  final Ref _ref;

  RegistrarTrasladoUseCase(this._ref);

  Future<void> ejecutar({
    required String originWarehouseId,
    required String destinationWarehouseId,
    required String descripcion,
    required List<Map<String, dynamic>> transferItems,
  }) async {
    if (originWarehouseId.isEmpty || destinationWarehouseId.isEmpty) {
      throw ArgumentError('Debes seleccionar las bodegas de origen y destino.');
    }

    if (transferItems.isEmpty) {
      throw ArgumentError('La orden de traslado está vacía.');
    }

    final repository = _ref.read(inventarioRepositoryProvider);

    final request = TransferRequest(
      originWarehouseId: originWarehouseId,
      destinationWarehouseId: destinationWarehouseId,
      descripcion: descripcion,
      items: transferItems.map(_mapItemToRequest).toList(),
    );

    RemoteLogger.info(
      'Traslado iniciado',
      module: 'inventario',
      action: 'traslado_inicio',
      metadata: {
        'origen': originWarehouseId,
        'destino': destinationWarehouseId,
        'items': transferItems.length,
      },
    );

    try {
      await repository.registrarTraslado(request);
    } catch (e, st) {
      RemoteLogger.error(
        'Error al registrar traslado',
        module: 'inventario',
        action: 'traslado_error',
        exception: e,
        stackTrace: st,
        metadata: {
          'origen': originWarehouseId,
          'destino': destinationWarehouseId,
          'items': transferItems.length,
        },
      );
      rethrow;
    }

    RemoteLogger.info(
      'Traslado registrado exitosamente',
      module: 'inventario',
      action: 'traslado_success',
      metadata: {
        'origen': originWarehouseId,
        'destino': destinationWarehouseId,
        'items': transferItems.length,
      },
    );

    _ref.invalidate(warehouseInventoryProvider(originWarehouseId));
    _ref.invalidate(warehouseInventoryProvider(destinationWarehouseId));
    _ref.invalidate(dashboardProvider);
  }

  TransferItemRequest _mapItemToRequest(Map<String, dynamic> item) {
    return TransferItemRequest(
      productId: item['productId'] as String,
      productVariantId: item['productVariantId']?.toString(),
      cantidad: (item['cantidad'] as num?)?.toDouble() ?? 0.0,
      costoProveedor: (item['cost'] as num?)?.toDouble() ?? 0.0,
      costoUnitarioFinal: (item['cost'] as num?)?.toDouble() ?? 0.0,
      precioVenta: (item['price'] as num?)?.toDouble(),
      sku: item['qr']?.toString(),
      size: item['size']?.toString(),
      availableStock: (item['availableStock'] as num?)?.toDouble(),
    );
  }
}
