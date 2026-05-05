import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/models/product_catalog_models.dart';
import 'package:inventario_v2/core/db/models/producto_stock_drift.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';

final listaProductosProvider = StreamProvider<List<ProductCatalogItemDrift>>((
  ref,
) {
  final db = ref.watch(driftDatabaseProvider);
  return db.inventoryDao.watchCatalogItems();
});

final productsWithStockProvider =
    FutureProvider.family<List<ProductCatalogItemDrift>, String>((
      ref,
      bodegaId,
    ) async {
      final db = ref.watch(driftDatabaseProvider);
      return db.inventoryDao.getCatalogItems(bodegaId: bodegaId);
    });

final stockDriftByBodegaProvider =
    FutureProvider.family<List<ProductoStockDrift>, String>((ref, bodegaId) {
      final db = ref.watch(driftDatabaseProvider);
      return db.inventoryDao.getStockRealPorBodega(bodegaId);
    });
