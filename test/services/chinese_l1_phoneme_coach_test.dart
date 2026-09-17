import 'package:flutter_test/flutter_test.dart';
import 'package:speak_master/services/chinese_l1_phoneme_coach.dart';

void main() {
  const coach = ChineseL1PhonemeCoach();

  test('returns L1 coaching for common Chinese-English problem words', () {
    final hints = coach.hintsForWords(const ['please', 'weather', 'latte']);

    expect(hints, isNotEmpty);
    expect(hints.join(' '), contains('please'));
    expect(hints.join(' '), contains('/z/'));
  });

  test('maps IPA phonemes without inventing a score', () {
    expect(coach.hintForPhoneme('θ'), contains('齿'));
    expect(coach.hintForPhoneme('/ð/'), contains('带声'));
  });
}
