import 'dart:io';

import 'package:yaml/yaml.dart';

import 'ground_truth_template.dart';

/// Qué debe cumplir la respuesta de un turno para considerarse correcto.
/// Todos los campos son opcionales: un escenario solo declara lo que le
/// importa verificar en ese turno.
class HarnessExpectation {
  /// Al menos una de estas tools debe haberse llamado en el turno.
  final List<String> toolsAnyOf;

  /// Todas estas tools deben haberse llamado (además de las de arriba).
  final List<String> toolsAllOf;

  /// Ninguna de estas tools debe haberse llamado (ej. draft.* en un
  /// escenario que NO debería tocar un borrador).
  final List<String> toolsNoneOf;

  /// Todos estos textos deben aparecer en la respuesta final (case
  /// insensitive). Soporta `{{gt:...}}`.
  final List<String> responseContainsAll;

  /// Al menos uno de estos textos debe aparecer en la respuesta.
  final List<String> responseContainsAny;

  /// Ninguno de estos textos debe aparecer en la respuesta (ej. un número
  /// inventado, o el nombre de un cliente que no pidió el usuario).
  final List<String> responseNotContainsAny;

  /// null = no se verifica. true = el turno debe dejar un borrador activo.
  /// false = el turno NO debe crear/dejar un borrador.
  final bool? draftExpected;

  /// Tablas (nombre SQL, snake_case) cuyo conteo de filas y checksum deben
  /// quedar IGUAL después del turno (ej. ["inventarios", "productos"] para
  /// verificar que consultar o proponer un borrador no escribió nada).
  final List<String> dbUnchangedTables;

  /// En modo voz: máximo de oraciones permitidas en la respuesta (Req-09:
  /// máx. 2 frases). null = no se verifica.
  final int? maxSentences;

  /// Nota libre para el reporte si esta expectativa falla.
  final String? note;

  const HarnessExpectation({
    this.toolsAnyOf = const [],
    this.toolsAllOf = const [],
    this.toolsNoneOf = const [],
    this.responseContainsAll = const [],
    this.responseContainsAny = const [],
    this.responseNotContainsAny = const [],
    this.draftExpected,
    this.dbUnchangedTables = const [],
    this.maxSentences,
    this.note,
  });

  factory HarnessExpectation.fromYaml(
    YamlMap? map,
    Map<String, dynamic> groundTruth,
  ) {
    if (map == null) return const HarnessExpectation();
    String tpl(String s) => resolveGroundTruthTemplate(s, groundTruth);
    List<String> strList(String key) =>
        (map[key] as YamlList?)?.map((e) => tpl(e.toString())).toList() ??
        const [];

    return HarnessExpectation(
      toolsAnyOf: strList('tools_any_of'),
      toolsAllOf: strList('tools_all_of'),
      toolsNoneOf: strList('tools_none_of'),
      responseContainsAll: strList('response_contains_all'),
      responseContainsAny: strList('response_contains_any'),
      responseNotContainsAny: strList('response_not_contains_any'),
      draftExpected: map['draft_expected'] as bool?,
      dbUnchangedTables:
          (map['db_unchanged_tables'] as YamlList?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      maxSentences: map['max_sentences'] as int?,
      note: map['note'] as String?,
    );
  }
}

class HarnessTurn {
  /// Mensaje del usuario. Null cuando [confirmDraft] es true (ese turno no
  /// pasa por el LLM).
  final String? user;

  /// true = simula tocar el botón "Confirmar" de la tarjeta del borrador
  /// (DraftEngine.execute directo, el mismo camino que usa la app — NO una
  /// tool del LLM, Req-15). El turno no manda nada al modelo.
  final bool confirmDraft;

  final HarnessExpectation expect;

  const HarnessTurn({
    this.user,
    this.confirmDraft = false,
    required this.expect,
  });

  factory HarnessTurn.fromYaml(
    YamlMap map,
    Map<String, dynamic> groundTruth,
  ) {
    final confirmDraft = map['confirm_draft'] as bool? ?? false;
    final userRaw = map['user'] as String?;
    if (!confirmDraft && userRaw == null) {
      throw StateError(
        'Un turno del escenario debe traer "user" o "confirm_draft: true".',
      );
    }
    return HarnessTurn(
      user: userRaw != null
          ? resolveGroundTruthTemplate(userRaw, groundTruth)
          : null,
      confirmDraft: confirmDraft,
      expect: HarnessExpectation.fromYaml(
        map['expect'] as YamlMap?,
        groundTruth,
      ),
    );
  }
}

class HarnessScenario {
  final String id;
  final String title;
  final String? description;

  /// true = se arma el turno con las reglas de modo voz (máx. 2 frases,
  /// system prompt con voiceMode=true).
  final bool voiceMode;

  final List<HarnessTurn> turns;

  const HarnessScenario({
    required this.id,
    required this.title,
    this.description,
    required this.voiceMode,
    required this.turns,
  });

  factory HarnessScenario.fromYaml(
    String id,
    YamlMap map,
    Map<String, dynamic> groundTruth,
  ) {
    final turnsYaml = map['turns'] as YamlList? ?? YamlList.wrap(const []);
    return HarnessScenario(
      id: id,
      title: map['title'] as String? ?? id,
      description: map['description'] as String?,
      voiceMode: map['voice_mode'] as bool? ?? false,
      turns: [
        for (final t in turnsYaml)
          HarnessTurn.fromYaml(t as YamlMap, groundTruth),
      ],
    );
  }

  static HarnessScenario loadFile(
    File file,
    Map<String, dynamic> groundTruth,
  ) {
    final doc = loadYaml(file.readAsStringSync()) as YamlMap;
    final id = file.uri.pathSegments.last.replaceAll('.yaml', '');
    return HarnessScenario.fromYaml(id, doc, groundTruth);
  }

  static List<HarnessScenario> loadDirectory(
    Directory dir,
    Map<String, dynamic> groundTruth, {
    bool includeScratch = false,
  }) {
    final files =
        dir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.yaml'))
            .where(
              (f) => includeScratch || !f.path.endsWith('scratch.yaml'),
            )
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    return [for (final f in files) loadFile(f, groundTruth)];
  }
}
