import 'package:inventario_v2/features/inventory/data/collections/producto_collection.dart';

class ProductWithStock {
  final ProductoCollection producto;
  final double cantidad;

  ProductWithStock({required this.producto, required this.cantidad});
}
