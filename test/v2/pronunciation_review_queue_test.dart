import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_master/models/user_progress.dart';
import 'package:speak_master/services/storage_service.dart';
import 'package:speak_master/v2/application/services/legacy_seed_learning_repository.dart';
import 'package:speak_master/v2/domain/models/learner_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'local progress persists pronunciation review entries and phoneme scores',
    () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init();

      final progress = const UserProgress(userId: 'local').copyWith(
        phonemeScores: {'c_θ': 42},
        pronunciationReviewEntries: [
          PronunciationReviewEntry(
            id: 'assessment_thursday:three',
            label: 'three',
            reason: 'TH was not stable in this attempt.',
            recommendedActivityKindKey: 'wordRepeat',
            recommendedActivityLabel: '单词跟读',
            sourcePromptId: 'assessment_thursday',
            weaknessScore: 72,
            createdAt: DateTime(2026, 4, 29, 9),
          ),
        ],
      );

      await storage.saveProgress(progress);
      final loaded = storage.loadProgress();

      expect(loaded.phonemeScores['c_θ'], 42);
      expect(loaded.pronunciationReviewEntries, hasLength(1));
      expect(loaded.pronunciationReviewEntries.single.label, 'three');

      final snapshot = LegacySeedLearningRepository().buildMasterySnapshot(
        loaded,
      );
      expect(snapshot.reviewQueue.map((item) => item.label), contains('three'));

      const learner = LearnerProfileV2(
        displayName: 'Ada',
        goal: LearningGoal.pronunciationConfidence,
        placementLevel: PlacementLevel.starter,
        accentPreference: 'american',
        dailyMinutes: 15,
        onboardingComplete: true,
      );
      final plan = LegacySeedLearningRepository().buildDailyPlan(
        progress: loaded,
        learnerName: 'Ada',
        learner: learner,
      );
      expect(plan.items[1].route, '/speaking?prompt=assessment_thursday');
    },
  );
}
