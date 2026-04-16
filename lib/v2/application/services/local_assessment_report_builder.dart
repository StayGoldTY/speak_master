import '../../domain/models/course_models.dart';
import '../../domain/models/learner_models.dart';
import '../../domain/models/speech_models.dart';

class LocalAssessmentReportBuilder {
  const LocalAssessmentReportBuilder();

  SpeechAssessmentReport build({
    required SpeechFeedback feedback,
    required String recommendedRoute,
  }) {
    final overallLabel = switch (feedback.fluencyBand) {
      FluencyBand.confident when feedback.coverageScore >= 0.85 =>
        'Ready to move on',
      FluencyBand.steady => 'Keep tightening the line',
      _ => 'Rebuild the target once more',
    };

    final nextSteps = <String>[
      ...feedback.retrySuggestions.take(3),
      if (feedback.weakWords.isEmpty)
        'Repeat the same line once more and keep the rhythm equally stable.',
    ];

    final weakTargets = feedback.weakPointTags.take(3).toList();
    final weakSummary = weakTargets.isEmpty
        ? 'The main line is already coming through clearly.'
        : 'The least stable targets were ${weakTargets.map((item) => item.label).join(', ')}.';

    return SpeechAssessmentReport(
      overallLabel: overallLabel,
      overview:
          'Coverage is ${(feedback.coverageScore * 100).round()}%. $weakSummary ${feedback.teacherExplanation}',
      weakTargets: weakTargets,
      nextSteps: nextSteps,
      recommendedRoute: recommendedRoute,
      source: SpeechAttemptSource.localFallback,
      createdAt: feedback.generatedAt,
    );
  }

  List<ReviewItem> buildReviewItems({
    required SpeechFeedback feedback,
    required String promptId,
  }) {
    return feedback.weakPointTags.take(3).map((tag) {
      return ReviewItem(
        id: '$promptId:${tag.label}',
        label: tag.label,
        reason: tag.reason,
        recommendedActivityKind: _activityForTag(tag.type),
        score: (1 - feedback.coverageScore).clamp(0, 1) * 100,
      );
    }).toList();
  }

  ActivityKind _activityForTag(WeakPointTagType type) {
    return switch (type) {
      WeakPointTagType.phoneme => ActivityKind.phonemeIntro,
      WeakPointTagType.word => ActivityKind.wordRepeat,
      WeakPointTagType.rhythm ||
      WeakPointTagType.linkedSpeech => ActivityKind.shadowing,
      WeakPointTagType.stress => ActivityKind.sentenceReadAloud,
    };
  }
}
