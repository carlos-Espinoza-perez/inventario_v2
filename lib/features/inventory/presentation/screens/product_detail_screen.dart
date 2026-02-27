import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/providers/database_provider.dart';
import 'package:inventario_v2/features/inventory/data/collections/categoria_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/producto_collection.dart';

import 'package:inventario_v2/features/inventory/data/collections/codigo_producto_collection.dart'; // Importar colección de variantes
import 'package:inventario_v2/features/inventory/data/repository/movimiento_repository.dart';
import 'package:inventario_v2/features/inventory/presentation/providers/warehouse_inventory_provider.dart'; // Para inventarioRepositoryProvider
import 'package:isar/isar.dart'; // Necesario para .filter()
import 'package:intl/intl.dart';
import 'package:inventario_v2/features/inventory/data/collections/inventario_collection.dart';
import 'package:inventario_v2/features/inventory/data/providers/producto_provider.dart';

// 1. Provider para cargar el producto individual
final productDetailProvider =
    FutureProvider.family<ProductoCollection?, String>((ref, id) async {
      final isar = await ref.watch(isarDbProvider.future);
      return await isar.productoCollections
          .filter()
          .serverIdEqualTo(id)
          .findFirst();
    });

// 2. Provider para cargar el historial de movimientos (Kardex)
final productHistoryProvider =
    FutureProvider.family<
      List<Map<String, dynamic>>,
      ({String id, String? bodegaId})
    >((ref, args) async {
      final repo = await ref.watch(movimientoRepositoryProvider.future);
      return repo.obtenerHistorialProducto(args.id, bodegaId: args.bodegaId);
    });

// 3. Provider para cargar variantes y stock total
final productVariantsProvider =
    FutureProvider.family<
      List<Map<String, dynamic>>,
      ({String id, String? bodegaId})
    >((ref, args) async {
      // Usamos el inventarioRepositoryProvider que ya existe en el proyecto
      final repo = await ref.watch(inventarioRepositoryProvider.future);
      return repo.obtenerVariantesProducto(args.id, bodegaId: args.bodegaId);
    });

// 4. Provider para obtener nombre de categoría
final productBodegaInvProvider =
    FutureProvider.family<
      InventarioCollection?,
      ({String productId, String bodegaId})
    >((ref, args) async {
      final isar = await ref.watch(isarDbProvider.future);
      return await isar.inventarioCollections
          .filter()
          .productoIdEqualTo(args.productId)
          .bodegaIdEqualTo(args.bodegaId)
          .findFirst();
    });

