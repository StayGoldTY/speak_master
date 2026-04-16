import 'package:flutter_test/flutter_test.dart';
import 'package:speak_master/services/pronunciation_check_engine.dart';
import 'package:speak_master/v2/application/services/local_assessment_report_builder.dart';
import 'package:speak_master/v2/application/services/speech_feedback_engine.dart';
import 'package:speak_master/v2/application/services/v2_speech_assessment_service.dart';
import 'package:speak_master/v2/domain/models/course_models.dart';
import 'package:speak_master/v2/domain/models/speech_models.dart';

void main() {
  test(
    'Speech assessment service falls back locally when cloud client is unavailable',
    () async {
      final service = V2SpeechAssessmentService(
        client: null,
        feedbackEngine: const SpeechFeedbackEngine(),
        reportBuilder: const LocalAssessmentReportBuilder(),
      );
      final prompt = SpeakingPrompt(
        id: 'assessment_pitch',
        kind: ActivityKind.assessmentTask,
        title: 'Confidence assessment',
        scenario: 'Read a sentence.',
        instruction: 'Read clearly.',
        referenceText: 'The weather is getting better.',
        focusWords: const ['weather', 'better'],
        checklist: const [],
      );
      final localResult = PronunciationCheckEngine.analyze(
        referenceText: prompt.referenceText,
        focusWords: prompt.focusWords,
        transcript: 'the weather is better',
      );

      final assessment = await service.submitAttempt(
        prompt: prompt,
        accentPreference: 'american',
        localResult: localResult,
      );

      expect(assessment.attempt.source, SpeechAttemptSource.localFallback);
      expect(assessment.attempt.feedback.weakWords, isNotEmpty);
      expect(assessment.report.overallLabel, isNotEmpty);
    },
  );
}
