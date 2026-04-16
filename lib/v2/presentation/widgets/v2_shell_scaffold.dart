import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

class V2ShellScaffold extends StatelessWidget {
  final Widget child;

  const V2ShellScaffold({super.key, required this.child});

  static int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/today')) return 0;
    if (location.startsWith('/learn')) return 1;
    if (location.startsWith('/speaking')) return 2;
    if (location.startsWith('/progress')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  static void _goTo(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/today');
        break;
      case 1:
        context.go('/learn');
        break;
      case 2:
        context.go('/speaking');
        break;
      case 3:
        context.go('/progress');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.glassBorder.withValues(alpha: 0.7),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: NavigationBar(
                  selectedIndex: _selectedIndex(context),
                  onDestinationSelected: (index) => _goTo(context, index),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.today_outlined),
                      selectedIcon: Icon(Icons.today),
                      label: '今日',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.school_outlined),
                      selectedIcon: Icon(Icons.school),
                      label: '课程',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.multitrack_audio_outlined),
                      selectedIcon: Icon(Icons.multitrack_audio),
                      label: '口语',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.auto_graph_outlined),
                      selectedIcon: Icon(Icons.auto_graph),
                      label: '进度',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: '我的',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
