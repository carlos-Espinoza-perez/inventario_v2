import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/inventario_provider.dart';

final productDetailProvider = FutureProvider.family<Producto?, String>((
  ref,
  id,
) async {
  final db = ref.watch(driftDatabaseProvider);
  return db.inventoryDao.getProductoById(id);
});

final productHistoryProvider =
    FutureProvider.family<
      List<Map<String, dynamic>>,
      ({String id, String? bodegaId})
    >((ref, args) async {
      final db = ref.watch(driftDatabaseProvider);
      return db.inventoryDao.getHistorialProducto(
        args.id,
        bodegaId: args.bodegaId,
      );
    });

final productVariantsProvider =
    FutureProvider.family<
      List<Map<String, dynamic>>,
      ({String id, String? bodegaId})
    >((ref, args) async {
      final repo = await ref.watch(inventarioRepositoryProvider.future);
      return repo.getVariantsWithStock(args.id, args.bodegaId ?? '');
    });

final productPriceByWarehouseProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, id) async {
      final db = ref.watch(driftDatabaseProvider);
      return db.inventoryDao.getPreciosProductoPorBodega(id);
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
                    Tab(text: 'Informacion'),
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
                    _buildPriceByWarehouse(product),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 0,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      image:
                          product.imagenUrl != null &&
                              product.imagenUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(product.imagenUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child:
                        product.imagenUrl == null || product.imagenUrl!.isEmpty
                        ? const Icon(Icons.inventory_2, size: 36)
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
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'SKU base: ${product.codigoPersonalizado ?? 'N/A'}',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Precio base: C\$ ${(product.precioBase ?? 0).toStringAsFixed(2)}',
                        ),
                        Text(
                          'Ultimo costo: C\$ ${product.ultimoCosto.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
              if (variants.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No hay variantes registradas en Drift'),
                  ),
                );
              }

              return Card(
                elevation: 0,
                color: Colors.white,
                child: Column(
                  children: variants
                      .map(
                        (variant) => ListTile(
                          title: Text(
                            '${variant['talla'] ?? 'General'} • ${variant['sku']}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${(variant['stock'] as num?)?.toString() ?? '0'} unds',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'C\$ ${((variant['precio'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceByWarehouse(Producto product) {
    final pricesAsync = ref.watch(
      productPriceByWarehouseProvider(widget.productId),
    );

    return pricesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error al cargar precios: $e')),
      data: (rows) {
        if (rows.isEmpty) {
          return const Center(child: Text('No hay precios por bodega'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rows.length,
          itemBuilder: (context, index) {
            final row = rows[index];
            return Card(
              elevation: 0,
              child: ListTile(
                title: Text('${row['bodega']} • ${row['sku']}'),
                subtitle: Text(
                  'Talla: ${row['talla']}  Color: ${row['color'] ?? 'N/A'}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'C\$ ${((row['precio'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Stock: ${row['stock']}'),
                  ],
                ),
              ),
            );
          },
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
            return Card(
              elevation: 0,
              child: ExpansionTile(
                title: Text(mov['tipo'].toString().toUpperCase()),
                subtitle: Text(
                  DateFormat(
                    'dd MMM yyyy, hh:mm a',
                  ).format(mov['fecha'] as DateTime),
                ),
                trailing: Text(
                  '${mov['cantidad']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  if (mov['descripcion'] != null)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(mov['descripcion'].toString()),
                    ),
                  if (variants.isNotEmpty)
                    ...variants.map(
                      (variant) => ListTile(
                        dense: true,
                        title: Text(
                          '${variant['talla'] ?? 'General'} • ${variant['sku'] ?? 'N/A'}',
                        ),
                        trailing: Text(
                          'C\$ ${((variant['precio'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
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
}
