import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/providers/database_provider.dart';
import 'package:inventario_v2/features/inventory/data/collections/codigo_producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/repository/codigo_producto_repository.dart';

// Provider del repositorio
final codigoProductoRepositoryProvider =
    FutureProvider<CodigoProductoRepository>((ref) async {
      final isar = await ref.watch(isarDbProvider.future);
      return CodigoProductoRepository(isar);
    });

// Stream de todos los códigos de un producto
final codigosByProductoProvider =
    StreamProvider.family<List<CodigoProductoCollection>, String>((
      ref,
      productoId,
    ) async* {
      final repo = await ref.watch(codigoProductoRepositoryProvider.future);
      yield* repo.watchByProductoId(productoId);
    });
