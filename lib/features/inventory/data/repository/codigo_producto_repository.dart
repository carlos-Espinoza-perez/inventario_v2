import 'package:isar/isar.dart';
import '../collections/codigo_producto_collection.dart';

class CodigoProductoRepository {
  final Isar _isar;
  CodigoProductoRepository(this._isar);

  // Obtener todos los CodigoProducto que tengan ese SKU/código de barras.
  // Estrategia multi-paso para tolerar variaciones del lector:
  //   1. Normaliza el input (trim + sin chars de control)
  //   2. Búsqueda exacta case-insensitive
  //   3. Si no hay resultados → búsqueda por startsWith (cubre sufijos extra raros)
  Future<List<CodigoProductoCollection>> getCodigosBySkuOBarcode(
    String sku,
  ) async {
    // Normalización defensiva
    final normalized = sku.trim().replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    if (normalized.isEmpty) return [];

    // 1. Búsqueda exacta (case-insensitive)
    final exact = await _isar.codigoProductoCollections
        .filter()
        .codigoSkuEqualTo(normalized, caseSensitive: false)
        .findAll();
    if (exact.isNotEmpty) return exact;

    // 2. Fallback: startsWith (por si el lector añade caracteres al final)
    final byPrefix = await _isar.codigoProductoCollections
        .filter()
        .codigoSkuStartsWith(normalized, caseSensitive: false)
        .findAll();
    if (byPrefix.isNotEmpty) return byPrefix;

    // 3. Fallback: contains (por si el código almacenado tiene prefijo diferente)
    return _isar.codigoProductoCollections
        .filter()
        .codigoSkuContains(normalized, caseSensitive: false)
        .findAll();
  }

  // Obtener por productoId (todas las variantes/tallas de un producto)
  Future<List<CodigoProductoCollection>> getCodigosByProductoId(
    String productoId,
  ) async {
    return _isar.codigoProductoCollections
        .filter()
        .productoIdEqualTo(productoId)
        .findAll();
  }

  // Obtener por serverId
  Future<CodigoProductoCollection?> getByServerId(String serverId) async {
    return _isar.codigoProductoCollections
        .filter()
        .serverIdEqualTo(serverId)
        .findFirst();
  }

  // Guardar o actualizar
  Future<void> upsert(CodigoProductoCollection item) async {
    await _isar.writeTxn(() async {
      await _isar.codigoProductoCollections.put(item);
    });
  }

  // Guardar múltiples
  Future<void> upsertAll(List<CodigoProductoCollection> items) async {
    await _isar.writeTxn(() async {
      await _isar.codigoProductoCollections.putAll(items);
    });
  }

  // Pendientes de sincronización
  Future<List<CodigoProductoCollection>> getPendientes() async {
    return _isar.codigoProductoCollections
        .filter()
        .pendienteSincronizacionEqualTo(true)
        .findAll();
  }

  // Watch todos los códigos de un producto
  Stream<List<CodigoProductoCollection>> watchByProductoId(String productoId) {
    return _isar.codigoProductoCollections
        .filter()
        .productoIdEqualTo(productoId)
        .watch(fireImmediately: true);
  }
}
