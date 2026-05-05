import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';

extension BodegaDriftCompat on Bodega {
  String get serverId => id;
}

final bodegaSearchQueryProvider = StateProvider<String>((ref) => '');

final bodegaListProvider = StreamProvider.autoDispose<List<Bodega>>((
  ref,
) async* {
  final db = ref.watch(driftDatabaseProvider);
  final query = ref.watch(bodegaSearchQueryProvider);
  yield* db.authDao.watchBodegasVisibles(query: query);
});

final selectedBodegaProvider = StateProvider<Bodega?>((ref) => null);

final currentBodegaProvider = FutureProvider<Bodega?>((ref) async {
  final selected = ref.watch(selectedBodegaProvider);
  if (selected != null) return selected;

  final db = ref.watch(driftDatabaseProvider);
  final sesion = await db.authDao.getSesionActiva();
  final bodegaId =
      sesion?.cajaActiva?.bodegaId ?? sesion?.usuario.bodegaDefaultId;
  if (bodegaId == null || bodegaId.isEmpty) return null;
  return db.authDao.getBodegaById(bodegaId);
});

final bodegaByIdProvider = FutureProvider.family<Bodega?, String>((
  ref,
  bodegaId,
) async {
  final db = ref.watch(driftDatabaseProvider);
  return db.authDao.getBodegaById(bodegaId);
});

final validBodegasIdsProvider = FutureProvider.autoDispose<Set<String>>((
  ref,
) async {
  final db = ref.watch(driftDatabaseProvider);
  return db.authDao.getValidBodegasIds();
});
