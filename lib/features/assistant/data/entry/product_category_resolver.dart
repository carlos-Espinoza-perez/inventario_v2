import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/features/assistant/domain/models/assistant_entry_models.dart';

class ProductCategoryResolver {
  final AppDatabase _db;

  ProductCategoryResolver(this._db);

  Future<AssistantSuggestedCategory> suggest({
    required String productName,
    required String empresaId,
  }) async {
    final categories = await _db.inventoryDao
        .watchCategoriasPorEmpresa(empresaId)
        .first;
    if (categories.isEmpty) {
      final usuarioId = await _currentUserId();
      final general = await _db.inventoryDao.saveCategoria(
        empresaId: empresaId,
        nombre: 'General',
        categoriaPadreId: null,
        usuarioRegistroId: usuarioId,
      );
      return AssistantSuggestedCategory(
        id: general.id,
        name: general.nombre,
        score: 0.4,
      );
    }

    final queryTokens = _tokens(productName);
    Categoria? best;
    var bestScore = 0.0;
    for (final category in categories) {
      final categoryTokens = _tokens(category.nombre);
      final score = _score(queryTokens, categoryTokens);
      if (score > bestScore) {
        best = category;
        bestScore = score;
      }
    }

    if (best != null && bestScore >= 0.42) {
      return AssistantSuggestedCategory(
        id: best.id,
        name: best.nombre,
        score: bestScore,
      );
    }

    final general = await _findOrCreateGeneral(empresaId);
    return AssistantSuggestedCategory(
      id: general.id,
      name: general.nombre,
      score: 0.2,
    );
  }

  Future<Categoria> resolveOrCreate({
    required String name,
    required String empresaId,
    required String usuarioId,
  }) async {
    final existing = await _db.inventoryDao.findCategoriaByName(
      empresaId: empresaId,
      name: name,
    );
    if (existing != null) return existing;
    return _db.inventoryDao.saveCategoria(
      empresaId: empresaId,
      nombre: name.trim().isEmpty ? 'General' : name.trim(),
      categoriaPadreId: null,
      usuarioRegistroId: usuarioId,
    );
  }

  Future<Categoria> _findOrCreateGeneral(String empresaId) async {
    final existing = await _db.inventoryDao.findCategoriaByName(
      empresaId: empresaId,
      name: 'General',
    );
    if (existing != null) return existing;
    final usuarioId = await _currentUserId();
    return _db.inventoryDao.saveCategoria(
      empresaId: empresaId,
      nombre: 'General',
      categoriaPadreId: null,
      usuarioRegistroId: usuarioId,
    );
  }

  Future<String> _currentUserId() async {
    final session = await _db.authDao.getSesionActiva();
    return session?.usuario.id ?? '';
  }

  double _score(List<String> productTokens, List<String> categoryTokens) {
    if (productTokens.isEmpty || categoryTokens.isEmpty) return 0;
    var total = 0.0;
    for (final productToken in productTokens) {
      var best = 0.0;
      for (final categoryToken in categoryTokens) {
        if (productToken == categoryToken) {
          best = 1;
        } else if (productToken.contains(categoryToken) ||
            categoryToken.contains(productToken)) {
          best = best < 0.75 ? 0.75 : best;
        } else {
          final distance = _levenshtein(productToken, categoryToken);
          final max = productToken.length > categoryToken.length
              ? productToken.length
              : categoryToken.length;
          if (max > 0) {
            final similarity = 1 - (distance / max);
            if (similarity > best) best = similarity;
          }
        }
      }
      total += best;
    }
    return total / productTokens.length;
  }

  List<String> _tokens(String value) {
    return _normalize(
      value,
    ).split(' ').map(_singularize).where((token) => token.length >= 3).toList();
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
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
