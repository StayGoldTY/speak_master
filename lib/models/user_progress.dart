class UserProgress {
  final String userId;
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
    required this.userId,
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

  factory UserProgress.empty(String userId) => UserProgress(userId: userId);

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      userId: json['user_id'] as String? ?? 'local',
      streakDays: json['streak_days'] as int? ?? 0,
      totalXp: json['total_xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      todayAssessmentCount: json['today_assessment_count'] as int? ?? 0,
      lastActiveDate: json['last_active_date'] != null
          ? DateTime.tryParse(json['last_active_date'] as String)
          : null,
      completedLessons: _toStringSet(json['completed_lessons']),
      completedUnits: _toStringSet(json['completed_units']),
      earnedBadges: _toStringSet(json['earned_badges']),
      phonemeScores: (json['phoneme_scores'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
          {},
      streakFreezeRemaining: json['streak_freeze_remaining'] as int? ?? 1,
      isPro: json['is_pro'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'streak_days': streakDays,
      'total_xp': totalXp,
      'level': level,
      'today_assessment_count': todayAssessmentCount,
      'last_active_date': lastActiveDate?.toIso8601String(),
      'completed_lessons': completedLessons.toList(),
      'completed_units': completedUnits.toList(),
      'earned_badges': earnedBadges.toList(),
      'phoneme_scores': phonemeScores,
      'streak_freeze_remaining': streakFreezeRemaining,
    };
  }

  UserProgress copyWith({
    String? userId,
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
      userId: userId ?? this.userId,
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

  static Set<String> _toStringSet(dynamic value) {
    if (value == null) return {};
    if (value is List) return value.map((e) => e.toString()).toSet();
    return {};
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
