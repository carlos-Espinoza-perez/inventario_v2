import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'package:inventario_v2/core/providers/database_provider.dart';
import 'package:inventario_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:inventario_v2/features/inventory/data/collections/producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/providers/bodega_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/inventario_provider.dart';
import 'package:inventario_v2/features/inventory/data/repository/movimiento_repository.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/product_selection_screen.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/barcode_capture_screen.dart';
import 'package:inventario_v2/features/inventory/data/collections/codigo_producto_collection.dart';

class WarehouseTransferScreen extends ConsumerStatefulWidget {
  final String bodegaOrigenId; // Id de bodega origen por defecto, si aplica

  const WarehouseTransferScreen({super.key, this.bodegaOrigenId = ''});

  @override
  ConsumerState<WarehouseTransferScreen> createState() =>
      _WarehouseTransferScreenState();
}

class _WarehouseTransferScreenState
    extends ConsumerState<WarehouseTransferScreen> {
  // Controladores
  String? _selectedOriginWarehouseId;
  String? _selectedDestinationWarehouseId;

  // Lista de items a trasladas: {productId, name, qr, size, cost, price, cantidad, availableStock}
  final List<Map<String, dynamic>> _transferItems = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.bodegaOrigenId.isNotEmpty) {
      _selectedOriginWarehouseId = widget.bodegaOrigenId;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos lista de bodegas
    final bodegasAsync = ref.watch(bodegaListProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      // BOTÓN FINALIZAR TRASLADO
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: (_transferItems.isEmpty || _isLoading)
                ? null
                : _finalizeTransfer,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan.shade900,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "FINALIZAR TRASLADO",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        ),
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TARJETA DE ORIGEN / DESTINO
                Container(
                  padding: const EdgeInsets.all(20),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Configuración de Traslado",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Selector de Bodega ORIGEN
                      // Selector de Bodega ORIGEN
                      bodegasAsync.when(
                        loading: () =>
                            const LinearProgressIndicator(minHeight: 2),
                        error: (err, _) => const SizedBox(),
                        data: (bodegas) {
                          if (widget.bodegaOrigenId.isNotEmpty) {
                            final origen = bodegas.firstWhere(
                              (b) => b.serverId == widget.bodegaOrigenId,
                              orElse: () => bodegas.first,
                            );
                            return TextFormField(
                              initialValue: origen.nombre,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: "Bodega de ORIGEN",
                                prefixIcon: const Icon(
                                  Icons.outbond,
                                  color: Colors.orange,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                filled: true,
                                fillColor: Colors.orange.shade50,
                              ),
                            );
                          }

                          return DropdownButtonFormField<String>(
                            initialValue: _selectedOriginWarehouseId,
                            decoration: InputDecoration(
                              labelText: "Bodega de ORIGEN",
                              prefixIcon: const Icon(
                                Icons.outbond,
                                color: Colors.orange,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            items: bodegas
                                .map(
                                  (b) => DropdownMenuItem(
                                    value: b.serverId,
                                    child: Text(b.nombre),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedOriginWarehouseId = val;
                                // Limpiar lista si cambia origen
                                if (_transferItems.isNotEmpty) {
                                  _transferItems.clear();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Lista limpiada por cambio de bodega origen",
                                      ),
                                    ),
                                  );
                                }
                              });
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Selector de Bodega DESTINO
                      bodegasAsync.when(
                        loading: () =>
                            const LinearProgressIndicator(minHeight: 2),
                        error: (err, _) => Text("Error cargando bodegas: $err"),
                        data: (bodegas) {
                          return DropdownButtonFormField<String>(
                            initialValue: _selectedDestinationWarehouseId,
                            decoration: InputDecoration(
                              labelText: "Bodega de DESTINO",
                              prefixIcon: const Icon(
                                Icons.download,
                                color: Colors.green,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            items: bodegas
                                .map(
                                  (b) => DropdownMenuItem(
                                    value: b.serverId,
                                    child: Text(b.nombre),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedDestinationWarehouseId = val;
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // SECCIÓN DE ITEMS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Items a Trasladar",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _scanSingleProduct,
                          icon: const Icon(Icons.qr_code_scanner),
                          tooltip: "Escanear Producto",
                          color: Colors.cyan.shade800,
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _selectProductFromList,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan.shade50,
                            foregroundColor: Colors.cyan.shade900,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.list, size: 18),
                          label: const Text("Seleccionar"),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (_transferItems.isEmpty)
                  _buildEmptyState()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _transferItems.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _buildTransferItemCard(_transferItems[index], index),
                  ),

                // Espacio final para no tapar con el botón flotante
                const SizedBox(height: 80),
              ],
            ),
          ),

          // LOADING OVERLAY
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.move_down_rounded, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "No hay items en el traslado",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Escanea o selecciona productos",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // --- WIDGET TARJETA DE ITEM (CON CANTIDAD, COSTO Y PRECIO) ---
  Widget _buildTransferItemCard(Map<String, dynamic> item, int index) {
    final priceCtrl = TextEditingController(
      text: item['price']?.toString() ?? '0',
    );
    final costCtrl = TextEditingController(
      text: item['cost']?.toString() ?? '0',
    );
    final qtyCtrl = TextEditingController(
      text: (item['cantidad'] as num).toDouble().toStringAsFixed(0),
    );

    // Stock disponible (del origen)
    final double maxStock = (item['availableStock'] as num?)?.toDouble() ?? 0.0;
    final double currentQty = (item['cantidad'] as num?)?.toDouble() ?? 0.0;
    final bool isExceeded = currentQty > maxStock;
    final bool isZero = currentQty <= 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: (isExceeded || isZero)
            ? Border.all(color: Colors.red.shade300, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // CABECERA ITEM
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.orange.shade50,
                child: Text(
                  item['size'],
                  style: TextStyle(
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "QR: ${item['qr']}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.redAccent,
                  size: 20,
                ),
                onPressed: () => setState(() => _transferItems.removeAt(index)),
              ),
            ],
          ),
          const Divider(),

          // FILA DE EDICIÓN (CANTIDAD | COSTO | PRECIO)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. CANTIDAD (Flex 2)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Cant.",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: "1",
                      ),
                      onChanged: (val) {
                        // Permitir campo vacío mientras el usuario escribe.
                        // Solo actualizamos el estado con un número válido.
                        if (val.isEmpty) return;
                        final v = double.tryParse(val);
                        if (v != null) {
                          setState(() {
                            item['cantidad'] = v;
                          });
                        }
                      },
                    ),
                    if (isExceeded)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          "Max: ${maxStock.toInt()}",
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // 2. COSTO (Flex 3)
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Costo Und.", style: TextStyle(fontSize: 11)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: costCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixText: "\$ ",
                      ),
                      onChanged: (val) {
                        final v = double.tryParse(val) ?? 0.0;
                        item['cost'] = v;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // 3. PRECIO (Flex 3)
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Precio Venta", style: TextStyle(fontSize: 11)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixText: "\$ ",
                      ),
                      onChanged: (val) {
                        final newPrice = double.tryParse(val) ?? 0.0;
                        item['price'] = newPrice;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- LÓGICA DE NEGOCIO ---

  void _scanSingleProduct() async {
    if (_selectedOriginWarehouseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecciona primero la bodega de origen"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final scannedCode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeCaptureScreen()),
    );

    if (scannedCode == null || scannedCode is! String) return;

    // Normalización defensiva (por si acaso el lector añadió algo extra)
    final normalizedCode = scannedCode.trim().replaceAll(
      RegExp(r'[\x00-\x1F\x7F]'),
      '',
    );
    if (normalizedCode.isEmpty) return;

    // Buscar en Isar: primero por codigoPersonalizado exacto, luego por codigoSku
    final isar = await ref.read(isarDbProvider.future);

    // 1. Búsqueda exacta en codigoPersonalizado
    ProductoCollection? producto = await isar.productoCollections
        .filter()
        .codigoPersonalizadoEqualTo(normalizedCode, caseSensitive: false)
        .findFirst();

    // 2. Fallback: buscar en codigo_producto por codigoSku
    if (producto == null) {
      final codigoProd = await isar.codigoProductoCollections
          .filter()
          .codigoSkuEqualTo(normalizedCode, caseSensitive: false)
          .findFirst()
          .then(
            (c) async => c == null
                ? await isar.codigoProductoCollections
                      .filter()
                      .codigoSkuContains(normalizedCode, caseSensitive: false)
                      .findFirst()
                : c,
          );

      if (codigoProd != null) {
        producto = await isar.productoCollections
            .filter()
            .serverIdEqualTo(codigoProd.productoId)
            .findFirst();
      }
    }

    if (producto == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No se encontró producto con código: $normalizedCode"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Obtener stock disponible en la bodega de origen
    final repo = await ref.read(inventarioRepositoryProvider.future);
    final inventario = await repo.getStockByProductAndBodega(
      producto.serverId,
      _selectedOriginWarehouseId!,
    );
    final double stockDisponible = inventario?.cantidadActual ?? 0.0;

    if (!mounted) return;

    if (stockDisponible <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${producto.nombre}: sin stock en la bodega de origen"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _addProductToTransferList(
      productId: producto.serverId,
      name: producto.nombre,
      qr: producto.codigoPersonalizado ?? scannedCode,
      size: 'Única',
      cost: inventario?.costoPromedio ?? producto.ultimoCosto ?? 0.0,
      price: producto.precioBase ?? 0.0,
      availableStock: stockDisponible,
    );
  }

  void _selectProductFromList() async {
    if (_selectedOriginWarehouseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona primero la bodega de origen")),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductSelectionScreen(
          mode: ProductSelectionMode.transfer,
          originWarehouseId: _selectedOriginWarehouseId,
        ),
      ),
    );

    if (result != null) {
      // 1. Manejo de Lista (Selección Múltiple y Nuevo Estándar)
      if (result is List) {
        for (var item in result) {
          _addProductToTransferList(
            productId: item['productId'] ?? item['id'] ?? const Uuid().v4(),
            name: item['name'] ?? "Producto Seleccionado",
            qr: item['qr'] ?? "MANUAL-SELECT",
            size: item['size'] ?? "U",
            cost: item['cost'] != null ? (item['cost'] as num).toDouble() : 0.0,
            price: item['price'] != null
                ? (item['price'] as num).toDouble()
                : 0.0,
            availableStock: item['availableStock'] != null
                ? (item['availableStock'] as num).toDouble()
                : 0.0,
            cantidad: item['cantidad'] != null
                ? (item['cantidad'] as num).toDouble()
                : 1.0,
          );
        }
      }
      // 2. Fallback para compatibilidad (Map único)
      else if (result is Map) {
        _addProductToTransferList(
          productId: result['productId'] ?? result['id'] ?? const Uuid().v4(),
          name: result['name'] ?? "Producto Seleccionado",
          qr: result['qr'] ?? "MANUAL-SELECT",
          size: result['size'] ?? "U",
          // Aquí recuperamos el costo que viene de ProductSelectionScreen
          cost: result['cost'] != null
              ? (result['cost'] as num).toDouble()
              : 0.0,
          price: result['price'] != null
              ? (result['price'] as num).toDouble()
              : 0.0,
          availableStock: result['availableStock'] != null
              ? (result['availableStock'] as num).toDouble()
              : 0.0,
          cantidad: 1.0,
        );
      }
    }
  }

  void _addProductToTransferList({
    required String productId,
    required String name,
    required String qr,
    required String size,
    required double cost,
    required double price,
    required double availableStock,
    double cantidad = 1.0,
  }) {
    setState(() {
      _transferItems.add({
        'productId': productId,
        'name': name,
        'qr': qr,
        'size': size,
        'cost': cost,
        'price': price,
        'cantidad': cantidad, // Cantidad seleccionada o default
        'availableStock': availableStock,
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Item(s) agregado(s) al traslado"),
        duration: Duration(milliseconds: 600),
      ),
    );
  }

  Future<void> _finalizeTransfer() async {
    if (_selectedOriginWarehouseId == null ||
        _selectedDestinationWarehouseId == null) {
      return;
    }

    if (_selectedOriginWarehouseId == _selectedDestinationWarehouseId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La bodega origen y destino no pueden ser iguales"),
        ),
      );
      return;
    }

    // Validar Stock antes de procesar
    for (final item in _transferItems) {
      final qty = (item['cantidad'] as num).toDouble();
      final max = (item['availableStock'] as num).toDouble();
      if (qty > max) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error: ${item['name']} supera el stock disponible (${max.toInt()}).",
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (qty <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${item['name']} tiene cantidad inválida."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final repository = await ref.read(movimientoRepositoryProvider.future);
      final authController = ref.read(authControllerProvider.notifier);
      final usuario =
          authController.usuarioActual ?? await authController.getUser();

      await repository.registrarTrasladoBodegas(
        empresaId: usuario?.empresaId ?? "",
        usuarioId: usuario?.serverId ?? "",
        bodegaOrigenId: _selectedOriginWarehouseId!,
        bodegaDestinoId: _selectedDestinationWarehouseId!,
        descripcion: "Traslado App - ${_transferItems.length} items",
        items: _transferItems,
      );

      if (!mounted) return;

      // Usar addPostFrameCallback para evitar conflictos de navegación durante rebuilds
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Traslado registrado correctamente"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error en traslado: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
