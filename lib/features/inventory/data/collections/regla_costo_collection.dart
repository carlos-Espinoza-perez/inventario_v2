import 'package:isar/isar.dart';

part 'regla_costo_collection.g.dart';

@collection
class ReglaCostoCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId; // UUID

  @Index()
  late String empresaId;

  String? nombre;
  double factorRedondeo = 1.0;
  bool activo = true;

  late DateTime ultimaActualizacion;

  // =========================================================
  // CAMPOS PARA SINCRONIZACIÓN (OFFLINE FIRST)
  // =========================================================

  @Index()
  bool pendienteSincronizacion = true;

  ReglaCostoCollection();

  // Mapper: De Supabase (snake_case) a Isar
  factory ReglaCostoCollection.fromJson(Map<String, dynamic> json) {
    return ReglaCostoCollection()
      ..serverId = json['id']
      ..empresaId = json['empresa_id']
      ..nombre = json['nombre']
      // Conversión segura de numéricos (int -> double)
      ..factorRedondeo = (json['factor_redondeo'] is int)
          ? (json['factor_redondeo'] as int).toDouble()
          : (json['factor_redondeo'] as double)
      ..activo = json['activo'] ?? true
      ..ultimaActualizacion = DateTime.parse(json['ultima_actualizacion']);
  }

  // Mapper: De Isar a Supabase (snake_case)
  Map<String, dynamic> toJson() {
    return {
      'id': serverId,
      'empresa_id': empresaId,
      'nombre': nombre,
      'factor_redondeo': factorRedondeo,
      'activo': activo,
      'ultima_actualizacion': ultimaActualizacion.toIso8601String(),
    };
  }
}
