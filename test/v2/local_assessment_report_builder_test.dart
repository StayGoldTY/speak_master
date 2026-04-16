import 'package:flutter_test/flutter_test.dart';
import 'package:speak_master/v2/application/services/local_assessment_report_builder.dart';
import 'package:speak_master/v2/domain/models/speech_models.dart';

void main() {
  test('Local assessment report builder creates a report and review items', () {
    const builder = LocalAssessmentReportBuilder();
    final feedback = SpeechFeedback(
      recognizedText: 'can i get a latte',
      coverageScore: 0.64,
      fluencyBand: FluencyBand.steady,
      paceBand: PaceBand.balanced,
      stressHints: const ['Lean on latte.'],
      weakWords: const ['please'],
      retrySuggestions: const ['Retry with extra clarity on please.'],
      teacherExplanation: 'Coverage is 64%. Focus next on please.',
      fallbackUsed: true,
      weakPointTags: const [
        WeakPointTag(
          label: 'please',
          type: WeakPointTagType.word,
          reason: 'This word was not stable.',
        ),
      ],
      generatedAt: DateTime(2026, 4, 16, 10, 0),
    );

    final report = builder.build(
      feedback: feedback,
      recommendedRoute: '/speaking',
    );
    final reviewItems = builder.buildReviewItems(
      feedback: feedback,
      promptId: 'prompt_001',
    );

    expect(report.source, SpeechAttemptSource.localFallback);
    expect(report.overallLabel, isNotEmpty);
    expect(report.nextSteps, isNotEmpty);
    expect(reviewItems, hasLength(1));
    expect(reviewItems.first.label, 'please');
  });
}
