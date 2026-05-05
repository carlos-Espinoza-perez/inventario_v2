class DashboardTopProduct {
  final String productoId;
  final String nombre;
  final double cantidadVendida;
  final double totalVendido;

  const DashboardTopProduct({
    required this.productoId,
    required this.nombre,
    required this.cantidadVendida,
    required this.totalVendido,
  });
}

class DashboardLowStockItem {
  final String inventarioId;
  final String productoId;
  final String nombre;
  final String sku;
  final double cantidadActual;
  final double costoPromedio;

  const DashboardLowStockItem({
    required this.inventarioId,
    required this.productoId,
    required this.nombre,
    required this.sku,
    required this.cantidadActual,
    required this.costoPromedio,
  });
}

class RecentTransactionDrift {
  final String title;
  final String subtitle;
  final double amount;
  final bool isIncome;
  final DateTime date;

  const RecentTransactionDrift({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
    required this.date,
  });
}
