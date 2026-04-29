import 'package:flutter_test/flutter_test.dart';
import 'package:speak_master/models/user_progress.dart';
import 'package:speak_master/v2/application/services/legacy_seed_learning_repository.dart';
import 'package:speak_master/v2/domain/models/learner_models.dart';

void main() {
  group('Daily plan personalization', () {
    final repository = LegacySeedLearningRepository();
    const progress = UserProgress(userId: 'local');

    LearnerProfileV2 learner({
      required LearningGoal goal,
      required PlacementLevel placementLevel,
      required int dailyMinutes,
    }) {
      return LearnerProfileV2(
        displayName: 'Ada',
        goal: goal,
        placementLevel: placementLevel,
        accentPreference: 'american',
        dailyMinutes: dailyMinutes,
        onboardingComplete: true,
      );
    }

    test('pronunciation learners get an assessment-oriented short plan', () {
      final plan = repository.buildDailyPlan(
        progress: progress,
        learnerName: 'Ada',
        learner: learner(
          goal: LearningGoal.pronunciationConfidence,
          placementLevel: PlacementLevel.starter,
          dailyMinutes: 10,
        ),
      );

      expect(plan.subtitle, contains('10 分钟'));
      expect(plan.items, hasLength(3));
      expect(plan.items.last.title, '发音状态测评');
      expect(
        plan.items.fold<int>(0, (total, item) => total + item.estimatedMinutes),
        lessThanOrEqualTo(10),
      );
    });

    test('workplace learners get a workplace speaking task in the plan', () {
      final plan = repository.buildDailyPlan(
        progress: progress,
        learnerName: 'Ada',
        learner: learner(
          goal: LearningGoal.workplaceSpeaking,
          placementLevel: PlacementLevel.intermediate,
          dailyMinutes: 30,
        ),
      );

      expect(plan.subtitle, contains('职场表达'));
      expect(plan.items.last.title, '会议进度汇报');
      expect(plan.items.last.subtitle, contains('会议'));
      expect(
        plan.items.fold<int>(0, (total, item) => total + item.estimatedMinutes),
        greaterThanOrEqualTo(24),
      );
    });
  });
}
