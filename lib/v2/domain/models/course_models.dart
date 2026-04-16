enum ActivityKind {
  phonemeIntro,
  minimalPair,
  wordRepeat,
  sentenceReadAloud,
  shadowing,
  dialogRoleplay,
  dictation,
  mcq,
  speakingReflection,
  assessmentTask,
}

extension ActivityKindX on ActivityKind {
  String get label => switch (this) {
        ActivityKind.phonemeIntro => 'Phoneme intro',
        ActivityKind.minimalPair => 'Minimal pair',
        ActivityKind.wordRepeat => 'Word repeat',
        ActivityKind.sentenceReadAloud => 'Sentence read aloud',
        ActivityKind.shadowing => 'Shadowing',
        ActivityKind.dialogRoleplay => 'Dialog roleplay',
        ActivityKind.dictation => 'Dictation',
        ActivityKind.mcq => 'MCQ',
        ActivityKind.speakingReflection => 'Speaking reflection',
        ActivityKind.assessmentTask => 'Assessment',
      };

  bool get isSpeaking => switch (this) {
        ActivityKind.wordRepeat ||
        ActivityKind.sentenceReadAloud ||
        ActivityKind.shadowing ||
        ActivityKind.dialogRoleplay ||
        ActivityKind.speakingReflection ||
        ActivityKind.assessmentTask =>
          true,
        _ => false,
      };
}

class ChoiceOption {
  final String id;
  final String label;
  final String? explanation;

  const ChoiceOption({
    required this.id,
    required this.label,
    this.explanation,
  });
}

class MinimalPairExample {
  final String word1;
  final String word2;
  final String phoneme1;
  final String phoneme2;

  const MinimalPairExample({
    required this.word1,
    required this.word2,
    this.phoneme1 = '',
    this.phoneme2 = '',
  });
}

class ActivityBlueprint {
  final String id;
  final ActivityKind kind;
  final String title;
  final String instruction;
  final String? content;
  final String? referenceText;
  final List<String> focusWords;
  final List<MinimalPairExample> pairs;
  final List<ChoiceOption> options;
  final String? correctOptionId;
  final List<String> checklist;
  final Map<String, dynamic> metadata;

  const ActivityBlueprint({
    required this.id,
    required this.kind,
    required this.title,
    required this.instruction,
    this.content,
    this.referenceText,
    this.focusWords = const [],
    this.pairs = const [],
    this.options = const [],
    this.correctOptionId,
    this.checklist = const [],
    this.metadata = const {},
  });
}

class LessonBlueprint {
  final String id;
  final String unitId;
  final int order;
  final String title;
  final String subtitle;
  final String description;
  final int estimatedMinutes;
  final List<ActivityBlueprint> activities;

  const LessonBlueprint({
    required this.id,
    required this.unitId,
    required this.order,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.estimatedMinutes,
    required this.activities,
  });
}

class UnitBlueprint {
  final String id;
  final int order;
  final String title;
  final String subtitle;
  final String description;
  final List<String> targetPhonemes;
  final List<LessonBlueprint> lessons;

  const UnitBlueprint({
    required this.id,
    required this.order,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.targetPhonemes,
    required this.lessons,
  });

  String? get firstLessonId => lessons.isEmpty ? null : lessons.first.id;
}

enum CourseVersionStatus { draft, published }

class CourseVersion {
  final String id;
  final String trackId;
  final CourseVersionStatus status;
  final DateTime publishedAt;

  const CourseVersion({
    required this.id,
    required this.trackId,
    required this.status,
    required this.publishedAt,
  });
}

class CourseTrack {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final CourseVersion version;
  final List<UnitBlueprint> units;

  const CourseTrack({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.version,
    required this.units,
  });
}

enum GenerationJobStatus { queued, reviewing, failed, ready }

class GenerationJob {
  final String id;
  final String title;
  final GenerationJobStatus status;
  final DateTime createdAt;
  final String summary;

  const GenerationJob({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.summary,
  });
}

class OpsDashboard {
  final int draftCount;
  final int publishedCount;
  final int failedJobs;
  final List<GenerationJob> jobs;

  const OpsDashboard({
    required this.draftCount,
    required this.publishedCount,
    required this.failedJobs,
    required this.jobs,
  });
}
