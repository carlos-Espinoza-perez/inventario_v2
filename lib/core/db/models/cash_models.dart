import '../app_database.dart';
import '../models/report_models.dart';

class CashExtraMovementView {
  final String id;
  final String tipo;
  final String? motivo;
  final double monto;
  final DateTime fecha;
  final String? referenciaVentaId;
  final String? usuarioRegistroId;
  final String syncStatus;

  const CashExtraMovementView({
    required this.id,
    required this.tipo,
    required this.motivo,
    required this.monto,
    required this.fecha,
    required this.referenciaVentaId,
    required this.usuarioRegistroId,
    required this.syncStatus,
  });
}

class CashSessionDetailDrift {
  final CajaSesione sesion;
  final String cajeroNombre;
  final double ventasEfectivo;
  final double ventasCreditoPendiente;
  final double gastosTotales;
  final double gananciaEstimada;
  final double efectivoEsperado;
  final List<CashExtraMovementView> movimientos;
  final List<SalesListItemDrift> ventas;

  const CashSessionDetailDrift({
    required this.sesion,
    required this.cajeroNombre,
    required this.ventasEfectivo,
    required this.ventasCreditoPendiente,
    required this.gastosTotales,
    required this.gananciaEstimada,
    required this.efectivoEsperado,
    required this.movimientos,
    required this.ventas,
  });
}
