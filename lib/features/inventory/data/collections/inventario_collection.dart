import 'package:isar/isar.dart';
part 'inventario_collection.g.dart';

@collection
class InventarioCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  @Index()
  late String bodegaId;

  @Index()
  late String productoId;

  double cantidadActual = 0;
  double cantidadReservada = 0;
  String? ubicacionPasillo;

  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;
}
