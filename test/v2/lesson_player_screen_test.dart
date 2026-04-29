import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_master/core/theme/app_theme.dart';
import 'package:speak_master/v2/application/services/legacy_seed_learning_repository.dart';
import 'package:speak_master/v2/presentation/screens/lesson_player_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'lesson player unlocks completion and persists progress after all activities are done',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(430, 932));

      final repository = LegacySeedLearningRepository();
      final lesson = repository.getLessonById('u1_L1')!;

      final router = GoRouter(
        initialLocation: '/lesson/${lesson.id}',
        routes: [
          GoRoute(
            path: '/lesson/:lessonId',
            builder: (context, state) =>
                LessonPlayerScreen(lessonId: state.pathParameters['lessonId']!),
          ),
          GoRoute(
            path: '/learn',
            builder: (context, state) =>
                const Scaffold(body: Text('learn-map')),
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

      final finishButtonFinder = find.byKey(
        const ValueKey('finish-lesson-button'),
      );
      FilledButton finishButton = tester.widget<FilledButton>(
        finishButtonFinder,
      );
      expect(finishButton.onPressed, isNull);

      for (final activity in lesson.activities) {
        final activityButton = find.byKey(
          ValueKey('complete-activity-${activity.id}'),
        );
        await tester.ensureVisible(activityButton);
        await tester.tap(activityButton);
        await tester.pumpAndSettle();
      }

      finishButton = tester.widget<FilledButton>(finishButtonFinder);
      expect(finishButton.onPressed, isNotNull);

      await tester.ensureVisible(finishButtonFinder);
      await tester.tap(finishButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text('本课已完成'), findsWidgets);
      expect(find.byKey(const ValueKey('next-lesson-button')), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getStringList('completed_lessons') ?? const <String>[],
        contains(lesson.id),
      );
      expect(prefs.getInt('total_xp'), 10);
    },
  );
}
