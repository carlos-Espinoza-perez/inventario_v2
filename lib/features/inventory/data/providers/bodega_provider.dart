import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/providers/database_provider.dart'; // Importa TU archivo donde está isarDbProvider
import 'package:inventario_v2/features/auth/data/collections/bodega_collection.dart';
import 'package:inventario_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:isar/isar.dart';
import 'package:inventario_v2/features/auth/data/collections/bodega_usuario_colletion.dart';
import '../../data/services/bodega_service.dart';

final bodegaServiceProvider = FutureProvider<BodegaService>((ref) async {
  final isar = await ref.watch(isarDbProvider.future);
  return BodegaService(isar);
});

final bodegaSearchQueryProvider = StateProvider<String>((ref) => '');

final bodegaListProvider = StreamProvider.autoDispose<List<BodegaCollection>>((
  ref,
) async* {
  final service = await ref.watch(bodegaServiceProvider.future);
  final query = ref.watch(bodegaSearchQueryProvider);
  final user = ref.watch(authControllerProvider.notifier).usuarioActual;

  if (user != null) {
    yield* service.watchBodegasByUser(user.serverId, query: query);
  } else {
    yield* service.watchBodegas(query: query);
  }
});

final selectedBodegaProvider = StateProvider<BodegaCollection?>((ref) => null);

// Provider para obtener una bodega por ID
final bodegaByIdProvider = FutureProvider.family<BodegaCollection?, String>((
  ref,
  bodegaId,
) async {
  final isar = await ref.watch(isarDbProvider.future);
  return await isar.bodegaCollections
      .filter()
      .serverIdEqualTo(bodegaId)
      .findFirst();
});

final validBodegasIdsProvider = FutureProvider.autoDispose<Set<String>>((
  ref,
) async {
  final isar = await ref.watch(isarDbProvider.future);
  final user = ref.read(authControllerProvider.notifier).usuarioActual;

  if (user != null) {
    final relaciones = await isar.bodegaUsuarioColletions
        .filter()
        .usuarioIdEqualTo(user.serverId)
        .and()
        .estadoEqualTo(true)
        .findAll();

    final ids = relaciones.map((r) => r.bodegaId).toList();
    if (ids.isEmpty) return {};

    final bodegas = await isar.bodegaCollections
        .filter()
        .anyOf(ids, (q, id) => q.serverIdEqualTo(id))
        .and()
        .estadoEqualTo(true)
        .findAll();

    return bodegas.map((b) => b.serverId).toSet();
  } else {
    final bodegas = await isar.bodegaCollections
        .filter()
        .estadoEqualTo(true)
        .findAll();
    return bodegas.map((b) => b.serverId).toSet();
  }
});
