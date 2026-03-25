import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'package:inventario_v2/core/providers/database_provider.dart';
import 'package:inventario_v2/features/sales/data/collections/venta_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/detalle_venta_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/cliente_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/producto_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/historial_pago_collection.dart';
import 'package:inventario_v2/core/constants/app_enums.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/features/sales/presentation/sales_dashboard_screen.dart';
import 'package:inventario_v2/features/dashboard/presentation/providers/dashboard_provider.dart';

final saleDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((
  ref,
  saleId,
) async {
  final isar = await ref.watch(isarDbProvider.future);

  // 1. Obtener Venta
  final venta = await isar.ventaCollections
      .filter()
      .serverIdEqualTo(saleId)
      .findFirst();
  if (venta == null) throw Exception("Venta no encontrada");

  // 2. Obtener Cliente
  final cliente = await isar.clienteCollections
      .filter()
      .serverIdEqualTo(venta.clienteId)
      .findFirst();

  // 3. Obtener Detalles (Items) y mapear con nombre de producto
  final detalles = await isar.detalleVentaCollections
      .filter()
      .ventaIdEqualTo(venta.serverId)
      .findAll();
  List<Map<String, dynamic>> items = [];

  for (var d in detalles) {
    final producto = await isar.productoCollections
        .filter()
        .serverIdEqualTo(d.productoId)
        .findFirst();
    items.add({
      'name': producto?.nombre ?? 'Producto Desconocido',
      'qty': d.cantidad,
      'price': d.precioUnitario,
      'subtotal': d.subTotal,
    });
  }

  // 4. Obtener Pagos
  final pagos = await isar.historialPagoCollections
      .filter()
      .ventaIdEqualTo(venta.serverId)
      .sortByFechaRegistroDesc()
      .findAll();
  List<Map<String, dynamic>> paymentsList = pagos
      .map(
        (p) => {
          'date': p.fechaRegistro,
          'amount': p.montoPagado,
          'note': p.metodoDePago.name,
        },
      )
      .toList();

  return {
    'id': venta.serverId.substring(0, 8).toUpperCase(),
    'fullId': venta.serverId, // Para operaciones
    'date': venta.fechaVenta,
    'client': cliente?.nombre ?? 'Cliente Desconocido',
    'type': venta.tipoVenta == TipoVenta.credito ? 'Fiado' : 'Contado',
    'total': venta.totalVenta,
    'subtotal':
        venta.totalVenta, // Simplificado, si tienes impuestos calcúlalos
    'tax': 0.0, // Ajustar si guardas impuestos
    'paidAmount': venta.totalPagado,
    'status': venta.estadoPago == EstadoPago.pagado ? 'Pagado' : 'Pendiente',
    'items': items,
    'payments': paymentsList,
  };
});

class SaleDetailScreen extends ConsumerStatefulWidget {
  final String saleId;

  const SaleDetailScreen({super.key, required this.saleId});

