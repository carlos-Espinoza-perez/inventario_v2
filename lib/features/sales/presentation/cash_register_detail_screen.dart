import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:inventario_v2/core/providers/database_provider.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/features/sales/data/collections/caja_sesion_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/venta_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/caja_movimiento_extra_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/detalle_venta_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/historial_pago_collection.dart';
import 'package:inventario_v2/core/constants/app_enums.dart';

final cashRegisterDetailProvider = FutureProvider.family
    .autoDispose<Map<String, dynamic>, String>((ref, sessionId) async {
      final isar = await ref.watch(isarDbProvider.future);

      // 1. Obtener la sesión de caja
      final session = await isar.cajaSesionCollections
          .filter()
          .serverIdEqualTo(sessionId)
          .findFirst();
      if (session == null) throw Exception("Sesión no encontrada");

      // 2. Obtener movimientos extras (gastos/salidas)
      final movements = await isar.cajaMovimientoExtraCollections
          .filter()
          .cajaSesionIdEqualTo(sessionId)
          .sortByUltimaActualizacionDesc()
          .findAll();

      double expensesTotal = 0;
      List<Map<String, dynamic>> expensesList = [];
      for (var m in movements) {
        if (m.tipo == TipoMovimientoCaja.egreso) {
          expensesTotal += m.monto;
          expensesList.add({
            'reason': m.motivo ?? 'Desconocido',
            'amount': m.monto,
            'time': m.ultimaActualizacion,
          });
        }
      }

      // 2.5 Obtener Pagos (Efectivo real que entró en esta caja)
      final pagos = await isar.historialPagoCollections
          .filter()
          .cajaSesionIdEqualTo(sessionId)
          .findAll();

      double salesCash = 0;
      for (var p in pagos) {
        salesCash += p.montoPagado;
      }

      // 3. Obtener Ventas de esta sesión para calcular Fiados generados y Ganancia Bruta
      final sales = await isar.ventaCollections
          .filter()
          .cajaSesionIdEqualTo(sessionId)
          .findAll();

      double salesCredit = 0;
      double estimatedProfit = 0;

      for (var sale in sales) {
        if (sale.estado) {
          if (sale.tipoVenta == TipoVenta.credito) {
            salesCredit += sale.saldoPendiente;
          }

          final detalles = await isar.detalleVentaCollections
              .filter()
              .ventaIdEqualTo(sale.serverId)
              .findAll();
          for (var det in detalles) {
            // Ganancia bruta de ese producto = (precio venta * cantidad) - (costo compra * cantidad) - descuento
            double costoTotalProducto = det.costoHistoricoCompra * det.cantidad;
            double ingresoTotalProducto = det.subTotal - det.descuento;
            estimatedProfit += (ingresoTotalProducto - costoTotalProducto);
          }
        }
      }

      // 4. Calcular Valores
      final closeDate = session.fechaCierre ?? session.ultimaActualizacion;
      double expectedCash = session.montoInicial + salesCash - expensesTotal;

      // Utilizaa base en variables de session
      return {
        'id': session.serverId.substring(0, 8).toUpperCase(),
        'openedAt': session.fechaApertura,
        'closedAt': closeDate,
        'user':
            'Cajero (ID: ${session.usuarioAperturaId.substring(0, 4)})', // Podriamos buscar usuario real

        'initialCash': session.montoInicial,
        'salesCash': salesCash,
        'expensesTotal': expensesTotal,
        'expectedCash': expectedCash,
        'countedCash': session.totalEfectivoReal,
        'difference': session.diferencia,

        'salesCredit': salesCredit,
        'estimatedProfit': estimatedProfit,

        'expensesList': expensesList,
        'status': session.estadoSesion.name,
      };
    });

class CashRegisterDetailScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const CashRegisterDetailScreen({super.key, required this.sessionId});

  @override
  ConsumerState<CashRegisterDetailScreen> createState() =>
      _CashRegisterDetailScreenState();
}

