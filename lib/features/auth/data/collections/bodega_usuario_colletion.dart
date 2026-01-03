import 'package:isar/isar.dart';

part 'bodega_usuario_colletion.g.dart';

@collection
class BodegaUsuarioColletion {
  // Isar requiere un ID entero local para su funcionamiento interno.
  // Usaremos fastHash para convertir tu GUID string a int si es necesario,
  // o simplemente dejamos que Isar lo autoincremente.
  Id id = Isar.autoIncrement;

  // Tu GUID original (Identificador único global)
  @Index(unique: true)
  late String uid;

  @Index()
  late String bodegaId;

  @Index()
  late String usuarioId;

  // --- Auditoría ---
  late String usuarioRegistroId;

  @Index() // Indexamos el estado para filtrar rápido lo "activo"
  bool estado = true;

  late DateTime fechaRegistro;

  DateTime? ultimaActualizacion;

  DateTime? fechaEliminacion;
}