  @override
  ConsumerState<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends ConsumerState<SaleDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(appBarProvider.notifier)
          .setOptions(
            title: "Detalle de Venta",
            showBackButton: true,
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share_outlined),
                tooltip: "Compartir Ticket",
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.print_outlined),
                tooltip: "Imprimir",
              ),
            ],
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final saleAsync = ref.watch(saleDetailProvider(widget.saleId));

    return saleAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text("Error: $err"))),
      data: (sale) {
        final double balance =
            (sale['total'] as double) - (sale['paidAmount'] as double);
        final bool isCredit = sale['type'] == 'Fiado';
        final bool isPaid = balance <= 0.01;

        return Scaffold(
          backgroundColor: Colors.grey[100],

          // BOTÓN DE ABONAR (SOLO SI HAY DEUDA)
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
                      onPressed: () {
                        // Abrir modal para registrar nuevo abono
                        _showAddPaymentModal(context, balance);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.attach_money, color: Colors.white),
                      label: const Text(
                        "REGISTRAR ABONO",
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
                // 1. TARJETA DE ESTADO (ENCABEZADO)
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
                          isPaid ? "COMPLETADO" : "PENDIENTE DE PAGO",
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
                        "Valor Total Venta",
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      Text(
                        NumberFormat.simpleCurrency().format(sale['total']),
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
                        ).format(sale['date']),
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. DATOS DEL CLIENTE
                _SectionTitle(title: "Información del Cliente"),
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
                            sale['client'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Ticket: ${sale['id']}",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Tipo de Venta Badge
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
                          sale['type'].toUpperCase(),
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

                // 3. LISTA DE PRODUCTOS
                _SectionTitle(title: "Productos"),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: (sale['items'] as List).length,
                    separatorBuilder: (c, i) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = sale['items'][index];
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
                            "${item['qty']}x",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          item['name'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: Text(
                          NumberFormat.simpleCurrency().format(item['price']),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // 4. RESUMEN FINANCIERO (TOTALES Y SALDOS)
                _SectionTitle(title: "Resumen Financiero"),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _SummaryRow(
                        label: "Subtotal",
                        value: NumberFormat.simpleCurrency().format(
                          sale['subtotal'],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        label: "Impuestos",
                        value: NumberFormat.simpleCurrency().format(
                          sale['tax'],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(),
                      ),
                      _SummaryRow(
                        label: "TOTAL A PAGAR",
                        value: NumberFormat.simpleCurrency().format(
                          sale['total'],
                        ),
                        isBold: true,
                        fontSize: 18,
                      ),

                      // SI ES FIADO, MOSTRAMOS EL DESGLOSE DE DEUDA
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
                                label: "Total Abonado (-)",
                                value: NumberFormat.simpleCurrency().format(
                                  sale['paidAmount'],
                                ),
                                textColor: Colors.green[700],
                              ),
                              const Divider(),
                              _SummaryRow(
                                label: "SALDO PENDIENTE",
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

                // 5. HISTORIAL DE PAGOS (SOLO SI ES FIADO)
                if (isCredit) ...[
                  const SizedBox(height: 20),
                  _SectionTitle(title: "Historial de Abonos"),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: (sale['payments'] as List).length,
                      separatorBuilder: (c, i) =>
                          const Divider(height: 1, indent: 50),
                      itemBuilder: (context, index) {
                        final payment = sale['payments'][index];
                        return ListTile(
                          leading: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          title: Text(
                            NumberFormat.simpleCurrency().format(
                              payment['amount'],
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            DateFormat('dd/MM/yyyy').format(payment['date']),
                          ),
                          trailing: Text(
                            payment['note'],
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
    final TextEditingController amountCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Registrar Nuevo Abono",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Saldo actual: ${NumberFormat.simpleCurrency().format(currentBalance)}",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: "Monto a abonar",
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
                  final amountString = amountCtrl.text.replaceAll(',', '.');
                  final amount = double.tryParse(amountString) ?? 0.0;

                  if (amount <= 0 || amount > currentBalance) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Monto inválido. Debe ser mayor a 0 y menor o igual a ${NumberFormat.simpleCurrency().format(currentBalance)}",
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    final isar = await ref.read(isarDbProvider.future);
                    Navigator.pop(ctx);

                    final venta = await isar.ventaCollections
                        .filter()
                        .serverIdEqualTo(widget.saleId)
                        .findFirst();

                    if (venta == null) return;

                    // VALIDACIÓN: El abono no puede ser mayor al saldo pendiente
                    if (amount > venta.saldoPendiente) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "⚠️ El abono (\$${amount.toStringAsFixed(2)}) no puede ser mayor "
                            "al saldo pendiente (\$${venta.saldoPendiente.toStringAsFixed(2)})",
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Se debe usar la CAJA ACTIVA ACTUAL, no la vieja de cuando se vendió (ya podría estar cerrada).
                    final dashboardState = ref.read(dashboardProvider).value;
                    final sesionActual = dashboardState?.cajaAbierta;

                    final nuevoPago = HistorialPagoCollection()
                      ..serverId = const Uuid().v4()
                      ..ventaId = widget.saleId
                      ..cajaSesionId =
                          sesionActual?.serverId ?? venta.cajaSesionId
                      ..montoPagado = amount
                      ..metodoDePago = MetodoPago.efectivo
                      ..fechaRegistro = DateTime.now()
                      ..usuarioRegistroId = venta.usuarioRegistroId
                      ..ultimaActualizacion = DateTime.now();

                    venta.totalPagado += amount;
                    venta.saldoPendiente =
                        (venta.totalVenta - venta.totalPagado);

                    if (venta.saldoPendiente <= 0.01) {
                      venta.estadoPago = EstadoPago.pagado;
                    }

                    await isar.writeTxn(() async {
                      await isar.historialPagoCollections.put(nuevoPago);
                      await isar.ventaCollections.put(venta);

                      // Actualizar saldo del cliente
                      final cliente = await isar.clienteCollections
                          .filter()
                          .serverIdEqualTo(venta.clienteId)
                          .findFirst();
                      if (cliente != null) {
                        cliente.saldoDeudorActual =
                            (cliente.saldoDeudorActual - amount).clamp(
                              0,
                              double.infinity,
                            );
                        cliente.pendienteSincronizacion = true;
                        await isar.clienteCollections.put(cliente);
                      }
                    });

                    ref.invalidate(saleDetailProvider(widget.saleId));
                    ref.invalidate(salesListProvider);
                    ref.invalidate(
                      dashboardProvider,
                    ); // Refrescar últimas transacciones
                    // TODO: ref.invalidate(cashRegisterDetailProvider(sesionActual?.serverId));

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Abono registrado con éxito"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    debugPrint("Error al registrar abono: $e");
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error al registrar: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                ),
                child: const Text(
                  "GUARDAR ABONO",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS UI PEQUEÑOS ---

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
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
