import '../../../data/lessons_data.dart';
import '../../../data/phonemes_data.dart';
import '../../../data/units_data.dart';
import '../../../models/lesson.dart';
import '../../../models/phoneme.dart';
import '../../../models/unit.dart';
import '../../../models/user_progress.dart';
import '../../../services/pronunciation_check_engine.dart';
import '../../domain/models/course_models.dart';
import '../../domain/models/learner_models.dart';
import '../../domain/models/speech_models.dart';
import '../../domain/repositories/v2_learning_repository.dart';

class LegacySeedLearningRepository implements V2LearningRepository {
  LegacySeedLearningRepository() : _track = _buildTrack();

  static const _primaryUnitIds = [
    'u1',
    'u2',
    'u3',
    'u4',
    'u5',
    'u6',
    'u7',
    'u8',
    'u9',
    'u10',
  ];
  static const _featuredPhonemeIds = [
    'c_胃',
    'c_冒',
    'c_v',
    'c_w',
    'c_r',
    'c_l',
    'v_忙',
    'v_瑟',
  ];

  final CourseTrack _track;

  @override
  CourseTrack getPrimaryTrack() => _track;

  @override
  UnitBlueprint? getUnitById(String unitId) {
    for (final unit in _track.units) {
      if (unit.id == unitId) {
        return unit;
      }
    }
    return null;
  }

  @override
  LessonBlueprint? getLessonById(String lessonId) {
    for (final unit in _track.units) {
      for (final lesson in unit.lessons) {
        if (lesson.id == lessonId) {
          return lesson;
        }
      }
    }
    return null;
  }

  @override
  List<PronunciationTarget> getFeaturedTargets() {
    return _featuredPhonemeIds
        .map(_findPhoneme)
        .whereType<Phoneme>()
        .map(_mapTarget)
        .toList();
  }

  @override
  List<SpeakingPrompt> getSpeakingPrompts() {
    return const [
      SpeakingPrompt(
        id: 'shadowing_cafe',
        kind: ActivityKind.shadowing,
        title: 'Cafe shadowing',
        scenario: 'Shadow a short service line with clean rhythm.',
        instruction: 'Listen, then repeat the full line in one connected chunk.',
        referenceText: 'Can I get a large latte with oat milk, please?',
        focusWords: ['large', 'latte', 'oat', 'please'],
        checklist: ['Keep "Can I get a" light.', 'Land clearly on "latte" and "oat milk".'],
      ),
      SpeakingPrompt(
        id: 'dialog_checkin',
        kind: ActivityKind.dialogRoleplay,
        title: 'Hotel check-in',
        scenario: 'Practice a guided roleplay line for front desk English.',
        instruction: 'Say the guest line naturally and keep the stressed words steady.',
        referenceText: 'Hi, I have a reservation under the name Lin for two nights.',
        focusWords: ['reservation', 'Lin', 'two nights'],
        checklist: ['Do not rush the name.', 'Let "reservation" carry the main stress.'],
      ),
      SpeakingPrompt(
        id: 'assessment_pitch',
        kind: ActivityKind.assessmentTask,
        title: 'Confidence assessment',
        scenario: 'Read one clean sentence and review the feedback summary.',
        instruction: 'Read it once clearly, then retry after the feedback.',
        referenceText: 'The weather is getting better, so we should go earlier.',
        focusWords: ['weather', 'better', 'earlier'],
        checklist: ['Keep rhythm across the sentence.', 'Avoid flattening the final phrase.'],
      ),
    ];
  }

