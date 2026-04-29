import '../../domain/models/speech_models.dart';

enum PronunciationDrillStageKind { listen, word, phrase, sentence, transfer }

class PronunciationDrillStage {
  final PronunciationDrillStageKind kind;
  final String title;
  final String helper;
  final List<String> items;

  const PronunciationDrillStage({
    required this.kind,
    required this.title,
    required this.helper,
    required this.items,
  });
}

class PronunciationDrillRouteBuilder {
  const PronunciationDrillRouteBuilder._();

  static List<PronunciationDrillStage> build(SpeakingPrompt prompt) {
    final focusItems = _cleanUnique([
      ...prompt.focusWords,
      ...prompt.warmupWords,
    ]);
    final warmupItems = _cleanUnique(
      prompt.warmupWords.isNotEmpty ? prompt.warmupWords : focusItems,
    );
    final phraseItems = _cleanUnique(
      prompt.phraseDrills.isNotEmpty
          ? prompt.phraseDrills
          : _referenceChunks(prompt.referenceText),
    );
    final sentenceItem = prompt.referenceText.trim();
    final transferItems = _cleanUnique([
      ...prompt.sentenceVariations,
      if (prompt.extensionPrompt.trim().isNotEmpty)
        prompt.extensionPrompt.trim(),
    ]);

    return [
      PronunciationDrillStage(
        kind: PronunciationDrillStageKind.listen,
        title: '先听辨',
        helper: '先听目标音和重音位置，再开口模仿。',
        items: _fallbackItems(focusItems.take(3), sentenceItem),
      ),
      PronunciationDrillStage(
        kind: PronunciationDrillStageKind.word,
        title: '再单练',
        helper: '把容易丢失或含糊的词单独练稳。',
        items: _fallbackItems(warmupItems, sentenceItem),
      ),
      PronunciationDrillStage(
        kind: PronunciationDrillStageKind.phrase,
        title: '短语连读',
        helper: '把词放回短语里，练连接、弱读和停顿。',
        items: _fallbackItems(phraseItems, sentenceItem),
      ),
      PronunciationDrillStage(
        kind: PronunciationDrillStageKind.sentence,
        title: '整句跟读',
        helper: '按自然语速跟读整句，保留清楚的重点词。',
        items: [if (sentenceItem.isNotEmpty) sentenceItem],
      ),
      PronunciationDrillStage(
        kind: PronunciationDrillStageKind.transfer,
        title: '变体开口',
        helper: '换一个细节复述，确认离开原句后仍然能说清楚。',
        items: _fallbackItems(transferItems, sentenceItem),
      ),
    ];
  }

  static List<String> _fallbackItems(Iterable<String> items, String fallback) {
    final cleaned = _cleanUnique(items);
    if (cleaned.isNotEmpty) {
      return cleaned;
    }
    final trimmed = fallback.trim();
    return trimmed.isEmpty ? const [] : [trimmed];
  }

  static List<String> _cleanUnique(Iterable<String> items) {
    final seen = <String>{};
    final result = <String>[];

    for (final item in items) {
      final normalized = item.trim();
      if (normalized.isNotEmpty && seen.add(normalized.toLowerCase())) {
        result.add(normalized);
      }
    }

    return result;
  }

  static List<String> _referenceChunks(String referenceText) {
    final words = referenceText
        .split(RegExp(r'\s+'))
        .map((word) => word.trim())
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.length <= 3) {
      return [referenceText.trim()];
    }

    final midpoint = (words.length / 2).ceil();
    return [words.take(midpoint).join(' '), words.skip(midpoint).join(' ')];
  }
}
