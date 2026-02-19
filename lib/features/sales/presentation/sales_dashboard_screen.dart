import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';

class SalesDashboardScreen extends ConsumerStatefulWidget {
  const SalesDashboardScreen({super.key});

  @override
  ConsumerState<SalesDashboardScreen> createState() =>
      _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends ConsumerState<SalesDashboardScreen> {
  // Estado de los Filtros
  String _searchQuery = "";
  String _selectedStatus = "Todos"; // Opciones: Todos, Pagado, Pendiente

  // DATOS MOCK (Simulación de DB)
  final List<Map<String, dynamic>> _allSales = [
    {
      'id': '#VEN-001',
      'client': 'Juan Pérez',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'total': 1500.0,
      'status': 'Pagado',
      'itemsCount': 3,
    },
    {
      'id': '#VEN-002',
      'client': 'Maria Lopez',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'total': 450.50,
      'status': 'Pagado',
      'itemsCount': 1,
    },
    {
      'id': '#VEN-003',
      'client': 'Tienda El Centro',
      'date': DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      'total': 8500.0,
      'status': 'Pendiente', // Fiado / Crédito
      'itemsCount': 12,
    },
    {
      'id': '#VEN-004',
      'client': 'Consumidor Final',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'total': 250.0,
      'status': 'Pagado',
      'itemsCount': 1,
    },
    {
      'id': '#VEN-005',
      'client': 'Carlos Rivas',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'total': 1200.0,
      'status': 'Anulado',
      'itemsCount': 4,
    },
  ];

  // Lógica de Filtrado
  List<Map<String, dynamic>> get _filteredSales {
    return _allSales.where((sale) {
      final matchesSearch =
          sale['client'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          sale['id'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      final matchesStatus =
          _selectedStatus == "Todos" || sale['status'] == _selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    // Configuración del Header Global
    Future.microtask(() {
      ref
          .read(appBarProvider.notifier)
          .setOptions(
            title: "Gestión de Ventas",
            showBackButton: true,
            actions: [
              // NUEVO BOTÓN: ACCESO A CORTE DE CAJA
              IconButton(
                onPressed: () {
                  // Asegúrate de tener esta ruta en tu router.dart
                  context.push('/cash-register-history');
                },
                icon: const Icon(
                  Icons.point_of_sale_sharp,
                  color: Colors.blueGrey,
                ),
                tooltip: "Corte de Caja / Arqueo",
              ),
              IconButton(
                onPressed: () {
                  print("Generar reporte");
                },
                icon: const Icon(Icons.bar_chart, color: Colors.black87),
                tooltip: "Estadísticas",
              ),
            ],
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      // BOTÓN FLOTANTE: NUEVA VENTA
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navegar a la pantalla de POS (Punto de Venta)
          // Asegúrate de tener esta ruta configurada en tu GoRouter
          context.push('/pos');
        },
        backgroundColor: Colors.blue[700],
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: const Text(
          "NUEVA VENTA",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        children: [
          // 1. ZONA DE FILTROS Y BÚSQUEDA
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Buscador Texto
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: "Buscar por cliente o #Ticket...",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Chips de Estado (Pagado / Pendiente)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _StatusFilterChip(
                        label: "Todos",
                        isSelected: _selectedStatus == "Todos",
                        onTap: () => setState(() => _selectedStatus = "Todos"),
                      ),
                      _StatusFilterChip(
                        label: "Pagado",
                        isSelected: _selectedStatus == "Pagado",
                        color: Colors.green,
                        onTap: () => setState(() => _selectedStatus = "Pagado"),
                      ),
                      _StatusFilterChip(
                        label: "Pendiente",
                        isSelected: _selectedStatus == "Pendiente",
                        color: Colors.orange,
                        onTap: () =>
                            setState(() => _selectedStatus = "Pendiente"),
                      ),
                      _StatusFilterChip(
                        label: "Anulado",
                        isSelected: _selectedStatus == "Anulado",
                        color: Colors.red,
                        onTap: () =>
                            setState(() => _selectedStatus = "Anulado"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. LISTA DE VENTAS
          Expanded(
            child: _filteredSales.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "No se encontraron ventas",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredSales.length,
                    itemBuilder: (context, index) {
                      final sale = _filteredSales[index];
                      return _SaleHistoryCard(sale: sale);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGETS COMPONENTES ---

class _SaleHistoryCard extends StatelessWidget {
  final Map<String, dynamic> sale;

  const _SaleHistoryCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    // Configurar colores según estado
    Color statusColor;
    Color statusBg;
    switch (sale['status']) {
      case 'Pagado':
        statusColor = Colors.green.shade700;
        statusBg = Colors.green.shade50;
        break;
      case 'Pendiente':
        statusColor = Colors.orange.shade800;
        statusBg = Colors.orange.shade50;
        break;
      case 'Anulado':
        statusColor = Colors.red.shade700;
        statusBg = Colors.red.shade50;
        break;
      default:
        statusColor = Colors.grey;
        statusBg = Colors.grey.shade100;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.push('/sales-detail');
            // Ver detalle de la venta (Ticket)
            // context.push('/sale-detail/${sale['id']}');
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ID y Fecha
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sale['id'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM - hh:mm a').format(sale['date']),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    // Etiqueta de Estado
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        sale['status'],
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cliente e Items
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue.shade50,
                          radius: 18,
                          child: Icon(
                            Icons.person,
                            size: 18,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sale['client'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "${sale['itemsCount']} Productos",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Total
                    Text(
                      NumberFormat.simpleCurrency().format(sale['total']),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _StatusFilterChip({
    required this.label,
    required this.isSelected,
    this.color = Colors.blue, // Color base si se selecciona
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
