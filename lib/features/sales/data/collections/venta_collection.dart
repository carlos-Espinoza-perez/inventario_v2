import 'package:isar/isar.dart';
import '../../../../core/constants/app_enums.dart'; // Importa tus enums
part 'venta_collection.g.dart';

@collection
class VentaCollection {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String serverId;

  @Index()
  late String empresaId;
  @Index()
  late String clienteId;
  late String cajaSesionId;

  // Enums en Isar
  @Enumerated(EnumType.ordinal)
  late TipoVenta tipoVenta;

  @Enumerated(EnumType.ordinal)
  late EstadoPago estadoPago;

  double totalVenta = 0;
  double totalPagado = 0;
  double saldoPendiente = 0;

  late DateTime fechaVenta;
  DateTime? fechaVencimiento;

  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;
}
