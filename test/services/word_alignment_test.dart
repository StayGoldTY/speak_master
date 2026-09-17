import 'package:flutter_test/flutter_test.dart';
import 'package:speak_master/services/word_alignment.dart';

void main() {
  const aligner = WordAligner();

  test('keeps word order so a scrambled sentence is not a perfect match', () {
    final result = aligner.align(
      expected: ['can', 'i', 'get', 'a', 'large', 'latte', 'please'],
      spoken: ['please', 'can', 'i', 'latte', 'get', 'a', 'large'],
    );

    expect(result.coverage, lessThan(1));
    expect(result.alignments.any((item) => !item.isMatch), isTrue);
  });

  test('marks omissions and substitutions in sequence', () {
    final result = aligner.align(
      expected: ['the', 'weather', 'is', 'getting', 'better'],
      spoken: ['the', 'whether', 'is', 'better'],
    );

    expect(result.matchedWords, containsAll(['the', 'is', 'better']));
    expect(result.substitutedWords, contains('weather'));
    expect(result.missingWords, contains('getting'));
    expect(result.coverage, closeTo(3 / 5, 0.001));
  });
}
