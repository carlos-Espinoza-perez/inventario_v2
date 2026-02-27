import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:inventario_v2/core/providers/database_provider.dart';
import 'package:inventario_v2/core/constants/app_enums.dart';
import 'package:inventario_v2/features/sales/data/collections/venta_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/detalle_venta_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/caja_movimiento_extra_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/caja_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/caja_sesion_collection.dart';
import 'package:inventario_v2/features/inventory/data/providers/bodega_provider.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';

// ------------------------------------------------------------------
// MODEL
// ------------------------------------------------------------------
class FinancialReportModel {
  final double ingresos;
  final double costoVenta;
  final double gastosOperativos;
  double get utilidadBruta => ingresos - costoVenta;
  double get utilidadNeta => ingresos - costoVenta - gastosOperativos;
  double get margen => ingresos > 0 ? (utilidadNeta / ingresos) * 100 : 0;

  FinancialReportModel({
    required this.ingresos,
    required this.costoVenta,
    required this.gastosOperativos,
  });
}

// ------------------------------------------------------------------
// PROVIDER — mes actual
// ------------------------------------------------------------------
final financialReportProvider = FutureProvider.autoDispose<FinancialReportModel>((
  ref,
) async {
  final isar = await ref.watch(isarDbProvider.future);
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

  final validBodegaIds = await ref.watch(validBodegasIdsProvider.future);

  final cajas = await isar.cajaCollections.where().findAll();
  final cajasDeBodegasValidas = cajas
      .where((c) => validBodegaIds.contains(c.bodegaId))
      .map((c) => c.serverId)
      .toSet();

  final sesiones = await isar.cajaSesionCollections.where().findAll();
  final sesionesValidas = sesiones
      .where((s) => cajasDeBodegasValidas.contains(s.cajaId))
      .map((s) => s.serverId)
      .toSet();

  // 1. Ventas del mes (activas)
  final ventasTodas = await isar.ventaCollections
      .filter()
      .fechaVentaGreaterThan(startOfMonth)
      .fechaVentaLessThan(endOfMonth)
      .estadoEqualTo(true)
      .findAll();

  final ventas = ventasTodas
      .where((v) => sesionesValidas.contains(v.cajaSesionId))
      .toList();

  double ingresos = 0;
  double costoVenta = 0;

  for (final v in ventas) {
    ingresos += v.totalVenta;
    // Costo de los productos vendidos
    final detalles = await isar.detalleVentaCollections
        .filter()
        .ventaIdEqualTo(v.serverId)
        .findAll();
    for (final d in detalles) {
      costoVenta += d.costoHistoricoCompra * d.cantidad;
    }
  }

  // 2. Gastos operativos del mes (cajaMovimientoExtra de egresos)
  final gastosTemp = await isar.cajaMovimientoExtraCollections
      .filter()
      .tipoEqualTo(TipoMovimientoCaja.egreso)
      .findAll();

  final gastos = gastosTemp
      .where((g) => sesionesValidas.contains(g.cajaSesionId))
      .toList();

  // Filtrar gastos del mes actual manualmente (Isar no soporta rangos en DateTime fácilmente sin índice extra)
  final gastosMes = gastos.where(
    (g) =>
        g.ultimaActualizacion.isAfter(startOfMonth) &&
        g.ultimaActualizacion.isBefore(endOfMonth),
  );
  final gastosOperativos = gastosMes.fold(0.0, (sum, g) => sum + g.monto);

  return FinancialReportModel(
    ingresos: ingresos,
    costoVenta: costoVenta,
    gastosOperativos: gastosOperativos,
  );
});

// ------------------------------------------------------------------
// SCREEN
// ------------------------------------------------------------------
class FinancialReportScreen extends ConsumerStatefulWidget {
  const FinancialReportScreen({super.key});

  @override
  ConsumerState<FinancialReportScreen> createState() =>
      _FinancialReportScreenState();
}

class _FinancialReportScreenState extends ConsumerState<FinancialReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(appBarProvider.notifier)
          .setOptions(
            title: "Reporte Financiero",
            subtitle: "Ingresos y Egresos",
            showBackButton: true,
            actions: [
              IconButton(
                onPressed: () => ref.invalidate(financialReportProvider),
                icon: const Icon(Icons.refresh),
              ),
            ],
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(financialReportProvider);
    final now = DateTime.now();
    final mesLabel = DateFormat('MMMM yyyy').format(now);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (report) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. UTILIDAD NETA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      report.utilidadNeta >= 0
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      report.utilidadNeta >= 0
                          ? Colors.green.shade600
                          : Colors.red.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (report.utilidadNeta >= 0 ? Colors.green : Colors.red)
                              .withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Utilidad Neta (Ganancia)",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      NumberFormat.simpleCurrency().format(report.utilidadNeta),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Margen: ${report.margen.toStringAsFixed(1)}%",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        mesLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 2. ESTADO DE RESULTADOS
              const Text(
                "Estado de Resultados",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _FinanceRow(
                      label: "Ingresos Totales (+)",
                      amount: report.ingresos,
                      color: Colors.blue,
                    ),
                    const Divider(),
                    _FinanceRow(
                      label: "Costo de Venta (-)",
                      amount: report.costoVenta,
                      color: Colors.red.shade300,
                    ),
                    _FinanceRow(
                      label: "Gastos Operativos (-)",
                      amount: report.gastosOperativos,
                      color: Colors.orange.shade300,
                    ),
                    const Divider(thickness: 2),
                    _FinanceRow(
                      label: "GANANCIA REAL (=)",
                      amount: report.utilidadNeta,
                      color: report.utilidadNeta >= 0
                          ? Colors.green
                          : Colors.red,
                      isBold: true,
                      fontSize: 18,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 3. GRÁFICO DE DISTRIBUCIÓN
              if (report.ingresos > 0) ...[
                const Text(
                  "Distribución de Ingresos",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: Colors.red.shade300,
                          value: report.costoVenta,
                          title:
                              '${((report.costoVenta / report.ingresos) * 100).toStringAsFixed(0)}%',
                          radius: 50,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        if (report.gastosOperativos > 0)
                          PieChartSectionData(
                            color: Colors.orange.shade300,
                            value: report.gastosOperativos,
                            title:
                                '${((report.gastosOperativos / report.ingresos) * 100).toStringAsFixed(0)}%',
                            radius: 50,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        if (report.utilidadNeta > 0)
                          PieChartSectionData(
                            color: Colors.green,
                            value: report.utilidadNeta,
                            title: '${report.margen.toStringAsFixed(0)}%',
                            radius: 55,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendDot(
                      color: Colors.red.shade300,
                      label: "Costo Venta",
                    ),
                    const SizedBox(width: 16),
                    _LegendDot(
                      color: Colors.orange.shade300,
                      label: "Gastos Op.",
                    ),
                    const SizedBox(width: 16),
                    _LegendDot(color: Colors.green, label: "Ganancia"),
                  ],
                ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinanceRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isBold;
  final double fontSize;

  const _FinanceRow({
    required this.label,
    required this.amount,
    required this.color,
    this.isBold = false,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
          Text(
            NumberFormat.simpleCurrency().format(amount),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
