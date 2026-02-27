import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:inventario_v2/core/constants/app_enums.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/core/providers/database_provider.dart';
import 'package:inventario_v2/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:inventario_v2/features/sales/data/collections/caja_movimiento_extra_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/venta_collection.dart';
import 'package:inventario_v2/features/sales/data/repositories/caja_repository.dart';
import 'package:inventario_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:inventario_v2/features/sales/data/collections/historial_pago_collection.dart';

// ------------------------------------------------------------------
// Provider: gastos reales de la sesión actual desde Isar
// ------------------------------------------------------------------
final gastosActivosProvider = FutureProvider.autoDispose
    .family<List<CajaMovimientoExtraCollection>, String>((
      ref,
      cajaSesionId,
    ) async {
      final repo = ref.read(cajaRepositoryProvider);
      return await repo.obtenerMovimientosExtras(cajaSesionId);
    });

// ------------------------------------------------------------------
// Provider: ventas en efectivo de la caja activa (solo contado + abonos)
// ------------------------------------------------------------------
final ventasEfectivoProvider = FutureProvider.autoDispose.family<double, String>((
  ref,
  cajaSesionId,
) async {
  final isar = await ref.watch(isarDbProvider.future);
  // Todos los pagos o abonos (entradas de dinero) que sucedieron en esta sesión
  final pagos = await isar.historialPagoCollections
      .filter()
      .cajaSesionIdEqualTo(cajaSesionId)
      .findAll();

  double totalEfectivo = 0;
  for (var p in pagos) {
    totalEfectivo += p.montoPagado;
  }
  return totalEfectivo;
});

// ------------------------------------------------------------------
// Provider: ventas a crédito de la sesión (informativo)
// ------------------------------------------------------------------
final ventasCreditoProvider = FutureProvider.autoDispose.family<double, String>(
  (ref, cajaSesionId) async {
    final isar = await ref.watch(isarDbProvider.future);
    final ventas = await isar.ventaCollections
        .filter()
        .cajaSesionIdEqualTo(cajaSesionId)
        .estadoEqualTo(true)
        .tipoVentaEqualTo(TipoVenta.credito)
        .findAll();

    // Sumar el saldo pendiente, esto ya resta los abonos realizados
    return ventas.fold<double>(0.0, (sum, v) => sum + v.saldoPendiente);
  },
);

// ------------------------------------------------------------------
// Screen
// ------------------------------------------------------------------
class CashRegisterScreen extends ConsumerStatefulWidget {
  const CashRegisterScreen({super.key});

  @override
  ConsumerState<CashRegisterScreen> createState() => _CashRegisterScreenState();
}

