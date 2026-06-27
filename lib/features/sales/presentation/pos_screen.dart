import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:inventario_v2/core/presentation/mixins/app_bar_config_mixin.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/bodega_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/inventario_provider.dart';
import 'package:inventario_v2/features/inventory/data/repositories/inventario_repository.dart';
import 'package:inventario_v2/features/inventory/presentation/providers/warehouse_inventory_provider.dart'
    show warehouseInventoryProvider;
import 'package:inventario_v2/features/inventory/presentation/screens/barcode_capture_screen.dart';
import 'package:inventario_v2/features/sales/presentation/cash_register_screen.dart';
import 'package:inventario_v2/features/sales/presentation/checkout_screen.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> with AppBarConfigMixin {
  final List<Map<String, dynamic>> _cart = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  @override
  void configureAppBar() {
    ref.read(appBarProvider.notifier).setOptions(
      title: 'Punto de Venta',
      showBackButton: true,
      actions: [
        IconButton(
          onPressed: _clearCart,
          icon: const Icon(Icons.delete_sweep, color: Colors.red),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(
        () => _searchQuery = _searchController.text.trim().toLowerCase(),
      );
    });
    Future.microtask(configureAppBar);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  double get _subtotal => _cart.fold(
    0.0,
    (sum, item) =>
        sum +
        (((item['price'] as num?)?.toDouble() ?? 0.0) *
            ((item['qty'] as num?)?.toDouble() ?? 0.0)),
  );

  double get _total => _subtotal;

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return dashboardAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (dashboardState) {
        if (dashboardState.cajaAbierta == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Punto de Venta')),
            body: Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CashRegisterScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.point_of_sale),
                label: const Text('ABRIR CAJA'),
              ),
            ),
          );
        }

        final selectedBodega = ref.watch(selectedBodegaProvider);
        if (selectedBodega == null) {
          return const _BodegaSelectorView();
        }

        final inventoryAsync = ref.watch(
          warehouseInventoryProvider(selectedBodega.serverId),
        );

        return inventoryAsync.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
          data: (items) {
            final groupedProducts = _buildGroupedProducts(items);
            final filteredProducts = groupedProducts.where((item) {
              if (_searchQuery.isEmpty) return true;
              return item.nombre.toLowerCase().contains(_searchQuery) ||
                  item.skus.any(
                    (sku) => sku.toLowerCase().contains(_searchQuery),
                  );
            }).toList();

            return Scaffold(
              backgroundColor: Colors.grey[100],
              body: Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.white,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(_cart.clear);
                                ref
                                        .read(selectedBodegaProvider.notifier)
                                        .state =
                                    null;
                              },
                              icon: const Icon(
                                Icons.warehouse,
                                color: Colors.blue,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bodega: ${selectedBodega.nombre}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TextField(
                                    controller: _searchController,
                                    focusNode: _searchFocusNode,
                                    textInputAction: TextInputAction.search,
                                    onSubmitted: (_) =>
                                        _handleScannedProduct(items),
                                    decoration: InputDecoration(
                                      hintText:
                                          'Buscar o escanear producto...',
                                      prefixIcon: const Icon(Icons.search),
                                      suffixIcon: Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: IconButton(
                                          onPressed: () =>
                                              _openBarcodeScanner(items),
                                          icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: filteredProducts.isEmpty
                            ? const Center(
                                child: Text('No se encontraron productos'),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  120,
                                ),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.68,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = filteredProducts[index];
                                  return _ProductGridCard(
                                    product: product,
                                    onTap: () => _showProductModal(
                                      product.productoId,
                                      product.nombre,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                  if (_cart.isNotEmpty)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: _showCartDetails,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.blue[800],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${_cart.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Total a cobrar',
                                        style: TextStyle(color: Colors.white70, fontSize: 13),
                                      ),
                                      Text(
                                        NumberFormat.simpleCurrency().format(_total),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: const [
                                    Text(
                                      'COBRAR',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<_GroupedInventoryItem> _buildGroupedProducts(List<InventarioDTO> items) {
    final grouped = <String, _GroupedInventoryItem>{};

    for (final item in items) {
      final existing = grouped[item.productoId];
      if (existing == null) {
        grouped[item.productoId] = _GroupedInventoryItem.fromDto(item);
      } else {
        grouped[item.productoId] = existing.merge(item);
      }
    }

    final result = grouped.values.toList()
      ..sort(
        (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
      );
    return result;
  }

  Future<void> _openBarcodeScanner(List<InventarioDTO> inventoryItems) async {
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeCaptureScreen()),
    );
    if (code == null || code.isEmpty) {
      _searchFocusNode.requestFocus();
      return;
    }
    _searchController.text = code;
    await _processScannedCode(code, inventoryItems);
  }

  Future<void> _processScannedCode(
    String code,
    List<InventarioDTO> inventoryItems,
  ) async {
    final repo = ref.read(inventarioRepositoryProvider);
    final lookup = await repo.buscarProductoPorCodigoONombre(code);
    if (lookup == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró un producto con ese código'),
        ),
      );
      return;
    }
    await _showProductModal(lookup.productId, lookup.nombre);
  }

  Future<void> _handleScannedProduct(List<InventarioDTO> inventoryItems) async {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return;

    final exactMatches = inventoryItems.where((item) {
      return item.sku.toLowerCase() == query ||
          item.nombre.toLowerCase() == query ||
          '${item.nombre} ${item.talla}'.toLowerCase() == query;
    }).toList();

    if (exactMatches.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontro un producto con ese codigo o nombre.'),
        ),
      );
      return;
    }

    if (exactMatches.length == 1) {
      final item = exactMatches.first;
      final success = _addToCart(
        productId: item.productoId,
        variantId: item.varianteId,
        sku: item.sku,
        name: item.nombre,
        size: item.talla,
        color: item.color,
        price: item.precio,
        qty: 1,
        stock: item.stock,
      );
      if (success) {
        _searchController.clear();
        _searchFocusNode.requestFocus();
        _showSuccessSnackbar(item.nombre);
      }
      return;
    }

    await _showProductModal(
      exactMatches.first.productoId,
      exactMatches.first.nombre,
    );
  }

  Future<void> _showProductModal(String productId, String productName) async {
    final selectedBodega = ref.read(selectedBodegaProvider);
    if (selectedBodega == null) return;

    final repo = ref.read(inventarioRepositoryProvider);
    final variants = await repo.getVariantsWithStock(
      productId,
      selectedBodega.serverId,
    );

    if (!mounted) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ProductDetailModal(
        productName: productName,
        variants: variants,
        onAddToCart: (variant, qty) {
          Navigator.pop(context);
          final success = _addToCart(
            productId: productId,
            variantId: variant['varianteId']?.toString(),
            sku: variant['sku']?.toString() ?? productId,
            name: productName,
            size: variant['talla']?.toString() ?? 'General',
            color: variant['color']?.toString(),
            price: (variant['precio'] as num?)?.toDouble() ?? 0.0,
            qty: qty,
            stock: (variant['stock'] as num?)?.toDouble() ?? 0.0,
          );
          if (success) {
            _searchController.clear();
            _searchFocusNode.requestFocus();
            _showSuccessSnackbar(productName);
          }
        },
      ),
    );
  }

  bool _addToCart({
    required String productId,
    required String? variantId,
    required String sku,
    required String name,
    required String size,
    required String? color,
    required double price,
    required int qty,
    required double stock,
  }) {
    final existingIndex = _cart.indexWhere(
      (item) => item['variantId'] == variantId && item['id'] == productId,
    );

    if (existingIndex >= 0) {
      final currentQty = (_cart[existingIndex]['qty'] as num?)?.toInt() ?? 0;
      if (currentQty + qty > stock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stock insuficiente para $name ($size).'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      setState(() {
        _cart[existingIndex]['qty'] = currentQty + qty;
      });
      return true;
    }

    if (qty > stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stock insuficiente para $name ($size).'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    setState(() {
      _cart.add({
        'id': productId,
        'variantId': variantId,
        'sku': sku,
        'name': name,
        'size': size,
        'color': color,
        'price': price,
        'qty': qty,
        'stock': stock,
      });
    });
    return true;
  }

  OverlayEntry? _successOverlay;

  void _showSuccessSnackbar(String productName) {
    _successOverlay?.remove();
    _successOverlay = null;

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + kToolbarHeight + 10,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$productName agregado al carrito',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    _successOverlay = overlayEntry;
    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _successOverlay == overlayEntry) {
        _successOverlay?.remove();
        _successOverlay = null;
      }
    });
  }

  void _showCartDetails() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          cartItems: _cart,
          subtotal: _subtotal,
          tax: 0.0,
          total: _total,
        ),
      ),
    );

    if (result == true) {
      setState(_cart.clear);
    }
  }

  void _clearCart() => setState(_cart.clear);
}

