import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';

final listCategoriasAllProvider = StreamProvider<List<Categoria>>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return db.inventoryDao.watchCategoriasPorEmpresa();
});

final listCategoriasPadreProvider = StreamProvider<List<Categoria>>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return db.inventoryDao.watchCategoriasPorEmpresa().map(
    (items) => items.where((item) => item.categoriaPadreId == null).toList(),
  );
});
