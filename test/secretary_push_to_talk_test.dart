import 'package:flutter_test/flutter_test.dart';
import 'package:inventario_v2/features/secretary/voice/push_to_talk.dart';

void main() {
  group('shouldDiscardHold', () {
    test('descarta si se deslizó fuera del botón, aunque haya texto', () {
      expect(
        shouldDiscardHold(
          heldMs: 2000,
          slidOutside: true,
          recognizedText: '12 pantalones a 10',
        ),
        isTrue,
      );
    });

    test('descarta un toque accidental (<400ms) sin texto', () {
      expect(
        shouldDiscardHold(
          heldMs: 150,
          slidOutside: false,
          recognizedText: null,
        ),
        isTrue,
      );
      expect(
        shouldDiscardHold(
          heldMs: 399,
          slidOutside: false,
          recognizedText: '   ',
        ),
        isTrue,
      );
    });

    test('descarta si no se reconoció nada, aunque se mantuvo tiempo', () {
      expect(
        shouldDiscardHold(
          heldMs: 3000,
          slidOutside: false,
          recognizedText: '',
        ),
        isTrue,
      );
    });

    test('envía cuando se sostuvo lo suficiente y hay texto', () {
      expect(
        shouldDiscardHold(
          heldMs: 800,
          slidOutside: false,
          recognizedText: 'cuánto stock hay de gorras',
        ),
        isFalse,
      );
    });

    test('descarta un hold <400ms aunque haya texto (toque accidental)', () {
      // Regla explícita del spec: soltar en menos de 400 ms se descarta
      // siempre, para no disparar un turno por un toque sin querer.
      expect(
        shouldDiscardHold(
          heldMs: 350,
          slidOutside: false,
          recognizedText: 'sí',
        ),
        isTrue,
      );
    });
  });
}
