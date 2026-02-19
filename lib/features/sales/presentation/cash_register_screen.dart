import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CashRegisterScreen extends StatefulWidget {
  const CashRegisterScreen({super.key});

  @override
  State<CashRegisterScreen> createState() => _CashRegisterScreenState();
}

class _CashRegisterScreenState extends State<CashRegisterScreen> {
  // ESTADO DE LA CAJA (Simulado)
  bool _isRegisterOpen = false;

  // CONTROLADORES
  final TextEditingController _expenseAmountCtrl = TextEditingController();
  final TextEditingController _expenseReasonCtrl = TextEditingController();

  // DATOS DE CAJA
  DateTime? _openingDate;

  // METRICAS DE MOVIMIENTOS (MOCK - Esto vendría de tu DB Isar)
  // 1. Dinero REAL (Afecta el arqueo)
  double _initialCash = 0.0; // Ahora inicia en 0 por defecto
  double _currentSalesCash = 0.0; // Ventas cobradas en efectivo

  // 2. Métricas INFORMATIVAS (No suman al efectivo físico pero son vitales)
  double _currentSalesCredit = 0.0; // Ventas al Fiado
  double _estimatedProfit = 0.0; // Ganancia (Venta - Costo)

  final List<Map<String, dynamic>> _registeredExpenses = [];

  // CÁLCULOS
  double get _totalExpenses => _registeredExpenses.fold(
    0.0,
    (sum, item) => sum + (item['amount'] as double),
  );

  // El dinero que DEBERÍA haber físicamente en el cajón
  double get _currentBalance =>
      (_initialCash + _currentSalesCash) - _totalExpenses;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _isRegisterOpen ? "Monitor de Caja" : "Caja Cerrada",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (_isRegisterOpen)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.fiber_manual_record,
                    size: 10,
                    color: Colors.green,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "EN CURSO",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),

      bottomNavigationBar: _isRegisterOpen
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
                  onPressed: _showCloseRegisterDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.lock_outline, color: Colors.white),
                  label: const Text(
                    "REALIZAR CORTE",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            )
          : null,

      body: _isRegisterOpen
          ? _buildOpenRegisterView()
          : _buildClosedRegisterView(),
    );
  }

  // --- VISTA 1: CAJA CERRADA (SIMPLIFICADA) ---
  Widget _buildClosedRegisterView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.point_of_sale,
              size: 80,
              color: Colors.blueGrey.shade300,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "Turno Cerrado",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Inicia un nuevo periodo para comenzar a registrar ventas y movimientos.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 40),

          // BOTÓN DE APERTURA SIN MONTO
          SizedBox(
            width: 200,
            height: 55,
            child: ElevatedButton(
              onPressed: _openRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: const Text(
                "ABRIR CAJA AHORA",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- VISTA 2: DASHBOARD CAJA ABIERTA ---
  Widget _buildOpenRegisterView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. TARJETA DE SALDO Y MÉTRICAS
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade900, Colors.blue.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "EFECTIVO EN CAJA (TEÓRICO)",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  NumberFormat.simpleCurrency().format(_currentBalance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 20),

                // GRID DE MÉTRICAS DETALLADAS
                // Usamos un Wrap o Column/Row anidado para organizar la info extra
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      // Fila 1: Entradas y Salidas de Efectivo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _BalanceDetailItem(
                            label: "Ventas Efec. (+)",
                            value: _currentSalesCash,
                            icon: Icons.arrow_upward,
                            color: Colors.green.shade200,
                          ),
                          _BalanceDetailItem(
                            label: "Gastos (-)",
                            value: _totalExpenses,
                            icon: Icons.arrow_downward,
                            color: Colors.orange.shade200,
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(color: Colors.white12, height: 1),
                      ),

                      // Fila 2: Métricas de Negocio (Ganancia y Fiado)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _BalanceDetailItem(
                            label: "Fiado / Crédito",
                            value: _currentSalesCredit,
                            icon: Icons.receipt_long,
                            color: Colors.blue.shade200,
                          ),
                          _BalanceDetailItem(
                            label: "Ganancia Est.",
                            value: _estimatedProfit,
                            icon: Icons.trending_up,
                            color: Colors.yellow.shade200,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // 2. REGISTRAR GASTO RÁPIDO
          const Text(
            "Registrar Salida / Gasto",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _expenseAmountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Monto",
                          prefixIcon: const Icon(Icons.attach_money, size: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _expenseReasonCtrl,
                        decoration: InputDecoration(
                          labelText: "Motivo",
                          hintText: "Ej. Almuerzo",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: _addExpense,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade800,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.output, size: 20),
                    label: const Text(
                      "REGISTRAR SALIDA",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // 3. LISTA DE MOVIMIENTOS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Últimos Movimientos",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              if (_openingDate != null)
                Text(
                  DateFormat('dd MMM - HH:mm').format(_openingDate!),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
            ],
          ),
          const SizedBox(height: 10),

          if (_registeredExpenses.isEmpty)
            Container(
              padding: const EdgeInsets.all(30),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.history, color: Colors.grey[300], size: 40),
                  const SizedBox(height: 5),
                  Text(
                    "Sin gastos registrados",
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _registeredExpenses.length,
              itemBuilder: (context, index) {
                final expense =
                    _registeredExpenses[(_registeredExpenses.length - 1) -
                        index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.shade50,
                      radius: 18,
                      child: Icon(
                        Icons.arrow_downward,
                        color: Colors.red.shade800,
                        size: 16,
                      ),
                    ),
                    title: Text(
                      expense['reason'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('HH:mm').format(expense['time']),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    trailing: Text(
                      "- ${NumberFormat.simpleCurrency().format(expense['amount'])}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- LÓGICA DE NEGOCIO ---

  void _openRegister() {
    // Ya no pedimos monto, iniciamos directo
    setState(() {
      _initialCash =
          0.0; // Inicia en 0 o se cargaría el remanente del día anterior desde BD
      _openingDate = DateTime.now();
      _isRegisterOpen = true;

      // Simulamos datos cargados de las ventas del día actual
      _currentSalesCash = 4500.00;
      _currentSalesCredit = 1200.00; // Ventas que no entraron en caja
      _estimatedProfit = 1500.00; // Ganancia estimada de todas las ventas

      _registeredExpenses.clear();
    });
  }

  void _addExpense() {
    final double? amount = double.tryParse(_expenseAmountCtrl.text);
    final String reason = _expenseReasonCtrl.text;

    if (amount == null || amount <= 0) return;
    if (reason.isEmpty) return;

    setState(() {
      _registeredExpenses.add({
        'amount': amount,
        'reason': reason,
        'time': DateTime.now(),
      });
      _expenseAmountCtrl.clear();
      _expenseReasonCtrl.clear();
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  void _showCloseRegisterDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Cerrar Turno?"),
        content: const Text(
          "Se guardará el balance actual y la caja quedará inactiva.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _isRegisterOpen = false;
                // Aquí guardarías el histórico en la BD
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ Turno cerrado correctamente")),
              );
            },
            child: const Text(
              "CONFIRMAR",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget pequeño para detalles dentro de la tarjeta azul
class _BalanceDetailItem extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color? color;

  const _BalanceDetailItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color ?? Colors.white70, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: color ?? Colors.white70, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          NumberFormat.compactSimpleCurrency().format(value),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
