import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_progress.dart';
import 'service_providers.dart';

class ProgressNotifier extends StateNotifier<UserProgress> {
  final Ref _ref;

  ProgressNotifier(this._ref) : super(const UserProgress(userId: 'local')) {
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    try {
      await _ref.read(storageServiceProvider).init();
      final progress = await _ref
          .read(progressSyncServiceProvider)
          .loadProgress();
      state = progress;
    } catch (e) {
      debugPrint('Failed to load initial progress: $e');
    }
  }

  Future<void> reload() async => _loadInitial();

  Future<void> completeLesson(String lessonId) async {
    if (state.completedLessons.contains(lessonId)) {
      return;
    }

    final syncService = _ref.read(progressSyncServiceProvider);
    final gamService = _ref.read(gamificationServiceProvider);

    var updated = state.copyWith(
      completedLessons: {...state.completedLessons, lessonId},
    );
    updated = gamService.addXp(updated, 10);
    updated = gamService.updateStreak(updated);
    updated = gamService.checkBadges(updated);

    state = updated;
    await syncService.saveProgress(updated);
  }

  Future<void> addXp(int xp) async {
    final syncService = _ref.read(progressSyncServiceProvider);
    final gamService = _ref.read(gamificationServiceProvider);

    var updated = gamService.addXp(state, xp);
    updated = gamService.checkBadges(updated);

    state = updated;
    await syncService.saveProgress(updated);
  }

  Future<void> updateStreak() async {
    final syncService = _ref.read(progressSyncServiceProvider);
    final gamService = _ref.read(gamificationServiceProvider);

    var updated = gamService.updateStreak(state);
    updated = gamService.checkBadges(updated);

    state = updated;
    await syncService.saveProgress(updated);
  }

  Future<void> completeUnit(String unitId) async {
    final syncService = _ref.read(progressSyncServiceProvider);
    final updated = state.copyWith(
      completedUnits: {...state.completedUnits, unitId},
    );
    state = updated;
    await syncService.saveProgress(updated);
  }

  Future<void> updatePhonemeScore(String phonemeId, double score) async {
    final syncService = _ref.read(progressSyncServiceProvider);
    final updated = state.copyWith(
      phonemeScores: {...state.phonemeScores, phonemeId: score},
    );
    state = updated;
    await syncService.saveProgress(updated);
  }

  Future<void> completeAssessment({
    int xp = 20,
    Map<String, double> phonemeUpdates = const {},
  }) async {
    final syncService = _ref.read(progressSyncServiceProvider);
    final gamService = _ref.read(gamificationServiceProvider);

    var updated = state.copyWith(
      todayAssessmentCount: state.todayAssessmentCount + 1,
      phonemeScores: {...state.phonemeScores, ...phonemeUpdates},
    );

    updated = gamService.addXp(updated, xp);
    updated = gamService.updateStreak(updated);
    updated = gamService.checkBadges(updated);

    state = updated;
    await syncService.saveProgress(updated);
  }

  Future<void> recordSpeakingPractice({
    int xp = 8,
    bool countAssessment = false,
    List<PronunciationReviewEntry> reviewEntries = const [],
  }) async {
    final syncService = _ref.read(progressSyncServiceProvider);
    final gamService = _ref.read(gamificationServiceProvider);

    var updated = state.copyWith(
      todayAssessmentCount: countAssessment
          ? state.todayAssessmentCount + 1
          : state.todayAssessmentCount,
      pronunciationReviewEntries: _mergeReviewEntries(
        state.pronunciationReviewEntries,
        reviewEntries,
      ),
    );

    updated = gamService.addXp(updated, xp);
    updated = gamService.updateStreak(updated);
    updated = gamService.checkBadges(updated);

    state = updated;
    await syncService.saveProgress(updated);
  }

  List<PronunciationReviewEntry> _mergeReviewEntries(
    List<PronunciationReviewEntry> existing,
    List<PronunciationReviewEntry> incoming,
  ) {
    final merged = <String, PronunciationReviewEntry>{};
    for (final entry in [...existing, ...incoming]) {
      merged[entry.id] = entry;
    }
    final values = merged.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return values.take(20).toList();
  }
}

final progressProvider = StateNotifierProvider<ProgressNotifier, UserProgress>((
  ref,
) {
  return ProgressNotifier(ref);
});
