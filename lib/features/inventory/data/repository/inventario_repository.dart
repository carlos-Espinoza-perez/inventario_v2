import 'package:drift/drift.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/db/models/inventory_requests.dart';
import 'package:inventario_v2/core/db/models/producto_stock_drift.dart';

class InventarioRepository {
  final AppDatabase _db;

  InventarioRepository(this._db);

  Future<List<Inventario>> getInventariosByProductId(String productId) async {
    final variants = await _db.inventoryDao.getVariantesByProductoId(productId);
    if (variants.isEmpty) return [];
    return (_db.select(_db.inventarios)..where(
          (tbl) => tbl.productoVarianteId.isIn(
            variants.map((variant) => variant.id).toList(),
          ),
        ))
        .get();
  }

  Future<Inventario?> getStockByProductAndBodega(
    String productId,
    String bodegaId,
    String? productVariantId,
  ) {
    return (_db.select(_db.inventarios)
          ..where(
            (tbl) => productVariantId != null
                ? tbl.productoVarianteId.equals(productVariantId)
                : tbl.productoVarianteId.isInQuery(
                    _db.selectOnly(_db.productoVariantes)
                      ..addColumns([_db.productoVariantes.id])
                      ..where(
                        _db.productoVariantes.productoId.equals(productId),
                      ),
                  ),
          )
          ..where((tbl) => tbl.bodegaId.equals(bodegaId))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<InventoryProductLookup?> buscarProductoPorCodigoONombre(
    String query,
  ) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return null;

    final variantes =
        await (_db.select(_db.productoVariantes)
              ..where((tbl) => tbl.sku.equals(normalized))
              ..limit(1))
            .getSingleOrNull();

    if (variantes != null) {
      final producto = await _db.inventoryDao.getProductoById(
        variantes.productoId,
      );
      if (producto != null) {
        return InventoryProductLookup(
          productId: producto.id,
          productVariantId: variantes.id,
          nombre: producto.nombre,
          categoriaId: producto.categoriaId,
          codigo: producto.codigoPersonalizado,
          sku: variantes.sku,
          talla: variantes.talla,
          color: variantes.color,
          ultimoCosto: producto.ultimoCosto,
          precioBase: (variantes.precioEspecifico ?? 0) > 0
              ? variantes.precioEspecifico!
              : (producto.precioBase ?? 0) > 0
              ? producto.precioBase!
              : producto.ultimoPrecioVenta,
        );
      }
    }

    final producto = await _db.inventoryDao.searchProductoByCodeOrName(
      normalized,
    );
    if (producto == null) return null;

    final variante =
        await (_db.select(_db.productoVariantes)
              ..where((tbl) => tbl.productoId.equals(producto.id))
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.sku)])
              ..limit(1))
            .getSingleOrNull();

    return InventoryProductLookup(
      productId: producto.id,
      productVariantId: variante?.id,
      nombre: producto.nombre,
      categoriaId: producto.categoriaId,
      codigo: producto.codigoPersonalizado,
      sku: variante?.sku,
      talla: variante?.talla,
      color: variante?.color,
      ultimoCosto: variante?.costoEspecifico ?? producto.ultimoCosto,
      precioBase: (variante?.precioEspecifico ?? 0) > 0
          ? variante!.precioEspecifico!
          : (producto.precioBase ?? 0) > 0
          ? producto.precioBase!
          : producto.ultimoPrecioVenta,
    );
  }

  Future<void> asignarCodigoAProducto({
    required String productId,
    required String barcode,
  }) {
    return _db.inventoryDao.assignBarcodeToProduct(
      productoId: productId,
      barcode: barcode,
    );
  }

  Future<ProductoVariante> resolveVariantForEntry({
    required String productId,
    required String? sku,
    required String? talla,
    required String? color,
    required double? precioVenta,
    required double? costo,
  }) {
    return _db.inventoryDao.resolveVariantForEntry(
      productoId: productId,
      sku: sku,
      talla: talla,
      color: color,
      precioVenta: precioVenta,
      costo: costo,
    );
  }

  Future<TransferItemDraft?> crearBorradorTrasladoDesdeCodigo({
    required String query,
    required String bodegaOrigenId,
  }) async {
    final producto = await buscarProductoPorCodigoONombre(query);
    if (producto == null) return null;

    final inventario = await getStockByProductAndBodega(
      producto.productId,
      bodegaOrigenId,
      producto.productVariantId,
    );

    if (inventario == null || inventario.cantidadActual <= 0) {
      return null;
    }

    return TransferItemDraft(
      productId: producto.productId,
      productVariantId: producto.productVariantId,
      nombre: producto.nombre,
      sku: producto.sku ?? producto.codigo ?? producto.productId,
      size: producto.talla ?? 'General',
      color: producto.color,
      availableStock: inventario.cantidadActual,
      cost: inventario.costoPromedio,
      price: inventario.precioVenta,
    );
  }

  Future<List<Map<String, dynamic>>> getVariantsWithStock(
    String productId,
    String bodegaId,
  ) async {
    if (bodegaId.isEmpty) {
      final variantes = await _db.inventoryDao.getVariantesByProductoId(
        productId,
      );
      final producto = await _db.inventoryDao.getProductoById(productId);
      return variantes
          .map(
            (item) => {
              'talla': item.talla ?? 'General',
              'color': item.color,
              'cantidad': 0.0,
              'stock': 0.0,
              'precio': _resolvePrice(
                item.precioEspecifico,
                null,
                producto?.precioBase,
                producto?.ultimoPrecioVenta,
              ),
              'costo': (item.costoEspecifico ?? 0) > 0
                  ? item.costoEspecifico!
                  : producto?.ultimoCosto ?? 0.0,
              'sku': item.sku,
              'varianteId': item.id,
            },
          )
          .toList();
    }

    final stock = await _db.inventoryDao.getStockRealPorBodega(bodegaId);
    return stock
        .where((item) => item.producto.id == productId)
        .map(
          (item) => {
            'talla': item.variante.talla ?? 'General',
            'color': item.variante.color,
            'cantidad': item.inventario.cantidadActual,
            'stock': item.inventario.cantidadActual,
            'precio': _resolvePrice(
              item.variante.precioEspecifico,
              item.inventario.precioVenta,
              item.producto.precioBase,
              item.producto.ultimoPrecioVenta,
            ),
            'costo': (item.variante.costoEspecifico ?? 0) > 0
                ? item.variante.costoEspecifico!
                : item.inventario.costoPromedio > 0
                ? item.inventario.costoPromedio
                : item.producto.ultimoCosto,
            'sku': item.variante.sku,
            'varianteId': item.variante.id,
          },
        )
        .toList();
  }

  double _resolvePrice(
    double? precioEspecifico,
    double? precioVenta,
    double? precioBase,
    double? ultimoPrecioVenta,
  ) {
    if ((precioEspecifico ?? 0) > 0) return precioEspecifico!;
    if ((precioVenta ?? 0) > 0) return precioVenta!;
    if ((precioBase ?? 0) > 0) return precioBase!;
    return ultimoPrecioVenta ?? 0.0;
  }

  Future<void> registrarEntrada(InventoryEntryRequest request) {
    return _db.inventoryDao.registrarMovimientoLogistico(request);
  }

  Future<void> registrarTraslado(TransferRequest request) {
    return _db.inventoryDao.registrarMovimientoLogistico(request);
  }

  Future<List<ProductoStockDrift>> getStockRealPorBodega(String bodegaId) {
    return _db.inventoryDao.getStockRealPorBodega(bodegaId);
  }
}
