import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/models/product_catalog_models.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';

final barcodeLookupProvider =
    FutureProvider.family<List<BarcodeLookupResultDrift>, String>((ref, code) {
      final db = ref.watch(driftDatabaseProvider);
      return db.inventoryDao.findProductsByBarcode(code);
    });
