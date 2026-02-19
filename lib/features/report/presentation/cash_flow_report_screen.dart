import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CashFlowReportScreen extends StatelessWidget {
  const CashFlowReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Auditoría de Cajas",
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
            // 1. GRÁFICO DE CUADRES (Diferencias)
            const Text(
              "Historial de Faltantes/Sobrantes",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Últimos 7 cierres",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => SideTitleWidget(
                          meta: meta, // <--- CORRECCIÓN DE LA LIBRERÍA
                          space: 4,
                          child: Text(
                            "Cierre ${value.toInt() + 1}",
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ),
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
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  barGroups: [
                    _makeGroup(0, 0, Colors.green), // Cuadre
                    _makeGroup(1, -20, Colors.red), // Faltante
                    _makeGroup(2, 0, Colors.green), // Cuadre
                    _makeGroup(3, 50, Colors.blue), // Sobrante
                    _makeGroup(4, -10, Colors.red), // Faltante
                    _makeGroup(5, 0, Colors.green), // Cuadre
                    _makeGroup(6, -5, Colors.red), // Faltante
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 2. INDICADORES DE RIESGO
            const Text(
              "Resumen de Auditoría",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _AuditCard(
                    label: "Cierres Perfectos",
                    value: "85%",
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _AuditCard(
                    label: "Faltante Acumulado",
                    value: "-\$ 35.00",
                    color: Colors.red,
                    icon: Icons.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 15,
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }
}

class _AuditCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _AuditCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
