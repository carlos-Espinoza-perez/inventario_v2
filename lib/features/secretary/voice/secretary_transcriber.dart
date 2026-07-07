import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart';

/// STT nativo para el secretario. A diferencia del transcriptor del
/// assistant viejo (pausa fija de 5.5 s), acá la pausa de fin de frase es
/// configurable: ~1.8 s en conversación para reaccionar rápido.
class SecretaryTranscriber {
  final SpeechToText _stt = SpeechToText();
  bool _available = false;
  Completer<String?>? _completer;
  Timer? _timeoutTimer;
  Timer? _completionTimer;

  /// Parciales en vivo para el HUD.
  void Function(String partial)? onPartialResult;

  /// Nivel de sonido (0-1 aprox) para animar el micrófono.
  void Function(double level)? onSoundLevel;

  Future<bool> initialize() async {
    if (_available) return true;
    _available = await _stt.initialize();
    return _available;
  }

  bool get isListening => _stt.isListening;

  /// Escucha hasta detectar fin de frase (pausa de [pauseFor]) o [listenFor]
  /// máximo. Devuelve el texto final o null si no se reconoció nada.
  Future<String?> listen({
    Duration pauseFor = const Duration(milliseconds: 1800),
    Duration listenFor = const Duration(seconds: 30),
  }) async {
    if (!await initialize()) return null;

    _completer = Completer<String?>();

    _stt.statusListener = (status) {
      // El engine nativo a veces cierra sin emitir finalResult: rescatamos
      // las últimas palabras reconocidas tras una gracia corta.
      if (status == 'done' || status == 'notListening') {
        _completionTimer?.cancel();
        _completionTimer = Timer(const Duration(milliseconds: 400), () {
          _complete(_stt.lastRecognizedWords);
        });
      }
    };

    await _stt.listen(
      onResult: (result) {
        if (result.finalResult) {
          _complete(result.recognizedWords);
        } else {
          _completionTimer?.cancel();
          onPartialResult?.call(result.recognizedWords);
        }
      },
      onSoundLevelChange: (level) =>
          onSoundLevel?.call((level / 10).clamp(0.0, 1.0)),
      listenFor: listenFor,
      pauseFor: pauseFor,
      localeId: 'es_ES',
      listenOptions: SpeechListenOptions(
        cancelOnError: false,
        partialResults: true,
      ),
    );

    _timeoutTimer = Timer(listenFor + const Duration(seconds: 5), () {
      _complete(_stt.lastRecognizedWords);
    });

    return _completer!.future;
  }

  /// Fuerza el cierre de la frase actual (tap en el micrófono).
  Future<void> stopListening() => _stt.stop();

  void _complete(String words) {
    _timeoutTimer?.cancel();
    _completionTimer?.cancel();
    if (!(_completer?.isCompleted ?? true)) {
      final trimmed = words.trim();
      _completer!.complete(trimmed.isNotEmpty ? trimmed : null);
    }
  }

  void cancel() {
    _timeoutTimer?.cancel();
    _completionTimer?.cancel();
    _stt.cancel();
    if (!(_completer?.isCompleted ?? true)) {
      _completer!.complete(null);
    }
  }

  void dispose() => cancel();
}
