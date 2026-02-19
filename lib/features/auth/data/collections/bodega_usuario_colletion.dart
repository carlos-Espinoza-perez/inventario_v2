import 'package:isar/isar.dart';

part 'bodega_usuario_colletion.g.dart';

@collection
class BodegaUsuarioColletion {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uid; // Tu GUID original (Id en Supabase)

  @Index()
  late String bodegaId;

  @Index()
  late String usuarioId;

  // --- Auditoría ---
  late String usuarioRegistroId;

  @Index()
  bool estado = true;

  late DateTime fechaRegistro;

  DateTime? ultimaActualizacion;

  DateTime? fechaEliminacion;

  // =========================================================
  // CAMPOS PARA SINCRONIZACIÓN (OFFLINE FIRST)
  // =========================================================

  @Index()
  bool pendienteSincronizacion = true;

  /// Constructor vacío requerido por Isar
  BodegaUsuarioColletion();

  /// Conversión de Supabase (JSON) -> Isar (Objeto Local)
  factory BodegaUsuarioColletion.fromJson(Map<String, dynamic> json) {
    return BodegaUsuarioColletion()
      ..uid = json['id'] as String
      ..bodegaId = json['bodega_id'] as String
      ..usuarioId = json['usuario_id'] as String
      ..usuarioRegistroId = json['usuario_registro_id'] as String
      ..estado = json['estado'] as bool? ?? true
      ..fechaRegistro = DateTime.parse(json['fecha_registro'] as String)
      ..ultimaActualizacion = json['ultima_actualizacion'] != null
          ? DateTime.parse(json['ultima_actualizacion'] as String)
          : null
      ..fechaEliminacion = json['fecha_eliminacion'] != null
          ? DateTime.parse(json['fecha_eliminacion'] as String)
          : null
      ..pendienteSincronizacion = false; // Viene del server, ya está sync
  }

  /// Conversión de Isar (Objeto Local) -> Supabase (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': uid,
      'bodega_id': bodegaId,
      'usuario_id': usuarioId,
      'usuario_registro_id': usuarioRegistroId,
      'estado': estado,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'ultima_actualizacion': ultimaActualizacion?.toIso8601String(),
      'fecha_eliminacion': fechaEliminacion?.toIso8601String(),
    };
  }
}
