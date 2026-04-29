enum PronunciationPlaybackSource { asset, tts }

enum PronunciationPlaybackSpeed { normal, slow }

enum PronunciationVoiceGender { neutral, female, male }

class PronunciationAudioAsset {
  final String id;
  final String text;
  final String accentPreference;
  final String assetPath;

  const PronunciationAudioAsset({
    required this.id,
    required this.text,
    required this.accentPreference,
    required this.assetPath,
  });
}

class PronunciationPlaybackPlan {
  final PronunciationPlaybackSource source;
  final PronunciationAudioAsset? asset;
  final String text;
  final String accentPreference;
  final PronunciationPlaybackSpeed speed;
  final PronunciationVoiceGender voiceGender;
  final String localeId;
  final double? ttsRate;
  final double? ttsPitch;
  final List<String> segments;

  const PronunciationPlaybackPlan({
    required this.source,
    required this.asset,
    required this.text,
    required this.accentPreference,
    required this.speed,
    required this.voiceGender,
    required this.localeId,
    required this.ttsRate,
    required this.ttsPitch,
    required this.segments,
  });
}

class PronunciationAudioLibrary {
  PronunciationAudioLibrary._();

  static const normalTtsRate = 0.46;
  static const slowTtsRate = 0.34;

  static const List<PronunciationAudioAsset> bundledAssets = [
    PronunciationAudioAsset(
      id: 'latte_us',
      text: 'latte',
      accentPreference: 'american',
      assetPath: 'assets/audio/pronunciation/core/latte_us.wav',
    ),
    PronunciationAudioAsset(
      id: 'oat_milk_us',
      text: 'oat milk',
      accentPreference: 'american',
      assetPath: 'assets/audio/pronunciation/core/oat_milk_us.wav',
    ),
    PronunciationAudioAsset(
      id: 'three_us',
      text: 'three',
      accentPreference: 'american',
      assetPath: 'assets/audio/pronunciation/core/three_us.wav',
    ),
    PronunciationAudioAsset(
      id: 'thin_us',
      text: 'thin',
      accentPreference: 'american',
      assetPath: 'assets/audio/pronunciation/core/thin_us.wav',
    ),
    PronunciationAudioAsset(
      id: 'thursday_us',
      text: 'thursday',
      accentPreference: 'american',
      assetPath: 'assets/audio/pronunciation/core/thursday_us.wav',
    ),
  ];

  static PronunciationPlaybackPlan resolvePlayback({
    required String text,
    required String accentPreference,
    PronunciationPlaybackSpeed speed = PronunciationPlaybackSpeed.normal,
    PronunciationVoiceGender voiceGender = PronunciationVoiceGender.neutral,
  }) {
    final normalizedAccent = _normalizeAccent(accentPreference);
    final normalizedText = _normalizeText(text);
    final asset = bundledAssets
        .where(
          (item) =>
              item.accentPreference == normalizedAccent &&
              _normalizeText(item.text) == normalizedText,
        )
        .firstOrNull;

    if (asset != null && speed == PronunciationPlaybackSpeed.normal) {
      return PronunciationPlaybackPlan(
        source: PronunciationPlaybackSource.asset,
        asset: asset,
        text: text.trim(),
        accentPreference: normalizedAccent,
        speed: speed,
        voiceGender: voiceGender,
        localeId: _localeForAccent(normalizedAccent),
        ttsRate: null,
        ttsPitch: null,
        segments: [text.trim()],
      );
    }

    return PronunciationPlaybackPlan(
      source: PronunciationPlaybackSource.tts,
      asset: null,
      text: text.trim(),
      accentPreference: normalizedAccent,
      speed: speed,
      voiceGender: voiceGender,
      localeId: _localeForAccent(normalizedAccent),
      ttsRate: speed == PronunciationPlaybackSpeed.slow
          ? slowTtsRate
          : normalTtsRate,
      ttsPitch: _pitchForVoice(voiceGender),
      segments: _segmentsForTts(text),
    );
  }

  static String assetSourcePath(PronunciationAudioAsset asset) {
    return asset.assetPath.replaceFirst('assets/', '');
  }

  static String _normalizeAccent(String value) {
    return value.toLowerCase() == 'british' ? 'british' : 'american';
  }

  static String _localeForAccent(String value) {
    return value == 'british' ? 'en-GB' : 'en-US';
  }

  static double _pitchForVoice(PronunciationVoiceGender voiceGender) {
    return switch (voiceGender) {
      PronunciationVoiceGender.female => 1.02,
      PronunciationVoiceGender.male => 0.94,
      PronunciationVoiceGender.neutral => 1.0,
    };
  }

  static List<String> _segmentsForTts(String value) {
    final normalized = value
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    if (normalized.isEmpty) {
      return const [];
    }
    return normalized;
  }

  static String _normalizeText(String value) {
    return value
        .toLowerCase()
        .replaceAll('’', "'")
        .replaceAll("'", '')
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