  @override
  DailyPlan buildDailyPlan({
    required UserProgress progress,
    required String learnerName,
  }) {
    final nextLesson = _findNextLesson(progress);
    final snapshot = buildMasterySnapshot(progress);
    final prompts = getSpeakingPrompts();

    return DailyPlan(
      headline: 'Today for $learnerName',
      subtitle: 'One main lesson, one weak-point loop, and one transfer task.',
      items: [
        DailyPlanItem(
          id: 'plan_lesson',
          title: nextLesson?.title ?? 'Review foundation loop',
          subtitle: nextLesson?.description ?? 'Keep pronunciation basics sharp with a quick review.',
          route: nextLesson == null ? '/speaking' : '/lesson/${nextLesson.id}',
          kind: DailyPlanItemKind.lesson,
          estimatedMinutes: nextLesson?.estimatedMinutes ?? 12,
          xpReward: 20,
        ),
        DailyPlanItem(
          id: 'plan_review',
          title: snapshot.weakPoints.isEmpty
              ? 'Run a minimal-pair refresher'
              : 'Rebuild ${snapshot.weakPoints.first.label}',
          subtitle: snapshot.weakPoints.isEmpty
              ? 'Refresh a contrast before it gets fuzzy.'
              : snapshot.weakPoints.first.description,
          route: '/speaking',
          kind: DailyPlanItemKind.review,
          estimatedMinutes: 8,
          xpReward: 10,
        ),
        DailyPlanItem(
          id: 'plan_transfer',
          title: prompts[1].title,
          subtitle: prompts[1].scenario,
          route: '/speaking',
          kind: DailyPlanItemKind.dialogue,
          estimatedMinutes: 10,
          xpReward: 15,
        ),
      ],
    );
  }

  @override
  MasterySnapshot buildMasterySnapshot(UserProgress progress) {
    final weakPoints = progress.phonemeScores.entries
        .where((entry) => entry.value < 75)
        .map(
          (entry) => WeakPointSummary(
            label: _labelForPhoneme(entry.key),
            description: 'This target still needs a cleaner repeat-and-transfer loop.',
            score: entry.value,
          ),
        )
        .toList()
      ..sort((a, b) => a.score.compareTo(b.score));

    final reviewQueue = weakPoints
        .take(4)
        .map(
          (item) => ReviewItem(
            id: item.label,
            label: item.label,
            reason: item.description,
            recommendedActivityKind: ActivityKind.wordRepeat,
            score: item.score,
          ),
        )
        .toList();

    return MasterySnapshot(
      streakDays: progress.streakDays,
      totalXp: progress.totalXp,
      completedLessons: progress.completedLessons.length,
      weakPoints: weakPoints,
      reviewQueue: reviewQueue,
      recommendedFocus: weakPoints.isEmpty
          ? 'Keep moving through the foundation track and keep a daily speaking loop.'
          : 'Revisit ${weakPoints.first.label} before adding more new material.',
    );
  }

  @override
  OpsDashboard buildOpsDashboard() {
    return OpsDashboard(
      draftCount: 2,
      publishedCount: 1,
      failedJobs: 1,
      jobs: [
        GenerationJob(
          id: 'job_001',
          title: 'Pronunciation Foundation v1 seed import',
          status: GenerationJobStatus.ready,
          createdAt: DateTime(2026, 4, 15, 9, 0),
          summary: 'Imported u1-u10 into versioned course blueprints.',
        ),
        GenerationJob(
          id: 'job_002',
          title: 'Daily dialog drill pack',
          status: GenerationJobStatus.reviewing,
          createdAt: DateTime(2026, 4, 16, 8, 30),
          summary: 'Awaiting content review before publish.',
        ),
        GenerationJob(
          id: 'job_003',
          title: 'Travel roleplay expansion',
          status: GenerationJobStatus.failed,
          createdAt: DateTime(2026, 4, 16, 9, 10),
          summary: 'Schema validation failed on two dialog activities.',
        ),
      ],
    );
  }

  static CourseTrack _buildTrack() {
    final units = UnitsData.units
        .where((unit) => _primaryUnitIds.contains(unit.id))
        .map(_mapUnit)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return CourseTrack(
      id: 'pronunciation_foundation',
      title: 'Pronunciation Foundation',
      subtitle: 'The legacy foundation track, rebuilt as V2 seed content.',
      description: 'A structured speaking-first course track for Chinese adult learners.',
      version: CourseVersion(
        id: 'pronunciation_foundation_v1',
        trackId: 'pronunciation_foundation',
        status: CourseVersionStatus.published,
        publishedAt: DateTime(2026, 4, 16),
      ),
      units: units,
    );
  }

  static UnitBlueprint _mapUnit(LearningUnit unit) {
    final lessons = LessonsData.getLessonsForUnit(unit.id).map(_mapLesson).toList();
    return UnitBlueprint(
      id: unit.id,
      order: unit.order,
      title: unit.titleEn,
      subtitle: unit.titleCn,
      description: unit.description,
      targetPhonemes: List<String>.from(unit.targetPhonemes),
      lessons: lessons,
    );
  }

