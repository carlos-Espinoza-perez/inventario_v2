import 'package:isar/isar.dart';

part 'acceso_rol_collection.g.dart';

@collection
class AccesoRolCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId; // ID GUID de Supabase

  @Index()
  late String rolId;

  late String codigoAcceso;

  // --- Auditoría (Requeridos por tu esquema de BD) ---
  late String usuarioRegistroId;
  late DateTime fechaRegistro;

  bool estado = true;
  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;

  // =========================================================
  // CAMPOS PARA SINCRONIZACIÓN (OFFLINE FIRST)
  // =========================================================

  @Index()
  bool pendienteSincronizacion = true;

  /// Constructor vacío requerido por Isar
  AccesoRolCollection();

  /// Conversión de Supabase (JSON) -> Isar (Objeto Local)
  factory AccesoRolCollection.fromJson(Map<String, dynamic> json) {
    return AccesoRolCollection()
      ..serverId = json['id'] as String
      ..rolId = json['rol_id'] as String
      ..codigoAcceso = json['codigo_acceso'] as String
      ..usuarioRegistroId = json['usuario_registro_id'] as String
      ..fechaRegistro = DateTime.parse(json['fecha_registro'] as String)
      ..estado =
          json['estado'] as bool? ??
          true // Protección contra nulos
      ..ultimaActualizacion = DateTime.parse(
        json['ultima_actualizacion'] as String,
      )
      ..fechaEliminacion = json['fecha_eliminacion'] != null
          ? DateTime.parse(json['fecha_eliminacion'] as String)
          : null
      ..pendienteSincronizacion = false; // Al venir del server, ya está sync
  }

  /// Conversión de Isar (Objeto Local) -> Supabase (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': serverId,
      'rol_id': rolId,
      'codigo_acceso': codigoAcceso,
      'usuario_registro_id': usuarioRegistroId,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'estado': estado,
      'ultima_actualizacion': ultimaActualizacion.toIso8601String(),
      'fecha_eliminacion': fechaEliminacion?.toIso8601String(),
    };
  }
}
