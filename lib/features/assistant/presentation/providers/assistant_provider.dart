import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/constants/app_constants.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../../core/draft_executor.dart';
import '../../core/turn_pipeline.dart';
import '../../core/semantic_router.dart';
import '../../core/reasoning_engine.dart';
import '../../core/stepwise_orchestrator.dart';
import '../../data/connectivity/connectivity_checker.dart';
import '../../data/context/assistant_context_builder.dart';
import '../../data/entity_resolver.dart';
import '../../data/entry/assistant_entry_draft_repository.dart';
import '../../data/entry/assistant_entry_workflow_service.dart';
import '../../data/entry/product_category_resolver.dart';
import '../../data/logging/assistant_chat_logger.dart';
import '../../data/offline/offline_query_handler.dart';
import '../../data/openai/openai_client.dart';
import '../../data/openai/openai_models.dart';
import '../../data/openai/openai_providers.dart';
import '../../data/speech_to_text_transcriber.dart';
import '../../data/flutter_tts_service.dart';
import '../../domain/models/assistant_draft.dart';
import '../../domain/models/assistant_input_event.dart';
import '../../domain/models/assistant_session.dart';
import '../../domain/models/conversation_state.dart';
import '../../domain/services/assistant_session_manager.dart';
import '../../domain/services/speech_transcriber.dart';
import '../../domain/services/tts_service.dart';
import '../../../inventory/domain/use_cases/registrar_entrada_use_case.dart';
import '../models/assistant_ui_state.dart';
import '../models/chat_message.dart';
import '../widgets/assistant_voice_button.dart';

export '../../data/openai/openai_providers.dart' show llmClientProvider;

// ── Providers de infraestructura ────────────────────────────────────────────

final turnPipelineProvider = Provider<TurnPipeline>((ref) {
  final db = ref.watch(driftDatabaseProvider);
  final entryDraftRepository = AssistantEntryDraftRepository(db);
  final entryResolver = EntityResolver(db);
  final categoryResolver = ProductCategoryResolver(db);
  return TurnPipeline(
    contextBuilder: ref.watch(assistantContextBuilderProvider),
    semanticRouter: ref.watch(semanticRouterProvider),
    reasoningEngine: ref.watch(reasoningEngineProvider),
    orchestrator: ref.watch(stepwiseOrchestratorProvider),
    connectivityChecker: ref.watch(connectivityCheckerProvider),
    offlineQueryHandler: ref.watch(offlineQueryHandlerProvider),
    entryWorkflowService: AssistantEntryWorkflowService(
      db: db,
      draftRepository: entryDraftRepository,
      entityResolver: entryResolver,
      categoryResolver: categoryResolver,
      registrarEntradaUseCase: ref.watch(registrarEntradaUseCaseProvider),
    ),
    db: db,
  );
});

final speechTranscriberProvider = Provider<SpeechTranscriber>((ref) {
  final transcriber = SpeechToTextTranscriber();
  ref.onDispose(transcriber.dispose);
  return transcriber;
});

final ttsServiceProvider = Provider<TtsService>((ref) {
  final tts = FlutterTtsService();
  ref.onDispose(tts.dispose);
  return tts;
});

// ── Notifier principal ──────────────────────────────────────────────────────

class AssistantNotifier extends StateNotifier<AssistantUiState> {
  final TurnPipeline _pipeline;
  final DraftExecutor _draftExecutor;
  final SpeechTranscriber _transcriber;
  final TtsService _ttsService;
  final AssistantChatLogger _logger;
  final LLMClient _llm;
  final AssistantSessionManager _sessionManager;
  static const _uuid = Uuid();

  // Controla el loop manos libres
  bool _voiceLoopActive = false;
  Timer? _silenceTimer;

  ConversationState _conversationState = ConversationState.initial();

  AssistantNotifier(
    this._pipeline,
    this._draftExecutor,
    this._transcriber,
    this._ttsService,
    this._logger,
    this._llm,
  ) : _sessionManager = const AssistantSessionManager(),
      super(const AssistantUiState()) {
    // Cuando el TTS termina, continuar el loop si el modo voz está activo
    _ttsService.onSpeakComplete = _onTtsSpeakComplete;
  }

