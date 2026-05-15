import '../app_database.dart';

class ProductCatalogItemDrift {
  final Producto producto;
  final ProductoVariante? variante;
  final double stock;
  final double costoPromedio;

  const ProductCatalogItemDrift({
    required this.producto,
    required this.variante,
    required this.stock,
    required this.costoPromedio,
  });

  String get id => producto.id;
  String get nombre => producto.nombre;
  String? get categoriaId => producto.categoriaId;
  String? get imagenUrl => producto.imagenUrl;
  String? get imagenLocal => producto.imagenLocal;
  String get sku =>
      variante?.sku ??
      producto.codigoPersonalizado ??
      producto.id.substring(0, 8).toUpperCase();
  String? get talla => variante?.talla;
  String? get color => variante?.color;
  double get precioVenta {
    if ((variante?.precioEspecifico ?? 0) > 0) return variante!.precioEspecifico!;
    if ((producto.precioBase ?? 0) > 0) return producto.precioBase!;
    return producto.ultimoPrecioVenta;
  }
}

class BarcodeLookupResultDrift {
  final Producto producto;
  final ProductoVariante variante;

  const BarcodeLookupResultDrift({
    required this.producto,
    required this.variante,
  });

  String get nombre => producto.nombre;
  String get sku => variante.sku;
  double get precio {
    if ((variante.precioEspecifico ?? 0) > 0) return variante.precioEspecifico!;
    if ((producto.precioBase ?? 0) > 0) return producto.precioBase!;
    return producto.ultimoPrecioVenta;
  }
  double get costo => variante.costoEspecifico ?? producto.ultimoCosto;
  String get imagen => producto.imagenUrl ?? producto.imagenLocal ?? '';
}
