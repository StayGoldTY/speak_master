import 'package:flutter_test/flutter_test.dart';
import 'package:speak_master/daily/application/session_composer.dart';
import 'package:speak_master/daily/domain/session_models.dart';
import 'package:speak_master/v2/application/services/legacy_seed_learning_repository.dart';

void main() {
  const composer = SessionComposer();
  final repository = LegacySeedLearningRepository();

  test('lesson sessions keep one-step-at-a-time activities', () {
    final lesson = repository.getLessonById('u1_L1')!;
    final session = composer.fromLesson(lesson: lesson);

    expect(session.kind, SessionKind.lesson);
    expect(session.steps, isNotEmpty);
    expect(session.steps.first.kind, SessionStepKind.tip);
    expect(session.steps.last.kind, SessionStepKind.multipleChoice);
  });

  test('prompt sessions start with words before the full line', () {
    final prompt = repository.getSpeakingPrompts().first;
    final session = composer.fromPrompt(prompt: prompt);

    expect(session.steps.length, greaterThanOrEqualTo(2));
    expect(session.steps.first.kind, SessionStepKind.listenSpeak);
    expect(session.steps.last.prompt, prompt.referenceText);
  });
}
