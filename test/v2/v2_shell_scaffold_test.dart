import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_master/core/theme/app_theme.dart';
import 'package:speak_master/v2/presentation/widgets/v2_page_scaffold.dart';
import 'package:speak_master/v2/presentation/widgets/v2_shell_scaffold.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('V2 shell keeps page content visible above the bottom nav', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(390, 844));

    final router = GoRouter(
      initialLocation: '/today',
      routes: [
        ShellRoute(
          builder: (context, state, child) => V2ShellScaffold(child: child),
          routes: [
            GoRoute(
              path: '/today',
              builder: (context, state) => const V2PageScaffold(
                title: '今日学习',
                subtitle: '验证 Shell 布局不会把内容区挤空。',
                child: Text('shell-body'),
              ),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    final bodyFinder = find.text('shell-body');
    final navFinder = find.byType(NavigationBar);

    expect(bodyFinder, findsOneWidget);
    expect(navFinder, findsOneWidget);

    final bodyRect = tester.getRect(bodyFinder);
    final navRect = tester.getRect(navFinder);

    expect(bodyRect.height, greaterThan(0));
    expect(bodyRect.top, lessThan(navRect.top));
  });
}
