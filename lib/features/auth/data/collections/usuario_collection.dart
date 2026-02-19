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

  // --- Auditoría ---
  String? usuarioRegistroId;
  DateTime? fechaRegistro;

  bool estado = true;
  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;

  // =========================================================
  // CAMPOS PARA SINCRONIZACIÓN (OFFLINE FIRST)
  // =========================================================

  @Index()
  bool pendienteSincronizacion = true;

  UsuarioCollection();

  // Mapper: De Supabase (snake_case) a Isar
  factory UsuarioCollection.fromJson(Map<String, dynamic> json) {
    return UsuarioCollection()
      ..serverId = json['id']
      ..empresaId = json['empresa_id']
      ..rolId = json['rol_id']
      ..nombreCompleto = json['nombre_completo']
      ..correo = json['correo']
      ..passwordHash = json['password_hash']
      ..pinOffline = json['pin_offline']
      // Auditoría
      ..usuarioRegistroId = json['usuario_registro_id']
      ..fechaRegistro = json['fecha_registro'] != null
          ? DateTime.parse(json['fecha_registro'])
          : null
      ..estado = json['estado'] ?? true
      ..ultimaActualizacion = DateTime.parse(json['ultima_actualizacion'])
      ..fechaEliminacion = json['fecha_eliminacion'] != null
          ? DateTime.parse(json['fecha_eliminacion'])
          : null;
  }

  // Mapper: De Isar a Supabase (snake_case)
  Map<String, dynamic> toJson() {
    return {
      'id': serverId,
      'empresa_id': empresaId,
      'rol_id': rolId,
      'nombre_completo': nombreCompleto,
      'correo': correo,
      'password_hash': passwordHash,
      'pin_offline': pinOffline,
      // Auditoría
      'usuario_registro_id': usuarioRegistroId,
      'fecha_registro': fechaRegistro?.toIso8601String(),
      'estado': estado,

      'ultima_actualizacion': ultimaActualizacion.toIso8601String(),
      'fecha_eliminacion': fechaEliminacion?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return '👤 User: $nombreCompleto | Email: $correo | ID: $serverId';
  }
}
