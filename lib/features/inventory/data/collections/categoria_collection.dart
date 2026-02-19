import 'dart:convert';

import 'package:isar/isar.dart';

part 'categoria_collection.g.dart';

@collection
class CategoriaCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId; // UUID

  @Index()
  late String empresaId;

  late String nombre;

  @Index()
  String? categoriaPadreId; // UUID de la categoría padre

  String? especificacionJson; // Guardamos el JSON como String

  // --- Auditoría ---
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

  CategoriaCollection();

  // Mapper: De Supabase (snake_case) a Isar
  factory CategoriaCollection.fromJson(Map<String, dynamic> json) {
    return CategoriaCollection()
      // 1. Campos obligatorios: Usamos '??' para evitar crashes si vienen null
      ..serverId = json['id'] as String? ?? ''
      ..empresaId = json['empresa_id'] as String? ?? ''
      ..nombre = json['nombre'] as String? ?? 'Sin Nombre'
      // 2. Categoria Padre (El sospechoso):
      // Al usar 'as String?', le decimos a Dart que está bien si es null
      ..categoriaPadreId = json['categoria_padre_id'] as String?
      // 3. Especificación:
      // Si viene como Map (JSONB de Supabase), lo convertimos a String correctamente.
      ..especificacionJson = json['especificacion'] != null
          ? (json['especificacion'] is String
                ? json['especificacion'] // Si ya es string, lo dejamos
                : jsonEncode(
                    json['especificacion'],
                  )) // Si es Map, lo volvemos String JSON
          : null
      // 4. Auditoría (Posibles nulos):
      // Si usuario_registro_id viene null de la DB, esto evitará el error
      ..usuarioRegistroId = json['usuario_registro_id'] as String? ?? ''
      ..fechaRegistro = json['fecha_registro'] != null
          ? DateTime.tryParse(json['fecha_registro'].toString()) ??
                DateTime.now()
          : DateTime.now()
      ..estado = json['estado'] as bool? ?? true
      ..ultimaActualizacion = json['ultima_actualizacion'] != null
          ? DateTime.tryParse(json['ultima_actualizacion'].toString()) ??
                DateTime.now()
          : DateTime.now()
      ..fechaEliminacion = json['fecha_eliminacion'] != null
          ? DateTime.tryParse(json['fecha_eliminacion'].toString())
          : null;
  }

  // Mapper: De Isar a Supabase (snake_case)
  Map<String, dynamic> toJson() {
    return {
      'id': serverId,
      'empresa_id': empresaId,
      'nombre': nombre,
      'categoria_padre_id': categoriaPadreId,
      'especificacion': especificacionJson, // Nombre de columna en DB
      // Auditoría
      'usuario_registro_id': usuarioRegistroId,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'estado': estado,

      'ultima_actualizacion': ultimaActualizacion.toIso8601String(),
      'fecha_eliminacion': fechaEliminacion?.toIso8601String(),
    };
  }
}
