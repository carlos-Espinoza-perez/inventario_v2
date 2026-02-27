import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import '../providers/warehouse_history_provider.dart';

class WarehouseHistoryScreen extends ConsumerStatefulWidget {
  final String warehouseId;
  const WarehouseHistoryScreen({super.key, required this.warehouseId});

  @override
  ConsumerState<WarehouseHistoryScreen> createState() =>
      _WarehouseHistoryScreenState();
}

class _WarehouseHistoryScreenState
    extends ConsumerState<WarehouseHistoryScreen> {
  String _selectedFilter = 'Todos'; // Filtro actual

  @override
  void initState() {
    super.initState();
    // Configurar AppBar Dinámico
    Future.microtask(() {
      ref
          .read(appBarProvider.notifier)
          .setOptions(
            title: "Historial de Movimientos",
            subtitle: "Últimos 30 días",
            showBackButton: true,
            actions: [
              IconButton(
                onPressed: () {
                  // Filtro por fecha avanzado
                },
                icon: const Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.black87,
                ),
              ),
            ],
          );
    });
  }

  // Lógica de filtrado en resultados de base de datos
  List<Map<String, dynamic>> _getFilteredMovements(
    List<Map<String, dynamic>> movements,
  ) {
    if (_selectedFilter == 'Todos') return movements;
    if (_selectedFilter == 'Entradas') {
      return movements
          .where((m) => m['direccion'].toString().contains('ENTRADA'))
          .toList();
    }
    if (_selectedFilter == 'Salidas') {
      return movements
          .where((m) => m['direccion'].toString().contains('SALIDA'))
          .toList();
    }
    if (_selectedFilter == 'Pendientes') {
      return movements
          .where((m) => m['estado'].toString().contains('PENDIENTE'))
          .toList();
    }
    return movements;
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(
      warehouseHistoryProvider(widget.warehouseId),
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // 1. FILTROS RÁPIDOS
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterTab(
                    label: "Todos",
                    isActive: _selectedFilter == 'Todos',
                    onTap: () => setState(() => _selectedFilter = 'Todos'),
                  ),
                  _FilterTab(
                    label: "Entradas",
                    isActive: _selectedFilter == 'Entradas',
                    icon: Icons.arrow_downward_rounded,
                    color: Colors.green,
                    onTap: () => setState(() => _selectedFilter = 'Entradas'),
                  ),
                  _FilterTab(
                    label: "Salidas",
                    isActive: _selectedFilter == 'Salidas',
                    icon: Icons.arrow_upward_rounded,
                    color: Colors.red,
                    onTap: () => setState(() => _selectedFilter = 'Salidas'),
                  ),
                  _FilterTab(
                    label: "Pendientes",
                    isActive: _selectedFilter == 'Pendientes',
                    icon: Icons.pending_actions_rounded,
                    color: Colors.orange,
                    onTap: () => setState(() => _selectedFilter = 'Pendientes'),
                  ),
                ],
              ),
            ),
          ),

          // 2. LISTA DE MOVIMIENTOS
          Expanded(
            child: historyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Error: $err")),
              data: (movements) {
                final filteredMovements = _getFilteredMovements(movements);

                if (filteredMovements.isEmpty) {
                  return const Center(
                    child: Text("No existen movimientos registrados"),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredMovements.length,
                  itemBuilder: (context, index) {
                    final mov = filteredMovements[index];
                    return _MovementCard(movement: mov);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------
// WIDGETS AUXILIARES
// ------------------------------------------------------------------

class _MovementCard extends StatelessWidget {
  final Map<String, dynamic> movement;

  const _MovementCard({required this.movement});

  @override
  Widget build(BuildContext context) {
    final String direccion = movement['direccion'];
    final String tipo = movement['tipo'];
    final bool isEntrada = direccion.contains('ENTRADA');
    final bool isTraslado = tipo == 'TRASLADO';

    // Configuración Visual según el tipo
    Color themeColor;
    IconData icon;

    if (isTraslado) {
      themeColor = Colors.blue;
      icon = Icons.swap_horiz_rounded;
    } else if (isEntrada) {
      themeColor = Colors.green;
      icon = Icons.arrow_downward_rounded;
    } else {
      themeColor = Colors.red;
      icon = Icons.arrow_upward_rounded;
    }

    final dateStr = DateFormat('dd MMM, hh:mm a').format(movement['fecha']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        onTap: () {
          context.push('/movement-detail/${movement['id']}');
        },
        // ICONO IZQUIERDO (Circular)
        leading: CircleAvatar(
          backgroundColor: themeColor.withValues(alpha: 0.1),
          child: Icon(icon, color: themeColor),
        ),

        // INFORMACIÓN PRINCIPAL
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatType(tipo),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            // Cantidad de items
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "${movement['items']} items",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),

        // DETALLES (Fecha y Referencia)
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movement['referencia'],
                style: const TextStyle(color: Colors.black87, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateStr,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const Spacer(),
                  Text(
                    movement['usuario'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatType(String tipo) {
    // Capitalizar primera letra (COMPRA -> Compra)
    return tipo[0] + tipo.substring(1).toLowerCase();
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;

  const _FilterTab({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? activeColor : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isActive ? activeColor : Colors.grey[600],
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : Colors.grey[600],
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
