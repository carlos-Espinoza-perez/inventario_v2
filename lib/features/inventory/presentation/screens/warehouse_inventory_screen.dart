import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/bodega_provider.dart';
import 'package:inventario_v2/features/inventory/presentation/widgets/categoria_filter_list.dart';
import 'package:inventario_v2/features/inventory/presentation/providers/warehouse_inventory_provider.dart';

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
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();

    // Escuchar cambios en el buscador para filtrar localmente
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Método para actualizar el título del AppBar reactivamente
  void _updateAppBarTitle() {
    final bodegaAsync = ref.watch(bodegaByIdProvider(widget.warehouseId));

    bodegaAsync.when(
      data: (bodega) {
        Future.microtask(() {
          ref
              .read(appBarProvider.notifier)
              .setOptions(
                title: bodega?.nombre ?? "Bodega",
                subtitle: "Inventario Actual",
                showBackButton: true,
                actions: [
                  IconButton(
                    onPressed: () {
                      context.push('/warehouse-history/${widget.warehouseId}');
                    },
                    icon: const Icon(Icons.history, color: Colors.black87),
                    tooltip: "Ver Historial",
                  ),
                ],
              );
        });
      },
      loading: () {
        Future.microtask(() {
          ref
              .read(appBarProvider.notifier)
              .setOptions(
                title: "Cargando...",
                subtitle: "Inventario Actual",
                showBackButton: true,
                actions: [
                  IconButton(
                    onPressed: () {
                      context.push('/warehouse-history/${widget.warehouseId}');
                    },
                    icon: const Icon(Icons.history, color: Colors.black87),
                    tooltip: "Ver Historial",
                  ),
                ],
              );
        });
      },
      error: (error, stack) {
        Future.microtask(() {
          ref
              .read(appBarProvider.notifier)
              .setOptions(
                title: "Bodega",
                subtitle: "Inventario Actual",
                showBackButton: true,
                actions: [
                  IconButton(
                    onPressed: () {
                      context.push('/warehouse-history/${widget.warehouseId}');
                    },
                    icon: const Icon(Icons.history, color: Colors.black87),
                    tooltip: "Ver Historial",
                  ),
                ],
              );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Actualizar el AppBar con el nombre de la bodega
    _updateAppBarTitle();

    // Escuchar el provider
    final inventoryAsync = ref.watch(
      warehouseInventoryProvider(widget.warehouseId),
    );

    return Scaffold(
      body: Column(
        children: [
          // 1. ZONA DE BÚSQUEDA Y FILTROS
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
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
                        context.push(
                          '/barcode-scanner?bodegaId=${widget.warehouseId}',
                        );
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
                const CategoriaFilterList(),
              ],
            ),
          ),

          // 2. LISTA DE PRODUCTOS (CON ESTADOS)
          Expanded(
            child: inventoryAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text('Error al cargar inventario: $err'),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.refresh(
                        warehouseInventoryProvider(widget.warehouseId),
                      ),
                      child: const Text("Reintentar"),
                    ),
                  ],
                ),
              ),
              data: (products) {
                // Filtrado local
                final filteredProducts = products.where((p) {
                  final matchesSearch =
                      p.nombre.toLowerCase().contains(_searchQuery) ||
                      p.sku.toLowerCase().contains(_searchQuery);
                  return matchesSearch && p.stock >= 1.0;
                }).toList();

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? "No hay productos en esta bodega"
                          : "No se encontraron coincidencias",
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final prod = filteredProducts[index];
                    final tallas = products
                        .where((p) =>
                            p.productoId == prod.productoId &&
                            p.talla != 'General' &&
                            p.talla.trim().isNotEmpty)
                        .map((p) => p.talla)
                        .toSet()
                        .toList();

                    return _ProductCard(
                      productId: prod.productoId, // Pasar ID
                      nombre: prod.nombre,
                      sku: prod.sku,
                      stock: prod.stock.toInt(),
                      precio: prod.precio,
                      costo: prod.costo,
                      categoria: prod.categoria,
                      imageUrl: prod.imagen,
                      warehouseId: widget.warehouseId,
                      tallaActual: prod.talla,
                      tallasDisponibles: tallas,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showActionModal(context),
        backgroundColor: Colors.blue[600],
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
                    context.push('/warehouse-transfer/${widget.warehouseId}');
                  },
                ),
                _ActionButton(
                  icon: Icons.list_alt_outlined,
                  color: Colors.blue,
                  label: "Lista de Productos",
                  onTap: () {
                    context.pop();
                    context.push('/product-list');
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
  final String productId; // ID del producto
  final String nombre;
  final String sku;
  final int stock;
  final double precio;
  final double costo;
  final String categoria;
  final String? imageUrl;
  final String warehouseId;
  final String tallaActual;
  final List<String> tallasDisponibles;

  const _ProductCard({
    required this.productId,
    required this.nombre,
    required this.sku,
    required this.stock,
    required this.precio,
    required this.costo,
    required this.categoria,
    this.imageUrl,
    required this.warehouseId,
    required this.tallaActual,
    required this.tallasDisponibles,
  });

  String _formatTallas(List<String> tallas) {
    if (tallas.length <= 3) {
      return tallas.join(' · ');
    } else {
      return '${tallas.take(3).join(' · ')} · ...';
    }
  }

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
            color: Colors.black.withValues(alpha: 0.04),
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
            context.push('/product-detail/$productId?bodegaId=$warehouseId');
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
                      // SKU y Talla
                      Row(
                        children: [
                          Flexible(
                            child: Container(
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          if (tallaActual != 'General') ...[
                            const SizedBox(width: 6),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  tallaActual,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
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

                      if (tallasDisponibles.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          "Tallas: ${_formatTallas(tallasDisponibles)}",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],

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
                          Flexible(
                            child: Text(
                              "Costo: ${costo.toStringAsFixed(0)}",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[400],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
        image: imageUrl != null && imageUrl!.isNotEmpty
            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: (imageUrl == null || imageUrl!.isEmpty)
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
                color: color.withValues(alpha: 0.1),
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
