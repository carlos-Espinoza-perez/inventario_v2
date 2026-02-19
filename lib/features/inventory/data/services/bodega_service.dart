import 'package:inventario_v2/features/auth/data/collections/bodega_collection.dart';
import 'package:inventario_v2/features/auth/data/collections/bodega_usuario_colletion.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

class BodegaService {
  final Isar _isar;

  BodegaService(this._isar);

  // Escuchar bodegas activas con filtro de búsqueda opcional
  Stream<List<BodegaCollection>> watchBodegas({String query = ''}) {
    QueryBuilder<BodegaCollection, BodegaCollection, QAfterFilterCondition> q =
        _isar.bodegaCollections.filter().estadoEqualTo(true); // Solo activas

    if (query.isNotEmpty) {
      // Filtro insensible a mayúsculas/minúsculas
      q = q.nombreContains(query, caseSensitive: false);
    }

    // Ordenar por nombre y retornar Stream
    return q.sortByNombre().watch(fireImmediately: true);
  }

  // Método para guardar (crear/editar) que usaremos más adelante
  Future<void> saveBodega(BodegaCollection bodega) async {
    await _isar.writeTxn(() async {
      bodega.ultimaActualizacion = DateTime.now();
      await _isar.bodegaCollections.put(bodega);
    });
  }

  Future<void> crearBodega({
    required String nombre,
    required String? direccion,
    required String? descripcion,
    required bool esPuntoVenta,
    required String usuarioIdActual,
    required String empresaId,
  }) async {
    // 1. Generar IDs únicos (Simulación de UUID)
    final String bodegaUid = _generateUid();
    final String relacionUid = _generateUid();

    // 2. Preparar objeto Bodega
    final nuevaBodega = BodegaCollection()
      ..serverId = bodegaUid
      ..empresaId = empresaId
      ..nombre = nombre
      ..direccion = direccion
      ..esPuntoVenta = esPuntoVenta
      ..usuarioRegistroId = usuarioIdActual
      ..fechaRegistro = DateTime.now()
      ..estado = true
      ..ultimaActualizacion = DateTime.now()
      ..pendienteSincronizacion = true;

    // 3. Preparar objeto Relación (BodegaUsuario)
    final nuevaRelacion = BodegaUsuarioColletion()
      ..uid = relacionUid
      ..bodegaId = bodegaUid
      ..usuarioId = usuarioIdActual
      ..usuarioRegistroId = usuarioIdActual
      ..estado = true
      ..fechaRegistro = DateTime.now()
      ..ultimaActualizacion = DateTime.now()
      ..pendienteSincronizacion = true;

    // 4. Guardar ambos en una sola transacción (Atomicidad)
    await _isar.writeTxn(() async {
      await _isar.bodegaCollections.put(nuevaBodega);
      await _isar.bodegaUsuarioColletions.put(nuevaRelacion);
    });
  }

  // Helper simple para generar IDs únicos (Si no usas el paquete 'uuid')
  String _generateUid() {
    const uuid = Uuid();

    String id = uuid.v4();
    return id;
  }
}
