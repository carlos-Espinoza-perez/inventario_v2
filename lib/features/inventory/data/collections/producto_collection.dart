import 'package:isar/isar.dart';
part 'producto_collection.g.dart';

@collection
class ProductoCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  @Index()
  late String empresaId;

  @Index()
  late String categoriaId;

  @Index(unique: true) // Código de barra único
  String? sku;

  String? codigoPersonalizado;
  late String nombre;
  String? descripcion;
  String? imagenUrl;

  double? precioBase; // Isar usa double, no decimal
  String? especificacionJson;

  bool estado = true;
  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;
}
