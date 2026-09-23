import 'package:flutter_test/flutter_test.dart';
import 'package:inventario_v2/features/secretary/data/entity_resolver.dart';

void main() {
  group('EntityResolver.normalizeSpokenQuery', () {
    test('letras deletreadas pegadas: "eme seis" → "m6"', () {
      expect(EntityResolver.normalizeSpokenQuery('eme seis'), 'm6');
    });

    test('letras deletreadas pegadas: "equis ele" → "xl"', () {
      expect(EntityResolver.normalizeSpokenQuery('equis ele'), 'xl');
    });

    test('letra suelta tras palabra "cue": "talla ese" → "talla s"', () {
      expect(EntityResolver.normalizeSpokenQuery('talla ese'), 'talla s');
    });

    test('número en palabras dentro de frase: "camisa talla seis"', () {
      expect(
        EntityResolver.normalizeSpokenQuery('camisa talla seis'),
        'camisa talla 6',
      );
    });

    test('código dentro de frase: "pantalon eme seis azul"', () {
      expect(
        EntityResolver.normalizeSpokenQuery('pantalon eme seis azul'),
        'pantalon m6 azul',
      );
    });

    test('tildes y mayúsculas se normalizan', () {
      expect(
        EntityResolver.normalizeSpokenQuery('PANTALÓN Número Ocho'),
        'pantalon numero 8',
      );
    });

    test('no convierte letras sueltas ambiguas sin contexto', () {
      // "ese" aislado, sin "talla"/"modelo" antes ni otro token código al
      // lado, se deja tal cual: es indistinguible de la palabra "ese".
      expect(
        EntityResolver.normalizeSpokenQuery('quiero ese producto'),
        'quiero ese producto',
      );
    });

    test('no rompe preposiciones comunes ("de")', () {
      expect(
        EntityResolver.normalizeSpokenQuery('gorra de futbol'),
        'gorra de futbol',
      );
    });

    test('no convierte artículos ("un", "una")', () {
      expect(
        EntityResolver.normalizeSpokenQuery('quiero un producto'),
        'quiero un producto',
      );
    });

    test('texto vacío devuelve vacío', () {
      expect(EntityResolver.normalizeSpokenQuery(''), '');
      expect(EntityResolver.normalizeSpokenQuery('   '), '');
    });

    test('dígitos ya numéricos se mantienen y se pegan a letras vecinas', () {
      expect(EntityResolver.normalizeSpokenQuery('eme 6'), 'm6');
    });
  });
}
