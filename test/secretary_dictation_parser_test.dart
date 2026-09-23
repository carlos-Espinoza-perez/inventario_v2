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

  group('DictationParser.parseLine — autocorrecciones', () {
    test('corrige la cantidad: "15... no, 50 tornillos"', () {
      final line = DictationParser.parseLine(
        '15 tornillos no 50 tornillos',
        esVenta: false,
      );
      expect(line, isNotNull);
      expect(line!.cantidad, 50);
      expect(line.nombre, 'tornillos');
    });

    test('corrige la cantidad con coma: "15, no, 50 tornillos"', () {
      final line = DictationParser.parseLine(
        '15 tornillos, no, 50 tornillos',
        esVenta: false,
      );
      expect(line!.cantidad, 50);
      expect(line.nombre, 'tornillos');
    });

    test('corrige el precio: "a 10 dólares, digo 12"', () {
      final line = DictationParser.parseLine(
        'dos camisas a 10 dolares digo 12',
        esVenta: false,
      );
      expect(line!.cantidad, 2);
      expect(line.nombre, 'camisas');
      expect(line.costo, 12);
    });

    test('corrige el precio en venta con "perdón"', () {
      final line = DictationParser.parseLine(
        'tres gorras a 15 perdon 18',
        esVenta: true,
      );
      expect(line!.precio, 18);
      expect(line.cantidad, 3);
      expect(line.nombre, 'gorras');
    });

    test('corrige con "mejor dicho"', () {
      final line = DictationParser.parseLine(
        'cinco cajas a 20 mejor dicho 25',
        esVenta: false,
      );
      expect(line!.costo, 25);
      expect(line.nombre, 'cajas');
    });

    test('corrige el precio explícito con "corrijo"', () {
      final line = DictationParser.parseLine(
        'tres cajas de gorras costo 5 precio 12 corrijo 15',
        esVenta: false,
      );
      expect(line!.costo, 5);
      expect(line.precio, 15);
      expect(line.nombre, 'cajas de gorras');
    });

    test('corrige cantidad en palabras: "doce no veinte camisas"', () {
      final line = DictationParser.parseLine(
        'doce camisas no veinte camisas',
        esVenta: false,
      );
      expect(line!.cantidad, 20);
      expect(line.nombre, 'camisas');
    });

    test('sin marcador de corrección: comportamiento normal', () {
      final line = DictationParser.parseLine(
        '12 pantalones a 10',
        esVenta: false,
      );
      expect(line!.cantidad, 12);
      expect(line.costo, 10);
    });

    test('"digo" corrige decimales hablados', () {
      final line = DictationParser.parseLine(
        'dos camisas a 5 digo dos con cincuenta',
        esVenta: false,
      );
      expect(line!.costo, 2.5);
    });

    test('corrección de cantidad sin cláusula de monto ni nombre repetido',
        () {
      final line = DictationParser.parseLine(
        'quince tornillos no cincuenta',
        esVenta: false,
      );
      expect(line!.cantidad, 50);
      expect(line.nombre, 'tornillos');
    });

    // --- Falsos positivos: NO deben disparar una corrección ---

    test('falso positivo: "no" dentro de "nogales"', () {
      final line = DictationParser.parseLine(
        'tres nogales a 10',
        esVenta: false,
      );
      expect(line, isNotNull);
      expect(line!.cantidad, 3);
      expect(line.nombre, 'nogales');
      expect(line.costo, 10);
    });

    test('falso positivo: "no" dentro de "notas"', () {
      final line = DictationParser.parseLine(
        'cinco notas a 3',
        esVenta: false,
      );
      expect(line, isNotNull);
      expect(line!.cantidad, 5);
      expect(line.nombre, 'notas');
      expect(line.costo, 3);
    });

    test('falso positivo: "no hay" no es corrección', () {
      final line = DictationParser.parseLine(
        'veinte cuadernos no hay mas',
        esVenta: false,
      );
      // "hay" no es un valor numérico: el marcador se ignora y la cantidad
      // original (20) se mantiene intacta.
      expect(line, isNotNull);
      expect(line!.cantidad, 20);
    });
  });

  group('DictationParser.parseCorrectLastCommand', () {
    test('con campo explícito "cantidad"', () {
      final c = DictationParser.parseCorrectLastCommand(
        'corrige lo último cantidad a 20',
        esVenta: false,
      );
      expect(c, isNotNull);
      expect(c!.field, DictationCorrectionField.cantidad);
      expect(c.value, 20);
    });

    test('con campo explícito "precio"', () {
      final c = DictationParser.parseCorrectLastCommand(
        'cambia lo último precio a 15',
        esVenta: true,
      );
      expect(c!.field, DictationCorrectionField.precio);
      expect(c.value, 15);
    });

    test('sin campo explícito usa costo en entrada', () {
      final c = DictationParser.parseCorrectLastCommand(
        'corrige lo último a 8',
        esVenta: false,
      );
      expect(c!.field, DictationCorrectionField.costo);
      expect(c.value, 8);
    });

    test('sin campo explícito usa precio en venta', () {
      final c = DictationParser.parseCorrectLastCommand(
        'corrige el último a 8',
        esVenta: true,
      );
      expect(c!.field, DictationCorrectionField.precio);
      expect(c.value, 8);
    });

    test('frase que no matchea devuelve null', () {
      expect(
        DictationParser.parseCorrectLastCommand(
          '12 pantalones a 10',
          esVenta: false,
        ),
        isNull,
      );
    });
  });
}
