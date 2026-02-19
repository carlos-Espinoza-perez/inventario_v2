import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FinancialReportScreen extends StatelessWidget {
  const FinancialReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos Dummy
    final double ingresos = 25000.00;
    final double costosVenta = 15000.00; // Lo que costó la mercadería
    final double gastosOp = 3500.00; // Luz, Agua, Renta
    final double utilidadNeta = ingresos - costosVenta - gastosOp;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Reporte Financiero",
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
            // 1. UTILIDAD NETA (RESULTADO FINAL)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade800, Colors.green.shade600],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
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
                    NumberFormat.simpleCurrency().format(utilidadNeta),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
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
                    child: const Text(
                      "Mes Actual",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 2. DESGLOSE (ESTADO DE RESULTADOS)
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
                    amount: ingresos,
                    color: Colors.blue,
                  ),
                  const Divider(),
                  _FinanceRow(
                    label: "Costo de Venta (-)",
                    amount: costosVenta,
                    color: Colors.red.shade300,
                  ),
                  _FinanceRow(
                    label: "Gastos Operativos (-)",
                    amount: gastosOp,
                    color: Colors.orange.shade300,
                  ),
                  const Divider(thickness: 2),
                  _FinanceRow(
                    label: "GANANCIA REAL (=)",
                    amount: utilidadNeta,
                    color: Colors.green,
                    isBold: true,
                    fontSize: 18,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 3. GRÁFICO DE GASTOS
            const Text(
              "Distribución de Gastos",
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
                      color: Colors.orange,
                      value: 40,
                      title: 'Renta',
                      radius: 50,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.blue,
                      value: 30,
                      title: 'Servicios',
                      radius: 50,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: 20,
                      title: 'Sueldos',
                      radius: 50,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.grey,
                      value: 10,
                      title: 'Otros',
                      radius: 50,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
