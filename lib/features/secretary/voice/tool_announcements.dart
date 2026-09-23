/// Frase corta local (sin llamada al LLM) para el acuse hablado inmediato
/// cuando el motor detecta que el modelo llamó una herramienta en modo voz
/// (SEC-IA-002 punto 5, preferencia "Aviso al consultar").
///
/// [toolId] llega tal como lo usa el registry (ej. `inventory.getStockPorBodega`,
/// `sales.getVentasDelDia`, `draft.addItems`). Se agrupa por el prefijo antes
/// del punto.
String toolAnnouncementFor(String toolId) {
  final group = toolId.split('.').first;
  return switch (group) {
    'entity_resolver' => 'Buscando el producto…',
    'inventory' => 'Revisando el stock…',
    'sales' => 'Consultando ventas y caja…',
    'draft' => 'Actualizando el borrador…',
    _ => 'Consultando…',
  };
}
