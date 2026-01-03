import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
// Asegúrate de importar tu provider del AppBar si lo necesitas,
// aunque en pantallas con SliverAppBar solemos usar el nativo para el efecto visual.

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  final String warehouseId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.warehouseId,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  // --- DATOS SIMULADOS (MOCK) ---
  final Map<String, dynamic> _productData = {
    "nombre": "Gorra Nike SB Negra",
    "sku": "SKU-1012",
    "categoria": "Accesorio",
    "descripcion": "Gorra original estilo urbano, talla única ajustable.",
    "imagen": null, // Cambia a una URL para probar
    "stock_actual": 15,
    "stock_minimo": 5,
    "precio_venta": 250.00,
    "costo_promedio": 120.00,
    "ultima_compra": DateTime.now().subtract(const Duration(days: 10)),
  };

  final List<Map<String, dynamic>> _history = [
    {
      "tipo": "VENTA",
      "fecha": DateTime.now().subtract(const Duration(hours: 2)),
      "cantidad": -1,
      "referencia": "Ticket #4021",
      "usuario": "Caja 1",
    },
    {
      "tipo": "COMPRA",
      "fecha": DateTime.now().subtract(const Duration(days: 5)),
      "cantidad": 20,
      "referencia": "Factura F-9921",
      "usuario": "Admin",
    },
    {
      "tipo": "TRASLADO",
      "fecha": DateTime.now().subtract(const Duration(days: 12)),
      "cantidad": -5,
      "referencia": "A Sucursal Norte",
      "usuario": "Juan Pérez",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: "C\$ ", decimalDigits: 2);
    final stock = _productData['stock_actual'] as int;
    final minStock = _productData['stock_minimo'] as int;
    final isLowStock = stock <= minStock;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // 1. HEADER COLAPSABLE CON IMAGEN
          SliverAppBar(
            expandedHeight: 280,
            pinned: true, // Se queda fijo arriba al scrollear
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_outlined, size: 20),
                ),
                onPressed: () {
                  // Editar producto
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _ProductImageHeader(
                imageUrl: _productData['imagen'],
                categoria: _productData['categoria'],
                tag: "hero-${widget.productId}", // Hero Animation
              ),
            ),
          ),

          // 2. CONTENIDO PRINCIPAL
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría y SKU
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _productData['categoria'].toString().toUpperCase(),
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _productData['sku'],
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Nombre
                  Text(
                    _productData['nombre'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Descripción
                  Text(
                    _productData['descripcion'],
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),

                  const SizedBox(height: 24),

                  // TARJETAS DE ESTADÍSTICAS (Grid)
                  Row(
                    children: [
                      // Tarjeta de Stock (Destacada)
                      Expanded(
                        child: _StatCard(
                          label: "Stock Actual",
                          value: "$stock",
                          subValue: isLowStock ? "Bajo Stock" : "Óptimo",
                          color: isLowStock ? Colors.red : Colors.green,
                          icon: Icons.inventory_2_outlined,
                          isPrimary: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Tarjeta de Precio
                      Expanded(
                        child: _StatCard(
                          label: "Precio Venta",
                          value: currency.format(_productData['precio_venta']),
                          subValue:
                              "Costo: ${currency.format(_productData['costo_promedio'])}",
                          color: Colors.blue,
                          icon: Icons.attach_money_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // SECCIÓN HISTORIAL
                  const Text(
                    "Historial de Movimientos",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // 3. LISTA DE HISTORIAL (SliverList para rendimiento)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final mov = _history[index];
                return _HistoryItem(movement: mov);
              }, childCount: _history.length),
            ),
          ),

          // Espacio final
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),

      // BOTÓN FLOTANTE: AJUSTE RÁPIDO
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Abrir modal de ajuste de inventario rápido
        },
        backgroundColor: Colors.black87,
        icon: const Icon(Icons.tune_rounded, color: Colors.white),
        label: const Text(
          "Ajustar Stock",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

// --- WIDGETS COMPONENTES ---

class _ProductImageHeader extends StatelessWidget {
  final String? imageUrl;
  final String categoria;
  final String tag;

  const _ProductImageHeader({
    required this.imageUrl,
    required this.categoria,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          image: imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: imageUrl == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getCategoryIcon(categoria),
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Sin Imagen",
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  IconData _getCategoryIcon(String categoria) {
    // Reutiliza tu lógica de iconos aquí
    return Icons.checkroom_rounded;
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subValue;
  final Color color;
  final IconData icon;
  final bool isPrimary;

  const _StatCard({
    required this.label,
    required this.value,
    required this.subValue,
    required this.color,
    required this.icon,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPrimary ? color.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrimary ? color.withOpacity(0.5) : Colors.grey.shade200,
        ),
        boxShadow: isPrimary
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? color : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subValue,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isPrimary ? color : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final Map<String, dynamic> movement;

  const _HistoryItem({required this.movement});

  @override
  Widget build(BuildContext context) {
    final int cantidad = movement['cantidad'];
    final bool isPositive = cantidad > 0;
    final Color color = isPositive ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          // Icono circular
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),

          // Info Central
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement['tipo'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  movement['referencia'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                Text(
                  DateFormat('dd MMM, hh:mm a').format(movement['fecha']),
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              ],
            ),
          ),

          // Cantidad a la derecha
          Text(
            isPositive ? "+$cantidad" : "$cantidad",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
