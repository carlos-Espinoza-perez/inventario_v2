import 'package:isar/isar.dart';

part 'empresa_collection.g.dart';

@collection
class EmpresaCollection {
  // ID interno de Isar (siempre necesario)
  Id id = Isar.autoIncrement;

  // Tu 'Id guid' de la base de datos (Clave primaria real)
  @Index(unique: true, replace: true)
  late String serverId;

  late String nombre;
  String? nombreComercial;
  String? ruc;

  // Tu campo 'Configuracion string [JSON]'
  // Isar no guarda JSON nativo, lo guardamos como String
  String? configuracion;

  // --- Auditoría ---
  bool estado = true;

  // Aunque en SQL tiene default now(), aquí puede venir nulo si no se ha sincronizado aún
  DateTime? fechaRegistro;

  String? usuarioRegistroId; // GUID del usuario creador

  late DateTime ultimaActualizacion; // VITAL para tu Sync
  DateTime? fechaEliminacion; // VITAL para Soft Delete

  // Constructor vacío
  EmpresaCollection();

  // Mapper para convertir lo que llega de Supabase
  factory EmpresaCollection.fromJson(Map<String, dynamic> json) {
    return EmpresaCollection()
      ..serverId = json['id']
      ..nombre = json['nombre']
      ..nombreComercial = json['nombre_comercial']
      ..ruc = json['ruc']
      // Si Supabase devuelve un Map (JSON), lo convertimos a String para guardarlo local
      ..configuracion = json['configuracion']?.toString()
      ..estado = json['estado'] ?? true
      ..fechaRegistro = json['fecha_registro'] != null
          ? DateTime.parse(json['fecha_registro'])
          : null
      ..usuarioRegistroId = json['usuario_registro_id']
      ..ultimaActualizacion = DateTime.parse(json['ultima_actualizacion'])
      ..fechaEliminacion = json['fecha_eliminacion'] != null
          ? DateTime.parse(json['fecha_eliminacion'])
          : null;
  }
}
