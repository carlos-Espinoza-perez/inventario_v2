// Una talla individual dentro de la matriz (Fila)
class VariantDraft {
  String size;
  int qty;
  String barcode;
  double? specialPrice; // Si es null, usa el precio general del lote

  VariantDraft({
    required this.size,
    this.qty = 0,
    this.barcode = '',
    this.specialPrice,
  });

  // Para guardar en memoria local (JSON)
  Map<String, dynamic> toMap() => {
    'size': size,
    'qty': qty,
    'barcode': barcode,
    'specialPrice': specialPrice,
  };

  factory VariantDraft.fromMap(Map<String, dynamic> map) => VariantDraft(
    size: map['size'],
    qty: map['qty'],
    barcode: map['barcode'],
    specialPrice: map['specialPrice'] != null
        ? (map['specialPrice'] as num).toDouble()
        : null,
  );
}

// El Producto completo que ves en la lista "Resumen"
class MovementItem {
  final String productName;
  final String category;
  final String brand;
  final String color;
  final double costPrice;
  final double salePrice;
  final String? imagePath;

  // Lista de variantes configuradas (Tallas con cantidad > 0)
  final List<VariantDraft> variants;

  MovementItem({
    required this.productName,
    required this.category,
    required this.brand,
    required this.color,
    required this.costPrice,
    required this.salePrice,
    required this.variants,
    this.imagePath,
  });

  // Cálculos automáticos para el resumen
  int get totalQuantity => variants.fold(0, (sum, v) => sum + v.qty);
  double get totalInvestment => totalQuantity * costPrice;
  double get expectedProfit => variants.fold(0, (sum, v) {
    double price = v.specialPrice ?? salePrice;
    return sum + ((price - costPrice) * v.qty);
  });
}
