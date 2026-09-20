import '../../v2/domain/models/course_models.dart';
import '../../v2/domain/models/speech_models.dart';
import '../domain/session_models.dart';

class SessionComposer {
  const SessionComposer();

  SessionBlueprint fromLesson({
    required LessonBlueprint lesson,
    String? dailyTaskId,
    int maxSteps = 8,
  }) {
    final steps = <SessionStep>[];
    for (final activity in lesson.activities) {
      final step = _fromActivity(activity);
      if (step != null) {
        steps.add(step);
      }
      if (steps.length >= maxSteps) {
        break;
      }
    }

    return SessionBlueprint(
      id: lesson.id,
      kind: SessionKind.lesson,
      title: lesson.title,
      subtitle: lesson.subtitle,
      lessonId: lesson.id,
      dailyTaskId: dailyTaskId,
      steps: steps.isEmpty ? [_emptySpeakFallback(lesson.title)] : steps,
    );
  }

  SessionBlueprint fromPrompt({
    required SpeakingPrompt prompt,
    String? dailyTaskId,
    SessionKind kind = SessionKind.prompt,
  }) {
    final steps = <SessionStep>[];
    for (final word in prompt.warmupWords.take(3)) {
      if (word.trim().isEmpty) {
        continue;
      }
      steps.add(
        SessionStep(
          id: '${prompt.id}_warm_${steps.length}',
          kind: SessionStepKind.listenSpeak,
          title: '先把词站稳',
          instruction: '听一遍，再清楚地说出这个词。',
          prompt: word,
          hint: prompt.instruction,
          focusWords: [word],
        ),
      );
    }
    if (prompt.phraseDrills.isNotEmpty) {
      steps.add(
        SessionStep(
          id: '${prompt.id}_phrase',
          kind: SessionStepKind.listenSpeak,
          title: '连成一小段',
          instruction: '把短语读成一口气，不要一个词一顿。',
          prompt: prompt.phraseDrills.first,
          hint: prompt.rhythmCue,
          focusWords: prompt.focusWords.take(3).toList(),
        ),
      );
    }
    steps.add(
      SessionStep(
        id: '${prompt.id}_line',
        kind: SessionStepKind.listenSpeak,
        title: prompt.title,
        instruction: prompt.instruction,
        prompt: prompt.referenceText,
        hint: prompt.scenario,
        focusWords: prompt.focusWords,
      ),
    );

    return SessionBlueprint(
      id: prompt.id,
      kind: kind,
      title: prompt.title,
      subtitle: prompt.scenario,
      promptId: prompt.id,
      dailyTaskId: dailyTaskId,
      steps: steps,
    );
  }

  SessionBlueprint fromReview({
    required String id,
    required String label,
    required String reason,
    String? dailyTaskId,
    SpeakingPrompt? sourcePrompt,
  }) {
    final steps = <SessionStep>[
      SessionStep(
        id: '${id}_word',
        kind: SessionStepKind.listenSpeak,
        title: '把弱项再开口一次',
        instruction: '先听示范，再单独说清楚。',
        prompt: label,
        hint: reason,
        focusWords: [label],
      ),
    ];
    if (sourcePrompt != null && sourcePrompt.referenceText.trim().isNotEmpty) {
      steps.add(
        SessionStep(
          id: '${id}_line',
          kind: SessionStepKind.listenSpeak,
          title: '送回原句',
          instruction: '把刚才的词放回整句里再说一遍。',
          prompt: sourcePrompt.referenceText,
          hint: sourcePrompt.instruction,
          focusWords: sourcePrompt.focusWords,
        ),
      );
    }

    return SessionBlueprint(
      id: id,
      kind: SessionKind.review,
      title: '复习 $label',
      subtitle: reason,
      promptId: sourcePrompt?.id,
      dailyTaskId: dailyTaskId,
      steps: steps,
    );
  }

