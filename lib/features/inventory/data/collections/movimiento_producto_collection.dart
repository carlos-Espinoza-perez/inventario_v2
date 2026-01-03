import 'package:isar/isar.dart';
import '../../../../core/constants/app_enums.dart';
part 'movimiento_producto_collection.g.dart';

@collection
class MovimientoProductoCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  @Index()
  late String empresaId;

  @Enumerated(EnumType.ordinal)
  late TipoMovimiento tipoMovimiento; // Enum

  String? bodegaOrigenId;
  String? bodegaDestinoId;

  @Enumerated(EnumType.ordinal)
  late EstadoMovimiento estadoMovimiento; // Enum

  String? descripcion;

  late DateTime fechaRegistro;
  String? usuarioRegistroId;
  bool estado = true;
  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;
}
