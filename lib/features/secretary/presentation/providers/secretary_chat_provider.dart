import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/constants/app_constants.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/core/services/app_logger.dart';
import 'package:inventario_v2/features/secretary/data/context/assistant_context_builder.dart';
import 'package:inventario_v2/features/secretary/data/tools/tool_executor.dart';

import '../../data/llm/function_schemas.dart';
import '../../data/llm/secretary_llm_client.dart';
import '../../data/llm/secretary_llm_models.dart';
import '../../data/repositories/chat_repository.dart';
import '../../drafts/draft_tools.dart';
import '../../engine/memory_extractor.dart';
import '../../engine/secretary_engine.dart';
import '../../engine/session_summarizer.dart';
import '../../engine/system_prompt_builder.dart';
import 'draft_provider.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(driftDatabaseProvider));
});

final secretaryEngineProvider = Provider<SecretaryEngine>((ref) {
  return SecretaryEngine(
    llm: SecretaryLlmClient(),
    toolExecutor: ref.watch(toolExecutorProvider),
  );
});

/// Mensajes de la sesión activa, reactivos desde Drift.
final secretaryMessagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, sessionId) {
  return ref.watch(chatRepositoryProvider).watchMessages(sessionId);
});

class SecretaryChatState {
  /// Sesión activa; null hasta que se envía el primer mensaje.
  final String? sessionId;
  final bool isSending;

  /// Texto parcial de la respuesta en streaming (aún no persistido).
  final String streamingText;

  /// Tool en ejecución (para indicador "consultando...").
  final String? runningTool;
  final String? error;

  /// Id del borrador que dejó ACTIVO el último turno (null si el turno no
  /// tocó un borrador o si ya se confirmó/descartó). El modo voz lo usa
  /// para abrir la ventana de "confirmar por voz" (SEC-IA-002 punto 4).
  final String? pendingDraftId;

  const SecretaryChatState({
    this.sessionId,
    this.isSending = false,
    this.streamingText = '',
    this.runningTool,
    this.error,
    this.pendingDraftId,
  });

  SecretaryChatState copyWith({
    String? sessionId,
    bool? isSending,
    String? streamingText,
    String? runningTool,
    String? error,
    String? pendingDraftId,
    bool clearRunningTool = false,
    bool clearError = false,
    bool clearPendingDraftId = false,
  }) {
    return SecretaryChatState(
      sessionId: sessionId ?? this.sessionId,
      isSending: isSending ?? this.isSending,
      streamingText: streamingText ?? this.streamingText,
      runningTool: clearRunningTool ? null : (runningTool ?? this.runningTool),
      error: clearError ? null : (error ?? this.error),
      pendingDraftId: clearPendingDraftId
          ? null
          : (pendingDraftId ?? this.pendingDraftId),
    );
  }
}

class SecretaryChatNotifier extends StateNotifier<SecretaryChatState> {
  final Ref _ref;

  SecretaryChatNotifier(this._ref) : super(const SecretaryChatState());

  /// Abre una sesión existente (desde el historial).
  void openSession(String sessionId) {
    state = SecretaryChatState(sessionId: sessionId);
  }

  /// Inicia una conversación nueva (la sesión se crea al primer mensaje).
  void startNewSession() {
    state = const SecretaryChatState();
  }

