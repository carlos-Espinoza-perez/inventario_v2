import 'package:isar/isar.dart';

part 'detalle_movimiento_producto_collection.g.dart';

@collection
class DetalleMovimientoProductoCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId; // UUID

  @Index()
  late String movimientoProductoId;

  @Index()
  late String productoId;

  double cantidad = 0;

  double costoProveedor = 0;
  String? cargosAdicionalesJson; // JSON snapshot
  double costoUnitarioFinal = 0;

  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;

  // =========================================================
  // CAMPOS PARA SINCRONIZACIÓN (OFFLINE FIRST)
  // =========================================================

  @Index()
  bool pendienteSincronizacion = true;

  DetalleMovimientoProductoCollection();

  // Mapper: De Supabase (snake_case) a Isar
  factory DetalleMovimientoProductoCollection.fromJson(
    Map<String, dynamic> json,
  ) {
    return DetalleMovimientoProductoCollection()
      ..serverId = json['id']
      ..movimientoProductoId = json['movimiento_producto_id']
      ..productoId = json['producto_id']
      // Manejo seguro de numéricos
      ..cantidad = (json['cantidad'] is int)
          ? (json['cantidad'] as int).toDouble()
          : (json['cantidad'] as double)
      ..costoProveedor = (json['costo_proveedor'] is int)
          ? (json['costo_proveedor'] as int).toDouble()
          : (json['costo_proveedor'] as double)
      ..cargosAdicionalesJson = json['cargos_adicionales']?.toString()
      ..costoUnitarioFinal = (json['costo_unitario_final'] is int)
          ? (json['costo_unitario_final'] as int).toDouble()
          : (json['costo_unitario_final'] as double)
      ..ultimaActualizacion = DateTime.parse(json['ultima_actualizacion'])
      ..fechaEliminacion = json['fecha_eliminacion'] != null
          ? DateTime.parse(json['fecha_eliminacion'])
          : null;
  }

  // Mapper: De Isar a Supabase (snake_case)
  Map<String, dynamic> toJson() {
    return {
      'id': serverId,
      'movimiento_producto_id': movimientoProductoId,
      'producto_id': productoId,
      'cantidad': cantidad,
      'costo_proveedor': costoProveedor,
      'cargos_adicionales': cargosAdicionalesJson,
      'costo_unitario_final': costoUnitarioFinal,

      'ultima_actualizacion': ultimaActualizacion.toIso8601String(),
      'fecha_eliminacion': fechaEliminacion?.toIso8601String(),
    };
  }
}
