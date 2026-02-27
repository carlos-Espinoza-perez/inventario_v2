import 'package:inventario_v2/features/inventory/data/collections/inventario_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/codigo_producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/inventario_codigo_producto_collection.dart';
import 'package:isar/isar.dart';

class InventarioRepository {
  final Isar _isar;

  InventarioRepository(this._isar);

  Future<List<InventarioCollection>> getInventariosByProductId(
    String productId,
  ) async {
    final inventarios = await _isar.inventarioCollections
        .filter()
        .productoIdEqualTo(productId)
        .findAll();

    return inventarios;
  }

  Future<InventarioCollection?> getStockByProductAndBodega(
    String productId,
    String bodegaId,
  ) async {
    return await _isar.inventarioCollections
        .filter()
        .productoIdEqualTo(productId)
        .and()
        .bodegaIdEqualTo(bodegaId)
        .findFirst();
  }

  Future<List<Map<String, dynamic>>> getVariantsWithStock(
    String productId,
    String bodegaId,
  ) async {
    final inventario = await _isar.inventarioCollections
        .filter()
        .productoIdEqualTo(productId)
        .and()
        .bodegaIdEqualTo(bodegaId)
        .findFirst();

    if (inventario == null) return [];

    final relaciones = await _isar.inventarioCodigoProductoCollections
        .filter()
        .inventarioIdEqualTo(inventario.serverId)
        .and()
        .cantidadGreaterThan(0)
        .and()
        .estadoEqualTo(true)
        .findAll();

    final List<Map<String, dynamic>> results = [];
    for (final rel in relaciones) {
      final codigo = await _isar.codigoProductoCollections
          .filter()
          .serverIdEqualTo(rel.codigoProductoId)
          .and()
          .estadoEqualTo(true)
          .findFirst();

      if (codigo != null) {
        results.add({
          'talla': codigo.talla,
          'cantidad': rel.cantidad,
          'precio': codigo.precioEspecifico,
          'sku': codigo.codigoSku,
        });
      }
    }
    return results;
  }
}
