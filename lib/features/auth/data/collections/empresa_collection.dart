import 'package:isar/isar.dart';

part 'empresa_collection.g.dart';

@collection
class EmpresaCollection {
  // ID interno de Isar
  Id id = Isar.autoIncrement;

  // Clave primaria real (Supabase UUID)
  @Index(unique: true, replace: true)
  late String serverId;

  late String nombre;
  String? nombreComercial;
  String? ruc;

  // JSON guardado como String localmente
  String? configuracion;

  // --- Auditoría ---
  bool estado = true;
  DateTime? fechaRegistro;
  String? usuarioRegistroId;

  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;

  // =========================================================
  // CAMPOS PARA SINCRONIZACIÓN (OFFLINE FIRST)
  // =========================================================

  @Index()
  bool pendienteSincronizacion = true;

  // Constructor vacío
  EmpresaCollection();

  // Mapper: De Supabase (snake_case) a Isar
  factory EmpresaCollection.fromJson(Map<String, dynamic> json) {
    return EmpresaCollection()
      ..serverId = json['id']
      ..nombre = json['nombre']
      ..nombreComercial = json['nombre_comercial']
      ..ruc = json['ruc']
      ..configuracion = json['configuracion']?.toString()
      ..estado = json['estado'] ?? true
      ..fechaRegistro = json['fecha_registro'] != null
          ? DateTime.parse(json['fecha_registro'])
          : null
      ..usuarioRegistroId = json['usuario_registro_id']
      ..ultimaActualizacion = DateTime.parse(json['ultima_actualizacion'])
      ..fechaEliminacion = json['fecha_eliminacion'] != null
          ? DateTime.parse(json['fecha_eliminacion'])
          : null;
  }

  // Mapper: De Isar a Supabase (snake_case)
  Map<String, dynamic> toJson() {
    return {
      'id': serverId,
      'nombre': nombre,
      'nombre_comercial': nombreComercial,
      'ruc': ruc,
      'configuracion': configuracion,
      'estado': estado,
      'fecha_registro': fechaRegistro?.toIso8601String(),
      'usuario_registro_id': usuarioRegistroId,
      'ultima_actualizacion': ultimaActualizacion.toIso8601String(),
      'fecha_eliminacion': fechaEliminacion?.toIso8601String(),
    };
  }
}
