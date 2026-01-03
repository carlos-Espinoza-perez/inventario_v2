import 'package:isar/isar.dart';
part 'categoria_collection.g.dart';

@collection
class CategoriaCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  @Index()
  late String empresaId;

  late String nombre;
  String? categoriaPadreId; // UUID de la categoría padre
  String? especificacionJson;

  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;
}
