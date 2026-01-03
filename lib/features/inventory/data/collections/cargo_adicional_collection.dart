import 'package:isar/isar.dart';
part 'cargo_adicional_collection.g.dart';

@collection
class CargoAdicionalCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;
  @Index()
  late String empresaId;

  String? nombre;
  double valor = 0;
  bool esPorcentaje = false;
  bool aplicarAutomatico = false;

  late DateTime ultimaActualizacion;
}
