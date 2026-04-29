import 'package:flutter_test/flutter_test.dart';
import 'package:speak_master/models/user_progress.dart';
import 'package:speak_master/v2/application/services/legacy_seed_learning_repository.dart';
import 'package:speak_master/v2/domain/models/learner_models.dart';

void main() {
  test('V2 seed repository exposes the pronunciation foundation track', () {
    final repository = LegacySeedLearningRepository();
    final track = repository.getPrimaryTrack();

    expect(track.id, 'pronunciation_foundation');
    expect(track.title, '发音基础课');
    expect(track.units, hasLength(10));
    expect(track.units.first.lessons, isNotEmpty);
    expect(repository.getLessonById('u1_L1'), isNotNull);
    expect(repository.getFeaturedTargets(), isNotEmpty);
  });

  test(
    'V2 seed repository builds a daily plan from next lesson and review loop',
    () {
      final repository = LegacySeedLearningRepository();
      const progress = UserProgress(userId: 'local');
      const learner = LearnerProfileV2(
        displayName: 'Taylor',
        goal: LearningGoal.pronunciationConfidence,
        placementLevel: PlacementLevel.starter,
        accentPreference: 'american',
        dailyMinutes: 15,
        onboardingComplete: true,
      );
      final plan = repository.buildDailyPlan(
        progress: progress,
        learnerName: 'Taylor',
        learner: learner,
      );

      expect(plan.items, hasLength(3));
      expect(plan.headline, contains('Taylor'));
      expect(plan.items.first.route, '/lesson/u1_L1');
      expect(plan.items.first.title, isNotEmpty);
    },
  );
}
