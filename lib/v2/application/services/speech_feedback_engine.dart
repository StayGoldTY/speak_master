import '../../../services/pronunciation_check_engine.dart';
import '../../domain/models/course_models.dart';
import '../../domain/models/speech_models.dart';

class SpeechFeedbackEngine {
  const SpeechFeedbackEngine();

  SpeechFeedback build({
    required PronunciationCheckResult result,
    required SpeakingPrompt prompt,
    required bool fallbackUsed,
  }) {
    final recognizedWords = _tokenize(result.transcript);
    final expectedWords = _tokenize(result.referenceText);
    final spokenWords = recognizedWords.toSet();
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
    final weakWords = _buildWeakWords(
      result: result,
      prompt: prompt,
      spokenWords: spokenWords,
    );
    final missingPhrases = prompt.phraseDrills
        .where((item) => !_fragmentCovered(item, spokenWords))
        .take(2)
        .toList();

    return SpeechFeedback(
      recognizedText: result.transcript,
      coverageScore: result.recognitionCoverage,
      fluencyBand: fluencyBand,
      paceBand: paceBand,
      stressHints: _buildStressHints(
        prompt: prompt,
        paceBand: paceBand,
        weakWords: weakWords,
        missingPhrases: missingPhrases,
      ),
      weakWords: weakWords,
      retrySuggestions: _buildRetrySuggestions(
        prompt: prompt,
        result: result,
        paceBand: paceBand,
        weakWords: weakWords,
        missingPhrases: missingPhrases,
        spokenWords: spokenWords,
      ),
      teacherExplanation: _buildTeacherExplanation(
        prompt: prompt,
        result: result,
        paceBand: paceBand,
        weakWords: weakWords,
        missingPhrases: missingPhrases,
      ),
      fallbackUsed: fallbackUsed,
      weakPointTags: _buildWeakPointTags(
        prompt: prompt,
        paceBand: paceBand,
        weakWords: weakWords,
        missingPhrases: missingPhrases,
      ),
      generatedAt: DateTime.now(),
    );
  }

  List<String> _buildWeakWords({
    required PronunciationCheckResult result,
    required SpeakingPrompt prompt,
    required Set<String> spokenWords,
  }) {
    final values = <String>[];

    void add(String value) {
      final normalized = value.trim();
      if (normalized.isNotEmpty && !values.contains(normalized)) {
        values.add(normalized);
      }
    }

    for (final item in result.missingFocusWords) {
      add(item);
    }
    for (final item in prompt.warmupWords) {
      if (!_fragmentCovered(item, spokenWords)) {
        add(item);
      }
    }
    for (final item in prompt.focusWords) {
      if (!_fragmentCovered(item, spokenWords)) {
        add(item);
      }
    }
    for (final item in result.missingWords) {
      add(item);
    }

    return values.take(4).toList();
  }

  List<String> _buildStressHints({
    required SpeakingPrompt prompt,
    required PaceBand paceBand,
    required List<String> weakWords,
    required List<String> missingPhrases,
  }) {
    final hints = <String>[];

    if (prompt.phraseDrills.isNotEmpty) {
      hints.add('句子骨架先盯住 ${prompt.phraseDrills.first}。');
    }
    if (missingPhrases.isNotEmpty) {
      hints.add('下一轮先把 ${missingPhrases.first} 这一段连成一口气。');
    } else if (weakWords.isNotEmpty) {
      hints.add('重点把 ${weakWords.take(2).join(' / ')} 落清楚。');
    }
    if (prompt.rhythmCue.trim().isNotEmpty) {
      hints.add(prompt.rhythmCue.trim());
    }
    hints.add(_paceHint(paceBand));

    return hints.take(3).toList();
  }

  List<String> _buildRetrySuggestions({
    required SpeakingPrompt prompt,
    required PronunciationCheckResult result,
    required PaceBand paceBand,
    required List<String> weakWords,
    required List<String> missingPhrases,
    required Set<String> spokenWords,
  }) {
    final suggestions = <String>[];
    final missingWarmups = prompt.warmupWords
        .where((item) => !_fragmentCovered(item, spokenWords))
        .take(2)
        .toList();

    if (missingWarmups.isNotEmpty) {
      suggestions.add('先单练 ${missingWarmups.join(' / ')}，把音读稳。');
    }
    if (missingPhrases.isNotEmpty) {
      suggestions.add('再把 ${missingPhrases.first} 这一段连起来读。');
    }
    switch (paceBand) {
      case PaceBand.tooFast:
        suggestions.add('语速先慢半拍，让重点词真正落下来。');
      case PaceBand.tooSlow:
        suggestions.add('保持整句往前走，不要把每个词都切开。');
      case PaceBand.balanced:
        break;
    }
    if (result.recognitionCoverage < 0.72) {
      suggestions.add(_coverageResetSuggestion(prompt.kind));
    }
    if (prompt.sentenceVariations.isNotEmpty) {
      suggestions.add('最后换一句变体再开口：${prompt.sentenceVariations.first}');
    } else if (prompt.extensionPrompt.trim().isNotEmpty) {
      suggestions.add(prompt.extensionPrompt.trim());
    }
    if (suggestions.isEmpty && weakWords.isNotEmpty) {
      suggestions.add('把 ${weakWords.join(' / ')} 再读一轮，然后回到整句。');
    }

    return suggestions.take(4).toList();
  }

