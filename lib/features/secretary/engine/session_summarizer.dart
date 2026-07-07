import 'package:inventario_v2/core/constants/app_constants.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/services/app_logger.dart';

import '../data/llm/secretary_llm_client.dart';
import '../data/llm/secretary_llm_models.dart';

/// Rolling summary: fusiona el resumen previo con los mensajes que van
/// saliendo de la ventana verbatim. Mantiene acotada la entrada por turno en
/// conversaciones largas; retomar una sesión = summary + últimos mensajes.
class SessionSummarizer {
  final AppDatabase _db;
  final SecretaryLlmClient _llm;

  SessionSummarizer(this._db, [SecretaryLlmClient? llm])
      : _llm = llm ?? SecretaryLlmClient();

  /// Regenera el resumen de la sesión (job asíncrono, best-effort).
  Future<void> summarize(String sessionId) async {
    try {
      final session = await _db.secretaryDao.getSessionById(sessionId);
      if (session == null) return;

      final messages =
          await _db.secretaryDao.getLastMessages(sessionId, limit: 24);
      if (messages.length < 8) return;

      final conversation = messages
          .map((m) =>
              '${m.role == 'user' ? 'Usuario' : 'Secretario'}: ${m.content}')
          .join('\n');
      final previo = session.summary?.trim() ?? '';

      final prompt = '''
Eres el módulo de resumen de un asistente de inventario. Fusiona el resumen previo con la conversación reciente en UN resumen actualizado de máximo 250 palabras, en español. Conserva SIEMPRE: productos/clientes/bodegas mencionados, operaciones registradas (entradas/ventas) con sus cantidades, y temas pendientes. Omite saludos y relleno. Responde SOLO el resumen, sin títulos.

RESUMEN PREVIO:
${previo.isEmpty ? '(ninguno)' : previo}

CONVERSACIÓN RECIENTE:
$conversation''';

      final events = _llm.streamChat(
        SecLlmRequest(
          model: AppConstants.openAiModel,
          messages: [SecMessage.system(prompt)],
          temperature: 0,
          maxTokens: 450,
        ),
      );
      SecLlmCompleted? completed;
      await for (final event in events) {
        if (event is SecLlmCompleted) completed = event;
      }
      final summary = completed?.content.trim() ?? '';
      if (summary.isEmpty) return;

      await _db.secretaryDao.updateSessionMeta(sessionId, summary: summary);
      AppLogger.info('[Secretary][Resumen] Sesión $sessionId resumida.');
    } catch (e) {
      AppLogger.warn('[Secretary][Resumen] Falló para $sessionId: $e');
    }
  }
}
