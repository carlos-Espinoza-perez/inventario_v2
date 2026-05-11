abstract class TtsService {
  Future<void> initialize();
  Future<void> speak(String text);
  Future<void> stop();
  void dispose();

  // Callback que se invoca cuando el TTS termina de hablar
  void Function()? get onSpeakComplete;
  set onSpeakComplete(void Function()? callback);
}
