import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:inventario_v2/core/db/models/product_catalog_models.dart';
import 'package:inventario_v2/core/db/exceptions/dao_exceptions.dart';
import 'package:inventario_v2/core/presentation/widgets/custom_text_field.dart';
import 'package:inventario_v2/features/inventory/data/providers/inventario_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/producto_provider.dart';
import 'package:inventario_v2/features/inventory/domain/use_cases/registrar_entrada_use_case.dart';

import 'barcode_capture_screen.dart';
import 'product_create_screen.dart';
import 'product_detail_entry_screen.dart';
import 'product_selection_screen.dart';
import 'package:inventario_v2/features/inventory/presentation/providers/warehouse_entry_draft_provider.dart';

class WarehouseEntryScreen extends ConsumerStatefulWidget {
  final String bodegaId;

  const WarehouseEntryScreen({super.key, required this.bodegaId});

  @override
  ConsumerState<WarehouseEntryScreen> createState() =>
      _WarehouseEntryScreenState();
}

class _WarehouseEntryScreenState extends ConsumerState<WarehouseEntryScreen> {
  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusDescripcion = FocusNode();

  bool _isLoading = false;
  bool _isLoadingProduct = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final draft = ref.read(warehouseEntryDraftProvider(widget.bodegaId));
      if (draft.description.isNotEmpty) {
        _descriptionCtrl.text = draft.description;
      }
    });
    _descriptionCtrl.addListener(() {
      ref.read(warehouseEntryDraftProvider(widget.bodegaId).notifier)
         .updateDescription(_descriptionCtrl.text);
    });
  }

  double _totalInvestment(List<Map<String, dynamic>> orderLines) => orderLines.fold(0.0, (sum, item) {
    final cost = (item['cost'] as num?)?.toDouble() ?? 0.0;
    final qty = ((item['items'] as List?)?.length ?? 0).toDouble();
    return sum + (cost * qty);
  });

  double _expectedSales(List<Map<String, dynamic>> orderLines) {
    return orderLines.fold(0.0, (sum, line) {
      final items = line['items'] as List? ?? [];
      double lineSales = 0.0;
      for (final item in items) {
        final Map itemMap = item as Map;
        final itemPrice = double.tryParse(itemMap['price']?.toString() ?? '') ?? 
                          (line['price'] as num?)?.toDouble() ?? 0.0;
        lineSales += itemPrice;
      }
      return sum + lineSales;
    });
  }

  int _totalItemsCount(List<Map<String, dynamic>> orderLines) => orderLines.fold(
    0,
    (sum, item) => sum + ((item['items'] as List?)?.length ?? 0),
  );

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    _searchController.dispose();
    _focusDescripcion.dispose();
    super.dispose();
  }

  Future<void> _saveEntireOrderToDB(List<Map<String, dynamic>> orderLines) async {
    if (_descriptionCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agrega una descripción para este movimiento'),
          backgroundColor: Colors.red,
        ),
      );
      _focusDescripcion.requestFocus();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final registrarEntrada = ref.read(registrarEntradaUseCaseProvider);

      await registrarEntrada.ejecutar(
        bodegaId: widget.bodegaId,
        descripcion: _descriptionCtrl.text,
        orderLines: orderLines,
      );

      if (!mounted) return;
      ref.read(warehouseEntryDraftProvider(widget.bodegaId).notifier).clear();
      _descriptionCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entrada de inventario registrada con exito'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_inventoryErrorMessage(e)),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _inventoryErrorMessage(Object error) {
    return switch (error) {
      WarehouseNotFoundException(:final message) => message,
      ContextoInvalidoException(:final message) => message,
      DaoException(:final message) => message,
      _ => 'Error al guardar: $error',
    };
  }

  @override
  Widget build(BuildContext context) {
    final draftState = ref.watch(warehouseEntryDraftProvider(widget.bodegaId));
    final orderLines = draftState.orderLines;

    return Scaffold(
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
          child: ElevatedButton.icon(
            onPressed: (orderLines.isEmpty || _isLoading)
                ? null
                : () => _saveEntireOrderToDB(orderLines),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan.shade900,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save_alt_rounded),
            label: Text(
              _isLoading
                  ? 'GUARDANDO...'
                  : 'FINALIZAR ENTRADA (${NumberFormat.simpleCurrency().format(_totalInvestment(orderLines))})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                color: Colors.cyan.shade800,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Informacion General',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          if (orderLines.isNotEmpty || _descriptionCtrl.text.isNotEmpty)
                            TextButton.icon(
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('¿Limpiar borrador?'),
                                    content: const Text('Se eliminarán todos los productos escaneados y la descripción actual.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('CANCELAR'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                                        child: const Text('LIMPIAR'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true && mounted) {
                                  ref.read(warehouseEntryDraftProvider(widget.bodegaId).notifier).clear();
                                  _descriptionCtrl.clear();
                                }
                              },
                              icon: const Icon(Icons.cleaning_services, size: 18),
                              label: const Text('Limpiar'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red.shade600,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Descripcion / Referencia',
                        controller: _descriptionCtrl,
                        hint: 'Ej. Compra semanal proveedor Nike - Factura 001',
                        icon: Icons.notes,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Productos',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (orderLines.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.cyan.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_totalItemsCount(orderLines)} unds',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.cyan.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: _isLoading ? null : _createNewProduct,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Nuevo', style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.cyan.shade800,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                        const SizedBox(width: 4),
                        ElevatedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : _selectProductAndStartScanning,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan.shade800,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.search, size: 18),
                          label: const Text('Catálogo'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar por codigo o nombre...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _isLoadingProduct
                              ? Transform.scale(
                                  scale: 0.5,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : (_searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 20),
                                        onPressed: _searchController.clear,
                                      )
                                    : null),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                        onSubmitted: (value) {
                          _handleScannedProduct(value);
                          _searchController.clear();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      onPressed: _isLoading || _isLoadingProduct
                          ? null
                          : _openScanner,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.cyan.shade800,
                      ),
                      icon: const Icon(Icons.qr_code_scanner),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (orderLines.isEmpty)
                  _buildEmptyState()
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orderLines.length,
                    itemBuilder: (context, index) => _buildOrderLineCard(index, orderLines),
                  ),
                if (orderLines.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSummaryCard(orderLines),
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),
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
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 40,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tu orden de entrada esta vacia',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(List<Map<String, dynamic>> orderLines) {
    final cost = _totalInvestment(orderLines);
    final sales = _expectedSales(orderLines);
    final profit = sales - cost;
    final currency = NumberFormat.simpleCurrency();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.cyan.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyan.shade100),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Costo total', style: TextStyle(color: Colors.grey)),
              Text(
                currency.format(cost),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Venta esperada', style: TextStyle(color: Colors.grey)),
              Text(
                currency.format(sales),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ganancia esperada',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                currency.format(profit),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: profit >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderLineCard(int index, List<Map<String, dynamic>> orderLines) {
    final line = orderLines[index];
    final qty = ((line['items'] as List?)?.length ?? 0);
    final cost = (line['cost'] as num?)?.toDouble() ?? 0.0;
    final totalLine = cost * qty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.cyan.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.checkroom,
                    color: Colors.cyan.shade800,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line['productName']?.toString() ?? 'Producto',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$qty unidades escaneadas',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      NumberFormat.simpleCurrency().format(totalLine),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text('Costo: \$$cost'),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Editar Lote'),
                  onPressed: _isLoading
                      ? null
                      : () => _editExistingProduct(index, orderLines),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                  onPressed: _isLoading
                      ? null
                      : () => ref.read(warehouseEntryDraftProvider(widget.bodegaId).notifier).removeOrderLine(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectProductAndStartScanning() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const ProductSelectionScreen(mode: ProductSelectionMode.entry),
      ),
    );

    if (result is Map<String, dynamic>) {
      ref.read(warehouseEntryDraftProvider(widget.bodegaId).notifier).addOrderLine(result);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Se agregaron ${((result['items'] as List?)?.length ?? 0)} unidades',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _editExistingProduct(int index, List<Map<String, dynamic>> orderLines) async {
    final line = orderLines[index];
    final existingItems = ((line['items'] as List?) ?? const [])
        .map((item) => Map<String, String>.from(item as Map))
        .toList();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailEntryScreen(
          productId: line['productId'] as String,
          categoriaId: (line['categoriaId'] as String?) ?? '',
          initialCost: (line['cost'] as num?)?.toDouble() ?? 0.0,
          initialPrice: (line['price'] as num?)?.toDouble() ?? 0.0,
          initialItems: existingItems,
        ),
      ),
    );

    if (result is Map<String, dynamic>) {
      ref.read(warehouseEntryDraftProvider(widget.bodegaId).notifier).updateOrderLine(index, result);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lote actualizado')));
    }
  }

  Future<void> _openScanner() async {
    final code = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeCaptureScreen()),
    );
    if (code is String) {
      await _handleScannedProduct(code);
    }
  }

  Future<void> _handleScannedProduct(String rawSku) async {
    final sku = rawSku.trim().replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    if (sku.isEmpty) return;

    setState(() => _isLoadingProduct = true);
    try {
      final repository = ref.read(inventarioRepositoryProvider);
      final product = await repository.buscarProductoPorCodigoONombre(sku);

      if (product == null) {
        await _handleUnknownBarcode(sku);
        return;
      }

      await _goToProductDetail(
        productId: product.productId,
        categoriaId: product.categoriaId,
        preferredBarcode: product.sku == sku ? sku : null,
      );
    } finally {
      if (mounted) setState(() => _isLoadingProduct = false);
    }
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
        await _createProductFromBarcode(barcode);
        return;
      case _UnknownBarcodeAction.assign:
        await _assignBarcodeToExistingProduct(barcode);
        return;
    }
  }

  Future<void> _createNewProduct() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductCreateScreen(),
      ),
    );
    if (!mounted || result == null) return;

    await _goToProductDetail(
      productId: result['productId'] as String,
      categoriaId: result['categoriaId'] as String?,
    );
  }

  Future<void> _createProductFromBarcode(String barcode) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductCreateScreen(initialBarcode: barcode),
      ),
    );
    if (!mounted || result == null) return;

    await _goToProductDetail(
      productId: result['productId'] as String,
      categoriaId: result['categoriaId'] as String?,
      preferredBarcode: barcode,
    );
  }

  Future<void> _assignBarcodeToExistingProduct(String barcode) async {
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
      final repository = ref.read(inventarioRepositoryProvider);
      await repository.asignarCodigoAProducto(
        productId: product.id,
        barcode: barcode,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Codigo asignado a ${product.nombre}'),
          backgroundColor: Colors.green.shade700,
        ),
      );
      await _goToProductDetail(
        productId: product.id,
        categoriaId: product.categoriaId,
        preferredBarcode: barcode,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_inventoryErrorMessage(e)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _goToProductDetail({
    required String productId,
    required String? categoriaId,
    String? preferredBarcode,
  }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailEntryScreen(
          productId: productId,
          categoriaId: categoriaId ?? '',
          preferredBarcode: preferredBarcode,
        ),
      ),
    );

    if (result is Map<String, dynamic>) {
      ref.read(warehouseEntryDraftProvider(widget.bodegaId).notifier).addOrderLine(result);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Se agregaron ${((result['items'] as List?)?.length ?? 0)} unidades',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
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
