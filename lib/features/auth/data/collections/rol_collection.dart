import 'package:isar/isar.dart';

part 'rol_collection.g.dart';

@collection
class RolCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId; // ID GUID

  @Index()
  late String empresaId;

  late String nombre;
  bool userAdmin = false;

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

  RolCollection();

  // Mapper: De Supabase (snake_case) a Isar
  factory RolCollection.fromJson(Map<String, dynamic> json) {
    return RolCollection()
      ..serverId = json['id']
      ..empresaId = json['empresa_id']
      ..nombre = json['nombre']
      ..userAdmin = json['user_admin'] ?? false
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
      'nombre': nombre,
      'user_admin': userAdmin,
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
    return '🛡️ Rol: $nombre | Admin: $userAdmin';
  }
}
