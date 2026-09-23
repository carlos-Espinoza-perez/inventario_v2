import 'package:flutter_test/flutter_test.dart';

import 'ground_truth_template.dart';

void main() {
  final groundTruth = <String, dynamic>{
    'stockTotalPorProducto': {'prd-1': 22.0, 'prd-2': 0.0},
    'stockPorVarianteIndex': {'prd-1|M|bod-central': 7.0},
    'saldosClientes': {
      'cli-1': {'nombre': 'Ana', 'saldo': 45.0, 'vencido': 0.0},
    },
    'ventasHoy': {'cantidad': 4, 'total': 215.0},
  };

  group('resolveGroundTruthPath', () {
    test('resuelve un path simple', () {
      expect(
        resolveGroundTruthPath('stockTotalPorProducto.prd-1', groundTruth),
        22.0,
      );
    });

    test('resuelve una clave compuesta con pipes', () {
      expect(
        resolveGroundTruthPath(
          'stockPorVarianteIndex.prd-1|M|bod-central',
          groundTruth,
        ),
        7.0,
      );
    });

    test('resuelve un path anidado de 2 niveles', () {
      expect(
        resolveGroundTruthPath('saldosClientes.cli-1.saldo', groundTruth),
        45.0,
      );
    });

    test('path inexistente devuelve null', () {
      expect(
        resolveGroundTruthPath('stockTotalPorProducto.prd-999', groundTruth),
        isNull,
      );
    });
  });

  group('resolveGroundTruthTemplate', () {
    test('sustituye un placeholder por el valor formateado', () {
      expect(
        resolveGroundTruthTemplate(
          'Hay {{gt:stockTotalPorProducto.prd-1}} unidades',
          groundTruth,
        ),
        'Hay 22 unidades',
      );
    });

    test('sustituye varios placeholders en el mismo texto', () {
      expect(
        resolveGroundTruthTemplate(
          '{{gt:ventasHoy.cantidad}} ventas por {{gt:ventasHoy.total}}',
          groundTruth,
        ),
        '4 ventas por 215',
      );
    });

    test('texto sin placeholders queda igual', () {
      expect(
        resolveGroundTruthTemplate('texto normal sin nada', groundTruth),
        'texto normal sin nada',
      );
    });

    test('placeholder que no resuelve lanza StateError', () {
      expect(
        () => resolveGroundTruthTemplate(
          '{{gt:no.existe}}',
          groundTruth,
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
