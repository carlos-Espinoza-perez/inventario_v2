import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:inventario_v2/core/db/models/product_catalog_models.dart';
import 'package:inventario_v2/core/db/models/producto_stock_drift.dart';
import 'package:inventario_v2/features/inventory/data/domain/models/product_with_stock.dart';
import 'package:inventario_v2/features/inventory/data/providers/categoria_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/codigo_producto_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/inventario_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/producto_provider.dart';

import 'product_create_screen.dart';
import 'product_detail_entry_screen.dart';

enum ProductSelectionMode { entry, transfer }

class ProductSelectionScreen extends ConsumerStatefulWidget {
  final ProductSelectionMode mode;
  final String? originWarehouseId;

  const ProductSelectionScreen({
    super.key,
    required this.mode,
    this.originWarehouseId,
    String? bodegaId,
  }) : assert(
         mode == ProductSelectionMode.entry || originWarehouseId != null,
         'originWarehouseId is required for transfer mode',
       );

  @override
  ConsumerState<ProductSelectionScreen> createState() =>
      _ProductSelectionScreenState();
}

class _ProductSelectionScreenState
    extends ConsumerState<ProductSelectionScreen> {
  String _selectedCategoryId = 'Todos';
  final TextEditingController _searchCtrl = TextEditingController();
  bool _showScanner = false;
  bool _isScannerActive = true;
  String? _scannedBarcode;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openScanner() {
    setState(() {
      _showScanner = true;
      _isScannerActive = true;
    });
  }

  void _closeScanner() {
    setState(() {
      _showScanner = false;
      _isScannerActive = false;
      _scannedBarcode = null;
    });
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (!_isScannerActive) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;
    final code = raw.trim().replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    if (code.isEmpty) return;

    setState(() => _isScannerActive = false);
    final results = await ref.read(barcodeLookupProvider(code).future);
    if (!mounted) return;

    if (results.isEmpty) {
      setState(() {
        _showScanner = false;
        _scannedBarcode = code;
      });
      await _handleUnknownBarcode(code);
      return;
    }

    setState(() {
      _showScanner = false;
      _scannedBarcode = code;
      _searchCtrl.text = results.first.producto.nombre;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categorias = ref.watch(listCategoriasAllProvider).value ?? [];
    final categoryNameMap = {for (final cat in categorias) cat.id: cat.nombre};
    final AsyncValue<List<ProductWithStock>> asyncProducts;

    if (widget.mode == ProductSelectionMode.entry) {
      asyncProducts = ref
          .watch(listaProductosProvider)
          .whenData(
            (list) => list
                .map(
                  (p) => ProductWithStock(
                    item: p,
                    cantidad: p.stock,
                    costoPromedio: p.costoPromedio,
                  ),
                )
                .toList(),
          );
    } else {
      asyncProducts = ref
          .watch(stockDriftByBodegaProvider(widget.originWarehouseId!))
          .whenData(_groupStockByProduct);
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildCategoryChips(categorias),
            if (_showScanner) _buildInlineScanner(),
            Expanded(
              child: asyncProducts.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (allProducts) {
                  final filteredProducts = allProducts.where((item) {
                    final matchesCategory =
                        _selectedCategoryId == 'Todos' ||
                        item.item.categoriaId == _selectedCategoryId;
                    final query = _searchCtrl.text.toLowerCase();
                    final matchesSearch =
                        item.item.nombre.toLowerCase().contains(query) ||
                        item.item.sku.toLowerCase().contains(query);
                    if (widget.mode == ProductSelectionMode.transfer &&
                        item.cantidad < 1.0) {
                      return false;
                    }
                    return matchesCategory && matchesSearch;
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No se encontraron productos',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.70,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final item = filteredProducts[index];
                      final catName =
                          categoryNameMap[item.item.categoriaId] ?? 'General';
                      return _buildProductGridCard(item, catName);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() => _scannedBarcode = null),
                decoration: InputDecoration(
                  hintText: widget.mode == ProductSelectionMode.entry
                      ? 'Buscar producto para ingresar...'
                      : 'Buscar producto para trasladar...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  suffixIcon:
                      _searchCtrl.text.isNotEmpty || _scannedBarcode != null
                      ? IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.grey[500],
                          ),
                          onPressed: () {
                            setState(() {
                              _searchCtrl.clear();
                              _scannedBarcode = null;
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: _showScanner ? _closeScanner : _openScanner,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade800,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _showScanner ? Icons.close : Icons.qr_code_scanner,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(List<dynamic> categorias) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Todos', 'Todos'),
            ...categorias.map((cat) => _buildFilterChip(cat.nombre, cat.id)),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineScanner() {
    return Container(
      height: 220,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          if (_isScannerActive)
            MobileScanner(onDetect: _onBarcodeDetected)
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Apunta al codigo de barras del producto',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String id) {
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

  List<ProductWithStock> _groupStockByProduct(
    List<ProductoStockDrift> stockRows,
  ) {
    final grouped = <String, ProductWithStock>{};

    for (final row in stockRows) {
      if (!row.producto.estado ||
          !row.variante.estado ||
          !row.inventario.estado) {
        continue;
      }

      final productId = row.producto.id;
      final stock = row.inventario.cantidadActual;
      final cost = row.inventario.costoPromedio;
      final current = grouped[productId];

      if (current == null) {
        grouped[productId] = ProductWithStock(
          item: ProductCatalogItemDrift(
            producto: row.producto,
            variante: row.variante,
            stock: stock,
            costoPromedio: cost,
          ),
          cantidad: stock,
          costoPromedio: cost,
        );
        continue;
      }

      final totalStock = current.cantidad + stock;
      final weightedCost = totalStock > 0
          ? ((current.costoPromedio * current.cantidad) + (cost * stock)) /
                totalStock
          : current.costoPromedio;

      grouped[productId] = ProductWithStock(
        item: ProductCatalogItemDrift(
          producto: current.item.producto,
          variante: current.item.variante,
          stock: totalStock,
          costoPromedio: weightedCost,
        ),
        cantidad: totalStock,
        costoPromedio: weightedCost,
      );
    }

    return grouped.values.toList()
      ..sort((a, b) => a.item.nombre.compareTo(b.item.nombre));
  }

  Widget _buildProductGridCard(ProductWithStock item, String categoryName) {
    final product = item.item;
    return GestureDetector(
      onTap: () => _onProductSelected(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: _buildImageWidget(product),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Spacer(),
                    if (widget.mode == ProductSelectionMode.transfer)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Disp: ${item.cantidad.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: item.cantidad > 0
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: Colors.grey[400],
                          ),
                        ],
                      )
                    else
                      Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.add_circle,
                          color: Colors.orange.shade800,
                        ),
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

  Widget _buildImageWidget(ProductCatalogItemDrift product) {
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
      color: Colors.cyan.shade800.withValues(alpha: 0.5),
    );
  }

  Future<void> _onProductSelected(ProductWithStock item) async {
    final product = item.item;
    if (widget.mode == ProductSelectionMode.entry) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailEntryScreen(
            productId: product.id,
            categoriaId: product.categoriaId ?? '',
            preferredBarcode: _scannedBarcode == product.sku
                ? _scannedBarcode
                : null,
          ),
        ),
      );
      if (result != null && mounted) {
        Navigator.pop(context, result);
      }
      return;
    }

    final repo = ref.read(inventarioRepositoryProvider);
    final variantes = await repo.getVariantsWithStock(
      product.id,
      widget.originWarehouseId!,
    );
    if (!mounted) return;

    if (variantes.isNotEmpty) {
      final seleccion = await showModalBottomSheet<List<Map<String, dynamic>>>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) =>
            _VariantSelectorSheet(variantes: variantes, product: product),
      );

      if (seleccion != null && seleccion.isNotEmpty && mounted) {
        Navigator.pop(context, seleccion);
      }
      return;
    }

    Navigator.pop(context, [
      {
        'productId': product.id,
        'productVariantId': product.variante?.id,
        'name': product.nombre,
        'qr': product.sku,
        'size': product.talla ?? 'General',
        'cantidad': 1.0,
        'price': product.precioVenta,
        'cost': item.costoPromedio,
        'availableStock': item.cantidad,
        'image': product.imagenUrl,
      },
    ]);
  }

  Future<void> _handleUnknownBarcode(String barcode) async {
    if (!mounted) return;
    final action = await showModalBottomSheet<_UnknownBarcodeAction>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _UnknownBarcodeSheet(barcode: barcode),
    );
    if (!mounted || action == null) return;

    switch (action) {
      case _UnknownBarcodeAction.create:
        final result = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder: (context) => ProductCreateScreen(initialBarcode: barcode),
          ),
        );
        if (!mounted || result == null) return;
        await _openProductEntryFromBarcode(
          productId: result['productId'] as String,
          categoriaId: result['categoriaId'] as String?,
          barcode: barcode,
        );
        return;
      case _UnknownBarcodeAction.assign:
        final product = await showModalBottomSheet<ProductCatalogItemDrift>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => const _ProductPickerSheet(),
        );
        if (!mounted || product == null) return;
        try {
          final repo = ref.read(inventarioRepositoryProvider);
          await repo.asignarCodigoAProducto(
            productId: product.id,
            barcode: barcode,
          );
          await _openProductEntryFromBarcode(
            productId: product.id,
            categoriaId: product.categoriaId,
            barcode: barcode,
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e'), backgroundColor: Colors.red.shade700),
          );
        }
        return;
    }
  }

  Future<void> _openProductEntryFromBarcode({
    required String productId,
    required String? categoriaId,
    required String barcode,
  }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailEntryScreen(
          productId: productId,
          categoriaId: categoriaId ?? '',
          preferredBarcode: barcode,
        ),
      ),
    );
    if (result != null && mounted) {
      Navigator.pop(context, result);
    }
  }
}

