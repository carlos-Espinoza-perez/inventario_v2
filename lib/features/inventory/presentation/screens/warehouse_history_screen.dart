import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:inventario_v2/core/database/app_bar_provider.dart';

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

  // Simulación de Datos (Basado en tu Table MovimientoProducto)
  final List<Map<String, dynamic>> _mockMovements = [
    {
      "tipo": "COMPRA",
      "fecha": DateTime.now().subtract(const Duration(minutes: 45)),
      "referencia": "Factura #FAC-9921",
      "items": 120, // Cantidad de productos
      "total": 15400.00,
      "usuario": "Juan Pérez",
      "direccion": "ENTRADA", // Calculado según BodegaDestinoId == warehouseId
      "estado": "APROBADO",
    },
    {
      "tipo": "VENTA",
      "fecha": DateTime.now().subtract(const Duration(hours: 3)),
      "referencia": "Ticket #Tk-004",
      "items": 3,
      "total": 850.00,
      "usuario": "Caja 1",
      "direccion": "SALIDA",
      "estado": "APROBADO",
    },
    {
      "tipo": "TRASLADO",
      "fecha": DateTime.now().subtract(const Duration(days: 1)),
      "referencia": "A Bodega Norte",
      "items": 50,
      "total": 0.0,
      "usuario": "Admin",
      "direccion": "SALIDA_TRASLADO", // Salió de aquí hacia otra
      "estado": "PENDIENTE",
    },
    {
      "tipo": "AJUSTE",
      "fecha": DateTime.now().subtract(const Duration(days: 2)),
      "referencia": "Merma por daño",
      "items": 2,
      "total": 0.0,
      "usuario": "Supervisor",
      "direccion": "SALIDA",
      "estado": "APROBADO",
    },
    {
      "tipo": "TRASLADO",
      "fecha": DateTime.now().subtract(const Duration(days: 3)),
      "referencia": "Desde Bodega Sur",
      "items": 15,
      "total": 0.0,
      "usuario": "Admin",
      "direccion": "ENTRADA_TRASLADO", // Llegó aquí desde otra
      "estado": "APROBADO",
    },
  ];

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

  // Lógica simple de filtrado en memoria
  List<Map<String, dynamic>> get _filteredMovements {
    if (_selectedFilter == 'Todos') return _mockMovements;
    if (_selectedFilter == 'Entradas') {
      return _mockMovements
          .where((m) => m['direccion'].toString().contains('ENTRADA'))
          .toList();
    }
    if (_selectedFilter == 'Salidas') {
      return _mockMovements
          .where((m) => m['direccion'].toString().contains('SALIDA'))
          .toList();
    }
    return _mockMovements;
  }

  @override
  Widget build(BuildContext context) {
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
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredMovements.length,
              itemBuilder: (context, index) {
                final mov = _filteredMovements[index];
                return _MovementCard(movement: mov);
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
            color: Colors.black.withOpacity(0.04),
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
          context.push('/movement-detail');
        },
        // ICONO IZQUIERDO (Circular)
        leading: CircleAvatar(
          backgroundColor: themeColor.withOpacity(0.1),
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
          color: isActive ? activeColor.withOpacity(0.1) : Colors.white,
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
