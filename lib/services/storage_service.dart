import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../daily/domain/session_models.dart';
import '../models/user_progress.dart';
import '../v2/domain/models/learner_models.dart';

class StorageService {
  StorageService._internal();

  static final StorageService _instance = StorageService._internal();

  factory StorageService() => _instance;

  static const _keyStreak = 'streak_days';
  static const _keyTotalXp = 'total_xp';
  static const _keyLevel = 'level';
  static const _keyLastActive = 'last_active';
  static const _keyCompletedLessons = 'completed_lessons';
  static const _keyCompletedUnits = 'completed_units';
  static const _keyEarnedBadges = 'earned_badges';
  static const _keyPhonemeScores = 'phoneme_scores';
  static const _keyPronunciationReviewEntries = 'pronunciation_review_entries';
  static const _keyIsPro = 'is_pro';
  static const _keyTodayAssessments = 'today_assessments';
  static const _keyStreakFreeze = 'streak_freeze';
  static const _keyAccentPreference = 'accent_preference';
  static const _keyReminderEnabled = 'reminder_enabled';
  static const _keyReminderHour = 'reminder_hour';
  static const _keyReminderMinute = 'reminder_minute';
  static const _keyV2OnboardingComplete = 'v2_onboarding_complete';
  static const _keyV2LearningGoal = 'v2_learning_goal';
  static const _keyV2PlacementLevel = 'v2_placement_level';
  static const _keyV2DailyMinutes = 'v2_daily_minutes';
  static const _keyDailyLoopDate = 'daily_loop_date';
  static const _keyDailyCompletedTasks = 'daily_completed_task_ids';
  static const _keyPracticeLog = 'daily_practice_log';
  static const _keyFrozenDailyPlan = 'daily_frozen_plan';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  UserProgress loadProgress() {
    final prefs = _prefs;
    if (prefs == null) {
      return const UserProgress(userId: 'local');
    }

    final lastActive = prefs.getString(_keyLastActive);

    return UserProgress(
      userId: 'local',
      streakDays: prefs.getInt(_keyStreak) ?? 0,
      totalXp: prefs.getInt(_keyTotalXp) ?? 0,
      level: prefs.getInt(_keyLevel) ?? 1,
      todayAssessmentCount: prefs.getInt(_keyTodayAssessments) ?? 0,
      lastActiveDate: lastActive != null && lastActive.isNotEmpty
          ? DateTime.tryParse(lastActive)
          : null,
      completedLessons: (prefs.getStringList(_keyCompletedLessons) ?? const [])
          .toSet(),
      completedUnits: (prefs.getStringList(_keyCompletedUnits) ?? const [])
          .toSet(),
      earnedBadges: (prefs.getStringList(_keyEarnedBadges) ?? const []).toSet(),
      phonemeScores: _loadPhonemeScores(prefs),
      pronunciationReviewEntries: _loadPronunciationReviewEntries(prefs),
      isPro: prefs.getBool(_keyIsPro) ?? false,
      streakFreezeRemaining: prefs.getInt(_keyStreakFreeze) ?? 1,
    );
  }

  Future<void> saveProgress(UserProgress progress) async {
    await init();
    final prefs = _prefs!;

    await Future.wait([
      prefs.setInt(_keyStreak, progress.streakDays),
      prefs.setInt(_keyTotalXp, progress.totalXp),
      prefs.setInt(_keyLevel, progress.level),
      prefs.setInt(_keyTodayAssessments, progress.todayAssessmentCount),
      prefs.setString(
        _keyLastActive,
        progress.lastActiveDate?.toIso8601String() ?? '',
      ),
      prefs.setStringList(
        _keyCompletedLessons,
        progress.completedLessons.toList(),
      ),
      prefs.setStringList(_keyCompletedUnits, progress.completedUnits.toList()),
      prefs.setStringList(_keyEarnedBadges, progress.earnedBadges.toList()),
      prefs.setString(_keyPhonemeScores, jsonEncode(progress.phonemeScores)),
      prefs.setStringList(
        _keyPronunciationReviewEntries,
        progress.pronunciationReviewEntries
            .map((entry) => jsonEncode(entry.toJson()))
            .toList(),
      ),
      prefs.setBool(_keyIsPro, progress.isPro),
      prefs.setInt(_keyStreakFreeze, progress.streakFreezeRemaining),
    ]);
  }

  String loadAccentPreference({String fallback = 'american'}) {
    final prefs = _prefs;
    if (prefs == null) {
      return fallback;
    }

    return prefs.getString(_keyAccentPreference) ?? fallback;
  }

  Future<void> saveAccentPreference(String accentPreference) async {
    await init();
    await _prefs!.setString(_keyAccentPreference, accentPreference);
  }

  ReminderPreference loadReminderPreference() {
    final prefs = _prefs;
    if (prefs == null) {
      return const ReminderPreference(enabled: false, hour: 20, minute: 0);
    }

    return ReminderPreference(
      enabled: prefs.getBool(_keyReminderEnabled) ?? false,
      hour: prefs.getInt(_keyReminderHour) ?? 20,
      minute: prefs.getInt(_keyReminderMinute) ?? 0,
    );
  }

  Future<void> saveReminderPreference(ReminderPreference preference) async {
    await init();
    await Future.wait([
      _prefs!.setBool(_keyReminderEnabled, preference.enabled),
      _prefs!.setInt(_keyReminderHour, preference.hour),
      _prefs!.setInt(_keyReminderMinute, preference.minute),
    ]);
  }

