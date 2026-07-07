import 'package:flutter/material.dart';

/// Convierte el markdown básico que emite el LLM a spans estilizados,
/// sin dependencias externas. Soporta:
/// - `**negrita**` y `*cursiva*` en línea;
/// - viñetas `- ` / `* ` al inicio de línea → "• ";
/// - encabezados `#`..`###` → línea en negrita;
/// - listas numeradas "1. **X**: ..." quedan legibles por los estilos inline.
/// Lo que no matchea se muestra literal (nunca se pierde texto).
TextSpan markdownLite(String text, {TextStyle? style}) {
  final lines = text.split('\n');
  final children = <TextSpan>[];

  for (var i = 0; i < lines.length; i++) {
    var line = lines[i];
    var lineStyle = style;

    final headerMatch = RegExp(r'^\s*#{1,4}\s+(.*)$').firstMatch(line);
    if (headerMatch != null) {
      line = headerMatch.group(1)!;
      lineStyle = (style ?? const TextStyle())
          .copyWith(fontWeight: FontWeight.bold);
    } else {
      final bulletMatch = RegExp(r'^(\s*)[-*]\s+(.*)$').firstMatch(line);
      if (bulletMatch != null) {
        line = '${bulletMatch.group(1)!}• ${bulletMatch.group(2)!}';
      }
    }

    children.addAll(_inlineSpans(line, lineStyle));
    if (i < lines.length - 1) children.add(const TextSpan(text: '\n'));
  }

  // Interlineado levemente mayor para que los párrafos respiren.
  final base = (style ?? const TextStyle()).copyWith(height: 1.35);
  return TextSpan(style: base, children: children);
}

/// Negrita `**...**` y cursiva `*...*` dentro de una línea.
List<TextSpan> _inlineSpans(String line, TextStyle? style) {
  final spans = <TextSpan>[];
  // Negrita primero (comparte delimitador con cursiva); la cursiva exige
  // contenido sin espacios en los bordes para no comerse multiplicaciones.
  final pattern = RegExp(r'\*\*(.+?)\*\*|\*(?!\s)([^*]+?)(?<!\s)\*');
  var index = 0;

  for (final match in pattern.allMatches(line)) {
    if (match.start > index) {
      spans.add(
        TextSpan(text: line.substring(index, match.start), style: style),
      );
    }
    if (match.group(1) != null) {
      spans.add(TextSpan(
        text: match.group(1),
        style: (style ?? const TextStyle())
            .copyWith(fontWeight: FontWeight.bold),
      ));
    } else {
      spans.add(TextSpan(
        text: match.group(2),
        style: (style ?? const TextStyle())
            .copyWith(fontStyle: FontStyle.italic),
      ));
    }
    index = match.end;
  }
  if (index < line.length) {
    spans.add(TextSpan(text: line.substring(index), style: style));
  }
  return spans;
}
