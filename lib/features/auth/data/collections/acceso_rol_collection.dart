import 'package:isar/isar.dart';
part 'acceso_rol_collection.g.dart';

@collection
class AccesoRolCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  @Index()
  late String rolId;
  late String codigoAcceso; // string

  bool estado = true;
  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;
}
