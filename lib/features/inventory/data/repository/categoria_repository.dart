import 'package:inventario_v2/features/inventory/data/collections/categoria_collection.dart';
import 'package:isar/isar.dart';

class CategoriaRepository {
  final Isar _isar;

  CategoriaRepository(this._isar);

  Stream<List<CategoriaCollection>> watchCategoriasPorEmpresa() {
    return _isar.categoriaCollections
        .filter()
        .estadoEqualTo(true)
        .and()
        .categoriaPadreIdIsNull()
        .sortByNombre()
        .watch(fireImmediately: true);
  }

  Stream<List<CategoriaCollection>> watchCategoriasHijasPorEmpresa() {
    return _isar.categoriaCollections
        .filter()
        .estadoEqualTo(true)
        .and()
        .categoriaPadreIdIsNotNull()
        .sortByNombre()
        .watch(fireImmediately: true);
  }

  Stream<List<CategoriaCollection>> watchCategoriasAllPorEmpresa() {
    return _isar.categoriaCollections
        .filter()
        .estadoEqualTo(true)
        .sortByNombre()
        .watch(fireImmediately: true);
  }

  Future<CategoriaCollection> getCategoriaPorServerId(String serverId) async {
    var categoria = await _isar.categoriaCollections
        .filter()
        .serverIdEqualTo(serverId)
        .findFirst();

    if (categoria == null) {
      throw Exception('Categoria no encontrada');
    }

    return categoria;
  }
}
