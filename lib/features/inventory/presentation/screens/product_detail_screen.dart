import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:inventario_v2/core/constants/permission_codes.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/features/auth/presentation/providers/authorization_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/inventario_provider.dart';

final productDetailProvider = FutureProvider.autoDispose
    .family<Producto?, String>((ref, id) async {
      final db = ref.watch(driftDatabaseProvider);
      return db.inventoryDao.getProductoById(id);
    });

final productHistoryProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, ({String id, String? bodegaId})>((
      ref,
      args,
    ) async {
      final db = ref.watch(driftDatabaseProvider);
      return db.inventoryDao.getHistorialProducto(
        args.id,
        bodegaId: args.bodegaId,
      );
    });

final productVariantsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, ({String id, String? bodegaId})>((
      ref,
      args,
    ) async {
      final repo = ref.watch(inventarioRepositoryProvider);
      return repo.getVariantsWithStock(args.id, args.bodegaId ?? '');
    });

final productPriceHistoryProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, ({String id, String? bodegaId})>((
      ref,
      args,
    ) async {
      if (args.bodegaId == null || args.bodegaId!.isEmpty) {
        return <Map<String, dynamic>>[];
      }
      final db = ref.watch(driftDatabaseProvider);
      return db.inventoryDao.getHistorialPreciosProductoEnBodega(
        productoId: args.id,
        bodegaId: args.bodegaId!,
      );
    });

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  final String? bodegaId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.bodegaId,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final Map<String, double> _editedPrices = {};
  final Map<String, double> _editedCosts = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (product) {
          if (product == null) {
            return const Center(child: Text('Producto no encontrado'));
          }

          return Column(
            children: [
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Información'),
                    Tab(text: 'Precios'),
                    Tab(text: 'Kardex'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGeneralInfo(product),
                    _buildPriceHistory(),
                    _buildHistoryTab(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGeneralInfo(Producto product) {
    final variantsAsync = ref.watch(
      productVariantsProvider((
        id: widget.productId,
        bodegaId: widget.bodegaId,
      )),
    );
    final authorizationAsync = ref.watch(authorizationStateProvider);
    final canEditPrice = authorizationAsync.maybeWhen(
      data: (authorization) => authorization.can(PermissionCode.productUpdate),
      orElse: () => false,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          variantsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (variants) => _ProductSummaryCard(
              product: product,
              variants: _groupVariantRows(_applyEditedValues(variants)),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Stock real por variante',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          variantsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error al cargar variantes: $e'),
            data: (variants) {
              final groupedVariants = _groupVariantRows(
                _applyEditedValues(variants),
              );
              if (groupedVariants.isEmpty) {
                return _SoftCard(
                  child: const Text('No hay variantes registradas en Drift'),
                );
              }

              return Column(
                children: groupedVariants
                    .map(
                      (variant) => _VariantStockCard(
                        variant: variant,
                        onEditPrice: canEditPrice ? _showEditPriceSheet : null,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceHistory() {
    final pricesAsync = ref.watch(
      productPriceHistoryProvider((
        id: widget.productId,
        bodegaId: widget.bodegaId,
      )),
    );

    return pricesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error al cargar historial: $e')),
      data: (rows) {
        if (widget.bodegaId == null || widget.bodegaId!.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Selecciona una bodega para ver los precios registrados',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (rows.isEmpty) {
          return const Center(
            child: Text('Sin precios registrados en esta bodega'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rows.length,
          itemBuilder: (context, index) => _PriceHistoryCard(row: rows[index]),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    final historyAsync = ref.watch(
      productHistoryProvider((id: widget.productId, bodegaId: widget.bodegaId)),
    );

    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error al cargar historial: $e')),
      data: (history) {
        if (history.isEmpty) {
          return const Center(child: Text('Sin movimientos registrados'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final mov = history[index];
            final variants = (mov['variantes'] as List?) ?? const [];
            final groupedVariants = _groupMovementVariantRows(variants);
            final movementId = mov['id']?.toString();
            return _SoftCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    onTap: movementId == null || movementId.isEmpty
                        ? null
                        : () => context.push('/movement-detail/$movementId'),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    title: Text(
                      mov['tipo'].toString().toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      DateFormat(
                        'dd MMM yyyy, hh:mm a',
                      ).format(mov['fecha'] as DateTime),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${mov['cantidad']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (movementId != null && movementId.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.open_in_new_rounded, size: 18),
                        ],
                      ],
                    ),
                  ),
                  if ((mov['descripcion']?.toString().trim() ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(mov['descripcion'].toString()),
                      ),
                    ),
                  if (groupedVariants.isEmpty)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Sin detalle de variantes'),
                      ),
                    )
                  else ...[
                    ...groupedVariants
                        .take(2)
                        .map((variant) => _KardexVariantTile(variant: variant)),
                    if (movementId != null && movementId.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Toca el movimiento para ver el detalle completo',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showEditPriceSheet(Map<String, dynamic> variant) async {
    final variantId = variant['varianteId']?.toString();
    if (variantId == null || variantId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Esta fila agrupa varias variantes. Edita una variante individual.',
          ),
        ),
      );
      return;
    }

    final currentPrice = _asDouble(variant['precio']) ?? 0;
    final currentCost = _asDouble(variant['costo']) ?? 0;

    final authorizationAsync = ref.read(authorizationStateProvider);
    final canEditCost = authorizationAsync.maybeWhen(
      data: (authorization) => authorization.isAdmin,
      orElse: () => false,
    );

    final result = await showModalBottomSheet<Map<String, double>>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _EditPriceSheet(
          productId: widget.productId,
          variant: variant,
          bodegaId: widget.bodegaId,
          currentPrice: currentPrice,
          currentCost: currentCost,
          canEditCost: canEditCost,
        );
      },
    );

    if (result != null) {
      final savedPrice = result['precio'];
      final savedCost = result['costo'];
      setState(() {
        if (savedPrice != null) {
          _editedPrices[variantId] = savedPrice;
        }
        if (savedCost != null) {
          _editedCosts[variantId] = savedCost;
        }
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valores actualizados correctamente')),
      );
    }
  }

  List<Map<String, dynamic>> _applyEditedValues(
    List<Map<String, dynamic>> variants,
  ) {
    if (_editedPrices.isEmpty && _editedCosts.isEmpty) return variants;
    return variants.map((variant) {
      final variantId = variant['varianteId']?.toString();
      if (variantId == null) return variant;

      var updatedVariant = {...variant};

      final editedPrice = _editedPrices[variantId];
      if (editedPrice != null) {
        updatedVariant['precio'] = editedPrice;
      }

      final editedCost = _editedCosts[variantId];
      if (editedCost != null) {
        updatedVariant['costo'] = editedCost;
      }

      return updatedVariant;
    }).toList();
  }
}

class _EditPriceSheet extends ConsumerStatefulWidget {
  final String productId;
  final Map<String, dynamic> variant;
  final String? bodegaId;
  final double currentPrice;
  final double currentCost;
  final bool canEditCost;

  const _EditPriceSheet({
    required this.productId,
    required this.variant,
    required this.bodegaId,
    required this.currentPrice,
    required this.currentCost,
    required this.canEditCost,
  });

  @override
  ConsumerState<_EditPriceSheet> createState() => _EditPriceSheetState();
}

class _EditPriceSheetState extends ConsumerState<_EditPriceSheet> {
  late final TextEditingController _priceController;
  late final TextEditingController _costController;
  String? _priceErrorText;
  String? _costErrorText;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: _formatPriceInput(widget.currentPrice),
    );
    _costController = TextEditingController(
      text: _formatPriceInput(widget.currentCost),
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final parsedPrice = _parseMoneyInput(_priceController.text);
    if (parsedPrice == null || parsedPrice < 0) {
      setState(() {
        _priceErrorText = 'Ingresa un precio válido mayor o igual a 0';
      });
      return;
    }

    double? parsedCost;
    if (widget.canEditCost) {
      parsedCost = _parseMoneyInput(_costController.text);
      if (parsedCost == null || parsedCost < 0) {
        setState(() {
          _costErrorText = 'Ingresa un costo válido mayor o igual a 0';
        });
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final variantId = widget.variant['varianteId']?.toString();
      
      // 1. Guardar precio de venta
      await ref
          .read(inventarioRepositoryProvider)
          .actualizarPrecioVentaVariante(
            productId: widget.productId,
            productVariantId: variantId!,
            bodegaId: widget.bodegaId,
            precioVenta: parsedPrice,
          );

      // 2. Guardar costo si tiene permiso
      if (widget.canEditCost && parsedCost != null) {
        await ref
            .read(inventarioRepositoryProvider)
            .actualizarCostoVariante(
              productId: widget.productId,
              productVariantId: variantId,
              bodegaId: widget.bodegaId,
              costo: parsedCost,
            );
      }

      // Invalida los providers correspondientes para refrescar reactivamente
      ref.invalidate(productVariantsProvider((
        id: widget.productId,
        bodegaId: widget.bodegaId,
      )));
      ref.invalidate(productDetailProvider(widget.productId));
      ref.invalidate(productPriceHistoryProvider((
        id: widget.productId,
        bodegaId: widget.bodegaId,
      )));

      if (mounted) {
        Navigator.pop(context, {
          'precio': parsedPrice,
          if (parsedCost != null) 'costo': parsedCost,
        });
      }
    } catch (_) {
      setState(() {
        _isSaving = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo actualizar los valores. Intenta nuevamente.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.canEditCost ? 'Editar precio y costo' : 'Editar precio de venta',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            [
              _displaySize(widget.variant['talla']),
              _displayCode(widget.variant['sku']),
            ].join(' - '),
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _priceController,
            autofocus: !widget.canEditCost,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: InputDecoration(
              labelText: 'Nuevo precio de venta',
              prefixText: 'C\$ ',
              errorText: _priceErrorText,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) {
              if (_priceErrorText != null) {
                setState(() => _priceErrorText = null);
              }
            },
          ),
          if (widget.canEditCost) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _costController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Nuevo costo',
                prefixText: 'C\$ ',
                errorText: _costErrorText,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_costErrorText != null) {
                  setState(() => _costErrorText = null);
                }
              },
              onSubmitted: _isSaving ? null : (_) => _save(),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Guardar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductSummaryCard extends StatelessWidget {
  final Producto product;
  final List<Map<String, dynamic>> variants;

  const _ProductSummaryCard({required this.product, required this.variants});

  @override
  Widget build(BuildContext context) {
    final firstVariant = variants.isNotEmpty ? variants.first : null;
    final variantPriceLabel = _priceLabel(variants);
    final priceLabel = variants.isNotEmpty && variantPriceLabel != 'C\$ 0.00'
        ? variantPriceLabel
        : (product.precioBase ?? 0) > 0
        ? _money(product.precioBase!)
        : _money(product.ultimoPrecioVenta);
    final cost = product.ultimoCosto > 0
        ? product.ultimoCosto
        : (_asDouble(firstVariant?['costo']) ?? 0);
    final sizes = _realSizes(variants);

    return _SoftCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  image:
                      product.imagenUrl != null && product.imagenUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(product.imagenUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: product.imagenUrl == null || product.imagenUrl!.isEmpty
                    ? Icon(
                        Icons.inventory_2_outlined,
                        size: 38,
                        color: Colors.grey[600],
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 19,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoPill(
                          label: 'SKU',
                          value: _displayCode(
                            product.codigoPersonalizado,
                            fallback: 'Sin codigo',
                          ),
                          icon: Icons.qr_code_2_rounded,
                        ),
                        _InfoPill(
                          label: 'Precio',
                          value: priceLabel,
                          icon: Icons.sell_outlined,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Último costo',
                  value: _money(cost),
                  icon: Icons.receipt_long_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  label: 'Variantes',
                  value: '${variants.length}',
                  icon: Icons.category_outlined,
                ),
              ),
            ],
          ),
          if (sizes.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Tallas disponibles',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...sizes.take(3).map((size) => _SizeChip(size)),
                if (sizes.length > 3) _SizeChip('+${sizes.length - 3}'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _VariantStockCard extends StatelessWidget {
  final Map<String, dynamic> variant;
  final ValueChanged<Map<String, dynamic>>? onEditPrice;

  const _VariantStockCard({required this.variant, this.onEditPrice});

  @override
  Widget build(BuildContext context) {
    final stock = _asDouble(variant['stock']) ?? 0;
    final price = _asDouble(variant['precio']) ?? 0;
    final priceLabel = variant['precioLabel']?.toString() ?? _money(price);

    return _SoftCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blue.shade50,
            child: Icon(
              Icons.inventory_2_outlined,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displaySize(variant['talla']),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _displayCode(variant['sku']),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_formatQuantity(stock)} unds',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    priceLabel,
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ],
              ),
              if (onEditPrice != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Editar precio',
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => onEditPrice!(variant),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceHistoryCard extends StatelessWidget {
  final Map<String, dynamic> row;

  const _PriceHistoryCard({required this.row});

  @override
  Widget build(BuildContext context) {
    final date = row['fecha'] as DateTime?;
    final price = _asDouble(row['precio']) ?? 0;
    final qty = _asDouble(row['cantidad']) ?? 0;

    return _SoftCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.green.shade50,
            child: Icon(
              Icons.price_change_outlined,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displaySize(row['talla']),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    _displayCode(row['sku']),
                    if (date != null)
                      DateFormat('dd MMM yyyy, hh:mm a').format(date),
                  ].join(' • '),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if ((row['descripcion']?.toString().trim() ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      row['descripcion'].toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _money(price),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                '${_formatQuantity(qty)} unds',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KardexVariantTile extends StatelessWidget {
  final Map<String, dynamic> variant;

  const _KardexVariantTile({required this.variant});

  @override
  Widget build(BuildContext context) {
    final qty = _asDouble(variant['cantidad']) ?? 1;
    final price = _asDouble(variant['precio'] ?? variant['price']) ?? 0;
    final color = variant['color']?.toString().trim();
    final titleParts = <String>[
      _displaySize(variant['talla'] ?? variant['size']),
      if (color != null && color.isNotEmpty) color,
      _displayCode(variant['sku'] ?? variant['qr']),
    ];

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: Colors.grey.shade100,
        child: Icon(Icons.check_rounded, size: 16, color: Colors.grey[700]),
      ),
      title: Text(titleParts.join(' - ')),
      subtitle: Text('${_formatQuantity(qty)} unds'),
      trailing: Text(price > 0 ? _money(price) : 'Sin precio'),
    );
  }
}

class _SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const _SoftCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoPill({
    required this.label,
    required this.value,
    required this.icon,
    this.color = Colors.black54,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[800],
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SizeChip extends StatelessWidget {
  final String label;

  const _SizeChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      backgroundColor: Colors.blue.shade50,
      side: BorderSide(color: Colors.blue.shade100),
      labelStyle: TextStyle(
        color: Colors.blue.shade800,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

String _money(double value) => 'C\$ ${value.toStringAsFixed(2)}';

String _formatPriceInput(double value) {
  if (value.truncateToDouble() == value) return value.toStringAsFixed(0);
  return value.toStringAsFixed(2);
}

double? _parseMoneyInput(String value) {
  final normalized = value.trim().replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}

double? _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

String _displaySize(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty || text.toLowerCase() == 'general') {
    return 'Sin talla especifica';
  }
  return text;
}

String _displayCode(Object? value, {String fallback = 'Sin código'}) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return fallback;
  if (text.length <= 22) return text;
  return '${text.substring(0, 18)}...';
}

String _formatQuantity(double value) {
  return value.truncateToDouble() == value
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
}

List<String> _realSizes(List<Map<String, dynamic>> variants) {
  return variants
      .map((variant) => variant['talla']?.toString().trim())
      .whereType<String>()
      .where((size) => size.isNotEmpty && size != 'General')
      .toSet()
      .toList();
}

List<Map<String, dynamic>> _groupVariantRows(List<Map<String, dynamic>> rows) {
  final grouped = <String, Map<String, dynamic>>{};

  for (final row in rows) {
    final talla = _displaySize(row['talla']);
    final color = row['color']?.toString().trim() ?? '';
    final key = '$talla|$color';
    final stock = _asDouble(row['stock']) ?? 0;
    final price = _asDouble(row['precio']) ?? 0;
    final cost = _asDouble(row['costo']) ?? 0;
    final sku = row['sku']?.toString().trim();
    final variantId = row['varianteId']?.toString().trim();

    final current = grouped.putIfAbsent(
      key,
      () => {
        'talla': talla,
        'color': color.isEmpty ? null : color,
        'sku': sku,
        'stock': 0.0,
        'precio': price,
        'costo': cost,
        'precios': <double>[],
        'skus': <String>{},
        'varianteIds': <String>{},
      },
    );

    current['stock'] = (current['stock'] as double) + stock;
    if (price > 0) (current['precios'] as List<double>).add(price);
    if (sku != null && sku.isNotEmpty) {
      (current['skus'] as Set<String>).add(sku);
    }
    if (variantId != null && variantId.isNotEmpty) {
      (current['varianteIds'] as Set<String>).add(variantId);
    }
  }

  final result =
      grouped.values.map((item) {
        final skus = item['skus'] as Set<String>;
        final variantIds = item['varianteIds'] as Set<String>;
        final prices = item['precios'] as List<double>;
        final singleSku = skus.isEmpty ? item['sku'] : skus.first;
        return {
          ...item,
          'sku': skus.length <= 1 ? singleSku : 'Varios códigos',
          'varianteId': variantIds.length == 1 ? variantIds.first : null,
          'precioLabel': _priceLabelFromPrices(prices),
        };
      }).toList()..sort(
        (a, b) => _displaySize(a['talla']).compareTo(_displaySize(b['talla'])),
      );

  return result;
}

List<Map<String, dynamic>> _groupMovementVariantRows(List rows) {
  final grouped = <String, Map<String, dynamic>>{};

  for (final raw in rows) {
    if (raw is! Map) continue;

    final row = Map<String, dynamic>.from(raw);
    final talla = _displaySize(row['talla'] ?? row['size']);
    final color = row['color']?.toString().trim() ?? '';
    final price = _asDouble(row['precio'] ?? row['price']) ?? 0;
    final qty = _asDouble(row['cantidad'] ?? row['quantity']) ?? 1;
    final sku = (row['sku'] ?? row['qr'])?.toString().trim();
    final key = '$talla|$color|$price';

    final current = grouped.putIfAbsent(
      key,
      () => {
        'talla': talla,
        'color': color.isEmpty ? null : color,
        'sku': sku,
        'precio': price,
        'cantidad': 0.0,
        'skus': <String>{},
      },
    );

    current['cantidad'] = (current['cantidad'] as double) + qty;
    if (sku != null && sku.isNotEmpty) {
      (current['skus'] as Set<String>).add(sku);
    }
  }

  final result =
      grouped.values.map((item) {
        final skus = item['skus'] as Set<String>;
        final singleSku = skus.isEmpty ? item['sku'] : skus.first;
        return {
          ...item,
          'sku': skus.length <= 1 ? singleSku : 'Varios codigos',
        };
      }).toList()..sort((a, b) {
        final sizeCompare = _displaySize(
          a['talla'],
        ).compareTo(_displaySize(b['talla']));
        if (sizeCompare != 0) return sizeCompare;

        final colorCompare = (a['color'] ?? '').toString().compareTo(
          (b['color'] ?? '').toString(),
        );
        if (colorCompare != 0) return colorCompare;

        return (_asDouble(a['precio']) ?? 0).compareTo(
          _asDouble(b['precio']) ?? 0,
        );
      });

  return result;
}

String _priceLabel(List<Map<String, dynamic>> rows) {
  return _priceLabelFromPrices(
    rows
        .map((row) => _asDouble(row['precio']) ?? 0)
        .where((price) => price > 0)
        .toList(),
  );
}

String _priceLabelFromPrices(List<double> prices) {
  if (prices.isEmpty) return 'C\$ 0.00';
  prices.sort();
  final min = prices.first;
  final max = prices.last;
  if (min == max) return _money(min);
  return '${_money(min)} - ${_money(max)}';
}
