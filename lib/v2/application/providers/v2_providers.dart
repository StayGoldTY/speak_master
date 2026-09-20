import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../daily/application/session_composer.dart';
import '../../../daily/domain/session_models.dart';
import '../../../models/user_progress.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/progress_provider.dart';
import '../../../providers/service_providers.dart';
import '../../../services/storage_service.dart';
import '../../domain/models/course_models.dart';
import '../../domain/models/learner_models.dart';
import '../../domain/models/speech_models.dart';
import '../../domain/repositories/v2_learning_repository.dart';
import '../services/legacy_seed_learning_repository.dart';
import '../services/local_assessment_report_builder.dart';
import '../services/speech_feedback_engine.dart';
import '../services/v2_speech_assessment_service.dart';

class V2LearnerSetupNotifier extends StateNotifier<V2LearnerSetupState> {
  final Ref _ref;

  V2LearnerSetupNotifier(this._ref)
    : super(
        const V2LearnerSetupState(
          goal: LearningGoal.pronunciationConfidence,
          placementLevel: PlacementLevel.starter,
          dailyMinutes: 15,
          onboardingComplete: false,
          accentPreference: 'american',
        ),
      ) {
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final storage = _ref.read(storageServiceProvider);
    await storage.init();
    state = V2LearnerSetupState(
      goal: LearningGoalX.fromKey(storage.loadV2LearningGoal()),
      placementLevel: PlacementLevelX.fromKey(storage.loadV2PlacementLevel()),
      dailyMinutes: storage.loadV2DailyMinutes(),
      onboardingComplete: storage.loadV2OnboardingComplete(),
      accentPreference: storage.loadAccentPreference(),
    );
  }

  Future<void> setGoal(LearningGoal goal) async {
    state = state.copyWith(goal: goal);
    await _ref.read(storageServiceProvider).saveV2LearningGoal(goal.key);
  }

  Future<void> setPlacementLevel(PlacementLevel level) async {
    state = state.copyWith(placementLevel: level);
    await _ref.read(storageServiceProvider).saveV2PlacementLevel(level.key);
  }

  Future<void> setDailyMinutes(int minutes) async {
    state = state.copyWith(dailyMinutes: minutes);
    await _ref.read(storageServiceProvider).saveV2DailyMinutes(minutes);
  }

  Future<void> setAccentPreference(String accentPreference) async {
    state = state.copyWith(accentPreference: accentPreference);
    await _ref.read(storageServiceProvider).saveAccentPreference(accentPreference);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(onboardingComplete: true);
    await _ref.read(storageServiceProvider).saveV2OnboardingComplete(true);
  }
}

final v2LearningRepositoryProvider = Provider<V2LearningRepository>((ref) {
  return LegacySeedLearningRepository();
});

final v2SpeechFeedbackEngineProvider = Provider<SpeechFeedbackEngine>((ref) {
  return const SpeechFeedbackEngine();
});

final v2LocalAssessmentReportBuilderProvider =
    Provider<LocalAssessmentReportBuilder>((ref) {
      return const LocalAssessmentReportBuilder();
    });

final v2SpeechAssessmentServiceProvider = Provider<V2SpeechAssessmentService>((
  ref,
) {
  return V2SpeechAssessmentService(
    client: ref.watch(supabaseClientProvider),
    feedbackEngine: ref.watch(v2SpeechFeedbackEngineProvider),
    reportBuilder: ref.watch(v2LocalAssessmentReportBuilderProvider),
  );
});

final v2LearnerSetupProvider =
    StateNotifierProvider<V2LearnerSetupNotifier, V2LearnerSetupState>((ref) {
      return V2LearnerSetupNotifier(ref);
    });

final v2LearnerProfileProvider = Provider<LearnerProfileV2>((ref) {
  final auth = ref.watch(authProvider);
  final setup = ref.watch(v2LearnerSetupProvider);

  return LearnerProfileV2(
    displayName: auth.profile?.displayName ?? '学习者',
    goal: setup.goal,
    placementLevel: setup.placementLevel,
    accentPreference:
        auth.profile?.accentPreference ?? setup.accentPreference,
    dailyMinutes: setup.dailyMinutes,
    onboardingComplete: setup.onboardingComplete,
  );
});

