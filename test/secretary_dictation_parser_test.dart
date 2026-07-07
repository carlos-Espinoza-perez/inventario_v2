import 'package:flutter_test/flutter_test.dart';
import 'package:inventario_v2/features/secretary/voice/dictation_parser.dart';

void main() {
  group('DictationParser.parseLine — entrada (a X = costo)', () {
    test('dígitos con precio corto', () {
      final line = DictationParser.parseLine(
        '12 pantalones a 10 dólares',
        esVenta: false,
      );
      expect(line, isNotNull);
      expect(line!.nombre, 'pantalones');
      expect(line.cantidad, 12);
      expect(line.costo, 10);
      expect(line.precio, isNull);
    });

    test('números en palabras', () {
      final line = DictationParser.parseLine(
        'doce gorras a diez',
        esVenta: false,
      );
      expect(line!.cantidad, 12);
      expect(line.nombre, 'gorras');
      expect(line.costo, 10);
    });

    test('decenas compuestas', () {
      final line = DictationParser.parseLine(
        'treinta y cinco camisas a veinticinco',
        esVenta: false,
      );
      expect(line!.cantidad, 35);
      expect(line.nombre, 'camisas');
      expect(line.costo, 25);
    });

    test('costo y precio explícitos', () {
      final line = DictationParser.parseLine(
        'tres cajas de gorras costo 5 precio 12',
        esVenta: false,
      );
      expect(line!.cantidad, 3);
      expect(line.nombre, 'cajas de gorras');
      expect(line.costo, 5);
      expect(line.precio, 12);
    });

    test('decimales hablados "con"', () {
      final line = DictationParser.parseLine(
        'dos camisas a dos con cincuenta',
        esVenta: false,
      );
      expect(line!.costo, 2.5);
    });

    test('decimales con dígitos', () {
      final line = DictationParser.parseLine(
        '5 gorras a 10.50',
        esVenta: false,
      );
      expect(line!.costo, 10.5);
    });

    test('docena', () {
      final line = DictationParser.parseLine(
        'una docena de huevos a 3',
        esVenta: false,
      );
      expect(line!.cantidad, 12);
      expect(line.nombre, 'huevos');
    });

    test('sin precio', () {
      final line = DictationParser.parseLine(
        'veinte cuadernos',
        esVenta: false,
      );
      expect(line!.cantidad, 20);
      expect(line.nombre, 'cuadernos');
      expect(line.costo, isNull);
      expect(line.precio, isNull);
    });
  });

  group('DictationParser.parseLine — venta (a X = precio)', () {
    test('el monto corto va a precio', () {
      final line = DictationParser.parseLine(
        '2 gorras a 15',
        esVenta: true,
      );
      expect(line!.precio, 15);
      expect(line.costo, isNull);
    });
  });

  group('DictationParser.parseLine — casos que caen al fallback', () {
    test('sin cantidad inicial', () {
      expect(
        DictationParser.parseLine('pantalones azules a 10', esVenta: false),
        isNull,
      );
    });

    test('dos ítems en una frase', () {
      expect(
        DictationParser.parseLine(
          '12 pantalones a 10 y 5 camisas a 20',
          esVenta: false,
        ),
        isNull,
      );
    });

    test('frase libre', () {
      expect(
        DictationParser.parseLine(
          'agregame también lo de ayer',
          esVenta: false,
        ),
        isNull,
      );
    });
  });

  group('DictationParser.parseCommand', () {
    test('finalizar', () {
      expect(DictationParser.parseCommand('listo'), DictationCommand.finish);
      expect(DictationParser.parseCommand('Ya está'), DictationCommand.finish);
      expect(
        DictationParser.parseCommand('eso es todo'),
        DictationCommand.finish,
      );
    });

    test('borrar último', () {
      expect(
        DictationParser.parseCommand('borra el último'),
        DictationCommand.undoLast,
      );
      expect(
        DictationParser.parseCommand('elimina lo último'),
        DictationCommand.undoLast,
      );
    });

    test('cancelar todo', () {
      expect(
        DictationParser.parseCommand('cancela todo'),
        DictationCommand.cancelAll,
      );
      expect(
        DictationParser.parseCommand('cancelar el dictado'),
        DictationCommand.cancelAll,
      );
    });

    test('una línea de ítem no es comando', () {
      expect(
        DictationParser.parseCommand('12 pantalones a 10'),
        isNull,
      );
    });
  });
}
