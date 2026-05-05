import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/features/inventory/data/repository/inventario_repository.dart';

final inventarioRepositoryProvider = FutureProvider<InventarioRepository>((
  ref,
) async {
  final db = ref.watch(driftDatabaseProvider);
  return InventarioRepository(db);
});
