import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/categoria_provider.dart';
import 'package:inventario_v2/features/inventory/presentation/widgets/categoria_filter_list.dart';

class WarehouseInventoryScreen extends ConsumerStatefulWidget {
  final String warehouseId;
  const WarehouseInventoryScreen({super.key, required this.warehouseId});

  @override
  ConsumerState<WarehouseInventoryScreen> createState() =>
      _WarehouseInventoryScreenState();
}

class _WarehouseInventoryScreenState
    extends ConsumerState<WarehouseInventoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Simulación de datos (Esto luego vendrá de tu Base de Datos)
  final List<Map<String, dynamic>> _mockProducts = [
    {
      "nombre": "Camisa Manga Larga Formal",
      "sku": "SKU-1002",
      "categoria": "Ropa",
      "stock": 15,
      "precio": 250.0,
      "costo": 120.0,
      "imagen": null,
    },
    {
      "nombre": "Gorra Nike SB",
      "sku": "SKU-1012",
      "categoria": "Accesorio",
      "stock": 15,
      "precio": 250.0,
      "costo": 120.0,
      "imagen": null,
    },
    {
      "nombre": "Pantalón Jeans Jingo",
      "sku": "SKU-1022",
      "categoria": "Ropa",
      "stock": 2, // Bajo Stock
      "precio": 550.0,
      "costo": 340.0,
      "imagen": null,
    },
    {
      "nombre": "Taza de Cerámica",
      "sku": "SKU-2032",
      "categoria": "Hogar",
      "stock": 8,
      "precio": 80.0,
      "costo": 40.0,
      "imagen": null,
    },
    {
      "nombre": "Zapatos Escolares",
      "sku": "SKU-3045",
      "categoria": "Calzado",
      "stock": 1, // Crítico
      "precio": 450.0,
      "costo": 200.0,
      "imagen": null,
    },
  ];

  @override
  void initState() {
    super.initState();
    // 🔥 CONTROL DEL HEADER DINÁMICO
    // Usamos microtask para configurar el AppBar global apenas carga la pantalla
    Future.microtask(() {
      ref
          .read(appBarProvider.notifier)
          .setOptions(
            title:
                "Bodega Central", // Aquí usarías widget.warehouseId para buscar el nombre real
            subtitle: "Inventario Actual",
            showBackButton: true, // Forzamos la flecha de regreso
            actions: [
              IconButton(
                onPressed: () {
                  context.push('/warehouse-history');
                  print("Ver historial");
                },
                icon: const Icon(Icons.history, color: Colors.black87),
                tooltip: "Ver Historial",
              ),
            ],
          );
    });
  }

  // Opcional: Si quieres limpiar al salir (aunque Dashboard suele resetearlo al entrar)
  @override
  void deactivate() {
    // ref.read(appBarProvider.notifier).reset();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El cuerpo principal
      body: Column(
        children: [
          // 1. ZONA DE BÚSQUEDA Y FILTROS
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Campo de Texto Buscador
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Buscar producto, SKU...",
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.black87,
                      ),
                      onPressed: () {
                        context.push('/barcode-scanner');
                      },
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Chips de Filtros (Scroll Horizontal)
                CategoriaFilterList(),
              ],
            ),
          ),

          // 2. LISTA DE PRODUCTOS
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _mockProducts.length,
              itemBuilder: (context, index) {
                final prod = _mockProducts[index];
                return _ProductCard(
                  nombre: prod['nombre'],
                  sku: prod['sku'],
                  stock: prod['stock'],
                  precio: prod['precio'],
                  costo: prod['costo'],
                  categoria: prod['categoria'],
                  imageUrl: prod['imagen'],
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showActionModal(context),
        backgroundColor: Colors.blue[600], // Ajusta a tu color de marca
        elevation: 4,
        icon: const Icon(Icons.bolt_rounded, color: Colors.white),
        label: const Text(
          "Acciones",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showActionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Operaciones de Inventario",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.download_rounded,
                  color: Colors.green,
                  label: "Entrada",
                  onTap: () {
                    context.pop();
                    context.push('/batch-entry/${widget.warehouseId}');
                  },
                ),
                _ActionButton(
                  icon: Icons.upload_rounded,
                  color: Colors.orange,
                  label: "Salida",
                  onTap: () {
                    context.pop();
                    context.go('/warehouse-transfer');
                  },
                ),
                _ActionButton(
                  icon: Icons.list_alt_outlined,
                  color: Colors.blue,
                  label: "Lista de Productos",
                  onTap: () {
                    context.pop();
                    context.push('/product-list');
                    // context.push('/warehouse/${widget.warehouseId}/add-product');
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// WIDGETS AUXILIARES (COMPONENTES UI)
// ------------------------------------------------------------------

class _ProductCard extends StatelessWidget {
  final String nombre;
  final String sku;
  final int stock;
  final double precio;
  final double costo;
  final String categoria;
  final String? imageUrl;

  const _ProductCard({
    required this.nombre,
    required this.sku,
    required this.stock,
    required this.precio,
    required this.costo,
    required this.categoria,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLowStock = stock <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.push('/product-detail');
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 1. IMAGEN INTELIGENTE
                _ProductImage(imageUrl: imageUrl, categoria: categoria),

                const SizedBox(width: 14),

                // 2. INFO DEL PRODUCTO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SKU y Categoría
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              sku,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            categoria,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Nombre Principal
                      Text(
                        nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Precios
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            "C\$ ${precio.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Costo (Discreto)
                          Text(
                            "Costo: ${costo.toStringAsFixed(0)}",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. INDICADOR DE STOCK LATERAL
                Column(
                  children: [
                    Container(
                      width: 50,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isLowStock ? Colors.red[50] : Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "$stock",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isLowStock
                                  ? Colors.red[700]
                                  : Colors.green[700],
                            ),
                          ),
                          Text(
                            "unds",
                            style: TextStyle(
                              fontSize: 9,
                              color: isLowStock
                                  ? Colors.red[300]
                                  : Colors.green[300],
                            ),
                          ),
                        ],
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

// Widget que decide si mostrar foto o icono
class _ProductImage extends StatelessWidget {
  final String? imageUrl;
  final String categoria;

  const _ProductImage({required this.imageUrl, required this.categoria});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        image: imageUrl != null
            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: imageUrl == null
          ? Center(
              child: Icon(
                _getCategoryIcon(categoria),
                color: Colors.grey[400],
                size: 32,
              ),
            )
          : null,
    );
  }

  IconData _getCategoryIcon(String categoria) {
    final cat = categoria.toLowerCase();
    if (cat.contains('ropa') ||
        cat.contains('camisa') ||
        cat.contains('pantal')) {
      return Icons.checkroom_rounded;
    } else if (cat.contains('calzado') || cat.contains('zapato')) {
      return Icons.hiking_rounded;
    } else if (cat.contains('hogar')) {
      return Icons.coffee_rounded;
    } else if (cat.contains('accesorio') || cat.contains('gorra')) {
      return Icons.backpack_outlined;
    }
    return Icons.inventory_2_outlined;
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
