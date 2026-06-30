import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:inventario_v2/core/db/models/report_models.dart';
import 'package:inventario_v2/core/presentation/mixins/app_bar_config_mixin.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:inventario_v2/features/sales/presentation/sales_dashboard_screen.dart';

final saleDetailProvider =
    FutureProvider.autoDispose.family<SaleDetailDrift, String>((
      ref,
      saleId,
    ) async {
  final db = ref.watch(driftDatabaseProvider);
  return db.salesDao.getSaleDetail(saleId);
});

class SaleDetailScreen extends ConsumerStatefulWidget {
  final String saleId;

  const SaleDetailScreen({super.key, required this.saleId});

  @override
  ConsumerState<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends ConsumerState<SaleDetailScreen>
    with AppBarConfigMixin {
  @override
  void configureAppBar() {
    ref.read(appBarProvider.notifier).setOptions(
      title: 'Detalle de Venta',
      showBackButton: true,
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.share_outlined),
          tooltip: 'Compartir Ticket',
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.print_outlined),
          tooltip: 'Imprimir',
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(configureAppBar);
  }

  @override
  Widget build(BuildContext context) {
    final saleAsync = ref.watch(saleDetailProvider(widget.saleId));

    return saleAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (sale) {
        final balance = sale.balancePendiente;
        final isCredit = sale.venta.tipoVenta == 'credito';
        final isPaid = sale.estaPagada;

        return Scaffold(
          backgroundColor: Colors.grey[100],
          bottomNavigationBar: (isCredit && !isPaid)
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
                      onPressed: () => _showAddPaymentModal(context, balance),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.attach_money, color: Colors.white),
                      label: const Text(
                        'REGISTRAR ABONO',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              : null,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isPaid
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isPaid
                                ? Colors.green.shade200
                                : Colors.orange.shade200,
                          ),
                        ),
                        child: Text(
                          isPaid ? 'COMPLETADO' : 'PENDIENTE DE PAGO',
                          style: TextStyle(
                            color: isPaid
                                ? Colors.green.shade800
                                : Colors.orange.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Valor Total Venta',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      Text(
                        NumberFormat.simpleCurrency().format(sale.venta.totalVenta),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 32,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        DateFormat(
                          'dd MMMM yyyy, hh:mm a',
                        ).format(sale.venta.fechaVenta),
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(title: 'Informacion del Cliente'),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        child: Icon(Icons.person, color: Colors.blue.shade700),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sale.cliente?.nombre ?? 'Cliente Desconocido',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Ticket: ${sale.venta.id.substring(0, 8).toUpperCase()}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          sale.venta.tipoVenta.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(title: 'Productos'),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sale.items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = sale.items[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${item.cantidad.toStringAsFixed(item.cantidad % 1 == 0 ? 0 : 2)}x',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          item.nombre,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: item.sku.isEmpty
                            ? null
                            : Text(
                                'SKU: ${item.sku}',
                                style: const TextStyle(fontSize: 11),
                              ),
                        trailing: Text(
                          NumberFormat.simpleCurrency().format(item.precioUnitario),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(title: 'Resumen Financiero'),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _SummaryRow(
                        label: 'Subtotal',
                        value: NumberFormat.simpleCurrency().format(
                          sale.venta.totalVenta,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        label: 'Impuestos',
                        value: NumberFormat.simpleCurrency().format(0),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(),
                      ),
                      _SummaryRow(
                        label: 'TOTAL A PAGAR',
                        value: NumberFormat.simpleCurrency().format(
                          sale.venta.totalVenta,
                        ),
                        isBold: true,
                        fontSize: 18,
                      ),
                      if (isCredit) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isPaid
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isPaid
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                            ),
                          ),
                          child: Column(
                            children: [
                              _SummaryRow(
                                label: 'Total Abonado (-)',
                                value: NumberFormat.simpleCurrency().format(
                                  sale.venta.totalPagado,
                                ),
                                textColor: Colors.green[700],
                              ),
                              const Divider(),
                              _SummaryRow(
                                label: 'SALDO PENDIENTE',
                                value: NumberFormat.simpleCurrency().format(
                                  balance,
                                ),
                                isBold: true,
                                textColor: isPaid
                                    ? Colors.green[700]
                                    : Colors.red[700],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isCredit) ...[
                  const SizedBox(height: 20),
                  _SectionTitle(title: 'Historial de Abonos'),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sale.pagos.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, indent: 50),
                      itemBuilder: (context, index) {
                        final payment = sale.pagos[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          title: Text(
                            NumberFormat.simpleCurrency().format(payment.monto),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            DateFormat('dd/MM/yyyy').format(payment.fecha),
                          ),
                          trailing: Text(
                            payment.metodoPago,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddPaymentModal(BuildContext context, double currentBalance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddPaymentModalContent(
        currentBalance: currentBalance,
        onSave: (amount) async {
          final db = ref.read(driftDatabaseProvider);
          await db.salesDao.registrarAbonoVenta(
            ventaId: widget.saleId,
            monto: amount,
          );
          if (!context.mounted) return;
          Navigator.pop(ctx);
          ref.invalidate(saleDetailProvider(widget.saleId));
          ref.invalidate(salesListProvider);
          ref.invalidate(dashboardProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Abono registrado con exito'),
              backgroundColor: Colors.green,
            ),
          );
        },
        onError: (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al registrar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        },
      ),
    );
  }
}

class _AddPaymentModalContent extends StatefulWidget {
  final double currentBalance;
  final Future<void> Function(double amount) onSave;
  final void Function(Object e) onError;

  const _AddPaymentModalContent({
    required this.currentBalance,
    required this.onSave,
    required this.onError,
  });

  @override
  State<_AddPaymentModalContent> createState() =>
      _AddPaymentModalContentState();
}

class _AddPaymentModalContentState extends State<_AddPaymentModalContent> {
  late final TextEditingController _amountCtrl;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Registrar Nuevo Abono',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Saldo actual: ${NumberFormat.simpleCurrency().format(widget.currentBalance)}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Monto a abonar',
              prefixIcon: Icon(Icons.attach_money),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(
                      _amountCtrl.text.replaceAll(',', '.'),
                    ) ??
                    0.0;
                if (amount <= 0 || amount > widget.currentBalance) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Monto invalido. Debe ser mayor a 0 y menor o igual a ${NumberFormat.simpleCurrency().format(widget.currentBalance)}',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                try {
                  await widget.onSave(amount);
                } catch (e) {
                  widget.onError(e);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
              ),
              child: const Text(
                'GUARDAR ABONO',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? textColor;
  final double fontSize;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.textColor,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: fontSize),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: fontSize,
            color: textColor ?? Colors.black,
          ),
        ),
      ],
    );
  }
}
