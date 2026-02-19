import 'package:isar/isar.dart';

part 'caja_collection.g.dart';

@collection
class CajaCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId; // UUID

  @Index()
  late String empresaId;

  @Index()
  late String bodegaId;

  late String nombre;

  // --- Auditoría ---
  late DateTime fechaRegistro;
  String? usuarioRegistroId;
  bool estado = true;

  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;

  // =========================================================
  // CAMPOS PARA SINCRONIZACIÓN (OFFLINE FIRST)
  // =========================================================

  @Index()
  bool pendienteSincronizacion = true;

  CajaCollection();

  // Mapper: De Supabase (snake_case) a Isar
  factory CajaCollection.fromJson(Map<String, dynamic> json) {
    return CajaCollection()
      ..serverId = json['id']
      ..empresaId = json['empresa_id']
      ..bodegaId = json['bodega_id']
      ..nombre = json['nombre']
      // Auditoría
      ..fechaRegistro = DateTime.parse(json['fecha_registro'])
      ..usuarioRegistroId = json['usuario_registro_id']
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
      'bodega_id': bodegaId,
      'nombre': nombre,

      // Auditoría
      'fecha_registro': fechaRegistro.toIso8601String(),
      'usuario_registro_id': usuarioRegistroId,
      'estado': estado,

      'ultima_actualizacion': ultimaActualizacion.toIso8601String(),
      'fecha_eliminacion': fechaEliminacion?.toIso8601String(),
    };
  }
}
