import 'package:isar/isar.dart';
import '../../../../core/constants/app_enums.dart';

part 'venta_collection.g.dart';

@collection
class VentaCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId; // UUID

  @Index()
  late String empresaId;

  @Index()
  late String clienteId;

  late String cajaSesionId;

  // Enums en Isar (se guardan como índice 0,1,2...)
  @Enumerated(EnumType.ordinal)
  late TipoVenta tipoVenta;

  @Enumerated(EnumType.ordinal)
  late EstadoPago estadoPago;

  double totalVenta = 0;
  double totalPagado = 0;
  double saldoPendiente = 0;

  late DateTime fechaVenta;
  DateTime? fechaVencimiento;

  // --- Auditoría (Agregados para consistencia con Sync) ---
  String? usuarioRegistroId; // Vendedor o creador

  @Index()
  bool estado = true; // Venta Anulada o Activa

  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;

  // =========================================================
  // CAMPOS PARA SINCRONIZACIÓN (OFFLINE FIRST)
  // =========================================================

  @Index()
  bool pendienteSincronizacion = true;

  VentaCollection();

  // Mapper: De Supabase (snake_case) a Isar
  factory VentaCollection.fromJson(Map<String, dynamic> json) {
    return VentaCollection()
      ..serverId = json['id']
      ..empresaId = json['empresa_id']
      ..clienteId = json['cliente_id']
      ..cajaSesionId = json['caja_sesion_id']
      // Conversión de String (BD) a Enum (Dart)
      ..tipoVenta = TipoVenta.values.firstWhere(
        (e) => e.name == json['tipo_venta'],
        orElse: () => TipoVenta.values.first,
      )
      ..estadoPago = EstadoPago.values.firstWhere(
        (e) => e.name == json['estado_pago'],
        orElse: () => EstadoPago.values.first,
      )
      // Conversión segura de numéricos (Dinero)
      ..totalVenta = (json['total_venta'] is int)
          ? (json['total_venta'] as int).toDouble()
          : (json['total_venta'] as double)
      ..totalPagado = (json['total_pagado'] is int)
          ? (json['total_pagado'] as int).toDouble()
          : (json['total_pagado'] as double)
      ..saldoPendiente = (json['saldo_pendiente'] is int)
          ? (json['saldo_pendiente'] as int).toDouble()
          : (json['saldo_pendiente'] as double)
      ..fechaVenta = DateTime.parse(json['fecha_venta'])
      ..fechaVencimiento = json['fecha_vencimiento'] != null
          ? DateTime.parse(json['fecha_vencimiento'])
          : null
      // Auditoría
      ..usuarioRegistroId =
          json['usuario_registro_id'] // O 'usuario_vendedor_id' según tu tabla
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
      'empresa_id': empresaId,
      'cliente_id': clienteId,
      'caja_sesion_id': cajaSesionId,

      // Enviamos el nombre del Enum a Supabase
      'tipo_venta': tipoVenta.name,
      'estado_pago': estadoPago.name,

      'total_venta': totalVenta,
      'total_pagado': totalPagado,
      'saldo_pendiente': saldoPendiente,

      'fecha_venta': fechaVenta.toIso8601String(),
      'fecha_vencimiento': fechaVencimiento?.toIso8601String(),

      // Auditoría
      'usuario_registro_id': usuarioRegistroId,
      'estado': estado,

      'ultima_actualizacion': ultimaActualizacion.toIso8601String(),
      'fecha_eliminacion': fechaEliminacion?.toIso8601String(),
    };
  }
}
