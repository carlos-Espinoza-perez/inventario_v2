import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../exceptions/dao_exceptions.dart';
import '../models/dashboard_models.dart';
import '../models/inventory_requests.dart';
import '../models/product_catalog_models.dart';
import '../models/producto_stock_drift.dart';
import '../tables/auth_tables.dart';
import '../tables/inventory_tables.dart';
import '../tables/logistics_tables.dart';
import 'base_dao.dart';

part 'inventory_dao.g.dart';

@DriftAccessor(
  tables: [
    Categorias,
    Productos,
    ProductoVariantes,
    Inventarios,
    Bodegas,
    Movimientos,
    DetalleMovimientos,
  ],
)
class InventoryDao extends BaseDao with _$InventoryDaoMixin {
  InventoryDao(super.db);

  Expression<bool> _isPending(GeneratedColumn<String> column) {
    return column.equals('pending_insert') | column.equals('pending_update');
  }

  Future<void> upsertCategoria(CategoriasCompanion categoria) {
    return into(categorias).insertOnConflictUpdate(categoria);
  }

  Future<void> upsertProducto(ProductosCompanion producto) {
    return into(productos).insertOnConflictUpdate(producto);
  }

  Future<void> upsertProductoVariante(ProductoVariantesCompanion variante) {
    return into(productoVariantes).insertOnConflictUpdate(variante);
  }

  Future<ProductoVariante> assignBarcodeToProduct({
    required String productoId,
    required String barcode,
  }) async {
    final normalizedBarcode = barcode.trim();
    if (normalizedBarcode.isEmpty) {
      throw const ContextoInvalidoException('El codigo no puede estar vacio.');
    }

    final context = await getRequiredContext();
    final now = DateTime.now();

    final producto =
        await (select(productos)
              ..where((tbl) => tbl.id.equals(productoId))
              ..where((tbl) => tbl.estado.equals(true))
              ..limit(1))
            .getSingleOrNull();
    if (producto == null) {
      throw ContextoInvalidoException(
        'El producto $productoId no existe en Drift.',
      );
    }

    final existingBarcode =
        await (select(productoVariantes)
              ..where((tbl) => tbl.sku.equals(normalizedBarcode))
              ..where((tbl) => tbl.estado.equals(true))
              ..limit(1))
            .getSingleOrNull();
    if (existingBarcode != null) {
      if (existingBarcode.productoId == productoId) return existingBarcode;
      throw ContextoInvalidoException(
        'El codigo $normalizedBarcode ya esta asignado a otro producto.',
      );
    }

    final newId = const Uuid().v4();
    await into(productoVariantes).insert(
      ProductoVariantesCompanion.insert(
        id: newId,
        productoId: productoId,
        sku: normalizedBarcode,
        talla: const Value('General'),
        color: const Value('General'),
        precioEspecifico: Value(producto.precioBase),
        costoEspecifico: Value(producto.ultimoCosto),
        usuarioRegistroId: Value(context.usuarioId),
        estado: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
        syncStatus: const Value('pending_insert'),
      ),
    );

    return (select(
      productoVariantes,
    )..where((tbl) => tbl.id.equals(newId))).getSingle();
  }

  Future<void> upsertInventario(InventariosCompanion inventario) {
    return into(inventarios).insertOnConflictUpdate(inventario);
  }

  Future<List<ProductCatalogItemDrift>> getCatalogItems({
    String? empresaId,
    String? bodegaId,
    int? limit,
    int offset = 0,
  }) async {
    final resolvedEmpresaId = empresaId ?? await getRequiredEmpresaId();
    final resolvedBodegaId = bodegaId ?? (await getRequiredContext()).bodegaId;

    final rows =
        await (select(productos).join([
                leftOuterJoin(
                  productoVariantes,
                  productoVariantes.productoId.equalsExp(productos.id) &
                      productoVariantes.estado.equals(true),
                ),
                if (resolvedBodegaId != null && resolvedBodegaId.isNotEmpty)
                  leftOuterJoin(
                    inventarios,
                    inventarios.productoVarianteId.equalsExp(
                          productoVariantes.id,
                        ) &
                        inventarios.bodegaId.equals(resolvedBodegaId) &
                        inventarios.estado.equals(true),
                  ),
              ])
              ..where(
                productos.empresaId.equals(resolvedEmpresaId) &
                    productos.estado.equals(true),
              )
              ..orderBy([OrderingTerm.asc(productos.nombre)])
              ..limit(limit ?? 1000, offset: offset))
            .get();

    final grouped = <String, ProductCatalogItemDrift>{};
    for (final row in rows) {
      final producto = row.readTable(productos);
      final variante = row.readTableOrNull(productoVariantes);
      final inventarioActual =
          resolvedBodegaId == null || resolvedBodegaId.isEmpty
          ? null
          : row.readTableOrNull(inventarios);

      grouped.putIfAbsent(
        producto.id,
        () => ProductCatalogItemDrift(
          producto: producto,
          variante: variante,
          stock: inventarioActual?.cantidadActual ?? 0,
          costoPromedio:
              inventarioActual?.costoPromedio ?? producto.ultimoCosto,
        ),
      );
    }
    return grouped.values.toList();
  }