enum _UnknownBarcodeAction { create, assign }

class _UnknownBarcodeSheet extends StatelessWidget {
  final String barcode;

  const _UnknownBarcodeSheet({required this.barcode});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Codigo no registrado',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              barcode,
              style: TextStyle(
                color: Colors.cyan.shade800,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.shade50,
                child: Icon(
                  Icons.add_box_outlined,
                  color: Colors.orange.shade800,
                ),
              ),
              title: const Text('Crear producto desde cero'),
              subtitle: const Text('El codigo quedara como SKU inicial'),
              onTap: () => Navigator.pop(context, _UnknownBarcodeAction.create),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.cyan.shade50,
                child: Icon(Icons.link, color: Colors.cyan.shade800),
              ),
              title: const Text('Asignar a producto existente'),
              subtitle: const Text(
                'Agrega otro codigo al producto seleccionado',
              ),
              onTap: () => Navigator.pop(context, _UnknownBarcodeAction.assign),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductPickerSheet extends ConsumerStatefulWidget {
  const _ProductPickerSheet();

  @override
  ConsumerState<_ProductPickerSheet> createState() =>
      _ProductPickerSheetState();
}

class _ProductPickerSheetState extends ConsumerState<_ProductPickerSheet> {
  final TextEditingController _filterCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _filterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(listaProductosProvider);

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: TextField(
                controller: _filterCtrl,
                autofocus: true,
                onChanged: (value) =>
                    setState(() => _query = value.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Buscar producto existente...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: productsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (products) {
                  final filtered = products.where((product) {
                    return product.nombre.toLowerCase().contains(_query) ||
                        product.sku.toLowerCase().contains(_query);
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'No se encontraron productos',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      return ListTile(
                        title: Text(product.nombre),
                        subtitle: Text(product.sku),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pop(context, product),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VariantSelectorSheet extends StatefulWidget {
  final List<Map<String, dynamic>> variantes;
  final ProductCatalogItemDrift product;

  const _VariantSelectorSheet({required this.variantes, required this.product});

  @override
  State<_VariantSelectorSheet> createState() => _VariantSelectorSheetState();
}

class _VariantSelectorSheetState extends State<_VariantSelectorSheet> {
  final Map<String, double> _quantities = {};

  @override
  void initState() {
    super.initState();
    final grouped = _groupVariants();
    for (final key in grouped.keys) {
      _quantities[key] = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupVariants();
    final tiposItems = _quantities.values.where((q) => q > 0).length;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Tallas: ${widget.product.nombre}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: grouped.keys.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final key = grouped.keys.elementAt(index);
                final items = grouped[key]!;
                final parts = key.split('_#_');
                final talla = parts[0];
                final costoGrp = double.tryParse(parts[1]) ?? 0.0;
                final precioGrp = double.tryParse(parts[2]) ?? 0.0;
                double totalStock = 0;
                for (final i in items) {
                  totalStock += (i['cantidad'] as num).toDouble();
                }
                final currentQty = _quantities[key] ?? 0.0;
                final hasStock = totalStock > 0;

                return ListTile(
                  title: Text(
                    talla,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Costo: ${costoGrp.toStringAsFixed(0)} | Venta: ${precioGrp.toStringAsFixed(0)} | Disp: ${totalStock.toInt()}',
                  ),
                  trailing: !hasStock
                      ? const Text('Agotado')
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red,
                              ),
                              onPressed: currentQty > 0
                                  ? () => setState(
                                      () => _quantities[key] = currentQty - 1,
                                    )
                                  : null,
                            ),
                            Text(currentQty.toInt().toString()),
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle,
                                color: Colors.green,
                              ),
                              onPressed: currentQty < totalStock
                                  ? () => setState(
                                      () => _quantities[key] = currentQty + 1,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: tiposItems > 0 ? _confirmSelection : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tiposItems > 0
                      ? Colors.cyan.shade800
                      : Colors.grey,
                ),
                child: const Text(
                  'AGREGAR SELECCION',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupVariants() {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final v in widget.variantes) {
      final talla = (v['talla'] as String?) ?? 'U';
      final costo =
          ((v['costoPromedio'] ?? v['costo']) as num?)?.toDouble() ?? 0.0;
      final precioEspecifico =
          ((v['precioEspecifico']) as num?)?.toDouble() ?? 0.0;
      final precioFallback = ((v['precio']) as num?)?.toDouble() ?? 0.0;
      final precio = precioEspecifico > 0
          ? precioEspecifico
          : precioFallback > 0
          ? precioFallback
          : widget.product.precioVenta;
      final key = '${talla}_#_${costo}_#_$precio';
      grouped.putIfAbsent(key, () => []).add(v);
    }
    return grouped;
  }

  void _confirmSelection() {
    final seleccionados = <Map<String, dynamic>>[];
    final grouped = _groupVariants();
    grouped.forEach((key, items) {
      var qtyNeeded = _quantities[key] ?? 0.0;
      if (qtyNeeded <= 0) return;
      for (final item in items) {
        if (qtyNeeded <= 0) break;
        final stockItem = (item['cantidad'] as num).toDouble();
        if (stockItem <= 0) continue;
        final toTake = qtyNeeded > stockItem ? stockItem : qtyNeeded;
        seleccionados.add({
          'productId': widget.product.id,
          'productVariantId': item['varianteId'],
          'name': widget.product.nombre,
          'qr': item['sku'],
          'size': item['talla'],
          'cantidad': toTake,
          'availableStock': stockItem,
          'cost':
              ((item['costoPromedio'] ?? item['costo']) as num?)?.toDouble() ??
              0.0,
          'price':
              ((item['precioEspecifico'] ?? item['precio']) as num?)
                  ?.toDouble() ??
              widget.product.precioVenta,
          'image': widget.product.imagenUrl,
        });
        qtyNeeded -= toTake;
      }
    });
    Navigator.pop(context, seleccionados);
  }
}
