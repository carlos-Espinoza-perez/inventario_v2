import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/db/models/product_catalog_models.dart';
import 'package:inventario_v2/core/presentation/mixins/app_bar_config_mixin.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/categoria_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/producto_provider.dart';

class CategoryTreeScreen extends ConsumerStatefulWidget {
  const CategoryTreeScreen({super.key});

  @override
  ConsumerState<CategoryTreeScreen> createState() => _CategoryTreeScreenState();
}

class _CategoryTreeScreenState extends ConsumerState<CategoryTreeScreen>
    with AppBarConfigMixin {
  @override
  void configureAppBar() {
    ref.read(appBarProvider.notifier).setOptions(
      title: 'Arbol del catalogo',
      subtitle: 'Categorias, marcas y productos',
      showBackButton: true,
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(configureAppBar);
  }

  @override
  Widget build(BuildContext context) {
    final categoriasAsync = ref.watch(listCategoriasAllProvider);
    final productosAsync = ref.watch(listaProductosProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: productosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (productos) => categoriasAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (categorias) => _CategoryTreeBody(
            categorias: categorias,
            productos: productos,
          ),
        ),
      ),
    );
  }
}

class _CategoryTreeBody extends StatelessWidget {
  final List<Categoria> categorias;
  final List<ProductCatalogItemDrift> productos;

  const _CategoryTreeBody({
    required this.categorias,
    required this.productos,
  });

  @override
  Widget build(BuildContext context) {
    if (categorias.isEmpty) {
      return const Center(child: Text('No hay categorias para mostrar.'));
    }

    final rootCategories =
        categorias.where((cat) => cat.categoriaPadreId == null).toList()
          ..sort((a, b) => a.nombre.compareTo(b.nombre));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _TreeSummaryCard(
          rootCount: rootCategories.length,
          productCount: productos.length,
        ),
        const SizedBox(height: 16),
        ...rootCategories.map(
          (root) => _CategoryNode(
            category: root,
            allCategories: categorias,
            products: productos,
            depth: 0,
          ),
        ),
      ],
    );
  }
}

class _TreeSummaryCard extends StatelessWidget {
  final int rootCount;
  final int productCount;

  const _TreeSummaryCard({required this.rootCount, required this.productCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.cyan.shade800, Colors.cyan.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.account_tree_outlined, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Explora tu catalogo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$rootCount categorias principales y $productCount productos registrados',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryNode extends StatelessWidget {
  final Categoria category;
  final List<Categoria> allCategories;
  final List<ProductCatalogItemDrift> products;
  final int depth;

  const _CategoryNode({
    required this.category,
    required this.allCategories,
    required this.products,
    required this.depth,
  });

  @override
  Widget build(BuildContext context) {
    final directChildren =
        allCategories.where((item) => item.categoriaPadreId == category.id).toList()
          ..sort((a, b) => a.nombre.compareTo(b.nombre));
    final matchingProducts =
        products.where((product) => product.categoriaId == category.id).toList()
          ..sort((a, b) => a.nombre.compareTo(b.nombre));

    return Container(
      margin: EdgeInsets.only(left: depth * 10, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.cyan.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.category_outlined, color: Colors.cyan.shade800),
        ),
        title: Text(
          category.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          directChildren.isEmpty
              ? '${matchingProducts.length} productos'
              : '${directChildren.length} subcategorias y ${matchingProducts.length} productos',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        children: [
          ...directChildren.map(
            (child) => _CategoryNode(
              category: child,
              allCategories: allCategories,
              products: products,
              depth: depth + 1,
            ),
          ),
          if (matchingProducts.isNotEmpty) _BrandSection(products: matchingProducts),
          if (directChildren.isEmpty && matchingProducts.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Esta categoria aun no tiene contenido asociado.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }
}

class _BrandSection extends StatelessWidget {
  final List<ProductCatalogItemDrift> products;

  const _BrandSection({required this.products});

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<ProductCatalogItemDrift>>{};
    for (final product in products) {
      final specs = _decodeSpecs(product.producto.especificacionJson);
      final brand = (specs['brand'] ?? 'Sin marca').toString();
      grouped.putIfAbsent(brand, () => []).add(product);
    }

    final brands = grouped.keys.toList()..sort();
    return Column(
      children: brands
          .map(
            (brand) => Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ExpansionTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.sell_outlined, color: Colors.indigo.shade700),
                ),
                title: Text(
                  brand,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('${grouped[brand]!.length} productos'),
                children: grouped[brand]!
                    .map(
                      (product) => Container(
                        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.cyan.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.inventory_2_outlined, color: Colors.cyan.shade800),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.nombre,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.sku.isNotEmpty
                                        ? 'SKU: ${product.sku}'
                                        : 'SKU no definido',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> _decodeSpecs(String? value) {
    if (value == null || value.isEmpty) return const {};
    try {
      final decoded = jsonDecode(value);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } catch (_) {
      return const {};
    }
  }
}
