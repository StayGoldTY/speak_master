import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:speak_master/core/theme/app_theme.dart';
import 'package:speak_master/v2/application/providers/v2_providers.dart';
import 'package:speak_master/v2/domain/models/course_models.dart';
import 'package:speak_master/v2/domain/models/speech_models.dart';
import 'package:speak_master/v2/presentation/screens/speaking_hub_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const prompts = <SpeakingPrompt>[
    SpeakingPrompt(
      id: 'shadow-1',
      kind: ActivityKind.shadowing,
      title: 'Morning shadow warmup',
      scenario: 'Use one short line to wake up your mouth and rhythm.',
      instruction: 'Echo the line and keep the ending lifted instead of flat.',
      referenceText: 'Today I will speak clearly and confidently.',
      focusWords: ['today', 'clearly', 'confidently'],
      checklist: ['Go slow first.', 'Land the key words.'],
      warmupWords: ['today', 'clearly'],
      phraseDrills: ['speak clearly', 'clearly and confidently'],
      sentenceVariations: [
        'Today I will speak slowly and clearly.',
        'Today I will sound calm and confident.',
      ],
      rhythmCue:
          'Lift the ending slightly instead of dropping every word flat.',
      extensionPrompt: 'Swap one adjective and repeat the sentence.',
    ),
    SpeakingPrompt(
      id: 'dialog-1',
      kind: ActivityKind.dialogRoleplay,
      title: 'Coffee order',
      scenario: 'Practice placing a short order with one clean breath group.',
      instruction: 'Say the order first, then change one detail and repeat it.',
      referenceText: 'Could I get a latte with oat milk?',
      focusWords: ['latte', 'oat', 'milk'],
      checklist: ['Do not swallow the sentence ending.'],
      warmupWords: ['latte', 'oat milk'],
      phraseDrills: ['Could I get a latte', 'with oat milk'],
      sentenceVariations: [
        'Could I get a hot latte with oat milk?',
        'Could I get a small latte with oat milk?',
      ],
      rhythmCue: 'Let the request flow first, then land the drink details.',
      extensionPrompt: 'Add size or temperature and say it again.',
    ),
    SpeakingPrompt(
      id: 'assessment-1',
      kind: ActivityKind.assessmentTask,
      title: 'TH check',
      scenario: 'Check whether the th sounds still collapse under speed.',
      instruction: 'Read the whole sentence once slowly and once naturally.',
      referenceText: 'Three thin thinkers thought thoughtful thoughts.',
      focusWords: ['three', 'thin', 'thoughts'],
      checklist: ['Keep the th sounds visible.'],
      warmupWords: ['three', 'thin', 'thoughts'],
      phraseDrills: ['three thin thinkers', 'thought thoughtful thoughts'],
      sentenceVariations: ['Those thinkers thought three thoughtful things.'],
      rhythmCue: 'Do not rush the th sounds just to finish the line.',
      extensionPrompt: 'Say it once slowly and once at natural speed.',
    ),
  ];

  const targets = <PronunciationTarget>[
    PronunciationTarget(
      id: 'th',
      symbol: '/th/',
      title: 'TH',
      subtitle: 'Avoid collapsing it into s or z',
      examples: ['think', 'three', 'thanks'],
      mouthPosition: 'Put the tongue lightly between the teeth.',
      correctionTip: 'Send air out gently instead of tightening the jaw.',
    ),
  ];

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        v2SpeakingPromptsProvider.overrideWith((ref) => prompts),
        v2FeaturedTargetsProvider.overrideWith((ref) => targets),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const SpeakingHubScreen(),
      ),
    );
  }

  Widget buildRoutedApp(String location) {
    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: '/speaking',
          builder: (context, state) => SpeakingHubScreen(
            focusPromptId: state.uri.queryParameters['prompt'],
          ),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        v2SpeakingPromptsProvider.overrideWith((ref) => prompts),
        v2FeaturedTargetsProvider.overrideWith((ref) => targets),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  group('SpeakingHubScreen', () {
    testWidgets('surfaces a recommended practice card above the prompt list', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Morning shadow warmup'), findsWidgets);
      expect(
        find.byKey(const ValueKey('speaking-quick-start')),
        findsOneWidget,
      );
    });

    testWidgets('filters prompt cards by selected practice mode', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Morning shadow warmup'), findsWidgets);
      expect(find.text('Coffee order'), findsWidgets);
      expect(find.text('TH check'), findsWidgets);

      final dialogFilter = find.byKey(const ValueKey('speaking-filter-情景对话'));
      await tester.ensureVisible(dialogFilter);
      await tester.tap(dialogFilter);
      await tester.pumpAndSettle();

      expect(find.text('Coffee order'), findsWidgets);
      expect(find.text('TH check'), findsNothing);
      expect(find.text('Morning shadow warmup'), findsNothing);
      expect(find.text('共 1 个训练'), findsOneWidget);
    });

    testWidgets(
      'shows layered pronunciation drills instead of only a single reference sentence',
      (tester) async {
        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        expect(find.text('先拆开练'), findsWidgets);
        expect(find.text('五步发音路线'), findsWidgets);
        expect(find.text('先听辨'), findsWidgets);
        expect(find.text('再单练'), findsWidgets);
        expect(find.text('短语连读'), findsWidgets);
        expect(find.text('短语连读'), findsWidgets);
        expect(find.text('自然变体开口'), findsWidgets);
        expect(find.text('today'), findsWidgets);
        expect(find.text('speak clearly'), findsOneWidget);
        expect(
          find.text('Today I will speak slowly and clearly.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'focuses a prompt from the route and quick-start highlights it',
      (tester) async {
        await tester.pumpWidget(buildRoutedApp('/speaking?prompt=dialog-1'));
        await tester.pumpAndSettle();

        expect(find.text('Coffee order'), findsWidgets);
        expect(
          find.byKey(const ValueKey('speaking-prompt-focused-dialog-1')),
          findsOneWidget,
        );

        final quickStart = find.byKey(const ValueKey('speaking-quick-start'));
        await tester.ensureVisible(quickStart);
        await tester.tap(quickStart);
        await tester.pumpAndSettle();

        expect(find.text('共 1 个训练'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('speaking-prompt-focused-dialog-1')),
          findsOneWidget,
        );
      },
    );
  });
}
