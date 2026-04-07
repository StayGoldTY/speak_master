import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';

class StorageService {
  static const _keyStreak = 'streak_days';
  static const _keyTotalXp = 'total_xp';
  static const _keyLevel = 'level';
  static const _keyLastActive = 'last_active';
  static const _keyCompletedLessons = 'completed_lessons';
  static const _keyCompletedUnits = 'completed_units';
  static const _keyEarnedBadges = 'earned_badges';
  static const _keyIsPro = 'is_pro';
  static const _keyTodayAssessments = 'today_assessments';
  static const _keyStreakFreeze = 'streak_freeze';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  UserProgress loadProgress() {
    return UserProgress(
      userId: 'local',
      streakDays: _prefs.getInt(_keyStreak) ?? 0,
      totalXp: _prefs.getInt(_keyTotalXp) ?? 0,
      level: _prefs.getInt(_keyLevel) ?? 1,
      todayAssessmentCount: _prefs.getInt(_keyTodayAssessments) ?? 0,
      lastActiveDate: _prefs.getString(_keyLastActive) != null && _prefs.getString(_keyLastActive)!.isNotEmpty
          ? DateTime.tryParse(_prefs.getString(_keyLastActive)!)
          : null,
      completedLessons: (_prefs.getStringList(_keyCompletedLessons) ?? []).toSet(),
      completedUnits: (_prefs.getStringList(_keyCompletedUnits) ?? []).toSet(),
      earnedBadges: (_prefs.getStringList(_keyEarnedBadges) ?? []).toSet(),
      isPro: _prefs.getBool(_keyIsPro) ?? false,
      streakFreezeRemaining: _prefs.getInt(_keyStreakFreeze) ?? 1,
    );
  }

  Future<void> saveProgress(UserProgress progress) async {
    await Future.wait([
      _prefs.setInt(_keyStreak, progress.streakDays),
      _prefs.setInt(_keyTotalXp, progress.totalXp),
      _prefs.setInt(_keyLevel, progress.level),
      _prefs.setInt(_keyTodayAssessments, progress.todayAssessmentCount),
      _prefs.setString(_keyLastActive, progress.lastActiveDate?.toIso8601String() ?? ''),
      _prefs.setStringList(_keyCompletedLessons, progress.completedLessons.toList()),
      _prefs.setStringList(_keyCompletedUnits, progress.completedUnits.toList()),
      _prefs.setStringList(_keyEarnedBadges, progress.earnedBadges.toList()),
      _prefs.setBool(_keyIsPro, progress.isPro),
      _prefs.setInt(_keyStreakFreeze, progress.streakFreezeRemaining),
    ]);
  }
}
