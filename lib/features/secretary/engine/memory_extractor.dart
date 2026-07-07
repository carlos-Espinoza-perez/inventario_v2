import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:inventario_v2/core/constants/app_constants.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/services/app_logger.dart';
import 'package:uuid/uuid.dart';

import '../data/llm/secretary_llm_client.dart';
import '../data/llm/secretary_llm_models.dart';

/// Extrae hechos de largo plazo de la conversación (job asíncrono, nunca
/// bloquea un turno). El dedupe lo hace el propio LLM: recibe las memorias
/// existentes y puede marcar `supersedesId` cuando un hecho actualiza a otro.
class MemoryExtractor {
  final AppDatabase _db;
  final SecretaryLlmClient _llm;

  MemoryExtractor(this._db, [SecretaryLlmClient? llm])
      : _llm = llm ?? SecretaryLlmClient();

  /// Analiza los últimos mensajes de la sesión y persiste memorias nuevas.
  Future<void> extractFromSession(String sessionId) async {
    try {
      final ctx = await _db.secretaryDao.getRequiredContext();
      final messages =
          await _db.secretaryDao.getLastMessages(sessionId, limit: 16);
      // Solo turnos de texto reales; sin suficiente material no hay nada
      // que aprender.
      final turns = messages.where((m) => m.content.trim().isNotEmpty).toList();
      if (turns.length < 4) return;

      final existing = await _db.secretaryDao.getActiveMemories(
        empresaId: ctx.empresaId,
        usuarioId: ctx.usuarioId,
      );

      final conversation = turns
          .map((m) => '${m.role == 'user' ? 'Usuario' : 'Secretario'}: ${m.content}')
          .join('\n');
      final existingList = existing
          .map((m) => '{"id": "${m.id}", "content": ${jsonEncode(m.content)}}')
          .join(',\n');

      final prompt = '''
Eres el módulo de memoria de un asistente de inventario. Analiza la conversación y extrae SOLO hechos duraderos sobre el usuario o su negocio que sirvan en futuras conversaciones (preferencias, reglas de trabajo, datos del negocio, correcciones). NO extraigas datos puntuales de una transacción (cantidades, ventas del día) ni nada ya cubierto por una memoria existente idéntica.

MEMORIAS EXISTENTES:
[$existingList]

CONVERSACIÓN:
$conversation

Responde SOLO un array JSON (sin markdown) con 0 a 3 objetos:
{"content": "hecho en una frase", "scope": "user"|"business", "category": "preference"|"fact"|"rule"|"correction", "confidence": 0.5-1.0, "supersedesId": "id de memoria existente que este hecho reemplaza, u omitir"}
Si no hay hechos nuevos responde [].''';

      final events = _llm.streamChat(
        SecLlmRequest(
          model: AppConstants.openAiModel,
          messages: [SecMessage.system(prompt)],
          temperature: 0,
          maxTokens: 400,
        ),
      );
      SecLlmCompleted? completed;
      await for (final event in events) {
        if (event is SecLlmCompleted) completed = event;
      }
      final content = completed?.content.trim() ?? '';
      if (content.isEmpty) return;

      final jsonText = content
          .replaceAll(RegExp(r'^```(json)?', multiLine: true), '')
          .replaceAll('```', '')
          .trim();
      final decoded = jsonDecode(jsonText);
      if (decoded is! List) return;

      for (final raw in decoded.whereType<Map>()) {
        final memContent = raw['content']?.toString().trim() ?? '';
        if (memContent.isEmpty) continue;

        final supersedesId = raw['supersedesId']?.toString();
        if (supersedesId != null && supersedesId.isNotEmpty) {
          await _db.secretaryDao.deactivateMemory(supersedesId);
        }

        await _db.secretaryDao.upsertMemory(
          AiMemoriesCompanion.insert(
            id: const Uuid().v4(),
            empresaId: ctx.empresaId,
            usuarioId: ctx.usuarioId,
            scope: Value(
              raw['scope'] == 'business' ? 'business' : 'user',
            ),
            category: switch (raw['category']?.toString()) {
              'preference' => 'preference',
              'rule' => 'rule',
              'correction' => 'correction',
              _ => 'fact',
            },
            content: memContent,
            sourceSessionId: Value(sessionId),
            confidence: Value(
              ((raw['confidence'] as num?)?.toDouble() ?? 0.8).clamp(0.0, 1.0),
            ),
          ),
        );
      }
      AppLogger.info(
        '[Secretary][Memoria] Extracción de $sessionId: ${decoded.length} hechos',
      );
    } catch (e) {
      // Best-effort: si falla se reintenta en el próximo disparo.
      AppLogger.warn('[Secretary][Memoria] Extracción falló: $e');
    }
  }
}
