import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:inventario_v2/features/inventory/data/domain/models/product_with_stock.dart';
import 'package:inventario_v2/features/inventory/data/collections/producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/providers/categoria_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/producto_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/codigo_producto_provider.dart';

import 'product_detail_entry_screen.dart';

enum ProductSelectionMode { entry, transfer }

class ProductSelectionScreen extends ConsumerStatefulWidget {
  final ProductSelectionMode mode;
  final String? originWarehouseId;

  const ProductSelectionScreen({
    super.key,
    required this.mode,
    this.originWarehouseId,
    // Compatibilidad temporal (deprecado)
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
  String _selectedCategoryId = "Todos";
  final TextEditingController _searchCtrl = TextEditingController();

  // ── Escáner ──────────────────────────────────────────────────────────────
  bool _showScanner = false;
  bool _isScannerActive = true;
  String? _scannedBarcode; // código encontrado, usado para filtrar

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // Abre el panel del escáner
  void _openScanner() {
    setState(() {
      _showScanner = true;
      _isScannerActive = true;
    });
  }

  // Cierra el escáner y limpia
  void _closeScanner() {
    setState(() {
      _showScanner = false;
      _isScannerActive = false;
      _scannedBarcode = null;
    });
  }

  // Callback cuando la cámara detecta un código
  void _onBarcodeDetected(BarcodeCapture capture) async {
    if (!_isScannerActive) return;

    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;

    final code = raw.trim().replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    if (code.isEmpty) return;

    // Pausar escáner
    setState(() => _isScannerActive = false);

    // Buscar si existe algún producto con ese código
    final repoCodigo =
        await ref.read(codigoProductoRepositoryProvider.future);
    final codigos = await repoCodigo.getCodigosBySkuOBarcode(code);

    if (!mounted) return;

    if (codigos.isEmpty) {
      // No se encontraron productos — mostrar mensaje y permitir re-escanear
      setState(() {
        _scannedBarcode = code; // guarda el código para mostrar "sin resultado"
        _showScanner = false;
      });
      _showNoBarcodeSnackbar(code);
    } else {
      // Encontrado: filtrar la lista de productos por los productos encontrados
      final productoIds = codigos.map((c) => c.productoId).toSet();

      // Usamos el nombre del primer producto como filtro de búsqueda si solo hay 1
      final repoProducto =
          await ref.read(productoRepositoryProvider.future);

      String filterText = '';
      if (productoIds.length == 1) {
        try {
          final prod =
              await repoProducto.getProductoPorServerId(productoIds.first);
          filterText = prod.nombre;
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() {
        _showScanner = false;
        _scannedBarcode = code;
        if (filterText.isNotEmpty) {
          _searchCtrl.text = filterText;
        }
      });
    }
  }

  void _showNoBarcodeSnackbar(String code) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.search_off, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'No se encontró ningún producto con el código: $code',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'RE-ESCANEAR',
          textColor: Colors.white,
          onPressed: _openScanner,
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Cargar Categorías
    final asyncCategorias = ref.watch(listCategoriasAllProvider);
    final listaCategorias = asyncCategorias.value ?? [];
    final categoryNameMap = {
      for (var cat in listaCategorias) cat.serverId: cat.nombre,
    };

    // 2. Cargar Productos según MODO
    final AsyncValue<List<ProductWithStock>> asyncProducts;

    if (widget.mode == ProductSelectionMode.entry) {
      final allProductsAsync = ref.watch(listaProductosProvider);
      asyncProducts = allProductsAsync.whenData((list) {
        return list
            .map((p) => ProductWithStock(producto: p, cantidad: 0))
            .toList();
      });
    } else {
      asyncProducts = ref.watch(
        productsWithStockProvider(widget.originWarehouseId!),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // ── Barra superior (sin AppBar nativo) ──────────────────────
            _buildHeader(context),

            // ── Filtros de categoría ─────────────────────────────────────
            _buildCategoryChips(listaCategorias),

            // ── Escáner inline ──────────────────────────────────────────
            if (_showScanner) _buildInlineScanner(),

            // ── Grid de productos ────────────────────────────────────────
            Expanded(
              child: asyncProducts.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Center(child: Text('Error: $err')),
                data: (allProducts) {
                  final filteredProducts = allProducts.where((item) {
                    final matchesCategory =
                        _selectedCategoryId == "Todos" ||
                        item.producto.categoriaId == _selectedCategoryId;

                    final matchesSearch = item.producto.nombre
                        .toLowerCase()
                        .contains(_searchCtrl.text.toLowerCase());

                    // En modo Traslado, solo productos con stock
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
                            "No se encontraron productos",
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 15,
                            ),
                          ),
                          if (_scannedBarcode != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Código escaneado: $_scannedBarcode',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
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
                          categoryNameMap[item.producto.categoriaId] ??
                          'General';
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

  // ── Header: búsqueda + escanear ──────────────────────────────────────────
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
          // Botón regresar
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Campo de búsqueda
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {
                  _scannedBarcode = null; // limpiar filtro de escáner al escribir
                }),
                decoration: InputDecoration(
                  hintText: widget.mode == ProductSelectionMode.entry
                      ? "Buscar producto para ingresar..."
                      : "Buscar producto para trasladar...",
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[400],
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  // Botón limpiar (cuando hay texto o código escaneado)
                  suffixIcon: _searchCtrl.text.isNotEmpty || _scannedBarcode != null
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

          // Botón escáner de código de barras
          _showScanner
              ? InkWell(
                  onTap: _closeScanner,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade800,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                )
              : InkWell(
                  onTap: _openScanner,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade800,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // ── Chips de categoría ───────────────────────────────────────────────────
  Widget _buildCategoryChips(List<dynamic> categorias) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip("Todos", "Todos"),
            ...categorias.map(
              (cat) => _buildFilterChip(cat.nombre, cat.serverId),
            ),
          ],
        ),
      ),
    );
  }

  // ── Escáner inline ───────────────────────────────────────────────────────
  Widget _buildInlineScanner() {
    return Container(
      height: 220,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Cámara
          if (_isScannerActive)
            MobileScanner(onDetect: _onBarcodeDetected)
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),

          // Marco de esquinas estilo profesional
          if (_isScannerActive) ...[
            _ScanCorner(left: 12, top: 12),
            _ScanCorner(right: 12, top: 12, flipH: true),
            _ScanCorner(left: 12, bottom: 12, flipV: true),
            _ScanCorner(right: 12, bottom: 12, flipH: true, flipV: true),
          ],

          // Texto guía
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
                  "Apunta al código de barras del producto",
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
    final isTransfer = widget.mode == ProductSelectionMode.transfer;

    final bool isDisabled = isTransfer && stock <= 0;

    return GestureDetector(
      onTap: isDisabled ? null : () => _onProductSelected(item),
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: isDisabled
                ? Border.all(color: Colors.red.shade100, width: 2)
                : null,
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
              // Imagen
              Expanded(
                flex: 3,
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

              // Info
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

                      if (isTransfer)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (stock <= 0)
                              const Text(
                                "SIN STOCK",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            else
                              Text(
                                "Disp: ${stock.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.green,
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
      color: Colors.cyan.shade800.withValues(alpha: 0.5),
    );
  }

  void _onProductSelected(ProductWithStock item) async {
    final product = item.producto;

    if (widget.mode == ProductSelectionMode.entry) {
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
    } else {
      final repo = await ref.read(productoRepositoryProvider.future);
      try {
        final variantes = await repo.getStockPorVariante(
          bodegaId: widget.originWarehouseId!,
          productoId: product.serverId,
        );

        if (variantes.isNotEmpty) {
          if (!mounted) return;
          final List<Map<String, dynamic>>? seleccion =
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (ctx) => _VariantSelectorSheet(
                  variantes: variantes,
                  product: product,
                ),
              );

          if (seleccion != null && seleccion.isNotEmpty && mounted) {
            Navigator.pop(context, seleccion);
          }
          return;
        }
      } catch (e) {
        debugPrint("Error consultando variantes: $e");
      }

      if (!mounted) return;
      final result = [
        {
          'productId': product.serverId,
          'name': product.nombre,
          'qr': "MANUAL-SELECT",
          'size': "U",
          'cantidad': 1.0,
          'price': product.ultimoPrecioVenta,
          'cost': item.costoPromedio,
          'availableStock': item.cantidad,
          'image': product.imagenUrl,
        },
      ];
      Navigator.pop(context, result);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Esquinas decorativas del marco de escaneo
// ─────────────────────────────────────────────────────────────────────────────
class _ScanCorner extends StatelessWidget {
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  final bool flipH;
  final bool flipV;

  const _ScanCorner({
    this.left,
    this.right,
    this.top,
    this.bottom,
    this.flipH = false,
    this.flipV = false,
  });

  @override
  Widget build(BuildContext context) {
    const double size = 20.0;
    const double thickness = 3.0;

    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Transform.scale(
        scaleX: flipH ? -1 : 1,
        scaleY: flipV ? -1 : 1,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: size,
                  height: thickness,
                  color: Colors.orange,
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: thickness,
                  height: size,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Selector de variantes / tallas (sin cambios)
// ─────────────────────────────────────────────────────────────────────────────
class _VariantSelectorSheet extends StatefulWidget {
  final List<Map<String, dynamic>> variantes;
  final ProductoCollection product;

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
    for (var key in grouped.keys) {
      _quantities[key] = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupVariants();
    int tiposItems = _quantities.values.where((q) => q > 0).length;

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
                    "Tallas: ${widget.product.nombre}",
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
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final key = grouped.keys.elementAt(index);
                final items = grouped[key]!;

                final parts = key.split('_#_');
                final talla = parts[0];
                final costoGrp = double.tryParse(parts[1]) ?? 0.0;
                final precioGrp = double.tryParse(parts[2]) ?? 0.0;

                double totalStock = 0;
                for (var i in items) {
                  totalStock += (i['cantidad'] as num).toDouble();
                }

                final currentQty = _quantities[key] ?? 0.0;
                final bool hasStock = totalStock > 0;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  color: currentQty > 0
                      ? Colors.blue.withValues(alpha: 0.05)
                      : null,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    talla,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (items.length > 1)
                                  Text(
                                    "(${items.length} lotes)",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[500],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              children: [
                                Text(
                                  "Costo: ${costoGrp.toStringAsFixed(0)}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  "Venta: ${precioGrp.toStringAsFixed(0)}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Disp: ${totalStock.toInt()}",
                              style: TextStyle(
                                fontSize: 12,
                                color: hasStock ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: !hasStock
                            ? const Center(
                                child: Text(
                                  "Agotado",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: currentQty > 0
                                        ? () {
                                            setState(() {
                                              _quantities[key] = currentQty - 1;
                                            });
                                          }
                                        : null,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  SizedBox(
                                    width: 30,
                                    child: Center(
                                      child: Text(
                                        currentQty.toInt().toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle,
                                      color: Colors.green,
                                    ),
                                    onPressed: currentQty < totalStock
                                        ? () {
                                            setState(() {
                                              _quantities[key] = currentQty + 1;
                                            });
                                          }
                                        : null,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: tiposItems > 0
                      ? Colors.cyan.shade800
                      : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: tiposItems > 0 ? _confirmSelection : null,
                child: const Text(
                  "AGREGAR SELECCIÓN",
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
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var v in widget.variantes) {
      final t = (v['talla'] as String?) ?? "U";
      final costo = v['costoPromedio'] != null
          ? (v['costoPromedio'] as num).toDouble()
          : 0.0;
      final precio = v['precioEspecifico'] != null
          ? (v['precioEspecifico'] as num).toDouble()
          : widget.product.ultimoPrecioVenta;

      final key = "${t}_#_${costo}_#_$precio";

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(v);
    }
    return grouped;
  }

  void _confirmSelection() {
    List<Map<String, dynamic>> seleccionados = [];
    final grouped = _groupVariants();

    grouped.forEach((key, items) {
      double qtyNeeded = _quantities[key] ?? 0.0;
      if (qtyNeeded > 0) {
        for (var item in items) {
          if (qtyNeeded <= 0) break;

          double stockItem = (item['cantidad'] as num).toDouble();
          if (stockItem <= 0) continue;

          double toTake = qtyNeeded;
          if (toTake > stockItem) {
            toTake = stockItem;
          }

          seleccionados.add({
            'productId': widget.product.serverId,
            'name': widget.product.nombre,
            'qr': item['sku'],
            'size': item['talla'],
            'cantidad': toTake,
            'availableStock': stockItem,
            'cost': (item['costoPromedio'] as num).toDouble(),
            'price':
                item['precioEspecifico'] ??
                widget.product.ultimoPrecioVenta,
            'image': widget.product.imagenUrl,
          });

          qtyNeeded -= toTake;
        }
      }
    });

    Navigator.pop(context, seleccionados);
  }
}
