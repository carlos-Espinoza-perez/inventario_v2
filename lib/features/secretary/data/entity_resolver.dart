import 'package:drift/drift.dart';
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

  // ---------------------------------------------------------------------
  // Normalización de consultas dictadas (letras deletreadas y números en
  // palabras) — función pura, sin acceso a datos.
  // ---------------------------------------------------------------------

  /// Nombres de letra en español que NO son palabras ambiguas del habla
  /// normal (se excluyen a propósito las vocales sueltas y "de": son
  /// preposiciones/artículos comunes y convertirlas rompería búsquedas
  /// normales como "gorra de fútbol").
  static const Map<String, String> _spokenLetters = {
    'be': 'b', 'ce': 'c', 'efe': 'f', 'ge': 'g', 'hache': 'h', 'jota': 'j',
    'ka': 'k', 'ele': 'l', 'eme': 'm', 'ene': 'n', 'pe': 'p', 'cu': 'q',
    'ere': 'r', 'erre': 'r', 'ese': 's', 'te': 't', 'uve': 'v', 've': 'v',
    'equis': 'x', 'ye': 'y', 'zeta': 'z',
  };

  static const Map<String, int> _spokenDigitWords = {
    'cero': 0, 'uno': 1, 'dos': 2, 'tres': 3, 'cuatro': 4, 'cinco': 5,
    'seis': 6, 'siete': 7, 'ocho': 8, 'nueve': 9, 'diez': 10, 'once': 11,
    'doce': 12, 'trece': 13, 'catorce': 14, 'quince': 15, 'dieciseis': 16,
    'diecisiete': 17, 'dieciocho': 18, 'diecinueve': 19, 'veinte': 20,
    'treinta': 30, 'cuarenta': 40, 'cincuenta': 50,
  };

  /// Palabras que anuncian un código/talla ("talla S", "modelo eme seis"):
  /// habilitan convertir una letra deletreada AISLADA (sin otro token
  /// código pegado) porque el contexto ya desambigua la intención.
  static const Set<String> _sizeCueWords = {
    'talla', 'numero', 'modelo', 'codigo', 'medida', 'referencia', 'ref',
  };

  /// Normaliza una consulta dictada por voz: convierte letras deletreadas
  /// ("eme seis" → "m6", "equis ele" → "xl") y números en palabras a
  /// dígitos, sin tildes ni mayúsculas. Es deliberadamente conservadora: una
  /// letra suelta ("ese", "de", "a"...) es carne de ambigüedad con palabras
  /// comunes del español, así que solo se convierte cuando aparece junto a
  /// otro token-código (dígito u otra letra) o tras una palabra "cue" como
  /// "talla"/"modelo". Los números sueltos sí se convierten siempre: son
  /// mucho menos ambiguos que las letras sueltas en este dominio.
  static String normalizeSpokenQuery(String raw) {
    final normalized = _normalizeStatic(raw);
    if (normalized.isEmpty) return normalized;
    final tokens = normalized.split(' ');

    final converted = List<String>.filled(tokens.length, '');
    final isDigitTok = List<bool>.filled(tokens.length, false);
    final isLetterTok = List<bool>.filled(tokens.length, false);
    for (var i = 0; i < tokens.length; i++) {
      final t = tokens[i];
      if (_spokenDigitWords.containsKey(t)) {
        converted[i] = _spokenDigitWords[t]!.toString();
        isDigitTok[i] = true;
      } else if (RegExp(r'^\d+$').hasMatch(t)) {
        converted[i] = t;
        isDigitTok[i] = true;
      } else if (_spokenLetters.containsKey(t)) {
        converted[i] = _spokenLetters[t]!;
        isLetterTok[i] = true;
      } else {
        converted[i] = t;
      }
    }

    final eligible = List<bool>.filled(tokens.length, false);
    for (var i = 0; i < tokens.length; i++) {
      if (isDigitTok[i]) {
        eligible[i] = true;
      } else if (isLetterTok[i]) {
        final prevIsCue = i > 0 && _sizeCueWords.contains(tokens[i - 1]);
        final prevIsCode =
            i > 0 && (isDigitTok[i - 1] || isLetterTok[i - 1]);
        final nextIsCode = i < tokens.length - 1 &&
            (isDigitTok[i + 1] || isLetterTok[i + 1]);
        eligible[i] = prevIsCue || prevIsCode || nextIsCode;
      }
    }

    final result = <String>[];
    var i = 0;
    while (i < tokens.length) {
      if (eligible[i]) {
        final run = StringBuffer(converted[i]);
        var j = i + 1;
        while (j < tokens.length &&
            eligible[j] &&
            (isDigitTok[j] || isLetterTok[j])) {
          run.write(converted[j]);
          j++;
        }
        result.add(run.toString());
        i = j;
      } else {
        result.add(tokens[i]);
        i++;
      }
    }
    return result.join(' ');
  }

  /// Igual que [_normalize] de instancia, pero estática para que la use
  /// [normalizeSpokenQuery] sin necesitar una instancia del resolver.
  static String _normalizeStatic(String value) {
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

  Future<EntityResolverResult<Producto>> resolveProduct(
    String query, {
    required String empresaId,
  }) async {
    if (query.trim().isEmpty) return EntityResolverResult.notFound();

    // Convierte letras deletreadas y números en palabras ("eme seis" → "m6")
    // antes de buscar, tanto por código exacto como por nombre/fuzzy.
    final normalizedQuery = normalizeSpokenQuery(query);

    // Solo CÓDIGO exacto resuelve directo. El atajo anterior
    // (searchProductoByCodeOrName) hacía LIKE por nombre con LIMIT 1 y
    // elegía un producto silenciosamente aunque hubiera varios parecidos
    // ("gorra" → Gorra Roja sin preguntar); el nombre debe pasar por la
    // lógica de catálogo, que sí detecta ambigüedad.
    final byCode = await (_db.select(_db.productos)
          ..where(
            (t) =>
                t.empresaId.equals(empresaId) &
                t.estado.equals(true) &
                (t.codigoPersonalizado.equals(query.trim()) |
                    t.codigoPersonalizado.equals(normalizedQuery)),
          )
          ..limit(1))
        .getSingleOrNull();
    if (byCode != null) return EntityResolverResult.resolved(byCode);

    // Buscar por nombre parcial y por nombres parecidos en el catalogo.
    final catalog = await _db.inventoryDao.getCatalogItems(
      empresaId: empresaId,
    );
    final queryTokens = _singularTokens(normalizedQuery);
    final containsMatches = catalog.where((item) {
      final normalizedName = _normalize(item.nombre);
      if (normalizedName.contains(normalizedQuery) ||
          normalizedQuery.contains(normalizedName)) {
        return true;
      }
      // Match por tokens singularizados: "pantalones" ≈ "Pantalon Jeans",
      // "gorras rojas" ≈ "Gorra Roja". Cada palabra de la consulta debe
      // aparecer (como prefijo) en el nombre del producto.
      final nameTokens = _singularTokens(normalizedName);
      return queryTokens.isNotEmpty &&
          queryTokens.every(
            (q) => nameTokens.any((n) => n == q || n.startsWith(q)),
          );
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

  /// Tokens en singular aproximado: "pantalones" → "pantalon",
  /// "gorras" → "gorra". Suficiente para emparejar consultas coloquiales
  /// en plural con los nombres del catálogo.
  List<String> _singularTokens(String normalized) {
    return normalized
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .map(_singular)
        .toList();
  }

  String _singular(String token) {
    if (token.length > 4 && token.endsWith('es')) {
      return token.substring(0, token.length - 2);
    }
    if (token.length > 3 && token.endsWith('s')) {
      return token.substring(0, token.length - 1);
    }
    return token;
  }

  String _normalize(String value) => _normalizeStatic(value);

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
