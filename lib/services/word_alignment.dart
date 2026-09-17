enum WordAlignStatus { match, substitute, missing, extra }

class AlignedWord {
  final String expected;
  final String spoken;
  final WordAlignStatus status;

  const AlignedWord({
    required this.expected,
    required this.spoken,
    required this.status,
  });

  bool get isMatch => status == WordAlignStatus.match;

  String get displayLabel {
    return switch (status) {
      WordAlignStatus.match => expected,
      WordAlignStatus.substitute => '$expected → $spoken',
      WordAlignStatus.missing => expected,
      WordAlignStatus.extra => spoken,
    };
  }
}

class WordAlignmentResult {
  final List<String> expectedWords;
  final List<String> spokenWords;
  final List<AlignedWord> alignments;
  final List<String> matchedWords;
  final List<String> missingWords;
  final List<String> extraWords;
  final List<String> substitutedWords;
  final double coverage;

  const WordAlignmentResult({
    required this.expectedWords,
    required this.spokenWords,
    required this.alignments,
    required this.matchedWords,
    required this.missingWords,
    required this.extraWords,
    required this.substitutedWords,
    required this.coverage,
  });
}

/// Ordered word alignment via Levenshtein backtrace.
///
/// Bag-of-words coverage treats "please can I latte get a large" as a perfect
/// match. Alignment keeps sequence, so substitutions and omissions stay visible.
class WordAligner {
  const WordAligner();

  WordAlignmentResult align({
    required List<String> expected,
    required List<String> spoken,
  }) {
    final table = _levenshtein(expected, spoken);
    final alignments = _backtrace(expected, spoken, table);

    final matched = alignments
        .where((item) => item.status == WordAlignStatus.match)
        .map((item) => item.expected)
        .toList();
    final missing = alignments
        .where((item) => item.status == WordAlignStatus.missing)
        .map((item) => item.expected)
        .toList();
    final extra = alignments
        .where((item) => item.status == WordAlignStatus.extra)
        .map((item) => item.spoken)
        .toList();
    final substituted = alignments
        .where((item) => item.status == WordAlignStatus.substitute)
        .map((item) => item.expected)
        .toList();

    final coverage = expected.isEmpty ? 0.0 : matched.length / expected.length;

    return WordAlignmentResult(
      expectedWords: expected,
      spokenWords: spoken,
      alignments: alignments,
      matchedWords: matched,
      missingWords: [...substituted, ...missing],
      extraWords: extra,
      substitutedWords: substituted,
      coverage: coverage.clamp(0.0, 1.0),
    );
  }

  List<List<int>> _levenshtein(List<String> expected, List<String> spoken) {
    final rows = expected.length;
    final cols = spoken.length;
    final table = List.generate(
      rows + 1,
      (row) => List<int>.filled(cols + 1, 0),
    );

    for (var row = 0; row <= rows; row++) {
      table[row][0] = row;
    }
    for (var col = 0; col <= cols; col++) {
      table[0][col] = col;
    }

    for (var row = 1; row <= rows; row++) {
      for (var col = 1; col <= cols; col++) {
        final cost = expected[row - 1] == spoken[col - 1] ? 0 : 1;
        table[row][col] = _min3(
          table[row - 1][col] + 1,
          table[row][col - 1] + 1,
          table[row - 1][col - 1] + cost,
        );
      }
    }

    return table;
  }

  List<AlignedWord> _backtrace(
    List<String> expected,
    List<String> spoken,
    List<List<int>> table,
  ) {
    var row = expected.length;
    var col = spoken.length;
    final reversed = <AlignedWord>[];

    while (row > 0 || col > 0) {
      if (row > 0 &&
          col > 0 &&
          expected[row - 1] == spoken[col - 1] &&
          table[row][col] == table[row - 1][col - 1]) {
        reversed.add(
          AlignedWord(
            expected: expected[row - 1],
            spoken: spoken[col - 1],
            status: WordAlignStatus.match,
          ),
        );
        row -= 1;
        col -= 1;
        continue;
      }

      if (row > 0 &&
          col > 0 &&
          table[row][col] == table[row - 1][col - 1] + 1) {
        reversed.add(
          AlignedWord(
            expected: expected[row - 1],
            spoken: spoken[col - 1],
            status: WordAlignStatus.substitute,
          ),
        );
        row -= 1;
        col -= 1;
        continue;
      }

      if (col > 0 && table[row][col] == table[row][col - 1] + 1) {
        reversed.add(
          AlignedWord(
            expected: '',
            spoken: spoken[col - 1],
            status: WordAlignStatus.extra,
          ),
        );
        col -= 1;
        continue;
      }

      reversed.add(
        AlignedWord(
          expected: expected[row - 1],
          spoken: '',
          status: WordAlignStatus.missing,
        ),
      );
      row -= 1;
    }

    return reversed.reversed.toList();
  }

  int _min3(int a, int b, int c) {
    if (a <= b && a <= c) {
      return a;
    }
    if (b <= a && b <= c) {
      return b;
    }
    return c;
  }
}
