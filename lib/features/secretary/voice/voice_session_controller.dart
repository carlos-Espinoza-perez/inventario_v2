import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/services/app_logger.dart';

import '../presentation/providers/secretary_chat_provider.dart';
import 'secretary_transcriber.dart';
import 'secretary_tts.dart';

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

  const VoiceSessionState({
    this.active = false,
    this.phase = VoicePhase.idle,
    this.partialText = '',
    this.soundLevel = 0,
    this.handsFree = true,
    this.error,
  });

  VoiceSessionState copyWith({
    bool? active,
    VoicePhase? phase,
    String? partialText,
    double? soundLevel,
    bool? handsFree,
    String? error,
    bool clearError = false,
  }) {
    return VoiceSessionState(
      active: active ?? this.active,
      phase: phase ?? this.phase,
      partialText: partialText ?? this.partialText,
      soundLevel: soundLevel ?? this.soundLevel,
      handsFree: handsFree ?? this.handsFree,
      error: clearError ? null : (error ?? this.error),
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
    } catch (_) {
      // Sin sesión activa: velocidad por defecto.
    }
    await _listenLoop(gen);
  }

  /// Cierra el modo voz por completo.
  Future<void> stop() async {
    _generation++;
    _transcriber.cancel();
    await _tts.stop();
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

      state = state.copyWith(phase: VoicePhase.thinking, partialText: text);

      String? reply;
      try {
        reply = await _ref
            .read(secretaryChatProvider.notifier)
            .sendMessage(text, voiceMode: true);
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

      if (!state.handsFree) {
        state = state.copyWith(phase: VoicePhase.idle);
        return;
      }
      // Pausa corta antes de volver a abrir el micrófono: evita que el
      // final del TTS se cuele como entrada.
      await Future.delayed(const Duration(milliseconds: 350));
    }
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
