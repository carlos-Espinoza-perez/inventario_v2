import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:inventario_v2/core/providers/database_provider.dart';
import 'package:inventario_v2/core/constants/app_enums.dart';
import 'package:inventario_v2/features/sales/data/collections/venta_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/cliente_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/historial_pago_collection.dart';
import 'package:go_router/go_router.dart';
import 'package:inventario_v2/features/sales/data/collections/caja_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/caja_sesion_collection.dart';
import 'package:inventario_v2/features/inventory/data/providers/bodega_provider.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';

// ------------------------------------------------------------------
// MODEL
// ------------------------------------------------------------------
class ReceivableClientModel {
  final String clientId;
  final String name;
  final double totalDebt;
  final DateTime? lastPaymentDate;
  final int ventasCount;

  ReceivableClientModel({
    required this.clientId,
    required this.name,
    required this.totalDebt,
    this.lastPaymentDate,
    required this.ventasCount,
  });
}

// ------------------------------------------------------------------
// PROVIDER
// ------------------------------------------------------------------
final receivablesProvider =
    FutureProvider.autoDispose<List<ReceivableClientModel>>((ref) async {
      final isar = await ref.watch(isarDbProvider.future);

      final validBodegaIds = await ref.watch(validBodegasIdsProvider.future);

      final cajas = await isar.cajaCollections.where().findAll();
      final cajasDeBodegasValidas = cajas
          .where((c) => validBodegaIds.contains(c.bodegaId))
          .map((c) => c.serverId)
          .toSet();

      final sesiones = await isar.cajaSesionCollections.where().findAll();
      final sesionesValidas = sesiones
          .where((s) => cajasDeBodegasValidas.contains(s.cajaId))
          .map((s) => s.serverId)
          .toSet();

      // Ventas a crédito con saldo pendiente
      final ventasTodas = await isar.ventaCollections
          .filter()
          .tipoVentaEqualTo(TipoVenta.credito)
          .estadoEqualTo(true)
          .findAll();

      final ventas = ventasTodas
          .where((v) => sesionesValidas.contains(v.cajaSesionId))
          .toList();

      final pendientes = ventas
          .where(
            (v) => v.estadoPago != EstadoPago.pagado && v.saldoPendiente > 0,
          )
          .toList();

      // Agrupar por cliente
      final Map<String, ReceivableClientModel> byClient = {};
      for (final v in pendientes) {
        final cliente = await isar.clienteCollections
            .filter()
            .serverIdEqualTo(v.clienteId)
            .findFirst();
        final nombre = cliente?.nombre ?? 'Cliente Desconocido';

        // Último pago de esta venta
        final ultimoPago = await isar.historialPagoCollections
            .filter()
            .ventaIdEqualTo(v.serverId)
            .sortByFechaRegistroDesc()
            .findFirst();

        if (byClient.containsKey(v.clienteId)) {
          final existing = byClient[v.clienteId]!;
          final newDebt = existing.totalDebt + v.saldoPendiente;
          final newCount = existing.ventasCount + 1;
          DateTime? lastPay = existing.lastPaymentDate;
          if (ultimoPago != null &&
              (lastPay == null || ultimoPago.fechaRegistro.isAfter(lastPay))) {
            lastPay = ultimoPago.fechaRegistro;
          }
          byClient[v.clienteId] = ReceivableClientModel(
            clientId: v.clienteId,
            name: nombre,
            totalDebt: newDebt,
            lastPaymentDate: lastPay,
            ventasCount: newCount,
          );
        } else {
          byClient[v.clienteId] = ReceivableClientModel(
            clientId: v.clienteId,
            name: nombre,
            totalDebt: v.saldoPendiente,
            lastPaymentDate: ultimoPago?.fechaRegistro,
            ventasCount: 1,
          );
        }
      }

      // Ordenar por mayor deuda
      final result = byClient.values.toList()
        ..sort((a, b) => b.totalDebt.compareTo(a.totalDebt));
      return result;
    });

// ------------------------------------------------------------------
// SCREEN
// ------------------------------------------------------------------
class ReceivablesReportScreen extends ConsumerStatefulWidget {
  const ReceivablesReportScreen({super.key});

  @override
  ConsumerState<ReceivablesReportScreen> createState() =>
      _ReceivablesReportScreenState();
}

class _ReceivablesReportScreenState
    extends ConsumerState<ReceivablesReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(appBarProvider.notifier)
          .setOptions(
            title: "Cuentas por Cobrar",
            subtitle: "Análisis de fiados",
            showBackButton: true,
            actions: [
              IconButton(
                onPressed: () => ref.invalidate(receivablesProvider),
                icon: const Icon(Icons.refresh),
              ),
            ],
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final receivablesAsync = ref.watch(receivablesProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: receivablesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 10),
              Text(
                "Error al cargar: $err",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        data: (clients) {
          final totalDebt = clients.fold(0.0, (sum, c) => sum + c.totalDebt);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. TOTAL PENDIENTE
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.money_off,
                          color: Colors.red.shade700,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Total en la Calle (Fiado)",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              NumberFormat.simpleCurrency().format(totalDebt),
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                              ),
                            ),
                            Text(
                              "${clients.length} cliente(s) con deuda",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                if (clients.isEmpty) ...[
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 60,
                          color: Colors.green[300],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "¡Sin deudas pendientes!",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Todos los clientes están al día.",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // 2. LISTA DE DEUDORES
                  const Text(
                    "Clientes con Saldo Pendiente",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final client = clients[index];
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueGrey.shade50,
                            child: Text(
                              client.name.isNotEmpty
                                  ? client.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey.shade700,
                              ),
                            ),
                          ),
                          title: Text(
                            client.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${client.ventasCount} venta(s) pendiente(s)",
                                style: const TextStyle(fontSize: 12),
                              ),
                              if (client.lastPaymentDate != null)
                                Text(
                                  "Último abono: ${DateFormat('dd MMM yyyy').format(client.lastPaymentDate!)}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                )
                              else
                                Text(
                                  "Sin abonos registrados",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                NumberFormat.simpleCurrency().format(
                                  client.totalDebt,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                              const Text(
                                "Pendiente",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Navegar a ventas filtradas por este cliente
                            context.push('/sales');
                          },
                        ),
                      );
                    },
                  ),
                ],

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
