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
      oderId: 'local',
      streakDays: _prefs.getInt(_keyStreak) ?? 0,
      totalXp: _prefs.getInt(_keyTotalXp) ?? 0,
      level: _prefs.getInt(_keyLevel) ?? 1,
      todayAssessmentCount: _prefs.getInt(_keyTodayAssessments) ?? 0,
      lastActiveDate: _prefs.getString(_keyLastActive) != null
          ? DateTime.parse(_prefs.getString(_keyLastActive)!)
          : null,
      completedLessons: (_prefs.getStringList(_keyCompletedLessons) ?? []).toSet(),
      completedUnits: (_prefs.getStringList(_keyCompletedUnits) ?? []).toSet(),
      earnedBadges: (_prefs.getStringList(_keyEarnedBadges) ?? []).toSet(),
      isPro: _prefs.getBool(_keyIsPro) ?? false,
      streakFreezeRemaining: _prefs.getInt(_keyStreakFreeze) ?? 1,
    );
  }

  Future<void> saveProgress(UserProgress progress) async {
    await _prefs.setInt(_keyStreak, progress.streakDays);
    await _prefs.setInt(_keyTotalXp, progress.totalXp);
    await _prefs.setInt(_keyLevel, progress.level);
    await _prefs.setInt(_keyTodayAssessments, progress.todayAssessmentCount);
    await _prefs.setString(_keyLastActive, progress.lastActiveDate?.toIso8601String() ?? '');
    await _prefs.setStringList(_keyCompletedLessons, progress.completedLessons.toList());
    await _prefs.setStringList(_keyCompletedUnits, progress.completedUnits.toList());
    await _prefs.setStringList(_keyEarnedBadges, progress.earnedBadges.toList());
    await _prefs.setBool(_keyIsPro, progress.isPro);
    await _prefs.setInt(_keyStreakFreeze, progress.streakFreezeRemaining);
  }

  Future<void> completeLesson(String lessonId) async {
    final lessons = _prefs.getStringList(_keyCompletedLessons) ?? [];
    if (!lessons.contains(lessonId)) {
      lessons.add(lessonId);
      await _prefs.setStringList(_keyCompletedLessons, lessons);
    }
  }

  Future<void> addXp(int xp) async {
    final current = _prefs.getInt(_keyTotalXp) ?? 0;
    await _prefs.setInt(_keyTotalXp, current + xp);
  }
}
