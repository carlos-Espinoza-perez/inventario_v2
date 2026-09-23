/// Reconocimiento determinista (sin LLM) de confirmación, rechazo y
/// elección de candidato por voz (SEC-IA-002 punto 4).
///
/// Deliberadamente estricto: solo acepta cuando el ENUNCIADO COMPLETO
/// normalizado es una de las formas conocidas. Nunca por contención parcial
/// — "sí pero cambia el precio" NO debe confirmar nada, tiene que mandarse
/// como mensaje normal para que el usuario pueda corregir antes de
/// confirmar de verdad.
class VoiceConfirmationMatcher {
  // La coma se elimina en _normalize, así que "sí, confirma" y "sí confirma"
  // terminan en la misma forma normalizada.
  static const Set<String> _confirmPhrases = {
    'confirmar',
    'confirmo',
    'si confirma',
    'si',
  };

  static bool isConfirmation(String text) =>
      _confirmPhrases.contains(_normalize(text));

  static const Set<String> _rejectPhrases = {
    'no',
    'cancela',
    'cancelar',
    'no confirmar',
    'no cancela',
  };

  static bool isRejection(String text) =>
      _rejectPhrases.contains(_normalize(text));

  static const Map<String, int> _ordinalWords = {
    'uno': 1, 'el uno': 1, 'primero': 1, 'el primero': 1, 'primera': 1,
    'la primera': 1,
    'dos': 2, 'el dos': 2, 'segundo': 2, 'el segundo': 2, 'segunda': 2,
    'la segunda': 2,
    'tres': 3, 'el tres': 3, 'tercero': 3, 'el tercero': 3, 'tercera': 3,
    'la tercera': 3,
    'cuatro': 4, 'el cuatro': 4, 'cuarto': 4, 'el cuarto': 4, 'cuarta': 4,
    'la cuarta': 4,
    'cinco': 5, 'el cinco': 5, 'quinto': 5, 'el quinto': 5, 'quinta': 5,
    'la quinta': 5,
  };

  /// Candidato elegido por número/ordinal hablado ("el uno", "segundo").
  /// 1-based, igual que se numeran los candidatos al leerlos. Null si el
  /// enunciado no es (solo) una elección.
  static int? parseChoice(String text) => _ordinalWords[_normalize(text)];

  static String _normalize(String text) {
    var s = text.toLowerCase().trim();
    const accents = {
      'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u', 'ñ': 'n',
    };
    accents.forEach((k, v) => s = s.replaceAll(k, v));
    s = s.replaceAll(RegExp(r'[^a-z\s]'), ' ');
    return s.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
