import '../models/lesson.dart';

enum PronunciationCheckLevel { retry, partial, good }

class PronunciationCheckResult {
  final String referenceText;
  final String transcript;
  final double recognitionCoverage;
  final List<String> matchedWords;
  final List<String> missingWords;
  final List<String> matchedFocusWords;
  final List<String> missingFocusWords;
  final List<String> notes;

  const PronunciationCheckResult({
    required this.referenceText,
    required this.transcript,
    required this.recognitionCoverage,
    required this.matchedWords,
    required this.missingWords,
    required this.matchedFocusWords,
    required this.missingFocusWords,
    required this.notes,
  });

  bool get hasTranscript => transcript.trim().isNotEmpty;

  int get recognitionCoveragePercent => (recognitionCoverage * 100).round();

  PronunciationCheckLevel get level {
    if (!hasTranscript || recognitionCoverage < 0.35) {
      return PronunciationCheckLevel.retry;
    }
    if (recognitionCoverage < 0.72 || missingFocusWords.isNotEmpty) {
      return PronunciationCheckLevel.partial;
    }
    return PronunciationCheckLevel.good;
  }

  String get levelLabel {
    return switch (level) {
      PronunciationCheckLevel.retry => '需要重试',
      PronunciationCheckLevel.partial => '接近了',
      PronunciationCheckLevel.good => '主体已读出来',
    };
  }
}

class PronunciationCheckEngine {
  PronunciationCheckEngine._();

  static PronunciationCheckResult analyze({
    LessonStep? step,
    String? referenceText,
    List<String>? focusWords,
    required String transcript,
  }) {
    assert(
      step != null || referenceText != null,
      'Either step or referenceText must be provided.',
    );

    final resolvedReferenceText =
        referenceText?.trim().isNotEmpty == true
            ? referenceText!.trim()
            : buildReferenceText(step!);
    final resolvedFocusWords =
        focusWords != null && focusWords.isNotEmpty
            ? _uniqueTokens(focusWords.expand((item) => _tokenize(item)).toList())
            : step != null
            ? extractFocusWords(step)
            : extractFocusWordsFromText(resolvedReferenceText);

    final expectedWords = _uniqueTokens(_tokenize(resolvedReferenceText));
    final spokenWords = _uniqueTokens(_tokenize(transcript));

    final matchedWords = expectedWords.where(spokenWords.contains).toList();
    final missingWords = expectedWords
        .where((word) => !spokenWords.contains(word))
        .take(8)
        .toList();
    final matchedFocusWords = resolvedFocusWords
        .where(spokenWords.contains)
        .toList();
    final missingFocusWords = resolvedFocusWords
        .where((word) => !spokenWords.contains(word))
        .toList();

    final recognitionCoverage = expectedWords.isEmpty
        ? 0.0
        : matchedWords.length / expectedWords.length;

    final notes = <String>[
      if (transcript.trim().isEmpty)
        '还没有识别到有效英文，先检查浏览器麦克风权限、环境噪音和说话音量。'
      else if (recognitionCoverage < 0.35)
        '识别覆盖较低，建议先放慢语速，只读一组词或一句短句。'
      else if (recognitionCoverage < 0.72)
        '句子主体已经被部分识别，下一轮优先把缺失的关键词说完整。'
      else
        '这次识别已经抓到大部分主体内容，可以继续回头修边界和节奏。',
      if (missingFocusWords.isNotEmpty)
        '重点词还没稳定识别出来：${missingFocusWords.join(' / ')}',
      if (matchedFocusWords.isNotEmpty)
        '已识别到的重点词：${matchedFocusWords.join(' / ')}',
      '这是基于语音识别的自动检查，不是声学发音评分。',
    ];

    return PronunciationCheckResult(
      referenceText: resolvedReferenceText,
      transcript: transcript.trim(),
      recognitionCoverage: recognitionCoverage.clamp(0.0, 1.0),
      matchedWords: matchedWords,
      missingWords: missingWords,
      matchedFocusWords: matchedFocusWords,
      missingFocusWords: missingFocusWords,
      notes: notes,
    );
  }

  static String buildReferenceText(LessonStep step) {
    final explicit = step.metadata?['referenceText']?.toString().trim() ?? '';
    if (explicit.isNotEmpty) {
      return explicit;
    }

    final pairWords = _extractPairWords(step);
    if (pairWords.isNotEmpty) {
      final groupedPairs = <String>[];
      for (var index = 0; index < pairWords.length && index < 12; index += 2) {
        final first = pairWords[index];
        final second = index + 1 < pairWords.length
            ? pairWords[index + 1]
            : null;
        groupedPairs.add(second == null ? first : '$first, $second');
      }
      return groupedPairs.join('. ');
    }

    final content = step.content?.trim() ?? '';
    if (content.isEmpty) {
      return '';
    }

    final lines = content
        .split('\n')
        .map((line) => _sanitizeEnglishLine(line))
        .where((line) => line.isNotEmpty && RegExp(r'[A-Za-z]').hasMatch(line))
        .toList();

    if (lines.isEmpty) {
      return '';
    }

    final selectedLines = <String>[];
    var tokenCount = 0;
    for (final line in lines) {
      selectedLines.add(line);
      tokenCount += _tokenize(line).length;
      if (tokenCount >= 28) {
        break;
      }
    }

    return selectedLines.join('. ').trim();
  }

  static List<String> extractFocusWords(LessonStep step) {
    final explicit = _stringList(step.metadata?['focusWords']);
    if (explicit.isNotEmpty) {
      return _uniqueTokens(explicit.expand((item) => _tokenize(item)).toList());
    }

    final pairWords = _extractPairWords(step);
    if (pairWords.isNotEmpty) {
      return _uniqueTokens(pairWords).take(6).toList();
    }

    return _uniqueTokens(_tokenize(buildReferenceText(step))).take(6).toList();
  }

  static List<String> extractFocusWordsFromText(
    String referenceText, {
    int limit = 6,
  }) {
    return _uniqueTokens(_tokenize(referenceText)).take(limit).toList();
  }

  static List<String> _extractPairWords(LessonStep step) {
    final pairs = step.metadata?['pairs'];
    if (pairs is! List) {
      return const [];
    }

    final words = <String>[];
    for (final pair in pairs) {
      if (pair is String) {
        final parts = pair
            .split('|')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty);
        words.addAll(parts.expand(_tokenize));
      } else if (pair is Map) {
        final word1 = pair['word1']?.toString() ?? '';
        final word2 = pair['word2']?.toString() ?? '';
        words.addAll(_tokenize(word1));
        words.addAll(_tokenize(word2));
      }
    }

    return _uniqueTokens(words);
  }

  static String _sanitizeEnglishLine(String line) {
    return line
        .replaceAll(RegExp(r'/[^/\n]+/'), ' ')
        .replaceAll('→', ' ')
        .replaceAll(RegExp(r"[^A-Za-z0-9\s,.'?!-]"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static List<String> _tokenize(String value) {
    final normalized = value
        .toLowerCase()
        .replaceAll('’', "'")
        .replaceAll("'", '')
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (normalized.isEmpty) {
      return const [];
    }

    return normalized
        .split(' ')
        .map((item) => item.trim())
        .where(
          (item) =>
              item.isNotEmpty &&
              (item.length > 1 || item == 'a' || item == 'i'),
        )
        .toList();
  }

  static List<String> _uniqueTokens(List<String> values) {
    final unique = <String>[];
    final seen = <String>{};
    for (final value in values) {
      if (seen.add(value)) {
        unique.add(value);
      }
    }
    return unique;
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return const [];
  }
}