  String _buildTeacherExplanation({
    required SpeakingPrompt prompt,
    required PronunciationCheckResult result,
    required PaceBand paceBand,
    required List<String> weakWords,
    required List<String> missingPhrases,
  }) {
    final coverage = (result.recognitionCoverage * 100).round();
    final coverageLine = switch (result.recognitionCoverage) {
      >= 0.82 => '这轮可理解度线索不错，识别到的主干约 $coverage%。',
      >= 0.56 => '这轮大意基本能被抓到，识别到的主干约 $coverage%。',
      _ => '这轮还在找句子骨架，识别到的主干约 $coverage%。',
    };
    final modeLine = switch (prompt.kind) {
      ActivityKind.shadowing => '影子跟读先追求整口气的连贯感，再修局部发音。',
      ActivityKind.dialogRoleplay => '场景表达先把意图抛出来，再补细节和礼貌尾音。',
      ActivityKind.assessmentTask => '测评句先保住整句稳定，再回头修局部音和节奏。',
      ActivityKind.wordRepeat => '这一轮先把目标词站稳，再把它们送回句子里。',
      _ => '这一轮先保住整句骨架，再去修细节。',
    };
    final weakLine = weakWords.isEmpty
        ? '重点词目前比较稳。'
        : '这次还要盯住 ${weakWords.take(2).join(' / ')}。';
    final phraseLine = missingPhrases.isNotEmpty
        ? '下一轮先拆回 ${missingPhrases.first}，再连回整句。'
        : prompt.extensionPrompt.trim().isNotEmpty
        ? prompt.extensionPrompt.trim()
        : '下一轮可以直接换一句变体，保持自然度。';
    final rhythmLine = prompt.rhythmCue.trim().isNotEmpty
        ? prompt.rhythmCue.trim()
        : _paceHint(paceBand);

    return '$coverageLine $modeLine $weakLine $rhythmLine $phraseLine';
  }

  List<WeakPointTag> _buildWeakPointTags({
    required SpeakingPrompt prompt,
    required PaceBand paceBand,
    required List<String> weakWords,
    required List<String> missingPhrases,
  }) {
    final tags = <WeakPointTag>[
      ...weakWords.map(
        (word) => WeakPointTag(
          label: word,
          type: WeakPointTagType.word,
          reason: '这一轮里它还没有稳定落出来，需要单独再练后回到整句。',
        ),
      ),
    ];

    if (missingPhrases.isNotEmpty) {
      tags.add(
        WeakPointTag(
          label: missingPhrases.first,
          type: WeakPointTagType.linkedSpeech,
          reason: '这段短语还没有形成一口气的自然连读。',
        ),
      );
    }
    if (paceBand != PaceBand.balanced || prompt.rhythmCue.trim().isNotEmpty) {
      tags.add(
        WeakPointTag(
          label: '节奏',
          type: WeakPointTagType.rhythm,
          reason: prompt.rhythmCue.trim().isNotEmpty
              ? prompt.rhythmCue.trim()
              : _paceHint(paceBand),
        ),
      );
    }

    return tags.take(4).toList();
  }

  String _coverageResetSuggestion(ActivityKind kind) {
    return switch (kind) {
      ActivityKind.shadowing => '先跟着标准音完整 shadow 一遍，再自己说一遍。',
      ActivityKind.dialogRoleplay => '先把参考句说顺，再替换一个细节做第二轮。',
      ActivityKind.assessmentTask => '先慢速读稳一轮，再用自然语速复读一遍。',
      _ => '先听一遍标准音，再按自然节奏重来一轮。',
    };
  }

  String _paceHint(PaceBand paceBand) {
    return switch (paceBand) {
      PaceBand.tooFast => '这轮语速有点快，先让重音词落下来。',
      PaceBand.tooSlow => '这轮节奏偏慢，下一轮把短语往前带起来。',
      PaceBand.balanced => '这轮节奏基本合适，继续把尾音收干净。',
    };
  }

  bool _fragmentCovered(String fragment, Set<String> spokenWords) {
    final tokens = _tokenize(fragment);
    if (tokens.isEmpty) {
      return true;
    }

    final matched = tokens.where(spokenWords.contains).length;
    return matched / tokens.length >= 0.7;
  }

  List<String> _tokenize(String value) {
    final normalized = value
        .toLowerCase()
        .replaceAll("'", '')
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (normalized.isEmpty) {
      return const [];
    }

    return normalized
        .split(' ')
        .where(
          (item) =>
              item.isNotEmpty &&
              (item.length > 1 || item == 'a' || item == 'i'),
        )
        .toList();
  }
}
