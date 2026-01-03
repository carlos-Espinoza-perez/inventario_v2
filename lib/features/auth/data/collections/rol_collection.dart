import 'package:isar/isar.dart';
part 'rol_collection.g.dart';

@collection
class RolCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  @Index()
  late String empresaId;

  late String nombre;
  bool userAdmin = false;

  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;

  RolCollection();

  factory RolCollection.fromJson(Map<String, dynamic> json) {
    return RolCollection()
      ..serverId = json['id']
      ..empresaId = json['empresa_id']
      ..nombre = json['nombre']
      ..userAdmin = json['user_admin'] ?? false
      ..ultimaActualizacion = DateTime.parse(json['ultima_actualizacion'])
      ..fechaEliminacion = json['fecha_eliminacion'] != null
          ? DateTime.parse(json['fecha_eliminacion'])
          : null;
  }

  @override
  String toString() {
    return '🛡️ Rol: $nombre | Admin: $userAdmin';
  }
}
