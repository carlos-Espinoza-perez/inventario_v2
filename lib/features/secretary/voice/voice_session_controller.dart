import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/core/services/app_logger.dart';

import '../presentation/providers/draft_provider.dart';
import '../presentation/providers/secretary_chat_provider.dart';
import 'push_to_talk.dart';
import 'secretary_transcriber.dart';
import 'secretary_tts.dart';
import 'tool_announcements.dart';
import 'voice_confirmation.dart';

/// Pausa de voz configurada en Preferencias (extraJson.voicePauseMs),
/// acotada entre 1.5 y 6 s. Compartida por el controlador y la pantalla
/// de preferencias.
int voicePauseMsFromPrefs(AiPreference prefs) {
  try {
    final extra = prefs.extraJson != null
        ? jsonDecode(prefs.extraJson!) as Map<String, dynamic>
        : const <String, dynamic>{};
    final ms = (extra['voicePauseMs'] as num?)?.toInt() ?? 3000;
    return ms.clamp(1500, 6000);
  } catch (_) {
    return 3000;
  }
}

/// Preferencia "Aviso al consultar" (extraJson.toolAnnounce, default true):
/// acuse hablado corto y local cuando el motor llama una herramienta en
/// modo voz (SEC-IA-002 punto 5).
bool toolAnnounceFromPrefs(AiPreference prefs) {
  try {
    final extra = prefs.extraJson != null
        ? jsonDecode(prefs.extraJson!) as Map<String, dynamic>
        : const <String, dynamic>{};
    return (extra['toolAnnounce'] as bool?) ?? true;
  } catch (_) {
    return true;
  }
}

/// Preferencia "Confirmar por voz" (extraJson.voiceConfirm, default false):
/// habilita decir "confirmar"/"sí" tras el resumen hablado de un borrador
/// para ejecutarlo, y elegir candidatos ambiguos por número/ordinal
/// (SEC-IA-002 punto 4).
bool voiceConfirmFromPrefs(AiPreference prefs) {
  try {
    final extra = prefs.extraJson != null
        ? jsonDecode(prefs.extraJson!) as Map<String, dynamic>
        : const <String, dynamic>{};
    return (extra['voiceConfirm'] as bool?) ?? false;
  } catch (_) {
    return false;
  }
}

/// Preferencia "Modo de escucha" (extraJson.listenMode: 'handsFree' |
/// 'pushToTalk', default 'handsFree'). SEC-IA-002 punto 1.
enum ListenMode { handsFree, pushToTalk }

ListenMode listenModeFromPrefs(AiPreference prefs) {
  try {
    final extra = prefs.extraJson != null
        ? jsonDecode(prefs.extraJson!) as Map<String, dynamic>
        : const <String, dynamic>{};
    return extra['listenMode'] == 'pushToTalk'
        ? ListenMode.pushToTalk
        : ListenMode.handsFree;
  } catch (_) {
    return ListenMode.handsFree;
  }
}

enum VoicePhase { idle, listening, thinking, speaking }

class VoiceSessionState {
  /// Overlay de voz visible.
  final bool active;
  final VoicePhase phase;

  /// Transcripción parcial en vivo.
  final String partialText;

  /// Nivel de sonido para animar el micrófono (0-1).
  final double soundLevel;

  /// Loop manos libres: tras hablar la respuesta vuelve a escuchar.
  final bool handsFree;
  final String? error;

  /// Modo de escucha vigente (Preferencias), leído al abrir el modo voz.
  final ListenMode listenMode;

  /// En modo "mantener para hablar": true mientras el dedo está fuera del
  /// botón (soltar en este estado cancela en vez de enviar). Solo para
  /// feedback visual.
  final bool holdCancelling;

  const VoiceSessionState({
    this.active = false,
    this.phase = VoicePhase.idle,
    this.partialText = '',
    this.soundLevel = 0,
    this.handsFree = true,
    this.error,
    this.listenMode = ListenMode.handsFree,
    this.holdCancelling = false,
  });

  bool get isPushToTalk => listenMode == ListenMode.pushToTalk;

