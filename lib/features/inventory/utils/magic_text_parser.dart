import 'package:inventario_v2/core/db/app_database.dart';

class MagicTextParser {
  /// Normaliza el texto removiendo tildes, convirtiendo a minúsculas
  /// y eliminando caracteres especiales.
  static String normalize(String text) {
    String normalized = text.toLowerCase().trim();
    const withDia = 'áéíóúüñ';
    const withoutDia = 'aeiouun';
    for (int i = 0; i < withDia.length; i++) {
      normalized = normalized.replaceAll(withDia[i], withoutDia[i]);
    }
    // Mantener solo letras, números y espacios
    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9\s]'), '');
    return normalized;
  }

  /// Busca la mejor coincidencia de categoría dentro de un texto dado.
  /// Devuelve un mapa con { 'parent': Categoria?, 'child': Categoria? }
  static Map<String, Categoria?> extractCategory({
    required String text,
    required List<Categoria> allCategories,
  }) {
    final normalizedText = normalize(text);
    if (normalizedText.isEmpty) return {'parent': null, 'child': null};

    final words = normalizedText.split(' ');

    Categoria? bestParent;
    Categoria? bestChild;

    // 1. Buscar coincidencias exactas por palabra completa
    for (final word in words) {
      if (word.length < 3) continue; // Ignorar palabras muy cortas (de, la, el)

      for (final cat in allCategories) {
        final normCatName = normalize(cat.nombre);
        // Si la palabra coincide con el nombre de la categoría, o parte principal de ella
        if (normCatName == word || (normCatName.isNotEmpty && word.contains(normCatName))) {
          if (cat.categoriaPadreId != null) {
            // Es subcategoría
            bestChild = cat;
            bestParent = allCategories.where((c) => c.id == cat.categoriaPadreId).firstOrNull;
          } else {
            // Es categoría padre
            bestParent = cat;
          }
          break; // Salir si encontramos una buena coincidencia en esta iteración
        }
      }
      if (bestChild != null || bestParent != null) break;
    }

    return {'parent': bestParent, 'child': bestChild};
  }

  /// Busca una marca dentro de un texto dado.
  static String? extractBrand({
    required String text,
    required List<String> knownBrands,
  }) {
    final normalizedText = normalize(text);
    if (normalizedText.isEmpty) return null;

    for (final brand in knownBrands) {
      final normBrand = normalize(brand);
      if (normBrand.isEmpty) continue;
      
      // Buscamos la marca completa como palabra exacta dentro del texto
      // \b indica límite de palabra
      final regex = RegExp(r'\b' + RegExp.escape(normBrand) + r'\b');
      if (regex.hasMatch(normalizedText)) {
        return brand; // Devolvemos la original (con mayúsculas, etc.)
      }
    }
    
    return null;
  }
}
