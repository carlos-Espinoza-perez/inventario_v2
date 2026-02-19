import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/providers/database_provider.dart'; // Importa TU archivo donde está isarDbProvider
import 'package:inventario_v2/features/auth/data/collections/bodega_collection.dart';
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

  yield* service.watchBodegas(query: query);
});
