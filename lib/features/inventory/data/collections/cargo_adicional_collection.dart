import 'package:isar/isar.dart';

part 'cargo_adicional_collection.g.dart';

@collection
class CargoAdicionalCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId; // UUID

  @Index()
  late String empresaId;

  String? nombre;
  double valor = 0;
  bool esPorcentaje = false;
  bool aplicarAutomatico = false;

  late DateTime ultimaActualizacion;

  // =========================================================
  // CAMPOS PARA SINCRONIZACIÓN (OFFLINE FIRST)
  // =========================================================

  @Index()
  bool pendienteSincronizacion = true;

  CargoAdicionalCollection();

  // Mapper: De Supabase (snake_case) a Isar
  factory CargoAdicionalCollection.fromJson(Map<String, dynamic> json) {
    return CargoAdicionalCollection()
      ..serverId = json['id']
      ..empresaId = json['empresa_id']
      ..nombre = json['nombre']
      // Manejo seguro de números (int a double)
      ..valor = (json['valor'] is int)
          ? (json['valor'] as int).toDouble()
          : (json['valor'] as double)
      ..esPorcentaje = json['es_porcentaje'] ?? false
      ..aplicarAutomatico = json['aplicar_automatico'] ?? false
      ..ultimaActualizacion = DateTime.parse(json['ultima_actualizacion']);
  }

  // Mapper: De Isar a Supabase (snake_case)
  Map<String, dynamic> toJson() {
    return {
      'id': serverId,
      'empresa_id': empresaId,
      'nombre': nombre,
      'valor': valor,
      'es_porcentaje': esPorcentaje,
      'aplicar_automatico': aplicarAutomatico,
      'ultima_actualizacion': ultimaActualizacion.toIso8601String(),
    };
  }
}
