import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/bodega_provider.dart';
import 'package:inventario_v2/core/providers/database_provider.dart';
import 'package:inventario_v2/features/inventory/data/collections/inventario_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/producto_collection.dart';

// ------------------------------------------------------------------
// MODEL
// ------------------------------------------------------------------
class InventoryReportModel {
  final double valorTotal;
  final int totalItems;
  final int criticos; // stock <= 5
  final int medios; // stock 6-20
  final int saludables; // stock > 20
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

// ------------------------------------------------------------------
// PROVIDER
// ------------------------------------------------------------------
final inventoryReportProvider =
    FutureProvider.autoDispose<InventoryReportModel>((ref) async {
      final isar = await ref.watch(isarDbProvider.future);

      final validBodegaIds = await ref.watch(validBodegasIdsProvider.future);

      // Obtener todos los inventarios
      final inventariosGlobal = await isar.inventarioCollections
          .where()
          .findAll();
      final inventarios = inventariosGlobal.where(
        (i) => validBodegaIds.contains(i.bodegaId),
      );

      double valorTotal = 0;
      int criticos = 0, medios = 0, saludables = 0;
      final List<LowStockItem> lowStockList = [];

      for (final inv in inventarios) {
        // Obtener producto para nombre y costo
        final producto = await isar.productoCollections
            .filter()
            .serverIdEqualTo(inv.productoId)
            .findFirst();

        if (producto == null) continue;

        final cantidad = inv.cantidadActual.toInt();
        final costo = inv.costoPromedio > 0
            ? inv.costoPromedio
            : producto.ultimoCosto;

        valorTotal += inv.cantidadActual * costo;

        // Clasificar estado de stock
        if (cantidad <= 5) {
          criticos++;
          lowStockList.add(
            LowStockItem(
              nombre: producto.nombre,
              sku: producto.codigoPersonalizado ?? 'Sin SKU',
              cantidadActual: cantidad,
              stockMinimo:
                  5, // umbral de alerta: crítico por debajo de 5 unidades
            ),
          );
        } else if (cantidad <= 20) {
          medios++;
        } else {
          saludables++;
        }
      }

      // Ordenar stock bajo de menor a mayor
      lowStockList.sort((a, b) => a.cantidadActual.compareTo(b.cantidadActual));

      final total = criticos + medios + saludables;

      return InventoryReportModel(
        valorTotal: valorTotal,
        totalItems: total,
        criticos: criticos,
        medios: medios,
        saludables: saludables,
        lowStock: lowStockList.take(10).toList(),
      );
    });

// ------------------------------------------------------------------
// SCREEN
// ------------------------------------------------------------------
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
            title: "Estado de Inventario",
            subtitle: "Distribución y valorización",
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
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (report) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. KPI: VALOR TOTAL
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
                          "Valor Total en Bodega",
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "\$ ${report.valorTotal.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 26,
                          ),
                        ),
                        Text(
                          "${report.totalItems} productos en stock",
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

              // 2. GRÁFICO DE DONA
              const Text(
                "Distribución de Stock",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 10),

              if (report.totalItems == 0)
                const Center(child: Text("No hay productos en inventario."))
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
                            "Total Items",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            "${report.totalItems}",
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
                      label: "Saludable (${report.saludables})",
                    ),
                    const SizedBox(width: 15),
                    _LegendItem(
                      color: Colors.orange,
                      label: "Medio (${report.medios})",
                    ),
                    const SizedBox(width: 15),
                    _LegendItem(
                      color: Colors.red,
                      label: "Crítico (${report.criticos})",
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 30),

              // 3. LISTA DE STOCK BAJO
              if (report.lowStock.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "⚠️ Alerta: Stock Bajo",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      "${report.lowStock.length} productos",
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
                "$stock / $maxStock",
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
