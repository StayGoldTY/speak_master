import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../screens/auth/auth_screen.dart';
import '../../../services/storage_service.dart';
import '../../presentation/screens/learn_screen.dart';
import '../../presentation/screens/lesson_player_screen.dart';
import '../../presentation/screens/onboarding_screen.dart';
import '../../presentation/screens/ops_console_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/progress_screen.dart';
import '../../presentation/screens/speaking_hub_screen.dart';
import '../../presentation/screens/today_screen.dart';
import '../../presentation/widgets/v2_shell_scaffold.dart';

class V2Router {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: StorageService().loadV2OnboardingComplete()
        ? '/today'
        : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            AuthScreen(redirectTo: state.uri.queryParameters['from']),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => V2ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/today',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TodayScreen()),
          ),
          GoRoute(
            path: '/learn',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: LearnScreen()),
          ),
          GoRoute(
            path: '/speaking',
            pageBuilder: (context, state) => NoTransitionPage(
              child: SpeakingHubScreen(
                focusPromptId: state.uri.queryParameters['prompt'],
              ),
            ),
          ),
          GoRoute(
            path: '/progress',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProgressScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreenV2()),
          ),
        ],
      ),
      GoRoute(
        path: '/lesson/:lessonId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            LessonPlayerScreen(lessonId: state.pathParameters['lessonId']!),
      ),
      GoRoute(
        path: '/ops',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OpsConsoleScreen(),
      ),
    ],
  );
}
