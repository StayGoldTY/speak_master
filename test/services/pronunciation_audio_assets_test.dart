import 'package:flutter_test/flutter_test.dart';
import 'package:speak_master/services/pronunciation_audio_assets.dart';

void main() {
  group('PronunciationAudioLibrary', () {
    test('uses a bundled reference asset before falling back to TTS', () {
      final plan = PronunciationAudioLibrary.resolvePlayback(
        text: 'latte',
        accentPreference: 'american',
      );

      expect(plan.source, PronunciationPlaybackSource.asset);
      expect(
        plan.asset?.assetPath,
        'assets/audio/pronunciation/core/latte_us.wav',
      );
      expect(plan.ttsRate, isNull);
    });

    test('falls back to slower segmented TTS when no asset exists', () {
      final plan = PronunciationAudioLibrary.resolvePlayback(
        text: 'This sentence has no bundled recording yet.',
        accentPreference: 'british',
        speed: PronunciationPlaybackSpeed.slow,
      );

      expect(plan.source, PronunciationPlaybackSource.tts);
      expect(plan.asset, isNull);
      expect(plan.localeId, 'en-GB');
      expect(plan.ttsRate, lessThan(PronunciationAudioLibrary.normalTtsRate));
      expect(plan.segments, ['This sentence has no bundled recording yet.']);
    });
  });
}