  /// Envía un mensaje y devuelve el texto final del asistente (null si
  /// falló) para que el modo voz pueda leerlo en voz alta.
  ///
  /// [onToolAnnounce] se dispara una sola vez, en la PRIMERA tool call del
  /// turno (si hay), para que el modo voz reproduzca un acuse corto local
  /// mientras el motor sigue trabajando (SEC-IA-002 punto 5).
  Future<String?> sendMessage(
    String text, {
    bool voiceMode = false,
    void Function(String toolId)? onToolAnnounce,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isSending) return null;

    final repo = _ref.read(chatRepositoryProvider);
    final startedAt = DateTime.now();
    int? firstAudioMs;
    var announced = false;

    try {
      state = state.copyWith(
        isSending: true,
        streamingText: '',
        clearRunningTool: true,
        clearError: true,
      );

      // Sesión: crear con el primer mensaje si no hay una activa.
      var sessionId = state.sessionId;
      if (sessionId == null) {
        final session = await repo.createSessionFromMessage(trimmed);
        sessionId = session.id;
        state = state.copyWith(sessionId: sessionId);
      }

      await repo.appendUserMessage(sessionId, trimmed);

      // Contexto operativo + preferencias + historial persistido.
      final contextBuilder = _ref.read(assistantContextBuilderProvider);
      final context = await contextBuilder.build();
      if (!context.isValid) {
        throw StateError('No hay sesión de usuario activa.');
      }
      final prefs = await repo.getOrCreatePreferences();
      final session = await repo.getSession(sessionId);
      final history = await repo.getLastMessages(
        sessionId,
        limit: AppConstants.assistantHistoryTurns,
      );
      final memories = await repo.getMemoriesForPrompt();
      if (memories.isNotEmpty) {
        // No espera: es telemetría de ranking, no afecta el turno.
        unawaited(repo.touchMemoriesUsed([for (final m in memories) m.id]));
      }

      final systemPrompt = SystemPromptBuilder().build(
        context: context,
        prefs: prefs,
        sessionSummary: session?.summary,
        memories: memories,
        voiceMode: voiceMode,
      );
      final messages = <SecMessage>[
        SecMessage.system(systemPrompt),
        for (final m in history)
          SecMessage(role: m.role, content: m.content),
      ];

      final engine = _ref.read(secretaryEngineProvider);
      final draftHandler = DraftToolHandler(
        engine: _ref.read(draftEngineProvider),
        db: _ref.read(driftDatabaseProvider),
        sessionId: sessionId,
        context: context,
        defaultBodegaId: prefs.defaultBodegaId,
      );
      final buffer = StringBuffer();
      TurnCompleted? completed;

      await for (final event in engine.runTurn(
        messages: messages,
        tools: [...secretaryReadOnlyTools, ...secretaryDraftTools],
        context: context,
        localToolHandler: draftHandler.handle,
      )) {
        switch (event) {
          case TurnTextDelta(:final content):
            buffer.write(content);
            state = state.copyWith(
              streamingText: buffer.toString(),
              clearRunningTool: true,
            );
          case TurnToolRunning(:final toolId):
            state = state.copyWith(runningTool: toolId);
            if (!announced) {
              announced = true;
              firstAudioMs = DateTime.now().difference(startedAt).inMilliseconds;
              onToolAnnounce?.call(toolId);
            }
          case TurnCompleted():
            completed = event;
        }
      }

      final finalText = completed?.content.trim().isNotEmpty == true
          ? completed!.content
          : buffer.toString();
      // Si el turno tocó un borrador, el mensaje lleva la tarjeta editable.
      final draftId = draftHandler.lastDraftId;
      final assistantMessage = await repo.appendAssistantMessage(
        sessionId,
        finalText.trim().isEmpty
            ? 'No pude generar una respuesta. Intentá de nuevo.'
            : finalText,
        contentType: draftId != null ? 'draft_card' : 'text',
        draftId: draftId,
      );

      if (completed != null) {
        await repo.saveTrace(
          sessionId: sessionId,
          messageId: assistantMessage.id,
          toolCallsJson: encodeTraceJson(completed.toolCallsLog),
          toolResultsJson: encodeTraceJson(completed.toolResultsLog),
          requestJson: _truncate(
            jsonEncode([for (final m in messages) m.toJson()]),
            16000,
          ),
          firstAudioMs: firstAudioMs,
          latencyMs: DateTime.now().difference(startedAt).inMilliseconds,
          tokensIn: completed.totalPromptTokens,
          tokensOut: completed.totalCompletionTokens,
          model: AppConstants.openAiModel,
        );
      }

      // El borrador queda "pendiente de confirmar por voz" solo si sigue
      // activo (no se auto-ejecutó, ej. por confirmBeforeExecute=false).
      String? stillActiveDraftId;
      if (draftId != null) {
        final draft = await _ref
            .read(driftDatabaseProvider)
            .secretaryDao
            .getDraftById(draftId);
        if (draft?.status == 'active') stillActiveDraftId = draftId;
      }

      state = state.copyWith(
        isSending: false,
        streamingText: '',
        clearRunningTool: true,
        pendingDraftId: stillActiveDraftId,
        clearPendingDraftId: stillActiveDraftId == null,
      );
      unawaited(_maybeExtractMemories(sessionId));
      unawaited(_maybeSummarize(sessionId));
      return assistantMessage.content;
    } catch (e, st) {
      AppLogger.error('[Secretary] Error en turno de chat', e, st);
      String? traceRef;
      final errorSessionId = state.sessionId;
      if (errorSessionId != null) {
        try {
          traceRef = await repo.saveTrace(
            sessionId: errorSessionId,
            errorText: _truncate(e.toString(), 4000),
            latencyMs: DateTime.now().difference(startedAt).inMilliseconds,
            model: AppConstants.openAiModel,
          );
        } catch (_) {}
      }
      state = state.copyWith(
        isSending: false,
        streamingText: '',
        clearRunningTool: true,
        error: _classifyError(e, traceRef),
      );
      return null;
    }
  }

