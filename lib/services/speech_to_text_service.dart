import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextService {
  final SpeechToText _speech = SpeechToText();

  Future<bool> init() async {
    return await _speech.initialize();
  }

  void startListening({
    required Function(String text) onResult,
    required String localeId,
  }) {
    _speech.listen(
      localeId: localeId,
      partialResults: true,
      listenMode: ListenMode.dictation,
      onResult: (result) {
        onResult(result.recognizedWords);
      },
    );
  }

  void stopListening() {
    _speech.stop();
  }

  bool get isListening => _speech.isListening;
}