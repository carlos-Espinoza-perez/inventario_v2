import 'package:flutter/material.dart';
import 'package:inventario_v2/features/dashboard/presentation/widgets/transaction_item.dart';

class SectionTransactionDashboard extends StatelessWidget {
  const SectionTransactionDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        Text(
          "Ultimas transacciones",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TransactionItem(
          title: "Venta de producto",
          subtitle: "Ronald Perez - 07:20 AM",
          amount: "NIO 100",
          isIncome: true,
          icon: Icons.shopping_bag_outlined,
        ),
        TransactionItem(
          title: "Venta de producto",
          subtitle: "Carlos Espinoza - 07:20 AM",
          amount: "NIO 100",
          isIncome: true,
          icon: Icons.shopping_bag_outlined,
        ),
        TransactionItem(
          title: "Venta de producto",
          subtitle: "Pablo Espinoza - 07:20 AM",
          amount: "NIO 100",
          isIncome: true,
          icon: Icons.shopping_bag_outlined,
        ),
        TransactionItem(
          title: "Venta de producto",
          subtitle: "Pablo Espinoza - 07:20 AM",
          amount: "NIO 100",
          isIncome: true,
          icon: Icons.shopping_bag_outlined,
        ),
      ],
    );
  }
}