class _GroupedInventoryItem {
  final String productoId;
  final String nombre;
  final String categoria;
  final String? imagen;
  final double stock;
  final double precioMinimo;
  final List<String> skus;

  const _GroupedInventoryItem({
    required this.productoId,
    required this.nombre,
    required this.categoria,
    required this.imagen,
    required this.stock,
    required this.precioMinimo,
    required this.skus,
  });

  factory _GroupedInventoryItem.fromDto(InventarioDTO item) {
    return _GroupedInventoryItem(
      productoId: item.productoId,
      nombre: item.nombre,
      categoria: item.categoria,
      imagen: item.imagen,
      stock: item.stock,
      precioMinimo: item.precio,
      skus: [item.sku],
    );
  }

  _GroupedInventoryItem merge(InventarioDTO item) {
    return _GroupedInventoryItem(
      productoId: productoId,
      nombre: nombre,
      categoria: categoria,
      imagen: imagen,
      stock: stock + item.stock,
      precioMinimo: item.precio < precioMinimo ? item.precio : precioMinimo,
      skus: [...skus, item.sku],
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  final _GroupedInventoryItem product;
  final VoidCallback onTap;

  const _ProductGridCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: product.imagen != null && product.imagen!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            product.imagen!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(child: Icon(Icons.inventory_2, size: 40, color: Colors.grey[300])),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                product.nombre,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                NumberFormat.simpleCurrency().format(product.precioMinimo),
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.green[700]),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: product.stock > 0 ? Colors.blue[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Stock: ${product.stock.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: product.stock > 0 ? Colors.blue[800] : Colors.red[800], 
                    fontWeight: FontWeight.bold, 
                    fontSize: 11
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductDetailModal extends StatefulWidget {
  final String productName;
  final List<Map<String, dynamic>> variants;
  final void Function(Map<String, dynamic> variant, int qty) onAddToCart;

  const _ProductDetailModal({
    required this.productName,
    required this.variants,
    required this.onAddToCart,
  });

  @override
  State<_ProductDetailModal> createState() => _ProductDetailModalState();
}

class _ProductDetailModalState extends State<_ProductDetailModal> {
  int _qty = 1;
  int _selectedIndex = 0;
  late TextEditingController _precioController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _initialSelectedIndex();
    final initialVariant = widget.variants.isNotEmpty
        ? widget.variants[_selectedIndex]
        : null;
    final initialPrice = initialVariant != null
        ? (initialVariant['precio'] as num?)?.toDouble() ?? 0.0
        : 0.0;
    _precioController = TextEditingController(
      text: initialPrice.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _precioController.dispose();
    super.dispose();
  }

  int _initialSelectedIndex() {
    final firstWithStock = widget.variants.indexWhere(_hasStock);
    return firstWithStock >= 0 ? firstWithStock : 0;
  }

  static double _stockOf(Map<String, dynamic> variant) {
    return (variant['stock'] as num?)?.toDouble() ?? 0.0;
  }

  static bool _hasStock(Map<String, dynamic> variant) {
    return _stockOf(variant) > 0;
  }

  void _onVariantChanged(int index) {
    final stock = _stockOf(widget.variants[index]);
    setState(() {
      _selectedIndex = index;
      final maxQty = stock.toInt();
      if (maxQty > 0 && _qty > maxQty) {
        _qty = maxQty;
      } else if (maxQty <= 0) {
        _qty = 1;
      }
    });
    final price = (widget.variants[index]['precio'] as num?)?.toDouble() ?? 0.0;
    _precioController.text = price.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final variants = widget.variants;
    final current = variants.isEmpty ? null : variants[_selectedIndex];
    final currentStock = current == null ? 0.0 : _stockOf(current);
    final canAddCurrent = current != null && currentStock >= _qty;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.productName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            if (variants.isEmpty)
              const Text('No hay variantes disponibles para este producto.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(variants.length, (index) {
                  final variant = variants[index];
                  final hasStock = _hasStock(variant);
                  final isSelected = index == _selectedIndex;
                  final label = variant['talla']?.toString() ?? 'General';
                  return InkWell(
                    onTap: hasStock ? () => _onVariantChanged(index) : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Colors.blue[600] 
                            : (hasStock ? Colors.grey[200] : Colors.grey[100]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        hasStock ? label : '$label (Sin stock)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected 
                              ? Colors.white 
                              : (hasStock ? Colors.black87 : Colors.grey[400]),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            const SizedBox(height: 16),
            if (current != null) ...[
              Text('SKU: ${current['sku']}'),
              Text('Color: ${current['color'] ?? 'N/A'}'),
              Text('Disponible: ${current['stock']}'),
              if (currentStock <= 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Esta variante no tiene stock disponible.',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _precioController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Precio de venta',
                  prefixText: 'C\$ ',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Cantidad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      InkWell(
                        onTap: _qty > 1 ? () => setState(() => _qty--) : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _qty > 1 ? Colors.blue[50] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.remove, size: 24, color: _qty > 1 ? Colors.blue[800] : Colors.grey[400]),
                        ),
                      ),
                      Container(
                        width: 60,
                        alignment: Alignment.center,
                        child: Text(
                          '$_qty',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
                        ),
                      ),
                      InkWell(
                        onTap: _qty < currentStock.toInt() ? () => setState(() => _qty++) : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _qty < currentStock.toInt() ? Colors.blue[50] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.add, size: 24, color: _qty < currentStock.toInt() ? Colors.blue[800] : Colors.grey[400]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: !canAddCurrent
                    ? null
                    : () {
                        final editedPrice =
                            double.tryParse(_precioController.text) ??
                            (current['precio'] as num?)?.toDouble() ??
                            0.0;
                        widget.onAddToCart({
                          ...current,
                          'precio': editedPrice,
                        }, _qty);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.shopping_cart, size: 22),
                label: const Text(
                  'AGREGAR AL CARRITO',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BodegaSelectorView extends ConsumerWidget {
  const _BodegaSelectorView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodegasAsync = ref.watch(bodegaListProvider);

    return Scaffold(
      body: bodegasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (bodegas) {
          if (bodegas.isEmpty) {
            return const Center(
              child: Text(
                'No hay bodegas disponibles.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            );
          }

          if (bodegas.length == 1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (ref.read(selectedBodegaProvider) == null) {
                ref.read(selectedBodegaProvider.notifier).state = bodegas.first;
              }
            });
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bodegas.length,
            itemBuilder: (context, index) {
              final bodega = bodegas[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: () {
                    ref.read(selectedBodegaProvider.notifier).state = bodega;
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.warehouse, color: Colors.blue, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            bodega.nombre,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
