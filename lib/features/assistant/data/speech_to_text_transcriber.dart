import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import '../domain/services/speech_transcriber.dart';

class SpeechToTextTranscriber implements SpeechTranscriber {
  final SpeechToText _stt = SpeechToText();
  Completer<String?>? _completer;

  // Callback para mostrar transcripción parcial en tiempo real
  void Function(String partial)? onPartialResult;

  @override
  Future<bool> initialize() => _stt.initialize();

  @override
  Future<String?> transcribe() async {
    _completer = Completer<String?>();

    await _stt.listen(
      onResult: (result) {
        if (!result.finalResult) {
          onPartialResult?.call(result.recognizedWords);
        }
        if (result.finalResult && !(_completer?.isCompleted ?? true)) {
          _completer!.complete(
            result.recognizedWords.isNotEmpty ? result.recognizedWords : null,
          );
        }
      },
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
      localeId: 'es_ES',
      listenOptions: SpeechListenOptions(cancelOnError: true),
    );

    _stt.statusListener = (status) {
      if (status == 'done' || status == 'notListening') {
        if (!(_completer?.isCompleted ?? true)) {
          final words = _stt.lastRecognizedWords;
          _completer!.complete(words.isNotEmpty ? words : null);
        }
      }
    };

    return _completer!.future;
  }

  @override
  void cancel() {
    _stt.cancel();
    if (!(_completer?.isCompleted ?? true)) {
      _completer!.complete(null);
    }
  }

  @override
  void dispose() {
    cancel();
  }
}
