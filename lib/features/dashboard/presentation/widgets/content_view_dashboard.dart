import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:inventario_v2/features/dashboard/presentation/widgets/card_info_dashboard.dart';
import 'package:inventario_v2/features/dashboard/presentation/widgets/section_caja_dashboard.dart';
import 'package:inventario_v2/features/dashboard/presentation/widgets/section_transaction_dashboard.dart';
import 'package:inventario_v2/features/dashboard/presentation/providers/dashboard_provider.dart';

class ContentViewDashboard extends StatelessWidget {
  final DashboardState state;

  const ContentViewDashboard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency();

    // Animación de entrada suave
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardInfoDashboard(
              title: "Monto total de inventario",
              amount: currencyFormat.format(state.montoTotalInventario),
              icon: Icons.inventory_2_outlined,
              color: Colors.cyan.shade800,
            ),

            const SizedBox(height: 12),

            CardInfoDashboard(
              title: "Monto total de fiados",
              amount: currencyFormat.format(state.montoTotalFiados),
              icon: Icons.receipt_long_outlined,
              color: Colors.red,
              isOutlined: true,
              buttonText: "Ver fiados",
              onButtonTap: () {
                context.go('/sales');
              },
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: CardInfoDashboard(
                    title: "Ventas del dia",
                    amount: currencyFormat.format(state.ventasDelDia),
                    icon: Icons.today_outlined,
                    color: Colors.blue.shade700,
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CardInfoDashboard(
                    title: "Stock bajo",
                    amount: state.stockBajo.toString(),
                    icon: Icons.warning_amber_rounded,
                    color: Colors.orange.shade700,
                    isOutlined: true,
                  ),
                ),
              ],
            ),

            SectionCajaDashboard(state: state),
            if (state.productosMasVendidos.isNotEmpty) ...[
              const SizedBox(height: 22),
              const Text(
                "Productos mas vendidos",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...state.productosMasVendidos.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: Text(
                      item.cantidadVendida.toStringAsFixed(0),
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: Text(
                    item.nombre,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    "Total vendido: ${currencyFormat.format(item.totalVendido)}",
                  ),
                ),
              ),
            ],
            SectionTransactionDashboard(
              transactions: state.ultimasTransacciones,
            ),
          ],
        ),
      ),
    );
  }
}
