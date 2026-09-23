import 'package:flutter_test/flutter_test.dart';

import 'scenario.dart';
import 'turn_verifier.dart';

void main() {
  group('verifyTurn — tools', () {
    test('tools_any_of pasa si al menos una se llamó', () {
      final failures = verifyTurn(
        const HarnessExpectation(
          toolsAnyOf: ['inventory.getStockPorBodega', 'inventory.getPrecioProducto'],
        ),
        const HarnessTurnResult(
          responseText: 'Hay 22 unidades.',
          toolIds: ['entity_resolver.resolveProduct', 'inventory.getStockPorBodega'],
          draftActive: false,
        ),
      );
      expect(failures, isEmpty);
    });

    test('tools_any_of falla si ninguna se llamó', () {
      final failures = verifyTurn(
        const HarnessExpectation(toolsAnyOf: ['inventory.getStockPorBodega']),
        const HarnessTurnResult(
          responseText: 'No sé.',
          toolIds: ['entity_resolver.resolveProduct'],
          draftActive: false,
        ),
      );
      expect(failures, isNotEmpty);
    });

    test('tools_all_of falla si falta una', () {
      final failures = verifyTurn(
        const HarnessExpectation(
          toolsAllOf: ['entity_resolver.resolveProduct', 'inventory.getStockPorBodega'],
        ),
        const HarnessTurnResult(
          responseText: 'Hay 22.',
          toolIds: ['entity_resolver.resolveProduct'],
          draftActive: false,
        ),
      );
      expect(failures, hasLength(1));
    });

    test('tools_none_of falla si se llamó una prohibida', () {
      final failures = verifyTurn(
        const HarnessExpectation(toolsNoneOf: ['draft.create']),
        const HarnessTurnResult(
          responseText: 'Listo.',
          toolIds: ['draft.create'],
          draftActive: true,
        ),
      );
      expect(failures, hasLength(1));
    });
  });

  group('verifyTurn — texto de la respuesta', () {
    test('response_contains_all: falla si falta uno', () {
      final failures = verifyTurn(
        const HarnessExpectation(responseContainsAll: ['22', 'central']),
        const HarnessTurnResult(
          responseText: 'Hay 22 unidades en la bodega sur.',
          toolIds: [],
          draftActive: false,
        ),
      );
      expect(failures, hasLength(1));
    });

    test('response_not_contains_any: detecta un número inventado', () {
      final failures = verifyTurn(
        const HarnessExpectation(responseNotContainsAny: ['100']),
        const HarnessTurnResult(
          responseText: 'Hay 100 unidades.',
          toolIds: [],
          draftActive: false,
        ),
      );
      expect(failures, hasLength(1));
    });

    test('es case-insensitive', () {
      final failures = verifyTurn(
        const HarnessExpectation(responseContainsAll: ['NO ENCONTRÉ']),
        const HarnessTurnResult(
          responseText: 'no encontré ese producto en el catálogo.',
          toolIds: [],
          draftActive: false,
        ),
      );
      expect(failures, isEmpty);
    });
  });

  group('verifyTurn — borrador', () {
    test('draft_expected true falla si no hay borrador', () {
      final failures = verifyTurn(
        const HarnessExpectation(draftExpected: true),
        const HarnessTurnResult(
          responseText: 'ok',
          toolIds: [],
          draftActive: false,
        ),
      );
      expect(failures, hasLength(1));
    });

    test('draft_expected false falla si SÍ hay borrador', () {
      final failures = verifyTurn(
        const HarnessExpectation(draftExpected: false),
        const HarnessTurnResult(
          responseText: 'ok',
          toolIds: [],
          draftActive: true,
        ),
      );
      expect(failures, hasLength(1));
    });

    test('null no verifica nada', () {
      final failures = verifyTurn(
        const HarnessExpectation(),
        const HarnessTurnResult(
          responseText: 'ok',
          toolIds: [],
          draftActive: true,
        ),
      );
      expect(failures, isEmpty);
    });
  });

  group('verifyTurn — modo voz (max_sentences)', () {
    test('pasa con 2 oraciones y max_sentences=2', () {
      final failures = verifyTurn(
        const HarnessExpectation(maxSentences: 2),
        const HarnessTurnResult(
          responseText: 'Hay 22 unidades. ¿Querés que revise otra bodega?',
          toolIds: [],
          draftActive: false,
        ),
      );
      expect(failures, isEmpty);
    });

    test('falla con 3 oraciones y max_sentences=2', () {
      final failures = verifyTurn(
        const HarnessExpectation(maxSentences: 2),
        const HarnessTurnResult(
          responseText: 'Hay 22 unidades. Están en bodega central. '
              '¿Necesitás algo más?',
          toolIds: [],
          draftActive: false,
        ),
      );
      expect(failures, hasLength(1));
    });
  });

  test('sin expectativas, siempre pasa', () {
    final failures = verifyTurn(
      const HarnessExpectation(),
      const HarnessTurnResult(
        responseText: 'cualquier cosa',
        toolIds: ['algo'],
        draftActive: true,
      ),
    );
    expect(failures, isEmpty);
  });
}
