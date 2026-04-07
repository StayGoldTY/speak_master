class UserProgress {
  final String oderId;
  final int streakDays;
  final int totalXp;
  final int level;
  final int todayAssessmentCount;
  final DateTime? lastActiveDate;
  final Set<String> completedLessons;
  final Set<String> completedUnits;
  final Set<String> earnedBadges;
  final Map<String, double> phonemeScores;
  final int streakFreezeRemaining;
  final bool isPro;

  const UserProgress({
    required this.oderId,
    this.streakDays = 0,
    this.totalXp = 0,
    this.level = 1,
    this.todayAssessmentCount = 0,
    this.lastActiveDate,
    this.completedLessons = const {},
    this.completedUnits = const {},
    this.earnedBadges = const {},
    this.phonemeScores = const {},
    this.streakFreezeRemaining = 1,
    this.isPro = false,
  });

  UserProgress copyWith({
    int? streakDays,
    int? totalXp,
    int? level,
    int? todayAssessmentCount,
    DateTime? lastActiveDate,
    Set<String>? completedLessons,
    Set<String>? completedUnits,
    Set<String>? earnedBadges,
    Map<String, double>? phonemeScores,
    int? streakFreezeRemaining,
    bool? isPro,
  }) {
    return UserProgress(
      oderId: oderId,
      streakDays: streakDays ?? this.streakDays,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      todayAssessmentCount: todayAssessmentCount ?? this.todayAssessmentCount,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      completedLessons: completedLessons ?? this.completedLessons,
      completedUnits: completedUnits ?? this.completedUnits,
      earnedBadges: earnedBadges ?? this.earnedBadges,
      phonemeScores: phonemeScores ?? this.phonemeScores,
      streakFreezeRemaining: streakFreezeRemaining ?? this.streakFreezeRemaining,
      isPro: isPro ?? this.isPro,
    );
  }

  int get xpForNextLevel => level * 100;
  double get levelProgress => (totalXp % xpForNextLevel) / xpForNextLevel;

  String get streakBadge {
    if (streakDays >= 365) return 'diamond';
    if (streakDays >= 90) return 'gold';
    if (streakDays >= 30) return 'silver';
    if (streakDays >= 7) return 'bronze';
    return 'none';
  }
}

class DailyTask {
  final String id;
  final String title;
  final String description;
  final TaskType type;
  final bool isCompleted;
  final int xpReward;

  const DailyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.isCompleted = false,
    required this.xpReward,
  });
}

enum TaskType { phonemePractice, readAloud, assessmentQuiz }