class _CashRegisterDetailScreenState
    extends ConsumerState<CashRegisterDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(appBarProvider.notifier)
          .setOptions(title: "Reporte de Cerrado", showBackButton: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(cashRegisterDetailProvider(widget.sessionId));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (report) {
          final double diff = report['difference'];
          Color statusColor;
          String statusText;
          IconData statusIcon;

          final bool isAbierta = report['status'] == 'abierta';

          if (isAbierta) {
            statusColor = Colors.orange;
            statusText = "TURNO EN CURSO";
            statusIcon = Icons.lock_open;
          } else if (diff == 0) {
            statusColor = Colors.green;
            statusText = "CUADRE PERFECTO";
            statusIcon = Icons.check_circle_outline;
          } else if (diff > 0) {
            statusColor = Colors.blue;
            statusText = "SOBRANTE DE CAJA";
            statusIcon = Icons.arrow_circle_up;
          } else {
            statusColor = Colors.red;
            statusText = "FALTANTE DE CAJA";
            statusIcon = Icons.error_outline;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. TARJETA DE RESULTADO DEL CIERRE
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(statusIcon, size: 40, color: statusColor),
                      const SizedBox(height: 10),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (diff != 0) ...[
                        const SizedBox(height: 5),
                        Text(
                          "${diff > 0 ? '+' : ''}${NumberFormat.simpleCurrency().format(diff)}",
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 2. INFORMACIÓN GENERAL
                _SectionHeader(title: "Detalles del Turno"),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _InfoRow("Cajero Responsable", report['user']),
                      const Divider(),
                      _InfoRow(
                        "Apertura",
                        DateFormat(
                          'dd MMM yyyy - hh:mm a',
                        ).format(report['openedAt']),
                      ),
                      _InfoRow(
                        "Cierre",
                        DateFormat(
                          'dd MMM yyyy - hh:mm a',
                        ).format(report['closedAt']),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 3. BALANCE DE EFECTIVO (LA MATEMÁTICA)
                _SectionHeader(title: "Balance de Efectivo"),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _MathRow(
                        label: "Fondo Inicial",
                        amount: report['initialCash'],
                        operator: "+",
                      ),
                      _MathRow(
                        label: "Ventas Efectivo",
                        amount: report['salesCash'],
                        operator: "+",
                      ),
                      _MathRow(
                        label: "Gastos / Salidas",
                        amount: report['expensesTotal'],
                        operator: "-",
                        isNegative: true,
                      ),
                      const Divider(thickness: 1.5),
                      _MathRow(
                        label: "Efectivo Esperado",
                        amount: report['expectedCash'],
                        isResult: true,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _MathRow(
                          label: "Efectivo Contado (Real)",
                          amount: report['countedCash'],
                          isBold: true,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 4. ESTADÍSTICAS DEL NEGOCIO (LO QUE PEDISTE)
                _SectionHeader(title: "Métricas del Negocio"),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: "Ventas a Crédito",
                        amount: report['salesCredit'],
                        icon: Icons.credit_score,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _StatCard(
                        label: "Ganancia Neta",
                        amount: report['estimatedProfit'],
                        icon: Icons.trending_up,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // 5. DETALLE DE GASTOS
                _SectionHeader(title: "Gastos Registrados"),
                if ((report['expensesList'] as List).isEmpty)
                  const Text(
                    "No hubo gastos en este turno.",
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: (report['expensesList'] as List).length,
                      separatorBuilder: (c, i) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = report['expensesList'][index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.arrow_downward,
                            color: Colors.red,
                            size: 18,
                          ),
                          title: Text(
                            item['reason'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            DateFormat('hh:mm a').format(item['time']),
                          ),
                          trailing: Text(
                            "- ${NumberFormat.simpleCurrency().format(item['amount'])}",
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- WIDGETS AUXILIARES DE DISEÑO ---

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _MathRow extends StatelessWidget {
  final String label;
  final double amount;
  final String? operator;
  final bool isResult;
  final bool isNegative;
  final bool isBold;

  const _MathRow({
    required this.label,
    required this.amount,
    this.operator,
    this.isResult = false,
    this.isNegative = false,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (operator != null)
            SizedBox(
              width: 20,
              child: Text(
                operator!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: (isResult || isBold)
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: isResult ? 16 : 14,
              ),
            ),
          ),
          Text(
            NumberFormat.simpleCurrency().format(amount),
            style: TextStyle(
              fontWeight: (isResult || isBold)
                  ? FontWeight.bold
                  : FontWeight.w500,
              fontSize: isResult ? 16 : 14,
              color: isNegative ? Colors.red : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(
            NumberFormat.compactSimpleCurrency().format(amount),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
