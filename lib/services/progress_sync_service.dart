import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_progress.dart';
import '../models/community.dart';
import 'storage_service.dart';

class ProgressSyncService {
  final SupabaseClient? _client;
  final StorageService _localStorage;

  ProgressSyncService(this._client, this._localStorage);

  String? get _userId => _client?.auth.currentUser?.id;
  bool get _hasCloud => _client != null && _userId != null;

  Future<UserProgress> loadProgress() async {
    if (!_hasCloud) {
      return _localStorage.loadProgress();
    }

    try {
      final data = await _client!
          .from('user_progress')
          .select()
          .eq('user_id', _userId!)
          .maybeSingle();

      if (data == null) return UserProgress.empty(_userId!);

      final profile = await _client!
          .from('profiles')
          .select('is_pro')
          .eq('id', _userId!)
          .maybeSingle();

      final progress = UserProgress.fromJson(data).copyWith(
        isPro: profile?['is_pro'] as bool? ?? false,
      );

      await _localStorage.saveProgress(progress);
      return progress;
    } catch (e) {
      debugPrint('Cloud load failed, using local: $e');
      return _localStorage.loadProgress();
    }
  }

  Future<void> saveProgress(UserProgress progress) async {
    await _localStorage.saveProgress(progress);
    if (!_hasCloud) return;

    try {
      await _client!.from('user_progress').upsert(progress.toJson());
    } catch (e) {
      debugPrint('Cloud sync failed: $e');
    }
  }

  Future<void> saveAssessment(AssessmentRecord record) async {
    if (!_hasCloud) return;
    try {
      await _client!.from('assessment_records').insert(record.toJson());
    } catch (e) {
      debugPrint('Save assessment failed: $e');
    }
  }

  Future<List<AssessmentRecord>> getAssessmentHistory({int limit = 20}) async {
    if (!_hasCloud) return [];
    try {
      final data = await _client!
          .from('assessment_records')
          .select()
          .eq('user_id', _userId!)
          .order('created_at', ascending: false)
          .limit(limit);
      return (data as List).map((e) => AssessmentRecord.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> syncLocalToCloud() async {
    if (!_hasCloud) return;

    final localProgress = _localStorage.loadProgress();
    final cloudProgress = await _fetchCloudProgress();

    if (cloudProgress == null) {
      await saveProgress(localProgress.copyWith(userId: _userId));
      return;
    }

    final merged = _mergeProgress(localProgress, cloudProgress);
    await saveProgress(merged);
  }

  Future<UserProgress?> _fetchCloudProgress() async {
    try {
      final data = await _client!
          .from('user_progress')
          .select()
          .eq('user_id', _userId!)
          .maybeSingle();
      return data != null ? UserProgress.fromJson(data) : null;
    } catch (e) {
      return null;
    }
  }

  UserProgress _mergeProgress(UserProgress local, UserProgress cloud) {
    return UserProgress(
      userId: _userId ?? local.userId,
      streakDays: local.streakDays > cloud.streakDays ? local.streakDays : cloud.streakDays,
      totalXp: local.totalXp > cloud.totalXp ? local.totalXp : cloud.totalXp,
      level: local.level > cloud.level ? local.level : cloud.level,
      todayAssessmentCount: local.todayAssessmentCount > cloud.todayAssessmentCount
          ? local.todayAssessmentCount : cloud.todayAssessmentCount,
      lastActiveDate: _laterDate(local.lastActiveDate, cloud.lastActiveDate),
      completedLessons: {...local.completedLessons, ...cloud.completedLessons},
      completedUnits: {...local.completedUnits, ...cloud.completedUnits},
      earnedBadges: {...local.earnedBadges, ...cloud.earnedBadges},
      phonemeScores: {...cloud.phonemeScores, ...local.phonemeScores},
      streakFreezeRemaining: local.streakFreezeRemaining > cloud.streakFreezeRemaining
          ? local.streakFreezeRemaining : cloud.streakFreezeRemaining,
      isPro: local.isPro || cloud.isPro,
    );
  }

  DateTime? _laterDate(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isAfter(b) ? a : b;
  }
}
