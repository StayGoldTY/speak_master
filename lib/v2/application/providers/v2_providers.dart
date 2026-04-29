import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/progress_provider.dart';
import '../../../providers/service_providers.dart';
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
  final storage = ref.watch(storageServiceProvider);

  return LearnerProfileV2(
    displayName: auth.profile?.displayName ?? '学习者',
    goal: setup.goal,
    placementLevel: setup.placementLevel,
    accentPreference:
        auth.profile?.accentPreference ?? storage.loadAccentPreference(),
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

final v2DailyPlanProvider = Provider<DailyPlan>((ref) {
  final repo = ref.watch(v2LearningRepositoryProvider);
  final progress = ref.watch(progressProvider);
  final learner = ref.watch(v2LearnerProfileProvider);

  return repo.buildDailyPlan(
    progress: progress,
    learnerName: learner.displayName,
    learner: learner,
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
