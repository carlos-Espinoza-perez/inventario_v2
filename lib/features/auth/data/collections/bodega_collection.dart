import 'package:isar/isar.dart';
part 'bodega_collection.g.dart';

@collection
class BodegaCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  @Index()
  late String empresaId;

  late String nombre;
  String? direccion;
  bool esPuntoVenta = false;

  bool estado = true;
  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;
}
