import 'package:inventario_v2/core/db/models/product_catalog_models.dart';

class ProductWithStock {
  final ProductCatalogItemDrift item;
  final double cantidad;
  final double costoPromedio;

  const ProductWithStock({
    required this.item,
    required this.cantidad,
    this.costoPromedio = 0.0,
  });
}
