import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:isar/isar.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/core/providers/database_provider.dart';
import 'package:inventario_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:inventario_v2/features/inventory/data/collections/producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/codigo_producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/inventario_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/inventario_codigo_producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/providers/bodega_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/inventario_provider.dart';
import 'package:inventario_v2/features/inventory/data/repository/movimiento_repository.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/product_selection_screen.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/barcode_capture_screen.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/product_detail_screen.dart';
import 'package:inventario_v2/features/inventory/presentation/providers/warehouse_inventory_provider.dart' hide inventarioRepositoryProvider;

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

    // Configurar el título del AppBar
    Future.microtask(() {
      ref
          .read(appBarProvider.notifier)
          .setOptions(
            title: "Realizar Traslado",
            subtitle: "Traslado entre Bodegas",
            showBackButton: true,
            actions: [],
          );
    });
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
                          // Filtrar la bodega de origen para que no aparezca en destino
                          final bodegasDestino = bodegas
                              .where(
                                (b) => b.serverId != _selectedOriginWarehouseId,
                              )
                              .toList();

                          return DropdownButtonFormField<String>(
                            value: _selectedDestinationWarehouseId,
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
                            items: bodegasDestino
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
                    itemBuilder: (context, index) => _TransferItemCard(
                      key: ValueKey(_transferItems[index]),
                      item: _transferItems[index],
                      index: index,
                      onDelete: () =>
                          setState(() => _transferItems.removeAt(index)),
                      onStateChanged: () => setState(() {}),
                    ),
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

    // Escanear código QR
    final scannedCode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeCaptureScreen()),
    );

    if (scannedCode == null || scannedCode is! String) return;

    // Normalización del código
    final normalizedCode = scannedCode.trim().replaceAll(
      RegExp(r'[\x00-\x1F\x7F]'),
      '',
    );
    if (normalizedCode.isEmpty) return;

    // Buscar producto en Isar
    final isar = await ref.read(isarDbProvider.future);

    // 1. Búsqueda por codigoPersonalizado
    ProductoCollection? producto = await isar.productoCollections
        .filter()
        .codigoPersonalizadoEqualTo(normalizedCode, caseSensitive: false)
        .findFirst();

    // 2. Fallback: buscar por codigoSku
    if (producto == null) {
      final codigoProd = await isar.codigoProductoCollections
          .filter()
          .codigoSkuEqualTo(normalizedCode, caseSensitive: false)
          .findFirst();

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

    // Obtener códigos de producto (tallas) del producto
    final codigosProducto = await isar.codigoProductoCollections
        .filter()
        .productoIdEqualTo(producto.serverId)
        .findAll();

    if (codigosProducto.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${producto.nombre}: no tiene códigos/tallas registrados",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Obtener inventarios del producto en la bodega de origen
    final repoInventario = await ref.read(inventarioRepositoryProvider.future);
    final todosInventarios = await repoInventario.getInventariosByProductId(
      producto.serverId,
    );

    // Filtrar solo los de la bodega de origen
    final inventarios = todosInventarios
        .where((inv) => inv.bodegaId == _selectedOriginWarehouseId)
        .toList();

    debugPrint("DEBUG _scanSingleProduct: Encontrados ${todosInventarios.length} inventarios para el producto ${producto.serverId} globalmente");
    debugPrint("DEBUG _scanSingleProduct: Encontrados ${inventarios.length} inventarios para el producto ${producto.serverId} filtrado para bodega origen $_selectedOriginWarehouseId");

    if (inventarios.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${producto.nombre}: sin stock en la bodega de origen"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Mostrar diálogo de selección de tallas y cantidades
    if (!mounted) return;
    
    debugPrint("DEBUG _scanSingleProduct: Abriendo Dialog de Seleccion con ${inventarios.first.cantidadActual} items macro.");
    await _showSizeSelectionDialog(
      producto: producto,
      codigosProducto: codigosProducto,
      inventarios: inventarios,
      scannedCode: normalizedCode,
    );
  }

  Future<void> _showSizeSelectionDialog({
    required ProductoCollection producto,
    required List<CodigoProductoCollection> codigosProducto,
    required List<InventarioCollection> inventarios,
    required String scannedCode,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => _SizeSelectionDialog(
        producto: producto,
        codigosProducto: codigosProducto,
        inventarios: inventarios,
        scannedCode: scannedCode,
        onAdd: _addProductToTransferList,
      ),
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
      // Agregar el item sin dividir, independientemente de la cantidad
      _transferItems.add({
        'productId': productId,
        'name': name,
        'qr': qr,
        'size': size,
        'cost': cost,
        'price': price,
        'cantidad': cantidad,
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
        // Invalidar proveedores del historial y variantes para que la vista de detalle se recargue
        for (final item in _transferItems) {
          final pId = item['productId'];
          if (pId != null) {
            ref.invalidate(productHistoryProvider);
            ref.invalidate(productVariantsProvider);
            ref.invalidate(productBodegaInvProvider);
            ref.invalidate(productDetailProvider(pId));
          }
        }
        ref.invalidate(warehouseInventoryProvider(_selectedOriginWarehouseId!));
        ref.invalidate(warehouseInventoryProvider(_selectedDestinationWarehouseId!));

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

// --- CLASES AUXILIARES PARA MANEJO DE ESTADO Y CONTROLADORES ---

class _TransferItemCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onStateChanged;

  const _TransferItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.onDelete,
    required this.onStateChanged,
  });

  @override
  State<_TransferItemCard> createState() => _TransferItemCardState();
}

class _TransferItemCardState extends State<_TransferItemCard> {
  late TextEditingController _priceCtrl;
  late TextEditingController _costCtrl;
  late TextEditingController _qtyCtrl;

  @override
  void initState() {
    super.initState();
    _priceCtrl = TextEditingController(
      text: widget.item['price']?.toString() ?? '0',
    );
    _costCtrl = TextEditingController(
      text: widget.item['cost']?.toString() ?? '0',
    );
    _qtyCtrl = TextEditingController(
      text: (widget.item['cantidad'] as num).toDouble().toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _costCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Stock disponible (del origen)
    final double maxStock =
        (widget.item['availableStock'] as num?)?.toDouble() ?? 0.0;
    final double currentQty =
        (widget.item['cantidad'] as num?)?.toDouble() ?? 0.0;
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
                  widget.item['size'] ?? '?',
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
                      widget.item['name'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "QR: ${widget.item['qr']}",
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
                onPressed: widget.onDelete,
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
                      controller: _qtyCtrl,
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
                        if (val.isEmpty) return;
                        final v = double.tryParse(val);
                        if (v != null) {
                          widget.item['cantidad'] = v;
                          widget.onStateChanged();
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
                      controller: _costCtrl,
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
                        widget.item['cost'] = v;
                        widget.onStateChanged();
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
                      controller: _priceCtrl,
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
                        widget.item['price'] = newPrice;
                        widget.onStateChanged();
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
}

class _SizeSelectionDialog extends StatefulWidget {
  final ProductoCollection producto;
  final List<CodigoProductoCollection> codigosProducto;
  final List<InventarioCollection> inventarios;
  final String scannedCode;
  final Function({
    required String productId,
    required String name,
    required String qr,
    required String size,
    required double cost,
    required double price,
    required double availableStock,
    required double cantidad,
  }) onAdd;

  const _SizeSelectionDialog({
    required this.producto,
    required this.codigosProducto,
    required this.inventarios,
    required this.scannedCode,
    required this.onAdd,
  });

  @override
  State<_SizeSelectionDialog> createState() => _SizeSelectionDialogState();
}

class _SizeSelectionDialogState extends State<_SizeSelectionDialog> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, double> _stockDisponible = {};

  @override
  void initState() {
    super.initState();
    _loadVariantsStock();
  }

  Future<void> _loadVariantsStock() async {
    try {
      final isar = Isar.getInstance();
      if (isar == null) {
        debugPrint("DEBUG _loadVariantsStock: Isar instance is null");
        return;
      }
      
      final inventarioMacro = widget.inventarios.first;
      debugPrint("DEBUG _loadVariantsStock: Inventario Macro ID: ${inventarioMacro.serverId}, Bodega ID: ${inventarioMacro.bodegaId}");
      
      final microInventarios = await isar.inventarioCodigoProductoCollections
          .filter()
          .inventarioIdEqualTo(inventarioMacro.serverId)
          .findAll();

      debugPrint("DEBUG _loadVariantsStock: Se encontraron ${microInventarios.length} micro inventarios");

      final Map<String, double> microStockMap = {};
      for (var micro in microInventarios) {
        microStockMap[micro.codigoProductoId] = micro.cantidad;
        debugPrint("DEBUG _loadVariantsStock: Micro Inv - Codigo ID: ${micro.codigoProductoId}, Cantidad: ${micro.cantidad}");
      }

      if (mounted) {
        setState(() {
          debugPrint("DEBUG _loadVariantsStock: Evaluando ${widget.codigosProducto.length} codigos/variantes disponibles para este producto");
          for (var codigo in widget.codigosProducto) {
            final talla = codigo.talla;
            // Get stock for this specific size from micro inventory
            final stockTotal = microStockMap[codigo.serverId] ?? 0.0;
            
            debugPrint("DEBUG _loadVariantsStock: Evaluando Talla '$talla' (SKU: ${codigo.codigoSku}, Server ID: ${codigo.serverId}) -> Stock encontrado: $stockTotal");

            if (stockTotal > 0) {
              _controllers[talla] = TextEditingController(text: '0');
              _stockDisponible[talla] = stockTotal;
              debugPrint("DEBUG _loadVariantsStock: ✅ Talla '$talla' agregada al dialog con stock maximo $stockTotal");
            } else {
              debugPrint("DEBUG _loadVariantsStock: ❌ Talla '$talla' omitida porque tiene stock <= 0 (stock=$stockTotal)");
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading variants stock: $e");
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.producto.nombre,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Código: ${widget.scannedCode}",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              "Selecciona cantidades por talla:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._controllers.entries.map((entry) {
              final talla = entry.key;
              final controller = entry.value;
              final stock = _stockDisponible[talla] ?? 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        talla,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Cantidad",
                          hintText: "0",
                          helperText: "Stock: ${stock.toInt()}",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            bool agregado = false;
            for (var entry in _controllers.entries) {
              final talla = entry.key;
              final cantidad = double.tryParse(entry.value.text) ?? 0.0;
              final stock = _stockDisponible[talla] ?? 0.0;

              if (cantidad > 0) {
                if (cantidad > stock) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Talla $talla: cantidad excede stock disponible",
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final codigo = widget.codigosProducto.firstWhere(
                  (c) => c.talla == talla,
                );
                final inv = widget.inventarios.first;

                widget.onAdd(
                  productId: widget.producto.serverId,
                  name: widget.producto.nombre,
                  qr: codigo.codigoSku,
                  size: talla,
                  cost: codigo.costoEspecifico ?? inv.costoPromedio,
                  price: codigo.precioEspecifico ??
                      widget.producto.precioBase ??
                      0.0,
                  availableStock: stock,
                  cantidad: cantidad,
                );
                agregado = true;
              }
            }

            if (agregado) {
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Debes ingresar al menos una cantidad"),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyan.shade900,
            foregroundColor: Colors.white,
          ),
          child: const Text("Agregar"),
        ),
      ],
    );
  }
}
