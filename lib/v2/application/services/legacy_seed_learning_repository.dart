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
    'c_ð',
    'c_θ',
    'c_v',
    'c_w',
    'c_r',
    'c_l',
    'v_ʌ',
    'v_ɜː',
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
        title: '咖啡点单影子跟读',
        scenario: '先听标准音，再把整句读成一口气的自然请求。',
        instruction: '前半句轻一点，把饮品信息和 please 落清楚。',
        referenceText: 'Can I get a large latte with oat milk, please?',
        focusWords: ['large', 'latte', 'oat', 'please'],
        checklist: ['“Can I get a” 前半段轻一点。', '把 “latte” 和 “oat milk” 落清楚。'],
        warmupWords: ['large', 'latte', 'oat milk', 'please'],
        phraseDrills: ['Can I get a', 'large latte', 'with oat milk'],
        sentenceVariations: [
          'Can I get a small latte with oat milk, please?',
          'Can I get a hot latte with regular milk, please?',
        ],
        rhythmCue: '前半句轻一点，饮品信息和 please 要落清楚。',
        extensionPrompt: '换一个杯型或奶类，再完整说一遍。',
      ),
      SpeakingPrompt(
        id: 'dialog_checkin',
        kind: ActivityKind.dialogRoleplay,
        title: '酒店入住对话',
        scenario: '用前台入住场景做一轮引导式口语练习。',
        instruction: '先把身份和订单信息说出来，再补停留时长。',
        referenceText:
            'Hi, I have a reservation under the name Lin for two nights.',
        focusWords: ['reservation', 'Lin', 'two nights'],
        checklist: ['人名不要一带而过。', '“reservation” 是这句话的重音中心。'],
        warmupWords: ['reservation', 'under the name Lin', 'two nights'],
        phraseDrills: [
          'I have a reservation',
          'under the name Lin',
          'for two nights',
        ],
        sentenceVariations: [
          'Hi, I have a reservation under the name Lin for three nights.',
          'Hi, I booked a room under the name Lin for two nights.',
        ],
        rhythmCue: '先把身份和订单信息抛出来，再补充停留时长。',
        extensionPrompt: '把 nights 换成入住人数，再说第二遍。',
      ),
      SpeakingPrompt(
        id: 'work_meeting_update',
        kind: ActivityKind.dialogRoleplay,
        title: '会议进度汇报',
        scenario: '模拟会议或站会，用两三句说清本周进展、卡点和下一步。',
        instruction: '先说结果，再把 still need to 后面的风险讲清楚。',
        referenceText:
            'I finished the onboarding flow, but I still need to fix the payment bug before Friday.',
        focusWords: ['finished', 'still need', 'payment bug', 'Friday'],
        checklist: ['先把完成项说清楚。', '“still need to” 不要全部压成一个音块。'],
        warmupWords: ['finished', 'payment bug', 'before Friday'],
        phraseDrills: [
          'I finished the onboarding flow',
          'I still need to fix',
          'before Friday',
        ],
        sentenceVariations: [
          'I finished the dashboard page, but I still need to fix the login bug before Friday.',
          'I wrapped up the onboarding flow, and the next step is fixing the payment bug.',
        ],
        rhythmCue: '先说结果，再把 still need to 后面的风险讲清楚。',
        extensionPrompt: '补一句 next step，让汇报更像真实站会。',
      ),
      SpeakingPrompt(
        id: 'assessment_pitch',
        kind: ActivityKind.assessmentTask,
        title: '发音状态测评',
        scenario: '读完一句完整句子后，查看结构化反馈和复练建议。',
        instruction: '先慢速读稳一遍，再用自然语速复读一轮。',
        referenceText:
            'The weather is getting better, so we should go earlier.',
        focusWords: ['weather', 'better', 'earlier'],
        checklist: ['整句节奏要连起来。', '结尾短语不要全部压平。'],
        warmupWords: ['weather', 'better', 'go earlier'],
        phraseDrills: [
          'The weather is getting better',
          'so we should go earlier',
        ],
        sentenceVariations: [
          'The weather is getting warmer, so we should leave earlier.',
          'The weather is much better today, so we can head out earlier.',
        ],
        rhythmCue: '前半句别太平，so we should go earlier 要一口气带过去。',
        extensionPrompt: '先慢速一遍，再用自然语速再读一遍。',
      ),
      SpeakingPrompt(
        id: 'shadowing_morning_reset',
        kind: ActivityKind.shadowing,
        title: '晨间重启跟读',
        scenario: '用一条中长句把嘴形、气息和节奏一起唤醒。',
        instruction: '先把句子拆成三段，再把它读成一口气。',
        referenceText:
            'I start my morning with water, a deep breath, and one clear sentence in English.',
        focusWords: ['morning', 'deep breath', 'clear sentence'],
        checklist: [
          '别把 and one clear sentence 读散了。',
          'breath 和 English 尾音要收干净。',
        ],
        warmupWords: ['morning', 'deep breath', 'clear sentence'],
        phraseDrills: [
          'I start my morning',
          'with water and a deep breath',
          'one clear sentence in English',
        ],
        sentenceVariations: [
          'I start my morning with water, one deep breath, and one calm sentence in English.',
          'I start my day with water, a deep breath, and one confident line in English.',
        ],
        rhythmCue: '不要一路往前冲，把 a deep breath 和 clear sentence 的重心拉出来。',
        extensionPrompt: '换 morning 或 sentence 里的一个词，再做一轮变体开口。',
      ),
      SpeakingPrompt(
        id: 'dialog_room_change',
        kind: ActivityKind.dialogRoleplay,
        title: '更换房间请求',
        scenario: '模拟入住后发现房间太吵闹，用礼貌但清楚的方式提出请求。',
        instruction: '先说问题，再说你想要的解决方案，尾音不要掉。',
        referenceText:
            'Could you move me to a quieter room if one is available tonight?',
        focusWords: ['move me', 'quieter room', 'available tonight'],
        checklist: ['quieter room 要分成三块读清。', 'if one is available 不要断得太碎。'],
        warmupWords: ['move me', 'quieter room', 'tonight'],
        phraseDrills: [
          'Could you move me',
          'to a quieter room',
          'if one is available tonight',
        ],
        sentenceVariations: [
          'Could you move me to a quieter room on a higher floor?',
          'Could you move me to another room if one is free tonight?',
        ],
        rhythmCue: '礼貌请求句要保持一口气，把 quieter room 和 tonight 托住。',
        extensionPrompt: '换成 floor、view 或 bed type 的请求，再说一遍。',
      ),
      SpeakingPrompt(
        id: 'dialog_delivery_issue',
        kind: ActivityKind.dialogRoleplay,
        title: '外卖问题反馈',
        scenario: '模拟餐品送达后发现延迟和漏项，用短句把问题说清。',
        instruction: '先说主要问题，再说你希望对方怎么处理。',
        referenceText:
            'My order arrived late, and one item was missing from the bag.',
        focusWords: ['arrived late', 'one item', 'missing from the bag'],
        checklist: [
          'arrived late 不要读成两个同样重的词。',
          'missing from the bag 后半句的气要稳。',
        ],
        warmupWords: ['arrived late', 'one item', 'missing'],
        phraseDrills: [
          'My order arrived late',
          'one item was missing',
          'from the bag',
        ],
        sentenceVariations: [
          'My order arrived late, and the drink was missing from the bag.',
          'My order was delayed, and one item was left out of the bag.',
        ],
        rhythmCue: '先把 primary problem 说清，再把 missing from the bag 收干净。',
        extensionPrompt: '再补一句 I need a refund 或 resend，让表达更完整。',
      ),
      SpeakingPrompt(
        id: 'assessment_thursday',
        kind: ActivityKind.assessmentTask,
        title: 'TH 系列测评',
        scenario: '专门看 th 是否在语速一快时又缩回到 s 或 d。',
        instruction: '先慢速读稳，再用自然语速读第二遍。',
        referenceText:
            'Three thin thinkers thought thoughtful things on Thursday.',
        focusWords: ['three', 'thin', 'thoughtful', 'Thursday'],
        checklist: ['每个 th 都要看得见舌尖动作。', '不要为了快把 thoughtful 压平。'],
        warmupWords: ['three', 'thin', 'Thursday'],
        phraseDrills: [
          'three thin thinkers',
          'thought thoughtful things',
          'on Thursday',
        ],
        sentenceVariations: [
          'Three thoughtful thinkers talked on Thursday.',
          'Those thin thinkers shared three thoughtful ideas on Thursday.',
        ],
        rhythmCue: '即使加快，th 也要保持嘴形和送气，不要把它吞掉。',
        extensionPrompt: '先把 three 和 Thursday 单独读稳，再回到整句。',
      ),
    ];
  }

  @override
  DailyPlan buildDailyPlan({
    required UserProgress progress,
    required String learnerName,
    required LearnerProfileV2 learner,
  }) {
    final nextLesson = _findNextLesson(progress);
    final snapshot = buildMasterySnapshot(progress);
    final prompts = getSpeakingPrompts();
    final transferPrompt = _selectTransferPrompt(
      prompts: prompts,
      goal: learner.goal,
    );
    final reviewRoute = progress.pronunciationReviewEntries.isEmpty
        ? '/speaking'
        : '/speaking?prompt=${progress.pronunciationReviewEntries.first.sourcePromptId}';
    final allocation = _allocatePlanMinutes(learner.dailyMinutes);

    return DailyPlan(
      headline: '$learnerName 的今日学习',
      subtitle: _buildPlanSubtitle(learner),
      items: [
        DailyPlanItem(
          id: 'plan_lesson',
          title: nextLesson?.title ?? '回顾发音基础',
          subtitle: nextLesson?.description ?? '先把发音底座复习一轮，保持嘴形和节奏感觉。',
          route: nextLesson == null ? '/speaking' : '/lesson/${nextLesson.id}',
          kind: DailyPlanItemKind.lesson,
          estimatedMinutes: allocation.lessonMinutes,
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
          route: reviewRoute,
          kind: DailyPlanItemKind.review,
          estimatedMinutes: allocation.reviewMinutes,
          xpReward: 10,
        ),
        DailyPlanItem(
          id: 'plan_transfer',
          title: transferPrompt.title,
          subtitle: transferPrompt.scenario,
          route: '/speaking?prompt=${transferPrompt.id}',
          kind: transferPrompt.kind == ActivityKind.assessmentTask
              ? DailyPlanItemKind.assessment
              : DailyPlanItemKind.dialogue,
          estimatedMinutes: allocation.transferMinutes,
          xpReward: 15,
        ),
      ],
    );
  }

  String _buildPlanSubtitle(LearnerProfileV2 learner) {
    final goalLine = switch (learner.goal) {
      LearningGoal.pronunciationConfidence => '围绕发音稳定度、补弱和测评做一轮短计划。',
      LearningGoal.dailyConversation => '围绕高频生活表达，做一轮能马上开口的日常练习。',
      LearningGoal.travelEnglish => '围绕旅行场景，把入住、点单和即时开口先练顺。',
      LearningGoal.workplaceSpeaking => '围绕职场表达，把汇报、会议和沟通说得更清楚。',
    };

    return '今天安排约 ${learner.dailyMinutes} 分钟，$goalLine';
  }

  SpeakingPrompt _selectTransferPrompt({
    required List<SpeakingPrompt> prompts,
    required LearningGoal goal,
  }) {
    final promptId = switch (goal) {
      LearningGoal.pronunciationConfidence => 'assessment_pitch',
      LearningGoal.dailyConversation => 'shadowing_cafe',
      LearningGoal.travelEnglish => 'dialog_checkin',
      LearningGoal.workplaceSpeaking => 'work_meeting_update',
    };

    for (final prompt in prompts) {
      if (prompt.id == promptId) {
        return prompt;
      }
    }

    return prompts.first;
  }

  _PlanMinuteAllocation _allocatePlanMinutes(int requestedMinutes) {
    final total = requestedMinutes.clamp(10, 30);
    final lessonMinutes = (total * 0.4).round().clamp(4, 12);
    final reviewMinutes = (total * 0.25).round().clamp(2, 8);
    final transferMinutes = total - lessonMinutes - reviewMinutes;

    return _PlanMinuteAllocation(
      lessonMinutes: lessonMinutes,
      reviewMinutes: reviewMinutes,
      transferMinutes: transferMinutes,
    );
  }

  @override
  MasterySnapshot buildMasterySnapshot(UserProgress progress) {
    final scoreWeakPoints =
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

    final reviewEntryWeakPoints = progress.pronunciationReviewEntries
        .map(
          (entry) => WeakPointSummary(
            label: entry.label,
            description: entry.reason,
            score: (100 - entry.weaknessScore).clamp(0, 100).toDouble(),
          ),
        )
        .toList();
    final weakPoints = [...scoreWeakPoints, ...reviewEntryWeakPoints]
      ..sort((a, b) => a.score.compareTo(b.score));

    final scoreReviewQueue = scoreWeakPoints
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
    final reviewQueue = [
      ...progress.pronunciationReviewEntries
          .take(6)
          .map(
            (entry) => ReviewItem(
              id: entry.id,
              label: entry.label,
              reason: entry.reason,
              recommendedActivityKind: _activityKindFromName(
                entry.recommendedActivityKindKey,
              ),
              score: entry.weaknessScore,
            ),
          ),
      ...scoreReviewQueue,
    ].take(6).toList();

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

  ActivityKind _activityKindFromName(String key) {
    return ActivityKind.values.firstWhere(
      (item) => item.name == key,
      orElse: () => ActivityKind.wordRepeat,
    );
  }

  static String _preferChinese(String? chinese, String english) {
    final normalized = (chinese ?? '').trim();
    if (normalized.isNotEmpty) {
      return normalized;
    }
    return english;
  }
}

class _PlanMinuteAllocation {
  final int lessonMinutes;
  final int reviewMinutes;
  final int transferMinutes;

  const _PlanMinuteAllocation({
    required this.lessonMinutes,
    required this.reviewMinutes,
    required this.transferMinutes,
  });
}
