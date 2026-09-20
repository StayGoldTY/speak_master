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
      backgroundColor: AppColors.bgLight,
      extendBody: true,
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.glassBorder),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
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
                      icon: Icon(
                        Icons.wb_sunny_outlined,
                        semanticLabel: '导航今日',
                      ),
                      selectedIcon: Icon(
                        Icons.wb_sunny_rounded,
                        semanticLabel: '导航今日',
                      ),
                      label: '今日',
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.route_outlined,
                        semanticLabel: '导航课程',
                      ),
                      selectedIcon: Icon(
                        Icons.route_rounded,
                        semanticLabel: '导航课程',
                      ),
                      label: '课程',
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.graphic_eq_outlined,
                        semanticLabel: '导航开口',
                      ),
                      selectedIcon: Icon(
                        Icons.graphic_eq_rounded,
                        semanticLabel: '导航开口',
                      ),
                      label: '开口',
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.insights_outlined,
                        semanticLabel: '导航进度',
                      ),
                      selectedIcon: Icon(
                        Icons.insights_rounded,
                        semanticLabel: '导航进度',
                      ),
                      label: '进度',
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.person_outline_rounded,
                        semanticLabel: '导航我的',
                      ),
                      selectedIcon: Icon(
                        Icons.person_rounded,
                        semanticLabel: '导航我的',
                      ),
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