final v2PrimaryTrackProvider = Provider<CourseTrack>((ref) {
  return ref.watch(v2LearningRepositoryProvider).getPrimaryTrack();
});

final v2LessonProvider = Provider.family<LessonBlueprint?, String>((
  ref,
  lessonId,
) {
  return ref.watch(v2LearningRepositoryProvider).getLessonById(lessonId);
});

final v2UnitProvider = Provider.family<UnitBlueprint?, String>((ref, unitId) {
  return ref.watch(v2LearningRepositoryProvider).getUnitById(unitId);
});

DailyPlan _composeLiveDailyPlan({
  required V2LearningRepository repo,
  required UserProgress progress,
  required LearnerProfileV2 learner,
}) {
  return repo.buildDailyPlan(
    progress: progress,
    learnerName: learner.displayName,
    learner: learner,
  );
}

class FrozenDailyPlanNotifier extends StateNotifier<DailyPlan?> {
  final Ref _ref;

  FrozenDailyPlanNotifier(this._ref) : super(null) {
    _hydrate();
  }

  Future<void> _hydrate() async {
    final storage = _ref.read(storageServiceProvider);
    await storage.init();
    final today = storage.todayKey();
    final frozen = storage.loadFrozenDailyPlan(today);
    if (frozen != null && frozen.items.isNotEmpty) {
      state = frozen;
      return;
    }
    if (state != null && state!.items.isNotEmpty) {
      await storage.saveFrozenDailyPlan(dateKey: today, plan: state!);
      return;
    }
    final live = _composeLiveDailyPlan(
      repo: _ref.read(v2LearningRepositoryProvider),
      progress: storage.loadProgress(),
      learner: _learnerFromStorage(storage),
    );
    state = live;
    await storage.saveFrozenDailyPlan(dateKey: today, plan: live);
  }

  LearnerProfileV2 _learnerFromStorage(StorageService storage) {
    final auth = _ref.read(authProvider);
    return LearnerProfileV2(
      displayName: auth.profile?.displayName ?? '学习者',
      goal: LearningGoalX.fromKey(storage.loadV2LearningGoal()),
      placementLevel: PlacementLevelX.fromKey(storage.loadV2PlacementLevel()),
      accentPreference:
          auth.profile?.accentPreference ?? storage.loadAccentPreference(),
      dailyMinutes: storage.loadV2DailyMinutes(),
      onboardingComplete: storage.loadV2OnboardingComplete(),
    );
  }
}

final frozenDailyPlanProvider =
    StateNotifierProvider<FrozenDailyPlanNotifier, DailyPlan?>((ref) {
      return FrozenDailyPlanNotifier(ref);
    });

final v2DailyPlanProvider = Provider<DailyPlan>((ref) {
  final frozen = ref.watch(frozenDailyPlanProvider);
  if (frozen != null && frozen.items.isNotEmpty) {
    return frozen;
  }

  return _composeLiveDailyPlan(
    repo: ref.watch(v2LearningRepositoryProvider),
    progress: ref.watch(progressProvider),
    learner: ref.watch(v2LearnerProfileProvider),
  );
});

final v2MasterySnapshotProvider = Provider<MasterySnapshot>((ref) {
  return ref
      .watch(v2LearningRepositoryProvider)
      .buildMasterySnapshot(ref.watch(progressProvider));
});

final v2FeaturedTargetsProvider = Provider<List<PronunciationTarget>>((ref) {
  return ref.watch(v2LearningRepositoryProvider).getFeaturedTargets();
});

final v2SpeakingPromptsProvider = Provider<List<SpeakingPrompt>>((ref) {
  return ref.watch(v2LearningRepositoryProvider).getSpeakingPrompts();
});

final v2RecentSpeakingAttemptsProvider =
    FutureProvider.family<List<SpeakingAttemptRecord>, SpeakingPrompt>((
      ref,
      prompt,
    ) {
      return ref
          .watch(v2SpeechAssessmentServiceProvider)
          .loadRecentAttempts(prompt: prompt);
    });

