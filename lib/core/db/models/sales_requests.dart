import '../app_database.dart';

class VentaDetalleInput {
  final String id;
  final String productoId;
  final String? productoVarianteId;
  final double cantidad;
  final double precioUnitario;
  final double descuento;
  final double subTotal;
  final double costoHistoricoCompra;

  const VentaDetalleInput({
    required this.id,
    required this.productoId,
    this.productoVarianteId,
    required this.cantidad,
    required this.precioUnitario,
    required this.descuento,
    required this.subTotal,
    required this.costoHistoricoCompra,
  });
}

class PagoVentaInput {
  final String id;
  final double montoPagado;
  final String metodoPago;
  final String? referencia;
  final DateTime fechaRegistro;
  final String? usuarioRegistroId;

  const PagoVentaInput({
    required this.id,
    required this.montoPagado,
    required this.metodoPago,
    this.referencia,
    required this.fechaRegistro,
    this.usuarioRegistroId,
  });
}

class RegistrarVentaCompletaRequest {
  final VentasCompanion venta;
  final List<VentaDetalleInput> detalles;
  final PagoVentaInput? pago;
  final ClientesCompanion? cliente;
  final String? bodegaId;

  const RegistrarVentaCompletaRequest({
    required this.venta,
    required this.detalles,
    this.pago,
    this.cliente,
    this.bodegaId,
  });
}

class VentaCompletaResult {
  final Venta venta;
  final List<DetalleVenta> detalles;
  final PagosVenta? pago;

  const VentaCompletaResult({
    required this.venta,
    required this.detalles,
    required this.pago,
  });
}
