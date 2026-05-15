abstract class SpeechTranscriber {
  Future<bool> initialize();
  Future<String?> transcribe();
  void cancel();
  void dispose();
  void Function(String partial)? onPartialResult;
}
