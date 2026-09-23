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

/// Campo que corrige el comando "corrige/cambia lo último a …".
enum DictationCorrectionField { cantidad, costo, precio }

/// Resultado de `DictationParser.parseCorrectLastCommand`.
class DictationLastCorrection {
  final DictationCorrectionField field;
  final double value;

  const DictationLastCorrection({required this.field, required this.value});
}

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

  /// Comando "corrige/cambia lo último a …": ajusta cantidad, costo o precio
  /// de la última fila del borrador sin borrarla. Null si el texto no
  /// matchea. Sin campo explícito, usa la misma regla que "a X" en
  /// [parseLine] (precio en venta, costo en entrada).
  static DictationLastCorrection? parseCorrectLastCommand(
    String text, {
    required bool esVenta,
  }) {
    final norm = _normalize(text);
    final match = RegExp(
      r'^(?:corrige|corregir|cambia|cambiar)\s+'
      r'(?:lo\s+ultimo|el\s+ultimo|la\s+ultima)\s+'
      r'(?:(cantidad|costo|precio)\s+)?(?:a|en)\s+(.+)$',
    ).firstMatch(norm);
    if (match == null) return null;

    final value = _parseAmount(match.group(2)!);
    if (value == null) return null;

    final field = switch (match.group(1)) {
      'cantidad' => DictationCorrectionField.cantidad,
      'costo' => DictationCorrectionField.costo,
      'precio' => DictationCorrectionField.precio,
      _ =>
        esVenta ? DictationCorrectionField.precio : DictationCorrectionField.costo,
    };
    return DictationLastCorrection(field: field, value: value);
  }

  // -------------------------------------------------------------------
  // Autocorrecciones dentro de una frase ("15... no, 50 tornillos")
  // -------------------------------------------------------------------

  static final RegExp _correctionMarkerRe =
      RegExp(r'\b(?:no|perdon|digo|corrijo|mejor\s+dicho)\b');

  static final RegExp _amountConnectorRe = RegExp(
    r'\b(?:a|en|por|costo(?:\s+de)?|precio(?:\s+(?:de\s+venta\s+)?de)?)\s+',
  );

  /// Detecta un marcador de autocorrección ("no", "perdón", "digo",
  /// "mejor dicho", "corrijo") seguido de un número o monto y reescribe la
  /// frase para que solo quede el último valor. Evita falsos positivos como
  /// "no hay" o "no" dentro de otra palabra (nogal, nota) exigiendo que lo
  /// siguiente al marcador sea, en efecto, un valor numérico.
  static String _applyCorrections(String normalized) {
    RegExpMatch? valid;
    for (final m in _correctionMarkerRe.allMatches(normalized)) {
      final rest = normalized.substring(m.end).replaceFirst(RegExp(r'^,?\s*'), '');
      if (_looksLikeCorrectionValue(rest)) valid = m;
    }
    if (valid == null) return normalized;

    final before = normalized.substring(0, valid.start).trim();
    final after =
        normalized.substring(valid.end).replaceFirst(RegExp(r'^,?\s*'), '').trim();
    if (after.isEmpty) return normalized;

    // "after" trae más que un monto puro (ej. "50 tornillos"): reemplaza
    // toda la frase por la versión corregida.
    final afterAmount = _parseAmount(after);
    if (afterAmount == null) return after;

    // "after" es un monto puro: si "before" trae una cláusula de monto
    // ("a X", "costo X", "precio X"), se reemplaza el monto de la ÚLTIMA
    // (la más cercana al marcador de corrección).
    final connectorMatches = _amountConnectorRe.allMatches(before).toList();
    if (connectorMatches.isNotEmpty) {
      final last = connectorMatches.last;
      final prefix = before.substring(0, last.start);
      final connector = before.substring(last.start, last.end);
      return '$prefix$connector$after'.trim();
    }

    // Sin cláusula de monto: se asume corrección de la cantidad inicial
    // ("quince tornillos no cincuenta" → "cincuenta tornillos").
    final tokens =
        before.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    final qty = tokens.isEmpty ? null : _parseLeadingQuantity(tokens);
    if (qty != null) {
      final rest = tokens.sublist(qty.$2).join(' ');
      return rest.isEmpty ? after : '$after $rest'.trim();
    }

    // No se pudo determinar qué campo corrige: mejor no tocar nada.
    return normalized;
  }

  static bool _looksLikeCorrectionValue(String rest) {
    final tokens =
        rest.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    if (tokens.isEmpty) return false;
    return _isNumberWord(tokens.first);
  }

  static bool _isNumberWord(String token) {
    if (double.tryParse(token.replaceAll(',', '.')) != null) return true;
    return _units.containsKey(token) ||
        _tens.containsKey(token) ||
        _veinti.containsKey(token) ||
        _hundreds.containsKey(token) ||
        token == 'media';
  }

  /// Interpreta una línea de ítem. [esVenta] decide si "a X" es precio
  /// (venta) o costo (entrada). Null → mandar al fallback LLM.
  static DictatedLine? parseLine(String text, {required bool esVenta}) {
    var str = _normalize(text);
    if (str.isEmpty) return null;
    str = _applyCorrections(str);
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
