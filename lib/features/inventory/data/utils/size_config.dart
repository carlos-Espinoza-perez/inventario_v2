class SizeConfig {
  static const List<String> _ropaSuperior = [
    "XS",
    "S",
    "M",
    "L",
    "XL",
    "XXL",
    "3XL",
  ];
  static const List<String> _ropaInferior = [
    "28",
    "30",
    "32",
    "34",
    "36",
    "38",
    "40",
    "42",
  ];
  static const List<String> _calzado = [
    "35",
    "36",
    "37",
    "38",
    "39",
    "40",
    "41",
    "42",
    "43",
    "44",
    "45",
  ];
  static const List<String> _unica = ["Única"];

  static List<String> getSizesForCategory(String category) {
    if (category.isEmpty) return _unica;
    final cat = category.toLowerCase();

    // Ropa Superior
    if (cat.contains("camis") ||
        cat.contains("blusa") ||
        cat.contains("top") ||
        cat.contains("sueter") ||
        cat.contains("jersey") ||
        cat.contains("sudadera") ||
        cat.contains("chaqueta") ||
        cat.contains("abrigo") ||
        cat.contains("saco") ||
        cat.contains("chaleco") ||
        cat.contains("vestido")) {
      return _ropaSuperior;
    }

    // Ropa Inferior
    if (cat.contains("jeans") ||
        cat.contains("pantal") ||
        cat.contains("falda") ||
        cat.contains("short") ||
        cat.contains("jogger") ||
        cat.contains("traje")) {
      return _ropaInferior;
    }

    // Calzado
    if (cat.contains("tenis") ||
        cat.contains("zapato") ||
        cat.contains("bota") ||
        cat.contains("sandalia") ||
        cat.contains("tacon")) {
      return _calzado;
    }

    // Default
    return _unica;
  }
}
