import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inventario_v2/features/dashboard/presentation/widgets/card_info_dashboard.dart';
import 'package:inventario_v2/features/dashboard/presentation/widgets/section_caja_dashboard.dart';
import 'package:inventario_v2/features/dashboard/presentation/widgets/section_transaction_dashboard.dart';

class ContentViewDashboard extends StatelessWidget {
  const ContentViewDashboard({super.key});

  @override
  Widget build(BuildContext context) {
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
              amount: "NIO 100",
              icon: Icons.inventory_2_outlined,
              color: Colors.cyan.shade800,
            ),

            const SizedBox(height: 12),

            CardInfoDashboard(
              title: "Monto total de fiados",
              amount: "NIO 100",
              icon: Icons.inventory_2_outlined,
              color: Colors.red,
              isOutlined: true,
              buttonText: "Ver fiados",
              onButtonTap: () {
                print("Ver fiados");
                context.go('/fiados');
              },
            ),

            const SectionCajaDashboard(),
            const SectionTransactionDashboard(),
          ],
        ),
      ),
    );
  }
}
