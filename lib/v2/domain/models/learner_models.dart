import 'course_models.dart';

enum LearningGoal {
  pronunciationConfidence,
  dailyConversation,
  travelEnglish,
  workplaceSpeaking,
}

extension LearningGoalX on LearningGoal {
  String get key => name;

  String get title => switch (this) {
    LearningGoal.pronunciationConfidence => '发音更自信',
    LearningGoal.dailyConversation => '日常交流',
    LearningGoal.travelEnglish => '旅行英语',
    LearningGoal.workplaceSpeaking => '职场表达',
  };

  String get subtitle => switch (this) {
    LearningGoal.pronunciationConfidence => '先把发音、节奏和开口稳定度练扎实。',
    LearningGoal.dailyConversation => '更自然地说出高频生活表达。',
    LearningGoal.travelEnglish => '提前练熟出行中的关键句型和场景。',
    LearningGoal.workplaceSpeaking => '在会议、汇报和沟通里更清楚、更有底气。',
  };

  static LearningGoal fromKey(String? value) {
    return LearningGoal.values.firstWhere(
      (goal) => goal.key == value,
      orElse: () => LearningGoal.pronunciationConfidence,
    );
  }
}

enum PlacementLevel { starter, elementary, intermediate }

extension PlacementLevelX on PlacementLevel {
  String get key => name;

  String get title => switch (this) {
    PlacementLevel.starter => '零基础起步',
    PlacementLevel.elementary => '基础入门',
    PlacementLevel.intermediate => '进阶提升',
  };

  String get subtitle => switch (this) {
    PlacementLevel.starter => '需要更多中文引导和发音基础支撑。',
    PlacementLevel.elementary => '能看懂简单英语，但口语习惯还需要重建。',
    PlacementLevel.intermediate => '可以开始强化自然节奏、连读和迁移应用。',
  };

  static PlacementLevel fromKey(String? value) {
    return PlacementLevel.values.firstWhere(
      (level) => level.key == value,
      orElse: () => PlacementLevel.starter,
    );
  }
}

class LearnerProfileV2 {
  final String displayName;
  final LearningGoal goal;
  final PlacementLevel placementLevel;
  final String accentPreference;
  final int dailyMinutes;
  final bool onboardingComplete;

  const LearnerProfileV2({
    required this.displayName,
    required this.goal,
    required this.placementLevel,
    required this.accentPreference,
    required this.dailyMinutes,
    required this.onboardingComplete,
  });

  String get accentLabel => accentPreference.accentLabel;

  String get accentShortLabel => accentPreference.accentShortLabel;
}

enum DailyPlanItemKind { lesson, review, speaking, assessment, dialogue }

class DailyPlanItem {
  final String id;
  final String title;
  final String subtitle;
  final String route;
  final DailyPlanItemKind kind;
  final int estimatedMinutes;
  final int xpReward;

  const DailyPlanItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.kind,
    required this.estimatedMinutes,
    required this.xpReward,
  });
}

class DailyPlan {
  final String headline;
  final String subtitle;
  final List<DailyPlanItem> items;

  const DailyPlan({
    required this.headline,
    required this.subtitle,
    required this.items,
  });
}

class ReviewItem {
  final String id;
  final String label;
  final String reason;
  final ActivityKind recommendedActivityKind;
  final double score;

  const ReviewItem({
    required this.id,
    required this.label,
    required this.reason,
    required this.recommendedActivityKind,
    required this.score,
  });
}

class WeakPointSummary {
  final String label;
  final String description;
  final double score;

  const WeakPointSummary({
    required this.label,
    required this.description,
    required this.score,
  });
}

class MasterySnapshot {
  final int streakDays;
  final int totalXp;
  final int completedLessons;
  final List<WeakPointSummary> weakPoints;
  final List<ReviewItem> reviewQueue;
  final String recommendedFocus;

  const MasterySnapshot({
    required this.streakDays,
    required this.totalXp,
    required this.completedLessons,
    required this.weakPoints,
    required this.reviewQueue,
    required this.recommendedFocus,
  });
}

class V2LearnerSetupState {
  final LearningGoal goal;
  final PlacementLevel placementLevel;
  final int dailyMinutes;
  final bool onboardingComplete;

  const V2LearnerSetupState({
    required this.goal,
    required this.placementLevel,
    required this.dailyMinutes,
    required this.onboardingComplete,
  });

  V2LearnerSetupState copyWith({
    LearningGoal? goal,
    PlacementLevel? placementLevel,
    int? dailyMinutes,
    bool? onboardingComplete,
  }) {
    return V2LearnerSetupState(
      goal: goal ?? this.goal,
      placementLevel: placementLevel ?? this.placementLevel,
      dailyMinutes: dailyMinutes ?? this.dailyMinutes,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }
}

extension AccentPreferenceValueX on String {
  String get accentLabel {
    return toLowerCase() == 'british' ? '英式发音' : '美式发音';
  }

  String get accentShortLabel {
    return toLowerCase() == 'british' ? '英式' : '美式';
  }
}
