import 'package:flutter_test/flutter_test.dart';
import 'package:speak_master/services/pronunciation_check_engine.dart';
import 'package:speak_master/v2/application/services/speech_feedback_engine.dart';
import 'package:speak_master/v2/domain/models/course_models.dart';
import 'package:speak_master/v2/domain/models/speech_models.dart';

void main() {
  test(
    'Speech feedback engine adds prompt-specific drill guidance instead of generic output',
    () {
      const engine = SpeechFeedbackEngine();
      const prompt = SpeakingPrompt(
        id: 'cafe-order',
        kind: ActivityKind.shadowing,
        title: 'Cafe order shadowing',
        scenario: 'Turn the sentence into one natural request.',
        instruction:
            'Keep the opening light, then land the drink words clearly.',
        referenceText: 'Can I get a large latte please',
        focusWords: ['large', 'latte', 'please'],
        checklist: ['Keep "Can I get a" light.', 'Land "latte" clearly.'],
        warmupWords: ['large', 'latte', 'please'],
        phraseDrills: ['Can I get a', 'large latte', 'latte please'],
        sentenceVariations: [
          'Can I get a small latte please',
          'Can I get an oat latte please',
        ],
        rhythmCue: 'Keep the request as one breath group, then land the drink.',
        extensionPrompt: 'Change one detail and say the order again.',
      );
      final check = PronunciationCheckEngine.analyze(
        referenceText: prompt.referenceText,
        focusWords: prompt.focusWords,
        transcript: 'can i get a latte',
      );

      final feedback = engine.build(
        result: check,
        prompt: prompt,
        fallbackUsed: true,
      );

      expect(feedback.recognizedText, 'can i get a latte');
      expect(feedback.fallbackUsed, isTrue);
      expect(feedback.weakWords, contains('please'));
      expect(feedback.retrySuggestions, isNotEmpty);
      expect(feedback.fluencyBand, isA<FluencyBand>());
      expect(feedback.paceBand, isA<PaceBand>());
      expect(
        feedback.teacherExplanation,
        contains('Keep the request as one breath group'),
      );
      expect(feedback.retrySuggestions.join(' '), contains('large latte'));
      expect(feedback.stressHints.join(' '), contains('Can I get a'));
    },
  );
}
