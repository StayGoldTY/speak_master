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
        ? const ['Keep the important content words clear and slightly longer.']
        : [
            'Lean on ${anchoredFocus.join(', ')} and keep function words lighter.',
          ];
    final retrySuggestions = [
      if (weakWords.isNotEmpty)
        'Retry with extra clarity on ${weakWords.join(', ')}.',
      if (paceBand == PaceBand.tooFast)
        'Slow down slightly so the key words land cleanly.',
      if (paceBand == PaceBand.tooSlow)
        'Keep the line connected and avoid over-separating each word.',
      if (result.recognitionCoverage < 0.72)
        'Listen once more and repeat in one smooth breath group.',
    ];
    final weakTags = [
      ...weakWords.map(
        (word) => WeakPointTag(
          label: word,
          type: WeakPointTagType.word,
          reason: 'This word was not stably recognized in the last attempt.',
        ),
      ),
      if (paceBand != PaceBand.balanced)
        WeakPointTag(
          label: 'pace',
          type: WeakPointTagType.rhythm,
          reason: 'The current delivery sounds less balanced than the target line.',
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
      PaceBand.tooFast => 'Your pace is running a little fast.',
      PaceBand.tooSlow => 'Your pace is a little too segmented.',
      PaceBand.balanced => 'Your overall pace is in a healthy range.',
    };
    final coverage = (result.recognitionCoverage * 100).round();
    final weakLine = weakWords.isEmpty
        ? 'Most target words were recognized.'
        : 'Focus next on ${weakWords.join(', ')}.';

    return 'Coverage is $coverage%. $paceLine $weakLine';
  }
}
