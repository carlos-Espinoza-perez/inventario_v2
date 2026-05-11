import 'package:inventario_v2/core/db/app_database.dart';

class EntityResolverResult<T> {
  final T? selected;
  final List<T> candidates;
  final bool isResolved;
  final bool isAmbiguous;
  final bool isNotFound;

  const EntityResolverResult._({
    this.selected,
    this.candidates = const [],
    this.isResolved = false,
    this.isAmbiguous = false,
    this.isNotFound = false,
  });

  factory EntityResolverResult.resolved(T item) => EntityResolverResult._(
        selected: item,
        isResolved: true,
      );

  factory EntityResolverResult.ambiguous(List<T> items) =>
      EntityResolverResult._(
        candidates: items,
        isAmbiguous: true,
      );

  factory EntityResolverResult.notFound() =>
      EntityResolverResult._(isNotFound: true);
}

class EntityResolver {
  final AppDatabase _db;

  EntityResolver(this._db);

  Future<EntityResolverResult<Producto>> resolveProduct(
    String query, {
    required String empresaId,
  }) async {
    if (query.trim().isEmpty) return EntityResolverResult.notFound();

    final normalizedQuery = query.trim().toLowerCase();

    // Buscar por código exacto primero
    final byCode = await _db.inventoryDao.searchProductoByCodeOrName(normalizedQuery);
    if (byCode != null) return EntityResolverResult.resolved(byCode);

    // Buscar por nombre parcial en el catálogo
    final catalog = await _db.inventoryDao.getCatalogItems(empresaId: empresaId);
    final matches = catalog
        .where((item) => item.nombre.toLowerCase().contains(normalizedQuery))
        .toList();

    if (matches.isEmpty) return EntityResolverResult.notFound();

    if (matches.length == 1) {
      return EntityResolverResult.resolved(matches.first.producto);
    }

    return EntityResolverResult.ambiguous(
      matches.take(5).map((m) => m.producto).toList(),
    );
  }

  Future<EntityResolverResult<Cliente>> resolveClient(
    String query, {
    required String empresaId,
  }) async {
    if (query.trim().isEmpty) return EntityResolverResult.notFound();

    final normalizedQuery = query.trim().toLowerCase();
    final todos = await _db.salesDao.getPendingClientes();

    final matches = todos
        .where((c) =>
            c.nombre.toLowerCase().contains(normalizedQuery) ||
            (c.celular?.contains(normalizedQuery) ?? false))
        .toList();

    if (matches.isEmpty) return EntityResolverResult.notFound();
    if (matches.length == 1) return EntityResolverResult.resolved(matches.first);
    return EntityResolverResult.ambiguous(matches.take(5).toList());
  }
}
