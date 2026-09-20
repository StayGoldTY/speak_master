import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_master/providers/progress_provider.dart';
import 'package:speak_master/providers/service_providers.dart';
import 'package:speak_master/v2/application/providers/v2_providers.dart';
import 'package:speak_master/v2/application/services/legacy_seed_learning_repository.dart';
import 'package:speak_master/v2/domain/models/learner_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('DailyPlan json roundtrip keeps the three task identities', () {
    const plan = DailyPlan(
      headline: '今天开口这 3 件事',
      subtitle: '约 15 分钟',
      items: [
        DailyPlanItem(
          id: 'plan_lesson',
          title: '清音与浊音的秘密',
          subtitle: '先开口',
          route: '/session?type=lesson&id=u1_L1&task=plan_lesson',
          kind: DailyPlanItemKind.lesson,
          estimatedMinutes: 8,
          xpReward: 20,
          sessionType: 'lesson',
          targetId: 'u1_L1',
        ),
        DailyPlanItem(
          id: 'plan_review',
          title: '练一组容易混的音',
          subtitle: '对比',
          route: '/session?type=sound&id=c_θ&task=plan_review',
          kind: DailyPlanItemKind.review,
          estimatedMinutes: 4,
          xpReward: 10,
          sessionType: 'sound',
          targetId: 'c_θ',
        ),
        DailyPlanItem(
          id: 'plan_transfer',
          title: '发音状态测评',
          subtitle: '整句',
          route: '/session?type=prompt&id=assessment_pitch&task=plan_transfer',
          kind: DailyPlanItemKind.assessment,
          estimatedMinutes: 3,
          xpReward: 15,
          sessionType: 'prompt',
          targetId: 'assessment_pitch',
        ),
      ],
    );

    final restored = DailyPlan.fromJson(plan.toJson());
    expect(restored.items, hasLength(3));
    expect(restored.items.first.title, plan.items.first.title);
    expect(restored.items.first.targetId, 'u1_L1');
    expect(restored.items.last.kind, DailyPlanItemKind.assessment);
  });

  test('frozen daily plan keeps the same lesson after progress advances', () async {
    SharedPreferences.setMockInitialValues({
      'v2_onboarding_complete': true,
      'v2_learning_goal': 'pronunciationConfidence',
      'v2_placement_level': 'starter',
      'v2_daily_minutes': 15,
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(storageServiceProvider).init();
    container.read(frozenDailyPlanProvider);
    await _waitForFrozenPlan(container);

    final first = container.read(v2DailyPlanProvider);
    expect(first.items, hasLength(3));
    expect(first.items.first.id, 'plan_lesson');
    expect(first.items.first.targetId, isNotEmpty);

    final liveAfterProgress = LegacySeedLearningRepository().buildDailyPlan(
      progress: container
          .read(progressProvider)
          .copyWith(
            completedLessons: {
              ...container.read(progressProvider).completedLessons,
              first.items.first.targetId,
            },
          ),
      learnerName: '学习者',
      learner: container.read(v2LearnerProfileProvider),
    );

    await container
        .read(progressProvider.notifier)
        .completeLesson(first.items.first.targetId);
    await _waitForFrozenPlan(container);

    final second = container.read(v2DailyPlanProvider);
    expect(second.items.first.title, first.items.first.title);
    expect(second.items.first.targetId, first.items.first.targetId);
    expect(second.items.first.route, first.items.first.route);
    expect(
      liveAfterProgress.items.first.targetId,
      isNot(first.items.first.targetId),
    );
  });

  test('frozen daily plan reloads from storage on a fresh container', () async {
    SharedPreferences.setMockInitialValues({
      'v2_onboarding_complete': true,
      'v2_learning_goal': 'workplaceSpeaking',
      'v2_placement_level': 'intermediate',
      'v2_daily_minutes': 20,
    });

    final firstContainer = ProviderContainer();
    addTearDown(firstContainer.dispose);
    await firstContainer.read(storageServiceProvider).init();
    firstContainer.read(frozenDailyPlanProvider);
    await _waitForFrozenPlan(firstContainer);
    final saved = firstContainer.read(v2DailyPlanProvider);

    final secondContainer = ProviderContainer();
    addTearDown(secondContainer.dispose);
    await secondContainer.read(storageServiceProvider).init();
    secondContainer.read(frozenDailyPlanProvider);
    await _waitForFrozenPlan(secondContainer);

    final restored = secondContainer.read(v2DailyPlanProvider);
    expect(restored.items.first.title, saved.items.first.title);
    expect(restored.items.last.title, saved.items.last.title);
    expect(restored.items.last.title, '会议进度汇报');
  });
}

Future<void> _waitForFrozenPlan(ProviderContainer container) async {
  for (var i = 0; i < 40; i++) {
    final frozen = container.read(frozenDailyPlanProvider);
    if (frozen != null && frozen.items.isNotEmpty) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  fail('frozen daily plan did not hydrate');
}
