import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'pronunciation_audio_assets.dart';

class LearnerRecording {
  final String path;
  final Duration duration;

  const LearnerRecording({required this.path, required this.duration});

  String get durationLabel {
    final totalSeconds = duration.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class PronunciationPracticeService {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _speech = SpeechToText();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _referencePlayer = AudioPlayer();
  final AudioPlayer _recordingPlayer = AudioPlayer();
  final StreamController<void> _recordingPlaybackCompletedController =
      StreamController<void>.broadcast();

  bool _speechInitialized = false;
  List<LocaleName>? _cachedLocales;

  PronunciationPracticeService() {
    _referencePlayer.setReleaseMode(ReleaseMode.stop);
    _recordingPlayer.setReleaseMode(ReleaseMode.stop);
    _recordingPlayer.onPlayerComplete.listen((_) {
      _recordingPlaybackCompletedController.add(null);
    });
  }

  Stream<void> get recordingPlaybackCompleted =>
      _recordingPlaybackCompletedController.stream;

  Future<void> speakReference({
    required String text,
    required String accentPreference,
    PronunciationPlaybackSpeed speed = PronunciationPlaybackSpeed.normal,
    PronunciationVoiceGender voiceGender = PronunciationVoiceGender.neutral,
  }) async {
    if (text.trim().isEmpty) {
      throw StateError('No reference text available.');
    }

    final plan = PronunciationAudioLibrary.resolvePlayback(
      text: text,
      accentPreference: accentPreference,
      speed: speed,
      voiceGender: voiceGender,
    );

    await _tts.awaitSpeakCompletion(true);
    await _tts.stop();
    await _referencePlayer.stop();

    if (plan.source == PronunciationPlaybackSource.asset &&
        plan.asset != null) {
      await _referencePlayer.play(
        AssetSource(PronunciationAudioLibrary.assetSourcePath(plan.asset!)),
      );
      return;
    }

    await _tts.setLanguage(plan.localeId);
    await _tryApplyPreferredVoice(plan);
    await _tts.setSpeechRate(
      plan.ttsRate ?? PronunciationAudioLibrary.normalTtsRate,
    );
    await _tts.setPitch(plan.ttsPitch ?? 1.0);
    await _tts.setVolume(1.0);

    for (final segment in plan.segments) {
      await _tts.speak(segment);
      if (plan.speed == PronunciationPlaybackSpeed.slow) {
        await Future<void>.delayed(const Duration(milliseconds: 180));
      }
    }
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
    await _referencePlayer.stop();
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

  Future<bool> startLearnerRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      return false;
    }

    final encoder = await _resolveRecordingEncoder();
    if (encoder == null) {
      throw StateError('No supported audio encoder available.');
    }

    await stopSpeaking();
    await stopLearnerRecordingPlayback();

    await _recorder.start(
      RecordConfig(
        encoder: encoder,
        numChannels: 1,
        autoGain: true,
        echoCancel: true,
        noiseSuppress: true,
      ),
      path: await _buildRecordingPath(encoder),
    );

    return true;
  }

  Future<LearnerRecording?> stopLearnerRecording({
    required Duration duration,
  }) async {
    final path = await _recorder.stop();
    if (path == null || path.trim().isEmpty) {
      return null;
    }

    return LearnerRecording(path: path.trim(), duration: duration);
  }

  Future<void> cancelLearnerRecording() async {
    await _recorder.cancel();
  }

  Future<void> playLearnerRecording(String path) async {
    await _recordingPlayer.stop();
    await _recordingPlayer.play(_recordingSource(path));
  }

  Future<void> stopLearnerRecordingPlayback() async {
    await _recordingPlayer.stop();
  }

  Future<void> dispose() async {
    await stopSpeaking();
    await cancelListening();
    await cancelLearnerRecording();
    await stopLearnerRecordingPlayback();
    await _recorder.dispose();
    await _referencePlayer.dispose();
    await _recordingPlayer.dispose();
    await _recordingPlaybackCompletedController.close();
  }

  Future<bool> _ensureSpeechReady({
    required void Function(String message) onError,
    void Function(String status)? onStatus,
  }) async {
    if (_speechInitialized) {
      final hasPermission = await _speech.hasPermission;
      if (!hasPermission) {
        onError('Browser microphone permission is not granted.');
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
      onError(
        'Speech recognition is not available in the current environment.',
      );
      return false;
    }

    final hasPermission = await _speech.hasPermission;
    if (!hasPermission) {
      onError('Browser microphone permission is not granted.');
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

  Future<AudioEncoder?> _resolveRecordingEncoder() async {
    const preferredEncoders = [
      AudioEncoder.aacLc,
      AudioEncoder.opus,
      AudioEncoder.wav,
      AudioEncoder.flac,
      AudioEncoder.pcm16bits,
    ];

    for (final encoder in preferredEncoders) {
      final supported = await _recorder.isEncoderSupported(encoder);
      if (supported) {
        return encoder;
      }
    }

    return null;
  }

  Future<String> _buildRecordingPath(AudioEncoder encoder) async {
    if (kIsWeb) {
      return '';
    }

    final directory = await getTemporaryDirectory();
    final extension = switch (encoder) {
      AudioEncoder.aacLc || AudioEncoder.aacEld || AudioEncoder.aacHe => 'm4a',
      AudioEncoder.amrNb || AudioEncoder.amrWb => '3gp',
      AudioEncoder.opus => 'opus',
      AudioEncoder.flac => 'flac',
      AudioEncoder.wav => 'wav',
      AudioEncoder.pcm16bits => 'pcm',
    };

    return '${directory.path}/pronunciation_${DateTime.now().millisecondsSinceEpoch}.$extension';
  }

  Source _recordingSource(String path) {
    return kIsWeb ? UrlSource(path) : DeviceFileSource(path);
  }

  Future<void> _tryApplyPreferredVoice(PronunciationPlaybackPlan plan) async {
    try {
      final voices = await _tts.getVoices;
      if (voices is! List) {
        return;
      }

      final candidates = voices.whereType<Map>().where((voice) {
        final locale = voice['locale']?.toString().toLowerCase() ?? '';
        return locale == plan.localeId.toLowerCase();
      }).toList();

      if (candidates.isEmpty) {
        return;
      }

      Map<dynamic, dynamic> selected = candidates.first;
      if (plan.voiceGender != PronunciationVoiceGender.neutral) {
        final genderNeedle = plan.voiceGender.name.toLowerCase();
        selected = candidates.firstWhere((voice) {
          final name = voice['name']?.toString().toLowerCase() ?? '';
          final gender = voice['gender']?.toString().toLowerCase() ?? '';
          return name.contains(genderNeedle) || gender.contains(genderNeedle);
        }, orElse: () => candidates.first);
      }

      final name = selected['name']?.toString();
      final locale = selected['locale']?.toString();
      if (name != null && locale != null) {
        await _tts.setVoice({'name': name, 'locale': locale});
      }
    } catch (_) {
      // Voice enumeration is platform-specific; language/rate/pitch are enough
      // for the fallback path when a detailed voice cannot be selected.
    }
  }
}
