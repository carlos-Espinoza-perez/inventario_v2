/// Sustituye placeholders `{{gt:path.to.value}}` dentro de un string por el
/// valor correspondiente del mapa de ground truth (el que devuelve
/// `SecretaryHarnessSeed.computeGroundTruth()`), para que los escenarios
/// YAML puedan referenciar valores calculados en vez de tenerlos
/// hardcodeados.
///
/// El path es notación de punto sobre Maps anidados. No hay índices de
/// lista (`[0]`): los mapas de ground truth ya vienen indexados por clave
/// (`stockTotalPorProducto`, `stockPorVarianteIndex`, `saldosClientes`,
/// `ventasPorMetodoPago`) para que no haga falta.
///
/// Ejemplos:
///   "{{gt:stockTotalPorProducto.prd-base-0}}"
///   "{{gt:stockPorVarianteIndex.prd-jeans-slim|32|harness-bod-central}}"
///   "{{gt:saldosClientes.harness-cli-vencido.saldo}}"
library;

final RegExp _placeholderRe = RegExp(r'\{\{gt:([^}]+)\}\}');

/// Reemplaza todos los placeholders de [text]. Lanza [StateError] con un
/// mensaje claro si algún path no resuelve (mejor fallar temprano al
/// cargar el escenario que silenciosamente comparar contra "null").
String resolveGroundTruthTemplate(
  String text,
  Map<String, dynamic> groundTruth,
) {
  return text.replaceAllMapped(_placeholderRe, (match) {
    final path = match.group(1)!.trim();
    final value = resolveGroundTruthPath(path, groundTruth);
    if (value == null) {
      throw StateError(
        'Ground truth: el path "$path" no resolvió a ningún valor. '
        'Revisá el nombre en el escenario o el shape de computeGroundTruth().',
      );
    }
    return _formatValue(value);
  });
}

/// Resuelve un path de punto (`a.b.c`) contra un Map anidado. Devuelve
/// null si algún segmento no existe (no lanza: quien llama decide si eso
/// es un error).
Object? resolveGroundTruthPath(String path, Map<String, dynamic> root) {
  Object? current = root;
  for (final segment in path.split('.')) {
    if (current is Map) {
      current = current[segment];
    } else {
      return null;
    }
  }
  return current;
}

String _formatValue(Object value) {
  if (value is double) {
    // Sin decimales de sobra ("22.0" -> "22") para que calce con cómo el
    // LLM normalmente escribe cantidades enteras en la respuesta.
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }
  return value.toString();
}
