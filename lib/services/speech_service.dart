import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize speech recognition.
  Future<bool> initializeSpeech() async {
    try {
      _isInitialized = await _speech.initialize(
        // onStatus: (status) => print('Speech Status: $status'),
        // onError: (error) => print('Speech Error: $error'),
      );
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
    return _isInitialized;
  }

  /// Start listening and pass recognized words to a callback.
  Future<void> startListening(Function(String) onResult) async {
    if (!_isInitialized) {
      await initializeSpeech();
    }
    if (_isInitialized) {
      _speech.listen(
        onResult: (val) {
          onResult(val.recognizedWords);
        },
      );
    }
  }

  /// Stop listening.
  Future<void> stopListening() async {
    await _speech.stop();
  }

  /// Check if currently listening.
  bool get isListening => _speech.isListening;
}
