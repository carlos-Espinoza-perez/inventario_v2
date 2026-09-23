import 'scenario.dart';

/// Resultado de un turno ya ejecutado, en la forma mínima que necesita el
/// verificador. Desacoplado de `SecretaryTurnEvent`/`TurnCompleted` del
/// motor a propósito: así `verifyTurn` se puede testear con fixtures
/// sintéticos, sin levantar el motor real ni la base.
class HarnessTurnResult {
  final String responseText;
  final List<String> toolIds;

  /// true si el turno dejó un borrador activo (o lo tocó) — lo decide el
  /// runner mirando `draftHandler.lastDraftId` + el estado del borrador.
  final bool draftActive;

  const HarnessTurnResult({
    required this.responseText,
    required this.toolIds,
    required this.draftActive,
  });
}

/// Verifica un resultado de turno contra lo que declara el escenario.
/// Devuelve la lista de fallos (vacía = pasó). Las verificaciones de base
/// de datos (`db_unchanged_tables`) NO se hacen acá — el runner las agrega
/// aparte porque necesitan un snapshot antes/después de la base real.
List<String> verifyTurn(HarnessExpectation expect, HarnessTurnResult result) {
  final failures = <String>[];
  final responseLower = result.responseText.toLowerCase();
  final toolIdsSet = result.toolIds.toSet();

  if (expect.toolsAnyOf.isNotEmpty &&
      !expect.toolsAnyOf.any(toolIdsSet.contains)) {
    failures.add(
      'Ninguna tool esperada se llamó (any_of): ${expect.toolsAnyOf} — '
      'llamadas: ${result.toolIds}',
    );
  }
  for (final tool in expect.toolsAllOf) {
    if (!toolIdsSet.contains(tool)) {
      failures.add('Falta la tool esperada "$tool" — llamadas: ${result.toolIds}');
    }
  }
  for (final tool in expect.toolsNoneOf) {
    if (toolIdsSet.contains(tool)) {
      failures.add('Se llamó una tool prohibida: "$tool"');
    }
  }

  for (final text in expect.responseContainsAll) {
    if (!responseLower.contains(text.toLowerCase())) {
      failures.add('La respuesta no contiene "$text"');
    }
  }
  if (expect.responseContainsAny.isNotEmpty &&
      !expect.responseContainsAny.any(
        (t) => responseLower.contains(t.toLowerCase()),
      )) {
    failures.add(
      'La respuesta no contiene ninguno de: ${expect.responseContainsAny}',
    );
  }
  for (final text in expect.responseNotContainsAny) {
    if (responseLower.contains(text.toLowerCase())) {
      failures.add('La respuesta contiene un texto prohibido: "$text"');
    }
  }

  if (expect.draftExpected != null &&
      expect.draftExpected != result.draftActive) {
    failures.add(
      expect.draftExpected!
          ? 'Se esperaba que el turno dejara un borrador activo y no lo hizo'
          : 'El turno dejó un borrador activo sin que el escenario lo esperara',
    );
  }

  if (expect.maxSentences != null) {
    final sentences = _countSentences(result.responseText);
    if (sentences > expect.maxSentences!) {
      failures.add(
        'La respuesta tiene $sentences oraciones, se esperaban máximo '
        '${expect.maxSentences} (modo voz)',
      );
    }
  }

  return failures;
}

int _countSentences(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return 0;
  final matches = RegExp(r'[.!?]+(?=\s|$)').allMatches(trimmed);
  // Si no hay puntuación de cierre pero hay texto, cuenta como 1 oración.
  return matches.isEmpty ? 1 : matches.length;
}
