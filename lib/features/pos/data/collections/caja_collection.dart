import 'package:isar/isar.dart';
part 'caja_collection.g.dart';

@collection
class CajaCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  @Index()
  late String empresaId;

  @Index()
  late String bodegaId;

  late String nombre;

  late DateTime fechaRegistro;
  String? usuarioRegistroId;
  bool estado = true;
  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;
}
