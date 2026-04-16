import 'package:flutter_test/flutter_test.dart';
import 'package:speak_master/services/pronunciation_check_engine.dart';
import 'package:speak_master/v2/application/services/speech_feedback_engine.dart';
import 'package:speak_master/v2/domain/models/speech_models.dart';

void main() {
  test('Speech feedback engine converts transcript checks into structured feedback', () {
    const engine = SpeechFeedbackEngine();
    final check = PronunciationCheckEngine.analyze(
      referenceText: 'Can I get a large latte please',
      focusWords: const ['large', 'latte', 'please'],
      transcript: 'can i get a latte',
    );

    final feedback = engine.build(
      result: check,
      focusWords: const ['large', 'latte', 'please'],
      fallbackUsed: true,
    );

    expect(feedback.recognizedText, 'can i get a latte');
    expect(feedback.fallbackUsed, isTrue);
    expect(feedback.weakWords, contains('please'));
    expect(feedback.retrySuggestions, isNotEmpty);
    expect(feedback.fluencyBand, isA<FluencyBand>());
    expect(feedback.paceBand, isA<PaceBand>());
  });
}
