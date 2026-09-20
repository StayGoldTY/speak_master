import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_master/core/theme/app_theme.dart';
import 'package:speak_master/daily/presentation/screens/speak_lab_screen.dart';
import 'package:speak_master/v2/application/providers/v2_providers.dart';
import 'package:speak_master/v2/domain/models/course_models.dart';
import 'package:speak_master/v2/domain/models/speech_models.dart';

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
      rhythmCue: 'Lift the ending slightly instead of dropping every word flat.',
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

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'v2_onboarding_complete': true,
    });
  });

  testWidgets('speak lab lists scenarios and empty review state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          v2SpeakingPromptsProvider.overrideWith((ref) => prompts),
          v2FeaturedTargetsProvider.overrideWith((ref) => targets),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const SpeakLabScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('开口实验室'), findsOneWidget);
    expect(find.byKey(const ValueKey('speak-review-empty')), findsOneWidget);
    expect(find.text('Morning shadow warmup'), findsOneWidget);
    expect(find.text('Coffee order'), findsOneWidget);
    expect(find.text('/th/'), findsOneWidget);
    expect(find.textContaining('不编发音分'), findsOneWidget);
  });

  testWidgets('speak lab can highlight a prompt from the route', (tester) async {
    final router = GoRouter(
      initialLocation: '/speaking?prompt=dialog-1',
      routes: [
        GoRoute(
          path: '/speaking',
          builder: (context, state) => SpeakLabScreen(
            focusPromptId: state.uri.queryParameters['prompt'],
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          v2SpeakingPromptsProvider.overrideWith((ref) => prompts),
          v2FeaturedTargetsProvider.overrideWith((ref) => targets),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Coffee order'), findsWidgets);
    expect(find.text('从这里开始'), findsOneWidget);
  });
}
