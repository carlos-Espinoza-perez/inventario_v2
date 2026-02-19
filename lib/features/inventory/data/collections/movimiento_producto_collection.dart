import 'package:isar/isar.dart';
import '../../../../core/constants/app_enums.dart';

part 'movimiento_producto_collection.g.dart';

@collection
class MovimientoProductoCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId; // UUID

  @Index()
  late String empresaId;

  @Enumerated(EnumType.ordinal)
  late TipoMovimiento tipoMovimiento; // Se guarda como int en Isar, pero String en JSON

  String? bodegaOrigenId;
  String? bodegaDestinoId;

  @Enumerated(EnumType.ordinal)
  late EstadoMovimiento estadoMovimiento; // Se guarda como int en Isar, pero String en JSON

  String? descripcion;

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

  MovimientoProductoCollection();

  // Mapper: De Supabase (snake_case) a Isar
  factory MovimientoProductoCollection.fromJson(Map<String, dynamic> json) {
    return MovimientoProductoCollection()
      ..serverId = json['id']
      ..empresaId = json['empresa_id']
      // Conversión de String (BD) a Enum (Dart)
      // Buscamos el enum cuyo nombre coincida con el texto de la BD
      ..tipoMovimiento = TipoMovimiento.values.firstWhere(
        (e) => e.name == json['tipo_movimiento'],
        orElse: () => TipoMovimiento.values.first, // Fallback por seguridad
      )
      ..bodegaOrigenId = json['bodega_origen_id']
      ..bodegaDestinoId = json['bodega_destino_id']
      // Conversión de String (BD) a Enum (Dart)
      ..estadoMovimiento = EstadoMovimiento.values.firstWhere(
        (e) => e.name == json['estado_movimiento'],
        orElse: () => EstadoMovimiento.values.first,
      )
      ..descripcion = json['descripcion']
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

      // Enviamos el nombre del Enum (ej: "COMPRA") a Supabase
      'tipo_movimiento': tipoMovimiento.name,

      'bodega_origen_id': bodegaOrigenId,
      'bodega_destino_id': bodegaDestinoId,

      // Enviamos el nombre del Enum (ej: "APROBADO") a Supabase
      'estado_movimiento': estadoMovimiento.name,

      'descripcion': descripcion,

      // Auditoría
      'fecha_registro': fechaRegistro.toIso8601String(),
      'usuario_registro_id': usuarioRegistroId,
      'estado': estado,

      'ultima_actualizacion': ultimaActualizacion.toIso8601String(),
      'fecha_eliminacion': fechaEliminacion?.toIso8601String(),
    };
  }
}
