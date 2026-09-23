import 'dart:convert';

import 'package:inventario_v2/core/constants/app_constants.dart';
import 'package:inventario_v2/core/services/app_logger.dart';

import '../data/llm/secretary_llm_client.dart';
import '../data/llm/secretary_llm_models.dart';
import '../drafts/draft_engine.dart';

/// Vía lenta del dictado: los segmentos que el parser local no entendió se
/// mandan al LLM en una llamada mínima (sin tools, sin historial) que
/// devuelve solo JSON con los ítems extraídos.
class DictationFallback {
  final SecretaryLlmClient _llm;

  DictationFallback([SecretaryLlmClient? llm])
      : _llm = llm ?? SecretaryLlmClient();

  /// Extrae ítems de un segmento dictado. Lista vacía si no se entendió.
  Future<List<RawDraftItem>> extractItems(
    String segment, {
    required bool esVenta,
  }) async {
    final montoCampo = esVenta ? 'precioUnitario' : 'costoUnitario';
    final prompt = '''
Extrae los productos de este dictado de ${esVenta ? 'venta' : 'entrada de inventario'} en español.
Responde SOLO un array JSON (sin markdown ni texto extra) con objetos:
{"nombre": string, "cantidad": number, "costoUnitario": number opcional, "precioUnitario": number opcional}
Si dice "a X" o "en X" el monto es $montoCampo. Si no hay productos responde [].
Si el usuario se corrige dentro de la frase (ej. "no", "perdón", "digo",
"corrijo", "mejor dicho" seguido de un nuevo valor), usa SOLO el último
valor dicho para ese campo, ignorá el anterior.

Dictado: "$segment"''';

    try {
      final events = _llm.streamChat(
        SecLlmRequest(
          model: AppConstants.openAiModel,
          messages: [SecMessage.system(prompt)],
          temperature: 0,
          maxTokens: 300,
        ),
      );
      SecLlmCompleted? completed;
      await for (final event in events) {
        if (event is SecLlmCompleted) completed = event;
      }
      final content = completed?.content.trim() ?? '';
      if (content.isEmpty) return const [];

      // Tolerar que el modelo envuelva el JSON en ```.
      final jsonText = content
          .replaceAll(RegExp(r'^```(json)?', multiLine: true), '')
          .replaceAll('```', '')
          .trim();
      final decoded = jsonDecode(jsonText);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((m) => RawDraftItem.fromJson(Map<String, dynamic>.from(m)))
          .where((i) => i.nombre.trim().isNotEmpty && i.cantidad > 0)
          .toList();
    } catch (e) {
      AppLogger.warn('[Secretary][Dictado] Fallback LLM falló: $e');
      return const [];
    }
  }
}
