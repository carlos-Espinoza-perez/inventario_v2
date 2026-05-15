import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/features/inventory/data/repositories/inventario_repository.dart';

// Proveedor del repositorio para el módulo de inventario (presentation layer)
final inventarioRepositoryProvider = Provider<InventarioRepository>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  return InventarioRepository(db);
});

// Stream reactivo del inventario por bodega
final warehouseInventoryProvider = StreamProvider.family
    .autoDispose<List<InventarioDTO>, String>((ref, bodegaId) {
      final repository = ref.watch(inventarioRepositoryProvider);
      return repository.obtenerInventarioPorBodega(bodegaId);
    });
