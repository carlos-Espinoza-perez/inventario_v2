class InventoryProductLookup {
  final String productId;
  final String? productVariantId;
  final String nombre;
  final String? categoriaId;
  final String? codigo;
  final String? sku;
  final String? talla;
  final String? color;
  final double ultimoCosto;
  final double precioBase;

  const InventoryProductLookup({
    required this.productId,
    this.productVariantId,
    required this.nombre,
    required this.categoriaId,
    required this.codigo,
    this.sku,
    this.talla,
    this.color,
    required this.ultimoCosto,
    required this.precioBase,
  });
}

class TransferItemDraft {
  final String productId;
  final String? productVariantId;
  final String nombre;
  final String sku;
  final String size;
  final String? color;
  final double availableStock;
  final double cost;
  final double price;
  final double cantidad;

  const TransferItemDraft({
    required this.productId,
    this.productVariantId,
    required this.nombre,
    required this.sku,
    required this.size,
    this.color,
    required this.availableStock,
    required this.cost,
    required this.price,
    this.cantidad = 1.0,
  });
}

class InventoryEntryItem {
  final String productId;
  final String? productVariantId;
  final double cantidad;
  final double costoProveedor;
  final double costoUnitarioFinal;
  final double? precioVenta;
  final String? sku;
  final String? talla;
  final String? color;
  final String? variantesJson;

  const InventoryEntryItem({
    required this.productId,
    this.productVariantId,
    required this.cantidad,
    required this.costoProveedor,
    required this.costoUnitarioFinal,
    this.precioVenta,
    this.sku,
    this.talla,
    this.color,
    this.variantesJson,
  });
}

class TransferItemRequest {
  final String productId;
  final String? productVariantId;
  final double cantidad;
  final double costoProveedor;
  final double costoUnitarioFinal;
  final double? precioVenta;
  final String? sku;
  final String? size;
  final String? color;
  final double? availableStock;

  const TransferItemRequest({
    required this.productId,
    this.productVariantId,
    required this.cantidad,
    required this.costoProveedor,
    required this.costoUnitarioFinal,
    this.precioVenta,
    this.sku,
    this.size,
    this.color,
    this.availableStock,
  });
}

class MovimientoInventarioDetalleInput {
  final String id;
  final String productoId;
  final String? productoVarianteId;
  final double cantidad;
  final double costoProveedor;
  final double costoUnitarioFinal;
  final String? cargosAdicionalesJson;
  final String? variantesJson;

  const MovimientoInventarioDetalleInput({
    required this.id,
    required this.productoId,
    this.productoVarianteId,
    required this.cantidad,
    required this.costoProveedor,
    required this.costoUnitarioFinal,
    this.cargosAdicionalesJson,
    this.variantesJson,
  });
}

sealed class InventoryMovementRequest {
  final String? descripcion;

  const InventoryMovementRequest({this.descripcion});

  String get tipoMovimiento;
  String? get bodegaOrigenId;
  String? get bodegaDestinoId;
}

class InventoryEntryRequest extends InventoryMovementRequest {
  final String destinationWarehouseId;
  final List<InventoryEntryItem> items;

  const InventoryEntryRequest({
    required this.destinationWarehouseId,
    required this.items,
    super.descripcion,
  });

  @override
  String get tipoMovimiento => 'entrada';

  @override
  String? get bodegaDestinoId => destinationWarehouseId;

  @override
  String? get bodegaOrigenId => null;
}

class TransferRequest extends InventoryMovementRequest {
  final String originWarehouseId;
  final String destinationWarehouseId;
  final List<TransferItemRequest> items;

  const TransferRequest({
    required this.originWarehouseId,
    required this.destinationWarehouseId,
    required this.items,
    super.descripcion,
  });

  @override
  String get tipoMovimiento => 'traslado';

  @override
  String? get bodegaDestinoId => destinationWarehouseId;

  @override
  String? get bodegaOrigenId => originWarehouseId;
}
