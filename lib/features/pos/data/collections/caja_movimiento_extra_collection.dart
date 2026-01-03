import 'package:isar/isar.dart';
import '../../../../core/constants/app_enums.dart';
part 'caja_movimiento_extra_collection.g.dart';

@collection
class CajaMovimientoExtraCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  @Index()
  late String cajaSesionId;

  String? referenciaVentaId;

  @Enumerated(EnumType.ordinal)
  late TipoMovimientoCaja tipo; // INGRESO, EGRESO

  String? motivo;
  double monto = 0;

  String? usuarioRegistroId;
  bool estado = true;
  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;
}