class _CashRegisterScreenState extends ConsumerState<CashRegisterScreen> {
  final TextEditingController _expenseAmountCtrl = TextEditingController();
  final TextEditingController _expenseReasonCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _expenseAmountCtrl.dispose();
    _expenseReasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return dashboardAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (dashboardState) {
        final isRegisterOpen = dashboardState.cajaAbierta != null;
        final cajaSesionId = dashboardState.cajaAbierta?.serverId ?? '';
        final openingDate = dashboardState.cajaAbierta?.fechaApertura;
        final initialCash = dashboardState.cajaAbierta?.montoInicial ?? 0.0;

        Future.microtask(() {
          ref
              .read(appBarProvider.notifier)
              .setOptions(
                title: isRegisterOpen ? "Monitor de Caja" : "Caja Cerrada",
                showBackButton: true,
                actions: [
                  if (isRegisterOpen)
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
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
              );
        });

        return Scaffold(
          backgroundColor: Colors.grey[50],
          bottomNavigationBar: isRegisterOpen
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
          body: isRegisterOpen
              ? _buildOpenRegisterView(cajaSesionId, openingDate, initialCash)
              : _buildClosedRegisterView(),
        );
      },
    );
  }

  // --- VISTA: CAJA CERRADA ---
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
                  color: Colors.black.withValues(alpha: 0.05),
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

  // --- VISTA: CAJA ABIERTA (con datos reales de Isar) ---
  Widget _buildOpenRegisterView(
    String cajaSesionId,
    DateTime? openingDate,
    double initialCash,
  ) {
    final gastosAsync = ref.watch(gastosActivosProvider(cajaSesionId));
    final ventasEfectivoAsync = ref.watch(ventasEfectivoProvider(cajaSesionId));
    final ventasCreditoAsync = ref.watch(ventasCreditoProvider(cajaSesionId));
    final gananciasEsperadas =
        ref.watch(dashboardProvider).value?.gananciasEsperadas ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. TARJETA DE BALANCE
          gastosAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text("Error gastos: $e"),
            data: (gastos) {
              final totalGastos = gastos.fold(0.0, (sum, g) => sum + g.monto);

              return ventasEfectivoAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text("Error ventas: $e"),
                data: (salesCash) {
                  final balance = (initialCash + salesCash) - totalGastos;

                  return Container(
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
                          color: Colors.indigo.withValues(alpha: 0.4),
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
                          NumberFormat.simpleCurrency().format(balance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _BalanceDetailItem(
                                    label: "Ventas Efec. (+)",
                                    value: salesCash,
                                    icon: Icons.arrow_upward,
                                    color: Colors.green.shade200,
                                  ),
                                  _BalanceDetailItem(
                                    label: "Gastos (-)",
                                    value: totalGastos,
                                    icon: Icons.arrow_downward,
                                    color: Colors.orange.shade200,
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(
                                  color: Colors.white12,
                                  height: 1,
                                ),
                              ),
                              ventasCreditoAsync.when(
                                data: (credit) => Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _BalanceDetailItem(
                                      label: "Fiado / Crédito",
                                      value: credit,
                                      icon: Icons.receipt_long,
                                      color: Colors.blue.shade200,
                                    ),
                                    _BalanceDetailItem(
                                      label: "Ganancia Est.",
                                      value: gananciasEsperadas,
                                      icon: Icons.trending_up,
                                      color: Colors.yellow.shade200,
                                    ),
                                  ],
                                ),
                                loading: () => const SizedBox.shrink(),
                                error: (e, _) => const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
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
                    onPressed: _isSubmitting
                        ? null
                        : () => _addExpense(cajaSesionId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade800,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.output, size: 20),
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

          // 3. LISTA DE MOVIMIENTOS (desde Isar)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Gastos del Turno",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              if (openingDate != null)
                Text(
                  DateFormat('dd MMM - HH:mm').format(openingDate),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
            ],
          ),
          const SizedBox(height: 10),
          gastosAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text("Error: $e"),
            data: (gastos) {
              if (gastos.isEmpty) {
                return Container(
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
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: gastos.length,
                itemBuilder: (context, index) {
                  final expense = gastos[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
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
                        expense.motivo ?? 'Sin motivo',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        DateFormat('HH:mm').format(expense.ultimaActualizacion),
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                      trailing: Text(
                        "- ${NumberFormat.simpleCurrency().format(expense.monto)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- LÓGICA DE NEGOCIO ---

  Future<void> _openRegister() async {
    final user = ref.read(authControllerProvider.notifier).usuarioActual;
    final repo = ref.read(cajaRepositoryProvider);

    if (user != null) {
      await repo.abrirCaja(usuarioId: user.serverId, cajaId: 'caja_principal');
      ref.invalidate(dashboardProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Turno abierto correctamente"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _addExpense(String cajaSesionId) async {
    final double? amount = double.tryParse(_expenseAmountCtrl.text);
    final String reason = _expenseReasonCtrl.text.trim();

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Ingresa un monto válido")),
      );
      return;
    }
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Ingresa el motivo del gasto")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(authControllerProvider.notifier).usuarioActual;
      final repo = ref.read(cajaRepositoryProvider);

      await repo.registrarGasto(
        cajaSesionId: cajaSesionId,
        amount: amount,
        reason: reason,
        usuarioId: user?.serverId ?? 'unknown',
      );

      _expenseAmountCtrl.clear();
      _expenseReasonCtrl.clear();
      FocusManager.instance.primaryFocus?.unfocus();

      // Refrescar gastos y dashboard
      ref.invalidate(gastosActivosProvider(cajaSesionId));
      ref.invalidate(dashboardProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Gasto registrado"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showCloseRegisterDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Cerrar Turno?"),
        content: const Text(
          "Se calculará el balance final y la caja quedará inactiva.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final cajaAbierta = ref
                  .read(dashboardProvider)
                  .value
                  ?.cajaAbierta;
              final user = ref
                  .read(authControllerProvider.notifier)
                  .usuarioActual;
              final repo = ref.read(cajaRepositoryProvider);

              if (cajaAbierta != null && user != null) {
                await repo.cerrarCaja(
                  cajaSesionId: cajaAbierta.serverId,
                  usuarioCierreId: user.serverId,
                );
                ref.invalidate(dashboardProvider);
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("✅ Turno cerrado correctamente"),
                  ),
                );
              }
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
