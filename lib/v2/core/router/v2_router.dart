import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../daily/presentation/screens/learn_path_screen.dart';
import '../../../daily/presentation/screens/me_screen.dart';
import '../../../daily/presentation/screens/onboarding_flow_screen.dart';
import '../../../daily/presentation/screens/progress_journey_screen.dart';
import '../../../daily/presentation/screens/session_player_screen.dart';
import '../../../daily/presentation/screens/speak_lab_screen.dart';
import '../../../daily/presentation/screens/today_home_screen.dart';
import '../../../screens/auth/auth_screen.dart';
import '../../../services/storage_service.dart';
import '../../presentation/screens/ops_console_screen.dart';
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
        builder: (context, state) => const OnboardingFlowScreen(),
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
                const NoTransitionPage(child: TodayHomeScreen()),
          ),
          GoRoute(
            path: '/learn',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: LearnPathScreen()),
          ),
          GoRoute(
            path: '/speaking',
            pageBuilder: (context, state) => NoTransitionPage(
              child: SpeakLabScreen(
                focusPromptId: state.uri.queryParameters['prompt'],
              ),
            ),
          ),
          GoRoute(
            path: '/progress',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProgressJourneyScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: MeScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/session',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => SessionPlayerScreen(
          type: state.uri.queryParameters['type'] ?? 'lesson',
          id: state.uri.queryParameters['id'] ?? '',
          taskId: state.uri.queryParameters['task'],
        ),
      ),
      GoRoute(
        path: '/lesson/:lessonId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => SessionPlayerScreen(
          type: 'lesson',
          id: state.pathParameters['lessonId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/ops',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OpsConsoleScreen(),
      ),
    ],
  );
}
