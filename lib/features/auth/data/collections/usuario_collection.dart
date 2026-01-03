import 'package:isar/isar.dart';
part 'usuario_collection.g.dart';

@collection
class UsuarioCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId; // UUID de Supabase Auth

  @Index()
  late String empresaId;
  late String rolId;

  late String nombreCompleto;
  String? correo;
  String? passwordHash;
  String? pinOffline; // El PIN de 4 dígitos

  bool estado = true;
  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;

  UsuarioCollection();

  factory UsuarioCollection.fromJson(Map<String, dynamic> json) {
    return UsuarioCollection()
      ..serverId = json['id']
      ..empresaId = json['empresa_id']
      ..rolId = json['rol_id']
      ..nombreCompleto = json['nombre_completo']
      ..correo = json['correo']
      ..passwordHash = json['password_hash']
      ..pinOffline = json['pin_offline']
      ..estado = json['estado'] ?? true
      ..ultimaActualizacion = DateTime.parse(json['ultima_actualizacion'])
      ..fechaEliminacion = json['fecha_eliminacion'] != null
          ? DateTime.parse(json['fecha_eliminacion'])
          : null;
  }

  @override
  String toString() {
    return '👤 User: $nombreCompleto | Email: $correo | ID: $serverId';
  }
}
