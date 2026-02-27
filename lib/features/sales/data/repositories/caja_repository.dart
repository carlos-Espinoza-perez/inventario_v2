import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'package:inventario_v2/core/providers/database_provider.dart';
import 'package:inventario_v2/features/sales/data/collections/caja_sesion_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/caja_movimiento_extra_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/venta_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/historial_pago_collection.dart';
import 'package:inventario_v2/core/constants/app_enums.dart';

final cajaRepositoryProvider = Provider((ref) {
  final isar = ref.watch(isarDbProvider).value;
  if (isar == null) throw Exception("Isar not initialized");
  return CajaRepository(isar);
});

class CajaRepository {
  final Isar _isar;

  CajaRepository(this._isar);

  Future<CajaSesionCollection?> obtenerCajaAbierta() async {
    return await _isar.cajaSesionCollections
        .filter()
        .estadoSesionEqualTo(EstadoSesion.abierta)
        .findFirst();
  }

  Future<void> abrirCaja({
    required String usuarioId,
    required String cajaId,
  }) async {
    await _isar.writeTxn(() async {
      final nuevaCaja = CajaSesionCollection()
        ..serverId = const Uuid().v4()
        ..cajaId = cajaId
        ..usuarioAperturaId = usuarioId
        ..fechaApertura = DateTime.now()
        ..montoInicial = 0
        ..totalVentasSistema = 0
        ..totalEfectivoReal = 0
        ..diferencia = 0
        ..estadoSesion = EstadoSesion.abierta
        ..ultimaActualizacion = DateTime.now()
        ..pendienteSincronizacion = true;

      await _isar.cajaSesionCollections.put(nuevaCaja);
    });
  }

  Future<void> registrarGasto({
    required String cajaSesionId,
    required double amount,
    required String reason,
    required String usuarioId,
  }) async {
    await _isar.writeTxn(() async {
      final nuevoGasto = CajaMovimientoExtraCollection()
        ..serverId = const Uuid().v4()
        ..cajaSesionId = cajaSesionId
        ..tipo = TipoMovimientoCaja.egreso
        ..monto = amount
        ..motivo = reason
        ..usuarioRegistroId = usuarioId
        ..ultimaActualizacion = DateTime.now()
        ..pendienteSincronizacion = true;

      await _isar.cajaMovimientoExtraCollections.put(nuevoGasto);
    });
  }

  Future<List<CajaMovimientoExtraCollection>> obtenerMovimientosExtras(
    String cajaSesionId,
  ) async {
    return await _isar.cajaMovimientoExtraCollections
        .filter()
        .cajaSesionIdEqualTo(cajaSesionId)
        .sortByUltimaActualizacionDesc()
        .findAll();
  }

  Future<List<CajaSesionCollection>> obtenerHistorialCajas() async {
    return await _isar.cajaSesionCollections
        .where()
        .sortByFechaAperturaDesc()
        .findAll();
  }

  /// Cierra el turno de caja calculando y guardando todos los totales:
  /// - totalVentasSistema: suma de ventas efectivo + crédito
  /// - totalEfectivoReal: monto inicial + ventas efectivo - gastos
  /// - diferencia: totalEfectivoReal - contado (puede ampliarse para arqueo)
  Future<void> cerrarCaja({
    required String cajaSesionId,
    required String usuarioCierreId,
  }) async {
    // 1. Leer datos necesarios ANTES de la transacción
    final caja = await _isar.cajaSesionCollections
        .filter()
        .serverIdEqualTo(cajaSesionId)
        .findFirst();

    if (caja == null) return;

    // 2. Calcular los ingresos en efectivo usando HistorialPago
    final pagos = await _isar.historialPagoCollections
        .filter()
        .cajaSesionIdEqualTo(cajaSesionId)
        .findAll();

    double ventasEfectivo = 0;
    for (final p in pagos) {
      ventasEfectivo += p.montoPagado;
    }

    // 2.1 Calcular total de ventas del sistema (independiente del cobro)
    final ventas = await _isar.ventaCollections
        .filter()
        .cajaSesionIdEqualTo(cajaSesionId)
        .estadoEqualTo(true)
        .findAll();

    double ventasTotal = 0;
    for (final v in ventas) {
      ventasTotal += v.totalVenta;
    }

    // 3. Calcular gastos de esta sesión
    final gastos = await _isar.cajaMovimientoExtraCollections
        .filter()
        .cajaSesionIdEqualTo(cajaSesionId)
        .tipoEqualTo(TipoMovimientoCaja.egreso)
        .findAll();

    final totalGastos = gastos.fold(0.0, (sum, g) => sum + g.monto);

    // 4. Calcular totales
    final totalEfectivoReal = caja.montoInicial + ventasEfectivo - totalGastos;
    // diferencia: 0 porque no hay arqueo físico en este flujo.
    // Cuando se implemente arqueo manual, se comparará con lo contado.
    const diferencia = 0.0;

    // 5. Guardar en Isar
    await _isar.writeTxn(() async {
      final cajaMutable = await _isar.cajaSesionCollections
          .filter()
          .serverIdEqualTo(cajaSesionId)
          .findFirst();

      if (cajaMutable != null) {
        cajaMutable
          ..estadoSesion = EstadoSesion.cerrada
          ..fechaCierre = DateTime.now()
          ..usuarioCierreId = usuarioCierreId
          ..totalVentasSistema = ventasTotal
          ..totalEfectivoReal = totalEfectivoReal
          ..diferencia = diferencia
          ..ultimaActualizacion = DateTime.now()
          ..pendienteSincronizacion = true;

        await _isar.cajaSesionCollections.put(cajaMutable);
      }
    });
  }
}