  Stream<List<ProductCatalogItemDrift>> watchCatalogItems({
    String? empresaId,
    String? bodegaId,
  }) {
    return Stream.fromFuture(
      empresaId == null ? getRequiredEmpresaId() : Future.value(empresaId),
    ).asyncExpand((resolvedEmpresaId) {
      return Stream.fromFuture(
        bodegaId == null
            ? getRequiredContext().then((ctx) => ctx.bodegaId)
            : Future.value(bodegaId),
      ).asyncExpand((resolvedBodegaId) {
        final query =
            select(productos).join([
                leftOuterJoin(
                  productoVariantes,
                  productoVariantes.productoId.equalsExp(productos.id) &
                      productoVariantes.estado.equals(true),
                ),
                if (resolvedBodegaId != null && resolvedBodegaId.isNotEmpty)
                  leftOuterJoin(
                    inventarios,
                    inventarios.productoVarianteId.equalsExp(
                          productoVariantes.id,
                        ) &
                        inventarios.bodegaId.equals(resolvedBodegaId) &
                        inventarios.estado.equals(true),
                  ),
              ])
              ..where(
                productos.empresaId.equals(resolvedEmpresaId) &
                    productos.estado.equals(true),
              )
              ..orderBy([OrderingTerm.asc(productos.nombre)]);

        return query.watch().map((rows) {
          final grouped = <String, ProductCatalogItemDrift>{};
          for (final row in rows) {
            final producto = row.readTable(productos);
            final variante = row.readTableOrNull(productoVariantes);
            final inventarioActual =
                resolvedBodegaId == null || resolvedBodegaId.isEmpty
                ? null
                : row.readTableOrNull(inventarios);

            grouped.putIfAbsent(
              producto.id,
              () => ProductCatalogItemDrift(
                producto: producto,
                variante: variante,
                stock: inventarioActual?.cantidadActual ?? 0,
                costoPromedio:
                    inventarioActual?.costoPromedio ?? producto.ultimoCosto,
              ),
            );
          }
          return grouped.values.toList();
        });
      });
    });
  }

  Future<List<BarcodeLookupResultDrift>> findProductsByBarcode(
    String code,
  ) async {
    final rows =
        await (select(productoVariantes).join([
                innerJoin(
                  productos,
                  productos.id.equalsExp(productoVariantes.productoId),
                ),
              ])
              ..where(productoVariantes.sku.equals(code))
              ..where(productos.estado.equals(true))
              ..where(productoVariantes.estado.equals(true)))
            .get();

    return rows
        .map(
          (row) => BarcodeLookupResultDrift(
            producto: row.readTable(productos),
            variante: row.readTable(productoVariantes),
          ),
        )
        .toList();
  }

  Future<Producto> saveProductLifecycle({
    String? productId,
    required String empresaId,
    required String usuarioRegistroId,
    required String nombre,
    required String categoriaId,
    required String? especificacionJson,
    required String? imagenLocal,
    required String? imagenUrl,
    required double ultimoCosto,
    required double precioBase,
    String? defaultSku,
    required Iterable<String> bodegaIds,
  }) async {
    final now = DateTime.now();
    final resolvedProductId = productId ?? const Uuid().v4();
    final resolvedVariantId = const Uuid().v4();
    final resolvedSku = (defaultSku == null || defaultSku.isEmpty)
        ? 'GEN-${resolvedProductId.substring(0, 8).toUpperCase()}'
        : defaultSku;

    return transaction(() async {
      await into(productos).insertOnConflictUpdate(
        ProductosCompanion.insert(
          id: resolvedProductId,
          empresaId: empresaId,
          categoriaId: Value(categoriaId),
          nombre: nombre,
          especificacionJson: Value(especificacionJson),
          precioBase: Value(precioBase),
          ultimoCosto: Value(ultimoCosto),
          ultimoPrecioVenta: Value(precioBase),
          imagenUrl: Value(imagenUrl),
          imagenLocal: Value(imagenLocal),
          usuarioRegistroId: Value(usuarioRegistroId),
          estado: const Value(true),
          createdAt: Value(now),
          updatedAt: Value(now),
          fechaEliminacion: const Value.absent(),
          syncStatus: Value(
            productId == null ? 'pending_insert' : 'pending_update',
          ),
        ),
      );

      final existingVariant =
          await (select(productoVariantes)
                ..where((tbl) => tbl.productoId.equals(resolvedProductId))
                ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)])
                ..limit(1))
              .getSingleOrNull();

