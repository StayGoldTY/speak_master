import 'package:flutter_test/flutter_test.dart';
import 'package:speak_master/services/azure_pronunciation_client.dart';

void main() {
  test('parses Azure phoneme-level pronunciation JSON', () {
    const locale = 'en-US';
    final assessment = AzurePronunciationParser.parse(
      {
        'RecognitionStatus': 'Success',
        'DisplayText': 'Can I get a large latte please.',
        'NBest': [
          {
            'Display': 'Can I get a large latte please.',
            'PronunciationAssessment': {
              'AccuracyScore': 78.4,
              'FluencyScore': 81.0,
              'CompletenessScore': 92.0,
              'PronScore': 80.2,
            },
            'Words': [
              {
                'Word': 'latte',
                'PronunciationAssessment': {
                  'AccuracyScore': 54.0,
                  'ErrorType': 'Mispronunciation',
                },
                'Phonemes': [
                  {
                    'Phoneme': 'æ',
                    'PronunciationAssessment': {
                      'AccuracyScore': 42.0,
                      'NBestPhonemes': [
                        {'Phoneme': 'ɑ', 'Score': 61.0},
                      ],
                    },
                  },
                ],
              },
              {
                'Word': 'please',
                'PronunciationAssessment': {
                  'AccuracyScore': 88.0,
                  'ErrorType': 'None',
                },
                'Phonemes': const [],
              },
            ],
          },
        ],
      },
      locale: locale,
    );

    expect(assessment, isNotNull);
    expect(assessment!.pronScore, closeTo(80.2, 0.01));
    expect(assessment.weakWords.map((item) => item.word), contains('latte'));
    expect(assessment.words.first.phonemes.first.spokenPhoneme, 'ɑ');
    expect(assessment.weakPhonemes, isNotEmpty);
  });

  test('rejects webm because Azure short-audio REST does not accept it', () {
    final client = AzurePronunciationClient(key: 'demo', region: 'eastasia');
    expect(client.supportsMimeType('audio/webm'), isFalse);
    expect(client.supportsMimeType('audio/wav'), isTrue);
    expect(client.contentTypeForMime('audio/webm'), isNull);
  });
}