  VoiceSessionState copyWith({
    bool? active,
    VoicePhase? phase,
    String? partialText,
    double? soundLevel,
    bool? handsFree,
    String? error,
    ListenMode? listenMode,
    bool? holdCancelling,
    bool clearError = false,
  }) {
    return VoiceSessionState(
      active: active ?? this.active,
      phase: phase ?? this.phase,
      partialText: partialText ?? this.partialText,
      soundLevel: soundLevel ?? this.soundLevel,
      handsFree: handsFree ?? this.handsFree,
      error: clearError ? null : (error ?? this.error),
      listenMode: listenMode ?? this.listenMode,
      holdCancelling: holdCancelling ?? this.holdCancelling,
    );
  }
}

/// Máquina de estados del modo voz:
/// idle → listening → thinking → speaking → listening (manos libres) | idle.
/// Barge-in: tocar el círculo mientras habla corta el TTS y vuelve a escuchar.
class VoiceSessionController extends StateNotifier<VoiceSessionState> {
  final Ref _ref;
  final SecretaryTranscriber _transcriber = SecretaryTranscriber();
  final SecretaryTts _tts = SecretaryTts();

  /// Pausa de silencio que cierra la frase y envía. Configurable en
  /// Preferencias (extraJson.voicePauseMs); default 3 s para poder pensar
  /// a mitad de frase sin que se dispare el envío.
  Duration _pauseFor = const Duration(milliseconds: 3000);

  /// Aviso hablado corto al detectar una tool call (Preferencias →
  /// "Aviso al consultar"). Se lee al abrir el modo voz.
  bool _announceTools = true;

  /// "Confirmar por voz" (Preferencias, default desactivada). Se lee al
  /// abrir el modo voz.
  bool _voiceConfirmEnabled = false;

  /// Borrador que quedó activo tras el último turno y la ventana en la que
  /// "confirmar"/"sí"/un ordinal se interpretan como respuesta a SU
  /// resumen (no como un mensaje libre nuevo). Se arma recién después de
  /// que el TTS termina de leer el resumen.
  String? _pendingConfirmDraftId;
  DateTime? _pendingConfirmExpiresAt;

  /// Duración de escucha en modo "mantener para hablar": el fin de turno lo
  /// decide el usuario al soltar, no una pausa de silencio, así que se usa
  /// el máximo razonable para que el plugin no corte solo.
  static const Duration _pushToTalkListenDuration = Duration(minutes: 2);

  Future<String?>? _holdListenFuture;
  DateTime? _holdStartedAt;

  /// Identifica la sesión de voz vigente: al cerrar/reiniciar se invalida
  /// para que los loops pendientes no sigan corriendo.
  int _generation = 0;

  VoiceSessionController(this._ref) : super(const VoiceSessionState()) {
    _transcriber.onPartialResult = (partial) {
      if (state.active && state.phase == VoicePhase.listening) {
        state = state.copyWith(partialText: partial);
      }
    };
    _transcriber.onSoundLevel = (level) {
      if (state.active && state.phase == VoicePhase.listening) {
        state = state.copyWith(soundLevel: level);
      }
    };
  }

  /// Abre el modo voz y empieza a escuchar.
  Future<void> start({bool handsFree = true}) async {
    _generation++;
    final gen = _generation;
    state = VoiceSessionState(
      active: true,
      phase: VoicePhase.listening,
      handsFree: handsFree,
    );

    final ok = await _transcriber.initialize();
    if (!ok) {
      state = state.copyWith(
        phase: VoicePhase.idle,
        error: 'No se pudo acceder al micrófono. Revisá los permisos.',
      );
      return;
    }
    await _tts.initialize();
    try {
      final prefs =
          await _ref.read(chatRepositoryProvider).getOrCreatePreferences();
      if (!prefs.voiceEnabled) {
        state = state.copyWith(
          phase: VoicePhase.idle,
          error: 'El modo voz está desactivado en Preferencias.',
        );
        return;
      }
      await _tts.setRate(prefs.ttsRate);
      _pauseFor = Duration(milliseconds: voicePauseMsFromPrefs(prefs));
      _announceTools = toolAnnounceFromPrefs(prefs);
      _voiceConfirmEnabled = voiceConfirmFromPrefs(prefs);
      state = state.copyWith(listenMode: listenModeFromPrefs(prefs));
    } catch (_) {
      // Sin sesión activa: velocidad y avisos por defecto.
    }
    _pendingConfirmDraftId = null;
    _pendingConfirmExpiresAt = null;

    if (state.isPushToTalk) {
      // "Mantener para hablar": queda a la espera de que mantengan
      // presionado el círculo (beginHold/endHold); no escucha sola.
      state = state.copyWith(phase: VoicePhase.idle);
      return;
    }
    await _listenLoop(gen);
  }

