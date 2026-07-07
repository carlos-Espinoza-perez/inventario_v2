/// Línea dictada ya interpretada por la vía rápida local.
class DictatedLine {
  final String nombre;
  final double cantidad;
  final double? costo;
  final double? precio;

  const DictatedLine({
    required this.nombre,
    required this.cantidad,
    this.costo,
    this.precio,
  });
}

/// Comandos reservados del modo dictado (se interceptan antes del parser).
enum DictationCommand { finish, undoLast, cancelAll }

/// Parser determinista de dictado en español. Vía rápida (<300 ms, sin red):
/// extrae (cantidad, descripción, costo/precio) de frases como
/// "12 pantalones a 10 dólares" o "tres cajas de gorras costo 5 precio 12".
/// Lo que no entienda devuelve null y cae al fallback LLM.
class DictationParser {
  /// Detecta comandos reservados. Null si la frase no es un comando.
  static DictationCommand? parseCommand(String text) {
    final norm = _normalize(text);
    const finishForms = {
      'listo', 'ya esta', 'ya estuvo', 'termine', 'terminar', 'terminamos',
      'finalizar', 'finaliza', 'confirmar', 'eso es todo', 'es todo',
    };
    if (finishForms.contains(norm)) return DictationCommand.finish;

    final hasDelete = RegExp(r'\b(borra|borrar|quita|quitar|elimina|eliminar)\b')
        .hasMatch(norm);
    if (hasDelete && norm.contains('ultim')) return DictationCommand.undoLast;

    final isCancel = RegExp(
      r'^(cancela|cancelar|descarta|descartar)\b.*\b(todo|dictado|borrador)$',
    ).hasMatch(norm);
    if (isCancel || norm == 'cancela todo' || norm == 'cancelar todo') {
      return DictationCommand.cancelAll;
    }
    return null;
  }

  /// Interpreta una línea de ítem. [esVenta] decide si "a X" es precio
  /// (venta) o costo (entrada). Null → mandar al fallback LLM.
  static DictatedLine? parseLine(String text, {required bool esVenta}) {
    var str = _normalize(text);
    if (str.isEmpty) return null;

    double? costo;
    double? precio;

    // 1. Marcadores explícitos: "costo (de) X", "precio (de venta) (de) X".
    final costoMatch = RegExp(r'\b(?:con\s+)?costo\s+(?:de\s+)?(.+?)(?=\s+(?:y\s+)?precio\b|$)')
        .firstMatch(str);
    if (costoMatch != null) {
      costo = _parseAmount(costoMatch.group(1)!);
      if (costo != null) str = str.replaceRange(costoMatch.start, costoMatch.end, ' ');
    }
    final precioMatch =
        RegExp(r'\b(?:con\s+)?precio\s+(?:de\s+venta\s+)?(?:de\s+)?(.+)$')
            .firstMatch(str);
    if (precioMatch != null) {
      precio = _parseAmount(precioMatch.group(1)!);
      if (precio != null) {
        str = str.replaceRange(precioMatch.start, precioMatch.end, ' ');
      }
    }

    // 2. Forma corta "… a 10 (dólares)" / "… en 10": según el tipo.
    if (costo == null && precio == null) {
      final aMatch = RegExp(r'\s\b(?:a|en|por)\s+(.+)$').firstMatch(str);
      if (aMatch != null) {
        final monto = _parseAmount(aMatch.group(1)!);
        if (monto != null) {
          if (esVenta) {
            precio = monto;
          } else {
            costo = monto;
          }
          str = str.replaceRange(aMatch.start, aMatch.end, ' ');
        }
      }
    }

    // 3. Cantidad al inicio (dígitos, palabras o docenas).
    final tokens =
        str.trim().split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    if (tokens.isEmpty) return null;
    final qtyResult = _parseLeadingQuantity(tokens);
    if (qtyResult == null) return null;
    final (cantidad, consumed) = qtyResult;
    if (cantidad <= 0) return null;

    // 4. Descripción = resto, limpiando conectores iniciales.
    var descTokens = tokens.sublist(consumed);
    while (descTokens.isNotEmpty &&
        const {'de', 'del', 'unidades', 'unidad', 'piezas', 'pieza'}
            .contains(descTokens.first)) {
      descTokens = descTokens.sublist(1);
    }
    final nombre = descTokens.join(' ').trim();
    if (nombre.isEmpty) return null;

    // Si la descripción todavía trae dígitos, quedaron montos/cantidades sin
    // interpretar (ej. dos ítems en una frase) → mejor el fallback LLM.
    if (RegExp(r'\d').hasMatch(nombre)) return null;

    return DictatedLine(
      nombre: nombre,
      cantidad: cantidad,
      costo: costo,
      precio: precio,
    );
  }

  // -------------------------------------------------------------------
  // Números en español
  // -------------------------------------------------------------------

