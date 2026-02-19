import 'package:isar/isar.dart';

part 'codigo_producto_collection.g.dart';

@collection
class CodigoProductoCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId; // Mapea a 'id'

  @Index()
  late String productoId; // Mapea a 'producto_id'

  @Index()
  late String talla; // Mapea a 'talla'

  String? color; // Mapea a 'color'

  @Index(unique: true)
  late String codigoSku; // Mapea a 'codigo_sku'

  // Auditoría
  late DateTime fechaRegistro; // 'fecha_registro'
  bool estado = true; // 'estado'
  late String usuarioRegistroId; // 'usuario_registro_id'
  late DateTime ultimaActualizacion; // 'ultima_actualizacion'
  DateTime? fechaEliminacion; // 'fecha_eliminacion'

  // Sync (Solo local)
  @Index()
  bool pendienteSincronizacion = true;

  CodigoProductoCollection();

  // Mapper: De Supabase (snake_case) a Isar
  factory CodigoProductoCollection.fromJson(Map<String, dynamic> json) {
    return CodigoProductoCollection()
      ..serverId = json['id'] as String? ?? ''
      ..productoId = json['producto_id'] as String? ?? ''
      ..talla = json['talla'] as String? ?? ''
      ..color = json['color'] as String?
      ..codigoSku = json['codigo_sku'] as String? ?? ''
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
      'producto_id': productoId,
      'talla': talla,
      'color': color,
      'codigo_sku': codigoSku,

      // Auditoría
      'usuario_registro_id': usuarioRegistroId,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'estado': estado,
      'ultima_actualizacion': ultimaActualizacion.toIso8601String(),
      'fecha_eliminacion': fechaEliminacion?.toIso8601String(),
    };
  }
}