  /// Cierra el modo voz por completo.
  Future<void> stop() async {
    _generation++;
    _transcriber.cancel();
    await _tts.stop();
    _holdListenFuture = null;
    _holdStartedAt = null;
    _pendingConfirmDraftId = null;
    _pendingConfirmExpiresAt = null;
    state = const VoiceSessionState();
  }

  void toggleHandsFree() {
    state = state.copyWith(handsFree: !state.handsFree);
  }

  /// Tap en el círculo central según la fase:
  /// - escuchando → cierra la frase ya (no esperar la pausa);
  /// - hablando → barge-in: corta el TTS y vuelve a escuchar;
  /// - idle → vuelve a escuchar.
  Future<void> tapMic() async {
    switch (state.phase) {
      case VoicePhase.listening:
        await _transcriber.stopListening();
      case VoicePhase.speaking:
        await _tts.stop();
        await _listenLoop(_generation);
      case VoicePhase.idle:
        state = state.copyWith(clearError: true);
        await _listenLoop(_generation);
      case VoicePhase.thinking:
        break; // El turno ya está en curso.
    }
  }

  /// Loop de escucha en modo manos libres (el otro modo es push-to-talk,
  /// ver [beginHold]/[endHold]).
  Future<void> _listenLoop(int gen) async {
    while (mounted && gen == _generation && state.active) {
      state = state.copyWith(
        phase: VoicePhase.listening,
        partialText: '',
        soundLevel: 0,
        clearError: true,
      );

      final text = await _transcriber.listen(pauseFor: _pauseFor);
      if (!mounted || gen != _generation || !state.active) return;

      if (text == null || text.trim().isEmpty) {
        // Silencio: pasamos a pausa (no escuchar indefinidamente gasta
        // batería); un tap en el micrófono retoma.
        state = state.copyWith(phase: VoicePhase.idle, partialText: '');
        return;
      }

      if (await _maybeHandleAsConfirmation(text, gen)) {
        if (!mounted || gen != _generation || !state.active) return;
        continue;
      }

      await _runTurn(text, gen);
      if (!mounted || gen != _generation || !state.active) return;

      if (!state.handsFree) {
        state = state.copyWith(phase: VoicePhase.idle);
        return;
      }
      // Pausa corta antes de volver a abrir el micrófono: evita que el
      // final del TTS se cuele como entrada.
      await Future.delayed(const Duration(milliseconds: 350));
    }
  }

  // -------------------------------------------------------------------
  // Modo "mantener para hablar" (push-to-talk, SEC-IA-002 punto 1)
  // -------------------------------------------------------------------

  /// Empieza a escuchar mientras el usuario mantiene presionado el círculo.
  /// Sin pausa de silencio: el fin de turno lo decide [endHold].
  Future<void> beginHold() async {
    if (!state.isPushToTalk) return;
    if (state.phase == VoicePhase.speaking) {
      // Barge-in: interrumpe lo que esté hablando y empieza a escuchar.
      await _tts.stop();
    } else if (state.phase != VoicePhase.idle) {
      return; // Ya está escuchando o pensando: ignorar otro press.
    }
    _holdStartedAt = DateTime.now();
    state = state.copyWith(
      phase: VoicePhase.listening,
      partialText: '',
      soundLevel: 0,
      holdCancelling: false,
      clearError: true,
    );
    _holdListenFuture = _transcriber.listen(
      pauseFor: _pushToTalkListenDuration,
      listenFor: _pushToTalkListenDuration,
    );
  }

  /// Mientras se mantiene presionado: true si el dedo está fuera del botón
  /// (soltar así cancela). Solo feedback visual — la decisión real la toma
  /// [endHold] con la posición al soltar/cancelar.
  void updateHoldCancelling(bool outside) {
    if (!state.isPushToTalk || state.phase != VoicePhase.listening) return;
    if (state.holdCancelling != outside) {
      state = state.copyWith(holdCancelling: outside);
    }
  }

