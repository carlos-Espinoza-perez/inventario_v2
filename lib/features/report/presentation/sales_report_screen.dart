import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:inventario_v2/core/presentation/mixins/app_bar_config_mixin.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/bodega_provider.dart';

class SalesReportModel {
  final List<double> ventasPorDia;
  final double totalSemana;
  final Map<String, double> ventasPorCategoria;
  final List<Map<String, dynamic>> gananciaPorProducto;

  SalesReportModel({
    required this.ventasPorDia,
    required this.totalSemana,
    required this.ventasPorCategoria,
    required this.gananciaPorProducto,
  });
}

final salesReportProvider = FutureProvider.autoDispose<SalesReportModel>((
  ref,
) async {
  final db = ref.watch(driftDatabaseProvider);
  final validBodegaIds = await ref.watch(validBodegasIdsProvider.future);
  final report = await db.salesDao.getWeeklySalesReport(
    bodegaIds: validBodegaIds,
  );
  return SalesReportModel(
    ventasPorDia: report.ventasPorDia,
    totalSemana: report.totalSemana,
    ventasPorCategoria: report.ventasPorCategoria,
    gananciaPorProducto: report.gananciaPorProducto,
  );
});

class SalesReportScreen extends ConsumerStatefulWidget {
  const SalesReportScreen({super.key});

  @override
  ConsumerState<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends ConsumerState<SalesReportScreen>
    with AppBarConfigMixin {
  @override
  void configureAppBar() {
    ref.read(appBarProvider.notifier).setOptions(
      title: 'Reporte de Ventas',
      subtitle: 'Analisis Semanal',
      showBackButton: true,
      actions: [
        IconButton(
          onPressed: () => ref.invalidate(salesReportProvider),
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(configureAppBar);
  }

  int _touchedIndex = -1;

  static const _dayLabels = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
  static const _chartColors = [
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.green,
    Colors.red,
    Colors.teal,
    Colors.amber,
  ];

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(salesReportProvider);
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekLabel =
        'Semana del ${DateFormat('dd MMM').format(monday)} al ${DateFormat('dd MMM').format(monday.add(const Duration(days: 6)))}';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (report) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tendencia Semanal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                weekLabel,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 15),
              Container(
                height: 290,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Semana',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              NumberFormat.simpleCurrency().format(
                                report.totalSemana,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Semana Actual',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: report.totalSemana == 0
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bar_chart_outlined,
                                  color: Colors.grey[300],
                                  size: 48,
                                ),
                                const Text(
                                  'Sin ventas esta semana',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            )
                          : BarChart(
                              BarChartData(
                                barTouchData: BarTouchData(
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipColor: (_) => Colors.blueGrey,
                                    getTooltipItem:
                                        (
                                          group,
                                          groupIndex,
                                          rod,
                                          rodIndex,
                                        ) => BarTooltipItem(
                                          NumberFormat.compactSimpleCurrency()
                                              .format(rod.toY),
                                          const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                  ),
                                  touchCallback: (FlTouchEvent event, response) {
                                    setState(() {
                                      if (!event.isInterestedForInteractions ||
                                          response == null ||
                                          response.spot == null) {
                                        _touchedIndex = -1;
                                        return;
                                      }
                                      _touchedIndex =
                                          response.spot!.touchedBarGroupIndex;
                                    });
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) =>
                                          SideTitleWidget(
                                            meta: meta,
                                            space: 4,
                                            child: Text(
                                              _dayLabels[value.toInt().clamp(
                                                0,
                                                6,
                                              )],
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                      reservedSize: 28,
                                    ),
                                  ),
                                  leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                gridData: const FlGridData(show: false),
                                barGroups: List.generate(7, (i) {
                                  final isTouched = i == _touchedIndex;
                                  return BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY: report.ventasPorDia[i],
                                        color: isTouched
                                            ? Colors.blueAccent
                                            : Colors.lightBlue.shade200,
                                        width: 22,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(6),
                                            ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              if (report.ventasPorCategoria.isNotEmpty) ...[
                const Text(
                  'Ventas por Categoria',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 180,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 35,
                              sections: _buildPieSections(
                                report.ventasPorCategoria,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildLegend(report.ventasPorCategoria),
                      ),
                    ],
                  ),
                ),
              ],
              if (report.gananciaPorProducto.isNotEmpty) ...[
                const SizedBox(height: 30),
                const Text(
                  'Ganancia por Producto',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: report.gananciaPorProducto.length,
                    separatorBuilder: (c, i) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = report.gananciaPorProducto[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade50,
                          child: Icon(
                            Icons.attach_money,
                            color: Colors.green.shade700,
                          ),
                        ),
                        title: Text(
                          item['nombre'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        trailing: Text(
                          NumberFormat.simpleCurrency().format(
                            item['ganancia'],
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.green,
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<String, double> data) {
    final total = data.values.fold(0.0, (s, v) => s + v);
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return List.generate(entries.length, (i) {
      final pct = total > 0 ? (entries[i].value / total * 100) : 0;
      return PieChartSectionData(
        color: _chartColors[i % _chartColors.length],
        value: entries[i].value,
        title: '${pct.toStringAsFixed(0)}%',
        radius: 45,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  List<Widget> _buildLegend(Map<String, double> data) {
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return List.generate(entries.length, (i) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 5,
              backgroundColor: _chartColors[i % _chartColors.length],
            ),
            const SizedBox(width: 6),
            Text(
              entries[i].key,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    });
  }
}