  static LessonBlueprint _mapLesson(Lesson lesson) {
    final activities = lesson.steps.map(_mapActivity).toList();
    return LessonBlueprint(
      id: lesson.id,
      unitId: lesson.unitId,
      order: lesson.order,
      title: lesson.titleEn,
      subtitle: lesson.titleCn,
      description: lesson.description,
      estimatedMinutes: lesson.estimatedMinutes,
      activities: activities,
    );
  }

  static ActivityBlueprint _mapActivity(LessonStep step) {
    final options = (step.metadata?['options'] as List<dynamic>? ?? const [])
        .asMap()
        .entries
        .map(
          (entry) => ChoiceOption(
            id: 'opt_${entry.key}',
            label: entry.value.toString(),
            explanation: step.metadata?['explanation']?.toString(),
          ),
        )
        .toList();
    final correctIndex = step.metadata?['correct'] as int?;

    return ActivityBlueprint(
      id: step.id,
      kind: _mapActivityKind(step.type),
      title: _mapActivityKind(step.type).label,
      instruction: step.instruction,
      content: step.content,
      referenceText: PronunciationCheckEngine.buildReferenceText(step),
      focusWords: PronunciationCheckEngine.extractFocusWords(step),
      pairs: _readPairs(step.metadata?['pairs']),
      options: options,
      correctOptionId: correctIndex == null ? null : 'opt_$correctIndex',
      checklist: [
        if ((step.content ?? '').isNotEmpty) 'Read once slowly, then once more naturally.',
      ],
      metadata: step.metadata ?? const {},
    );
  }

  static ActivityKind _mapActivityKind(StepType type) {
    return switch (type) {
      StepType.text || StepType.animation => ActivityKind.phonemeIntro,
      StepType.audio => ActivityKind.wordRepeat,
      StepType.recordAndCompare => ActivityKind.wordRepeat,
      StepType.minimalPairQuiz => ActivityKind.minimalPair,
      StepType.dragAndDrop => ActivityKind.dictation,
      StepType.multipleChoice => ActivityKind.mcq,
      StepType.readAloud => ActivityKind.sentenceReadAloud,
    };
  }

  static List<MinimalPairExample> _readPairs(dynamic raw) {
    if (raw is! List) {
      return const [];
    }

    return raw.map((pair) {
      if (pair is String) {
        final parts = pair.split('|');
        return MinimalPairExample(
          word1: parts.isEmpty ? '' : parts.first.trim(),
          word2: parts.length < 2 ? '' : parts[1].trim(),
        );
      }

      final map = pair as Map<dynamic, dynamic>;
      return MinimalPairExample(
        word1: map['word1']?.toString() ?? '',
        word2: map['word2']?.toString() ?? '',
        phoneme1: map['phoneme1']?.toString() ?? '',
        phoneme2: map['phoneme2']?.toString() ?? '',
      );
    }).toList();
  }

  PronunciationTarget _mapTarget(Phoneme phoneme) {
    return PronunciationTarget(
      id: phoneme.id,
      symbol: phoneme.symbol,
      title: phoneme.nameEn,
      subtitle: phoneme.nameCn,
      examples: phoneme.exampleWords.take(4).toList(),
      mouthPosition: phoneme.mouthPosition,
      correctionTip: phoneme.correctionTip,
    );
  }

  LessonBlueprint? _findNextLesson(UserProgress progress) {
    for (final unit in _track.units) {
      for (final lesson in unit.lessons) {
        if (!progress.completedLessons.contains(lesson.id)) {
          return lesson;
        }
      }
    }
    return null;
  }

  Phoneme? _findPhoneme(String id) {
    for (final phoneme in PhonemesData.allPhonemes) {
      if (phoneme.id == id) {
        return phoneme;
      }
    }
    return null;
  }

  String _labelForPhoneme(String key) {
    final phoneme = _findPhoneme(key);
    return phoneme == null ? key.replaceFirst(RegExp(r'^[a-z]_'), '') : phoneme.symbol;
  }
}
