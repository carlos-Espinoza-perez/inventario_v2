import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/db/models/cash_models.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/core/services/remote_logger.dart';

final cajaRepositoryProvider = Provider((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return CajaRepository(db);
});

class CajaRepository {
  final AppDatabase _db;

  CajaRepository(this._db);

  Future<CajaSesione?> obtenerCajaAbierta() {
    return _db.salesDao.getCajaSesionActivaActual();
  }

  Future<CajaSesione> abrirCaja({double montoInicial = 0}) async {
    try {
      final sesion = await _db.salesDao.abrirCajaActual(montoInicial: montoInicial);
      RemoteLogger.info(
        'Caja abierta',
        module: 'caja',
        action: 'abrir_caja',
        metadata: {'cajaSesionId': sesion.id, 'montoInicial': montoInicial},
      );
      return sesion;
    } catch (e, st) {
      RemoteLogger.error(
        'Error al abrir caja',
        module: 'caja',
        action: 'abrir_caja_error',
        exception: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<CajaMovimientosExtra> registrarGasto({
    required String cajaSesionId,
    required double amount,
    required String reason,
  }) {
    return _db.salesDao.registrarMovimientoExtraCaja(
      cajaSesionId: cajaSesionId,
      tipo: 'egreso',
      monto: amount,
      motivo: reason,
    );
  }

  Future<List<CajaMovimientosExtra>> obtenerMovimientosExtras(
    String cajaSesionId,
  ) {
    return _db.salesDao.getMovimientosExtrasCaja(cajaSesionId);
  }

  Future<List<CajaSesione>> obtenerHistorialCajas() {
    return _db.salesDao.obtenerHistorialCajas();
  }

  Future<void> cerrarCaja({
    required String cajaSesionId,
    required String usuarioCierreId,
    double? efectivoContado,
  }) async {
    RemoteLogger.info(
      'Cierre de caja iniciado',
      module: 'caja',
      action: 'cerrar_caja_inicio',
      metadata: {'cajaSesionId': cajaSesionId},
    );
    try {
      await _db.salesDao.cerrarCaja(
        cajaSesionId: cajaSesionId,
        usuarioCierreId: usuarioCierreId,
        efectivoContado: efectivoContado,
      );
      RemoteLogger.info(
        'Caja cerrada exitosamente',
        module: 'caja',
        action: 'cerrar_caja_success',
        metadata: {
          'cajaSesionId': cajaSesionId,
          'efectivoContado': efectivoContado,
        },
      );
    } catch (e, st) {
      RemoteLogger.error(
        'Error al cerrar caja',
        module: 'caja',
        action: 'cerrar_caja_error',
        exception: e,
        stackTrace: st,
        metadata: {'cajaSesionId': cajaSesionId},
      );
      rethrow;
    }
  }

  Future<double> obtenerVentasEfectivo(String cajaSesionId) {
    return _db.salesDao.getVentasEfectivoSesion(cajaSesionId);
  }

  Future<double> obtenerVentasCredito(String cajaSesionId) {
    return _db.salesDao.getVentasCreditoPendienteSesion(cajaSesionId);
  }

  Future<double> obtenerGananciaSesion(String cajaSesionId) {
    return _db.salesDao.getGananciaSesion(cajaSesionId);
  }

  Future<CashSessionDetailDrift> obtenerDetalleSesion(String sessionId) {
    return _db.salesDao.getCajaSessionDetail(sessionId);
  }
}
