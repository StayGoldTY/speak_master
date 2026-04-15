import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class PronunciationPracticeService {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _speech = SpeechToText();

  bool _speechInitialized = false;
  List<LocaleName>? _cachedLocales;

  Future<void> speakReference({
    required String text,
    required String accentPreference,
  }) async {
    if (text.trim().isEmpty) {
      throw StateError('No reference text available.');
    }

    await _tts.awaitSpeakCompletion(true);
    await _tts.stop();
    await _tts.setLanguage(_ttsLanguageForAccent(accentPreference));
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  Future<bool> startListening({
    required String accentPreference,
    required void Function(SpeechRecognitionResult result) onResult,
    required void Function(String message) onError,
    void Function(String status)? onStatus,
  }) async {
    final ready = await _ensureSpeechReady(
      onError: onError,
      onStatus: onStatus,
    );
    if (!ready) {
      return false;
    }

    final localeId = await _resolveLocaleId(accentPreference);
    await _speech.cancel();
    await _speech.listen(
      onResult: onResult,
      localeId: localeId,
      listenFor: const Duration(seconds: 18),
      pauseFor: const Duration(seconds: 3),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
      ),
    );

    return _speech.isListening;
  }

  Future<String> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
    return _speech.lastRecognizedWords.trim();
  }

  Future<void> cancelListening() async {
    await _speech.cancel();
  }

  Future<void> dispose() async {
    await stopSpeaking();
    await cancelListening();
  }

  Future<bool> _ensureSpeechReady({
    required void Function(String message) onError,
    void Function(String status)? onStatus,
  }) async {
    if (_speechInitialized) {
      final hasPermission = await _speech.hasPermission;
      if (!hasPermission) {
        onError('浏览器没有授予麦克风权限。');
      }
      return hasPermission;
    }

    final initialized = await _speech.initialize(
      onError: (error) => onError(error.errorMsg),
      onStatus: onStatus,
      debugLogging: false,
    );
    _speechInitialized = initialized;

    if (!initialized) {
      onError('当前环境没有可用的语音识别能力。');
      return false;
    }

    final hasPermission = await _speech.hasPermission;
    if (!hasPermission) {
      onError('浏览器没有授予麦克风权限。');
      return false;
    }

    return true;
  }

  Future<String?> _resolveLocaleId(String accentPreference) async {
    _cachedLocales ??= await _speech.locales();
    final locales = _cachedLocales!;

    final preferredLocaleIds = accentPreference == 'british'
        ? ['en_GB', 'en-GB']
        : ['en_US', 'en-US'];

    for (final preferred in preferredLocaleIds) {
      for (final locale in locales) {
        if (locale.localeId.toLowerCase() == preferred.toLowerCase()) {
          return locale.localeId;
        }
      }
    }

    for (final locale in locales) {
      if (locale.localeId.toLowerCase().startsWith('en')) {
        return locale.localeId;
      }
    }

    return null;
  }

  String _ttsLanguageForAccent(String accentPreference) {
    return accentPreference == 'british' ? 'en-GB' : 'en-US';
  }
}
