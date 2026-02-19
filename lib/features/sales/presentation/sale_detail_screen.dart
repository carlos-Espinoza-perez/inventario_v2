import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SaleDetailScreen extends StatelessWidget {
  final String saleId;

  // En una app real, usarías el saleId para buscar en la BD.
  // Aquí simularé que recibimos los datos de una venta "FIADA" para mostrarte el caso más completo.
  const SaleDetailScreen({super.key, required this.saleId});

  @override
  Widget build(BuildContext context) {
    // --- DATOS MOCK (SIMULACIÓN DE UNA VENTA A CRÉDITO) ---
    final Map<String, dynamic> sale = {
      'id': '#VEN-001',
      'date': DateTime.now(),
      'client': 'Juan Pérez',
      'type': 'Fiado', // "Contado" o "Fiado"
      'total': 5000.00,
      'subtotal': 4347.82,
      'tax': 652.18,
      'paidAmount':
          2000.00, // Lo que ha pagado hasta hoy (Abono inicial + otros abonos)
      'status': 'Pendiente', // "Pagado" o "Pendiente"
      'items': [
        {'qty': 2, 'name': 'Camisa Manga Larga', 'price': 500.00},
        {'qty': 4, 'name': 'Pantalón Jingo', 'price': 1000.00},
      ],
      'payments': [
        {
          'date': DateTime.now().subtract(const Duration(days: 5)),
          'amount': 1000.0,
          'note': 'Abono Inicial',
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 2)),
          'amount': 1000.0,
          'note': 'Abono Semanal',
        },
      ],
    };

    final double balance = sale['total'] - sale['paidAmount'];
    final bool isCredit = sale['type'] == 'Fiado';
    final bool isPaid = balance <= 0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Detalle de Venta",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined),
            tooltip: "Compartir Ticket",
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.print_outlined),
            tooltip: "Imprimir",
          ),
        ],
      ),

      // BOTÓN DE ABONAR (SOLO SI HAY DEUDA)
      bottomNavigationBar: (isCredit && !isPaid)
          ? Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Abrir modal para registrar nuevo abono
                    _showAddPaymentModal(context, balance);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.attach_money, color: Colors.white),
                  label: const Text(
                    "REGISTRAR ABONO",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          : null,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TARJETA DE ESTADO (ENCABEZADO)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isPaid
                            ? Colors.green.shade200
                            : Colors.orange.shade200,
                      ),
                    ),
                    child: Text(
                      isPaid ? "COMPLETADO" : "PENDIENTE DE PAGO",
                      style: TextStyle(
                        color: isPaid
                            ? Colors.green.shade800
                            : Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Valor Total Venta",
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  Text(
                    NumberFormat.simpleCurrency().format(sale['total']),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 32,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    DateFormat('dd MMMM yyyy, hh:mm a').format(sale['date']),
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. DATOS DEL CLIENTE
            _SectionTitle(title: "Información del Cliente"),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: Icon(Icons.person, color: Colors.blue.shade700),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sale['client'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Ticket: ${sale['id']}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Tipo de Venta Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      sale['type'].toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. LISTA DE PRODUCTOS
            _SectionTitle(title: "Productos"),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: (sale['items'] as List).length,
                separatorBuilder: (c, i) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = sale['items'][index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${item['qty']}x",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      item['name'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Text(
                      NumberFormat.simpleCurrency().format(item['price']),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // 4. RESUMEN FINANCIERO (TOTALES Y SALDOS)
            _SectionTitle(title: "Resumen Financiero"),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _SummaryRow(
                    label: "Subtotal",
                    value: NumberFormat.simpleCurrency().format(
                      sale['subtotal'],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: "Impuestos",
                    value: NumberFormat.simpleCurrency().format(sale['tax']),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  _SummaryRow(
                    label: "TOTAL A PAGAR",
                    value: NumberFormat.simpleCurrency().format(sale['total']),
                    isBold: true,
                    fontSize: 18,
                  ),

                  // SI ES FIADO, MOSTRAMOS EL DESGLOSE DE DEUDA
                  if (isCredit) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isPaid
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isPaid
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                        ),
                      ),
                      child: Column(
                        children: [
                          _SummaryRow(
                            label: "Total Abonado (-)",
                            value: NumberFormat.simpleCurrency().format(
                              sale['paidAmount'],
                            ),
                            textColor: Colors.green[700],
                          ),
                          const Divider(),
                          _SummaryRow(
                            label: "SALDO PENDIENTE",
                            value: NumberFormat.simpleCurrency().format(
                              balance,
                            ),
                            isBold: true,
                            textColor: isPaid
                                ? Colors.green[700]
                                : Colors.red[700],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 5. HISTORIAL DE PAGOS (SOLO SI ES FIADO)
            if (isCredit) ...[
              const SizedBox(height: 20),
              _SectionTitle(title: "Historial de Abonos"),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: (sale['payments'] as List).length,
                  separatorBuilder: (c, i) =>
                      const Divider(height: 1, indent: 50),
                  itemBuilder: (context, index) {
                    final payment = sale['payments'][index];
                    return ListTile(
                      leading: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                      title: Text(
                        NumberFormat.simpleCurrency().format(payment['amount']),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy').format(payment['date']),
                      ),
                      trailing: Text(
                        payment['note'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
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
    );
  }

  void _showAddPaymentModal(BuildContext context, double currentBalance) {
    final TextEditingController amountCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Registrar Nuevo Abono",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Saldo actual: ${NumberFormat.simpleCurrency().format(currentBalance)}",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: "Monto a abonar",
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // AQUÍ GUARDARÍAS EL ABONO EN LA BD Y ACTUALIZARÍAS LA VENTA
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Abono registrado correctamente"),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                ),
                child: const Text(
                  "GUARDAR ABONO",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS UI PEQUEÑOS ---

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? textColor;
  final double fontSize;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.textColor,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: fontSize),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: fontSize,
            color: textColor ?? Colors.black,
          ),
        ),
      ],
    );
  }
}