  /// Suelta el botón: cierra la escucha y, salvo que corresponda descartar
  /// (ver [shouldDiscardHold]), procesa el turno igual que en manos libres.
  Future<void> endHold({bool forceCancel = false}) async {
    final future = _holdListenFuture;
    final startedAt = _holdStartedAt;
    final slidOutside = forceCancel || state.holdCancelling;
    _holdListenFuture = null;
    _holdStartedAt = null;
    if (future == null || startedAt == null) return;

    final gen = _generation;
    final heldMs = DateTime.now().difference(startedAt).inMilliseconds;
    await _transcriber.stopListening();
    final text = await future;
    if (!mounted || gen != _generation || !state.active) return;

    if (shouldDiscardHold(
      heldMs: heldMs,
      slidOutside: slidOutside,
      recognizedText: text,
    )) {
      state = state.copyWith(
        phase: VoicePhase.idle,
        partialText: '',
        holdCancelling: false,
      );
      return;
    }

    final trimmed = text!.trim();
    if (await _maybeHandleAsConfirmation(trimmed, gen)) {
      if (!mounted || gen != _generation || !state.active) return;
      state = state.copyWith(phase: VoicePhase.idle);
      return;
    }
    await _runTurn(trimmed, gen);
    if (!mounted || gen != _generation || !state.active) return;
    // Push-to-talk es de a un turno por hold: siempre vuelve a idle, sin
    // auto-relisten (eso es lo que lo distingue de manos libres).
    if (state.phase != VoicePhase.idle) {
      state = state.copyWith(phase: VoicePhase.idle);
    }
  }

  // -------------------------------------------------------------------
  // Lógica de turno compartida por ambos modos de escucha
  // -------------------------------------------------------------------

  /// Ventana de "confirmar por voz" abierta: intercepta antes de mandarlo
  /// como turno normal al LLM. true = lo consumió (confirmó, rechazó o
  /// eligió candidato); false = no matcheó nada conocido y debe tratarse
  /// como mensaje libre.
  Future<bool> _maybeHandleAsConfirmation(String text, int gen) async {
    if (!_voiceConfirmEnabled ||
        _pendingConfirmDraftId == null ||
        _pendingConfirmExpiresAt == null ||
        !DateTime.now().isBefore(_pendingConfirmExpiresAt!)) {
      return false;
    }
    final handled = await _handleVoiceConfirmationInput(text);
    if (!mounted || gen != _generation || !state.active) return true;
    if (handled) return true;
    _pendingConfirmDraftId = null;
    _pendingConfirmExpiresAt = null;
    return false;
  }

  /// Manda [text] como turno normal al motor y habla la respuesta. Cualquier
  /// modo de escucha pasa por acá.
  Future<void> _runTurn(String text, int gen) async {
    state = state.copyWith(phase: VoicePhase.thinking, partialText: text);

    String? reply;
    try {
      reply = await _ref.read(secretaryChatProvider.notifier).sendMessage(
            text,
            voiceMode: true,
            onToolAnnounce: _announceTool,
          );
    } catch (e, st) {
      AppLogger.error('[Secretary][Voz] Error en turno de voz', e, st);
    }
    if (!mounted || gen != _generation || !state.active) return;

    if (reply == null) {
      state = state.copyWith(
        phase: VoicePhase.idle,
        error: 'No pude responder. Tocá el micrófono para reintentar.',
      );
      return;
    }

    state = state.copyWith(phase: VoicePhase.speaking);
    await _speakAndWait(reply);
    if (!mounted || gen != _generation || !state.active) return;

    // Recién ahora, con el resumen ya leído completo, se abre la ventana de
    // 15 s para "confirmar"/"sí"/un candidato por voz.
    if (_voiceConfirmEnabled) {
      final pendingDraftId = _ref.read(secretaryChatProvider).pendingDraftId;
      if (pendingDraftId != null) {
        _pendingConfirmDraftId = pendingDraftId;
        _pendingConfirmExpiresAt =
            DateTime.now().add(const Duration(seconds: 15));
      } else {
        _pendingConfirmDraftId = null;
        _pendingConfirmExpiresAt = null;
      }
    }
  }

