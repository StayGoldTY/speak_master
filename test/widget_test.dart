import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_master/core/theme/app_theme.dart';
import 'package:speak_master/data/lessons_data.dart';
import 'package:speak_master/data/phonemes_data.dart';
import 'package:speak_master/data/units_data.dart';
import 'package:speak_master/models/lesson.dart';
import 'package:speak_master/screens/auth/auth_screen.dart';
import 'package:speak_master/screens/assessment/assessment_screen.dart';
import 'package:speak_master/screens/practice/practice_screen.dart';
import 'package:speak_master/screens/tutorial/lesson_screen.dart';
import 'package:speak_master/screens/tutorial/tutorial_map_screen.dart';
import 'package:speak_master/screens/tutorial/unit_detail_screen.dart';
import 'package:speak_master/services/pronunciation_check_engine.dart';
import 'package:speak_master/widgets/phoneme_card.dart';
import 'package:speak_master/widgets/record_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('u1-u10 的教程数据完整、题目元数据合法，targetPhonemes 能映射到音位数据', () {
    const phaseOneUnitIds = [
      'u1',
      'u2',
      'u3',
      'u4',
      'u5',
      'u6',
      'u7',
      'u8',
      'u9',
      'u10',
    ];
    final phonemeIds = PhonemesData.allPhonemes
        .map((phoneme) => phoneme.id)
        .toSet();

    for (final unit in UnitsData.units) {
      for (final targetPhoneme in unit.targetPhonemes) {
        expect(
          phonemeIds.contains(targetPhoneme),
          isTrue,
          reason: '${unit.id} -> $targetPhoneme 不存在于音位数据中',
        );
      }
    }

    for (final unitId in phaseOneUnitIds) {
      expect(LessonsData.hasAuthoredLessons(unitId), isTrue);
      expect(LessonsData.isReleasedUnit(unitId), isTrue);

      final lessons = LessonsData.getLessonsForUnit(unitId);
      expect(lessons, hasLength(3));

      for (final lesson in lessons) {
        expect(lesson.titleCn, isNotEmpty);
        expect(lesson.description, isNotEmpty);
        expect(lesson.steps, isNotEmpty);
        expect(LessonsData.getLessonById(lesson.id)?.id, lesson.id);

        for (final step in lesson.steps) {
          if (step.type == StepType.multipleChoice) {
            final options =
                (step.metadata?['options'] as List<dynamic>? ?? const []);
            final correct = step.metadata?['correct'] as int?;

            expect(options, isNotEmpty);
            expect(correct, isNotNull);
            expect(correct, inInclusiveRange(0, options.length - 1));
          }

          if (step.type == StepType.minimalPairQuiz) {
            final pairs = step.metadata?['pairs'] as List<dynamic>? ?? const [];

            expect(pairs, isNotEmpty);
            for (final pair in pairs.cast<Map<dynamic, dynamic>>()) {
              expect(pair['word1'], isNotNull);
              expect(pair['word2'], isNotNull);
              expect(pair['phoneme1'], isNotNull);
              expect(pair['phoneme2'], isNotNull);
            }
          }
        }
      }
    }

    expect(LessonsData.isReleasedUnit('u12'), isFalse);
    expect(LessonsData.hasAuthoredLessons('u12'), isTrue);
    expect(LessonsData.getAuthoredLessonCount('u10'), 3);
  });

  test('发音检查引擎会提取可跟读脚本并返回缺失重点词', () {
    const step = LessonStep(
      id: 'demo_step',
      type: StepType.recordAndCompare,
      instruction: '说：最小对立体跟读',
      metadata: {
        'pairs': ['fan|van', 'sip|zip', 'ten|den'],
      },
    );

    final referenceText = PronunciationCheckEngine.buildReferenceText(step);
    final result = PronunciationCheckEngine.analyze(
      step: step,
      transcript: 'fan zip',
    );

    expect(referenceText, contains('fan'));
    expect(referenceText, contains('van'));
    expect(result.matchedFocusWords, contains('fan'));
    expect(result.matchedFocusWords, contains('zip'));
    expect(result.missingFocusWords, contains('van'));
    expect(result.transcript, 'fan zip');
  });

  testWidgets('教程地图允许进入已开放单元，并把后续单元标记为即将开放', (tester) async {
    await _pumpRouter(
      tester,
      initialLocation: '/learn',
      size: const Size(390, 844),
      routes: [
        GoRoute(
          path: '/learn',
          builder: (context, state) => const TutorialMapScreen(),
        ),
        GoRoute(
          path: '/unit/:unitId',
          builder: (context, state) =>
              UnitDetailScreen(unitId: state.pathParameters['unitId']!),
        ),
      ],
    );

    expect(find.byType(TutorialMapScreen), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('unit-tile-u1')),
      240,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('status-u1')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('unit-tile-u1')));
    await tester.pumpAndSettle();

    expect(find.byType(UnitDetailScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('lesson-tile-u1_L1')), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('unit-tile-u11')),
      300,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('status-u11')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('unit-tile-u11')));
    await tester.pumpAndSettle();

    expect(find.byType(UnitDetailScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('upcoming-roadmap-u11')), findsOneWidget);
  });

  testWidgets('已开放单元详情页显示目标音位和真实课程列表', (tester) async {
    await _pumpRouter(
      tester,
      initialLocation: '/unit/u7',
      size: const Size(1440, 900),
      routes: [
        GoRoute(
          path: '/unit/:unitId',
          builder: (context, state) =>
              UnitDetailScreen(unitId: state.pathParameters['unitId']!),
        ),
      ],
    );

    expect(find.byType(UnitDetailScreen), findsOneWidget);
    expect(find.text('目标音位'), findsOneWidget);
    expect(find.byType(PhonemeCard), findsNWidgets(5));
    expect(find.byKey(const ValueKey('lesson-tile-u7_L1')), findsOneWidget);
    expect(find.byKey(const ValueKey('lesson-tile-u7_L2')), findsOneWidget);
  });

  testWidgets('课程页可以按步骤渲染 recordAndCompare 和 minimalPairQuiz', (tester) async {
    await _pumpRouter(
      tester,
      initialLocation: '/lesson/u3_L2',
      size: const Size(390, 844),
      routes: [
        GoRoute(
          path: '/lesson/:lessonId',
          builder: (context, state) =>
              LessonScreen(lessonId: state.pathParameters['lessonId']!),
        ),
      ],
    );

    expect(find.byType(LessonScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('lesson-sidebar')), findsOneWidget);

    await tester.tap(find.text('下一步'));
    await tester.pumpAndSettle();
    expect(find.byType(RecordButton), findsOneWidget);

    await tester.tap(find.text('下一步'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('pair-u3_L2_s3-ship-sheep')),
      findsOneWidget,
    );
  });

  testWidgets('课程页可以渲染 multipleChoice 并显示解释', (tester) async {
    await _pumpRouter(
      tester,
      initialLocation: '/lesson/u2_L1',
      size: const Size(1440, 900),
      routes: [
        GoRoute(
          path: '/lesson/:lessonId',
          builder: (context, state) =>
              LessonScreen(lessonId: state.pathParameters['lessonId']!),
        ),
      ],
    );

    await tester.tap(find.text('下一步'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('下一步'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const ValueKey('mc-option-u2_L1_s3-1')),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('mc-option-u2_L1_s3-1')),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('mc-explanation-u2_L1_s3')),
      findsOneWidget,
    );
  });

  testWidgets('auth 页面在本地模式下会保留来源页返回能力', (tester) async {
    await _pumpRouter(
      tester,
      initialLocation: '/auth?from=%2Fprofile',
      size: const Size(390, 844),
      routes: [
        GoRoute(
          path: '/auth',
          builder: (context, state) =>
              AuthScreen(redirectTo: state.uri.queryParameters['from']),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const _RouteMarker(label: 'profile'),
        ),
      ],
    );

    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.text('当前是本地体验模式'), findsOneWidget);
    expect(find.text('登录后会回到刚才的页面'), findsOneWidget);

    await tester.tap(find.text('先返回上一页'));
    await tester.pumpAndSettle();

    expect(find.text('route:profile'), findsOneWidget);
  });

  testWidgets('practice 页面会为自由朗读和跟读材料提供标准发音脚本', (tester) async {
    await _pumpRouter(
      tester,
      initialLocation: '/practice',
      size: const Size(1440, 900),
      routes: [
        GoRoute(
          path: '/practice',
          builder: (context, state) => const PracticeScreen(),
        ),
      ],
    );

    expect(find.byType(PracticeScreen), findsOneWidget);
    expect(
      find.byKey(const ValueKey('speech-reference-practice_free_0')),
      findsOneWidget,
    );

    await tester.tap(find.text('跟读参考'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('speech-reference-practice_follow_0')),
      findsOneWidget,
    );
  });

  testWidgets('assessment 页面会渲染标准发音和识别检查入口', (tester) async {
    await _pumpRouter(
      tester,
      initialLocation: '/assessment',
      size: const Size(390, 844),
      routes: [
        GoRoute(
          path: '/assessment',
          builder: (context, state) => const AssessmentScreen(),
        ),
        GoRoute(
          path: '/practice',
          builder: (context, state) => const PracticeScreen(),
        ),
      ],
    );

    expect(find.byType(AssessmentScreen), findsOneWidget);
    expect(find.text('这里是识别检查 + 引导式自评'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('speech-reference-assessment_assessment_1')),
      findsOneWidget,
    );
  });

  testWidgets('教程主链页面在手机和桌面宽度下都能渲染', (tester) async {
    final scenarios = <({String route, Size size, List<RouteBase> routes})>[
      (
        route: '/learn',
        size: const Size(390, 844),
        routes: [
          GoRoute(
            path: '/learn',
            builder: (context, state) => const TutorialMapScreen(),
          ),
        ],
      ),
      (
        route: '/learn',
        size: const Size(1440, 900),
        routes: [
          GoRoute(
            path: '/learn',
            builder: (context, state) => const TutorialMapScreen(),
          ),
        ],
      ),
      (
        route: '/unit/u5',
        size: const Size(390, 844),
        routes: [
          GoRoute(
            path: '/unit/:unitId',
            builder: (context, state) =>
                UnitDetailScreen(unitId: state.pathParameters['unitId']!),
          ),
        ],
      ),
      (
        route: '/unit/u5',
        size: const Size(1440, 900),
        routes: [
          GoRoute(
            path: '/unit/:unitId',
            builder: (context, state) =>
                UnitDetailScreen(unitId: state.pathParameters['unitId']!),
          ),
        ],
      ),
      (
        route: '/lesson/u2_L1',
        size: const Size(390, 844),
        routes: [
          GoRoute(
            path: '/lesson/:lessonId',
            builder: (context, state) =>
                LessonScreen(lessonId: state.pathParameters['lessonId']!),
          ),
        ],
      ),
      (
        route: '/lesson/u2_L1',
        size: const Size(1440, 900),
        routes: [
          GoRoute(
            path: '/lesson/:lessonId',
            builder: (context, state) =>
                LessonScreen(lessonId: state.pathParameters['lessonId']!),
          ),
        ],
      ),
    ];

    for (final scenario in scenarios) {
      await _pumpRouter(
        tester,
        initialLocation: scenario.route,
        size: scenario.size,
        routes: scenario.routes,
      );

      expect(tester.takeException(), isNull);
    }
  });
}

Future<void> _pumpRouter(
  WidgetTester tester, {
  required String initialLocation,
  required Size size,
  required List<RouteBase> routes,
}) async {
  SharedPreferences.setMockInitialValues({});
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(size);

  final router = GoRouter(initialLocation: initialLocation, routes: routes);

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
        builder: (context, child) =>
            Material(child: child ?? const SizedBox.shrink()),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

class _RouteMarker extends StatelessWidget {
  final String label;

  const _RouteMarker({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('route:$label')));
  }
}
