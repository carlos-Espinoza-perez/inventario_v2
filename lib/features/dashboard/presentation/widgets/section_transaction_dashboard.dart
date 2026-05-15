import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventario_v2/features/dashboard/presentation/widgets/transaction_item.dart';
import 'package:inventario_v2/features/dashboard/presentation/providers/dashboard_provider.dart';

class SectionTransactionDashboard extends StatelessWidget {
  final List<TransactionItemModel> transactions;

  const SectionTransactionDashboard({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) return const SizedBox.shrink();

    final currencyFormat = NumberFormat.simpleCurrency();
    final dateFormat = DateFormat('dd MMM - hh:mm a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        const Text(
          "Últimas transacciones",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...transactions.map((tx) {
          final subtitleDate = "${tx.subtitle} - ${dateFormat.format(tx.date)}";
          return TransactionItem(
            title: tx.title,
            subtitle: subtitleDate,
            amount: currencyFormat.format(tx.amount),
            isIncome: tx.isIncome,
            icon: tx.isIncome ? Icons.trending_up : Icons.trending_down,
          );
        }),
      ],
    );
  }
}
