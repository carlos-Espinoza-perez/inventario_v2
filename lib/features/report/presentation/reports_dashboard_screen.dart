import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:inventario_v2/core/db/models/report_models.dart';
import 'package:inventario_v2/core/presentation/mixins/app_bar_config_mixin.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/bodega_provider.dart';

final todayStatsProvider = FutureProvider.autoDispose<ReportDashboardStatsDrift>((
  ref,
) async {
  final db = ref.watch(driftDatabaseProvider);
  final validBodegaIds = await ref.watch(validBodegasIdsProvider.future);
  return db.salesDao.getTodayStats(bodegaIds: validBodegaIds);
});

class ReportsDashboardScreen extends ConsumerStatefulWidget {
  const ReportsDashboardScreen({super.key});

  @override
  ConsumerState<ReportsDashboardScreen> createState() =>
      _ReportsDashboardScreenState();
}

class _ReportsDashboardScreenState
    extends ConsumerState<ReportsDashboardScreen> with AppBarConfigMixin {
  final List<Map<String, dynamic>> _reportMenu = const [
    {
      'title': 'Ventas',
      'subtitle': 'Historial, tendencias y productos top',
      'icon': Icons.bar_chart,
      'color': Colors.blue,
      'route': '/reports/sales',
    },
    {
      'title': 'Inventario',
      'subtitle': 'Valoracion, stock bajo y movimientos',
      'icon': Icons.inventory_2,
      'color': Colors.orange,
      'route': '/reports/inventory',
    },
    {
      'title': 'Finanzas',
      'subtitle': 'Ganancias, gastos y margenes',
      'icon': Icons.pie_chart,
      'color': Colors.green,
      'route': '/reports/financial',
    },
    {
      'title': 'Cuentas x Cobrar',
      'subtitle': 'Estado de clientes y creditos',
      'icon': Icons.account_balance_wallet,
      'color': Colors.purple,
      'route': '/reports/receivables',
    },
    {
      'title': 'Cierres de Caja',
      'subtitle': 'Auditoria de turnos pasados',
      'icon': Icons.receipt_long,
      'color': Colors.teal,
      'route': '/reports/cash-history',
    },
  ];

  @override
  void configureAppBar() {
    ref.read(appBarProvider.notifier).setOptions(
      title: 'Centro de Reportes',
      subtitle: 'Estadisticas y Analisis',
      showBackButton: false,
      actions: [],
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(configureAppBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen del Dia',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Consumer(
              builder: (_, ref, _) {
                final statsAsync = ref.watch(todayStatsProvider);
                return statsAsync.when(
                  loading: () => Row(
                    children: const [
                      Expanded(
                        child: _FlashCard(
                          title: 'Ventas Hoy',
                          value: 0,
                          icon: Icons.trending_up,
                          color: Colors.blue,
                          isLoading: true,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _FlashCard(
                          title: 'Utilidad',
                          value: 0,
                          icon: Icons.attach_money,
                          color: Colors.green,
                          isLoading: true,
                        ),
                      ),
                    ],
                  ),
                  error: (e, _) => Text(
                    'Error: $e',
                    style: const TextStyle(color: Colors.red),
                  ),
                  data: (stats) => Row(
                    children: [
                      Expanded(
                        child: _FlashCard(
                          title: 'Ventas Hoy',
                          value: stats.ventasHoy,
                          icon: Icons.trending_up,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FlashCard(
                          title: 'Utilidad',
                          value: stats.utilidadHoy,
                          icon: Icons.attach_money,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            const Text(
              'Catalogo de Reportes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reportMenu.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _reportMenu[index];
                return _ReportMenuItem(item: item);
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _FlashCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;
  final bool isLoading;

  const _FlashCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isLoading
                ? '--'
                : NumberFormat.compactSimpleCurrency().format(value),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportMenuItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const _ReportMenuItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(item['route'] as String),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['subtitle'] as String,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[300]),
            ],
          ),
        ),
      ),
    );
  }
}

