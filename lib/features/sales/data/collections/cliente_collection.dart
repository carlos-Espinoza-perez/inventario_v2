import 'package:isar/isar.dart';

part 'cliente_collection.g.dart';

@collection
class ClienteCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId; // UUID

  @Index()
  late String empresaId;

  late String nombre;
  String? identificacion;
  String? celular;
  String? direccion;

  double montoCreditoMaximo = 0;
  double saldoDeudorActual = 0;

  // --- Auditoría ---
  late DateTime fechaRegistro;
  bool estado = true;
  String? usuarioRegistroId;

  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;

  // =========================================================
  // CAMPOS PARA SINCRONIZACIÓN (OFFLINE FIRST)
  // =========================================================

  @Index()
  bool pendienteSincronizacion = true;

  ClienteCollection();

  // Mapper: De Supabase (snake_case) a Isar
  factory ClienteCollection.fromJson(Map<String, dynamic> json) {
    return ClienteCollection()
      ..serverId = json['id']
      ..empresaId = json['empresa_id']
      ..nombre = json['nombre']
      ..identificacion = json['identificacion']
      ..celular = json['celular']
      ..direccion = json['direccion']
      // Conversión segura de numéricos (Dinero)
      ..montoCreditoMaximo = (json['monto_credito_maximo'] is int)
          ? (json['monto_credito_maximo'] as int).toDouble()
          : (json['monto_credito_maximo'] as double? ?? 0.0)
      ..saldoDeudorActual = (json['saldo_deudor_actual'] is int)
          ? (json['saldo_deudor_actual'] as int).toDouble()
          : (json['saldo_deudor_actual'] as double? ?? 0.0)
      // Auditoría
      ..fechaRegistro = DateTime.parse(json['fecha_registro'])
      ..estado = json['estado'] ?? true
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
      'empresa_id': empresaId,
      'nombre': nombre,
      'identificacion': identificacion,
      'celular': celular,
      'direccion': direccion,

      'monto_credito_maximo': montoCreditoMaximo,
      'saldo_deudor_actual': saldoDeudorActual,

      // Auditoría
      'fecha_registro': fechaRegistro.toIso8601String(),
      'estado': estado,
      'usuario_registro_id': usuarioRegistroId,

      'ultima_actualizacion': ultimaActualizacion.toIso8601String(),
      'fecha_eliminacion': fechaEliminacion?.toIso8601String(),
    };
  }
}
