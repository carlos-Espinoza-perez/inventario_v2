import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/db/models/producto_stock_drift.dart';

class InventarioDTO {
  final String productoId;
  final String varianteId;
  final String nombre;
  final String sku;
  final String talla;
  final String? color;
  final String categoria;
  final double stock;
  final double precio;
  final double costo;
  final String? imagen;

  InventarioDTO({
    required this.productoId,
    required this.varianteId,
    required this.nombre,
    required this.sku,
    required this.talla,
    this.color,
    required this.categoria,
    required this.stock,
    required this.precio,
    required this.costo,
    this.imagen,
  });
}

class InventarioRepository {
  final AppDatabase _db;

  InventarioRepository(this._db);

  Stream<List<InventarioDTO>> obtenerInventarioPorBodega(String bodegaId) {
    return _db.inventoryDao
        .watchStockPorBodega(bodegaId)
        .map((items) => items.map(_toDto).toList());
  }

  Future<List<Map<String, dynamic>>> obtenerVariantesProducto(
    String productId, {
    String? bodegaId,
  }) async {
    final items = bodegaId == null
        ? (await _db.inventoryDao.getVariantesByProductoId(productId))
              .map(
                (variante) => {
                  'talla': variante.talla ?? 'General',
                  'color': variante.color,
                  'sku': variante.sku,
                  'stock': 0.0,
                  'precio': variante.precioEspecifico ?? 0.0,
                  'varianteId': variante.id,
                },
              )
              .toList()
        : (await _db.inventoryDao.getStockRealPorBodega(bodegaId))
              .where((item) => item.producto.id == productId)
              .map(
                (item) => {
                  'talla': item.variante.talla ?? 'General',
                  'color': item.variante.color,
                  'sku': item.variante.sku,
                  'stock': item.inventario.cantidadActual,
                  'precio': _resolvePrecio(item),
                  'varianteId': item.variante.id,
                },
              )
              .toList();

    return items.map((item) => item).toList();
  }

  static double _resolvePrecio(ProductoStockDrift item) {
    final directo =
        item.variante.precioEspecifico ?? item.inventario.precioVenta;
    if (directo > 0) return directo;
    return item.producto.precioBase ?? item.producto.ultimoPrecioVenta;
  }

  InventarioDTO _toDto(ProductoStockDrift item) {
    return InventarioDTO(
      productoId: item.producto.id,
      varianteId: item.variante.id,
      nombre: item.producto.nombre,
      sku: item.variante.sku,
      talla: item.variante.talla ?? 'General',
      color: item.variante.color,
      categoria: item.producto.categoriaId ?? 'Sin Categoria',
      stock: item.inventario.cantidadActual,
      precio: _resolvePrecio(item),
      costo: item.variante.costoEspecifico ?? item.inventario.costoPromedio,
      imagen: item.producto.imagenUrl,
    );
  }
}
