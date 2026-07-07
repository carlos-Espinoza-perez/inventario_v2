import 'package:flutter_tts/flutter_tts.dart';

/// TTS del secretario. Igual al del assistant viejo pero con velocidad
/// configurable desde las preferencias (AiPreferences.ttsRate).
class SecretaryTts {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  double _rate = 1.0;

  void Function()? onSpeakComplete;

  Future<void> initialize() async {
    if (_initialized) return;
    await _tts.setLanguage('es-ES');
    await _applyRate();
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() => onSpeakComplete?.call());
    _initialized = true;
  }

  /// [rate] en escala de preferencias: 1.0 = normal. El plugin usa ~0.5 como
  /// velocidad natural en Android, así que se mapea proporcionalmente.
  Future<void> setRate(double rate) async {
    _rate = rate.clamp(0.5, 2.0);
    if (_initialized) await _applyRate();
  }

  Future<void> _applyRate() => _tts.setSpeechRate(0.5 * _rate);

  Future<void> speak(String text) async {
    await initialize();
    await _tts.stop();
    await _tts.speak(_speakShort(text));
  }

  Future<void> stop() => _tts.stop();

  void dispose() {
    _tts.stop();
  }

  // Solo la primera oración: las respuestas largas no se leen completas.
  String _speakShort(String text) {
    const maxChars = 220;
    if (text.length <= maxChars) return text;
    final cutPoints = ['. ', '.\n', '! ', '? '];
    for (final cut in cutPoints) {
      final idx = text.indexOf(cut);
      if (idx > 0 && idx <= maxChars) return text.substring(0, idx + 1);
    }
    return '${text.substring(0, maxChars)}…';
  }
}