  bool loadV2OnboardingComplete() {
    final prefs = _prefs;
    if (prefs == null) {
      return false;
    }

    return prefs.getBool(_keyV2OnboardingComplete) ?? false;
  }

  Future<void> saveV2OnboardingComplete(bool value) async {
    await init();
    await _prefs!.setBool(_keyV2OnboardingComplete, value);
  }

  String loadV2LearningGoal({String fallback = 'pronunciationConfidence'}) {
    final prefs = _prefs;
    if (prefs == null) {
      return fallback;
    }

    return prefs.getString(_keyV2LearningGoal) ?? fallback;
  }

  Future<void> saveV2LearningGoal(String value) async {
    await init();
    await _prefs!.setString(_keyV2LearningGoal, value);
  }

  String loadV2PlacementLevel({String fallback = 'starter'}) {
    final prefs = _prefs;
    if (prefs == null) {
      return fallback;
    }

    return prefs.getString(_keyV2PlacementLevel) ?? fallback;
  }

  Future<void> saveV2PlacementLevel(String value) async {
    await init();
    await _prefs!.setString(_keyV2PlacementLevel, value);
  }

  int loadV2DailyMinutes({int fallback = 15}) {
    final prefs = _prefs;
    if (prefs == null) {
      return fallback;
    }

    return prefs.getInt(_keyV2DailyMinutes) ?? fallback;
  }

  Future<void> saveV2DailyMinutes(int value) async {
    await init();
    await _prefs!.setInt(_keyV2DailyMinutes, value);
  }

  String todayKey([DateTime? now]) {
    final date = now ?? DateTime.now();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String loadDailyLoopDate() {
    final prefs = _prefs;
    if (prefs == null) {
      return '';
    }
    return prefs.getString(_keyDailyLoopDate) ?? '';
  }

  List<String> loadDailyCompletedTaskIds() {
    final prefs = _prefs;
    if (prefs == null) {
      return const [];
    }
    return prefs.getStringList(_keyDailyCompletedTasks) ?? const [];
  }

  Future<void> saveDailyLoop({
    required String dateKey,
    required Iterable<String> completedTaskIds,
  }) async {
    await init();
    await Future.wait([
      _prefs!.setString(_keyDailyLoopDate, dateKey),
      _prefs!.setStringList(_keyDailyCompletedTasks, completedTaskIds.toList()),
    ]);
  }

  List<PracticeLogEntry> loadPracticeLog() {
    final prefs = _prefs;
    if (prefs == null) {
      return const [];
    }
    final raw = prefs.getStringList(_keyPracticeLog) ?? const [];
    return raw
        .map((item) {
          try {
            final decoded = jsonDecode(item);
            if (decoded is Map) {
              return PracticeLogEntry.fromJson(
                decoded.map((key, value) => MapEntry(key.toString(), value)),
              );
            }
          } catch (_) {
            return null;
          }
          return null;
        })
        .whereType<PracticeLogEntry>()
        .toList();
  }

  DailyPlan? loadFrozenDailyPlan(String dateKey) {
    final prefs = _prefs;
    if (prefs == null) {
      return null;
    }
    final raw = prefs.getString(_keyFrozenDailyPlan);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return null;
      }
      if (decoded['dateKey']?.toString() != dateKey) {
        return null;
      }
      final plan = decoded['plan'];
      if (plan is! Map) {
        return null;
      }
      return DailyPlan.fromJson(
        plan.map((key, value) => MapEntry(key.toString(), value)),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveFrozenDailyPlan({
    required String dateKey,
    required DailyPlan plan,
  }) async {
    await init();
    await _prefs!.setString(
      _keyFrozenDailyPlan,
      jsonEncode({'dateKey': dateKey, 'plan': plan.toJson()}),
    );
  }

  Future<void> savePracticeLog(List<PracticeLogEntry> entries) async {
    await init();
    await _prefs!.setStringList(
      _keyPracticeLog,
      entries.map((entry) => jsonEncode(entry.toJson())).toList(),
    );
  }

  Map<String, double> _loadPhonemeScores(SharedPreferences prefs) {
    final raw = prefs.getString(_keyPhonemeScores);
    if (raw == null || raw.trim().isEmpty) {
      return const {};
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return const {};
      }

      return decoded.map(
        (key, value) =>
            MapEntry(key.toString(), (value as num?)?.toDouble() ?? 0),
      );
    } catch (_) {
      return const {};
    }
  }

  List<PronunciationReviewEntry> _loadPronunciationReviewEntries(
    SharedPreferences prefs,
  ) {
    final rawEntries =
        prefs.getStringList(_keyPronunciationReviewEntries) ?? const [];

    return rawEntries
        .map((raw) {
          try {
            final decoded = jsonDecode(raw);
            if (decoded is Map) {
              return PronunciationReviewEntry.fromJson(
                decoded.map((key, value) => MapEntry(key.toString(), value)),
              );
            }
          } catch (_) {
            return null;
          }
          return null;
        })
        .whereType<PronunciationReviewEntry>()
        .toList();
  }
}

class ReminderPreference {
  final bool enabled;
  final int hour;
  final int minute;

  const ReminderPreference({
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  String get label {
    final hh = hour.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  ReminderPreference copyWith({bool? enabled, int? hour, int? minute}) {
    return ReminderPreference(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }
}
