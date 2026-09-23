/// Decide si un press-and-hold de "mantener para hablar" debe descartarse
/// sin enviar nada (SEC-IA-002 punto 1, modo de escucha "pushToTalk").
///
/// Se descarta cuando:
/// - el dedo se deslizó fuera del botón antes de soltar (cancelación), o
/// - se soltó en menos de 400 ms sin haber reconocido texto (toque
///   accidental), o
/// - simplemente no se reconoció nada.
bool shouldDiscardHold({
  required int heldMs,
  required bool slidOutside,
  required String? recognizedText,
}) {
  if (slidOutside) return true;
  final trimmed = recognizedText?.trim() ?? '';
  if (trimmed.isEmpty) return true;
  if (heldMs < 400) return true;
  return false;
}
