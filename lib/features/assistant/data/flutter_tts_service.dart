import 'package:flutter_tts/flutter_tts.dart';
import '../domain/services/tts_service.dart';

class FlutterTtsService implements TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  @override
  void Function()? onSpeakComplete;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    await _tts.setLanguage('es-ES');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() => onSpeakComplete?.call());
    _initialized = true;
  }

  @override
  Future<void> speak(String text) async {
    await initialize();
    await _tts.stop();
    await _tts.speak(_speakShort(text));
  }

  @override
  Future<void> stop() => _tts.stop();

  @override
  void dispose() {
    _tts.stop();
  }

  // Extrae solo la primera oración para no leer respuestas largas completas
  String _speakShort(String text) {
    const maxChars = 180;
    if (text.length <= maxChars) return text;
    final cutPoints = ['. ', '.\n', '! ', '? '];
    for (final cut in cutPoints) {
      final idx = text.indexOf(cut);
      if (idx > 0 && idx <= maxChars) return text.substring(0, idx + 1);
    }
    return '${text.substring(0, maxChars)}…';
  }
}
