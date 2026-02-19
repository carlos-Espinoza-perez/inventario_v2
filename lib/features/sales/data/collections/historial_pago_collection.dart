import 'package:isar/isar.dart';
import '../../../../core/constants/app_enums.dart';

part 'historial_pago_collection.g.dart';

@collection
class HistorialPagoCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId; // UUID

  @Index()
  late String ventaId;

  @Index()
  late String cajaSesionId; // Vital para arqueo de caja

  double montoPagado = 0;

  @Enumerated(EnumType.ordinal)
  late MetodoPago metodoDePago; // Enum (Efectivo, Tarjeta, etc.)

  String? referencia;

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

  HistorialPagoCollection();

  // Mapper: De Supabase (snake_case) a Isar
  factory HistorialPagoCollection.fromJson(Map<String, dynamic> json) {
    return HistorialPagoCollection()
      ..serverId = json['id']
      ..ventaId = json['venta_id']
      ..cajaSesionId = json['caja_sesion_id']
      // Conversión segura de numéricos
      ..montoPagado = (json['monto_pagado'] is int)
          ? (json['monto_pagado'] as int).toDouble()
          : (json['monto_pagado'] as double)
      // Conversión de String (BD) a Enum (Dart)
      ..metodoDePago = MetodoPago.values.firstWhere(
        (e) => e.name == json['metodo_de_pago'],
        orElse: () => MetodoPago.values.first, // Fallback
      )
      ..referencia = json['referencia']
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
      'venta_id': ventaId,
      'caja_sesion_id': cajaSesionId,
      'monto_pagado': montoPagado,

      // Enviamos el nombre del Enum a Supabase
      'metodo_de_pago': metodoDePago.name,

      'referencia': referencia,

      // Auditoría
      'fecha_registro': fechaRegistro.toIso8601String(),
      'usuario_registro_id': usuarioRegistroId,
      'estado': estado,

      'ultima_actualizacion': ultimaActualizacion.toIso8601String(),
      'fecha_eliminacion': fechaEliminacion?.toIso8601String(),
    };
  }
}
