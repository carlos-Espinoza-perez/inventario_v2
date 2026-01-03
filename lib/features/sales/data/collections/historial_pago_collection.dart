import 'package:isar/isar.dart';
import '../../../../core/constants/app_enums.dart';
part 'historial_pago_collection.g.dart';

@collection
class HistorialPagoCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  @Index()
  late String ventaId;

  @Index()
  late String cajaSesionId; // Vital para arqueo

  double montoPagado = 0;

  @Enumerated(EnumType.ordinal)
  late MetodoPago metodoDePago; // Enum

  String? referencia;

  late DateTime fechaRegistro;
  String? usuarioRegistroId;
  bool estado = true;
  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;
}
