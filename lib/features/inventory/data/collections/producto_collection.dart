import 'package:isar/isar.dart';

part 'producto_collection.g.dart';

@collection
class ProductoCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId; // UUID

  @Index()
  late String empresaId;

  @Index()
  late String categoriaId;

  String? codigoPersonalizado;

  @Index(type: IndexType.value) // Indexado para búsqueda por nombre
  late String nombre;

  String? descripcion;
  String? imagenUrl;

  double? precioBase; // Precio referencial
  String? especificacionJson; // JSON de metadatos

  double ultimoCosto = 0.0;
  double ultimoPrecioVenta = 0.0;

  // --- Auditoría ---
  late DateTime fechaRegistro;
  late String usuarioRegistroId; // En tu esquema: RegistroUsuarioId

  @Index()
  bool estado = true;

  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;

  // =========================================================
  // CAMPOS PARA SINCRONIZACIÓN (OFFLINE FIRST)
  // =========================================================

  String? imagenLocal;

  @Index()
  bool pendienteSincronizacion = true;

  ProductoCollection();

  // Mapper: De Supabase (snake_case) a Isar
  factory ProductoCollection.fromJson(Map<String, dynamic> json) {
    return ProductoCollection()
      ..serverId = json['id']
      ..empresaId = json['empresa_id']
      ..categoriaId = json['categoria_id']
      ..codigoPersonalizado = json['codigo_personalizado']
      ..nombre = json['nombre']
      ..descripcion = json['descripcion']
      ..imagenUrl = json['imagen_url']
      // Conversión segura num -> double
      ..precioBase = json['precio_base'] != null
          ? (json['precio_base'] is int
                ? (json['precio_base'] as int).toDouble()
                : (json['precio_base'] as double))
          : 0.0
      ..especificacionJson = json['especificacion']?.toString()
      // Auditoría
      ..fechaRegistro = DateTime.parse(json['fecha_registro'])
      ..usuarioRegistroId =
          json['registro_usuario_id'] // Ojo: snake_case según esquema
      ..estado = json['estado'] ?? true
      ..ultimaActualizacion = DateTime.parse(json['ultima_actualizacion'])
      ..fechaEliminacion = json['fecha_eliminacion'] != null
          ? DateTime.parse(json['fecha_eliminacion'])
          : null
      ..ultimoCosto = json['ultimo_costo'] ?? 0.0
      ..ultimoPrecioVenta = json['ultimo_precio_venta'] ?? 0.0;
  }

  // Mapper: De Isar a Supabase (snake_case)
  Map<String, dynamic> toJson() {
    return {
      'id': serverId,
      'empresa_id': empresaId,
      'categoria_id': categoriaId,
      'codigo_personalizado': codigoPersonalizado,
      'nombre': nombre,
      'descripcion': descripcion,
      'imagen_url': imagenUrl,
      'precio_base': precioBase,
      'especificacion': especificacionJson,

      // Auditoría
      'fecha_registro': fechaRegistro.toIso8601String(),
      'registro_usuario_id': usuarioRegistroId,
      'estado': estado,

      'ultima_actualizacion': ultimaActualizacion.toIso8601String(),
      'fecha_eliminacion': fechaEliminacion?.toIso8601String(),

      'ultimo_costo': ultimoCosto,
      'ultimo_precio_venta': ultimoPrecioVenta,
    };
  }
}
