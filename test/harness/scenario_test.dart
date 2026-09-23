import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import 'scenario.dart';

void main() {
  final groundTruth = <String, dynamic>{
    'stockTotalPorProducto': {'prd-1': 22.0},
  };

  const yamlText = '''
title: "Escenario de prueba"
description: "Solo para testear el loader"
voice_mode: true
turns:
  - user: "¿Cuánto stock hay de la camisa?"
    expect:
      tools_any_of: ["inventory.getStockPorBodega"]
      tools_all_of: ["entity_resolver.resolveProduct"]
      tools_none_of: ["draft.create"]
      response_contains_all: ["{{gt:stockTotalPorProducto.prd-1}}"]
      response_not_contains_any: ["100"]
      draft_expected: false
      db_unchanged_tables: ["inventarios"]
      max_sentences: 2
      note: "nota de prueba"
  - user: "gracias"
    expect: {}
''';

  test('parsea un escenario completo desde YAML', () {
    final doc = loadYaml(yamlText) as YamlMap;
    final scenario = HarnessScenario.fromYaml('escenario_test', doc, groundTruth);

    expect(scenario.id, 'escenario_test');
    expect(scenario.title, 'Escenario de prueba');
    expect(scenario.voiceMode, isTrue);
    expect(scenario.turns, hasLength(2));

    final t1 = scenario.turns.first;
    expect(t1.user, '¿Cuánto stock hay de la camisa?');
    expect(t1.expect.toolsAnyOf, ['inventory.getStockPorBodega']);
    expect(t1.expect.toolsAllOf, ['entity_resolver.resolveProduct']);
    expect(t1.expect.toolsNoneOf, ['draft.create']);
    // El placeholder de ground truth se resolvió al cargar.
    expect(t1.expect.responseContainsAll, ['22']);
    expect(t1.expect.responseNotContainsAny, ['100']);
    expect(t1.expect.draftExpected, isFalse);
    expect(t1.expect.dbUnchangedTables, ['inventarios']);
    expect(t1.expect.maxSentences, 2);
    expect(t1.expect.note, 'nota de prueba');

    final t2 = scenario.turns.last;
    expect(t2.user, 'gracias');
    expect(t2.expect.toolsAnyOf, isEmpty);
  });

  test('título por defecto es el id si falta "title"', () {
    final doc = loadYaml('turns: []') as YamlMap;
    final scenario = HarnessScenario.fromYaml('sin_titulo', doc, groundTruth);
    expect(scenario.title, 'sin_titulo');
    expect(scenario.voiceMode, isFalse);
    expect(scenario.turns, isEmpty);
  });
}
