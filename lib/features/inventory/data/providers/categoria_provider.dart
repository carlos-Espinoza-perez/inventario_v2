import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/providers/database_provider.dart';
import 'package:inventario_v2/features/inventory/data/collections/categoria_collection.dart';
import 'package:inventario_v2/features/inventory/data/repository/categoria_repository.dart';

final categoriaRepositoryProvider = FutureProvider<CategoriaRepository>((
  ref,
) async {
  final isar = await ref.watch(isarDbProvider.future);
  return CategoriaRepository(isar);
});

final listCategoriasPadreProvider = StreamProvider<List<CategoriaCollection>>((
  ref,
) async* {
  final repository = await ref.watch(categoriaRepositoryProvider.future);

  yield* repository.watchCategoriasPorEmpresa();
});

final listCategoriasAllProvider = StreamProvider<List<CategoriaCollection>>((
  ref,
) async* {
  final repository = await ref.watch(categoriaRepositoryProvider.future);

  yield* repository.watchCategoriasAllPorEmpresa();
});