final v2OpsDashboardProvider = Provider<OpsDashboard>((ref) {
  return ref.watch(v2LearningRepositoryProvider).buildOpsDashboard();
});

final sessionComposerProvider = Provider<SessionComposer>((ref) {
  return const SessionComposer();
});

class DailyLoopNotifier extends StateNotifier<DailyLoopState> {
  final Ref _ref;

  DailyLoopNotifier(this._ref)
    : super(const DailyLoopState(dateKey: '', completedTaskIds: {})) {
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final storage = _ref.read(storageServiceProvider);
    await storage.init();
    final today = storage.todayKey();
    final storedDate = storage.loadDailyLoopDate();
    if (state.dateKey == today && state.completedTaskIds.isNotEmpty) {
      return;
    }
    if (storedDate != today) {
      state = DailyLoopState(dateKey: today, completedTaskIds: {});
      return;
    }
    state = DailyLoopState(
      dateKey: today,
      completedTaskIds: {
        ...storage.loadDailyCompletedTaskIds(),
        if (state.dateKey == today) ...state.completedTaskIds,
      },
    );
  }

  Future<void> completeTask(String taskId) async {
    if (taskId.trim().isEmpty || state.completedTaskIds.contains(taskId)) {
      return;
    }
    final storage = _ref.read(storageServiceProvider);
    final today = storage.todayKey();
    final next = {
      if (state.dateKey == today) ...state.completedTaskIds,
      taskId,
    };
    state = DailyLoopState(dateKey: today, completedTaskIds: next);
    await storage.saveDailyLoop(dateKey: today, completedTaskIds: next);
  }
}

final dailyLoopProvider =
    StateNotifierProvider<DailyLoopNotifier, DailyLoopState>((ref) {
      return DailyLoopNotifier(ref);
    });

class PracticeLogNotifier extends StateNotifier<List<PracticeLogEntry>> {
  final Ref _ref;

  PracticeLogNotifier(this._ref) : super(const []) {
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final storage = _ref.read(storageServiceProvider);
    await storage.init();
    state = storage.loadPracticeLog();
  }

  Future<void> add(PracticeLogEntry entry) async {
    final next = [entry, ...state].take(20).toList();
    state = next;
    await _ref.read(storageServiceProvider).savePracticeLog(next);
  }
}

final practiceLogProvider =
    StateNotifierProvider<PracticeLogNotifier, List<PracticeLogEntry>>((ref) {
      return PracticeLogNotifier(ref);
    });

final journeySnapshotProvider = Provider<JourneySnapshot>((ref) {
  final progress = ref.watch(progressProvider);
  final track = ref.watch(v2PrimaryTrackProvider);
  final learner = ref.watch(v2LearnerProfileProvider);
  final totalLessons = track.units.fold<int>(
    0,
    (sum, unit) => sum + unit.lessons.length,
  );
  final completed = progress.completedLessons.length;
  final band = switch (completed) {
    >= 18 => JourneyBand.confident,
    >= 9 => JourneyBand.intermediate,
    >= 3 => JourneyBand.elementary,
    _ => JourneyBand.starter,
  };
  final bounds = switch (band) {
    JourneyBand.starter => (0, 3),
    JourneyBand.elementary => (3, 9),
    JourneyBand.intermediate => (9, 18),
    JourneyBand.confident => (18, totalLessons == 0 ? 30 : totalLessons),
  };
  final span = (bounds.$2 - bounds.$1).clamp(1, 100);
  final progressToNext = ((completed - bounds.$1) / span).clamp(0.0, 1.0);

  return JourneySnapshot(
    band: band,
    progressToNext: progressToNext,
    completedLessons: completed,
    totalLessons: totalLessons,
    recommendedMinutes: learner.dailyMinutes,
    summary: completed == 0
        ? '先完成今日 3 个开口任务，旅程才会开始往前走。'
        : '已完成 $completed / $totalLessons 节开口课，正在从${band.title}走向${band.nextTitle}。',
  );
});
