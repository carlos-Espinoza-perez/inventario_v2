import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:inventario_v2/core/providers/database_provider.dart';
import 'package:inventario_v2/features/inventory/data/collections/inventario_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/producto_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/venta_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/detalle_venta_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/caja_sesion_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/historial_pago_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/cliente_collection.dart';
import 'package:inventario_v2/core/constants/app_enums.dart';

class TransactionItemModel {
  final String title;
  final String subtitle;
  final double amount;
  final bool isIncome;
  final DateTime date;

  TransactionItemModel({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
    required this.date,
  });
}

class DashboardState {
  final double montoTotalInventario;
  final double montoTotalFiados;

  final CajaSesionCollection? cajaAbierta;
  final double ventasEnCurso;
  final double gananciasEsperadas;

  final List<TransactionItemModel> ultimasTransacciones;

  DashboardState({
    this.montoTotalInventario = 0,
    this.montoTotalFiados = 0,
    this.cajaAbierta,
    this.ventasEnCurso = 0,
    this.gananciasEsperadas = 0,
    this.ultimasTransacciones = const [],
  });
}

final dashboardProvider = FutureProvider.autoDispose<DashboardState>((
  ref,
) async {
  final isar = await ref.watch(isarDbProvider.future);

  // 1. Monto total de inventario (Cantidad * PrecioVenta de productos/Inventario)
  // Nota: Podríamos calcular cantidad_actual * ultimoCosto o cantidad_actual * ultimoPrecioVenta.
  // Asumiremos costo (valoración de inventario en bodega).
  final inventarios = await isar.inventarioCollections.where().findAll();
  double totalInventario = 0;
  for (var inv in inventarios) {
    if (inv.cantidadActual > 0) {
      final prod = await isar.productoCollections
          .filter()
          .serverIdEqualTo(inv.productoId)
          .findFirst();
      if (prod != null) {
        totalInventario += (inv.cantidadActual * prod.ultimoCosto);
      }
    }
  }

  // 2. Monto total de fiados (Saldo Pendiente de ventas al crédito no pagadas)
  final fiadosList = await isar.ventaCollections
      .filter()
      .tipoVentaEqualTo(TipoVenta.credito)
      .estadoEqualTo(true)
      .findAll();

  final fiados = fiadosList
      .where((f) => f.estadoPago != EstadoPago.pagado)
      .toList();

  double totalFiados = fiados.fold(0.0, (sum, f) => sum + (f.saldoPendiente));

  // 3. Caja actual en curso
  final cajaAbierta = await isar.cajaSesionCollections
      .filter()
      .estadoSesionEqualTo(EstadoSesion.abierta)
      .findFirst();

  double ventasSesion = 0;
  double gananciasEsperadas = 0;

  if (cajaAbierta != null) {
    final ventasCaja = await isar.ventaCollections
        .filter()
        .cajaSesionIdEqualTo(cajaAbierta.serverId)
        .estadoEqualTo(true)
        .findAll();

    for (var v in ventasCaja) {
      if (v.tipoVenta == TipoVenta.credito) {
        ventasSesion += v
            .totalPagado; // Solo sumamos lo que se ha pagado de la venta a crédito
      } else {
        ventasSesion += v.totalVenta;
      }

      // Obtener el costo de los detalles
      final detalles = await isar.detalleVentaCollections
          .filter()
          .ventaIdEqualTo(v.serverId)
          .findAll();

      double costoVenta = 0;
      for (var d in detalles) {
        costoVenta += (d.cantidad * d.costoHistoricoCompra);
      }

      if (v.tipoVenta == TipoVenta.credito) {
        double pctPagado = v.totalVenta > 0
            ? (v.totalPagado / v.totalVenta)
            : 0;
        double gananciaVenta = v.totalVenta - costoVenta;
        gananciasEsperadas += (gananciaVenta * pctPagado);
      } else {
        gananciasEsperadas += (v.totalVenta - costoVenta);
      }
    }
  }

  // 4. Últimas Transacciones
  // Obtenemos últimas ventas
  final ultimasVentas = await isar.ventaCollections
      .where()
      .sortByFechaVentaDesc()
      .limit(10)
      .findAll();

  // Obtenemos últimos abonos (HistorialPabgo)
  final ultimosAbonos = await isar.historialPagoCollections
      .where()
      .sortByFechaRegistroDesc()
      .limit(10)
      .findAll();

  List<TransactionItemModel> transacciones = [];

  for (var v in ultimasVentas) {
    if (!v.estado)
      continue; // Si está anulada, mostrar distinto o ignorar. La ignoramos momentáneamente
    final cli = await isar.clienteCollections
        .filter()
        .serverIdEqualTo(v.clienteId)
        .findFirst();
    final nombreCliente = cli?.nombre ?? 'Cliente Desconocido';
    final isCredito = v.tipoVenta == TipoVenta.credito;

    transacciones.add(
      TransactionItemModel(
        title: isCredito ? "Venta a crédito" : "Venta de productos",
        subtitle: nombreCliente,
        amount: v.totalVenta,
        isIncome: true, // Venta suma a ventas (aunque fiado suma a CxC)
        date: v.fechaVenta,
      ),
    );
  }

  for (var pago in ultimosAbonos) {
    final v = await isar.ventaCollections
        .filter()
        .serverIdEqualTo(pago.ventaId)
        .findFirst();
    if (v == null) continue;
    final cli = await isar.clienteCollections
        .filter()
        .serverIdEqualTo(v.clienteId)
        .findFirst();
    final nombreCliente = cli?.nombre ?? 'Cliente Desconocido';

    transacciones.add(
      TransactionItemModel(
        title: "Abono de cliente",
        subtitle: nombreCliente,
        amount: pago.montoPagado,
        isIncome: true,
        date: pago.fechaRegistro,
      ),
    );
  }

  // Ordenar mezcla y tomar 5
  transacciones.sort((a, b) => b.date.compareTo(a.date));
  if (transacciones.length > 5) {
    transacciones = transacciones.sublist(0, 5);
  }

  return DashboardState(
    montoTotalInventario: totalInventario,
    montoTotalFiados: totalFiados,
    cajaAbierta: cajaAbierta,
    ventasEnCurso: ventasSesion,
    gananciasEsperadas: gananciasEsperadas,
    ultimasTransacciones: transacciones,
  );
});