  /// Mensaje de error accionable por categoría + referencia de traza para
  /// soporte (F8.3), en vez del genérico "revisá tu conexión".
  String _classifyError(Object e, String? traceRef) {
    final ref = traceRef != null ? ' (ref: ${traceRef.substring(0, 8)})' : '';
    if (e is SecretaryLlmException) {
      final msg = e.message.toLowerCase();
      if (msg.contains('openai_api_key')) {
        return 'El servidor de IA no tiene configurada la clave de OpenAI. '
            'Avisale al administrador.$ref';
      }
      return switch (e.statusCode) {
        401 || 403 =>
          'Sesión no autorizada con el servidor. Cerrá sesión y volvé a '
              'entrar.$ref',
        429 => 'El servicio de IA está saturado. Esperá un momento y '
            'reintentá.$ref',
        >= 500 => 'El servidor de IA falló. Reintentá en unos minutos.$ref',
        _ => 'El servicio de IA rechazó la petición '
            '(código ${e.statusCode}).$ref',
      };
    }
    final text = e.toString();
    if (text.contains('SocketException') ||
        text.contains('Connection') ||
        text.contains('HandshakeException')) {
      return 'Sin conexión a internet. El chat necesita red; las consultas '
          'de datos siguen disponibles al volver la conexión.$ref';
    }
    return 'No se pudo completar la respuesta.$ref';
  }

  String _truncate(String text, int maxChars) =>
      text.length <= maxChars ? text : '${text.substring(0, maxChars)}…';

  /// Ejecuta el borrador tras el tap en Confirmar de la tarjeta (Req-15:
  /// la transacción real solo ocurre con confirmación explícita del usuario).
  Future<void> confirmDraft(String draftId) async {
    final sessionId = state.sessionId;
    if (sessionId == null || state.isSending) return;
    final repo = _ref.read(chatRepositoryProvider);
    try {
      state = state.copyWith(isSending: true, clearError: true);
      final contextBuilder = _ref.read(assistantContextBuilderProvider);
      final context = await contextBuilder.build();
      await _ref.read(draftEngineProvider).execute(draftId, context);
      await repo.appendAssistantMessage(
        sessionId,
        'Listo, registré la operación correctamente.',
      );
      state = state.copyWith(isSending: false, clearPendingDraftId: true);
    } catch (e, st) {
      AppLogger.error('[Secretary] Error al ejecutar borrador', e, st);
      await repo.appendAssistantMessage(
        sessionId,
        'No pude registrar la operación: ${e.toString().replaceFirst('Exception: ', '').replaceFirst('Bad state: ', '')}',
      );
      state = state.copyWith(isSending: false);
    }
  }

  Future<void> discardDraft(String draftId) async {
    final sessionId = state.sessionId;
    if (sessionId == null) return;
    await _ref.read(draftEngineProvider).discard(draftId);
    await _ref
        .read(chatRepositoryProvider)
        .appendAssistantMessage(sessionId, 'Borrador descartado.');
    if (state.pendingDraftId == draftId) {
      state = state.copyWith(clearPendingDraftId: true);
    }
  }

  /// Rolling summary cada 12 mensajes nuevos (asíncrono, best-effort).
  Future<void> _maybeSummarize(String sessionId) async {
    try {
      final repo = _ref.read(chatRepositoryProvider);
      final session = await repo.getSession(sessionId);
      if (session == null) return;

      final meta = session.metadataJson != null
          ? Map<String, dynamic>.from(jsonDecode(session.metadataJson!))
          : <String, dynamic>{};
      final summarizedUpTo = (meta['sumUpTo'] as num?)?.toInt() ?? 0;
      if (session.messageCount - summarizedUpTo < 12) return;

      meta['sumUpTo'] = session.messageCount;
      await repo.updateSessionMetadata(sessionId, jsonEncode(meta));
      await _ref.read(sessionSummarizerProvider).summarize(sessionId);
    } catch (e) {
      AppLogger.warn('[Secretary][Resumen] Disparo falló: $e');
    }
  }

  /// Dispara la extracción de memorias cada 8 mensajes nuevos (asíncrono,
  /// best-effort). El avance se marca en metadataJson de la sesión.
  Future<void> _maybeExtractMemories(String sessionId) async {
    try {
      final repo = _ref.read(chatRepositoryProvider);
      final session = await repo.getSession(sessionId);
      if (session == null) return;

      final meta = session.metadataJson != null
          ? Map<String, dynamic>.from(jsonDecode(session.metadataJson!))
          : <String, dynamic>{};
      final extractedUpTo = (meta['memUpTo'] as num?)?.toInt() ?? 0;
      if (session.messageCount - extractedUpTo < 8) return;

      meta['memUpTo'] = session.messageCount;
      await repo.updateSessionMetadata(sessionId, jsonEncode(meta));
      await _ref.read(memoryExtractorProvider).extractFromSession(sessionId);
    } catch (e) {
      AppLogger.warn('[Secretary][Memoria] Disparo de extracción falló: $e');
    }
  }
}

final memoryExtractorProvider = Provider<MemoryExtractor>((ref) {
  return MemoryExtractor(ref.watch(driftDatabaseProvider));
});

final sessionSummarizerProvider = Provider<SessionSummarizer>((ref) {
  return SessionSummarizer(ref.watch(driftDatabaseProvider));
});

final secretaryChatProvider =
    StateNotifierProvider<SecretaryChatNotifier, SecretaryChatState>((ref) {
  return SecretaryChatNotifier(ref);
});