  SessionBlueprint fromSound({
    required PronunciationTarget target,
    String? dailyTaskId,
  }) {
    final examples = target.examples.where((item) => item.trim().isNotEmpty);
    final steps = <SessionStep>[
      SessionStep(
        id: '${target.id}_tip',
        kind: SessionStepKind.tip,
        title: target.symbol,
        instruction: target.subtitle,
        prompt: examples.isEmpty ? target.symbol : examples.first,
        hint: '${target.mouthPosition} ${target.correctionTip}'.trim(),
      ),
      ...examples.take(3).map(
        (word) => SessionStep(
          id: '${target.id}_$word',
          kind: SessionStepKind.listenSpeak,
          title: '跟读 ${target.symbol}',
          instruction: '听示范，再把这个词说清楚。',
          prompt: word,
          hint: target.correctionTip,
          focusWords: [word],
        ),
      ),
    ];

    return SessionBlueprint(
      id: target.id,
      kind: SessionKind.sound,
      title: '${target.symbol}  ${target.title}',
      subtitle: target.subtitle,
      dailyTaskId: dailyTaskId,
      steps: steps,
    );
  }

  SessionStep? _fromActivity(ActivityBlueprint activity) {
    switch (activity.kind) {
      case ActivityKind.mcq:
        if (activity.options.isEmpty) {
          return null;
        }
        return SessionStep(
          id: activity.id,
          kind: SessionStepKind.multipleChoice,
          title: activity.title,
          instruction: activity.instruction,
          prompt: activity.content ?? '',
          hint: activity.options
              .map((option) => option.explanation)
              .whereType<String>()
              .where((item) => item.trim().isNotEmpty)
              .firstOrNull ??
              '',
          options: activity.options,
          correctOptionId: activity.correctOptionId,
        );
      case ActivityKind.minimalPair:
        if (activity.pairs.isEmpty) {
          return null;
        }
        return SessionStep(
          id: activity.id,
          kind: SessionStepKind.minimalPair,
          title: activity.title,
          instruction: activity.instruction,
          prompt: activity.pairs
              .take(3)
              .map((pair) => '${pair.word1} / ${pair.word2}')
              .join('   '),
          hint: '先听清差别，再选你要练的那个词开口。',
          focusWords: [
            ...activity.pairs.take(2).expand((pair) => [pair.word1, pair.word2]),
          ],
          pairs: activity.pairs,
        );
      case ActivityKind.wordRepeat:
      case ActivityKind.sentenceReadAloud:
      case ActivityKind.shadowing:
      case ActivityKind.dialogRoleplay:
      case ActivityKind.speakingReflection:
      case ActivityKind.assessmentTask:
        final text = (activity.referenceText ?? activity.content ?? '').trim();
        if (text.isEmpty) {
          return null;
        }
        return SessionStep(
          id: activity.id,
          kind: SessionStepKind.listenSpeak,
          title: activity.title,
          instruction: activity.instruction,
          prompt: text,
          hint: activity.checklist.isEmpty ? '' : activity.checklist.first,
          focusWords: activity.focusWords,
        );
      case ActivityKind.phonemeIntro:
      case ActivityKind.dictation:
        return SessionStep(
          id: activity.id,
          kind: SessionStepKind.tip,
          title: activity.title,
          instruction: activity.instruction,
          prompt: _firstEnglishLine(activity.referenceText ?? activity.content ?? ''),
          hint: _shortHint(activity.content ?? activity.instruction),
        );
    }
  }

  SessionStep _emptySpeakFallback(String title) {
    return SessionStep(
      id: 'fallback_hello',
      kind: SessionStepKind.listenSpeak,
      title: title,
      instruction: '先听一遍，再把这句说出来。',
      prompt: 'Hello, nice to meet you.',
      hint: '没有找到可开口的原句，先用这句把循环走通。',
      focusWords: const ['hello', 'nice', 'meet'],
    );
  }

  String _firstEnglishLine(String raw) {
    final lines = raw
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && RegExp(r'[A-Za-z]').hasMatch(line))
        .map(
          (line) => line
              .replaceAll(RegExp(r'[*`#]'), '')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim(),
        )
        .where((line) => line.length <= 80)
        .toList();
    return lines.isEmpty ? '' : lines.first;
  }

  String _shortHint(String raw) {
    final cleaned = raw
        .replaceAll(RegExp(r'[*#`]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleaned.length <= 140) {
      return cleaned;
    }
    return '${cleaned.substring(0, 137).trim()}…';
  }
}
