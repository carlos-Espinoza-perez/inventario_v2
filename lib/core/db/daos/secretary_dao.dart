import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables/secretary_tables.dart';
import 'base_dao.dart';

part 'secretary_dao.g.dart';

@DriftAccessor(
  tables: [
    ChatSessions,
    ChatMessages,
    AiMemories,
    AiPreferences,
    ChatTurnTraces,
    SecretaryDrafts,
    SecretaryDraftItems,
  ],
)
class SecretaryDao extends BaseDao with _$SecretaryDaoMixin {
  SecretaryDao(super.db);

  Expression<bool> _isPending(GeneratedColumn<String> column) {
    return column.equals('pending_insert') |
        column.equals('pending_update') |
        column.equals('sync_error');
  }

  // ---------------------------------------------------------------------
  // Pendientes de sync (push)
  // ---------------------------------------------------------------------

  Future<List<ChatSession>> getPendingChatSessions() {
    return (select(
      chatSessions,
    )..where((tbl) => _isPending(tbl.syncStatus))).get();
  }

  Future<List<ChatMessage>> getPendingChatMessages() {
    return (select(
      chatMessages,
    )..where((tbl) => _isPending(tbl.syncStatus))).get();
  }

  Future<List<AiMemory>> getPendingAiMemories() {
    return (select(
      aiMemories,
    )..where((tbl) => _isPending(tbl.syncStatus))).get();
  }

  Future<List<AiPreference>> getPendingAiPreferences() {
    return (select(
      aiPreferences,
    )..where((tbl) => _isPending(tbl.syncStatus))).get();
  }

  // ---------------------------------------------------------------------
  // Sesiones de chat
  // ---------------------------------------------------------------------

  Future<ChatSession> createSession({required String title}) async {
    final ctx = await getRequiredContext();
    final now = DateTime.now();
    final session = ChatSessionsCompanion.insert(
      id: const Uuid().v4(),
      empresaId: ctx.empresaId,
      usuarioId: ctx.usuarioId,
      title: title,
      lastMessageAt: Value(now),
      createdAt: Value(now),
      updatedAt: Value(now),
    );
    await into(chatSessions).insert(session);
    return (select(
      chatSessions,
    )..where((t) => t.id.equals(session.id.value))).getSingle();
  }

