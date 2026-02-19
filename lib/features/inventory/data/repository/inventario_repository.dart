import 'package:inventario_v2/features/inventory/data/collections/inventario_collection.dart';
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
}
