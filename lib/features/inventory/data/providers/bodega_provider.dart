import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/providers/auto_sync_provider.dart';
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

final currentBodegaProvider = FutureProvider.autoDispose<Bodega?>((ref) async {
  ref.watch(autoSyncProvider.select((s) => s.value?.lastSync));
  final db = ref.watch(driftDatabaseProvider);
  final validBodegas = await db.authDao.getValidBodegasIds();

  final selected = ref.watch(selectedBodegaProvider);
  if (selected != null && validBodegas.contains(selected.id)) {
    return selected;
  }

  final sesion = await db.authDao.getSesionActiva();
  final bodegaId =
      sesion?.cajaActiva?.bodegaId ?? sesion?.usuario.bodegaDefaultId;

  if (bodegaId != null && bodegaId.isNotEmpty && validBodegas.contains(bodegaId)) {
    return db.authDao.getBodegaById(bodegaId);
  }

  if (validBodegas.isNotEmpty) {
    return db.authDao.getBodegaById(validBodegas.first);
  }

  return null;
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
  ref.watch(autoSyncProvider.select((s) => s.value?.lastSync));
  final db = ref.watch(driftDatabaseProvider);
  return db.authDao.getValidBodegasIds();
});
