import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/core/providers/database_provider.dart';
import 'package:inventario_v2/features/inventory/data/collections/producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/providers/bodega_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/inventario_provider.dart';
import '../../inventory/presentation/screens/barcode_capture_screen.dart';
import 'package:inventario_v2/features/inventory/data/collections/codigo_producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/inventario_collection.dart';
import 'checkout_screen.dart';
import 'package:go_router/go_router.dart';
import 'sales_dashboard_screen.dart';
import 'package:inventario_v2/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:inventario_v2/features/sales/presentation/cash_register_screen.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  // Carrito de Compras
  final List<Map<String, dynamic>> _cart = [];
  bool _isLoadingProduct = false;

  // Búsqueda
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    // Configuración del AppBar Global
    Future.microtask(() {
      ref
          .read(appBarProvider.notifier)
          .setOptions(
            title: "Punto de Venta",
            showBackButton: true,
            actions: [
              IconButton(
                onPressed: _clearCart,
                icon: const Icon(Icons.delete_sweep, color: Colors.red),
                tooltip: "Limpiar Carrito",
              ),
            ],
          );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // CÁLCULOS
  double get _subtotal =>
      _cart.fold(0.0, (sum, item) => sum + (item['price'] * item['qty']));
  double get _tax => 0.0; // IVA omitido
  double get _total => _subtotal;

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return dashboardAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (dashboardState) {
        if (dashboardState.cajaAbierta == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Punto de Venta")),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  const Text(
                    "La caja está cerrada",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Abre la caja para comenzar a realizar ventas.",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CashRegisterScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.point_of_sale),
                    label: const Text("ABRIR CAJA"),
                  ),
                ],
              ),
            ),
          );
        }

        final selectedBodega = ref.watch(selectedBodegaProvider);

        if (selectedBodega == null) {
          return const _BodegaSelectorView();
        }

        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: Stack(
            children: [
              Column(
                children: [
                  // 1. BARRA SUPERIOR (BUSCADOR + SCAN)
                  Container(
                    padding: const EdgeInsets.only(
                      top: 16,
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.warehouse, color: Colors.blue),
                          onPressed: () {
                            setState(
                              () => _cart.clear(),
                            ); // Limpia carrito al cambiar bodega para evitar discrepancias
                            ref.read(selectedBodegaProvider.notifier).state =
                                null;
                          },
                          tooltip: "Cambiar Bodega",
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Bodega: ${selectedBodega.nombre}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: "Buscar producto...",
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: Colors.grey,
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () =>
                                              _searchController.clear(),
                                        )
                                      : (_isLoadingProduct
                                            ? Transform.scale(
                                                scale: 0.5,
                                                child:
                                                    const CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : null),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                ),
                                onSubmitted: (val) =>
                                    _handleScannedProduct(val),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton.filled(
                          onPressed: _openScanner,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(12),
                          ),
                          icon: const Icon(
                            Icons.qr_code_scanner,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. LISTA DE PRODUCTOS (CATÁLOGO)
                  Expanded(
                    child: FutureBuilder<List<ProductoCollection>>(
                      future: _loadProducts(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 60,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "No se encontraron productos",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          );
                        }

                        final products = snapshot.data!;
                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.70,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            return _ProductGridCard(
                              product: products[index],
                              onTap: () => _showProductModal(products[index]),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),

              // 3. BARRA FLOTANTE DEL CARRITO (SI HAY ITEMS)
              if (_cart.isNotEmpty)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Material(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[900],
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
                              "${_cart.fold<int>(0, (sum, item) => sum + (item['qty'] as int))}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Total",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                NumberFormat.simpleCurrency().format(_total),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _showCartDetails,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.shopping_cart),
                            label: const Text("Ver Carrito"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // --- MÉTODOS DE AYUDA ---

  Future<List<ProductoCollection>> _loadProducts() async {
    final isar = await ref.read(isarDbProvider.future);
    final selectedBodega = ref.read(selectedBodegaProvider);
    final bodegaId = selectedBodega?.serverId ?? '';

    // Obtener IDs de productos con stock >= 1 en la bodega seleccionada
    final inventarios = await isar.inventarioCollections
        .filter()
        .bodegaIdEqualTo(bodegaId)
        .cantidadActualGreaterThan(0.999)
        .findAll();

    final productoIds = inventarios.map((i) => i.productoId).toSet();
    if (productoIds.isEmpty) return [];

    if (_searchQuery.isEmpty) {
      // Traer solo los productos que tienen stock en esta bodega
      final todos = await isar.productoCollections
          .filter()
          .estadoEqualTo(true)
          .findAll();
      return todos
          .where((p) => productoIds.contains(p.serverId))
          .take(50)
          .toList();
    } else {
      final encontrados = await isar.productoCollections
          .filter()
          .estadoEqualTo(true)
          .and()
          .group(
            (q) => q
                .nombreContains(_searchQuery, caseSensitive: false)
                .or()
                .codigoPersonalizadoContains(
                  _searchQuery,
                  caseSensitive: false,
                ),
          )
          .findAll();
      return encontrados
          .where((p) => productoIds.contains(p.serverId))
          .toList();
    }
  }

  Future<void> _handleScannedProduct(String rawSku) async {
    if (rawSku.isEmpty) return;

    // Normalizar igual que el scanner
    final sku = rawSku.trim().replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    if (sku.isEmpty) return;

    setState(() => _isLoadingProduct = true);
    try {
      final isar = await ref.read(isarDbProvider.future);

      // 1. Buscar por codigoPersonalizado exacto (case-insensitive)
      ProductoCollection? product = await isar.productoCollections
          .filter()
          .codigoPersonalizadoEqualTo(sku, caseSensitive: false)
          .findFirst();

      // 2. Buscar en codigo_producto por codigoSku (talla específica)
      if (product == null) {
        final codigoProd = await isar.codigoProductoCollections
            .filter()
            .codigoSkuEqualTo(sku, caseSensitive: false)
            .findFirst()
            .then(
              (c) async => c == null
                  ? await isar.codigoProductoCollections
                        .filter()
                        .codigoSkuContains(sku, caseSensitive: false)
                        .findFirst()
                  : c,
            );
        if (codigoProd != null) {
          product = await isar.productoCollections
              .filter()
              .serverIdEqualTo(codigoProd.productoId)
              .findFirst();
        }
      }

      // 3. Fallback: buscar por nombre (entrada manual desde teclado)
      if (product == null) {
        product = await isar.productoCollections
            .filter()
            .nombreContains(sku, caseSensitive: false)
            .findFirst();
      }

      if (product != null) {
        if (!mounted) return;
        _showProductModal(product);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Producto no encontrado: $sku"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingProduct = false);
    }
  }

  void _showProductModal(ProductoCollection product) async {
    final selectedBodega = ref.read(selectedBodegaProvider);
    if (selectedBodega == null) return;

    setState(() => _isLoadingProduct = true);
    try {
      final repo = await ref.read(inventarioRepositoryProvider.future);
      final stock = await repo.getStockByProductAndBodega(
        product.serverId,
        selectedBodega.serverId,
      );
      final double maxStock = stock?.cantidadActual ?? 0.0;

      // Buscar variantes (tallas) con stock en esta bodega
      final variants = await repo.getVariantsWithStock(
        product.serverId,
        selectedBodega.serverId,
      );

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _ProductDetailModal(
          product: product,
          maxStock: maxStock,
          variants: variants,
          onAddToCart: (qty, size, price, maxStockForSize) {
            _addToCart(
              product,
              qty: qty,
              size: size,
              price: price,
              maxStock: maxStockForSize,
            );
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Agregado: ${product.nombre} ($size) x$qty"),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoadingProduct = false);
    }
  }

  void _showCartDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Tu Carrito",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _clearCart();
                            Navigator.pop(context); // Close modal on clear
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _cart.isEmpty
                        ? const Center(child: Text("Carrito vacío"))
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: _cart.length,
                            itemBuilder: (context, index) {
                              final item = _cart[index];
                              // Override CartItemCard to show Size if available
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.shopping_bag,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  title: Text(
                                    item['name'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "${item['sku']} | Talla: ${item['size']} | Un: ${NumberFormat.simpleCurrency().format(item['price'])}",
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                        onPressed: () {
                                          _adjustQty(index, -1);
                                          setModalState(() {}); // Refresh modal
                                        },
                                      ),
                                      Text(
                                        "${item['qty']}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                        ),
                                        onPressed: () {
                                          _adjustQty(index, 1);
                                          setModalState(() {}); // Refresh modal
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _cart.isEmpty
                            ? null
                            : () {
                                Navigator.pop(context);
                                _goToCheckout();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "IR A PAGAR",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              NumberFormat.simpleCurrency().format(_total),
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _addToCart(
    ProductoCollection product, {
    int qty = 1,
    String size = 'Única',
    double? price,
    double maxStock = 9999,
  }) {
    final finalPrice = price ?? product.precioBase ?? 0.0;
    final index = _cart.indexWhere(
      (item) => item['id'] == product.serverId && item['size'] == size,
    );

    setState(() {
      if (index >= 0) {
        final currentQty = _cart[index]['qty'] as int;
        if (currentQty + qty <= maxStock) {
          _cart[index]['qty'] += qty;
        } else {
          _cart[index]['qty'] = maxStock.toInt();
        }
        _cart[index]['price'] = finalPrice;
      } else {
        _cart.add({
          'id': product.serverId,
          'name': product.nombre,
          'sku': product.codigoPersonalizado ?? 'S/C',
          'price': finalPrice,
          'stockMax': maxStock.toInt(),
          'qty': qty,
          'size': size,
        });
      }
    });
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
    });
  }

  void _adjustQty(int index, int change) {
    setState(() {
      final currentQty = _cart[index]['qty'] as int;
      final maxStock = _cart[index]['stockMax'] as int;
      final newQty = currentQty + change;

      if (newQty > maxStock) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Stock máximo alcanzado")));
        _cart[index]['qty'] = maxStock;
      } else if (newQty > 0) {
        _cart[index]['qty'] = newQty;
      } else {
        _cart.removeAt(index);
      }
    });
  }

  void _goToCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          cartItems: _cart,
          total: _total,
          tax: _tax,
          subtotal: _subtotal,
        ),
      ),
    ).then((result) {
      if (!mounted) return;
      if (result == true) {
        _clearCart();
        ref.invalidate(salesListProvider);
        context.go('/sales');
      } else {
        ref
            .read(appBarProvider.notifier)
            .setOptions(
              title: "Punto de Venta",
              showBackButton: true,
              actions: [
                IconButton(
                  onPressed: _clearCart,
                  icon: const Icon(Icons.delete_sweep, color: Colors.red),
                  tooltip: "Limpiar Carrito",
                ),
              ],
            );
      }
    });
  }

  void _openScanner() async {
    final code = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeCaptureScreen()),
    );
    if (code != null && code is String) {
      _handleScannedProduct(code);
    }
  }
}

// --- NUEVOS WIDGETS ---

class _ProductGridCard extends StatelessWidget {
  final ProductoCollection product;
  final VoidCallback onTap;

  const _ProductGridCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  image: product.imagenUrl != null
                      ? DecorationImage(
                          image: NetworkImage(product.imagenUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: product.imagenUrl == null
                    ? Icon(Icons.inventory_2, size: 40, color: Colors.grey[400])
                    : null,
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      NumberFormat.simpleCurrency().format(
                        product.precioBase ?? 0,
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
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
}

class _ProductDetailModal extends StatefulWidget {
  final ProductoCollection product;
  final double maxStock;
  final List<Map<String, dynamic>> variants;
  final Function(int qty, String size, double price, double maxStockForSize) onAddToCart;

  const _ProductDetailModal({
    required this.product,
    required this.maxStock,
    required this.variants,
    required this.onAddToCart,
  });

  @override
  State<_ProductDetailModal> createState() => _ProductDetailModalState();
}

class _ProductDetailModalState extends State<_ProductDetailModal> {
  int _qty = 1;
  late String _selectedSize;
  List<String> _sizes = [];
  late TextEditingController _priceController;
  late double _currentMaxStock;

  @override
  void initState() {
    super.initState();
    _currentMaxStock = widget.maxStock;
    _priceController = TextEditingController(
      text: (widget.product.precioBase ?? 0.0).toStringAsFixed(2),
    );
    _parseSizes();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _parseSizes() {
    // Si hay variantes reales del inventario de esta bodega, las usamos
    if (widget.variants.isNotEmpty) {
      _sizes = widget.variants
          .map((v) => v['talla'] as String)
          .toSet()
          .toList();
    } else {
      // Fallback a Única si no hay variantes con stock pero hay stock general
      _sizes = ["Única"];
    }

    _selectedSize = _sizes.contains("Única") ? "Única" : _sizes.first;

    // Actualizamos precio y stock para la talla seleccionada
    _updateDynamicValuesForSize();
  }

  void _updateDynamicValuesForSize() {
    debugPrint("DEBUG _updateDynamicValuesForSize: Evaluando talla '$_selectedSize'");
    debugPrint("DEBUG _updateDynamicValuesForSize: Variantes totales: ${widget.variants}");

    if (widget.variants.isNotEmpty) {
      final variant = widget.variants.firstWhere(
        (v) => v['talla'] == _selectedSize,
        orElse: () => <String, dynamic>{},
      );
      
      debugPrint("DEBUG _updateDynamicValuesForSize: Talla encontrada: $variant");

      if (variant.isNotEmpty) {
        if (variant['precio'] != null) {
          _priceController.text = (variant['precio'] as num).toDouble().toStringAsFixed(2);
        } else {
          _priceController.text = (widget.product.precioBase ?? 0.0).toStringAsFixed(2);
        }

        if (variant['cantidad'] != null) {
          _currentMaxStock = (variant['cantidad'] as num).toDouble();
          debugPrint("DEBUG _updateDynamicValuesForSize: Usando cantidad variante: $_currentMaxStock");
        } else {
          _currentMaxStock = widget.maxStock;
          debugPrint("DEBUG _updateDynamicValuesForSize: Fallback a maxStock porque la variante no tiene cantidad: $_currentMaxStock");
        }
      } else {
         _priceController.text = (widget.product.precioBase ?? 0.0).toStringAsFixed(2);
         _currentMaxStock = widget.maxStock;
         debugPrint("DEBUG _updateDynamicValuesForSize: Variante NO encontrada. Fallback a maxStock: $_currentMaxStock");
      }
    } else {
      _currentMaxStock = widget.maxStock;
      _priceController.text = (widget.product.precioBase ?? 0.0).toStringAsFixed(2);
      debugPrint("DEBUG _updateDynamicValuesForSize: Lista de variantes Vacia! Fallback a maxStock: $_currentMaxStock");
    }

    if (_qty > _currentMaxStock) {
      _qty = _currentMaxStock > 0 ? 1 : (_currentMaxStock.toInt() == 0 ? 0 : 0);
    }
    
    debugPrint("DEBUG _updateDynamicValuesForSize: STOCK LIMITE ESTABLECIDO EN $_currentMaxStock, para talla $_selectedSize");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  image: widget.product.imagenUrl != null
                      ? DecorationImage(
                          image: NetworkImage(widget.product.imagenUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.product.imagenUrl == null
                    ? const Icon(
                        Icons.inventory_2,
                        size: 30,
                        color: Colors.grey,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "SKU: ${widget.product.codigoPersonalizado ?? 'N/A'}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormat.simpleCurrency().format(
                        widget.product.precioBase ?? 0,
                      ),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // SIZE SELECTOR
          const Text(
            "Seleccionar Talla",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: _sizes.map((size) {
              final isSelected = _selectedSize == size;
              return ChoiceChip(
                label: Text(size),
                selected: isSelected,
                onSelected: (val) {
                  setState(() {
                    _selectedSize = size;
                    _updateDynamicValuesForSize();
                  });
                },
                selectedColor: Colors.blue[100],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.blue[900] : Colors.black,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // PRICE AND QTY SELECTOR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // PRECIO EDITABLE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Precio de Venta",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        prefixText: "\$",
                        filled: true,
                        fillColor: Colors.blue[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // CANTIDAD
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "Cantidad",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () {
                          if (_qty > 1) setState(() => _qty--);
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "$_qty",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () {
                          if (_qty < _currentMaxStock) {
                            setState(() => _qty++);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Stock máximo alcanzado"),
                                duration: Duration(milliseconds: 500),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  Text(
                    "Disponible: ${_currentMaxStock.toInt()}",
                    style: TextStyle(
                      fontSize: 11,
                      color: _currentMaxStock > 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _currentMaxStock <= 0
                  ? null
                  : () {
                      final price =
                          double.tryParse(_priceController.text) ??
                          (widget.product.precioBase ?? 0.0);
                      widget.onAddToCart(_qty, _selectedSize, price, _currentMaxStock);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                disabledBackgroundColor: Colors.grey,
              ),
              child: const Text(
                "AGREGAR AL CARRITO",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- VISTA DE SELECCIÓN DE BODEGA ---
class _BodegaSelectorView extends ConsumerWidget {
  const _BodegaSelectorView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodegasAsync = ref.watch(bodegaListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.warehouse_rounded, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                "Seleccione Bodega",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Para comenzar la venta, elija la bodega de donde saldrá la mercancía.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              bodegasAsync.when(
                data: (bodegas) {
                  if (bodegas.isEmpty) {
                    return const Center(
                      child: Text("No hay bodegas registradas"),
                    );
                  }

                  // AUTO-SELECCCCIÓN SI SOLO HAY UNA NO SE MUESTRA LA LISTA
                  if (bodegas.length == 1) {
                    Future.microtask(() {
                      ref.read(selectedBodegaProvider.notifier).state =
                          bodegas.first;
                    });
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: bodegas.length,
                    itemBuilder: (context, index) {
                      final bodega = bodegas[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[200]!),
                        ),
                        child: InkWell(
                          onTap: () {
                            ref.read(selectedBodegaProvider.notifier).state =
                                bodega;
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.store,
                                    color: Colors.blue,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        bodega.nombre,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      if (bodega.direccion != null &&
                                          bodega.direccion!
                                              .trim()
                                              .isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          bodega.direccion!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text("Error: $e")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