      final variantId = existingVariant?.id ?? resolvedVariantId;
      await into(productoVariantes).insertOnConflictUpdate(
        ProductoVariantesCompanion.insert(
          id: variantId,
          productoId: resolvedProductId,
          sku: resolvedSku,
          talla: const Value('General'),
          color: const Value('General'),
          precioEspecifico: Value(precioBase),
          costoEspecifico: Value(ultimoCosto),
          usuarioRegistroId: Value(usuarioRegistroId),
          estado: const Value(true),
          createdAt: Value(now),
          updatedAt: Value(now),
          syncStatus: Value(
            existingVariant == null ? 'pending_insert' : 'pending_update',
          ),
        ),
      );

      for (final bodegaId in bodegaIds) {
        final existingInventory =
            await (select(inventarios)
                  ..where((tbl) => tbl.productoVarianteId.equals(variantId))
                  ..where((tbl) => tbl.bodegaId.equals(bodegaId))
                  ..limit(1))
                .getSingleOrNull();
        if (existingInventory == null) {
          await into(inventarios).insert(
            InventariosCompanion.insert(
              id: const Uuid().v4(),
              productoVarianteId: variantId,
              bodegaId: bodegaId,
              cantidadActual: const Value(0),
              precioVenta: Value(precioBase),
              costoPromedio: Value(ultimoCosto),
              actualizadoPor: Value(usuarioRegistroId),
              estado: const Value(true),
              createdAt: Value(now),
              updatedAt: Value(now),
              fechaEliminacion: const Value.absent(),
              syncStatus: const Value('pending_insert'),
            ),
          );
        } else {
          await (update(
            inventarios,
          )..where((tbl) => tbl.id.equals(existingInventory.id))).write(
            InventariosCompanion(
              precioVenta: Value(precioBase),
              costoPromedio: Value(ultimoCosto),
              actualizadoPor: Value(usuarioRegistroId),
              updatedAt: Value(now),
              syncStatus: const Value('pending_update'),
            ),
          );
        }
      }

