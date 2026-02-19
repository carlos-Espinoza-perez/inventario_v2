import 'dart:math'; // Para generar precios aleatorios en productos desconocidos
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import '../../inventory/presentation/screens/barcode_capture_screen.dart';
import 'checkout_screen.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  // Carrito de Compras
  final List<Map<String, dynamic>> _cart = [];

  // INVENTARIO MOCK (Datos de prueba)
  final List<Map<String, dynamic>> _inventory = [
    {
      'id': '1',
      'name': 'Camisa Manga Larga',
      'sku': 'SKU-1002',
      'price': 250.0,
      'stock': 15,
    },
    {
      'id': '2',
      'name': 'Gorra Nike SB',
      'sku': 'SKU-1012',
      'price': 500.0,
      'stock': 15,
    },
    {
      'id': '3',
      'name': 'Pantalón Jeans',
      'sku': 'SKU-1022',
      'price': 550.0,
      'stock': 2,
    },
    {
      'id': '4',
      'name': 'Zapatos Deportivos',
      'sku': 'SKU-5000',
      'price': 1200.0,
      'stock': 8,
    },
  ];

  @override
  void initState() {
    super.initState();
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

  // CÁLCULOS
  double get _subtotal =>
      _cart.fold(0, (sum, item) => sum + (item['price'] * item['qty']));
  double get _tax => _subtotal * 0.15; // IVA 15%
  double get _total => _subtotal + _tax;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // 1. BARRA SUPERIOR (BUSCADOR + SCAN)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Buscar nombre o SKU...",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                    ),
                    onSubmitted: (val) => _findAndAddToCart(query: val),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 48,
                  width: 48,
                  child: IconButton.filled(
                    onPressed: _openScanner,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                    ),
                    tooltip: "Escanear Código",
                  ),
                ),
              ],
            ),
          ),

          // 2. LISTA DEL CARRITO
          Expanded(
            child: _cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            size: 50,
                            color: Colors.blue.shade200,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "El carrito está vacío",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Escanea o busca un producto para comenzar",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cart.length,
                    itemBuilder: (context, index) {
                      // Invertir lista para que el último agregado salga arriba (opcional, aquí es orden normal)
                      return _CartItemCard(
                        item: _cart[index],
                        onAdd: () => _adjustQty(index, 1),
                        onRemove: () => _adjustQty(index, -1),
                        onDelete: () => setState(() => _cart.removeAt(index)),
                      );
                    },
                  ),
          ),

          // 3. BARRA DE TOTALES (RESUMEN)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Desglose rápido
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Subtotal:",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        NumberFormat.simpleCurrency().format(_subtotal),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total a Pagar",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        NumberFormat.simpleCurrency().format(_total),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Botón Cobrar
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _cart.isEmpty ? null : _goToCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.payments_outlined),
                      label: const Text(
                        "IR A COBRAR",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- LÓGICA DE NEGOCIO ---

  void _openScanner() async {
    // Navegamos a la pantalla de cámara que ya creaste antes
    final code = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeCaptureScreen()),
    );

    if (code != null && code is String) {
      _findAndAddToCart(sku: code);
    }
  }

  void _findAndAddToCart({String? query, String? sku}) {
    // 1. Buscar coincidencia exacta en el inventario simulado
    var product = _inventory.firstWhere(
      (p) =>
          (sku != null && p['sku'] == sku) ||
          (query != null &&
              p['name'].toString().toLowerCase().contains(query.toLowerCase())),
      orElse: () => {},
    );

    // 2. LÓGICA "DUMMY": Si no existe, pero se escaneó un código (sku != null),
    // creamos un producto temporal para que la prueba no falle.
    if (product.isEmpty && sku != null) {
      final randomPrice =
          (Random().nextInt(100) + 1) * 10.0; // Precio entre 10 y 1000
      product = {
        'id': 'temp-${DateTime.now().millisecondsSinceEpoch}',
        'name': 'Producto Escaneado',
        'sku': sku, // Usamos el código que se leyó
        'price': randomPrice,
        'stock': 999, // Stock infinito para prueba
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✨ Producto nuevo detectado: $sku"),
          backgroundColor: Colors.green,
          duration: const Duration(milliseconds: 1500),
        ),
      );
    } else if (product.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Producto no encontrado"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 3. Agregar al carrito
    final index = _cart.indexWhere(
      (item) => item['id'] == product['id'] || item['sku'] == product['sku'],
    );

    setState(() {
      if (index >= 0) {
        // Si ya existe, sumamos 1
        if (_cart[index]['qty'] < product['stock']) {
          _cart[index]['qty']++;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Stock máximo alcanzado")),
          );
        }
      } else {
        // Si es nuevo en el carrito
        _cart.add({
          'id': product['id'],
          'name': product['name'],
          'sku': product['sku'],
          'price': product['price'],
          'stockMax': product['stock'],
          'qty': 1,
        });
      }
    });
  }

  void _adjustQty(int index, int change) {
    setState(() {
      final currentQty = _cart[index]['qty'] as int;
      final maxStock = _cart[index]['stockMax'] as int;
      final newQty = currentQty + change;

      if (newQty > 0 && newQty <= maxStock) {
        _cart[index]['qty'] = newQty;
      }
    });
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
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
    );
  }
}

// --- WIDGET TARJETA DE ITEM (DISEÑO MEJORADO) ---
class _CartItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onDelete;

  const _CartItemCard({
    required this.item,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = item['price'] * item['qty'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // CONTROLADOR DE CANTIDAD (VERTICAL)
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: onAdd,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(Icons.add, size: 18, color: Colors.blue[800]),
                  ),
                ),
                Text(
                  "${item['qty']}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.blue[900],
                  ),
                ),
                InkWell(
                  onTap: onRemove,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.remove,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // INFORMACIÓN DEL PRODUCTO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item['sku'],
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Unit: ${NumberFormat.simpleCurrency().format(item['price'])}",
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),

          // TOTAL Y BORRAR
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.redAccent,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 12),
              Text(
                NumberFormat.simpleCurrency().format(subtotal),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
