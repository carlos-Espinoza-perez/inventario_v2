import '../app_database.dart';

class SaleDetailItemDrift {
  final String detalleId;
  final String productoId;
  final String? productoVarianteId;
  final String nombre;
  final String sku;
  final String? talla;
  final String? color;
  final double cantidad;
  final double precioUnitario;
  final double descuento;
  final double subtotal;
  final double costoHistoricoCompra;

  const SaleDetailItemDrift({
    required this.detalleId,
    required this.productoId,
    required this.productoVarianteId,
    required this.nombre,
    required this.sku,
    required this.talla,
    required this.color,
    required this.cantidad,
    required this.precioUnitario,
    required this.descuento,
    required this.subtotal,
    required this.costoHistoricoCompra,
  });
}

class SalePaymentDrift {
  final String id;
  final DateTime fecha;
  final double monto;
  final String metodoPago;
  final String? referencia;

  const SalePaymentDrift({
    required this.id,
    required this.fecha,
    required this.monto,
    required this.metodoPago,
    required this.referencia,
  });
}

class SaleDetailDrift {
  final Venta venta;
  final Cliente? cliente;
  final List<SaleDetailItemDrift> items;
  final List<SalePaymentDrift> pagos;

  const SaleDetailDrift({
    required this.venta,
    required this.cliente,
    required this.items,
    required this.pagos,
  });

  double get balancePendiente => venta.totalVenta - venta.totalPagado;
  bool get estaPagada => balancePendiente <= 0.01;
}

class SalesListItemDrift {
  final String id;
  final String fullId;
  final String client;
  final DateTime date;
  final double total;
  final String status;
  final int itemsCount;

  const SalesListItemDrift({
    required this.id,
    required this.fullId,
    required this.client,
    required this.date,
    required this.total,
    required this.status,
    required this.itemsCount,
  });
}

class ReceivableClientDrift {
  final String clientId;
  final String name;
  final double totalDebt;
  final DateTime? lastPaymentDate;
  final int ventasCount;

  const ReceivableClientDrift({
    required this.clientId,
    required this.name,
    required this.totalDebt,
    required this.lastPaymentDate,
    required this.ventasCount,
  });
}

class FinancialReportDrift {
  final double ingresos;
  final double costoVenta;
  final double gastosOperativos;

  const FinancialReportDrift({
    required this.ingresos,
    required this.costoVenta,
    required this.gastosOperativos,
  });

  double get utilidadBruta => ingresos - costoVenta;
  double get utilidadNeta => ingresos - costoVenta - gastosOperativos;
  double get margen => ingresos > 0 ? (utilidadNeta / ingresos) * 100 : 0;
}

class CashAuditDrift {
  final String sessionId;
  final DateTime openedAt;
  final DateTime? closedAt;
  final double totalVentas;
  final double totalEfectivo;
  final double diferencia;
  final String estado;

  const CashAuditDrift({
    required this.sessionId,
    required this.openedAt,
    required this.closedAt,
    required this.totalVentas,
    required this.totalEfectivo,
    required this.diferencia,
    required this.estado,
  });
}

class ReportDashboardStatsDrift {
  final double ventasHoy;
  final double utilidadHoy;

  const ReportDashboardStatsDrift({
    required this.ventasHoy,
    required this.utilidadHoy,
  });
}
