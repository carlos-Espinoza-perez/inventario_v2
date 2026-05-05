import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/bodega_provider.dart';

class InventoryReportModel {
  final double valorTotal;
  final int totalItems;
  final int criticos;
  final int medios;
  final int saludables;
  final List<LowStockItem> lowStock;

  InventoryReportModel({
    required this.valorTotal,
    required this.totalItems,
    required this.criticos,
    required this.medios,
    required this.saludables,
    required this.lowStock,
  });
}

class LowStockItem {
  final String nombre;
  final String sku;
  final int cantidadActual;
  final int stockMinimo;

  LowStockItem({
    required this.nombre,
    required this.sku,
    required this.cantidadActual,
    required this.stockMinimo,
  });
}

final inventoryReportProvider =
    FutureProvider.autoDispose<InventoryReportModel>((ref) async {
      final db = ref.watch(driftDatabaseProvider);
      final validBodegaIds = await ref.watch(validBodegasIdsProvider.future);
      final report = await db.inventoryDao.getInventoryReport(
        bodegaIds: validBodegaIds,
      );

      return InventoryReportModel(
        valorTotal: report.valorTotal,
        totalItems: report.totalItems,
        criticos: report.criticos,
        medios: report.medios,
        saludables: report.saludables,
        lowStock: report.lowStock
            .map(
              (item) => LowStockItem(
                nombre: item.nombre,
                sku: item.sku,
                cantidadActual: item.cantidadActual,
                stockMinimo: item.stockMinimo,
              ),
            )
            .toList(),
      );
    });

class InventoryReportScreen extends ConsumerStatefulWidget {
  const InventoryReportScreen({super.key});

  @override
  ConsumerState<InventoryReportScreen> createState() =>
      _InventoryReportScreenState();
}

class _InventoryReportScreenState extends ConsumerState<InventoryReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(appBarProvider.notifier)
          .setOptions(
            title: 'Estado de Inventario',
            subtitle: 'Distribucion y valorizacion',
            showBackButton: true,
            actions: [
              IconButton(
                onPressed: () => ref.invalidate(inventoryReportProvider),
                icon: const Icon(Icons.refresh),
              ),
            ],
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(inventoryReportProvider);

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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade800, Colors.indigo.shade500],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Valor Total en Bodega',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '\$ ${report.valorTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 26,
                          ),
                        ),
                        Text(
                          '${report.totalItems} productos en stock',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.inventory,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Distribucion de Stock',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 10),
              if (report.totalItems == 0)
                const Center(child: Text('No hay productos en inventario.'))
              else ...[
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 70,
                          sections: [
                            if (report.saludables > 0)
                              PieChartSectionData(
                                color: Colors.green,
                                value: report.saludables.toDouble(),
                                title: '',
                                radius: 25,
                              ),
                            if (report.medios > 0)
                              PieChartSectionData(
                                color: Colors.orange,
                                value: report.medios.toDouble(),
                                title: '',
                                radius: 25,
                              ),
                            if (report.criticos > 0)
                              PieChartSectionData(
                                color: Colors.red,
                                value: report.criticos.toDouble(),
                                title: '',
                                radius: 30,
                              ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Total Items',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            '${report.totalItems}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendItem(
                      color: Colors.green,
                      label: 'Saludable (${report.saludables})',
                    ),
                    const SizedBox(width: 15),
                    _LegendItem(
                      color: Colors.orange,
                      label: 'Medio (${report.medios})',
                    ),
                    const SizedBox(width: 15),
                    _LegendItem(
                      color: Colors.red,
                      label: 'Critico (${report.criticos})',
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 30),
              if (report.lowStock.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Stock Bajo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      '${report.lowStock.length} productos',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: report.lowStock.length,
                  itemBuilder: (context, index) {
                    final item = report.lowStock[index];
                    final percent =
                        item.cantidadActual /
                        (item.stockMinimo > 0 ? item.stockMinimo : 1);
                    return _LowStockItem(
                      name: item.nombre,
                      sku: item.sku,
                      stock: item.cantidadActual,
                      maxStock: item.stockMinimo,
                      percent: percent.clamp(0.0, 1.0),
                    );
                  },
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

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _LowStockItem extends StatelessWidget {
  final String name;
  final String sku;
  final int stock;
  final int maxStock;
  final double percent;

  const _LowStockItem({
    required this.name,
    required this.sku,
    required this.stock,
    required this.maxStock,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  sku,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$stock / $maxStock',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 60,
                child: LinearProgressIndicator(
                  value: percent,
                  color: Colors.red,
                  backgroundColor: Colors.red.shade100,
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