// 5. Provider para obtener nombre de categoría
final tempCategoryNameProvider = FutureProvider.family<String, String>((
  ref,
  catId,
) async {
  final isar = await ref.watch(isarDbProvider.future);
  final cat = await isar.categoriaCollections
      .filter()
      .serverIdEqualTo(catId)
      .findFirst();
  return cat?.nombre ?? 'Sin Categoría';
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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        error: (err, st) => Center(child: Text('Error: $err')),
        data: (product) {
          if (product == null) {
            return const Center(child: Text('Producto no encontrado'));
          }

          return Column(
            children: [
              // Tabs
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.blue[800],
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue[800],
                  tabs: const [
                    Tab(text: "Información"),
                    Tab(text: "Kardex"),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Contenido
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGeneralInfo(context, product),
                    _buildHistoryTab(context),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: productAsync.value != null
          ? FloatingActionButton.extended(
              onPressed: () =>
                  _showEditPriceDialog(context, productAsync.value!),
              icon: const Icon(Icons.edit),
              label: const Text("Editar Precio"),
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue[800],
            )
          : null,
    );
  }

  Widget _buildGeneralInfo(BuildContext context, ProductoCollection product) {
    // Obtenemos el nombre de la categoría
    final categoryAsync = ref.watch(
      tempCategoryNameProvider(product.categoriaId),
    );
    final categoryName = categoryAsync.value ?? "Cargando...";

    // Obtenemos variantes
    final variantsAsync = ref.watch(
      productVariantsProvider((
        id: product.serverId,
        bodegaId: widget.bodegaId,
      )),
    );

    // Obtenemos inv local si hay bodegaId
    final invAsync = widget.bodegaId != null
        ? ref.watch(
            productBodegaInvProvider((
              productId: product.serverId,
              bodegaId: widget.bodegaId!,
            )),
          )
        : null;

    final precioAMostrar = invAsync?.value?.precioVenta ?? product.precioBase;
    final costoAMostrar = invAsync?.value?.costoPromedio ?? product.ultimoCosto;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. TARJETA DE IMAGEN Y DATOS BÁSICOS
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Imagen
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[100],
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
                        (product.imagenUrl == null ||
                            product.imagenUrl!.isEmpty)
                        ? Icon(
                            Icons.inventory_2,
                            size: 40,
                            color: Colors.grey[400],
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  // Datos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.nombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          categoryName,
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "SKU: ${product.codigoPersonalizado ?? 'N/A'}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. PRECIOS
          _InfoCard(
            title: "Precios",
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _PriceColumn(
                    label: "Costo Último",
                    amount: costoAMostrar,
                    color: Colors.grey[700],
                  ),
                  Container(width: 1, height: 40, color: Colors.grey[300]),
                  _PriceColumn(
                    label: "Precio Base",
                    amount: precioAMostrar,
                    color: Colors.green[700],
                    isBold: true,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. DESGLOSE DE TALLAS (VARIANTES)
          const Text(
            "Disponibilidad por Talla",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          variantsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text("Error al cargar variantes: $e"),
            data: (variants) {
              if (variants.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("No hay variantes registradas"),
                  ),
                );
              }

              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: variants.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final v = variants[index];
                    final stock =
                        num.tryParse(v['stock'].toString())?.toDouble() ?? 0.0;
                    final price =
                        num.tryParse(
                          v['precio']?.toString() ?? '',
                        )?.toDouble() ??
                        product.precioBase;

                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[50],
                        child: Text(
                          v['talla'].toString(),
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      title: Text("SKU: ${v['sku']}"),
                      subtitle: price != product.precioBase
                          ? Text(
                              "Precio Específico: C\$ ${price?.toStringAsFixed(2)}",
                            )
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: stock > 0
                                  ? Colors.green[50]
                                  : Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${stock.toStringAsFixed(0)} unds",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: stock > 0
                                    ? Colors.green[700]
                                    : Colors.red[700],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.grey,
                            ),
                            onPressed: () => _showEditVariantPriceDialog(
                              context,
                              v['sku'],
                              price,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 80), // Espacio para el FAB
        ],
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    final historyAsync = ref.watch(
      productHistoryProvider((id: widget.productId, bodegaId: widget.bodegaId)),
    );

    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Error al cargar historial: $e")),
      data: (history) {
        if (history.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_toggle_off, size: 60, color: Colors.grey),
                SizedBox(height: 10),
                Text("Sin movimientos registrados"),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final mov = history[index];
            final bool esEntrada =
                mov['tipo'] == 'compra' || mov['tipo'] == 'ajuste_entrada';

            return Card(
              elevation: 0,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: esEntrada
                      ? Colors.green[100]
                      : Colors.orange[100],
                  child: Icon(
                    esEntrada ? Icons.arrow_downward : Icons.arrow_upward,
                    color: esEntrada ? Colors.green[800] : Colors.orange[800],
                    size: 20,
                  ),
                ),
                title: Text(
                  mov['tipo'].toString().toUpperCase().replaceAll('_', ' '),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('dd MMM yyyy, hh:mm a').format(mov['fecha']),
                    ),
                    if (mov['descripcion'] != null &&
                        mov['descripcion'].isNotEmpty)
                      Text(
                        mov['descripcion'],
                        style: const TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min, // Importante para layout
                  children: [
                    Text(
                      "${esEntrada ? '+' : '-'}${mov['cantidad']}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: esEntrada ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                    // Flecha del ExpansionTile se encarga del indicador visual de expansión
                  ],
                ),
                children: [
                  const Divider(height: 1),
                  if (mov['variantes'] != null)
                    ...(mov['variantes'] as List).map((v) {
                      final cantidad = v['cantidad'];
                      final precio = v['precio'];
                      final talla = v['talla'];

                      // Si es registro antiguo sin detalle real (General), lo mostramos como "N/A" o "General"
                      // para que el usuario igual vea la fila si despliega.
                      final displayTalla = talla == 'General' ? 'N/A' : talla;

                      return Container(
                        color: Colors.grey[50],
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                          visualDensity: VisualDensity.compact,
                          leading: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Text(
                              "$displayTalla",
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          title: Text(
                            "SKU: ${v['sku']}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "x$cantidad",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (precio != null)
                                Text(
                                  "C\$ ${(precio as num).toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  if ((mov['variantes'] as List).isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: Text(
                        "Costo Ref: C\$ ${(mov['costo'] as num).toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

  void _showEditVariantPriceDialog(
    BuildContext context,
    String sku,
    double? currentPrice,
  ) {
    final TextEditingController priceCtrl = TextEditingController(
      text: currentPrice?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Editar Precio SKU: $sku"),
        content: TextField(
          controller: priceCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: "Precio Específico",
            prefixText: "C\$ ",
            border: OutlineInputBorder(),
            helperText: "Dejar vacío para usar precio base",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final newPrice = double.tryParse(priceCtrl.text);

              // Actualizar en ISAR
              final isar = await ref.read(isarDbProvider.future);
              await isar.writeTxn(() async {
                // Buscar la variante por SKU (debería ser único por producto, pero buscamos seguro)
                // Como CodigoProductoCollection tiene 'codigoSku'
                // Necesitamos importar codigo_producto_collection.dart si no está.
                // Pero ya está importado en repositories, aquí no directo?
                // Ah, pero necesitamos Isar collection access.

                // Debemos importar el archivo de collection para usar .filter()
                // Ya está en imports.
                final variante = await isar.codigoProductoCollections
                    .filter()
                    .codigoSkuEqualTo(sku)
                    .findFirst();

                if (variante != null) {
                  variante.precioEspecifico = newPrice; // Puede ser null
                  variante.ultimaActualizacion = DateTime.now();
                  variante.pendienteSincronizacion = true;
                  await isar.codigoProductoCollections.put(variante);
                }
              });

              // Refrescar Provider de Variantes
              ref.invalidate(
                productVariantsProvider((
                  id: widget.productId,
                  bodegaId: widget.bodegaId,
                )),
              );
              if (mounted) Navigator.pop(ctx);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Precio de variante actualizado")),
              );
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void _showEditPriceDialog(
    BuildContext context,
    ProductoCollection product,
  ) async {
    // Determine existing specfic price if bodegaId is present
    double? currentVal = product.precioBase;
    InventarioCollection? invMacro;

    final isar = await ref.read(isarDbProvider.future);

    if (widget.bodegaId != null) {
      invMacro = await isar.inventarioCollections
          .filter()
          .productoIdEqualTo(product.serverId)
          .bodegaIdEqualTo(widget.bodegaId!)
          .findFirst();
      if (invMacro != null && invMacro.precioVenta != null) {
        currentVal = invMacro.precioVenta;
      }
    }

    final TextEditingController priceCtrl = TextEditingController(
      text: currentVal?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Editar Precio Base"),
        content: TextField(
          controller: priceCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: "Nuevo Precio",
            prefixText: "C\$ ",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final newPrice = double.tryParse(priceCtrl.text);
              if (newPrice != null) {
                await isar.writeTxn(() async {
                  if (invMacro != null) {
                    // Update only specific bodega
                    invMacro.precioVenta = newPrice;
                    invMacro.ultimaActualizacion = DateTime.now();
                    invMacro.pendienteSincronizacion = true;
                    await isar.inventarioCollections.put(invMacro);
                  } else {
                    // Update global
                    product.precioBase = newPrice;
                    product.ultimoPrecioVenta = newPrice; // Sincronizar
                    product.ultimaActualizacion = DateTime.now();
                    product.pendienteSincronizacion = true;
                    await isar.productoCollections.put(product);
                  }
                });

                // Refrescar Providers
                ref.invalidate(productDetailProvider(product.serverId));
                if (widget.bodegaId != null) {
                  ref.invalidate(
                    productBodegaInvProvider((
                      productId: product.serverId,
                      bodegaId: widget.bodegaId!,
                    )),
                  );
                  // Invalidar el provider de la bodega para que actualice la lista afuera (Requerimiento 1)
                  ref.invalidate(warehouseInventoryProvider(widget.bodegaId!));
                }
                ref.invalidate(listaProductosProvider);

                if (mounted) Navigator.pop(ctx);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Precio actualizado correctamente"),
                  ),
                );
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _PriceColumn extends StatelessWidget {
  final String label;
  final double? amount;
  final Color? color;
  final bool isBold;

  const _PriceColumn({
    required this.label,
    required this.amount,
    this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          "C\$ ${amount?.toStringAsFixed(2) ?? '0.00'}",
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
