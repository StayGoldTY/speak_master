import 'course_models.dart';
import 'learner_models.dart';

enum FluencyBand { emerging, steady, confident }

extension FluencyBandX on FluencyBand {
  String get key => name;

  String get label => switch (this) {
    FluencyBand.emerging => '还需加强',
    FluencyBand.steady => '逐渐稳定',
    FluencyBand.confident => '比较自然',
  };

  static FluencyBand fromKey(String? value) {
    return FluencyBand.values.firstWhere(
      (item) => item.key == value,
      orElse: () => FluencyBand.emerging,
    );
  }
}

enum PaceBand { tooSlow, balanced, tooFast }

extension PaceBandX on PaceBand {
  String get key => name;

  String get label => switch (this) {
    PaceBand.tooSlow => '节奏偏慢',
    PaceBand.balanced => '节奏合适',
    PaceBand.tooFast => '节奏偏快',
  };

  static PaceBand fromKey(String? value) {
    return PaceBand.values.firstWhere(
      (item) => item.key == value,
      orElse: () => PaceBand.balanced,
    );
  }
}

enum WeakPointTagType { phoneme, word, rhythm, stress, linkedSpeech }

extension WeakPointTagTypeX on WeakPointTagType {
  String get key => name;

  static WeakPointTagType fromKey(String? value) {
    return WeakPointTagType.values.firstWhere(
      (item) => item.key == value,
      orElse: () => WeakPointTagType.word,
    );
  }
}

enum SpeechAttemptSource { cloud, localFallback }

extension SpeechAttemptSourceX on SpeechAttemptSource {
  String get key => switch (this) {
    SpeechAttemptSource.cloud => 'cloud',
    SpeechAttemptSource.localFallback => 'local_fallback',
  };

  String get label => switch (this) {
    SpeechAttemptSource.cloud => '云端评测',
    SpeechAttemptSource.localFallback => '本地回退',
  };

  static SpeechAttemptSource fromKey(String? value) {
    return SpeechAttemptSource.values.firstWhere(
      (item) => item.key == value,
      orElse: () => SpeechAttemptSource.localFallback,
    );
  }
}

class PronunciationTarget {
  final String id;
  final String symbol;
  final String title;
  final String subtitle;
  final List<String> examples;
  final String mouthPosition;
  final String correctionTip;

  const PronunciationTarget({
    required this.id,
    required this.symbol,
    required this.title,
    required this.subtitle,
    required this.examples,
    required this.mouthPosition,
    required this.correctionTip,
  });
}

class SpeakingPrompt {
  final String id;
  final ActivityKind kind;
  final String title;
  final String scenario;
  final String instruction;
  final String referenceText;
  final List<String> focusWords;
  final List<String> checklist;
  final List<String> warmupWords;
  final List<String> phraseDrills;
  final List<String> sentenceVariations;
  final String rhythmCue;
  final String extensionPrompt;

  const SpeakingPrompt({
    required this.id,
    required this.kind,
    required this.title,
    required this.scenario,
    required this.instruction,
    required this.referenceText,
    required this.focusWords,
    required this.checklist,
    this.warmupWords = const [],
    this.phraseDrills = const [],
    this.sentenceVariations = const [],
    this.rhythmCue = '',
    this.extensionPrompt = '',
  });
}

class WeakPointTag {
  final String label;
  final WeakPointTagType type;
  final String reason;

  const WeakPointTag({
    required this.label,
    required this.type,
    required this.reason,
  });

  Map<String, dynamic> toMap() {
    return {'label': label, 'type': type.key, 'reason': reason};
  }

  factory WeakPointTag.fromMap(Map<String, dynamic> map) {
    return WeakPointTag(
      label: map['label']?.toString() ?? '',
      type: WeakPointTagTypeX.fromKey(map['type']?.toString()),
      reason: map['reason']?.toString() ?? '',
    );
  }
}

class SpeechFeedback {
  final String recognizedText;
  final double coverageScore;
  final FluencyBand fluencyBand;
  final PaceBand paceBand;
  final List<String> stressHints;
  final List<String> weakWords;
  final List<String> retrySuggestions;
  final String teacherExplanation;
  final bool fallbackUsed;
  final List<WeakPointTag> weakPointTags;
  final DateTime generatedAt;

  const SpeechFeedback({
    required this.recognizedText,
    required this.coverageScore,
    required this.fluencyBand,
    required this.paceBand,
    required this.stressHints,
    required this.weakWords,
    required this.retrySuggestions,
    required this.teacherExplanation,
    required this.fallbackUsed,
    required this.weakPointTags,
    required this.generatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'recognizedText': recognizedText,
      'coverageScore': coverageScore,
      'fluencyBand': fluencyBand.key,
      'paceBand': paceBand.key,
      'stressHints': stressHints,
      'weakWords': weakWords,
      'retrySuggestions': retrySuggestions,
      'teacherExplanation': teacherExplanation,
      'fallbackUsed': fallbackUsed,
      'weakPointTags': weakPointTags.map((item) => item.toMap()).toList(),
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  factory SpeechFeedback.fromMap(Map<String, dynamic> map) {
    final rawWeakTags = map['weakPointTags'] as List<dynamic>? ?? const [];

    return SpeechFeedback(
      recognizedText: map['recognizedText']?.toString() ?? '',
      coverageScore: (map['coverageScore'] as num?)?.toDouble() ?? 0,
      fluencyBand: FluencyBandX.fromKey(map['fluencyBand']?.toString()),
      paceBand: PaceBandX.fromKey(map['paceBand']?.toString()),
      stressHints: (map['stressHints'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      weakWords: (map['weakWords'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      retrySuggestions: (map['retrySuggestions'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      teacherExplanation: map['teacherExplanation']?.toString() ?? '',
      fallbackUsed: map['fallbackUsed'] == true,
      weakPointTags: rawWeakTags
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (item) => WeakPointTag.fromMap(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList(),
      generatedAt:
          DateTime.tryParse(map['generatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class SpeechAssessmentReport {
  final String? id;
  final String overallLabel;
  final String overview;
  final List<WeakPointTag> weakTargets;
  final List<String> nextSteps;
  final String? recommendedRoute;
  final SpeechAttemptSource source;
  final DateTime createdAt;

  const SpeechAssessmentReport({
    this.id,
    required this.overallLabel,
    required this.overview,
    required this.weakTargets,
    required this.nextSteps,
    this.recommendedRoute,
    required this.source,
    required this.createdAt,
  });
}

class SpeakingAttemptRecord {
  final String? id;
  final String promptId;
  final ActivityKind activityKind;
  final String accentPreference;
  final String transcriptSource;
  final int? audioDurationMs;
  final SpeechAttemptSource source;
  final SpeechFeedback feedback;
  final DateTime createdAt;

  const SpeakingAttemptRecord({
    this.id,
    required this.promptId,
    required this.activityKind,
    required this.accentPreference,
    required this.transcriptSource,
    this.audioDurationMs,
    required this.source,
    required this.feedback,
    required this.createdAt,
  });
}

class SpeakingAssessmentResult {
  final SpeakingAttemptRecord attempt;
  final SpeechAssessmentReport report;
  final List<ReviewItem> reviewItems;

  const SpeakingAssessmentResult({
    required this.attempt,
    required this.report,
    required this.reviewItems,
  });
}
