import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:inventario_v2/core/providers/database_provider.dart';
import 'package:inventario_v2/core/constants/app_enums.dart';
import 'package:inventario_v2/features/sales/data/collections/caja_sesion_collection.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';

// ------------------------------------------------------------------
// MODEL
// ------------------------------------------------------------------
class CashAuditModel {
  final String sessionId;
  final DateTime openedAt;
  final DateTime? closedAt;
  final double totalVentas;
  final double totalEfectivo;
  final double diferencia;
  final EstadoSesion estado;

  CashAuditModel({
    required this.sessionId,
    required this.openedAt,
    this.closedAt,
    required this.totalVentas,
    required this.totalEfectivo,
    required this.diferencia,
    required this.estado,
  });
}

// ------------------------------------------------------------------
// PROVIDER
// ------------------------------------------------------------------
final cashAuditProvider = FutureProvider.autoDispose<List<CashAuditModel>>((
  ref,
) async {
  final isar = await ref.watch(isarDbProvider.future);

  final allSessions = await isar.cajaSesionCollections
      .where()
      .sortByFechaAperturaDesc()
      .findAll();

  final sessions = allSessions.take(20).toList();

  return sessions
      .map(
        (s) => CashAuditModel(
          sessionId: s.serverId,
          openedAt: s.fechaApertura,
          closedAt: s.fechaCierre,
          totalVentas: s.totalVentasSistema,
          totalEfectivo: s.totalEfectivoReal,
          diferencia: s.diferencia,
          estado: s.estadoSesion,
        ),
      )
      .toList();
});

// ------------------------------------------------------------------
// SCREEN
// ------------------------------------------------------------------
class CashFlowReportScreen extends ConsumerStatefulWidget {
  const CashFlowReportScreen({super.key});

  @override
  ConsumerState<CashFlowReportScreen> createState() =>
      _CashFlowReportScreenState();
}

class _CashFlowReportScreenState extends ConsumerState<CashFlowReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(appBarProvider.notifier)
          .setOptions(
            title: "Auditoría de Cajas",
            subtitle: "Historial de faltantes",
            showBackButton: true,
            actions: [
              IconButton(
                onPressed: () => ref.invalidate(cashAuditProvider),
                icon: const Icon(Icons.refresh),
              ),
            ],
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final auditAsync = ref.watch(cashAuditProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: auditAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (sessions) {
          final cerradas = sessions
              .where((s) => s.estado == EstadoSesion.cerrada)
              .toList();
          final perfectos = cerradas.where((s) => s.diferencia == 0).length;
          final faltanteAcumulado = cerradas
              .where((s) => s.diferencia < 0)
              .fold(0.0, (sum, s) => sum + s.diferencia);
          final pctPerfectos = cerradas.isNotEmpty
              ? ((perfectos / cerradas.length) * 100).toStringAsFixed(0)
              : '0';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. GRÁFICO de diferencias
                if (cerradas.isNotEmpty) ...[
                  const Text(
                    "Historial de Faltantes/Sobrantes",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Text(
                    "Últimos ${cerradas.take(7).length} cierres",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 250,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: BarChart(
                      BarChartData(
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx >= cerradas.length) {
                                  return const SizedBox.shrink();
                                }
                                return SideTitleWidget(
                                  meta: meta,
                                  space: 4,
                                  child: Text(
                                    DateFormat(
                                      'dd/MM',
                                    ).format(cerradas[idx].openedAt),
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: const FlGridData(
                          show: true,
                          drawVerticalLine: false,
                        ),
                        barGroups: List.generate(cerradas.take(7).length, (i) {
                          final diff = cerradas[i].diferencia;
                          Color color = Colors.green;
                          if (diff < 0) color = Colors.red;
                          if (diff > 0) color = Colors.blue;
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: diff,
                                color: color,
                                width: 20,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // 2. RESUMEN DE AUDITORÍA
                const Text(
                  "Resumen de Auditoría",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _AuditCard(
                        label: "Cierres Perfectos",
                        value: "$pctPerfectos%",
                        color: Colors.green,
                        icon: Icons.check_circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AuditCard(
                        label: "Faltante Acumulado",
                        value: NumberFormat.compactSimpleCurrency().format(
                          faltanteAcumulado,
                        ),
                        color: faltanteAcumulado == 0
                            ? Colors.green
                            : Colors.red,
                        icon: faltanteAcumulado == 0
                            ? Icons.check_circle
                            : Icons.warning,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 3. LISTA de sesiones
                const Text(
                  "Sesiones Recientes",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 10),
                if (sessions.isEmpty)
                  const Center(child: Text("No hay sesiones registradas."))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final s = sessions[index];
                      final isAbierta = s.estado == EstadoSesion.abierta;
                      Color diffColor = Colors.grey;
                      if (isAbierta) {
                        diffColor = Colors.orange;
                      } else if (s.diferencia > 0) {
                        diffColor = Colors.blue;
                      } else if (s.diferencia < 0) {
                        diffColor = Colors.red;
                      } else {
                        diffColor = Colors.green;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: diffColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isAbierta
                                    ? Icons.lock_open
                                    : (s.diferencia > 0
                                          ? Icons.arrow_upward
                                          : (s.diferencia < 0
                                                ? Icons.warning
                                                : Icons.check)),
                                color: diffColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat(
                                      'dd MMM yyyy',
                                    ).format(s.openedAt),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    isAbierta
                                        ? "EN CURSO"
                                        : "Cierre: ${s.closedAt != null ? DateFormat('HH:mm').format(s.closedAt!) : '-'}",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isAbierta
                                          ? Colors.orange[800]
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  NumberFormat.compactSimpleCurrency().format(
                                    s.totalVentas,
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  isAbierta
                                      ? "Activo"
                                      : "Dif: ${s.diferencia > 0 ? '+' : ''}${NumberFormat.compactSimpleCurrency().format(s.diferencia)}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: diffColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
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

class _AuditCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _AuditCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
