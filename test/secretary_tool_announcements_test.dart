import 'package:flutter_test/flutter_test.dart';
import 'package:inventario_v2/features/secretary/voice/tool_announcements.dart';

void main() {
  group('toolAnnouncementFor', () {
    test('entity_resolver.*', () {
      expect(
        toolAnnouncementFor('entity_resolver.resolveProduct'),
        'Buscando el producto…',
      );
    });

    test('inventory.*', () {
      expect(
        toolAnnouncementFor('inventory.getStockPorBodega'),
        'Revisando el stock…',
      );
    });

    test('sales.*', () {
      expect(
        toolAnnouncementFor('sales.getVentasDelDia'),
        'Consultando ventas y caja…',
      );
    });

    test('draft.*', () {
      expect(toolAnnouncementFor('draft.addItems'), 'Actualizando el borrador…');
    });

    test('tool desconocida cae al genérico', () {
      expect(toolAnnouncementFor('otra_cosa.algo'), 'Consultando…');
    });
  });
}
