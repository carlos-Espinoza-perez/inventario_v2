import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/exceptions/dao_exceptions.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/bodega_provider.dart';
import 'package:inventario_v2/features/sales/data/repositories/sales_repository.dart';

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
  }) async {
    // 1. Validaciones básicas de entrada
    if (saleType == "Fiado" && nombreCliente.trim().isEmpty) {
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
    
    final dashboardState = _ref.read(dashboardProvider).value;
    final cajaSesionId = dashboardState?.cajaAbierta?.serverId;

    if (cajaSesionId == null) {
      throw CajaSesionNoActivaException(
        "No hay una sesión de caja abierta. Abre caja primero.",
      );
    }

    final selectedBodega = _ref.read(selectedBodegaProvider);
    final bodegaId = selectedBodega?.serverId ?? '';

    if (bodegaId.isEmpty) {
      throw ContextoInvalidoException(
        "Requieres tener una bodega seleccionada para vender.",
      );
    }

    // 3. Ejecutar la acción en el repositorio
    await salesRepository.registrarVentaDesdeCheckout(
      cajaSesionId: cajaSesionId,
      nombreCliente: nombreCliente,
      saleType: saleType,
      total: total,
      depositAmount: depositAmount,
      bodegaId: bodegaId,
      cartItems: cartItems,
    );

    // 4. Invalidar estados para refrescar la UI
    _ref.invalidate(dashboardProvider);
  }
}
