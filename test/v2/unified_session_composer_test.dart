import 'package:flutter_test/flutter_test.dart';
import 'package:speak_master/models/srs_memory.dart';
import 'package:speak_master/models/user_progress.dart';
import 'package:speak_master/v2/application/services/unified_session_composer.dart';
import 'package:speak_master/v2/data/unified_learning_catalog.dart';
import 'package:speak_master/v2/domain/models/learner_models.dart';
import 'package:speak_master/v2/domain/models/learning_item.dart';

void main() {
  const composer = UnifiedSessionComposer();
  const learner = LearnerProfileV2(
    displayName: 'Ada',
    goal: LearningGoal.travelEnglish,
    placementLevel: PlacementLevel.starter,
    accentPreference: 'american',
    dailyMinutes: 15,
    onboardingComplete: true,
  );

  test(
    'catalog contains vocabulary, grammar and speaking in shared scenes',
    () {
      final tracks = UnifiedLearningCatalog.items
          .map((item) => item.track)
          .toSet();
      expect(
        tracks,
        containsAll([
          SkillTrack.vocabulary,
          SkillTrack.grammar,
          SkillTrack.speaking,
        ]),
      );
      expect(
        UnifiedLearningCatalog.items.any((item) => item.morphologyNote != null),
        isTrue,
      );
    },
  );

  test('due reviews come before new cards and tracks are interleaved', () {
    final now = DateTime(2026, 9, 17, 10);
    final dueVocab = UnifiedLearningCatalog.items.firstWhere(
      (item) => item.track == SkillTrack.vocabulary,
    );
    final dueGrammar = UnifiedLearningCatalog.items.firstWhere(
      (item) => item.track == SkillTrack.grammar,
    );
    final dueSpeaking = UnifiedLearningCatalog.items.firstWhere(
      (item) => item.track == SkillTrack.speaking,
    );

    final progress = UserProgress(
      userId: 'local',
      srsMemories: {
        dueVocab.id: SrsMemory(
          itemId: dueVocab.id,
          dueAt: now.subtract(const Duration(hours: 1)),
        ),
        dueGrammar.id: SrsMemory(
          itemId: dueGrammar.id,
          dueAt: now.subtract(const Duration(hours: 2)),
        ),
        dueSpeaking.id: SrsMemory(
          itemId: dueSpeaking.id,
          dueAt: now.subtract(const Duration(minutes: 20)),
        ),
      },
    );

    final plan = composer.compose(
      catalog: UnifiedLearningCatalog.items,
      progress: progress,
      learner: learner,
      now: now,
    );

    expect(plan.dueCount, 3);
    expect(plan.items.take(3).map((item) => item.id).toSet(), {
      dueVocab.id,
      dueGrammar.id,
      dueSpeaking.id,
    });
    expect(plan.items.take(3).map((item) => item.track).toSet().length, 3);
    expect(plan.newCount, greaterThan(0));
  });

  test('high due load does not pile on a large batch of new cards', () {
    final now = DateTime(2026, 9, 17, 10);
    final due = {
      for (final item in UnifiedLearningCatalog.items)
        item.id: SrsMemory(
          itemId: item.id,
          dueAt: now.subtract(const Duration(hours: 3)),
        ),
    };
    const shortLearner = LearnerProfileV2(
      displayName: 'Ada',
      goal: LearningGoal.travelEnglish,
      placementLevel: PlacementLevel.starter,
      accentPreference: 'american',
      dailyMinutes: 10,
      onboardingComplete: true,
    );
    final plan = composer.compose(
      catalog: UnifiedLearningCatalog.items,
      progress: UserProgress(userId: 'local', srsMemories: due),
      learner: shortLearner,
      now: now,
    );

    expect(plan.newCount, 0);
    expect(plan.dueCount, greaterThan(0));
  });
}
