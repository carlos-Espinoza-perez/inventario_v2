import 'package:isar/isar.dart';
part 'cliente_collection.g.dart';

@collection
class ClienteCollection {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String serverId;
  @Index()
  late String empresaId;

  late String nombre;
  String? identificacion;
  String? celular;
  String? direccion;

  double montoCreditoMaximo = 0;
  double saldoDeudorActual = 0;

  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;
}
