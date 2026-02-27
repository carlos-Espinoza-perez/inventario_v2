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

            SectionCajaDashboard(state: state),
            SectionTransactionDashboard(
              transactions: state.ultimasTransacciones,
            ),
          ],
        ),
      ),
    );
  }
}
