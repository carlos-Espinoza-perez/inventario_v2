import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:inventario_v2/core/db/models/report_models.dart';
import 'package:inventario_v2/core/presentation/mixins/app_bar_config_mixin.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/bodega_provider.dart';

final receivablesProvider =
    FutureProvider.autoDispose<List<ReceivableClientDrift>>((ref) async {
      final db = ref.watch(driftDatabaseProvider);
      final validBodegaIds = await ref.watch(validBodegasIdsProvider.future);
      return db.salesDao.getReceivablesReport(bodegaIds: validBodegaIds);
    });

class ReceivablesReportScreen extends ConsumerStatefulWidget {
  const ReceivablesReportScreen({super.key});

  @override
  ConsumerState<ReceivablesReportScreen> createState() =>
      _ReceivablesReportScreenState();
}

class _ReceivablesReportScreenState
    extends ConsumerState<ReceivablesReportScreen> with AppBarConfigMixin {
  @override
  void configureAppBar() {
    ref.read(appBarProvider.notifier).setOptions(
      title: 'Cuentas por Cobrar',
      subtitle: 'Analisis de fiados',
      showBackButton: true,
      actions: [
        IconButton(
          onPressed: () => ref.invalidate(receivablesProvider),
          icon: const Icon(Icons.refresh),
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
    final receivablesAsync = ref.watch(receivablesProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: receivablesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error al cargar: $err')),
        data: (clients) {
          final totalDebt = clients.fold(0.0, (sum, c) => sum + c.totalDebt);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade100),
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
                              'Total en la Calle (Fiado)',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
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
                              '${clients.length} cliente(s) con deuda',
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
                if (clients.isEmpty)
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
                          'Sin deudas pendientes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Todos los clientes estan al dia.',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                else ...[
                  const Text(
                    'Clientes con Saldo Pendiente',
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
                                '${client.ventasCount} venta(s) pendiente(s)',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                client.lastPaymentDate != null
                                    ? 'Ultimo abono: ${DateFormat('dd MMM yyyy').format(client.lastPaymentDate!)}'
                                    : 'Sin abonos registrados',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: client.lastPaymentDate != null
                                      ? Colors.grey[500]
                                      : Colors.orange[700],
                                  fontWeight: client.lastPaymentDate == null
                                      ? FontWeight.bold
                                      : FontWeight.normal,
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
                                'Pendiente',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => context.push('/sales'),
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