  static const _units = {
    'cero': 0, 'un': 1, 'una': 1, 'uno': 1, 'dos': 2, 'tres': 3,
    'cuatro': 4, 'cinco': 5, 'seis': 6, 'siete': 7, 'ocho': 8, 'nueve': 9,
    'diez': 10, 'once': 11, 'doce': 12, 'trece': 13, 'catorce': 14,
    'quince': 15, 'dieciseis': 16, 'diecisiete': 17, 'dieciocho': 18,
    'diecinueve': 19,
  };

  static const _tens = {
    'veinte': 20, 'treinta': 30, 'cuarenta': 40, 'cincuenta': 50,
    'sesenta': 60, 'setenta': 70, 'ochenta': 80, 'noventa': 90,
  };

  static const _veinti = {
    'veintiun': 21, 'veintiuno': 21, 'veintiuna': 21, 'veintidos': 22,
    'veintitres': 23, 'veinticuatro': 24, 'veinticinco': 25,
    'veintiseis': 26, 'veintisiete': 27, 'veintiocho': 28,
    'veintinueve': 29,
  };

  static const _hundreds = {
    'cien': 100, 'ciento': 100, 'doscientos': 200, 'trescientos': 300,
    'cuatrocientos': 400, 'quinientos': 500, 'seiscientos': 600,
    'setecientos': 700, 'ochocientos': 800, 'novecientos': 900,
  };

  /// Cantidad al inicio de la frase → (valor, tokens consumidos).
  static (double, int)? _parseLeadingQuantity(List<String> tokens) {
    // "media docena (de)" / "una docena" / "dos docenas".
    if (tokens.first == 'media' &&
        tokens.length > 1 &&
        tokens[1].startsWith('docena')) {
      return (6, 2);
    }
    final numResult = _parseNumberTokens(tokens);
    if (numResult == null) return null;
    var (value, consumed) = numResult;
    if (consumed < tokens.length && tokens[consumed].startsWith('docena')) {
      value *= 12;
      consumed++;
    }
    return (value, consumed);
  }

  /// Número (dígitos o palabras) al inicio → (valor, tokens consumidos).
  static (double, int)? _parseNumberTokens(List<String> tokens) {
    if (tokens.isEmpty) return null;
    final first = tokens.first;

    final digits = double.tryParse(first.replaceAll(',', '.'));
    if (digits != null) return (digits, 1);
    if (_veinti.containsKey(first)) return (_veinti[first]!.toDouble(), 1);

    if (_hundreds.containsKey(first)) {
      var value = _hundreds[first]!.toDouble();
      var consumed = 1;
      final rest = _parseNumberTokens(tokens.sublist(1));
      // "ciento veinte" — el resto tiene que ser < 100 para ser continuación.
      if (rest != null && rest.$1 < 100) {
        value += rest.$1;
        consumed += rest.$2;
      }
      return (value, consumed);
    }

    if (_tens.containsKey(first)) {
      var value = _tens[first]!.toDouble();
      var consumed = 1;
      // "treinta y cinco"
      if (tokens.length > 2 &&
          tokens[1] == 'y' &&
          _units.containsKey(tokens[2]) &&
          _units[tokens[2]]! < 10) {
        value += _units[tokens[2]]!;
        consumed = 3;
      }
      return (value, consumed);
    }

    if (_units.containsKey(first)) return (_units[first]!.toDouble(), 1);
    return null;
  }

  /// Monto de dinero desde texto libre: "10", "10.50", "diez dolares",
  /// "dos con cincuenta" (=2.50). Ignora palabras de moneda y muletillas.
  static double? _parseAmount(String raw) {
    final cleaned = _normalize(raw)
        .replaceAll(
          RegExp(
            r'\b(pesos?|dolares?|cordobas?|lempiras?|quetzales?|colones?|'
            r'soles?|bolivianos?|centavos?|centimos?|cada\s+un[oa]|'
            r'la\s+unidad|por\s+unidad|c/u|cu)\b',
          ),
          ' ',
        )
        .trim();
    final tokens =
        cleaned.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    if (tokens.isEmpty) return null;

    final entero = _parseNumberTokens(tokens);
    if (entero == null) return null;
    var (value, consumed) = entero;

    // Decimales hablados: "dos con cincuenta" → 2.50.
    if (consumed < tokens.length && tokens[consumed] == 'con') {
      final decimales = _parseNumberTokens(tokens.sublist(consumed + 1));
      if (decimales != null && decimales.$1 < 100) {
        value += decimales.$1 / 100;
        consumed += 1 + decimales.$2;
      }
    }

    // Si sobró texto (ej. "10 y 5 camisas a 20": dos ítems en una frase),
    // no es un monto simple → que lo interprete el fallback LLM completo.
    if (consumed != tokens.length) return null;
    return value;
  }

  static String _normalize(String text) {
    var s = text.toLowerCase().trim();
    const accents = {
      'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u', 'ñ': 'n',
    };
    accents.forEach((k, v) => s = s.replaceAll(k, v));
    s = s.replaceAll(RegExp(r'[$€!?;:]'), ' ');
    // Puntos/comas solo se conservan como separador decimal entre dígitos.
    s = s.replaceAll(RegExp(r'(?<!\d)[.,]|[.,](?!\d)'), ' ');
    return s.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
