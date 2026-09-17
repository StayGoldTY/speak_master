import '../../domain/models/course_models.dart';
import '../../domain/models/learner_models.dart';
import '../../domain/models/speech_models.dart';

class LocalAssessmentReportBuilder {
  const LocalAssessmentReportBuilder();

  SpeechAssessmentReport build({
    required SpeechFeedback feedback,
    required String recommendedRoute,
  }) {
    final overallLabel = feedback.isAcoustic
        ? switch (feedback.overallAcousticScore ?? 0) {
            >= 80 => '声学评分可以进入下一轮',
            >= 60 => '声学评分还要再收一收',
            _ => '先把低分词和音素补上',
          }
        : switch (feedback.fluencyBand) {
            FluencyBand.confident when feedback.coverageScore >= 0.85 =>
              '状态不错，可以继续',
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
    final scoreLine = feedback.isAcoustic
        ? '本轮 Azure 综合发音分 ${feedback.overallAcousticScore?.round() ?? 0}（准确 ${feedback.accuracyScore?.round() ?? 0} / 完整 ${((feedback.completenessScore ?? (feedback.coverageScore * 100)).round())}）。'
        : '本轮识别对齐约 ${(feedback.coverageScore * 100).round()}%，不是声学评分。';

    return SpeechAssessmentReport(
      overallLabel: overallLabel,
      overview: '$scoreLine $weakSummary ${feedback.teacherExplanation}',
      weakTargets: weakTargets,
      nextSteps: nextSteps,
      recommendedRoute: recommendedRoute,
      source: feedback.isAcoustic
          ? SpeechAttemptSource.cloud
          : SpeechAttemptSource.localFallback,
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
        score: feedback.isAcoustic
            ? (100 - (feedback.overallAcousticScore ?? 0)).clamp(0, 100).toDouble()
            : (1 - feedback.coverageScore).clamp(0, 1) * 100,
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
