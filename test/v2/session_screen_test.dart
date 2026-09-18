import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_master/core/theme/app_theme.dart';
import 'package:speak_master/v2/presentation/screens/session_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'session asks for retrieval first then shows the next review time',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'v2_onboarding_complete': true,
        'v2_learning_goal': 'pronunciationConfidence',
        'v2_placement_level': 'starter',
        'v2_daily_minutes': 15,
      });
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(430, 932));

      final router = GoRouter(
        initialLocation: '/session',
        routes: [
          GoRoute(
            path: '/session',
            builder: (context, state) => const SessionScreen(),
          ),
          GoRoute(
            path: '/today',
            builder: (context, state) => const Scaffold(body: Text('today')),
          ),
          GoRoute(
            path: '/progress',
            builder: (context, state) => const Scaffold(body: Text('progress')),
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

      expect(find.text('今日学习循环'), findsWidgets);
      expect(find.byKey(const ValueKey('session-cue')), findsOneWidget);
      expect(find.byKey(const ValueKey('session-target')), findsNothing);

      final reveal = find.byKey(const ValueKey('session-reveal-button'));
      await tester.ensureVisible(reveal);
      await tester.tap(reveal);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('session-target')), findsOneWidget);
      expect(find.textContaining('明天'), findsWidgets);

      final good = find.byKey(const ValueKey('session-grade-good'));
      await tester.ensureVisible(good);
      await tester.tap(good);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('session-cue')), findsOneWidget);
    },
  );
}
