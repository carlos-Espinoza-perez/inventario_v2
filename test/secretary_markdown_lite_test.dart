import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario_v2/features/secretary/presentation/widgets/markdown_lite.dart';

String _plainText(TextSpan span) {
  final buffer = StringBuffer();
  span.visitChildren((child) {
    if (child is TextSpan && child.text != null) buffer.write(child.text);
    return true;
  });
  return buffer.toString();
}

List<TextSpan> _boldSpans(TextSpan span) {
  final result = <TextSpan>[];
  span.visitChildren((child) {
    if (child is TextSpan &&
        child.style?.fontWeight == FontWeight.bold &&
        child.text != null) {
      result.add(child);
    }
    return true;
  });
  return result;
}

void main() {
  test('negrita **texto** se renderiza sin asteriscos', () {
    final span = markdownLite('1. **Productos**: nombres y cantidades.');
    expect(_plainText(span), '1. Productos: nombres y cantidades.');
    expect(_boldSpans(span).single.text, 'Productos');
  });

  test('viñetas - y * se convierten a •', () {
    final span = markdownLite('- primera\n* segunda');
    expect(_plainText(span), '• primera\n• segunda');
  });

  test('encabezado ## queda en negrita sin #', () {
    final span = markdownLite('## Resumen');
    expect(_plainText(span), 'Resumen');
    expect(_boldSpans(span).single.text, 'Resumen');
  });

  test('asteriscos sueltos (multiplicación) quedan literales', () {
    final span = markdownLite('total = 3 * 4 * 2');
    expect(_plainText(span), 'total = 3 * 4 * 2');
    expect(_boldSpans(span), isEmpty);
  });

  test('texto plano con párrafos se preserva', () {
    const texto = 'Hola.\n\nSegundo párrafo.';
    expect(_plainText(markdownLite(texto)), texto);
  });
}
