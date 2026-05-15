import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import '../domain/services/speech_transcriber.dart';

class SpeechToTextTranscriber implements SpeechTranscriber {
  final SpeechToText _stt = SpeechToText();
  Completer<String?>? _completer;
  Timer? _timeoutTimer;
  Timer? _completionTimer;

  @override
  void Function(String partial)? onPartialResult;

  @override
  Future<bool> initialize() => _stt.initialize();

  @override
  Future<String?> transcribe() async {
    _completer = Completer<String?>();

    await _stt.listen(
      onResult: (result) {
        if (!result.finalResult) {
          _completionTimer?.cancel();
          onPartialResult?.call(result.recognizedWords);
        }
        if (result.finalResult && !(_completer?.isCompleted ?? true)) {
          _timeoutTimer?.cancel();
          _completer!.complete(
            result.recognizedWords.isNotEmpty ? result.recognizedWords : null,
          );
        }
      },
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(milliseconds: 5500),
      localeId: 'es_ES',
      listenOptions: SpeechListenOptions(
        cancelOnError: false,
        partialResults: true,
      ),
    );

    _stt.statusListener = (status) {
      if (status == 'done' || status == 'notListening') {
        _completionTimer?.cancel();
        _completionTimer = Timer(const Duration(milliseconds: 900), () {
          if (!(_completer?.isCompleted ?? true)) {
            final words = _stt.lastRecognizedWords;
            _timeoutTimer?.cancel();
            _completer!.complete(words.isNotEmpty ? words : null);
          }
        });
      }
    };

    _timeoutTimer = Timer(const Duration(seconds: 70), () {
      if (!(_completer?.isCompleted ?? true)) {
        final words = _stt.lastRecognizedWords;
        _completer!.complete(words.isNotEmpty ? words : null);
      }
    });

    return _completer!.future;
  }

  @override
  void cancel() {
    _timeoutTimer?.cancel();
    _completionTimer?.cancel();
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
