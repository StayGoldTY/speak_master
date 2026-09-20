import 'package:flutter_test/flutter_test.dart';
import 'package:speak_master/daily/domain/word_aligner.dart';

void main() {
  const aligner = WordAligner();

  test('aligns words in order and marks misses without inventing a score', () {
    final words = aligner.align(
      expected: 'Can I get a latte please',
      spoken: 'Can I get latte',
    );

    expect(words.map((word) => word.expected).toList(), [
      'can',
      'i',
      'get',
      'a',
      'latte',
      'please',
    ]);
    expect(words[0].status, WordAlignStatus.hit);
    expect(words[3].status, WordAlignStatus.miss);
    expect(words[4].status, WordAlignStatus.hit);
    expect(words[5].status, WordAlignStatus.miss);
    expect(aligner.hitCount(words), 4);
  });

  test('marks substitutions instead of pretending the word was correct', () {
    final words = aligner.align(expected: 'think thin', spoken: 'sink thin');
    expect(words.first.status, WordAlignStatus.subst);
    expect(words.last.status, WordAlignStatus.hit);
  });
}