  Future<ChatSession?> getSessionById(String id) {
    return (select(
      chatSessions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Sesiones del usuario activo ordenadas por actividad reciente.
  Stream<List<ChatSession>> watchSessions({
    required String usuarioId,
    bool includeArchived = false,
  }) {
    final query = select(chatSessions)
      ..where((t) => t.usuarioId.equals(usuarioId))
      ..orderBy([(t) => OrderingTerm.desc(t.lastMessageAt)]);
    if (!includeArchived) {
      query.where((t) => t.status.equals('active'));
    }
    return query.watch();
  }

  Future<void> updateSessionMeta(
    String sessionId, {
    String? title,
    String? summary,
    String? status,
    DateTime? lastMessageAt,
    int? messageCount,
    String? metadataJson,
  }) async {
    await (update(chatSessions)..where((t) => t.id.equals(sessionId))).write(
      ChatSessionsCompanion(
        title: title != null ? Value(title) : const Value.absent(),
        summary: summary != null ? Value(summary) : const Value.absent(),
        status: status != null ? Value(status) : const Value.absent(),
        lastMessageAt: lastMessageAt != null
            ? Value(lastMessageAt)
            : const Value.absent(),
        messageCount: messageCount != null
            ? Value(messageCount)
            : const Value.absent(),
        metadataJson:
            metadataJson != null ? Value(metadataJson) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending_update'),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Mensajes
  // ---------------------------------------------------------------------

  /// Inserta un mensaje y actualiza los metadatos de la sesión en la misma
  /// transacción (seq incremental, lastMessageAt, messageCount).
  Future<ChatMessage> appendMessage({
    required String sessionId,
    required String role,
    required String content,
    String contentType = 'text',
    String? draftId,
  }) async {
    final ctx = await getRequiredContext();
    return transaction(() async {
      final maxSeqRow = await customSelect(
        'SELECT COALESCE(MAX(seq), 0) AS max_seq FROM chat_messages WHERE session_id = ?',
        variables: [Variable.withString(sessionId)],
      ).getSingle();
      final nextSeq = maxSeqRow.read<int>('max_seq') + 1;
      final now = DateTime.now();
      final id = const Uuid().v4();

      await into(chatMessages).insert(
        ChatMessagesCompanion.insert(
          id: id,
          sessionId: sessionId,
          empresaId: ctx.empresaId,
          usuarioId: ctx.usuarioId,
          role: role,
          content: content,
          contentType: Value(contentType),
          draftId: Value(draftId),
          seq: nextSeq,
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      await (update(chatSessions)..where((t) => t.id.equals(sessionId))).write(
        ChatSessionsCompanion(
          lastMessageAt: Value(now),
          messageCount: Value(nextSeq),
          updatedAt: Value(now),
          syncStatus: const Value('pending_update'),
        ),
      );

      return (select(
        chatMessages,
      )..where((t) => t.id.equals(id))).getSingle();
    });
  }

  Stream<List<ChatMessage>> watchMessages(String sessionId) {
    return (select(chatMessages)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.asc(t.seq)]))
        .watch();
  }

  /// Últimos [limit] mensajes de la sesión en orden cronológico.
  Future<List<ChatMessage>> getLastMessages(
    String sessionId, {
    int limit = 14,
  }) async {
    final rows =
        await (select(chatMessages)
              ..where((t) => t.sessionId.equals(sessionId))
              ..orderBy([(t) => OrderingTerm.desc(t.seq)])
              ..limit(limit))
            .get();
    return rows.reversed.toList();
  }

  // ---------------------------------------------------------------------
  // Memorias de largo plazo
  // ---------------------------------------------------------------------

  /// Memorias activas visibles para el usuario: las propias + las de alcance
  /// 'business' de la empresa.
  Future<List<AiMemory>> getActiveMemories({
    required String empresaId,
    required String usuarioId,
    int limit = 50,
  }) {
    return (select(aiMemories)
          ..where(
            (t) =>
                t.isActive.equals(true) &
                t.empresaId.equals(empresaId) &
                (t.usuarioId.equals(usuarioId) | t.scope.equals('business')),
          )
          ..orderBy([
            (t) => OrderingTerm.desc(t.confidence),
            (t) => OrderingTerm.desc(t.lastUsedAt),
          ])
          ..limit(limit))
        .get();
  }

  Future<void> upsertMemory(AiMemoriesCompanion memory) async {
    await into(aiMemories).insertOnConflictUpdate(memory);
  }

  Future<void> deactivateMemory(String id) async {
    await (update(aiMemories)..where((t) => t.id.equals(id))).write(
      AiMemoriesCompanion(
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending_update'),
      ),
    );
  }

  Future<void> touchMemoriesUsed(List<String> ids) async {
    if (ids.isEmpty) return;
    final questions = List.filled(ids.length, '?').join(',');
    // No marca pending_update: lastUsedAt es telemetría local de ranking y no
    // amerita un push por cada turno; viajará con la próxima edición real.
    await customStatement(
      'UPDATE ai_memories SET last_used_at = ? WHERE id IN ($questions)',
      [DateTime.now().toIso8601String(), ...ids],
    );
  }

  // ---------------------------------------------------------------------
  // Preferencias
  // ---------------------------------------------------------------------

  Future<AiPreference?> getPreferences({
    required String empresaId,
    required String usuarioId,
  }) {
    return (select(aiPreferences)
          ..where(
            (t) =>
                t.empresaId.equals(empresaId) & t.usuarioId.equals(usuarioId),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  /// Devuelve las preferencias del usuario, creándolas con defaults si no existen.
  Future<AiPreference> getOrCreatePreferences() async {
    final ctx = await getRequiredContext();
    final existing = await getPreferences(
      empresaId: ctx.empresaId,
      usuarioId: ctx.usuarioId,
    );
    if (existing != null) return existing;

    final id = const Uuid().v4();
    await into(aiPreferences).insert(
      AiPreferencesCompanion.insert(
        id: id,
        empresaId: ctx.empresaId,
        usuarioId: ctx.usuarioId,
      ),
      mode: InsertMode.insertOrIgnore,
    );
    return (await getPreferences(
      empresaId: ctx.empresaId,
      usuarioId: ctx.usuarioId,
    ))!;
  }

  Future<void> updatePreferences(
    String id,
    AiPreferencesCompanion changes,
  ) async {
    await (update(aiPreferences)..where((t) => t.id.equals(id))).write(
      changes.copyWith(
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending_update'),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Borradores (tablas temporales de dictado) — solo local
  // ---------------------------------------------------------------------

  Future<SecretaryDraft> createDraft({
    required String draftType,
    String? sessionId,
    String? bodegaId,
    String? clienteId,
    String? metaJson,
  }) async {
    final ctx = await getRequiredContext();
    final id = const Uuid().v4();
    await into(secretaryDrafts).insert(
      SecretaryDraftsCompanion.insert(
        id: id,
        empresaId: ctx.empresaId,
        usuarioId: ctx.usuarioId,
        sessionId: Value(sessionId),
        draftType: draftType,
        bodegaId: Value(bodegaId),
        clienteId: Value(clienteId),
        metaJson: Value(metaJson),
      ),
    );
    return (select(
      secretaryDrafts,
    )..where((t) => t.id.equals(id))).getSingle();
  }

  Future<SecretaryDraft?> getDraftById(String id) {
    return (select(
      secretaryDrafts,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Borrador activo más reciente de una sesión de chat.
  Future<SecretaryDraft?> getActiveDraftForSession(String sessionId) {
    return (select(secretaryDrafts)
          ..where(
            (t) => t.sessionId.equals(sessionId) & t.status.equals('active'),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<SecretaryDraft?> watchDraft(String draftId) {
    return (select(
      secretaryDrafts,
    )..where((t) => t.id.equals(draftId))).watchSingleOrNull();
  }

  Stream<List<SecretaryDraftItem>> watchDraftItems(String draftId) {
    return (select(secretaryDraftItems)
          ..where((t) => t.draftId.equals(draftId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Future<List<SecretaryDraftItem>> getDraftItems(String draftId) {
    return (select(secretaryDraftItems)
          ..where((t) => t.draftId.equals(draftId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<SecretaryDraftItem> insertDraftItem(
    SecretaryDraftItemsCompanion item,
  ) async {
    await into(secretaryDraftItems).insert(item);
    await _touchDraft(item.draftId.value);
    return (select(
      secretaryDraftItems,
    )..where((t) => t.id.equals(item.id.value))).getSingle();
  }

  Future<void> updateDraftItem(
    String itemId,
    SecretaryDraftItemsCompanion changes,
  ) async {
    await (update(secretaryDraftItems)..where((t) => t.id.equals(itemId)))
        .write(changes.copyWith(updatedAt: Value(DateTime.now())));
    final item = await (select(
      secretaryDraftItems,
    )..where((t) => t.id.equals(itemId))).getSingleOrNull();
    if (item != null) await _touchDraft(item.draftId);
  }

  Future<void> removeDraftItem(String itemId) async {
    final item = await (select(
      secretaryDraftItems,
    )..where((t) => t.id.equals(itemId))).getSingleOrNull();
    await (delete(
      secretaryDraftItems,
    )..where((t) => t.id.equals(itemId))).go();
    if (item != null) await _touchDraft(item.draftId);
  }

  Future<void> updateDraft(
    String draftId,
    SecretaryDraftsCompanion changes,
  ) async {
    await (update(secretaryDrafts)..where((t) => t.id.equals(draftId)))
        .write(changes.copyWith(updatedAt: Value(DateTime.now())));
  }

  Future<void> _touchDraft(String draftId) async {
    await (update(secretaryDrafts)..where((t) => t.id.equals(draftId))).write(
      SecretaryDraftsCompanion(updatedAt: Value(DateTime.now())),
    );
  }

  // ---------------------------------------------------------------------
  // Trazas de turno (solo local)
  // ---------------------------------------------------------------------

  Future<void> insertTrace(ChatTurnTracesCompanion trace) async {
    await into(chatTurnTraces).insert(trace);
  }

  /// Trazas recientes para la pantalla de diagnóstico (F8.2).
  Future<List<ChatTurnTrace>> getRecentTraces({int limit = 100}) {
    return (select(chatTurnTraces)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  // ---------------------------------------------------------------------
  // Mantenimiento (llamar al arranque)
  // ---------------------------------------------------------------------

  /// Limpieza local: trazas > 14 días y archivado de sesiones > 90 días.
  Future<void> runMaintenance() async {
    final now = DateTime.now();
    final traceCutoff = now.subtract(const Duration(days: 14));
    await (delete(
      chatTurnTraces,
    )..where((t) => t.createdAt.isSmallerThanValue(traceCutoff))).go();

    final sessionCutoff = now.subtract(const Duration(days: 90));
    await (update(chatSessions)
          ..where(
            (t) =>
                t.status.equals('active') &
                t.lastMessageAt.isSmallerThanValue(sessionCutoff),
          ))
        .write(
      ChatSessionsCompanion(
        status: const Value('archived'),
        updatedAt: Value(now),
        syncStatus: const Value('pending_update'),
      ),
    );
  }
}
