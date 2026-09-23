import 'package:drift/drift.dart';

import 'auth_tables.dart';
import 'inventory_tables.dart';
import 'sync_table.dart';

/// Sesión de conversación del secretario IA. Sincroniza a `chat_sessions`.
class ChatSessions extends Table with SyncTable {
  TextColumn get empresaId =>
      text().references(Empresas, #id, onDelete: KeyAction.cascade)();
  TextColumn get usuarioId =>
      text().references(Usuarios, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get summary => text().nullable()();
  // 'active' | 'archived'
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get lastMessageAt =>
      dateTime().withDefault(currentDateAndTime)();
  IntColumn get messageCount => integer().withDefault(const Constant(0))();
  TextColumn get metadataJson => text().nullable()();
}

/// Mensaje de chat (solo turnos user/assistant; las trazas técnicas van en
/// ChatTurnTraces y no se sincronizan).
class ChatMessages extends Table with SyncTable {
  TextColumn get sessionId =>
      text().references(ChatSessions, #id, onDelete: KeyAction.cascade)();
  // Desnormalizados para push directo y RLS por usuario en Supabase.
  TextColumn get empresaId => text()();
  TextColumn get usuarioId => text()();
  // 'user' | 'assistant'
  TextColumn get role => text()();
  TextColumn get content => text()();
  // 'text' | 'draft_card' | 'query_result'
  TextColumn get contentType => text().withDefault(const Constant('text'))();
  TextColumn get draftId => text().nullable()();
  IntColumn get seq => integer()();
}

/// Hechos de largo plazo extraídos de las conversaciones.
class AiMemories extends Table with SyncTable {
  TextColumn get empresaId => text()();
  TextColumn get usuarioId => text()();
  // 'user' (privado) | 'business' (visible a toda la empresa)
  TextColumn get scope => text().withDefault(const Constant('user'))();
  // 'preference' | 'fact' | 'rule' | 'correction'
  TextColumn get category => text()();
  TextColumn get content => text()();
  TextColumn get sourceSessionId => text().nullable()();
  RealColumn get confidence => real().withDefault(const Constant(1.0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastUsedAt => dateTime().nullable()();
}

/// Preferencias del secretario: una fila por usuario.
class AiPreferences extends Table with SyncTable {
  TextColumn get empresaId => text()();
  TextColumn get usuarioId => text()();
  // 'formal' | 'neutral' | 'casual'
  TextColumn get tone => text().withDefault(const Constant('neutral'))();
  // 'concise' | 'normal' | 'detailed'
  TextColumn get verbosity => text().withDefault(const Constant('concise'))();
  TextColumn get defaultBodegaId => text().nullable()();
  BoolColumn get voiceEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get autoReadResponses =>
      boolean().withDefault(const Constant(false))();
  RealColumn get ttsRate => real().withDefault(const Constant(1.0))();
  BoolColumn get confirmBeforeExecute =>
      boolean().withDefault(const Constant(true))();
  TextColumn get extraJson => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {empresaId, usuarioId},
      ];
}

/// Traza técnica de un turno (tool calls, tokens, latencia). Solo local,
/// nunca se sincroniza; retención de 14 días.
class ChatTurnTraces extends Table {
  TextColumn get id => text()();
  TextColumn get messageId => text().nullable()();
  TextColumn get sessionId => text().nullable()();
  TextColumn get toolCallsJson => text().nullable()();
  TextColumn get toolResultsJson => text().nullable()();

  /// Payload exacto enviado al LLM (system prompt + mensajes), truncado.
  /// Permite reproducir un turno bit a bit al depurar (F8.1).
  TextColumn get requestJson => text().nullable()();

  /// Error del turno si falló (F8.3); null en turnos exitosos.
  TextColumn get errorText => text().nullable()();

  /// Tiempo hasta el primer audio del acuse local al detectar una tool call
  /// en modo voz (SEC-IA-002 punto 5); null si el turno no usó tools o no
  /// fue en modo voz. [latencyMs] sigue siendo el tiempo hasta la
  /// respuesta final completa.
  IntColumn get firstAudioMs => integer().nullable()();
  IntColumn get latencyMs => integer().nullable()();
  IntColumn get tokensIn => integer().nullable()();
  IntColumn get tokensOut => integer().nullable()();
  TextColumn get model => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Borrador genérico del secretario (tabla temporal de dictado). Solo local:
/// la transacción resultante se sincroniza por las tablas de negocio.
class SecretaryDrafts extends Table {
  TextColumn get id => text()();
  TextColumn get empresaId =>
      text().references(Empresas, #id, onDelete: KeyAction.cascade)();
  TextColumn get usuarioId =>
      text().references(Usuarios, #id, onDelete: KeyAction.cascade)();
  TextColumn get sessionId => text().nullable()();
  // 'entrada' | 'venta' | 'ajuste' | 'transferencia'
  TextColumn get draftType => text()();
  // 'active' | 'confirmed' | 'discarded' | 'executed'
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get bodegaId => text().nullable()();
  TextColumn get bodegaDestinoId => text().nullable()();
  TextColumn get clienteId => text().nullable()();
  TextColumn get resultRefId => text().nullable()();
  TextColumn get metaJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class SecretaryDraftItems extends Table {
  TextColumn get id => text()();
  TextColumn get draftId =>
      text().references(SecretaryDrafts, #id, onDelete: KeyAction.cascade)();
  TextColumn get productId => text().nullable().references(
        Productos,
        #id,
        onDelete: KeyAction.setNull,
      )();
  TextColumn get productoVarianteId => text().nullable()();
  TextColumn get proposedName => text()();
  TextColumn get resolvedName => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get categoryName => text().nullable()();
  RealColumn get quantity => real()();
  RealColumn get unitCost => real().nullable()();
  RealColumn get unitPrice => real().nullable()();
  // 'pending' | 'needs_review' | 'ready' | 'confirmed'
  TextColumn get status => text().withDefault(const Constant('ready'))();
  TextColumn get candidatesJson => text().nullable()();
  BoolColumn get isNewProduct => boolean().withDefault(const Constant(false))();
  TextColumn get metaJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
