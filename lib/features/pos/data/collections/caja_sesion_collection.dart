import 'package:isar/isar.dart';
import '../../../../core/constants/app_enums.dart';
part 'caja_sesion_collection.g.dart';

@collection
class CajaSesionCollection {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String serverId;

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
  late EstadoSesion estadoSesion;

  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;
}
