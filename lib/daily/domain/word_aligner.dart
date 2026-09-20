enum WordAlignStatus { hit, miss, subst }

class AlignedWord {
  final String expected;
  final String? spoken;
  final WordAlignStatus status;

  const AlignedWord({
    required this.expected,
    required this.status,
    this.spoken,
  });
}

class WordAligner {
  const WordAligner();

  List<String> tokenize(String value) {
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

  List<AlignedWord> align({
    required String expected,
    required String spoken,
  }) {
    final source = tokenize(expected);
    final target = tokenize(spoken);
    if (source.isEmpty) {
      return const [];
    }

    final rows = source.length + 1;
    final cols = target.length + 1;
    final dist = List.generate(rows, (_) => List<int>.filled(cols, 0));
    final ops = List.generate(rows, (_) => List<String>.filled(cols, ''));

    for (var i = 1; i < rows; i++) {
      dist[i][0] = i;
      ops[i][0] = 'D';
    }
    for (var j = 1; j < cols; j++) {
      dist[0][j] = j;
      ops[0][j] = 'I';
    }

    for (var i = 1; i < rows; i++) {
      for (var j = 1; j < cols; j++) {
        final same = source[i - 1] == target[j - 1];
        final sub = dist[i - 1][j - 1] + (same ? 0 : 1);
        final del = dist[i - 1][j] + 1;
        final ins = dist[i][j - 1] + 1;
        if (sub <= del && sub <= ins) {
          dist[i][j] = sub;
          ops[i][j] = same ? 'M' : 'S';
        } else if (del <= ins) {
          dist[i][j] = del;
          ops[i][j] = 'D';
        } else {
          dist[i][j] = ins;
          ops[i][j] = 'I';
        }
      }
    }

    final aligned = <AlignedWord>[];
    var i = source.length;
    var j = target.length;
    while (i > 0 || j > 0) {
      final op = ops[i][j];
      if (op == 'M' || op == 'S') {
        aligned.add(
          AlignedWord(
            expected: source[i - 1],
            spoken: target[j - 1],
            status: op == 'M' ? WordAlignStatus.hit : WordAlignStatus.subst,
          ),
        );
        i -= 1;
        j -= 1;
      } else if (op == 'D') {
        aligned.add(
          AlignedWord(expected: source[i - 1], status: WordAlignStatus.miss),
        );
        i -= 1;
      } else if (op == 'I') {
        j -= 1;
      } else {
        break;
      }
    }

    return aligned.reversed.toList();
  }

  int hitCount(List<AlignedWord> words) {
    return words.where((word) => word.status == WordAlignStatus.hit).length;
  }
}
