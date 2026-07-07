import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/db/models/product_catalog_models.dart';

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

  factory EntityResolverResult.resolved(T item) =>
      EntityResolverResult._(selected: item, isResolved: true);

  factory EntityResolverResult.ambiguous(List<T> items) =>
      EntityResolverResult._(candidates: items, isAmbiguous: true);

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

    final normalizedQuery = _normalize(query);

    // Buscar por codigo exacto primero.
    final byCode = await _db.inventoryDao.searchProductoByCodeOrName(
      normalizedQuery,
    );
    if (byCode != null) return EntityResolverResult.resolved(byCode);

    // Buscar por nombre parcial y por nombres parecidos en el catalogo.
    final catalog = await _db.inventoryDao.getCatalogItems(
      empresaId: empresaId,
    );
    final containsMatches = catalog.where((item) {
      final normalizedName = _normalize(item.nombre);
      return normalizedName.contains(normalizedQuery) ||
          normalizedQuery.contains(normalizedName);
    }).toList();

    final matches = containsMatches.isNotEmpty
        ? containsMatches
        : _findFuzzyProductMatches(catalog, normalizedQuery);

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

    final normalizedQuery = _normalize(query);
    final todos = await _db.salesDao.searchClientes(
      normalizedQuery,
      empresaId,
    );

    final matches = todos
        .where(
          (c) =>
              _normalize(c.nombre).contains(normalizedQuery) ||
              (c.celular?.contains(normalizedQuery) ?? false),
        )
        .toList();

    if (matches.isEmpty) return EntityResolverResult.notFound();
    if (matches.length == 1) {
      return EntityResolverResult.resolved(matches.first);
    }
    return EntityResolverResult.ambiguous(matches.take(5).toList());
  }

  List<ProductCatalogItemDrift> _findFuzzyProductMatches(
    List<ProductCatalogItemDrift> catalog,
    String normalizedQuery,
  ) {
    final queryTokens = _importantTokens(normalizedQuery);
    if (queryTokens.isEmpty) return const [];

    final scored = <({ProductCatalogItemDrift item, double score})>[];
    for (final item in catalog) {
      final name = _normalize(item.nombre);
      final nameTokens = _importantTokens(name);
      if (nameTokens.isEmpty) continue;

      final score = _similarityScore(
        queryTokens,
        nameTokens,
        normalizedQuery,
        name,
      );
      if (score >= 0.72) {
        scored.add((item: item, score: score));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    if (scored.isEmpty) return const [];

    final bestScore = scored.first.score;
    return scored
        .where((entry) => bestScore - entry.score <= 0.08)
        .map((entry) => entry.item)
        .take(5)
        .toList();
  }

  double _similarityScore(
    List<String> queryTokens,
    List<String> nameTokens,
    String normalizedQuery,
    String normalizedName,
  ) {
    if (normalizedName == normalizedQuery) return 1;

    var total = 0.0;
    for (final queryToken in queryTokens) {
      var best = 0.0;
      for (final nameToken in nameTokens) {
        final score = _tokenSimilarity(queryToken, nameToken);
        if (score > best) best = score;
      }
      total += best;
    }
    return total / queryTokens.length;
  }

  double _tokenSimilarity(String a, String b) {
    if (a == b) return 1;
    if (a.length >= 4 && (a.contains(b) || b.contains(a))) return 0.92;

    final singularA = _singularize(a);
    final singularB = _singularize(b);
    if (singularA == singularB) return 0.96;
    if (singularA.length >= 4 &&
        (singularA.contains(singularB) || singularB.contains(singularA))) {
      return 0.9;
    }

    final distance = _levenshtein(singularA, singularB);
    final maxLength = singularA.length > singularB.length
        ? singularA.length
        : singularB.length;
    if (maxLength == 0) return 0;
    final similarity = 1 - (distance / maxLength);

    if (maxLength <= 5 && distance <= 1) return similarity;
    if (maxLength <= 10 && distance <= 2) return similarity;
    if (maxLength > 10 && distance <= 3) return similarity;
    return similarity >= 0.78 ? similarity : 0;
  }

  List<String> _importantTokens(String value) {
    const stopWords = {
      'de',
      'del',
      'la',
      'las',
      'el',
      'los',
      'un',
      'una',
      'para',
      'por',
      'con',
    };
    return value
        .split(' ')
        .map(_singularize)
        .where((token) => token.length >= 3 && !stopWords.contains(token))
        .toList();
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _singularize(String token) {
    if (token.endsWith('es') && token.length > 5) {
      return token.substring(0, token.length - 2);
    }
    if (token.endsWith('s') && token.length > 4) {
      return token.substring(0, token.length - 1);
    }
    return token;
  }

  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    var previous = List<int>.generate(b.length + 1, (i) => i);
    for (var i = 0; i < a.length; i++) {
      final current = List<int>.filled(b.length + 1, 0);
      current[0] = i + 1;
      for (var j = 0; j < b.length; j++) {
        final insert = current[j] + 1;
        final delete = previous[j + 1] + 1;
        final replace =
            previous[j] + (a.codeUnitAt(i) == b.codeUnitAt(j) ? 0 : 1);
        current[j + 1] = [
          insert,
          delete,
          replace,
        ].reduce((value, element) => value < element ? value : element);
      }
      previous = current;
    }
    return previous[b.length];
  }
}
