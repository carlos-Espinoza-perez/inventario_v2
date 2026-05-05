import 'package:inventario_v2/core/db/app_database.dart';

class ProductoStockDrift {
  final Producto producto;
  final ProductoVariante variante;
  final Inventario inventario;

  const ProductoStockDrift({
    required this.producto,
    required this.variante,
    required this.inventario,
  });
}
