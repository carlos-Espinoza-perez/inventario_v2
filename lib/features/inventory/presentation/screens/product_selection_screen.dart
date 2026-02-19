import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/features/inventory/data/domain/models/product_with_stock.dart';

import 'package:inventario_v2/features/inventory/data/collections/producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/providers/categoria_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/producto_provider.dart';

import 'product_detail_entry_screen.dart';

class ProductSelectionScreen extends ConsumerStatefulWidget {
  final String bodegaId;

  const ProductSelectionScreen({super.key, required this.bodegaId});

  @override
  ConsumerState<ProductSelectionScreen> createState() =>
      _ProductSelectionScreenState();
}

class _ProductSelectionScreenState
    extends ConsumerState<ProductSelectionScreen> {
  String _selectedCategoryId = "Todos";
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // 1. Cargar Categorías (Para los filtros y nombres en las cards)
    final asyncCategorias = ref.watch(listCategoriasAllProvider);
    final listaCategorias = asyncCategorias.value ?? [];

    // Mapa para obtener nombre de categoría por ID rápido
    final categoryNameMap = {
      for (var cat in listaCategorias) cat.serverId: cat.nombre,
    };

    // 2. Cargar Productos con Stock (Usando el nuevo provider)
    final asyncProducts = ref.watch(productsWithStockProvider(widget.bodegaId));

    return asyncProducts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (allProducts) {
        // 3. Lógica de Filtrado en Memoria
        final filteredProducts = allProducts.where((item) {
          // Filtro Categoría
          final matchesCategory =
              _selectedCategoryId == "Todos" ||
              item.producto.categoriaId == _selectedCategoryId;

          // Filtro Buscador
          final matchesSearch = item.producto.nombre.toLowerCase().contains(
            _searchCtrl.text.toLowerCase(),
          );

          return matchesCategory && matchesSearch;
        }).toList();

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .03),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: "Buscar producto...",
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip("Todos", "Todos"),
                        ...listaCategorias.map(
                          (cat) => _buildFilterChip(cat.nombre, cat.serverId),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: filteredProducts.isEmpty
                  ? Center(
                      child: Text(
                        "No se encontraron productos",
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final item = filteredProducts[index];
                        final catName =
                            categoryNameMap[item.producto.categoriaId] ??
                            'General';
                        return _buildProductGridCard(item, catName);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String id) {
    final isSelected = _selectedCategoryId == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() => _selectedCategoryId = id);
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.cyan.shade100,
        labelStyle: TextStyle(
          color: isSelected ? Colors.cyan.shade900 : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.cyan : Colors.grey.shade300,
          ),
        ),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildProductGridCard(ProductWithStock item, String categoryName) {
    final product = item.producto;
    final stock = item.cantidad;

    return GestureDetector(
      onTap: () => _goToScanningWorker(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // A. Imagen del Producto (Parte Superior)
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50], // Fondo suave
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: _buildImageWidget(product),
                  ),
                ),
              ),
            ),

            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryName,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (stock <= 0)
                          const Text(
                            "Agotado",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          Text(
                            "${stock.toStringAsFixed(0)} unds",
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(ProductoCollection product) {
    if (product.imagenLocal != null &&
        File(product.imagenLocal!).existsSync()) {
      return Image.file(
        File(product.imagenLocal!),
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }

    if (product.imagenUrl != null && product.imagenUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: product.imagenUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (context, url) =>
            Center(child: Icon(Icons.image, color: Colors.grey[300], size: 40)),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Icon(
      Icons.checkroom,
      size: 60,
      color: Colors.cyan.shade800.withValues(alpha: .5),
    );
  }

  void _goToScanningWorker(ProductWithStock item) async {
    final product = item.producto;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailEntryScreen(
          productId: product.serverId,
          categoriaId: product.categoriaId,
        ),
      ),
    );

    if (result != null && mounted) {
      Navigator.pop(context, result);
    }
  }
}
