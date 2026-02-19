import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double tax;
  final double total;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.tax,
    required this.total,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Estado
  String _saleType = "Contado"; // Opciones: "Contado", "Fiado"
  final TextEditingController _clientCtrl = TextEditingController();
  final TextEditingController _depositCtrl = TextEditingController();

  // Cálculos dinámicos
  double get _depositAmount => double.tryParse(_depositCtrl.text) ?? 0.0;

  double get _pendingBalance {
    if (_saleType == "Contado") return 0.0;
    // Si es fiado: Total - Abono. Si el abono es mayor al total, es 0.
    double balance = widget.total - _depositAmount;
    return balance < 0 ? 0 : balance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Confirmar Venta",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CLIENTE
            const Text(
              "Cliente",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _clientCtrl,
              decoration: InputDecoration(
                hintText: "Nombre del cliente...",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 2. TIPO DE VENTA (SELECTOR)
            const Text(
              "Tipo de Venta",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _SaleTypeCard(
                  label: "CONTADO",
                  icon: Icons.monetization_on_outlined,
                  isSelected: _saleType == "Contado",
                  color: Colors.green,
                  onTap: () {
                    setState(() {
                      _saleType = "Contado";
                      _depositCtrl
                          .clear(); // Limpiamos abono si cambia a contado
                    });
                  },
                ),
                const SizedBox(width: 15),
                _SaleTypeCard(
                  label: "FIADO / CRÉDITO",
                  icon: Icons.history_edu_outlined,
                  isSelected: _saleType == "Fiado",
                  color: Colors.orange,
                  onTap: () => setState(() => _saleType = "Fiado"),
                ),
              ],
            ),

            // 3. SECCIÓN ABONO (SOLO SI ES FIADO)
            if (_saleType == "Fiado") ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Abono Inicial (Opcional)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _depositCtrl,
                      keyboardType: TextInputType.number,
                      // Actualizamos la UI cada vez que escribe para recalcular el saldo
                      onChanged: (val) => setState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.attach_money,
                          color: Colors.orange,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        hintText: "0.00",
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 30),

            // 4. RESUMEN FINANCIERO
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _SummaryRow(label: "Subtotal", value: widget.subtotal),
                  const SizedBox(height: 8),
                  _SummaryRow(label: "IVA", value: widget.tax),
                  const Divider(height: 24),

                  // TOTAL DE LA VENTA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "TOTAL VENTA",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        NumberFormat.simpleCurrency().format(widget.total),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  // INFORMACIÓN DE CRÉDITO (SI ES FIADO)
                  if (_saleType == "Fiado") ...[
                    const SizedBox(height: 12),
                    const Divider(color: Colors.orange, thickness: 1),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: "(-) Abono Inicial",
                      value: _depositAmount,
                      isNegative: true,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "SALDO PENDIENTE",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          NumberFormat.simpleCurrency().format(_pendingBalance),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 5. BOTÓN FINALIZAR
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _processSale,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _saleType == "Fiado"
                      ? Colors.orange[800]
                      : Colors.green[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                icon: Icon(
                  _saleType == "Fiado"
                      ? Icons.save_as
                      : Icons.check_circle_outline,
                  color: Colors.white,
                ),
                label: Text(
                  _saleType == "Fiado" ? "REGISTRAR FIADO" : "COBRAR CONTADO",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _processSale() {
    // Validaciones
    if (_saleType == "Fiado" && _clientCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "⚠️ Para ventas al fiado, el nombre del cliente es obligatorio",
          ),
        ),
      );
      return;
    }

    if (_depositAmount > widget.total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ El abono no puede ser mayor al total"),
        ),
      );
      return;
    }

    // DATOS FINALES PARA GUARDAR EN BASE DE DATOS
    // final saleData = {
    //   'client': _clientCtrl.text.isEmpty ? 'Consumidor Final' : _clientCtrl.text,
    //   'type': _saleType, // Contado o Fiado
    //   'total': widget.total,
    //   'deposit': _saleType == 'Fiado' ? _depositAmount : widget.total,
    //   'balance': _pendingBalance,
    //   'items': widget.cartItems
    // };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _saleType == "Fiado" ? Icons.pending_actions : Icons.check_circle,
              color: _saleType == "Fiado" ? Colors.orange : Colors.green,
              size: 60,
            ),
            const SizedBox(height: 20),
            Text(
              _saleType == "Fiado" ? "Crédito Registrado" : "Venta Exitosa",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              _saleType == "Fiado"
                  ? "Saldo pendiente: ${NumberFormat.simpleCurrency().format(_pendingBalance)}"
                  : "Cobro total realizado correctamente.",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("CERRAR"),
          ),
        ],
      ),
    );
  }
}

// --- WIDGETS AUXILIARES ---

class _SaleTypeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _SaleTypeCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.white,
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isSelected ? color : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isNegative;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700])),
        Text(
          NumberFormat.simpleCurrency().format(value),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isNegative ? Colors.red : Colors.black,
          ),
        ),
      ],
    );
  }
}
