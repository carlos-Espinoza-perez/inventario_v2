import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/features/sales/data/repositories/caja_repository.dart';
import 'package:inventario_v2/features/sales/presentation/cash_register_detail_screen.dart';

final historialCajasProvider = FutureProvider.autoDispose<List<CajaSesione>>((
  ref,
) async {
  final repo = ref.read(cajaRepositoryProvider);
  return repo.obtenerHistorialCajas();
});

class CashRegisterHistoryScreen extends ConsumerStatefulWidget {
  const CashRegisterHistoryScreen({super.key});

  @override
  ConsumerState<CashRegisterHistoryScreen> createState() =>
      _CashRegisterHistoryScreenState();
}

class _CashRegisterHistoryScreenState
    extends ConsumerState<CashRegisterHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(appBarProvider.notifier)
          .setOptions(title: 'Historial de Cajas', showBackButton: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final historialCajasAsync = ref.watch(historialCajasProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bitacora de Sesiones',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            historialCajasAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, stack) =>
                  Center(child: Text('Error al cargar historial: $err')),
              data: (cajas) {
                if (cajas.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No hay historial de cajas registrado'),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cajas.length,
                  itemBuilder: (context, index) {
                    final session = cajas[index];
                    return _SessionItem(session: session);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionItem extends StatelessWidget {
  final CajaSesione session;

  const _SessionItem({required this.session});

  @override
  Widget build(BuildContext context) {
    final diff = session.diferencia;
    var diffColor = Colors.grey;
    var diffIcon = Icons.check_circle_outline;
    final isAbierta = session.estadoSesion == 'abierta';

    if (isAbierta) {
      diffColor = Colors.orange;
      diffIcon = Icons.lock_open;
    } else if (diff > 0) {
      diffColor = Colors.blue;
      diffIcon = Icons.arrow_upward;
    } else if (diff < 0) {
      diffColor = Colors.red;
      diffIcon = Icons.warning_amber_rounded;
    } else {
      diffColor = Colors.green;
    }

    final closeDate = session.fechaCierre;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CashRegisterDetailScreen(sessionId: session.id),
            ),
          );
        },
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('dd').format(session.fechaApertura),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            Text(
              DateFormat('MMM').format(session.fechaApertura).toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        title: Text(
          NumberFormat.simpleCurrency().format(session.totalEfectivoReal),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              'Apertura: ${DateFormat('hh:mm a').format(session.fechaApertura)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              'Cierre: ${closeDate != null ? DateFormat('hh:mm a').format(closeDate) : 'EN CURSO'}',
              style: TextStyle(
                fontSize: 12,
                color: isAbierta ? Colors.orange[800] : Colors.grey[600],
                fontWeight: isAbierta ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.payments_outlined,
                  size: 12,
                  color: Colors.blueGrey[400],
                ),
                const SizedBox(width: 4),
                Text(
                  'Inicial: ${NumberFormat.simpleCurrency().format(session.montoInicial)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blueGrey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.point_of_sale,
                  size: 12,
                  color: Colors.blueGrey[400],
                ),
                const SizedBox(width: 4),
                Text(
                  'Ventas: ${NumberFormat.simpleCurrency().format(session.totalVentasSistema)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blueGrey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: diffColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(diffIcon, color: diffColor, size: 20),
        ),
      ),
    );
  }
}