  // ── Texto ────────────────────────────────────────────────────────────────

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final turnId = _uuid.v4();
    final startedAt = DateTime.now();
    await _logger.logEvent(
      'assistant.turn.start',
      data: {
        'turnId': turnId,
        'inputMode': state.isVoiceMode ? 'voice' : 'text',
        'hasActiveSession': state.hasActiveSession,
        'message': text.trim(),
      },
    );

    if (state.hasActiveSession) {
      await _processSessionEvent(TextInputEvent(text.trim()), turnId: turnId);
      return;
    }

    if (state.hasPendingDraft) {
      await _processDraftCommand(text.trim(), turnId: turnId);
      return;
    }

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.user,
      content: text.trim(),
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      clearError: true,
    );

    try {
      final result = await _pipeline.process(text.trim(), _conversationState);
      _conversationState = result.updatedState;

      final isOffline = result.isOffline;
      final pausedNames = _conversationState.pausedWorkflowStack
          .map((p) => p.state.workflowId)
          .toList();
      final clarificationOpts = _extractClarificationOptions(result);

      // ── Borrador pendiente de confirmación ─────────────────────────────
      if (result.requiresConfirmation && result.draft != null) {
        AssistantDraft draft;
        if (result.draft is AssistantDraft) {
          draft = result.draft as AssistantDraft;
        } else if (result.draft is Map<String, dynamic>) {
          draft = AssistantDraft.fromMap(result.draft as Map<String, dynamic>);
        } else {
          _addErrorMessage(
            'No se pudo preparar el borrador. Intentá de nuevo.',
          );
          return;
        }

        final hintText = result.responseText.isNotEmpty
            ? result.responseText
            : 'Revisá el borrador antes de confirmar.';

        final hintMsg = ChatMessage(
          id: _uuid.v4(),
          type: ChatMessageType.assistant,
          content: hintText,
          timestamp: DateTime.now(),
        );

        state = state.copyWith(
          messages: [...state.messages, hintMsg],
          isLoading: false,
          pendingDraft: draft,
          pausedWorkflowNames: pausedNames,
          isOffline: isOffline,
        );

        await _logger.logEvent(
          'assistant.turn.draft',
          data: {
            'turnId': turnId,
            'responseText': hintText,
            'draft': _draftToLog(draft),
            'isOffline': isOffline,
            'durationMs': DateTime.now().difference(startedAt).inMilliseconds,
          },
        );
        await _speakIfVoiceMode(hintText);
        return;
      }

      // ── Respuesta con streaming ────────────────────────────────────────
      if (result.responseStream != null) {
        final streamingMsgId = _uuid.v4();
        final streamingMsg = ChatMessage(
          id: streamingMsgId,
          type: ChatMessageType.assistant,
          content: '',
          timestamp: DateTime.now(),
          isStreaming: true,
        );

        state = state.copyWith(
          messages: [...state.messages, streamingMsg],
          isLoading: false,
          isStreaming: true,
          pausedWorkflowNames: pausedNames,
          isOffline: isOffline,
        );

        final buffer = StringBuffer();

        await for (final token in result.responseStream!) {
          buffer.write(token);
          final updatedMessages = state.messages.map((m) {
            if (m.id == streamingMsgId) {
              return m.copyWith(content: buffer.toString());
            }
            return m;
          }).toList();
          state = state.copyWith(messages: updatedMessages);
        }

        var finalMessages = state.messages.map((m) {
          if (m.id == streamingMsgId) {
            return m.copyWith(isStreaming: false);
          }
          return m;
        }).toList();

        _conversationState = _pipeline.addAssistantTurn(
          buffer.toString(),
          _conversationState,
        );

        if (result.resumeHint != null && result.resumeHint!.isNotEmpty) {
          final resumeMsg = ChatMessage(
            id: _uuid.v4(),
            type: ChatMessageType.assistant,
            content: result.resumeHint!,
            timestamp: DateTime.now(),
          );
          finalMessages = [...finalMessages, resumeMsg];
        }

        state = state.copyWith(messages: finalMessages, isStreaming: false);

        await _logger.logEvent(
          'assistant.turn.response',
          data: {
            'turnId': turnId,
            'responseText': buffer.toString(),
            'resumeHint': result.resumeHint,
            'isStreaming': true,
            'isOffline': isOffline,
            'durationMs': DateTime.now().difference(startedAt).inMilliseconds,
          },
        );
        await _speakIfVoiceMode(buffer.toString());
      } else {
        // ── Respuesta directa (sin stream) ─────────────────────────────
        var messages = [
          ...state.messages,
          ChatMessage(
            id: _uuid.v4(),
            type: ChatMessageType.assistant,
            content: result.responseText,
            timestamp: DateTime.now(),
          ),
        ];

        if (result.resumeHint != null && result.resumeHint!.isNotEmpty) {
          messages = [
            ...messages,
            ChatMessage(
              id: _uuid.v4(),
              type: ChatMessageType.assistant,
              content: result.resumeHint!,
              timestamp: DateTime.now(),
            ),
          ];
        }

        state = state.copyWith(
          messages: messages,
          isLoading: false,
          pausedWorkflowNames: pausedNames,
          isOffline: isOffline,
          clarificationOptions: clarificationOpts,
        );

        await _logger.logEvent(
          'assistant.turn.response',
          data: {
            'turnId': turnId,
            'responseText': result.responseText,
            'resumeHint': result.resumeHint,
            'clarificationOptions': clarificationOpts,
            'isStreaming': false,
            'isOffline': isOffline,
            'durationMs': DateTime.now().difference(startedAt).inMilliseconds,
          },
        );
        await _speakIfVoiceMode(result.responseText);
      }
    } on OpenAIException catch (e) {
      await _logger.logEvent(
        'assistant.turn.error',
        data: {
          'turnId': turnId,
          'durationMs': DateTime.now().difference(startedAt).inMilliseconds,
        },
        error: e,
      );
      _addErrorMessage(_friendlyOpenAIError(e));
    } catch (e, st) {
      await _logger.logEvent(
        'assistant.turn.error',
        data: {
          'turnId': turnId,
          'durationMs': DateTime.now().difference(startedAt).inMilliseconds,
        },
        error: e,
        stackTrace: st,
      );
      _addErrorMessage('Ocurrió un error inesperado. Intentá de nuevo.');
    }
  }

  // ── Modo Voz ─────────────────────────────────────────────────────────────

  Future<void> toggleVoiceMode() async {
    if (state.isVoiceMode) {
      await _exitVoiceMode();
    } else {
      await _enterVoiceMode();
    }
  }

  Future<void> _enterVoiceMode() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      _addErrorMessage('Se necesita permiso de micrófono para el modo voz.');
      return;
    }

    final initialized = await _transcriber.initialize();
    if (!initialized) {
      _addErrorMessage(
        'El reconocimiento de voz no está disponible en este dispositivo.',
      );
      return;
    }

    await _ttsService.initialize();

    state = state.copyWith(isVoiceMode: true);
    HapticFeedback.mediumImpact();

    _voiceLoopActive = true;
    await _speakAndListen('Modo voz activado. Te escucho.');
  }

  Future<void> _exitVoiceMode() async {
    _voiceLoopActive = false;
    _silenceTimer?.cancel();
    _transcriber.cancel();
    await _ttsService.stop();
    state = state.copyWith(
      isVoiceMode: false,
      voiceState: VoiceButtonState.idle,
      clearLiveTranscript: true,
    );
    HapticFeedback.lightImpact();
  }

  // Habla un texto y, cuando termina, inicia la escucha del loop
  Future<void> _speakAndListen(String text) async {
    if (!_voiceLoopActive || !state.isVoiceMode) return;
    state = state.copyWith(voiceState: VoiceButtonState.speaking);
    await _ttsService.speak(text);
    // _onTtsSpeakComplete se encarga de continuar el loop
  }

  void _onTtsSpeakComplete() {
    if (!_voiceLoopActive || !state.isVoiceMode) return;
    _startListeningLoop();
  }

  Future<void> _startListeningLoop() async {
    if (!_voiceLoopActive || !state.isVoiceMode) return;

    state = state.copyWith(
      voiceState: VoiceButtonState.recording,
      clearLiveTranscript: true,
    );
    HapticFeedback.lightImpact();

    // Registrar transcripción en tiempo real
    _transcriber.onPartialResult = (partial) {
      if (state.isVoiceMode) {
        state = state.copyWith(liveTranscript: partial);
      }
    };

    // Timeout de silencio: si no habla en 30s, pausar el loop
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(seconds: 30), () {
      if (state.isRecording && _voiceLoopActive) {
        _transcriber.cancel();
        state = state.copyWith(
          voiceState: VoiceButtonState.idle,
          clearLiveTranscript: true,
        );
      }
    });

    try {
      final transcript = await _transcriber.transcribe();
      _silenceTimer?.cancel();
      state = state.copyWith(
        voiceState: VoiceButtonState.processing,
        clearLiveTranscript: true,
      );

      if (transcript != null && transcript.trim().isNotEmpty) {
        // Detectar comando de salida por voz
        final lower = transcript.toLowerCase().trim();
        if (_isExitCommand(lower)) {
          await _exitVoiceMode();
          return;
        }
        await sendMessage(transcript.trim());
      } else {
        // Sin voz detectada, volver a idle en modo voz
        state = state.copyWith(voiceState: VoiceButtonState.idle);
      }
    } catch (_) {
      state = state.copyWith(voiceState: VoiceButtonState.idle);
    }
  }

  bool _isExitCommand(String text) {
    const exitPhrases = [
      'salir',
      'cerrar',
      'cerrar modo voz',
      'salir modo voz',
      'apagar',
      'stop',
      'detener',
      'para',
      'parar',
    ];
    return exitPhrases.any((phrase) => text.contains(phrase));
  }

  // Habla la respuesta solo si el modo voz está activo
  Future<void> _speakIfVoiceMode(String text) async {
    if (!state.isVoiceMode || !_voiceLoopActive) return;
    state = state.copyWith(voiceState: VoiceButtonState.speaking);
    await _ttsService.speak(text);
  }

  // ── Voz push-to-talk (modo chat) ─────────────────────────────────────────

  Future<void> startVoiceInput() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      _addErrorMessage('Se necesita permiso de micrófono para usar la voz.');
      return;
    }

    final initialized = await _transcriber.initialize();
    if (!initialized) {
      _addErrorMessage(
        'El reconocimiento de voz no está disponible en este dispositivo.',
      );
      return;
    }

    state = state.copyWith(voiceState: VoiceButtonState.recording);
    HapticFeedback.lightImpact();

    try {
      final transcript = await _transcriber.transcribe();
      state = state.copyWith(voiceState: VoiceButtonState.processing);

      if (transcript != null && transcript.isNotEmpty) {
        await sendMessage(transcript);
      }
    } catch (_) {
      // silencioso — simplemente vuelve a idle
    } finally {
      state = state.copyWith(voiceState: VoiceButtonState.idle);
    }
  }

  void cancelVoiceInput() {
    _transcriber.cancel();
    state = state.copyWith(voiceState: VoiceButtonState.idle);
  }

  // ── Sesión acumulativa ───────────────────────────────────────────────────

  void startSession(AssistantSessionType type) {
    final session = _sessionManager.tryStartSession(type);
    if (session == null) return;

    final modeLabel = switch (type) {
      AssistantSessionType.registerEntry => 'Entrada de inventario',
      AssistantSessionType.registerSale => 'Venta',
      AssistantSessionType.registerOutputAdjustment => 'Salida / Ajuste',
    };

    final msg = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.assistant,
      content:
          'Modo $modeLabel activado. Escaneá productos o decí "listo" para confirmar.',
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      activeSession: session,
      messages: [...state.messages, msg],
    );
  }

  Future<void> handleBarcode(String barcode) async {
    if (!state.hasActiveSession) return;
    await _processSessionEvent(
      BarcodeInputEvent(barcode: barcode, resolvedProduct: null),
    );
  }

  Future<void> handleBarcodeWithProduct(String barcode, dynamic product) async {
    if (!state.hasActiveSession) return;
    await _processSessionEvent(
      BarcodeInputEvent(barcode: barcode, resolvedProduct: product),
    );
  }

  void cancelSession() {
    if (!state.hasActiveSession) return;
    final cancelMsg = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.system,
      content: 'Sesión cancelada. No se guardó nada.',
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, cancelMsg],
      clearSession: true,
    );
  }

  Future<void> _processSessionEvent(
    AssistantInputEvent event, {
    String? turnId,
  }) async {
    final session = state.activeSession;
    if (session == null) return;
    final sessionTurnId = turnId ?? _uuid.v4();
    final startedAt = DateTime.now();

    final text = switch (event) {
      TextInputEvent(text: final t) => t,
      VoiceInputEvent(transcript: final t) => t,
      BarcodeInputEvent(barcode: final b) => '📷 $b',
    };

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.user,
      content: text,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(messages: [...state.messages, userMsg]);

    try {
      final result = await _sessionManager.processEvent(session, event);

      final responseMsg = ChatMessage(
        id: _uuid.v4(),
        type: ChatMessageType.assistant,
        content: result.responseText,
        timestamp: DateTime.now(),
      );

      if (result.session.state == AssistantSessionState.cancelled) {
        state = state.copyWith(
          messages: [...state.messages, responseMsg],
          clearSession: true,
        );
        await _logger.logEvent(
          'assistant.session.response',
          data: {
            'turnId': sessionTurnId,
            'sessionType': session.type.name,
            'sessionState': result.session.state.name,
            'responseText': result.responseText,
            'durationMs': DateTime.now().difference(startedAt).inMilliseconds,
          },
        );
        await _speakIfVoiceMode(result.responseText);
        return;
      }

      if (result.showDraft) {
        state = state.copyWith(
          messages: [...state.messages, responseMsg],
          activeSession: result.session,
          pendingDraft: result.session.draft,
        );
        await _logger.logEvent(
          'assistant.session.draft',
          data: {
            'turnId': sessionTurnId,
            'sessionType': session.type.name,
            'sessionState': result.session.state.name,
            'responseText': result.responseText,
            'draft': _draftToLog(result.session.draft),
            'durationMs': DateTime.now().difference(startedAt).inMilliseconds,
          },
        );
        await _speakIfVoiceMode(result.responseText);
        return;
      }

      state = state.copyWith(
        messages: [...state.messages, responseMsg],
        activeSession: result.session,
      );

      await _logger.logEvent(
        'assistant.session.response',
        data: {
          'turnId': sessionTurnId,
          'sessionType': session.type.name,
          'sessionState': result.session.state.name,
          'responseText': result.responseText,
          'durationMs': DateTime.now().difference(startedAt).inMilliseconds,
        },
      );
      await _speakIfVoiceMode(result.responseText);
      HapticFeedback.selectionClick();
    } catch (e, st) {
      await _logger.logEvent(
        'assistant.session.error',
        data: {
          'turnId': sessionTurnId,
          'sessionType': session.type.name,
          'durationMs': DateTime.now().difference(startedAt).inMilliseconds,
        },
        error: e,
        stackTrace: st,
      );
      _addErrorMessage('Error procesando el evento. Intentá de nuevo.');
    }
  }

  // ── Borrador ─────────────────────────────────────────────────────────────

  Future<void> confirmDraft() async {
    final draft = state.pendingDraft;
    if (draft == null) return;

    state = state.copyWith(isConfirming: true);

    try {
      await _draftExecutor.execute(draft);

      final successText = draft.type == DraftType.sale
          ? 'Venta registrada correctamente.'
          : 'Entrada de inventario registrada correctamente.';

      final successMsg = ChatMessage(
        id: _uuid.v4(),
        type: ChatMessageType.assistant,
        content: successText,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, successMsg],
        isConfirming: false,
        clearDraft: true,
        clearSession: true,
      );

      HapticFeedback.heavyImpact();
      await _speakIfVoiceMode(successText);
    } catch (e) {
      _addErrorMessage(_friendlyExecutionError(e));
      state = state.copyWith(isConfirming: false);
    }
  }

  Future<void> _processDraftCommand(
    String text, {
    required String turnId,
  }) async {
    final userMsg = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.user,
      content: text,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(messages: [...state.messages, userMsg]);

    final draft = state.pendingDraft;
    if (draft == null) {
      state = state.copyWith(clearDraft: true);
      return;
    }

    final llmResponse = await _callLlmForDraft(text, draft);
    final action = llmResponse['action'] as String? ?? 'unrelated';
    final reasoning = llmResponse['reasoning'] as String? ?? '';

    await _logger.logEvent(
      'assistant.draft.llm',
      data: {
        'turnId': turnId,
        'message': text,
        'action': action,
        'reasoning': reasoning,
      },
    );

    switch (action) {
      case 'confirm':
        await confirmDraft();
        return;
      case 'reject':
        cancelDraft();
        return;
      case 'modify_items':
        await _applyItemModifications(llmResponse, turnId: turnId);
        return;
      case 'change_field':
        await _applyFieldChanges(llmResponse, turnId: turnId);
        return;
      case 'unrelated':
      default:
        await _showDraftHelp(text, reasoning, turnId: turnId);
        return;
    }
  }

  Future<Map<String, dynamic>> _callLlmForDraft(
    String userMessage,
    AssistantDraft draft,
  ) async {
    final itemsStr = draft.items.asMap().entries.map((e) {
      final i = e.key + 1;
      final item = e.value;
      return '  $i. ${item.productName} — cantidad: ${item.quantity.toStringAsFixed(0)}, '
          'precio: \$${item.unitPrice.toStringAsFixed(2)}'
          '${item.unitCost != null ? ', costo: \$${item.unitCost!.toStringAsFixed(2)}' : ''}';
    }).join('\n');

    final draftStr = '''
Tipo: ${draft.type == DraftType.sale ? 'Venta' : 'Entrada de inventario'}
Items:
$itemsStr
${draft.clientName != null ? 'Cliente: ${draft.clientName}' : ''}
${draft.saleType != null ? 'Tipo de venta: ${draft.saleType}' : ''}
${draft.description != null ? 'Descripción: ${draft.description}' : ''}
${draft.depositAmount != null ? 'Abono: \$${draft.depositAmount!.toStringAsFixed(2)}' : ''}
Total: \$${draft.total.toStringAsFixed(2)}
''';

    const systemPrompt = '''
Eres el gestor de borradores del Secretario IA. Tu única tarea es interpretar mensajes del usuario sobre un borrador pendiente.

BORRADOR ACTUAL:
{draft}

ACCIONES DISPONIBLES:
1. "confirm" — El usuario quiere confirmar/aceptar el borrador. Sin cambios adicionales.
2. "reject" — El usuario quiere rechazar/cancelar el borrador. Sin cambios adicionales.
3. "modify_items" — El usuario quiere modificar productos del borrador.
4. "change_field" — El usuario quiere cambiar datos generales del borrador (cliente, tipo de venta, descripción, abono).
5. "unrelated" — El mensaje no tiene nada que ver con el borrador.

REGLAS PARA "modify_items":
- "item_changes": lista de cambios a items existentes. Cada cambio: {"index": N, "quantity": N, "unitPrice": N}
- "add_items": lista de nuevos items a agregar. Cada item: {"productName": "...", "quantity": N, "unitPrice": N}
- "remove_indices": lista de índices (0-based) de items a eliminar
- Solo inclí los campos que cambian en cada item
- Si no se especifica unitPrice en un item nuevo, usá 0

REGLAS PARA "change_field":
- "fields": {"clientName": "...", "saleType": "...", "description": "...", "depositAmount": N}
- Solo incluí los campos que cambian

RESPONDE SOLO CON JSON VÁLIDO, SIN TEXTO ADICIONAL.

FORMATO:
{"action":"...","reasoning":"...","item_changes":[{"index":0,"quantity":5}],"add_items":[{"productName":"...","quantity":1}],"remove_indices":[],"fields":{}}
''';

    final prompt = systemPrompt.replaceAll('{draft}', draftStr);

    final request = OpenAIRequest(
      model: AppConstants.openAiModel,
      messages: [
        OpenAIMessage.system(prompt),
        OpenAIMessage.user(userMessage),
      ],
      stream: false,
      temperature: 0.2,
      maxTokens: AppConstants.openAiMaxTokens,
      responseFormat: {'type': 'json_object'},
    );

    try {
      final response = await _llm.chat(request);
      return jsonDecode(response.content) as Map<String, dynamic>;
    } catch (e) {
      return {
        'action': 'unrelated',
        'reasoning': 'Error al interpretar el mensaje: $e',
      };
    }
  }

  Future<void> _applyItemModifications(
    Map<String, dynamic> response, {
    required String turnId,
  }) async {
    final draft = state.pendingDraft;
    if (draft == null) return;

    var items = [...draft.items];

    // Eliminar items por índice
    final removeIndices = (response['remove_indices'] as List?)
            ?.map((e) => e is int ? e : int.tryParse(e.toString()))
            .whereType<int>()
            .toList() ??
        [];
    if (removeIndices.isNotEmpty) {
      final sorted = List<int>.from(removeIndices)..sort((a, b) => b.compareTo(a));
      for (final index in sorted) {
        if (index >= 0 && index < items.length) {
          items.removeAt(index);
        }
      }
    }

    // Modificar items existentes
    final itemChanges = (response['item_changes'] as List?) ?? [];
    for (final change in itemChanges) {
      if (change is! Map) continue;
      final index = change['index'];
      if (index is! int || index < 0 || index >= items.length) continue;
      final num? qty = change['quantity'] != null ? (change['quantity'] as num) : null;
      final num? price = change['unitPrice'] != null
          ? (change['unitPrice'] as num)
          : change['price'] != null
              ? (change['price'] as num)
              : null;
      items[index] = items[index].copyWith(
        quantity: qty?.toDouble(),
        unitPrice: price?.toDouble(),
      );
    }

    // Agregar nuevos items
    final addItems = (response['add_items'] as List?) ?? [];
    for (final item in addItems) {
      if (item is! Map) continue;
      final productName =
          (item['productName'] as String? ?? item['product_name'] as String?)
              ?.trim();
      if (productName == null || productName.isEmpty) continue;
      items.add(DraftItem(
        productId: 'draft_new_${_uuid.v4()}',
        productName: productName,
        quantity: (item['quantity'] != null
                ? (item['quantity'] as num)
                : 1)
            .toDouble(),
        unitPrice: (item['unitPrice'] != null
                ? (item['unitPrice'] as num)
                : (item['price'] != null ? (item['price'] as num) : 0))
            .toDouble(),
      ));
    }

    if (items.isEmpty) {
      cancelDraft();
      return;
    }

    final updatedDraft = draft.copyWith(items: items);

    final responseMsg = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.assistant,
      content: 'Listo, actualicé el borrador. Revisalo y confirmá cuando esté correcto.',
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      pendingDraft: updatedDraft,
      messages: [...state.messages, responseMsg],
    );
    await _logger.logEvent(
      'assistant.draft.updated',
      data: {
        'turnId': turnId,
        'action': 'modify_items',
        'draft': _draftToLog(updatedDraft),
      },
    );
    await _speakIfVoiceMode(responseMsg.content);
  }

  Future<void> _applyFieldChanges(
    Map<String, dynamic> response, {
    required String turnId,
  }) async {
    final draft = state.pendingDraft;
    if (draft == null) return;

    final fields = response['fields'] as Map<String, dynamic>? ?? {};

    final updatedDraft = draft.copyWith(
      clientName: _readField(fields, ['clientName', 'client_name', 'nombreCliente']),
      saleType: _readField(fields, ['saleType', 'sale_type', 'tipoVenta']),
      description: _readField(fields, ['description', 'descripcion']),
      depositAmount: _readNumField(fields, ['depositAmount', 'deposit_amount', 'abono']),
    );

    final responseMsg = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.assistant,
      content: 'Listo, actualicé el borrador. Revisalo y confirmá cuando esté correcto.',
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      pendingDraft: updatedDraft,
      messages: [...state.messages, responseMsg],
    );
    await _logger.logEvent(
      'assistant.draft.updated',
      data: {
        'turnId': turnId,
        'action': 'change_field',
        'draft': _draftToLog(updatedDraft),
      },
    );
    await _speakIfVoiceMode(responseMsg.content);
  }

  String? _readField(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  double? _readNumField(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value.replaceAll(',', '.'));
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  Future<void> _showDraftHelp(
    String text,
    String reasoning, {
    required String turnId,
  }) async {
    final helpMsg = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.assistant,
      content: 'Tenés un borrador pendiente. Podés decir: "confirmar", '
          '"cancelar", "cambia cantidad de [producto] a N", '
          '"agrega N de [producto]", "quita [producto]" '
          'o "cambia cliente a [nombre]".',
      timestamp: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, helpMsg]);
    await _logger.logEvent(
      'assistant.draft.help',
      data: {'turnId': turnId, 'message': text, 'reasoning': reasoning},
    );
    await _speakIfVoiceMode(helpMsg.content);
  }

  void updateDraftItem(int index, {double? quantity, double? unitPrice}) {
    final draft = state.pendingDraft;
    if (draft == null || index < 0 || index >= draft.items.length) return;
    final items = [...draft.items];
    items[index] = items[index].copyWith(
      quantity: quantity != null && quantity > 0 ? quantity : null,
      unitPrice: unitPrice != null && unitPrice >= 0 ? unitPrice : null,
    );
    state = state.copyWith(pendingDraft: draft.copyWith(items: items));
  }

  void cancelDraft() {
    final cancelMsg = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.system,
      content: 'Borrador cancelado.',
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, cancelMsg],
      clearDraft: true,
    );
    // Reanudar loop si modo voz está activo
    if (state.isVoiceMode && _voiceLoopActive) {
      _startListeningLoop();
    }
  }

  void clearConversation() {
    _conversationState = ConversationState.initial();
    state = const AssistantUiState();
  }

  @override
  void dispose() {
    _voiceLoopActive = false;
    _silenceTimer?.cancel();
    super.dispose();
  }

  // ── Helpers privados ─────────────────────────────────────────────────────

  void _addErrorMessage(String text) {
    final errMsg = ChatMessage(
      id: _uuid.v4(),
      type: ChatMessageType.system,
      content: text,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, errMsg],
      isLoading: false,
      isStreaming: false,
      voiceState: VoiceButtonState.idle,
    );
  }

  String _friendlyOpenAIError(OpenAIException e) {
    if (e.statusCode == 401)
      return 'API key inválida. Verificá la configuración.';
    if (e.statusCode == 429)
      return 'Límite de solicitudes alcanzado. Esperá unos segundos.';
    if (e.statusCode >= 500)
      return 'El servicio de IA no está disponible. Intentá más tarde.';
    return 'Error al conectar con el asistente (${e.statusCode}).';
  }

  String _friendlyExecutionError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('caja'))
      return 'No hay caja abierta. Abrí caja antes de registrar.';
    if (msg.contains('bodega')) return 'No hay bodega seleccionada.';
    if (msg.contains('stock'))
      return 'Stock insuficiente para completar la operación.';
    if (msg.contains('fiado'))
      return 'Para ventas al fiado se requiere nombre del cliente.';
    return 'No se pudo completar la operación. Error: ${e.toString().replaceAll('Exception: ', '')}';
  }

  Map<String, dynamic>? _draftToLog(AssistantDraft? draft) {
    if (draft == null) return null;
    return {
      'type': draft.type.name,
      'clientName': draft.clientName,
      'saleType': draft.saleType,
      'description': draft.description,
      'depositAmount': draft.depositAmount,
      'bodegaId': draft.bodegaId,
      'cajaSesionId': draft.cajaSesionId,
      'total': draft.total,
      'items': draft.items
          .map(
            (item) => {
              'productId': item.productId,
              'productName': item.productName,
              'quantity': item.quantity,
              'unitPrice': item.unitPrice,
              'unitCost': item.unitCost,
              'variantId': item.variantId,
              'subtotal': item.subtotal,
            },
          )
          .toList(),
    };
  }

  List<String> _extractClarificationOptions(TurnResult result) {
    final raw = result.updatedState.collectedData['_clarificationOptions'];
    if (raw == null) return const [];
    final value = raw.value;
    if (value is List) return value.whereType<String>().toList();
    return const [];
  }
}

final assistantProvider =
    StateNotifierProvider<AssistantNotifier, AssistantUiState>(
      (ref) => AssistantNotifier(
        ref.watch(turnPipelineProvider),
        ref.watch(draftExecutorProvider),
        ref.watch(speechTranscriberProvider),
        ref.watch(ttsServiceProvider),
        ref.watch(assistantChatLoggerProvider),
        ref.watch(llmClientProvider),
      ),
    );
