import 'package:isar/isar.dart';
import '../../../../core/constants/app_enums.dart';

part 'caja_movimiento_extra_collection.g.dart';

@collection
class CajaMovimientoExtraCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId; // UUID

  @Index()
  late String cajaSesionId;

  String? referenciaVentaId;

  @Enumerated(EnumType.ordinal)
  late TipoMovimientoCaja tipo; // Enum: INGRESO, EGRESO

  String? motivo;
  double monto = 0;

  // --- Auditoría ---
  String? usuarioRegistroId;
  bool estado = true;

  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;

  // =========================================================
  // CAMPOS PARA SINCRONIZACIÓN (OFFLINE FIRST)
  // =========================================================

  @Index()
  bool pendienteSincronizacion = true;

  CajaMovimientoExtraCollection();

  // Mapper: De Supabase (snake_case) a Isar
  factory CajaMovimientoExtraCollection.fromJson(Map<String, dynamic> json) {
    return CajaMovimientoExtraCollection()
      ..serverId = json['id']
      ..cajaSesionId = json['caja_sesion_id']
      ..referenciaVentaId = json['referencia_venta_id']
      // Conversión de String (BD) a Enum (Dart)
      ..tipo = TipoMovimientoCaja.values.firstWhere(
        (e) => e.name == json['tipo'],
        orElse: () => TipoMovimientoCaja.values.first,
      )
      ..motivo = json['motivo']
      // Conversión segura de numéricos
      ..monto = (json['monto'] is int)
          ? (json['monto'] as int).toDouble()
          : (json['monto'] as double)
      // Auditoría
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
      'caja_sesion_id': cajaSesionId,
      'referencia_venta_id': referenciaVentaId,

      // Enviamos el nombre del Enum a Supabase
      'tipo': tipo.name,

      'motivo': motivo,
      'monto': monto,

      // Auditoría
      'usuario_registro_id': usuarioRegistroId,
      'estado': estado,

      'ultima_actualizacion': ultimaActualizacion.toIso8601String(),
      'fecha_eliminacion': fechaEliminacion?.toIso8601String(),
    };
  }
}
