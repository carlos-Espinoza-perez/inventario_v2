import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/db/models/dashboard_models.dart';
import 'package:inventario_v2/core/providers/auto_sync_provider.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/bodega_provider.dart';

final syncErrorCountProvider = FutureProvider.autoDispose<int>((ref) async {
  ref.watch(autoSyncProvider.select((s) => s.value?.lastSync));
  final db = ref.watch(driftDatabaseProvider);
  const tables = [
    'empresas', 'roles', 'accesos_rol', 'usuarios', 'bodegas', 'bodegas_usuarios',
    'cajas', 'caja_sesiones', 'caja_movimientos_extras', 'categorias', 'productos',
    'producto_variantes', 'inventarios', 'clientes', 'movimientos',
    'detalle_movimientos', 'ventas', 'detalle_ventas', 'pagos_ventas',
  ];
  var total = 0;
  for (final table in tables) {
    final row = await db
        .customSelect("SELECT COUNT(*) AS cnt FROM $table WHERE sync_status = 'sync_error'")
        .getSingleOrNull();
    total += row?.read<int>('cnt') ?? 0;
  }
  return total;
});

extension CajaSesionDashboardCompat on CajaSesione {
  String get serverId => id;
}

class TransactionItemModel {
  final String title;
  final String subtitle;
  final double amount;
  final bool isIncome;
  final DateTime date;

  const TransactionItemModel({
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
  final CajaSesione? cajaAbierta;
  final double ventasEnCurso;
  final double gananciasEsperadas;
  final double ventasDelDia;
  final int stockBajo;
  final List<DashboardTopProduct> productosMasVendidos;
  final List<TransactionItemModel> ultimasTransacciones;

  const DashboardState({
    this.montoTotalInventario = 0,
    this.montoTotalFiados = 0,
    this.cajaAbierta,
    this.ventasEnCurso = 0,
    this.gananciasEsperadas = 0,
    this.ventasDelDia = 0,
    this.stockBajo = 0,
    this.productosMasVendidos = const [],
    this.ultimasTransacciones = const [],
  });
}

final dashboardProvider = FutureProvider.autoDispose<DashboardState>((ref) async {
  // Se re-ejecuta cuando termina una sincronización exitosa con el servidor
  ref.watch(autoSyncProvider.select((s) => s.value?.lastSync));

  final db = ref.watch(driftDatabaseProvider);
  final validBodegaIds = await ref.watch(validBodegasIdsProvider.future);

  final montoTotalInventario = await db.inventoryDao.getValorTotalInventario(
    bodegaIds: validBodegaIds,
  );
  final montoTotalFiados = await db.salesDao.getMontoTotalFiados(
    bodegaIds: validBodegaIds,
  );
  final cajaAbierta = await db.salesDao.getCajaSesionActivaActual(
    bodegaIds: validBodegaIds,
  );
  final ventasDelDia = await db.salesDao.getVentasDelDia(
    bodegaIds: validBodegaIds,
  );
  final lowStock = await db.inventoryDao.getLowStockProducts(
    bodegaIds: validBodegaIds,
  );
  final topProducts = await db.salesDao.getTopSellingProducts(
    bodegaIds: validBodegaIds,
    limit: 5,
  );
  final transacciones = await db.salesDao.getRecentTransactions(
    bodegaIds: validBodegaIds,
    limit: 5,
  );

  var ventasEnCurso = 0.0;
  var gananciasEsperadas = 0.0;
  if (cajaAbierta != null) {
    ventasEnCurso = await db.salesDao.getVentasEfectivoSesion(cajaAbierta.id);
    gananciasEsperadas = await db.salesDao.getGananciaSesion(cajaAbierta.id);
  }

  return DashboardState(
    montoTotalInventario: montoTotalInventario,
    montoTotalFiados: montoTotalFiados,
    cajaAbierta: cajaAbierta,
    ventasEnCurso: ventasEnCurso,
    gananciasEsperadas: gananciasEsperadas,
    ventasDelDia: ventasDelDia,
    stockBajo: lowStock.length,
    productosMasVendidos: topProducts,
    ultimasTransacciones: transacciones
        .map(
          (tx) => TransactionItemModel(
            title: tx.title,
            subtitle: tx.subtitle,
            amount: tx.amount,
            isIncome: tx.isIncome,
            date: tx.date,
          ),
        )
        .toList(),
  );
});