      return (select(
        productos,
      )..where((tbl) => tbl.id.equals(resolvedProductId))).getSingle();
    });
  }

  Future<Producto?> getProductoById(String productoId) {
    return (select(
      productos,
    )..where((tbl) => tbl.id.equals(productoId))).getSingleOrNull();
  }

  Future<Categoria?> getCategoriaById(String categoriaId) {
    return (select(
      categorias,
    )..where((tbl) => tbl.id.equals(categoriaId))).getSingleOrNull();
  }

  Future<List<ProductoVariante>> getVariantesByProductoId(String productoId) {
    return (select(productoVariantes)
          ..where((tbl) => tbl.productoId.equals(productoId))
          ..where((tbl) => tbl.estado.equals(true))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.sku)]))
        .get();
  }

  Future<List<Map<String, dynamic>>> getHistorialProducto(
    String productoId, {
    String? bodegaId,
  }) async {
    final rows =
        await (select(detalleMovimientos).join([
                innerJoin(
                  movimientos,
                  movimientos.id.equalsExp(detalleMovimientos.movimientoId),
                ),
              ])
              ..where(detalleMovimientos.productoId.equals(productoId))
              ..where(
                bodegaId == null
                    ? const Constant(true)
                    : movimientos.bodegaOrigenId.equals(bodegaId) |
                          movimientos.bodegaDestinoId.equals(bodegaId),
              )
              ..orderBy([OrderingTerm.desc(movimientos.createdAt)]))
            .get();

    return rows
        .map(
          (row) => {
            'id': row.readTable(movimientos).id,
            'fecha': row.readTable(movimientos).createdAt,
            'tipo': row.readTable(movimientos).tipoMovimiento,
            'descripcion': row.readTable(movimientos).descripcion,
            'cantidad': row.readTable(detalleMovimientos).cantidad,
            'costo': row.readTable(detalleMovimientos).costoUnitarioFinal,
            'variantes': row.readTable(detalleMovimientos).variantesJson == null
                ? <Map<String, dynamic>>[]
                : _decodeVariantes(
                    row.readTable(detalleMovimientos).variantesJson!,
                  ),
          },
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> getPreciosProductoPorBodega(
    String productoId,
  ) async {
    final rows =
        await (select(inventarios).join([
                innerJoin(
                  productoVariantes,
                  productoVariantes.id.equalsExp(
                    inventarios.productoVarianteId,
                  ),
                ),
                innerJoin(bodegas, bodegas.id.equalsExp(inventarios.bodegaId)),
              ])
              ..where(productoVariantes.productoId.equals(productoId))
              ..orderBy([OrderingTerm.asc(bodegas.nombre)]))
            .get();

    return rows
        .map(
          (row) => {
            'bodegaId': row.readTable(bodegas).id,
            'bodega': row.readTable(bodegas).nombre,
            'sku': row.readTable(productoVariantes).sku,
            'talla': row.readTable(productoVariantes).talla ?? 'General',
            'color': row.readTable(productoVariantes).color,
            'precio':
                row.readTable(productoVariantes).precioEspecifico ??
                row.readTable(inventarios).precioVenta,
            'costo':
                row.readTable(productoVariantes).costoEspecifico ??
                row.readTable(inventarios).costoPromedio,
            'stock': row.readTable(inventarios).cantidadActual,
          },
        )
        .toList();
  }

  List<Map<String, dynamic>> _decodeVariantes(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is! List) return const <Map<String, dynamic>>[];
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return const <Map<String, dynamic>>[];
    }
  }

  Future<Producto?> searchProductoByCodeOrName(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return null;

    final byCode =
        await (select(productos)
              ..where((tbl) => tbl.codigoPersonalizado.equals(normalized))
              ..limit(1))
            .getSingleOrNull();
    if (byCode != null) return byCode;

    return (select(productos)
          ..where((tbl) => tbl.nombre.like('%$normalized%'))
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<List<Producto>> watchProductosPorEmpresa([String? empresaId]) {
    return Stream.fromFuture(
      empresaId == null ? getRequiredEmpresaId() : Future.value(empresaId),
    ).asyncExpand((resolvedEmpresaId) {
      return (select(productos)
            ..where(
              (tbl) =>
                  tbl.empresaId.equals(resolvedEmpresaId) &
                  tbl.estado.equals(true),
            )
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.nombre)]))
          .watch();
    });
  }

  Stream<List<ProductoStockDrift>> watchStockPorBodega([String? bodegaId]) {
    return Stream.fromFuture(
      bodegaId == null
          ? getRequiredContext().then((ctx) => ctx.bodegaId ?? '')
          : Future.value(bodegaId),
    ).asyncExpand((resolvedBodegaId) {
      final query = select(inventarios).join([
        innerJoin(
          productoVariantes,
          productoVariantes.id.equalsExp(inventarios.productoVarianteId),
        ),
        innerJoin(
          productos,
          productos.id.equalsExp(productoVariantes.productoId),
        ),
      ])..where(inventarios.bodegaId.equals(resolvedBodegaId));

      return query.watch().map(
        (rows) => rows
            .map(
              (row) => ProductoStockDrift(
                producto: row.readTable(productos),
                variante: row.readTable(productoVariantes),
                inventario: row.readTable(inventarios),
              ),
            )
            .toList(),
      );
    });
  }

  Future<List<ProductoStockDrift>> getStockRealPorBodega([
    String? bodegaId,
  ]) async {
    final resolvedBodegaId = bodegaId ?? (await getRequiredContext()).bodegaId;
    if (resolvedBodegaId == null || resolvedBodegaId.isEmpty) {
      throw const ContextoInvalidoException(
        'No se pudo resolver la bodega activa para consultar stock.',
      );
    }

    final rows = await (select(inventarios).join([
      innerJoin(
        productoVariantes,
        productoVariantes.id.equalsExp(inventarios.productoVarianteId),
      ),
      innerJoin(
        productos,
        productos.id.equalsExp(productoVariantes.productoId),
      ),
    ])..where(inventarios.bodegaId.equals(resolvedBodegaId))).get();

    return rows
        .map(
          (row) => ProductoStockDrift(
            producto: row.readTable(productos),
            variante: row.readTable(productoVariantes),
            inventario: row.readTable(inventarios),
          ),
        )
        .toList();
  }

  Future<void> registrarMovimientoLogistico(
    InventoryMovementRequest request,
  ) async {
    final context = await getRequiredContext();
    final now = DateTime.now();
    final usuarioId = context.usuarioId;
    final movimientoId = const Uuid().v4();
    final detalles = _buildDetalleInputs(request);

    await transaction(() async {
      await _validateMovementRequest(request, detalles);

      await into(movimientos).insert(
        MovimientosCompanion.insert(
          id: movimientoId,
          empresaId: context.empresaId,
          tipoMovimiento: request.tipoMovimiento,
          estadoMovimiento: 'aprobado',
          bodegaOrigenId: Value(request.bodegaOrigenId),
          bodegaDestinoId: Value(request.bodegaDestinoId),
          descripcion: Value(request.descripcion),
          usuarioRegistroId: Value(usuarioId),
          estado: const Value(true),
          createdAt: Value(now),
          updatedAt: Value(now),
          syncStatus: const Value('pending_insert'),
        ),
      );

      for (final detalle in detalles) {
        if (request.tipoMovimiento == 'entrada') {
          await _sumarInventario(
            bodegaId: request.bodegaDestinoId,
            productoId: detalle.productoId,
            productoVarianteId: detalle.productoVarianteId,
            cantidad: detalle.cantidad,
            usuarioId: usuarioId,
            costoPromedio: detalle.costoUnitarioFinal,
          );
        } else if (request.tipoMovimiento == 'salida') {
          await _restarInventario(
            bodegaId: request.bodegaOrigenId,
            productoId: detalle.productoId,
            productoVarianteId: detalle.productoVarianteId,
            cantidad: detalle.cantidad,
            usuarioId: usuarioId,
          );
        } else if (request.tipoMovimiento == 'traslado') {
          await _restarInventario(
            bodegaId: request.bodegaOrigenId,
            productoId: detalle.productoId,
            productoVarianteId: detalle.productoVarianteId,
            cantidad: detalle.cantidad,
            usuarioId: usuarioId,
          );
          await _sumarInventario(
            bodegaId: request.bodegaDestinoId,
            productoId: detalle.productoId,
            productoVarianteId: detalle.productoVarianteId,
            cantidad: detalle.cantidad,
            usuarioId: usuarioId,
            costoPromedio: detalle.costoUnitarioFinal,
          );
        } else if (request.tipoMovimiento == 'ajuste') {
          if (detalle.cantidad >= 0) {
            await _sumarInventario(
              bodegaId: request.bodegaDestinoId ?? request.bodegaOrigenId,
              productoId: detalle.productoId,
              productoVarianteId: detalle.productoVarianteId,
              cantidad: detalle.cantidad,
              usuarioId: usuarioId,
              costoPromedio: detalle.costoUnitarioFinal,
            );
          } else {
            await _restarInventario(
              bodegaId: request.bodegaOrigenId ?? request.bodegaDestinoId,
              productoId: detalle.productoId,
              productoVarianteId: detalle.productoVarianteId,
              cantidad: detalle.cantidad.abs(),
              usuarioId: usuarioId,
            );
          }
        }

        await into(detalleMovimientos).insert(
          DetalleMovimientosCompanion.insert(
            id: detalle.id,
            movimientoId: movimientoId,
            productoId: detalle.productoId,
            cantidad: detalle.cantidad,
            costoProveedor: Value(detalle.costoProveedor),
            costoUnitarioFinal: Value(detalle.costoUnitarioFinal),
            cargosAdicionalesJson: Value(detalle.cargosAdicionalesJson),
            variantesJson: Value(detalle.variantesJson),
            createdAt: Value(now),
            updatedAt: Value(now),
            syncStatus: const Value('pending_insert'),
          ),
        );
      }
    });
  }

  List<MovimientoInventarioDetalleInput> _buildDetalleInputs(
    InventoryMovementRequest request,
  ) {
    return switch (request) {
      InventoryEntryRequest(:final items) =>
        items
            .map(
              (item) => MovimientoInventarioDetalleInput(
                id: const Uuid().v4(),
                productoId: item.productId,
                productoVarianteId: item.productVariantId,
                cantidad: item.cantidad,
                costoProveedor: item.costoProveedor,
                costoUnitarioFinal: item.costoUnitarioFinal,
                variantesJson:
                    item.variantesJson ??
                    _buildVariantesJson(
                      sku: item.sku,
                      talla: item.talla,
                      color: item.color,
                      cantidad: item.cantidad,
                      precio: item.precioVenta ?? item.costoUnitarioFinal,
                    ),
              ),
            )
            .toList(),
      TransferRequest(:final items) =>
        items
            .map(
              (item) => MovimientoInventarioDetalleInput(
                id: const Uuid().v4(),
                productoId: item.productId,
                productoVarianteId: item.productVariantId,
                cantidad: item.cantidad,
                costoProveedor: item.costoProveedor,
                costoUnitarioFinal: item.costoUnitarioFinal,
                variantesJson: _buildVariantesJson(
                  sku: item.sku,
                  talla: item.size,
                  color: item.color,
                  cantidad: item.cantidad,
                  precio: item.precioVenta ?? item.costoUnitarioFinal,
                ),
              ),
            )
            .toList(),
    };
  }

  String? _buildVariantesJson({
    required String? sku,
    required String? talla,
    required String? color,
    required double cantidad,
    required double precio,
  }) {
    if (sku == null && talla == null && color == null) {
      return null;
    }

    return jsonEncode([
      {
        'sku': sku,
        'talla': talla ?? 'General',
        'color': color,
        'cantidad': cantidad,
        'precio': precio,
      },
    ]);
  }

  Future<void> _validateMovementRequest(
    InventoryMovementRequest request,
    List<MovimientoInventarioDetalleInput> detalles,
  ) async {
    if (detalles.isEmpty) {
      throw const ContextoInvalidoException(
        'El movimiento requiere al menos un detalle.',
      );
    }

    if (request is TransferRequest) {
      if (request.originWarehouseId == request.destinationWarehouseId) {
        throw const InvalidTransferException(
          'La bodega origen y destino no pueden ser iguales.',
        );
      }
      await _ensureWarehouseExists(
        request.originWarehouseId,
        'La bodega origen no existe.',
      );
      await _ensureWarehouseExists(
        request.destinationWarehouseId,
        'La bodega destino no existe.',
      );
    } else if (request is InventoryEntryRequest) {
      await _ensureWarehouseExists(
        request.destinationWarehouseId,
        'La bodega destino no existe.',
      );
    }

    for (final detalle in detalles) {
      if (detalle.cantidad <= 0) {
        throw const ContextoInvalidoException(
          'Todas las cantidades deben ser mayores que cero.',
        );
      }

      final producto =
          await (select(productos)
                ..where((tbl) => tbl.id.equals(detalle.productoId))
                ..limit(1))
              .getSingleOrNull();

      if (producto == null) {
        throw ContextoInvalidoException(
          'El producto ${detalle.productoId} no existe en Drift.',
        );
      }

      if (detalle.productoVarianteId != null &&
          detalle.productoVarianteId!.isNotEmpty) {
        final variante =
            await (select(productoVariantes)
                  ..where((tbl) => tbl.id.equals(detalle.productoVarianteId!))
                  ..limit(1))
                .getSingleOrNull();

        if (variante == null || variante.productoId != detalle.productoId) {
          throw ContextoInvalidoException(
            'La variante ${detalle.productoVarianteId} no coincide con el producto ${detalle.productoId}.',
          );
        }
      }
    }
  }

  Future<void> _ensureWarehouseExists(String? bodegaId, String message) async {
    if (bodegaId == null || bodegaId.isEmpty) {
      throw WarehouseNotFoundException(message);
    }

    final warehouse =
        await (select(bodegas)
              ..where((tbl) => tbl.id.equals(bodegaId))
              ..limit(1))
            .getSingleOrNull();

    if (warehouse == null) {
      throw WarehouseNotFoundException(message);
    }
  }

  Future<void> _restarInventario({
    required String? bodegaId,
    required String productoId,
    String? productoVarianteId,
    required double cantidad,
    required String usuarioId,
  }) async {
    if (bodegaId == null || bodegaId.isEmpty) {
      throw const WarehouseNotFoundException(
        'La bodega origen es obligatoria para salidas y traslados.',
      );
    }

    final inventario =
        await (select(inventarios)
              ..where((tbl) => tbl.bodegaId.equals(bodegaId))
              ..where(
                (tbl) => productoVarianteId == null
                    ? tbl.productoVarianteId.isInQuery(
                        selectOnly(productoVariantes)
                          ..addColumns([productoVariantes.id])
                          ..where(
                            productoVariantes.productoId.equals(productoId),
                          ),
                      )
                    : tbl.productoVarianteId.equals(productoVarianteId),
              )
              ..limit(1))
            .getSingleOrNull();

    if (inventario == null || inventario.cantidadActual < cantidad) {
      throw StockInsuficienteException(
        'Stock insuficiente para el producto $productoId en la bodega $bodegaId.',
      );
    }

    await (update(
      inventarios,
    )..where((tbl) => tbl.id.equals(inventario.id))).write(
      InventariosCompanion(
        cantidadActual: Value(inventario.cantidadActual - cantidad),
        actualizadoPor: Value(usuarioId),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending_update'),
      ),
    );
  }

  Future<void> _sumarInventario({
    required String? bodegaId,
    required String productoId,
    String? productoVarianteId,
    required double cantidad,
    required String usuarioId,
    required double costoPromedio,
  }) async {
    if (bodegaId == null || bodegaId.isEmpty) {
      throw const WarehouseNotFoundException(
        'La bodega destino es obligatoria para entradas y traslados.',
      );
    }

    final current =
        await (select(inventarios)
              ..where((tbl) => tbl.bodegaId.equals(bodegaId))
              ..where(
                (tbl) => productoVarianteId == null
                    ? tbl.productoVarianteId.isInQuery(
                        selectOnly(productoVariantes)
                          ..addColumns([productoVariantes.id])
                          ..where(
                            productoVariantes.productoId.equals(productoId),
                          ),
                      )
                    : tbl.productoVarianteId.equals(productoVarianteId),
              )
              ..limit(1))
            .getSingleOrNull();

    if (current == null) {
      final resolvedVarianteId =
          productoVarianteId ??
          await _ensureDefaultVariantForProducto(
            productoId: productoId,
            usuarioId: usuarioId,
          );
      await into(inventarios).insert(
        InventariosCompanion.insert(
          id: const Uuid().v4(),
          productoVarianteId: resolvedVarianteId,
          bodegaId: bodegaId,
          cantidadActual: Value(cantidad),
          costoPromedio: Value(costoPromedio),
          actualizadoPor: Value(usuarioId),
          updatedAt: Value(DateTime.now()),
          syncStatus: const Value('pending_insert'),
        ),
      );
      return;
    }

    final nuevaCantidad = current.cantidadActual + cantidad;
    final nuevoCostoPromedio = nuevaCantidad > 0
        ? ((current.cantidadActual * current.costoPromedio) +
                  (cantidad * costoPromedio)) /
              nuevaCantidad
        : current.costoPromedio;

    await (update(
      inventarios,
    )..where((tbl) => tbl.id.equals(current.id))).write(
      InventariosCompanion(
        cantidadActual: Value(nuevaCantidad),
        costoPromedio: Value(nuevoCostoPromedio),
        actualizadoPor: Value(usuarioId),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending_update'),
      ),
    );
  }

  Future<String> _ensureDefaultVariantForProducto({
    required String productoId,
    required String usuarioId,
  }) async {
    final current =
        await (select(productoVariantes)
              ..where((tbl) => tbl.productoId.equals(productoId))
              ..where((tbl) => tbl.sku.equals('GEN-$productoId'))
              ..limit(1))
            .getSingleOrNull();
    if (current != null) return current.id;

    final newId = const Uuid().v4();
    await into(productoVariantes).insert(
      ProductoVariantesCompanion.insert(
        id: newId,
        productoId: productoId,
        sku: 'GEN-$productoId',
        talla: const Value('General'),
        color: const Value('General'),
        usuarioRegistroId: Value(usuarioId),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending_insert'),
      ),
    );
    return newId;
  }

  Future<List<Categoria>> getPendingCategorias() {
    return (select(
      categorias,
    )..where((tbl) => _isPending(tbl.syncStatus))).get();
  }

  Future<List<Producto>> getPendingProductos() {
    return (select(
      productos,
    )..where((tbl) => _isPending(tbl.syncStatus))).get();
  }

  Future<List<ProductoVariante>> getPendingProductoVariantes() {
    return (select(
      productoVariantes,
    )..where((tbl) => _isPending(tbl.syncStatus))).get();
  }

  Future<List<Inventario>> getPendingInventarios() {
    return (select(
      inventarios,
    )..where((tbl) => _isPending(tbl.syncStatus))).get();
  }

  Future<List<Movimiento>> getPendingMovimientos() {
    return (select(
      movimientos,
    )..where((tbl) => _isPending(tbl.syncStatus))).get();
  }

  Future<List<DetalleMovimiento>> getPendingDetalleMovimientos() {
    return (select(
      detalleMovimientos,
    )..where((tbl) => _isPending(tbl.syncStatus))).get();
  }

  Future<double> getValorTotalInventario({Set<String>? bodegaIds}) async {
    final rows =
        await (select(inventarios).join([
                innerJoin(
                  productoVariantes,
                  productoVariantes.id.equalsExp(
                    inventarios.productoVarianteId,
                  ),
                ),
                innerJoin(
                  productos,
                  productos.id.equalsExp(productoVariantes.productoId),
                ),
              ])
              ..where(inventarios.estado.equals(true))
              ..where(
                bodegaIds == null || bodegaIds.isEmpty
                    ? const Constant(true)
                    : inventarios.bodegaId.isIn(bodegaIds.toList()),
              ))
            .get();

    var total = 0.0;
    for (final row in rows) {
      final inventario = row.readTable(inventarios);
      final variante = row.readTable(productoVariantes);
      final producto = row.readTable(productos);
      final costo =
          variante.costoEspecifico ??
          (inventario.costoPromedio > 0
              ? inventario.costoPromedio
              : producto.ultimoCosto);
      total += inventario.cantidadActual * costo;
    }
    return total;
  }

  Future<List<DashboardLowStockItem>> getLowStockProducts({
    Set<String>? bodegaIds,
    int threshold = 5,
    int limit = 10,
  }) async {
    final rows =
        await (select(inventarios).join([
                innerJoin(
                  productoVariantes,
                  productoVariantes.id.equalsExp(
                    inventarios.productoVarianteId,
                  ),
                ),
                innerJoin(
                  productos,
                  productos.id.equalsExp(productoVariantes.productoId),
                ),
              ])
              ..where(inventarios.estado.equals(true))
              ..where(
                inventarios.cantidadActual.isSmallerOrEqualValue(
                  threshold.toDouble(),
                ),
              )
              ..where(
                bodegaIds == null || bodegaIds.isEmpty
                    ? const Constant(true)
                    : inventarios.bodegaId.isIn(bodegaIds.toList()),
              )
              ..orderBy([OrderingTerm.asc(inventarios.cantidadActual)]))
            .get();

    return rows
        .take(limit)
        .map(
          (row) => DashboardLowStockItem(
            inventarioId: row.readTable(inventarios).id,
            productoId: row.readTable(productos).id,
            nombre: row.readTable(productos).nombre,
            sku: row.readTable(productoVariantes).sku,
            cantidadActual: row.readTable(inventarios).cantidadActual,
            costoPromedio: row.readTable(inventarios).costoPromedio,
          ),
        )
        .toList();
  }

  Future<InventoryReportData> getInventoryReport({
    required Set<String> bodegaIds,
  }) async {
    final rows =
        await (select(inventarios).join([
                innerJoin(
                  productoVariantes,
                  productoVariantes.id.equalsExp(
                    inventarios.productoVarianteId,
                  ),
                ),
                innerJoin(
                  productos,
                  productos.id.equalsExp(productoVariantes.productoId),
                ),
              ])
              ..where(inventarios.estado.equals(true))
              ..where(
                bodegaIds.isEmpty
                    ? const Constant(true)
                    : inventarios.bodegaId.isIn(bodegaIds.toList()),
              ))
            .get();

    var valorTotal = 0.0;
    var criticos = 0;
    var medios = 0;
    var saludables = 0;
    final lowStock = <InventoryLowStockData>[];

    for (final row in rows) {
      final inventario = row.readTable(inventarios);
      final variante = row.readTable(productoVariantes);
      final producto = row.readTable(productos);
      final cantidad = inventario.cantidadActual.toInt();
      final costo =
          variante.costoEspecifico ??
          (inventario.costoPromedio > 0
              ? inventario.costoPromedio
              : producto.ultimoCosto);

      valorTotal += inventario.cantidadActual * costo;

      if (cantidad <= 5) {
        criticos++;
        lowStock.add(
          InventoryLowStockData(
            nombre: producto.nombre,
            sku: variante.sku,
            cantidadActual: cantidad,
            stockMinimo: 5,
          ),
        );
      } else if (cantidad <= 20) {
        medios++;
      } else {
        saludables++;
      }
    }

    lowStock.sort((a, b) => a.cantidadActual.compareTo(b.cantidadActual));

    return InventoryReportData(
      valorTotal: valorTotal,
      totalItems: rows.length,
      criticos: criticos,
      medios: medios,
      saludables: saludables,
      lowStock: lowStock.take(10).toList(),
    );
  }

  Stream<List<Categoria>> watchCategoriasPorEmpresa([String? empresaId]) {
    return Stream.fromFuture(
      empresaId == null ? getRequiredEmpresaId() : Future.value(empresaId),
    ).asyncExpand((resolvedEmpresaId) {
      return (select(categorias)
            ..where(
              (tbl) =>
                  tbl.empresaId.equals(resolvedEmpresaId) &
                  tbl.estado.equals(true),
            )
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.nombre)]))
          .watch();
    });
  }

  Future<Categoria?> findCategoriaByName({
    required String empresaId,
    required String name,
    String? categoriaPadreId,
    String? excludeCategoriaId,
  }) async {
    final result =
        await (select(categorias)..where(
              (tbl) =>
                  tbl.empresaId.equals(empresaId) &
                  tbl.nombre.equals(name) &
                  tbl.estado.equals(true) &
                  (categoriaPadreId == null
                      ? tbl.categoriaPadreId.isNull()
                      : tbl.categoriaPadreId.equals(categoriaPadreId)),
            ))
            .get();
    for (final categoria in result) {
      if (excludeCategoriaId == null || categoria.id != excludeCategoriaId) {
        return categoria;
      }
    }
    return null;
  }

  Future<Categoria> saveCategoria({
    String? categoriaId,
    required String empresaId,
    required String nombre,
    String? categoriaPadreId,
    required String usuarioRegistroId,
  }) async {
    final now = DateTime.now();
    final resolvedId = categoriaId ?? const Uuid().v4();
    await into(categorias).insertOnConflictUpdate(
      CategoriasCompanion.insert(
        id: resolvedId,
        empresaId: empresaId,
        nombre: nombre,
        categoriaPadreId: Value(categoriaPadreId),
        usuarioRegistroId: Value(usuarioRegistroId),
        estado: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
        fechaEliminacion: const Value.absent(),
        syncStatus: Value(
          categoriaId == null ? 'pending_insert' : 'pending_update',
        ),
      ),
    );
    return (select(
      categorias,
    )..where((tbl) => tbl.id.equals(resolvedId))).getSingle();
  }

  Future<void> deactivateCategoria(String categoriaId) async {
    final now = DateTime.now();
    await (update(
      categorias,
    )..where((tbl) => tbl.id.equals(categoriaId))).write(
      CategoriasCompanion(
        estado: const Value(false),
        fechaEliminacion: Value(now),
        updatedAt: Value(now),
        syncStatus: const Value('pending_update'),
      ),
    );
  }

  // Fallback para el asistente: primera bodega disponible cuando el usuario
  // no tiene bodegaDefaultId configurado en su perfil.
  Future<String?> getPrimeraBodegaId() async {
    final row = await (select(bodegas)
          ..where((b) => b.syncStatus.isNotIn(['deleted', 'pending_delete']))
          ..orderBy([(b) => OrderingTerm.asc(b.nombre)])
          ..limit(1))
        .getSingleOrNull();
    return row?.id;
  }
}

class InventoryLowStockData {
  final String nombre;
  final String sku;
  final int cantidadActual;
  final int stockMinimo;

  const InventoryLowStockData({
    required this.nombre,
    required this.sku,
    required this.cantidadActual,
    required this.stockMinimo,
  });
}

class InventoryReportData {
  final double valorTotal;
  final int totalItems;
  final int criticos;
  final int medios;
  final int saludables;
  final List<InventoryLowStockData> lowStock;

  const InventoryReportData({
    required this.valorTotal,
    required this.totalItems,
    required this.criticos,
    required this.medios,
    required this.saludables,
    required this.lowStock,
  });
}

