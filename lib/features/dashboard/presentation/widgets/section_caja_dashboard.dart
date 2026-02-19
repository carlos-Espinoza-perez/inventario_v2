import 'package:flutter/material.dart';
import 'package:inventario_v2/core/presentation/widgets/custom_button.dart';
import 'package:inventario_v2/features/dashboard/presentation/widgets/card_info_dashboard.dart';

class SectionCajaDashboard extends StatelessWidget {
  const SectionCajaDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Ventas en curso",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Del 27/12/2025 a hoy",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            const Spacer(),

            const CustomButton(
              text: "Cerrar caja",
              onPressed: null,
              color: Colors.cyan,
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
              amount: "NIO 100",
              icon: Icons.inventory_2_outlined,
              color: Colors.grey,
              isOutlined: true,
              hideIcon: true,
            ),
            CardInfoDashboard(
              title: "Ganancias esperadas",
              amount: "NIO 100",
              icon: Icons.inventory_2_outlined,
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
