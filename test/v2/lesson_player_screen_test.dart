import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_master/core/theme/app_theme.dart';
import 'package:speak_master/daily/presentation/screens/session_player_screen.dart';
import 'package:speak_master/v2/application/services/legacy_seed_learning_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'session player can finish a lesson without fake scores and persist progress',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'v2_onboarding_complete': true,
      });
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(430, 932));

      final repository = LegacySeedLearningRepository();
      final lesson = repository.getLessonById('u1_L1')!;

      final router = GoRouter(
        initialLocation: '/session?type=lesson&id=${lesson.id}&task=plan_lesson',
        routes: [
          GoRoute(
            path: '/session',
            builder: (context, state) => SessionPlayerScreen(
              type: state.uri.queryParameters['type'] ?? 'lesson',
              id: state.uri.queryParameters['id'] ?? '',
              taskId: state.uri.queryParameters['task'],
            ),
          ),
          GoRoute(
            path: '/today',
            builder: (context, state) => const Scaffold(body: Text('today')),
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

      expect(find.text(lesson.activities.first.instruction), findsWidgets);

      await tester.tap(find.byKey(const ValueKey('session-continue')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('session-continue')));
      await tester.pumpAndSettle();

      final finishFinder = find.byKey(const ValueKey('session-finish'));
      expect(tester.widget<FilledButton>(finishFinder).onPressed, isNull);

      await tester.tap(find.byKey(const ValueKey('mc-option-opt_1')));
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(finishFinder).onPressed, isNotNull);

      await tester.tap(finishFinder);
      await tester.pumpAndSettle();

      expect(find.text('这节完成了'), findsOneWidget);
      expect(find.textContaining('不会出现发音总分'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getStringList('completed_lessons') ?? const <String>[],
        contains(lesson.id),
      );
      expect(
        prefs.getStringList('daily_completed_task_ids') ?? const <String>[],
        contains('plan_lesson'),
      );
    },
  );
}
