import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CashRegisterDetailScreen extends StatelessWidget {
  final String sessionId;

  // En producción, usarías el sessionId para buscar en la BD (Isar).
  const CashRegisterDetailScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    // --- DATOS MOCK (Simulación de un cierre histórico) ---
    final Map<String, dynamic> report = {
      'id': sessionId,
      'openedAt': DateTime.now().subtract(const Duration(days: 1, hours: 10)),
      'closedAt': DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      'user': 'Juan Pérez',

      // CAJA FÍSICA
      'initialCash': 0.0,
      'salesCash': 5400.00, // Lo que entró en efectivo
      'expensesTotal': 250.00, // Total gastos
      'expectedCash': 5150.00, // (0 + 5400 - 250)
      'countedCash': 5140.00, // Lo que el cajero contó
      'difference': -10.00, // Faltante de 10 pesos
      // NEGOCIO (Informativo)
      'salesCredit': 1200.00, // Fiado
      'salesCard': 2500.00, // Tarjeta
      'estimatedProfit': 1800.00, // Ganancia del turno
      // LISTA DE GASTOS
      'expensesList': [
        {
          'reason': 'Pago de Agua',
          'amount': 200.0,
          'time': DateTime.now().subtract(const Duration(days: 1, hours: 8)),
        },
        {
          'reason': 'Artículos Limpieza',
          'amount': 50.0,
          'time': DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        },
      ],
    };

    final double diff = report['difference'];
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (diff == 0) {
      statusColor = Colors.green;
      statusText = "CUADRE PERFECTO";
      statusIcon = Icons.check_circle_outline;
    } else if (diff > 0) {
      statusColor = Colors.blue;
      statusText = "SOBRANTE DE CAJA";
      statusIcon = Icons.arrow_circle_up;
    } else {
      statusColor = Colors.red;
      statusText = "FALTANTE DE CAJA";
      statusIcon = Icons.error_outline;
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Reporte de Cierre #${report['id']}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined),
            tooltip: "Compartir Reporte",
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.print_outlined),
            tooltip: "Imprimir",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TARJETA DE RESULTADO DEL CIERRE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  Icon(statusIcon, size: 40, color: statusColor),
                  const SizedBox(height: 10),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (diff != 0) ...[
                    const SizedBox(height: 5),
                    Text(
                      "${diff > 0 ? '+' : ''}${NumberFormat.simpleCurrency().format(diff)}",
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 2. INFORMACIÓN GENERAL
            _SectionHeader(title: "Detalles del Turno"),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _InfoRow("Cajero Responsable", report['user']),
                  const Divider(),
                  _InfoRow(
                    "Apertura",
                    DateFormat(
                      'dd MMM yyyy - hh:mm a',
                    ).format(report['openedAt']),
                  ),
                  _InfoRow(
                    "Cierre",
                    DateFormat(
                      'dd MMM yyyy - hh:mm a',
                    ).format(report['closedAt']),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 3. BALANCE DE EFECTIVO (LA MATEMÁTICA)
            _SectionHeader(title: "Balance de Efectivo"),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _MathRow(
                    label: "Fondo Inicial",
                    amount: report['initialCash'],
                    operator: "+",
                  ),
                  _MathRow(
                    label: "Ventas Efectivo",
                    amount: report['salesCash'],
                    operator: "+",
                  ),
                  _MathRow(
                    label: "Gastos / Salidas",
                    amount: report['expensesTotal'],
                    operator: "-",
                    isNegative: true,
                  ),
                  const Divider(thickness: 1.5),
                  _MathRow(
                    label: "Efectivo Esperado",
                    amount: report['expectedCash'],
                    isResult: true,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _MathRow(
                      label: "Efectivo Contado (Real)",
                      amount: report['countedCash'],
                      isBold: true,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 4. ESTADÍSTICAS DEL NEGOCIO (LO QUE PEDISTE)
            _SectionHeader(title: "Métricas del Negocio"),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: "Ventas a Crédito",
                    amount: report['salesCredit'],
                    icon: Icons.credit_score,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _StatCard(
                    label: "Ganancia Neta",
                    amount: report['estimatedProfit'],
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // 5. DETALLE DE GASTOS
            _SectionHeader(title: "Gastos Registrados"),
            if ((report['expensesList'] as List).isEmpty)
              const Text(
                "No hubo gastos en este turno.",
                style: TextStyle(color: Colors.grey),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: (report['expensesList'] as List).length,
                  separatorBuilder: (c, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = report['expensesList'][index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.arrow_downward,
                        color: Colors.red,
                        size: 18,
                      ),
                      title: Text(
                        item['reason'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        DateFormat('hh:mm a').format(item['time']),
                      ),
                      trailing: Text(
                        "- ${NumberFormat.simpleCurrency().format(item['amount'])}",
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS AUXILIARES DE DISEÑO ---

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _MathRow extends StatelessWidget {
  final String label;
  final double amount;
  final String? operator;
  final bool isResult;
  final bool isNegative;
  final bool isBold;

  const _MathRow({
    required this.label,
    required this.amount,
    this.operator,
    this.isResult = false,
    this.isNegative = false,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (operator != null)
            SizedBox(
              width: 20,
              child: Text(
                operator!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: (isResult || isBold)
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: isResult ? 16 : 14,
              ),
            ),
          ),
          Text(
            NumberFormat.simpleCurrency().format(amount),
            style: TextStyle(
              fontWeight: (isResult || isBold)
                  ? FontWeight.bold
                  : FontWeight.w500,
              fontSize: isResult ? 16 : 14,
              color: isNegative ? Colors.red : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(
            NumberFormat.compactSimpleCurrency().format(amount),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
