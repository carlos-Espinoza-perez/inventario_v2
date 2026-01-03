import 'package:isar/isar.dart';
part 'detalle_venta_collection.g.dart';

@collection
class DetalleVentaCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  @Index()
  late String ventaId;

  @Index()
  late String productoId;

  double cantidad = 0;
  double precioUnitario = 0;
  double descuento = 0;
  double subTotal = 0;

  double costoHistoricoCompra = 0; // Para reportes de ganancia

  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;
}
