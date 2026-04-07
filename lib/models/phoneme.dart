enum PhonemeType { vowel, consonant }

enum VowelSubType { frontVowel, centralVowel, backVowel, diphthong }

enum ConsonantSubType { plosive, fricative, affricate, nasal, lateral, approximant, cluster }

class Phoneme {
  final String id;
  final String symbol;
  final PhonemeType type;
  final VowelSubType? vowelSubType;
  final ConsonantSubType? consonantSubType;
  final String nameEn;
  final String nameCn;
  final String description;
  final List<String> exampleWords;
  final List<String> exampleSentences;
  final String mouthPosition;
  final String commonMistake;
  final String correctionTip;
  final String? audioAsset;
  final bool isChineseDifficulty;

  const Phoneme({
    required this.id,
    required this.symbol,
    required this.type,
    this.vowelSubType,
    this.consonantSubType,
    required this.nameEn,
    required this.nameCn,
    required this.description,
    required this.exampleWords,
    required this.exampleSentences,
    required this.mouthPosition,
    required this.commonMistake,
    required this.correctionTip,
    this.audioAsset,
    this.isChineseDifficulty = false,
  });
}

class MinimalPair {
  final String word1;
  final String word2;
  final String phoneme1;
  final String phoneme2;
  final String word1Meaning;
  final String word2Meaning;

  const MinimalPair({
    required this.word1,
    required this.word2,
    required this.phoneme1,
    required this.phoneme2,
    required this.word1Meaning,
    required this.word2Meaning,
  });
}
