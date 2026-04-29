import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_master/core/theme/app_theme.dart';
import 'package:speak_master/v2/application/services/legacy_seed_learning_repository.dart';
import 'package:speak_master/v2/presentation/screens/learn_screen.dart';
import 'package:speak_master/v2/presentation/screens/today_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('V2 product flow surfaces next actions', () {
    testWidgets('today screen highlights the next lesson and routes into it', (
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
            builder: (context, state) => const TodayScreen(),
          ),
          GoRoute(
            path: '/lesson/:lessonId',
            builder: (context, state) => Scaffold(
              body: Text('lesson:${state.pathParameters['lessonId']}'),
            ),
          ),
          GoRoute(
            path: '/speaking',
            builder: (context, state) => const Scaffold(body: Text('speaking')),
          ),
          GoRoute(
            path: '/onboarding',
            builder: (context, state) =>
                const Scaffold(body: Text('onboarding')),
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

      expect(find.text('继续主线课程'), findsOneWidget);
      expect(find.text(nextLesson.title), findsOneWidget);
      expect(
        find.text('已完成 1 / ${firstUnit.lessons.length} 节'),
        findsOneWidget,
      );

      final primaryCta = find.byKey(const ValueKey('today-primary-cta'));
      await tester.ensureVisible(primaryCta);
      await tester.tap(primaryCta);
      await tester.pumpAndSettle();

      expect(find.text('lesson:${nextLesson.id}'), findsOneWidget);
    });

    testWidgets(
      'learn screen locks future units until the current one is done',
      (tester) async {
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
              builder: (context, state) => const LearnScreen(),
            ),
            GoRoute(
              path: '/lesson/:lessonId',
              builder: (context, state) => Scaffold(
                body: Text('lesson:${state.pathParameters['lessonId']}'),
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

        expect(find.text('当前推荐'), findsOneWidget);
        expect(find.text(secondUnit.title), findsWidgets);
        expect(find.text('可开始'), findsWidgets);
        expect(find.text('待解锁'), findsWidgets);

        final lockedButton = find.byKey(ValueKey('unit-cta-${thirdUnit.id}'));
        final enabledButton = find.byKey(ValueKey('unit-cta-${secondUnit.id}'));

        expect(tester.widget<FilledButton>(lockedButton).onPressed, isNull);
        expect(tester.widget<FilledButton>(enabledButton).onPressed, isNotNull);
      },
    );
  });
}
