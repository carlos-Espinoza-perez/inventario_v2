import 'package:flutter_test/flutter_test.dart';
import 'package:inventario_v2/features/secretary/voice/voice_confirmation.dart';

void main() {
  group('VoiceConfirmationMatcher.isConfirmation', () {
    test('acepta formas exactas conocidas', () {
      expect(VoiceConfirmationMatcher.isConfirmation('confirmar'), isTrue);
      expect(VoiceConfirmationMatcher.isConfirmation('Confirmo'), isTrue);
      expect(VoiceConfirmationMatcher.isConfirmation('sí'), isTrue);
      expect(VoiceConfirmationMatcher.isConfirmation('Sí, confirma'), isTrue);
      expect(VoiceConfirmationMatcher.isConfirmation('si confirma'), isTrue);
    });

    test('rechaza cuando trae algo más además del "sí"', () {
      expect(
        VoiceConfirmationMatcher.isConfirmation('sí pero cambia el precio'),
        isFalse,
      );
      expect(
        VoiceConfirmationMatcher.isConfirmation('sí, espera un momento'),
        isFalse,
      );
      expect(
        VoiceConfirmationMatcher.isConfirmation('creo que sí'),
        isFalse,
      );
    });

    test('rechaza frases libres no relacionadas', () {
      expect(
        VoiceConfirmationMatcher.isConfirmation('cuánto stock hay de gorras'),
        isFalse,
      );
    });
  });

  group('VoiceConfirmationMatcher.isRejection', () {
    test('acepta formas exactas conocidas', () {
      expect(VoiceConfirmationMatcher.isRejection('no'), isTrue);
      expect(VoiceConfirmationMatcher.isRejection('Cancela'), isTrue);
      expect(VoiceConfirmationMatcher.isRejection('cancelar'), isTrue);
    });

    test('rechaza frases con más texto', () {
      expect(
        VoiceConfirmationMatcher.isRejection('no, espera un momento'),
        isFalse,
      );
    });
  });

  group('VoiceConfirmationMatcher.parseChoice', () {
    test('números y ordinales 1 a 5', () {
      expect(VoiceConfirmationMatcher.parseChoice('el uno'), 1);
      expect(VoiceConfirmationMatcher.parseChoice('primero'), 1);
      expect(VoiceConfirmationMatcher.parseChoice('el segundo'), 2);
      expect(VoiceConfirmationMatcher.parseChoice('tres'), 3);
      expect(VoiceConfirmationMatcher.parseChoice('la cuarta'), 4);
      expect(VoiceConfirmationMatcher.parseChoice('quinto'), 5);
    });

    test('frase que no es una elección devuelve null', () {
      expect(VoiceConfirmationMatcher.parseChoice('confirmar'), isNull);
      expect(
        VoiceConfirmationMatcher.parseChoice('el segundo por favor'),
        isNull,
      );
    });
  });
}
