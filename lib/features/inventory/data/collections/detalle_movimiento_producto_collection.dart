import 'package:isar/isar.dart';
part 'detalle_movimiento_producto_collection.g.dart';

@collection
class DetalleMovimientoProductoCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  @Index()
  late String movimientoProductoId;

  @Index()
  late String productoId;

  double cantidad = 0;

  double costoProveedor = 0;
  String? cargosAdicionalesJson; // JSON snapshot
  double costoUnitarioFinal = 0;

  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;
}
