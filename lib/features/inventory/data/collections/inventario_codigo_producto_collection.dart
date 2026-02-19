import 'package:isar/isar.dart';

part 'inventario_codigo_producto_collection.g.dart';

@collection
class InventarioCodigoProductoCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId; // 'id'

  @Index()
  late String inventarioId; // 'inventario_id'

  @Index()
  late String codigoProductoId; // 'codigo_producto_id'

  double cantidad = 0; // 'cantidad'

  // Auditoría
  late DateTime fechaRegistro; // 'fecha_registro'
  bool estado = true; // 'estado'
  late String usuarioRegistroId; // 'usuario_registro_id'
  late DateTime ultimaActualizacion; // 'ultima_actualizacion'
  DateTime? fechaEliminacion; // 'fecha_eliminacion'

  // Sync
  @Index()
  bool pendienteSincronizacion = true;

  InventarioCodigoProductoCollection();

  // Mapper: De Supabase (snake_case) a Isar
  factory InventarioCodigoProductoCollection.fromJson(
    Map<String, dynamic> json,
  ) {
    return InventarioCodigoProductoCollection()
      ..serverId = json['id'] as String? ?? ''
      ..inventarioId = json['inventario_id'] as String? ?? ''
      ..codigoProductoId = json['codigo_producto_id'] as String? ?? ''
      // Manejo seguro de numéricos
      ..cantidad = (json['cantidad'] is int)
          ? (json['cantidad'] as int).toDouble()
          : (json['cantidad'] as double? ?? 0.0)
      // Auditoría
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
      'inventario_id': inventarioId,
      'codigo_producto_id': codigoProductoId,
      'cantidad': cantidad,

      // Auditoría
      'usuario_registro_id': usuarioRegistroId,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'estado': estado,
      'ultima_actualizacion': ultimaActualizacion.toIso8601String(),
      'fecha_eliminacion': fechaEliminacion?.toIso8601String(),
    };
  }
}
