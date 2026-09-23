import 'package:drift/drift.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:uuid/uuid.dart';

/// Persistencia del chat del secretario sobre Drift (SecretaryDao).
/// El sync a Supabase lo maneja el SyncRepository existente vía syncStatus.
class ChatRepository {
  final AppDatabase _db;

  ChatRepository(this._db);

  /// Crea una sesión con título derivado del primer mensaje.
  Future<ChatSession> createSessionFromMessage(String firstMessage) {
    final words = firstMessage.trim().split(RegExp(r'\s+'));
    var title = words.take(6).join(' ');
    if (words.length > 6) title = '$title…';
    if (title.isEmpty) title = 'Nueva conversación';
    return _db.secretaryDao.createSession(title: title);
  }

  Future<ChatSession?> getSession(String sessionId) =>
      _db.secretaryDao.getSessionById(sessionId);

  Stream<List<ChatSession>> watchSessions(String usuarioId) =>
      _db.secretaryDao.watchSessions(usuarioId: usuarioId);

  Stream<List<ChatMessage>> watchMessages(String sessionId) =>
      _db.secretaryDao.watchMessages(sessionId);

  Future<List<ChatMessage>> getLastMessages(String sessionId, {int limit = 14}) =>
      _db.secretaryDao.getLastMessages(sessionId, limit: limit);

  Future<ChatMessage> appendUserMessage(String sessionId, String content) =>
      _db.secretaryDao.appendMessage(
        sessionId: sessionId,
        role: 'user',
        content: content,
      );

  Future<ChatMessage> appendAssistantMessage(
    String sessionId,
    String content, {
    String contentType = 'text',
    String? draftId,
  }) =>
      _db.secretaryDao.appendMessage(
        sessionId: sessionId,
        role: 'assistant',
        content: content,
        contentType: contentType,
        draftId: draftId,
      );

  Future<AiPreference> getOrCreatePreferences() =>
      _db.secretaryDao.getOrCreatePreferences();

  /// Top de memorias activas para inyectar al prompt (ya vienen ordenadas
  /// por confianza y uso reciente).
  Future<List<AiMemory>> getMemoriesForPrompt({int limit = 12}) async {
    final ctx = await _db.secretaryDao.getRequiredContext();
    return _db.secretaryDao.getActiveMemories(
      empresaId: ctx.empresaId,
      usuarioId: ctx.usuarioId,
      limit: limit,
    );
  }

  Future<void> touchMemoriesUsed(List<String> ids) =>
      _db.secretaryDao.touchMemoriesUsed(ids);

  Future<void> updateSessionMetadata(String sessionId, String metadataJson) =>
      _db.secretaryDao.updateSessionMeta(
        sessionId,
        metadataJson: metadataJson,
      );

  /// Guarda la traza y devuelve su id (referencia corta para soporte).
  Future<String> saveTrace({
    required String sessionId,
    String? messageId,
    String? toolCallsJson,
    String? toolResultsJson,
    String? requestJson,
    String? errorText,
    int? firstAudioMs,
    int? latencyMs,
    int? tokensIn,
    int? tokensOut,
    String? model,
  }) async {
    final id = const Uuid().v4();
    await _db.secretaryDao.insertTrace(
      ChatTurnTracesCompanion.insert(
        id: id,
        sessionId: Value(sessionId),
        messageId: Value(messageId),
        toolCallsJson: Value(toolCallsJson),
        toolResultsJson: Value(toolResultsJson),
        requestJson: Value(requestJson),
        errorText: Value(errorText),
        firstAudioMs: Value(firstAudioMs),
        latencyMs: Value(latencyMs),
        tokensIn: Value(tokensIn),
        tokensOut: Value(tokensOut),
        model: Value(model),
      ),
    );
    return id;
  }
}
