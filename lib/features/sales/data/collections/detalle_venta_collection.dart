import 'package:isar/isar.dart';

part 'detalle_venta_collection.g.dart';

@collection
class DetalleVentaCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId; // UUID

  @Index()
  late String ventaId;

  @Index()
  late String productoId;

  double cantidad = 0;
  double precioUnitario = 0;
  double descuento = 0;
  double subTotal = 0;

  double costoHistoricoCompra = 0; // Para reportes de ganancia real

  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;

  // =========================================================
  // CAMPOS PARA SINCRONIZACIÓN (OFFLINE FIRST)
  // =========================================================

  @Index()
  bool pendienteSincronizacion = true;

  DetalleVentaCollection();

  // Mapper: De Supabase (snake_case) a Isar
  factory DetalleVentaCollection.fromJson(Map<String, dynamic> json) {
    return DetalleVentaCollection()
      ..serverId = json['id']
      ..ventaId = json['venta_id']
      ..productoId = json['producto_id']
      // Conversiones seguras de numéricos (int -> double)
      ..cantidad = (json['cantidad'] is int)
          ? (json['cantidad'] as int).toDouble()
          : (json['cantidad'] as double)
      ..precioUnitario = (json['precio_unitario'] is int)
          ? (json['precio_unitario'] as int).toDouble()
          : (json['precio_unitario'] as double)
      ..descuento = (json['descuento'] is int)
          ? (json['descuento'] as int).toDouble()
          : (json['descuento'] as double)
      ..subTotal = (json['sub_total'] is int)
          ? (json['sub_total'] as int).toDouble()
          : (json['sub_total'] as double)
      ..costoHistoricoCompra = (json['costo_historico_compra'] is int)
          ? (json['costo_historico_compra'] as int).toDouble()
          : (json['costo_historico_compra'] as double? ?? 0.0)
      ..ultimaActualizacion = DateTime.parse(json['ultima_actualizacion'])
      ..fechaEliminacion = json['fecha_eliminacion'] != null
          ? DateTime.parse(json['fecha_eliminacion'])
          : null;
  }

  // Mapper: De Isar a Supabase (snake_case)
  Map<String, dynamic> toJson() {
    return {
      'id': serverId,
      'venta_id': ventaId,
      'producto_id': productoId,

      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'descuento': descuento,
      'sub_total': subTotal,
      'costo_historico_compra': costoHistoricoCompra,

      'ultima_actualizacion': ultimaActualizacion.toIso8601String(),
      'fecha_eliminacion': fechaEliminacion?.toIso8601String(),
    };
  }
}
