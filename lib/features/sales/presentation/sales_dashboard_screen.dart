import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/core/providers/database_provider.dart';
import 'package:inventario_v2/features/sales/data/collections/venta_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/cliente_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/detalle_venta_collection.dart';
import 'package:inventario_v2/core/constants/app_enums.dart'; // Para EstadoPago
import 'package:inventario_v2/features/dashboard/presentation/providers/dashboard_provider.dart';

// PROVIDER DE VENTAS
final salesListProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final isar = await ref.watch(isarDbProvider.future);

  // Obtener todas las ventas ordenadas por fecha reciente
  final ventas = await isar.ventaCollections
      .where()
      .sortByFechaVentaDesc()
      .findAll();

  List<Map<String, dynamic>> resultados = [];

  for (var venta in ventas) {
    // 1. Obtener Cliente
    final cliente = await isar.clienteCollections
        .filter()
        .serverIdEqualTo(venta.clienteId)
        .findFirst();
    final nombreCliente = cliente?.nombre ?? 'Cliente Desconocido';

    // 2. Contar Items (Detalles)
    final itemsCount = await isar.detalleVentaCollections
        .filter()
        .ventaIdEqualTo(venta.serverId)
        .count();

    // 3. Mapear estado
    String status = 'Pendiente';
    if (!venta.estado) {
      status = 'Anulado';
    } else if (venta.estadoPago == EstadoPago.pagado) {
      status = 'Pagado';
    } else {
      status = 'Pendiente';
    }

    resultados.add({
      'id': venta.serverId.substring(0, 8).toUpperCase(), // ID visual corto
      'fullId': venta.serverId, // ID real para navegación
      'client': nombreCliente,
      'date': venta.fechaVenta,
      'total': venta.totalVenta,
      'status': status,
      'itemsCount': itemsCount,
    });
  }
  return resultados;
});

class SalesDashboardScreen extends ConsumerStatefulWidget {
  const SalesDashboardScreen({super.key});

  @override
  ConsumerState<SalesDashboardScreen> createState() =>
      _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends ConsumerState<SalesDashboardScreen> {
  // Estado de los Filtros
  String _searchQuery = "";
  String _selectedStatus =
      "Todos"; // Opciones: Todos, Pagado, Pendiente, Anulado

  // Lógica de Filtrado Local (sobre los datos traídos del provider)
  List<Map<String, dynamic>> _filterSales(List<Map<String, dynamic>> allSales) {
    return allSales.where((sale) {
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
              IconButton(
                onPressed: () {
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
                  debugPrint("Generar reporte");
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
    final dashboardState = ref.watch(dashboardProvider).value;
    final bool isCajaAbierta = dashboardState?.cajaAbierta != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],

      // BOTÓN FLOTANTE: NUEVA VENTA
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (isCajaAbierta) {
            context.push('/pos');
          } else {
            // Ir directamente a abrir caja para saltar el paso extra
            context.push('/cash-register');
          }
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
                  color: Colors.black.withValues(alpha: 0.04),
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
          // 2. LISTA DE VENTAS
          Expanded(
            child: ref
                .watch(salesListProvider)
                .when(
                  data: (allSales) {
                    final filteredSales = _filterSales(allSales);

                    if (filteredSales.isEmpty) {
                      return Center(
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
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredSales.length,
                      itemBuilder: (context, index) {
                        final sale = filteredSales[index];
                        return _SaleHistoryCard(sale: sale);
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) =>
                      Center(child: Text("Error al cargar ventas: $err")),
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
            color: Colors.black.withValues(alpha: 0.02),
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
            context.push('/sales-detail/${sale['fullId']}');
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
            color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
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
