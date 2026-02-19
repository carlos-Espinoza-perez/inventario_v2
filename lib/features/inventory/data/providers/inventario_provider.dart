import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/providers/database_provider.dart';
import 'package:inventario_v2/features/inventory/data/repository/inventario_repository.dart';

final inventarioRepositoryProvider = FutureProvider<InventarioRepository>((
  ref,
) async {
  final isar = await ref.watch(isarDbProvider.future);
  return InventarioRepository(isar);
});
