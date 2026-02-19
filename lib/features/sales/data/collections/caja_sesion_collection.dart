import 'package:isar/isar.dart';
import '../../../../core/constants/app_enums.dart';

part 'caja_sesion_collection.g.dart';

@collection
class CajaSesionCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId; // UUID

  @Index()
  late String cajaId;

  late String usuarioAperturaId;
  String? usuarioCierreId;

  late DateTime fechaApertura;
  DateTime? fechaCierre;

  double montoInicial = 0;
  double totalVentasSistema = 0;
  double totalEfectivoReal = 0;
  double diferencia = 0;

  @Enumerated(EnumType.ordinal)
  late EstadoSesion estadoSesion; // Enum: ABIERTA, CERRADA, ARQUEADA

  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;

  // =========================================================
  // CAMPOS PARA SINCRONIZACIÓN (OFFLINE FIRST)
  // =========================================================

  @Index()
  bool pendienteSincronizacion = true;

  CajaSesionCollection();

  // Mapper: De Supabase (snake_case) a Isar
  factory CajaSesionCollection.fromJson(Map<String, dynamic> json) {
    return CajaSesionCollection()
      ..serverId = json['id']
      ..cajaId = json['caja_id']
      ..usuarioAperturaId = json['usuario_apertura_id']
      ..usuarioCierreId = json['usuario_cierre_id']
      ..fechaApertura = DateTime.parse(json['fecha_apertura'])
      ..fechaCierre = json['fecha_cierre'] != null
          ? DateTime.parse(json['fecha_cierre'])
          : null
      // Conversión segura de numéricos (Dinero)
      ..montoInicial = (json['monto_inicial'] is int)
          ? (json['monto_inicial'] as int).toDouble()
          : (json['monto_inicial'] as double)
      ..totalVentasSistema = (json['total_ventas_sistema'] is int)
          ? (json['total_ventas_sistema'] as int).toDouble()
          : (json['total_ventas_sistema'] as double)
      ..totalEfectivoReal = (json['total_efectivo_real'] is int)
          ? (json['total_efectivo_real'] as int).toDouble()
          : (json['total_efectivo_real'] as double)
      ..diferencia = (json['diferencia'] is int)
          ? (json['diferencia'] as int).toDouble()
          : (json['diferencia'] as double)
      // Conversión de String (BD) a Enum (Dart)
      ..estadoSesion = EstadoSesion.values.firstWhere(
        (e) => e.name == json['estado_sesion'],
        orElse: () => EstadoSesion.values.first,
      )
      ..ultimaActualizacion = DateTime.parse(json['ultima_actualizacion'])
      ..fechaEliminacion = json['fecha_eliminacion'] != null
          ? DateTime.parse(json['fecha_eliminacion'])
          : null;
  }

  // Mapper: De Isar a Supabase (snake_case)
  Map<String, dynamic> toJson() {
    return {
      'id': serverId,
      'caja_id': cajaId,
      'usuario_apertura_id': usuarioAperturaId,
      'usuario_cierre_id': usuarioCierreId,
      'fecha_apertura': fechaApertura.toIso8601String(),
      'fecha_cierre': fechaCierre?.toIso8601String(),

      'monto_inicial': montoInicial,
      'total_ventas_sistema': totalVentasSistema,
      'total_efectivo_real': totalEfectivoReal,
      'diferencia': diferencia,

      // Enviamos el nombre del Enum a Supabase
      'estado_sesion': estadoSesion.name,

      'ultima_actualizacion': ultimaActualizacion.toIso8601String(),
      'fecha_eliminacion': fechaEliminacion?.toIso8601String(),
    };
  }
}
