import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/db/exceptions/dao_exceptions.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/core/services/remote_logger.dart';
import 'package:inventario_v2/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/bodega_provider.dart';
import 'package:inventario_v2/features/inventory/presentation/providers/warehouse_inventory_provider.dart';
import 'package:inventario_v2/features/sales/data/repositories/sales_repository.dart';
import 'package:inventario_v2/features/sales/presentation/sales_dashboard_screen.dart';

final registrarVentaUseCaseProvider = Provider((ref) {
  return RegistrarVentaUseCase(ref);
});

class RegistrarVentaUseCase {
  final Ref _ref;

  RegistrarVentaUseCase(this._ref);

  Future<void> ejecutar({
    required List<Map<String, dynamic>> cartItems,
    required String nombreCliente,
    required String saleType,
    required double total,
    required double depositAmount,
    String? bodegaId,
    String? cajaSesionId,
  }) async {
    final normalizedSaleType = _normalizeSaleType(saleType);
    // 1. Validaciones básicas de entrada
    if (normalizedSaleType == "Fiado" && nombreCliente.trim().isEmpty) {
      throw ContextoInvalidoException(
        "Para ventas al fiado, el nombre del cliente es obligatorio",
      );
    }

    if (depositAmount > total) {
      throw ContextoInvalidoException("El abono no puede ser mayor al total");
    }

    // 2. Obtener contexto operativo
    final db = _ref.read(driftDatabaseProvider);
    final salesRepository = SalesRepository(db);

    CajaSesione? activeCashSession;
    String effectiveCajaSesionId;
    if (cajaSesionId != null && cajaSesionId.isNotEmpty) {
      effectiveCajaSesionId = cajaSesionId;
      activeCashSession =
          await (db.select(db.cajaSesiones)
                ..where((tbl) => tbl.id.equals(cajaSesionId))
                ..limit(1))
              .getSingleOrNull();
      if (activeCashSession == null) {
        activeCashSession = await db.salesDao.getCajaSesionActivaActual();
        effectiveCajaSesionId = activeCashSession?.id ?? effectiveCajaSesionId;
      }
    } else {
      final dashboardState = _ref.read(dashboardProvider).value;
      activeCashSession = dashboardState?.cajaAbierta;
      effectiveCajaSesionId = activeCashSession?.id ?? '';
      if (effectiveCajaSesionId.isEmpty) {
        activeCashSession = await db.salesDao.getCajaSesionActivaActual();
        effectiveCajaSesionId = activeCashSession?.id ?? '';
      }
    }

    if (effectiveCajaSesionId.isEmpty) {
      throw CajaSesionNoActivaException(
        "No hay una sesión de caja abierta. Abre caja primero.",
      );
    }

    String effectiveBodegaId;
    if (bodegaId != null && bodegaId.isNotEmpty) {
      effectiveBodegaId = bodegaId;
    } else {
      final selectedBodega = _ref.read(selectedBodegaProvider);
      effectiveBodegaId = selectedBodega?.serverId ?? '';
      activeCashSession ??= await db.salesDao.getCajaSesionActivaActual();
      if (effectiveBodegaId.isEmpty && activeCashSession != null) {
        final caja =
            await (db.select(db.cajas)
                  ..where((tbl) => tbl.id.equals(activeCashSession!.cajaId))
                  ..limit(1))
                .getSingleOrNull();
        effectiveBodegaId = caja?.bodegaId ?? '';
      }
    }

    if (effectiveBodegaId.isEmpty) {
      throw ContextoInvalidoException(
        "Requieres tener una bodega seleccionada para vender.",
      );
    }

    // 3. Ejecutar la acción en el repositorio
    try {
      await salesRepository.registrarVentaDesdeCheckout(
        cajaSesionId: effectiveCajaSesionId,
        nombreCliente: nombreCliente,
        saleType: normalizedSaleType,
        total: total,
        depositAmount: depositAmount,
        bodegaId: effectiveBodegaId,
        cartItems: cartItems,
      );
    } catch (e, st) {
      RemoteLogger.error(
        'Error al registrar venta',
        module: 'ventas',
        action: 'registrar_venta_error',
        errorCode: e.runtimeType.toString(),
        exception: e,
        stackTrace: st,
        metadata: {
          'total': total,
          'tipo': normalizedSaleType,
          'items': cartItems.length,
          'cajaSesionId': effectiveCajaSesionId,
          'bodegaId': effectiveBodegaId,
        },
      );
      rethrow;
    }

    RemoteLogger.info(
      'Venta registrada',
      module: 'ventas',
      action: 'registrar_venta_success',
      metadata: {
        'total': total,
        'tipo': normalizedSaleType,
        'items': cartItems.length,
        'bodegaId': effectiveBodegaId,
      },
    );

    // 4. Invalidar estados para refrescar la UI
    _ref.invalidate(salesListProvider);
    _ref.invalidate(warehouseInventoryProvider(effectiveBodegaId));
    _ref.invalidate(dashboardProvider);
  }

  String _normalizeSaleType(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e');
    if (normalized == 'fiado') return 'Fiado';
    if (normalized == 'credito') return 'Fiado';
    if (normalized == 'contado') return 'Contado';
    return 'Contado';
  }
}
