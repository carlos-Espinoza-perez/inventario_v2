import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/models/product_catalog_models.dart';
import 'package:inventario_v2/core/presentation/mixins/app_bar_config_mixin.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/categoria_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/producto_provider.dart';

import 'product_create_screen.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen>
    with AppBarConfigMixin {
  String _searchQuery = '';
  String _selectedCategoryId = 'Todos';

  @override
  void configureAppBar() {
    ref.read(appBarProvider.notifier).setOptions(
      title: 'Catalogo de Productos',
      showBackButton: true,
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
    final productosAsync = ref.watch(listaProductosProvider);
    final categoriasAsync = ref.watch(listCategoriasAllProvider);
    final categorias = categoriasAsync.value ?? [];
    final categoriaMap = {for (final c in categorias) c.id: c.nombre};

    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEditProduct(),
        backgroundColor: Colors.cyan.shade800,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nuevo producto',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: const InputDecoration(
                      hintText: 'Buscar producto...',
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
                      _buildCategoryChip('Todos', 'Todos'),
                      ...categorias.map(
                        (cat) => _buildCategoryChip(cat.nombre, cat.id),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: productosAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (productos) {
                final filteredProducts = productos.where((p) {
                  final matchesCategory =
                      _selectedCategoryId == 'Todos' ||
                      p.categoriaId == _selectedCategoryId;
                  final query = _searchQuery.toLowerCase();
                  final matchesSearch =
                      p.nombre.toLowerCase().contains(query) ||
                      p.sku.toLowerCase().contains(query);
                  return matchesCategory && matchesSearch;
                }).toList();

                if (filteredProducts.isEmpty) {
                  return _buildEmptyState();
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.82,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final categoryName =
                        categoriaMap[product.categoriaId] ?? 'Sin Categoria';
                    return _buildProductGridCard(product, categoryName);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String id) {
    final isSelected = _selectedCategoryId == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedCategoryId = id),
        backgroundColor: Colors.white,
        selectedColor: Colors.cyan.shade100,
        labelStyle: TextStyle(
          color: isSelected ? Colors.cyan.shade900 : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
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

  Widget _buildProductGridCard(
    ProductCatalogItemDrift product,
    String categoryName,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () => _openFullScreenImage(product),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
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
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _navigateToAddEditProduct(existingProduct: product),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
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
                    Expanded(
                      child: Text(
                        product.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          height: 1.2,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'C\$ ${product.precioVenta.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(
    ProductCatalogItemDrift product, {
    BoxFit fit = BoxFit.cover,
  }) {
    if (product.imagenLocal != null &&
        File(product.imagenLocal!).existsSync()) {
      return Image.file(
        File(product.imagenLocal!),
        fit: fit,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (product.imagenUrl != null && product.imagenUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: product.imagenUrl!,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.cyan.shade100,
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(),
        fadeInDuration: const Duration(milliseconds: 300),
      );
    }

    return _buildPlaceholder();
  }

  void _openFullScreenImage(ProductCatalogItemDrift product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: _buildImageWidget(product, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.checkroom,
        size: 50,
        color: Colors.cyan.shade800.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(
            'No se encontraron productos',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _navigateToAddEditProduct({ProductCatalogItemDrift? existingProduct}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProductCreateScreen(productToEdit: existingProduct?.producto),
      ),
    );
  }
}
