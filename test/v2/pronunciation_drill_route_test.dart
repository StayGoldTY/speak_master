import 'package:flutter_test/flutter_test.dart';
import 'package:speak_master/v2/application/services/pronunciation_drill_route_builder.dart';
import 'package:speak_master/v2/domain/models/course_models.dart';
import 'package:speak_master/v2/domain/models/speech_models.dart';

void main() {
  test(
    'builds a complete listening-to-transfer route for speaking prompts',
    () {
      const prompt = SpeakingPrompt(
        id: 'cafe',
        kind: ActivityKind.shadowing,
        title: 'Cafe order',
        scenario: 'Order a drink naturally.',
        instruction: 'Keep the opening light.',
        referenceText: 'Can I get a large latte please',
        focusWords: ['large', 'latte', 'please'],
        checklist: ['Keep the opening light.'],
        warmupWords: ['large', 'latte', 'please'],
        phraseDrills: ['Can I get a', 'large latte'],
        sentenceVariations: ['Can I get a small latte please'],
        rhythmCue: 'Keep the request as one breath group.',
        extensionPrompt: 'Change one detail and repeat.',
      );

      final route = PronunciationDrillRouteBuilder.build(prompt);

      expect(route, hasLength(5));
      expect(route.map((stage) => stage.kind), [
        PronunciationDrillStageKind.listen,
        PronunciationDrillStageKind.word,
        PronunciationDrillStageKind.phrase,
        PronunciationDrillStageKind.sentence,
        PronunciationDrillStageKind.transfer,
      ]);
      expect(route.first.title, '先听辨');
      expect(route[1].items, ['large', 'latte', 'please']);
      expect(route[4].items, contains('Can I get a small latte please'));
    },
  );
}
