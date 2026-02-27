import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventario_v2/core/presentation/widgets/custom_button.dart';
import 'package:inventario_v2/features/dashboard/presentation/widgets/card_info_dashboard.dart';
import 'package:inventario_v2/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:inventario_v2/features/sales/presentation/cash_register_screen.dart';

class SectionCajaDashboard extends StatelessWidget {
  final DashboardState state;

  const SectionCajaDashboard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency();
    final isCajaAbierta = state.cajaAbierta != null;

    final dateCaja = isCajaAbierta
        ? DateFormat(
            'dd/MM/yyyy HH:mm a',
          ).format(state.cajaAbierta!.fechaApertura)
        : "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCajaAbierta ? "Ventas en curso" : "Caja Cerrada",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isCajaAbierta
                      ? "Abierta el $dateCaja"
                      : "Abre caja para comenzar",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            const Spacer(),

            CustomButton(
              text: isCajaAbierta ? "Cerrar caja" : "Abrir caja",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CashRegisterScreen(),
                  ),
                );
              },
              color: isCajaAbierta ? Colors.cyan : Colors.grey,
              isOutlined: true,
              icon: Icons.payments_rounded,
            ),
          ],
        ),

        const SizedBox(height: 10),

        GridView.count(
          crossAxisCount: 2,

          crossAxisSpacing: 16,
          mainAxisSpacing: 16,

          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),

          childAspectRatio: 2,

          children: [
            CardInfoDashboard(
              title: "Total de ventas",
              amount: currencyFormat.format(state.ventasEnCurso),
              icon: Icons.point_of_sale_outlined,
              color: Colors.grey,
              isOutlined: true,
              hideIcon: true,
            ),
            CardInfoDashboard(
              title: "Ganancias esperadas",
              amount: currencyFormat.format(state.gananciasEsperadas),
              icon: Icons.trending_up,
              color: Colors.grey,
              isOutlined: true,

              hideIcon: true,
            ),
          ],
        ),
      ],
    );
  }
}