  /// Interpreta el enunciado dentro de la ventana de confirmación por voz.
  /// true = lo manejó (confirmó, rechazó o eligió candidato) y el loop debe
  /// seguir escuchando sin mandarlo como mensaje libre; false = no matcheó
  /// nada conocido, así que se manda como turno normal.
  Future<bool> _handleVoiceConfirmationInput(String text) async {
    if (VoiceConfirmationMatcher.isConfirmation(text)) {
      await _confirmPendingDraft();
      return true;
    }
    if (VoiceConfirmationMatcher.isRejection(text)) {
      await _discardPendingDraft();
      return true;
    }
    final choice = VoiceConfirmationMatcher.parseChoice(text);
    if (choice != null) {
      await _resolveAmbiguityByVoice(choice);
      return true;
    }
    return false;
  }

  Future<void> _confirmPendingDraft() async {
    final draftId = _pendingConfirmDraftId;
    _pendingConfirmDraftId = null;
    _pendingConfirmExpiresAt = null;
    if (draftId == null) return;
    state = state.copyWith(phase: VoicePhase.speaking);
    await _speakAndWait('Registrando.');
    // Mismo camino que el botón Confirmar de la tarjeta: DraftEngine.execute
    // vía SecretaryChatNotifier.confirmDraft, nunca una tool del LLM.
    await _ref.read(secretaryChatProvider.notifier).confirmDraft(draftId);
  }

  Future<void> _discardPendingDraft() async {
    final draftId = _pendingConfirmDraftId;
    _pendingConfirmDraftId = null;
    _pendingConfirmExpiresAt = null;
    if (draftId == null) return;
    await _ref.read(secretaryChatProvider.notifier).discardDraft(draftId);
    state = state.copyWith(phase: VoicePhase.speaking);
    await _speakAndWait('Borrador descartado.');
  }

  /// Elige el candidato [choice] (1-based) para la primera fila ambigua del
  /// borrador pendiente. Renueva la ventana: puede quedar otra fila
  /// ambigua o faltar confirmar.
  Future<void> _resolveAmbiguityByVoice(int choice) async {
    final draftId = _pendingConfirmDraftId;
    if (draftId == null) return;
    final items =
        await _ref.read(driftDatabaseProvider).secretaryDao.getDraftItems(draftId);
    SecretaryDraftItem? pending;
    for (final item in items) {
      if (item.status == 'needs_review' && item.candidatesJson != null) {
        pending = item;
        break;
      }
    }
    state = state.copyWith(phase: VoicePhase.speaking);
    if (pending == null) {
      await _speakAndWait('No hay nada pendiente de elegir.');
      return;
    }
    final candidates = jsonDecode(pending.candidatesJson!) as List;
    if (choice < 1 || choice > candidates.length) {
      await _speakAndWait('No tengo esa opción. Decime el número de la lista.');
      return;
    }
    final chosen = Map<String, dynamic>.from(candidates[choice - 1] as Map);
    await _ref.read(draftEngineProvider).updateItem(
          pending.id,
          productoId: chosen['id'] as String,
        );
    await _speakAndWait('Listo, elegí ${chosen['nombre']}.');
    _pendingConfirmExpiresAt = DateTime.now().add(const Duration(seconds: 15));
  }

  /// Acuse hablado corto (local, sin LLM) al detectar una tool call. No
  /// bloquea el loop: se reproduce mientras el motor sigue trabajando y la
  /// respuesta final la interrumpe naturalmente (`_tts.speak` hace stop
  /// antes de hablar).
  void _announceTool(String toolId) {
    if (!_announceTools) return;
    unawaited(_tts.speak(toolAnnouncementFor(toolId)));
  }

  /// Habla y espera a que termine (o a que un barge-in lo corte).
  Future<void> _speakAndWait(String text) async {
    final gen = _generation;
    var done = false;
    _tts.onSpeakComplete = () => done = true;
    await _tts.speak(text);
    // Espera activa liviana: el plugin solo ofrece callback global.
    while (!done &&
        mounted &&
        gen == _generation &&
        state.active &&
        state.phase == VoicePhase.speaking) {
      await Future.delayed(const Duration(milliseconds: 120));
    }
  }

  @override
  void dispose() {
    _generation++;
    _transcriber.dispose();
    _tts.dispose();
    super.dispose();
  }
}

final voiceSessionProvider =
    StateNotifierProvider<VoiceSessionController, VoiceSessionState>((ref) {
  return VoiceSessionController(ref);
});
