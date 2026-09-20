import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_master/core/theme/app_theme.dart';
import 'package:speak_master/daily/presentation/screens/learn_path_screen.dart';
import 'package:speak_master/daily/presentation/screens/today_home_screen.dart';
import 'package:speak_master/v2/application/services/legacy_seed_learning_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Daily product flow', () {
    testWidgets('today shows three tasks and starts the next session', (
      tester,
    ) async {
      final repository = LegacySeedLearningRepository();
      final firstUnit = repository.getPrimaryTrack().units.first;
      final firstLesson = firstUnit.lessons.first;
      final nextLesson = firstUnit.lessons[1];

      SharedPreferences.setMockInitialValues({
        'completed_lessons': [firstLesson.id],
        'v2_onboarding_complete': true,
        'v2_learning_goal': 'pronunciationConfidence',
        'v2_placement_level': 'starter',
        'v2_daily_minutes': 15,
      });

      final router = GoRouter(
        initialLocation: '/today',
        routes: [
          GoRoute(
            path: '/today',
            builder: (context, state) => const TodayHomeScreen(),
          ),
          GoRoute(
            path: '/session',
            builder: (context, state) => Scaffold(
              body: Text(
                'session:${state.uri.queryParameters['type']}:${state.uri.queryParameters['id']}',
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('今天这 3 件事'), findsOneWidget);
      expect(find.text(nextLesson.title), findsWidgets);
      expect(find.byKey(const ValueKey('today-task-plan_lesson')), findsOneWidget);
      expect(find.byKey(const ValueKey('today-task-plan_review')), findsOneWidget);
      expect(find.byKey(const ValueKey('today-task-plan_transfer')), findsOneWidget);

      final primaryCta = find.byKey(const ValueKey('today-primary-cta'));
      await tester.ensureVisible(primaryCta);
      await tester.tap(primaryCta);
      await tester.pumpAndSettle();

      expect(find.text('session:lesson:${nextLesson.id}'), findsOneWidget);
    });

    testWidgets('learn path locks later units until the current one is done', (
      tester,
    ) async {
      final repository = LegacySeedLearningRepository();
      final track = repository.getPrimaryTrack();
      final firstUnit = track.units.first;
      final secondUnit = track.units[1];
      final thirdUnit = track.units[2];

      SharedPreferences.setMockInitialValues({
        'completed_lessons': firstUnit.lessons
            .map((lesson) => lesson.id)
            .toList(),
        'completed_units': [firstUnit.id],
      });

      final router = GoRouter(
        initialLocation: '/learn',
        routes: [
          GoRoute(
            path: '/learn',
            builder: (context, state) => const LearnPathScreen(),
          ),
          GoRoute(
            path: '/session',
            builder: (context, state) => Scaffold(
              body: Text('session:${state.uri.queryParameters['id']}'),
            ),
          ),
          GoRoute(
            path: '/speaking',
            builder: (context, state) => const Scaffold(body: Text('speaking')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('现在学这个'), findsOneWidget);
      expect(find.text(secondUnit.title), findsWidgets);
      expect(find.text('可开始'), findsWidgets);
      expect(find.text('待解锁'), findsWidgets);

      final lockedButton = find.byKey(ValueKey('unit-cta-${thirdUnit.id}'));
      final enabledButton = find.byKey(ValueKey('unit-cta-${secondUnit.id}'));

      expect(tester.widget<FilledButton>(lockedButton).onPressed, isNull);
      expect(tester.widget<FilledButton>(enabledButton).onPressed, isNotNull);
    });

    testWidgets('today celebrates when all three tasks are already done', (
      tester,
    ) async {
      final now = DateTime.now();
      final month = now.month.toString().padLeft(2, '0');
      final day = now.day.toString().padLeft(2, '0');
      SharedPreferences.setMockInitialValues({
        'v2_onboarding_complete': true,
        'daily_loop_date': '${now.year}-$month-$day',
        'daily_completed_task_ids': [
          'plan_lesson',
          'plan_review',
          'plan_transfer',
        ],
        'streak_days': 3,
      });

      final router = GoRouter(
        initialLocation: '/today',
        routes: [
          GoRoute(
            path: '/today',
            builder: (context, state) => const TodayHomeScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('today-goal-complete')), findsOneWidget);
      expect(find.text('今日目标完成'), findsOneWidget);
    });
  });
}
