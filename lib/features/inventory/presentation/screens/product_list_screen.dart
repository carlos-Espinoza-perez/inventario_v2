import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';

// Providers y Colecciones
import 'package:inventario_v2/features/inventory/data/collections/producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/providers/producto_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/categoria_provider.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'product_create_screen.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  String _searchQuery = "";
  String _selectedCategoryId = "Todos"; // ID de la categoría seleccionada

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(appBarProvider.notifier)
          .setOptions(
            title: "Catálogo de Productos",
            showBackButton: true,
            actions: [],
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Obtener Productos
    final asyncProductos = ref.watch(listaProductosProvider);
    final listaProductos = asyncProductos.value ?? [];

    // 2. Obtener Categorías
    final asyncCategorias = ref.watch(listCategoriasAllProvider);
    final listaCategorias = asyncCategorias.value ?? [];

    // 3. Crear Mapa de Categorías (ID -> Nombre) para búsqueda rápida
    final Map<String, String> categoriaMap = {
      for (var c in listaCategorias) c.serverId: c.nombre,
    };

    // 4. Lógica de Filtrado (Buscador + Categoría)
    final filteredProducts = listaProductos.where((p) {
      // Filtro Categoría
      final matchesCategory =
          _selectedCategoryId == "Todos" ||
          p.categoriaId == _selectedCategoryId;

      // Filtro Texto
      final nombre = p.nombre.toLowerCase();
      final query = _searchQuery.toLowerCase();
      final matchesSearch = nombre.contains(query);

      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],

      // Botón flotante para crear nuevo
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEditProduct(),
        backgroundColor: Colors.cyan.shade800,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Nuevo producto",
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
                // 1. Buscador
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: const InputDecoration(
                      hintText: "Buscar producto...",
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 2. Chips de Categorías (Dinámicos desde DB)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Chip "Todos"
                      _buildCategoryChip("Todos", "Todos"),
                      // Chips de la DB
                      ...listaCategorias.map(
                        (cat) => _buildCategoryChip(cat.nombre, cat.serverId),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- ZONA INFERIOR: GRILLA DE PRODUCTOS ---
          Expanded(
            child: filteredProducts.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 2 columnas
                          childAspectRatio:
                              0.75, // Proporción exacta de tu referencia
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      // Buscamos el nombre de la categoría usando el mapa
                      final categoryName =
                          categoriaMap[product.categoriaId] ?? 'Sin Categoría';

                      return _buildProductGridCard(product, categoryName);
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
    ProductoCollection product,
    String categoryName,
  ) {
    // Quitamos el GestureDetector global de aquí
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: GestureDetector(
              onTap: () => _openFullScreenImage(product), // Abre Preview
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
                  // Aquí usamos el fit por defecto (cover) para la tarjeta
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

                    // Aquí puedes poner tu fila de SKU y Stock...
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER: IMAGEN (Local > Caché Inteligente > Placeholder) ---
  Widget _buildImageWidget(
    ProductoCollection product, {
    BoxFit fit = BoxFit.cover,
  }) {
    // 1. IMAGEN LOCAL
    if (product.imagenLocal != null &&
        File(product.imagenLocal!).existsSync()) {
      return Image.file(
        File(product.imagenLocal!),
        fit: fit, // Usamos la variable fit
        width: double.infinity,
        height: double.infinity, // Aseguramos que llene el contenedor
      );
    }

    // 2. IMAGEN REMOTA
    if (product.imagenUrl != null && product.imagenUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: product.imagenUrl!,
        fit: fit, // Usamos la variable fit
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

    // 3. Fallback
    return _buildPlaceholder();
  }

  void _openFullScreenImage(ProductoCollection product) {
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
            // InteractiveViewer permite hacer Zoom con los dedos
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                // Usamos BoxFit.contain para ver la foto completa
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
        Icons.checkroom, // El icono de ropa que tenías en la referencia
        size: 50,
        color: Colors.cyan.shade800.withOpacity(0.3),
      ),
    );
  }

  // --- ESTADO VACÍO ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(
            "No se encontraron productos",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // --- NAVEGACIÓN ---
  void _navigateToAddEditProduct({ProductoCollection? existingProduct}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProductCreateScreen(productToEdit: existingProduct),
      ),
    );
  }
}
