import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/features/report/presentation/cash_flow_report_screen.dart';
import 'package:inventario_v2/features/report/presentation/financial_report_screen.dart';
import 'package:inventario_v2/features/report/presentation/inventory_report_screen.dart';
import 'package:inventario_v2/features/report/presentation/receivables_report_screen.dart';
import 'package:inventario_v2/features/report/presentation/sales_report_screen.dart';

class ReportsDashboardScreen extends ConsumerStatefulWidget {
  const ReportsDashboardScreen({super.key});

  @override
  ConsumerState<ReportsDashboardScreen> createState() =>
      _ReportsDashboardScreenState();
}

class _ReportsDashboardScreenState
    extends ConsumerState<ReportsDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(appBarProvider.notifier)
          .setOptions(
            title: "Centro de Reportes",
            subtitle: "Estadísticas y Análisis",
            showBackButton: false, // Es una pestaña principal del menú inferior
            actions: [],
          );
    });
  }

  // LISTA DE REPORTES DISPONIBLES
  final List<Map<String, dynamic>> _reportMenu = [
    {
      'title': 'Ventas',
      'subtitle': 'Historial, tendencias y productos top',
      'icon': Icons.bar_chart,
      'color': Colors.blue,
      'route': '/reports/sales', // Ruta a definir
    },
    {
      'title': 'Inventario',
      'subtitle': 'Valoración, stock bajo y movimientos',
      'icon': Icons.inventory_2,
      'color': Colors.orange,
      'route': '/reports/inventory',
    },
    {
      'title': 'Finanzas',
      'subtitle': 'Ganancias, gastos y márgenes',
      'icon': Icons.pie_chart,
      'color': Colors.green,
      'route': '/reports/financial',
    },
    {
      'title': 'Cuentas x Cobrar',
      'subtitle': 'Estado de clientes y créditos',
      'icon': Icons.account_balance_wallet,
      'color': Colors.purple,
      'route': '/reports/receivables',
    },
    {
      'title': 'Cierres de Caja',
      'subtitle': 'Auditoría de turnos pasados',
      'icon': Icons.receipt_long,
      'color': Colors.teal,
      'route':
          '/reports/cash-history', // Podrías reutilizar CashRegisterHistoryScreen aquí
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. RESUMEN RÁPIDO (FLASH DE HOY)
            const Text(
              "Resumen del Día",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _FlashCard(
                    title: "Ventas Hoy",
                    value: 12500.00,
                    icon: Icons.trending_up,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FlashCard(
                    title: "Utilidad",
                    value: 3200.00,
                    icon: Icons.attach_money,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 2. LISTA DE REPORTES (GRID MENU)
            const Text(
              "Catálogo de Reportes",
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
              separatorBuilder: (c, i) => const SizedBox(height: 12),
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

// --- WIDGETS COMPONENTES ---

class _FlashCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;

  const _FlashCard({
    required this.title,
    required this.value,
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
            NumberFormat.compactSimpleCurrency().format(value),
            style: TextStyle(
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
      // borderRadius: BorderRadius.circular(16), <--- ELIMINA ESTA LÍNEA QUE CAUSA EL ERROR
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          16,
        ), // Ya estamos definiendo el borde aquí
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          String route = item['route'];
          Widget? page;

          if (route == '/reports/sales') {
            page = const SalesReportScreen();
          } else if (route == '/reports/inventory') {
            page = const InventoryReportScreen();
          } else if (route == '/reports/financial') {
            page = const FinancialReportScreen();
          } else if (route == '/reports/receivables') {
            page = const ReceivablesReportScreen();
          } else if (route == '/reports/cash-history') {
            page = const CashFlowReportScreen();
          }

          if (page != null) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Ruta no definida: $route")));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icono con fondo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item['icon'], color: item['color'], size: 28),
              ),
              const SizedBox(width: 16),

              // Textos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['subtitle'],
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Flecha
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[300]),
            ],
          ),
        ),
      ),
    );
  }
}
