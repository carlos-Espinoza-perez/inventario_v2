import 'package:isar/isar.dart';

part 'inventario_collection.g.dart';

@collection
class InventarioCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId; // UUID

  @Index()
  late String bodegaId;

  @Index()
  late String productoId;

  double cantidadActual = 0;
  double cantidadReservada = 0;
  String? ubicacionPasillo;

  double costoPromedio = 0.0;

  // --- Auditoría (Según esquema: ActualizadoPor) ---
  String? actualizadoPor; // GUID del usuario que modificó el stock

  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;

  // =========================================================
  // CAMPOS PARA SINCRONIZACIÓN (OFFLINE FIRST)
  // =========================================================

  @Index()
  bool pendienteSincronizacion = true;

  InventarioCollection();

  // Mapper: De Supabase (snake_case) a Isar
  factory InventarioCollection.fromJson(Map<String, dynamic> json) {
    return InventarioCollection()
      ..serverId = json['id']
      ..bodegaId = json['bodega_id']
      ..productoId = json['producto_id']
      // Conversión segura de numéricos
      ..cantidadActual = (json['cantidad_actual'] is int)
          ? (json['cantidad_actual'] as int).toDouble()
          : (json['cantidad_actual'] as double)
      ..cantidadReservada = (json['cantidad_reservada'] is int)
          ? (json['cantidad_reservada'] as int).toDouble()
          : (json['cantidad_reservada'] as double)
      ..ubicacionPasillo = json['ubicacion_pasillo']
      ..costoPromedio = (json['costo_promedio'] == null)
          ? 0.0
          : (json['costo_promedio'] as num).toDouble()
      // Auditoría
      ..actualizadoPor = json['actualizado_por']
      ..ultimaActualizacion = DateTime.parse(json['ultima_actualizacion'])
      ..fechaEliminacion = json['fecha_eliminacion'] != null
          ? DateTime.parse(json['fecha_eliminacion'])
          : null;
  }

  // Mapper: De Isar a Supabase (snake_case)
  Map<String, dynamic> toJson() {
    return {
      'id': serverId,
      'bodega_id': bodegaId,
      'producto_id': productoId,
      'cantidad_actual': cantidadActual,
      'cantidad_reservada': cantidadReservada,
      'ubicacion_pasillo': ubicacionPasillo,
      'costo_promedio': costoPromedio,
      'actualizado_por': actualizadoPor,

      'ultima_actualizacion': ultimaActualizacion.toIso8601String(),
      'fecha_eliminacion': fechaEliminacion?.toIso8601String(),
    };
  }
}
