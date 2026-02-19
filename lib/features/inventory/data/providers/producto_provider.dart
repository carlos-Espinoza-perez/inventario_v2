import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/providers/database_provider.dart'; // Tu provider de Isar base
import 'package:inventario_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:inventario_v2/features/inventory/data/collections/producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/domain/models/product_with_stock.dart';
import 'package:inventario_v2/features/inventory/data/repository/producto_repository.dart';

// 1. Provider del Repositorio (FutureProvider porque depende de Isar async)
final productoRepositoryProvider = FutureProvider<ProductoRepository>((
  ref,
) async {
  final isar = await ref.watch(isarDbProvider.future);
  return ProductoRepository(isar);
});

final listaProductosProvider = StreamProvider<List<ProductoCollection>>((
  ref,
) async* {
  final repository = await ref.watch(productoRepositoryProvider.future);

  yield* repository.watchProductosPorEmpresa();
});

final productsWithStockProvider =
    FutureProvider.family<List<ProductWithStock>, String>((
      ref,
      bodegaId,
    ) async {
      final authController = ref.read(authControllerProvider.notifier);

      final usuario =
          authController.usuarioActual ?? await authController.getUser();
      final empresaId = usuario?.empresaId ?? '';
      if (empresaId.isEmpty) return [];

      final repo = await ref.watch(productoRepositoryProvider.future);

      // Llamamos a la nueva función
      return repo.getProductsWithStock(
        empresaId: empresaId,
        bodegaId: bodegaId,
      );
    });
