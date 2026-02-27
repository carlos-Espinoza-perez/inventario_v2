import 'package:inventario_v2/features/inventory/data/collections/inventario_collection.dart';
import 'package:inventario_v2/features/inventory/data/domain/models/product_with_stock.dart';
import 'package:isar/isar.dart';
// Asegúrate de importar tu modelo generado
import 'package:inventario_v2/features/inventory/data/collections/producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/codigo_producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/inventario_codigo_producto_collection.dart';

class ProductoRepository {
  final Isar _isar;

  ProductoRepository(this._isar);

  Stream<List<ProductoCollection>> watchProductosPorEmpresa() {
    return _isar.productoCollections
        .filter()
        .estadoEqualTo(true) // Solo traemos los activos
        .sortByNombre() // Opcional: ordenar por nombre
        .watch(fireImmediately: true);
  }

  Future<ProductoCollection?> getProducto(int id) async {
    return await _isar.productoCollections.get(id);
  }

  Future<int> saveProducto(ProductoCollection producto) async {
    return await _isar.writeTxn(() async {
      return await _isar.productoCollections.put(producto);
    });
  }

  Future<List<int>> saveProductosMasivos(
    List<ProductoCollection> productos,
  ) async {
    return await _isar.writeTxn(() async {
      return await _isar.productoCollections.putAll(productos);
    });
  }

  Future<void> deleteProductoLogico(int id) async {
    await _isar.writeTxn(() async {
      final producto = await _isar.productoCollections.get(id);
      if (producto != null) {
        producto.estado = false;
        producto.fechaEliminacion = DateTime.now();
        producto.pendienteSincronizacion =
            true; // Para que suba el cambio a la nube
        await _isar.productoCollections.put(producto);
      }
    });
  }

  Future<void> deleteProductoFisico(int id) async {
    await _isar.writeTxn(() async {
      await _isar.productoCollections.delete(id);
    });
  }

  Future<List<ProductWithStock>> getProductsWithStock({
    required String empresaId,
    required String bodegaId,
  }) async {
    // 1. Obtener todos los productos de la empresa
    final productos = await _isar.productoCollections
        .filter()
        .empresaIdEqualTo(empresaId)
        .estadoEqualTo(true) // Solo activos
        .findAll();

    final inventarios = await _isar.inventarioCollections
        .filter()
        .bodegaIdEqualTo(bodegaId)
        .findAll();

    final Map<String, InventarioCollection> invMap = {
      for (var inv in inventarios) inv.productoId: inv,
    };

    List<ProductWithStock> resultado = [];

    for (var prod in productos) {
      final inv = invMap[prod.serverId];
      final stock = inv?.cantidadActual ?? 0.0;
      final avgCost = inv?.costoPromedio ?? 0.0;

      resultado.add(
        ProductWithStock(
          producto: prod,
          cantidad: stock,
          costoPromedio: avgCost,
        ),
      );
    }

    return resultado;
  }

  Future<ProductoCollection> getProductoPorServerId(String serverId) async {
    var producto = await _isar.productoCollections
        .filter()
        .serverIdEqualTo(serverId)
        .findFirst();

    if (producto == null) {
      throw Exception('Producto no encontrado');
    }

    return producto;
  }

  Future<List<Map<String, dynamic>>> getStockPorVariante({
    required String bodegaId,
    required String productoId,
  }) async {
    // 1. Obtener Inventario Macro
    final inventario = await _isar.inventarioCollections
        .filter()
        .bodegaIdEqualTo(bodegaId)
        .productoIdEqualTo(productoId)
        .findFirst();

    if (inventario == null) return [];

    // 2. Obtener stocks por variante (Micro)
    final microInventarios = await _isar.inventarioCodigoProductoCollections
        .filter()
        .inventarioIdEqualTo(inventario.serverId)
        .findAll();

    List<Map<String, dynamic>> resultados = [];

    for (var micro in microInventarios) {
      // Opcional: filtrar si cantidad <= 0, pero tal vez quiera ver que no hay stock
      if (micro.cantidad <= 0) continue;

      final variante = await _isar.codigoProductoCollections
          .filter()
          .serverIdEqualTo(micro.codigoProductoId)
          .findFirst();

      if (variante != null) {
        resultados.add({
          'talla': variante.talla,
          'sku': variante.codigoSku,
          'cantidad': micro.cantidad,
          'costoPromedio': inventario.costoPromedio,
          'precioEspecifico': variante.precioEspecifico,
        });
      }
    }
    return resultados;
  }
}
