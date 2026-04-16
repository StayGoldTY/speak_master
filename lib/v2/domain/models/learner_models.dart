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
        LearningGoal.pronunciationConfidence => 'Pronunciation confidence',
        LearningGoal.dailyConversation => 'Daily conversation',
        LearningGoal.travelEnglish => 'Travel English',
        LearningGoal.workplaceSpeaking => 'Workplace speaking',
      };

  String get subtitle => switch (this) {
        LearningGoal.pronunciationConfidence => 'Build clean sounds, rhythm, and speaking control.',
        LearningGoal.dailyConversation => 'Get comfortable with everyday English responses.',
        LearningGoal.travelEnglish => 'Practice common travel interactions and clarity.',
        LearningGoal.workplaceSpeaking => 'Sound more confident in meetings and presentations.',
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
        PlacementLevel.starter => 'Starter',
        PlacementLevel.elementary => 'Elementary',
        PlacementLevel.intermediate => 'Intermediate',
      };

  String get subtitle => switch (this) {
        PlacementLevel.starter => 'Need heavy support and clearer sound foundations.',
        PlacementLevel.elementary => 'Can follow simple English but need stronger speaking habits.',
        PlacementLevel.intermediate => 'Ready for more natural rhythm and transfer practice.',
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
