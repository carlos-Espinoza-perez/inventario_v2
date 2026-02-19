import 'package:isar/isar.dart';

part 'bodega_collection.g.dart';

@collection
class BodegaCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId; // ID GUID de Supabase

  @Index()
  late String empresaId;

  late String nombre;
  String? direccion;
  bool esPuntoVenta = false;

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
  BodegaCollection();

  /// Conversión de Supabase (JSON) -> Isar (Objeto Local)
  factory BodegaCollection.fromJson(Map<String, dynamic> json) {
    return BodegaCollection()
      ..serverId = json['id'] as String
      ..empresaId = json['empresa_id'] as String
      ..nombre = json['nombre'] as String
      ..direccion = json['direccion'] as String?
      ..esPuntoVenta = json['es_punto_venta'] as bool? ?? false
      ..usuarioRegistroId = json['usuario_registro_id'] as String
      ..fechaRegistro = DateTime.parse(json['fecha_registro'] as String)
      ..estado = json['estado'] as bool? ?? true
      ..ultimaActualizacion = DateTime.parse(
        json['ultima_actualizacion'] as String,
      )
      ..fechaEliminacion = json['fecha_eliminacion'] != null
          ? DateTime.parse(json['fecha_eliminacion'] as String)
          : null
      ..pendienteSincronizacion =
          false; // Importante: Viene de la nube, ya está sync
  }

  /// Conversión de Isar (Objeto Local) -> Supabase (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': serverId,
      'empresa_id': empresaId,
      'nombre': nombre,
      'direccion': direccion,
      'es_punto_venta': esPuntoVenta,
      'usuario_registro_id': usuarioRegistroId,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'estado': estado,
      'ultima_actualizacion': ultimaActualizacion.toIso8601String(),
      'fecha_eliminacion': fechaEliminacion?.toIso8601String(),
    };
  }
}
