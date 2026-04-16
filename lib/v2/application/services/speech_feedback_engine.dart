import '../../../services/pronunciation_check_engine.dart';
import '../../domain/models/speech_models.dart';

class SpeechFeedbackEngine {
  const SpeechFeedbackEngine();

  SpeechFeedback build({
    required PronunciationCheckResult result,
    required List<String> focusWords,
    required bool fallbackUsed,
  }) {
    final recognizedWords = result.transcript
        .split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .toList();
    final expectedWords = result.referenceText
        .split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .toList();
    final wordRatio = expectedWords.isEmpty
        ? 0.0
        : recognizedWords.length / expectedWords.length;

    final fluencyBand = switch (result.recognitionCoverage) {
      >= 0.82 => FluencyBand.confident,
      >= 0.56 => FluencyBand.steady,
      _ => FluencyBand.emerging,
    };
    final paceBand = wordRatio > 1.18
        ? PaceBand.tooFast
        : wordRatio < 0.72
        ? PaceBand.tooSlow
        : PaceBand.balanced;
    final weakWords = {
      ...result.missingFocusWords,
      ...result.missingWords,
    }.take(4).toList();
    final anchoredFocus = focusWords.take(3).toList();
    final stressHints = anchoredFocus.isEmpty
        ? const ['把内容词读得更清楚一点，并适当拉长重音。']
        : ['下一轮重点盯住 ${anchoredFocus.join('、')}，虚词可以更轻一些。'];
    final retrySuggestions = [
      if (weakWords.isNotEmpty) '重练时把 ${weakWords.join('、')} 读得更清楚。',
      if (paceBand == PaceBand.tooFast) '语速稍微放慢一点，让重点词真正落下来。',
      if (paceBand == PaceBand.tooSlow) '保持整句连贯，不要把每个词切得太开。',
      if (result.recognitionCoverage < 0.72) '再听一遍标准音，然后按一个顺畅意群连着读。',
    ];
    final weakTags = [
      ...weakWords.map(
        (word) => WeakPointTag(
          label: word,
          type: WeakPointTagType.word,
          reason: '这个词在上一轮里没有被稳定识别出来。',
        ),
      ),
      if (paceBand != PaceBand.balanced)
        WeakPointTag(
          label: '节奏',
          type: WeakPointTagType.rhythm,
          reason: '这一轮的整体节奏还没有贴近目标句子的自然状态。',
        ),
    ];

    return SpeechFeedback(
      recognizedText: result.transcript,
      coverageScore: result.recognitionCoverage,
      fluencyBand: fluencyBand,
      paceBand: paceBand,
      stressHints: stressHints,
      weakWords: weakWords,
      retrySuggestions: retrySuggestions,
      teacherExplanation: _buildTeacherExplanation(
        result: result,
        weakWords: weakWords,
        paceBand: paceBand,
      ),
      fallbackUsed: fallbackUsed,
      weakPointTags: weakTags,
      generatedAt: DateTime.now(),
    );
  }

  String _buildTeacherExplanation({
    required PronunciationCheckResult result,
    required List<String> weakWords,
    required PaceBand paceBand,
  }) {
    final paceLine = switch (paceBand) {
      PaceBand.tooFast => '这一轮语速略快。',
      PaceBand.tooSlow => '这一轮节奏稍微有些断开。',
      PaceBand.balanced => '整体节奏基本合适。',
    };
    final coverage = (result.recognitionCoverage * 100).round();
    final weakLine = weakWords.isEmpty
        ? '大部分目标词已经被识别到。'
        : '下一轮重点盯住 ${weakWords.join('、')}。';

    return '识别覆盖率约为 $coverage%。$paceLine $weakLine';
  }
}
