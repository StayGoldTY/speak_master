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
      FluencyBand.confident when feedback.coverageScore >= 0.85 => '状态不错，可以继续',
      FluencyBand.steady => '再收一收会更稳',
      _ => '建议先补强这一轮',
    };

    final nextSteps = <String>[
      ...feedback.retrySuggestions.take(3),
      if (feedback.weakWords.isEmpty) '把同一句再读一遍，继续保持当前节奏。',
    ];

    final weakTargets = feedback.weakPointTags.take(3).toList();
    final weakSummary = weakTargets.isEmpty
        ? '这句话的主体已经比较清楚。'
        : '目前最不稳定的点是 ${weakTargets.map((item) => item.label).join('、')}。';

    return SpeechAssessmentReport(
      overallLabel: overallLabel,
      overview:
          '本轮识别线索约 ${(feedback.coverageScore * 100).round()}%。$weakSummary ${feedback.teacherExplanation}',
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
