import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/models/inventory_requests.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/db/exceptions/dao_exceptions.dart';
import 'package:inventario_v2/features/inventory/data/providers/bodega_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/inventario_provider.dart';
import 'package:inventario_v2/features/inventory/domain/use_cases/registrar_traslado_use_case.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/barcode_capture_screen.dart';
import 'package:inventario_v2/features/inventory/presentation/screens/product_selection_screen.dart';

class WarehouseTransferScreen extends ConsumerStatefulWidget {
  final String bodegaOrigenId;

  const WarehouseTransferScreen({super.key, this.bodegaOrigenId = ''});

  @override
  ConsumerState<WarehouseTransferScreen> createState() =>
      _WarehouseTransferScreenState();
}

class _WarehouseTransferScreenState
    extends ConsumerState<WarehouseTransferScreen> {
  String? _selectedOriginWarehouseId;
  String? _selectedDestinationWarehouseId;
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
    final bodegasAsync = ref.watch(bodegaListProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
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
                    'FINALIZAR TRASLADO',
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
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Configuracion de Traslado',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      bodegasAsync.when(
                        loading: () =>
                            const LinearProgressIndicator(minHeight: 2),
                        error: (err, _) => Text('Error cargando bodegas: $err'),
                        data: (bodegas) {
                          final destinationBodegas = _destinationWarehouses(
                            bodegas,
                          );
                          _syncDestinationSelection(destinationBodegas);

                          return Column(
                            children: [
                              DropdownButtonFormField<String>(
                                initialValue: _selectedOriginWarehouseId,
                                decoration: const InputDecoration(
                                  labelText: 'Bodega de ORIGEN',
                                  border: OutlineInputBorder(),
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
                                    _transferItems.clear();
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedDestinationWarehouseId,
                                decoration: const InputDecoration(
                                  labelText: 'Bodega de DESTINO',
                                  border: OutlineInputBorder(),
                                ),
                                items: destinationBodegas
                                    .map(
                                      (b) => DropdownMenuItem(
                                        value: b.serverId,
                                        child: Text(b.nombre),
                                      ),
                                    )
                                    .toList(),
                                onChanged: destinationBodegas.isEmpty
                                    ? null
                                    : (val) {
                                        setState(
                                          () =>
                                              _selectedDestinationWarehouseId =
                                                  val,
                                        );
                                      },
                              ),
                              if (destinationBodegas.isEmpty) ...[
                                const SizedBox(height: 8),
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'No hay bodegas disponibles para destino.',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Items a Trasladar',
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
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _selectProductFromList,
                          icon: const Icon(Icons.list, size: 18),
                          label: const Text('Seleccionar'),
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
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _TransferItemCard(
                      item: _transferItems[index],
                      onDelete: () =>
                          setState(() => _transferItems.removeAt(index)),
                      onChanged: () => setState(() {}),
                    ),
                  ),
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



  List<Bodega> _destinationWarehouses(List<Bodega> bodegas) {
    final originId = _selectedOriginWarehouseId;
    if (originId == null || originId.isEmpty) return bodegas;

    return bodegas.where((b) => b.serverId != originId).toList();
  }

  void _syncDestinationSelection(List<Bodega> destinationBodegas) {
    final currentDestination = _selectedDestinationWarehouseId;
    final hasCurrent = destinationBodegas.any(
      (b) => b.serverId == currentDestination,
    );

    if (destinationBodegas.isEmpty) {
      if (currentDestination != null) {
        _selectedDestinationWarehouseId = null;
      }
      return;
    }

    if (destinationBodegas.length == 1) {
      final onlyDestination = destinationBodegas.first.serverId;
      if (currentDestination != onlyDestination) {
        _selectedDestinationWarehouseId = onlyDestination;
      }
      return;
    }

    if (!hasCurrent) {
      _selectedDestinationWarehouseId = null;
    }
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
            'No hay items en el traslado',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanSingleProduct() async {
    final originWarehouseId = _selectedOriginWarehouseId;
    if (originWarehouseId == null || originWarehouseId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona primero la bodega de origen'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final scannedCode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeCaptureScreen()),
    );

    if (scannedCode is! String) return;

    final normalizedCode = scannedCode.trim().replaceAll(
      RegExp(r'[\x00-\x1F\x7F]'),
      '',
    );
    if (normalizedCode.isEmpty) return;

    final repository = ref.read(inventarioRepositoryProvider);
    final draft = await repository.crearBorradorTrasladoDesdeCodigo(
      query: normalizedCode,
      bodegaOrigenId: originWarehouseId,
    );

    if (draft == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se encontro stock disponible para el codigo: $normalizedCode',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _addTransferDraft(draft);
  }

  Future<void> _selectProductFromList() async {
    final originWarehouseId = _selectedOriginWarehouseId;
    if (originWarehouseId == null || originWarehouseId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona primero la bodega de origen')),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductSelectionScreen(
          mode: ProductSelectionMode.transfer,
          originWarehouseId: originWarehouseId,
        ),
      ),
    );

    if (result is List) {
      for (final item in result) {
        _transferItems.add(Map<String, dynamic>.from(item as Map));
      }
      setState(() {});
    } else if (result is Map) {
      setState(() => _transferItems.add(Map<String, dynamic>.from(result)));
    }
  }

  void _addTransferDraft(TransferItemDraft draft) {
    setState(() {
      _transferItems.add({
        'productId': draft.productId,
        'name': draft.nombre,
        'qr': draft.sku,
        'size': draft.size,
        'cost': draft.cost,
        'price': draft.price,
        'cantidad': draft.cantidad,
        'availableStock': draft.availableStock,
      });
    });
  }

  Future<void> _finalizeTransfer() async {
    final originWarehouseId = _selectedOriginWarehouseId;
    final destinationWarehouseId = _selectedDestinationWarehouseId;

    if (originWarehouseId == null || destinationWarehouseId == null) {
      return;
    }

    if (originWarehouseId == destinationWarehouseId) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La bodega origen y destino no pueden ser iguales.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final registrarTraslado = ref.read(registrarTrasladoUseCaseProvider);

      await registrarTraslado.ejecutar(
        originWarehouseId: originWarehouseId,
        destinationWarehouseId: destinationWarehouseId,
        descripcion: 'Traslado App - ${_transferItems.length} items',
        transferItems: _transferItems,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Traslado registrado correctamente'),
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
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _inventoryErrorMessage(Object error) {
    return switch (error) {
      WarehouseNotFoundException(:final message) => message,
      InvalidTransferException(:final message) => message,
      StockInsuficienteException(:final message) => message,
      ContextoInvalidoException(:final message) => message,
      DaoException(:final message) => message,
      _ => 'Error en traslado: $error',
    };
  }
}

class _TransferItemCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  const _TransferItemCard({
    required this.item,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  State<_TransferItemCard> createState() => _TransferItemCardState();
}

class _TransferItemCardState extends State<_TransferItemCard> {
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _costCtrl;
  late final TextEditingController _priceCtrl;

  String _formatNum(double val) {
    if (val % 1 == 0) {
      return val.toInt().toString();
    }
    return val.toString();
  }

  @override
  void initState() {
    super.initState();
    _qtyCtrl = TextEditingController(
      text: ((widget.item['cantidad'] as num?)?.toDouble() ?? 1.0)
          .toStringAsFixed(0),
    );
    final double cost = (widget.item['cost'] as num?)?.toDouble() ?? 0.0;
    final double price = (widget.item['price'] as num?)?.toDouble() ?? 0.0;
    _costCtrl = TextEditingController(text: _formatNum(cost));
    _priceCtrl = TextEditingController(text: _formatNum(price));
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _costCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.orange.shade50,
                foregroundColor: Colors.orange.shade700,
                child: const Icon(Icons.inventory_2_outlined, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item['name']?.toString() ?? 'Producto',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'SKU: ${widget.item['qr'] ?? widget.item['productId']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        if (widget.item['size'] != null &&
                            widget.item['size'].toString().trim().isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: widget.item['size'].toString() == 'General'
                                  ? Colors.grey[100]
                                  : Colors.blue[50],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.item['size'].toString(),
                              style: TextStyle(
                                fontSize: 10,
                                color: widget.item['size'].toString() == 'General'
                                    ? Colors.grey[600]
                                    : Colors.blue[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      'Disponible: ${((widget.item['availableStock'] as num?)?.toDouble() ?? 0).toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.close, color: Colors.redAccent),
              ),
            ],
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: _FieldCell(
                  label: 'Cant.',
                  controller: _qtyCtrl,
                  onChanged: (value) {
                    final qty = double.tryParse(value);
                    if (qty != null) {
                      widget.item['cantidad'] = qty;
                      widget.onChanged();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FieldCell(
                  label: 'Costo',
                  controller: _costCtrl,
                  onChanged: (value) {
                    widget.item['cost'] = double.tryParse(value) ?? 0.0;
                    widget.onChanged();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FieldCell(
                  label: 'Precio',
                  controller: _priceCtrl,
                  onChanged: (value) {
                    widget.item['price'] = double.tryParse(value) ?? 0.0;
                    widget.onChanged();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FieldCell extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _FieldCell({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 10,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
