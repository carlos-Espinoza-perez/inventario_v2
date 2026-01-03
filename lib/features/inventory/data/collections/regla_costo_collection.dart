import 'package:isar/isar.dart';
part 'regla_costo_collection.g.dart';

@collection
class ReglaCostoCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;
  @Index()
  late String empresaId;

  String? nombre;
  double factorRedondeo = 1.0;
  bool activo = true;

  late DateTime ultimaActualizacion;
}
