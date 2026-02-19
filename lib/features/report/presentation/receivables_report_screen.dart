import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReceivablesReportScreen extends StatelessWidget {
  const ReceivablesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos Mock
    final List<Map<String, dynamic>> debtors = [
      {
        'name': 'Juan Pérez',
        'phone': '8888-8888',
        'debt': 1500.00,
        'lastPay': DateTime.now().subtract(const Duration(days: 5)),
      },
      {
        'name': 'Tienda La Esperanza',
        'phone': '2222-2222',
        'debt': 5200.50,
        'lastPay': DateTime.now().subtract(const Duration(days: 20)),
      },
      {
        'name': 'Carlos Rivas',
        'phone': '8765-4321',
        'debt': 300.00,
        'lastPay': DateTime.now().subtract(const Duration(days: 2)),
      },
    ];

    final double totalDebt = debtors.fold(
      0,
      (sum, item) => sum + (item['debt'] as double),
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Cuentas por Cobrar",
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
            // 1. TOTAL PENDIENTE
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.money_off,
                      color: Colors.red.shade700,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Total en la Calle (Fiado)",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        NumberFormat.simpleCurrency().format(totalDebt),
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 2. LISTA DE DEUDORES
            const Text(
              "Clientes con Saldo Pendiente",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: debtors.length,
              itemBuilder: (context, index) {
                final client = debtors[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueGrey.shade50,
                      child: Text(
                        client['name'][0],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade700,
                        ),
                      ),
                    ),
                    title: Text(
                      client['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Último abono: ${DateFormat('dd MMM').format(client['lastPay'])}",
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          NumberFormat.simpleCurrency().format(client['debt']),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          "Pendiente",
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Ir a detalle del cliente o cobrar
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
