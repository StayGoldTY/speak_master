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
        title: '咖啡店影子跟读',
        scenario: '先听标准音，再把整句话连成一个自然意群跟出来。',
        instruction: '重点保持句子连贯，别把每个词都读得一样重。',
        referenceText: 'Can I get a large latte with oat milk, please?',
        focusWords: ['large', 'latte', 'oat', 'please'],
        checklist: ['“Can I get a” 前半段轻一点。', '把 “latte” 和 “oat milk” 落清楚。'],
      ),
      SpeakingPrompt(
        id: 'dialog_checkin',
        kind: ActivityKind.dialogRoleplay,
        title: '酒店入住对话',
        scenario: '用前台入住场景做一轮引导式跟练。',
        instruction: '把住客这句话说自然，重点词读稳，不要着急。',
        referenceText:
            'Hi, I have a reservation under the name Lin for two nights.',
        focusWords: ['reservation', 'Lin', 'two nights'],
        checklist: ['人名不要一带而过。', '“reservation” 是这句话的重音中心。'],
      ),
      SpeakingPrompt(
        id: 'assessment_pitch',
        kind: ActivityKind.assessmentTask,
        title: '发音状态测评',
        scenario: '读完一句完整句子后，查看结构化反馈和复练建议。',
        instruction: '先清楚读一遍，再根据反馈重试一轮。',
        referenceText:
            'The weather is getting better, so we should go earlier.',
        focusWords: ['weather', 'better', 'earlier'],
        checklist: ['整句节奏要连起来。', '结尾短语不要全部压平。'],
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
      headline: '$learnerName 的今日学习',
      subtitle: '主线课、补弱练习和口语迁移三步一起推进。',
      items: [
        DailyPlanItem(
          id: 'plan_lesson',
          title: nextLesson?.title ?? '回顾发音基础',
          subtitle: nextLesson?.description ?? '先把发音底座复习一轮，保持嘴形和节奏感觉。',
          route: nextLesson == null ? '/speaking' : '/lesson/${nextLesson.id}',
          kind: DailyPlanItemKind.lesson,
          estimatedMinutes: nextLesson?.estimatedMinutes ?? 12,
          xpReward: 20,
        ),
        DailyPlanItem(
          id: 'plan_review',
          title: snapshot.weakPoints.isEmpty
              ? '做一轮最小对立体复习'
              : '补强 ${snapshot.weakPoints.first.label}',
          subtitle: snapshot.weakPoints.isEmpty
              ? '趁感觉还在，先复习一组容易混淆的对比音。'
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
    final weakPoints =
        progress.phonemeScores.entries
            .where((entry) => entry.value < 75)
            .map(
              (entry) => WeakPointSummary(
                label: _labelForPhoneme(entry.key),
                description: '这个目标音还需要再做一轮“跟读到迁移”的巩固。',
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
          ? '主线可以继续推进，但每天仍要保留一轮口语输出。'
          : '先把 ${weakPoints.first.label} 练稳，再继续加新内容。',
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
          title: '发音基础课 v1 内容导入',
          status: GenerationJobStatus.ready,
          createdAt: DateTime(2026, 4, 15, 9, 0),
          summary: '已将 u1-u10 映射为可版本化的课程蓝图。',
        ),
        GenerationJob(
          id: 'job_002',
          title: '每日对话练习包',
          status: GenerationJobStatus.reviewing,
          createdAt: DateTime(2026, 4, 16, 8, 30),
          summary: '等待人工审核后即可发布。',
        ),
        GenerationJob(
          id: 'job_003',
          title: '旅行场景对话扩展',
          status: GenerationJobStatus.failed,
          createdAt: DateTime(2026, 4, 16, 9, 10),
          summary: '两条对话活动未通过 schema 校验。',
        ),
      ],
    );
  }

  static CourseTrack _buildTrack() {
    final units =
        UnitsData.units
            .where((unit) => _primaryUnitIds.contains(unit.id))
            .map(_mapUnit)
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));

    return CourseTrack(
      id: 'pronunciation_foundation',
      title: '发音基础课',
      subtitle: '由原 u1-u10 重构而来的正式课程主线',
      description: '面向中国成人学习者的发音优先课程，先打底，再迁移到真实开口场景。',
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
    final lessons = LessonsData.getLessonsForUnit(
      unit.id,
    ).map(_mapLesson).toList();
    return UnitBlueprint(
      id: unit.id,
      order: unit.order,
      title: _preferChinese(unit.titleCn, unit.titleEn),
      subtitle: unit.titleEn,
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
      title: _preferChinese(lesson.titleCn, lesson.titleEn),
      subtitle: lesson.titleEn,
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
      checklist: [if ((step.content ?? '').isNotEmpty) '先慢读一遍，再用更自然的节奏读一遍。'],
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
    return phoneme == null
        ? key.replaceFirst(RegExp(r'^[a-z]_'), '')
        : phoneme.symbol;
  }

  static String _preferChinese(String? chinese, String english) {
    final normalized = (chinese ?? '').trim();
    if (normalized.isNotEmpty) {
      return normalized;
    }
    return english;
  }
}
