import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/providers/database_provider.dart';
import 'package:inventario_v2/features/inventory/data/repositories/inventario_repository.dart';

// Proveedor del repositorio (Async porque necesita la DB)
final inventarioRepositoryProvider = FutureProvider<InventarioRepository>((
  ref,
) async {
  final isar = await ref.watch(isarDbProvider.future);
  return InventarioRepository(isar);
});

// Proveedor de la lista de inventario por bodega
// Proveedor de la lista de inventario por bodega (REACTIVO)
final warehouseInventoryProvider = StreamProvider.family
    .autoDispose<List<InventarioDTO>, String>((ref, bodegaId) async* {
      // Obtenemos el repositorio
      final repository = await ref.watch(inventarioRepositoryProvider.future);

      // Emitimos el stream del repositorio
      yield* repository.obtenerInventarioPorBodega(bodegaId);
    });
