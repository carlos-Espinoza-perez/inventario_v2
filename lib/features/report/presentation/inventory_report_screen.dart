import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class InventoryReportScreen extends StatelessWidget {
  const InventoryReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Estado de Inventario",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. KPI PRINCIPAL: VALOR DEL INVENTARIO
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Valor Total en Bodega",
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "\$ 45,200.00",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
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

            // 2. GRÁFICO DE DONA: STOCK POR ESTADO
            const Text(
              "Distribución de Stock",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 10),
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
                        PieChartSectionData(
                          color: Colors.green,
                          value: 70,
                          title: '',
                          radius: 25,
                        ), // Saludable
                        PieChartSectionData(
                          color: Colors.orange,
                          value: 20,
                          title: '',
                          radius: 25,
                        ), // Medio
                        PieChartSectionData(
                          color: Colors.red,
                          value: 10,
                          title: '',
                          radius: 30,
                        ), // Crítico
                      ],
                    ),
                  ),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Total Items",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        "1,250",
                        style: TextStyle(
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
            // Leyenda Manual
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(color: Colors.green, label: "Saludable (70%)"),
                const SizedBox(width: 15),
                _LegendItem(color: Colors.orange, label: "Medio (20%)"),
                const SizedBox(width: 15),
                _LegendItem(color: Colors.red, label: "Crítico (10%)"),
              ],
            ),

            const SizedBox(height: 30),

            // 3. LISTA DE ALERTA: STOCK BAJO
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
                TextButton(onPressed: () {}, child: const Text("Ver Todo")),
              ],
            ),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                _LowStockItem(
                  name: "Jeans 501 Azul",
                  sku: "SKU-1020",
                  stock: 2,
                  maxStock: 20,
                ),
                _LowStockItem(
                  name: "Camisa Blanca S",
                  sku: "SKU-3301",
                  stock: 1,
                  maxStock: 15,
                ),
                _LowStockItem(
                  name: "Zapatos Escolares #38",
                  sku: "SKU-5050",
                  stock: 3,
                  maxStock: 10,
                ),
              ],
            ),
          ],
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

  const _LowStockItem({
    required this.name,
    required this.sku,
    required this.stock,
    required this.maxStock,
  });

  @override
  Widget build(BuildContext context) {
    double percent = stock / maxStock;
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
