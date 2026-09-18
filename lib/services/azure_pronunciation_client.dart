import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../core/constants/env_config.dart';

class AzurePronunciationPhoneme {
  final String phoneme;
  final double accuracyScore;
  final String? spokenPhoneme;

  const AzurePronunciationPhoneme({
    required this.phoneme,
    required this.accuracyScore,
    this.spokenPhoneme,
  });
}

class AzurePronunciationWord {
  final String word;
  final double? accuracyScore;
  final String errorType;
  final List<AzurePronunciationPhoneme> phonemes;

  const AzurePronunciationWord({
    required this.word,
    required this.errorType,
    this.accuracyScore,
    this.phonemes = const [],
  });

  bool get isOmission => errorType.toLowerCase() == 'omission';

  bool get isInsertion => errorType.toLowerCase() == 'insertion';

  bool get isMispronunciation =>
      errorType.toLowerCase() == 'mispronunciation';

  bool get isWeak {
    if (isOmission || isMispronunciation) {
      return true;
    }
    final score = accuracyScore;
    return score != null && score < 70;
  }
}

class AzurePronunciationAssessment {
  final String recognizedText;
  final double accuracyScore;
  final double fluencyScore;
  final double completenessScore;
  final double pronScore;
  final List<AzurePronunciationWord> words;
  final String locale;

  const AzurePronunciationAssessment({
    required this.recognizedText,
    required this.accuracyScore,
    required this.fluencyScore,
    required this.completenessScore,
    required this.pronScore,
    required this.words,
    required this.locale,
  });

  List<AzurePronunciationWord> get weakWords =>
      words.where((word) => word.isWeak).toList();

  List<AzurePronunciationPhoneme> get weakPhonemes {
    final issues = <AzurePronunciationPhoneme>[];
    for (final word in words) {
      for (final phoneme in word.phonemes) {
        if (phoneme.accuracyScore < 60) {
          issues.add(phoneme);
        }
      }
    }
    return issues;
  }

  Map<String, dynamic> toMap() {
    return {
      'recognizedText': recognizedText,
      'accuracyScore': accuracyScore,
      'fluencyScore': fluencyScore,
      'completenessScore': completenessScore,
      'pronScore': pronScore,
      'locale': locale,
      'words': words
          .map(
            (word) => {
              'word': word.word,
              'accuracyScore': word.accuracyScore,
              'errorType': word.errorType,
              'phonemes': word.phonemes
                  .map(
                    (phoneme) => {
                      'phoneme': phoneme.phoneme,
                      'accuracyScore': phoneme.accuracyScore,
                      'spokenPhoneme': phoneme.spokenPhoneme,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
    };
  }

  static AzurePronunciationAssessment? tryParse(
    Map<String, dynamic> payload, {
    required String locale,
  }) {
    return AzurePronunciationParser.parse(payload, locale: locale);
  }
}

class AzurePronunciationParser {
  const AzurePronunciationParser();

  static AzurePronunciationAssessment? parse(
    Map<String, dynamic> payload, {
    required String locale,
  }) {
    final nBest = payload['NBest'];
    Map<String, dynamic>? best;
    if (nBest is List && nBest.isNotEmpty && nBest.first is Map) {
      best = Map<String, dynamic>.from(nBest.first as Map);
    }

    final displayText =
        payload['DisplayText']?.toString() ??
        best?['Display']?.toString() ??
        '';
    final assessmentRaw = best?['PronunciationAssessment'];
    if (assessmentRaw is! Map) {
      return null;
    }

    final assessment = Map<String, dynamic>.from(assessmentRaw);
    final wordsRaw = best?['Words'];
    final words = <AzurePronunciationWord>[];
    if (wordsRaw is List) {
      for (final item in wordsRaw) {
        if (item is! Map) {
          continue;
        }
        words.add(_parseWord(Map<String, dynamic>.from(item)));
      }
    }

    return AzurePronunciationAssessment(
      recognizedText: displayText.trim(),
      accuracyScore: _asDouble(assessment['AccuracyScore']),
      fluencyScore: _asDouble(assessment['FluencyScore']),
      completenessScore: _asDouble(assessment['CompletenessScore']),
      pronScore: _asDouble(
        assessment['PronScore'] ?? assessment['AccuracyScore'],
      ),
      words: words,
      locale: locale,
    );
  }

  static AzurePronunciationWord _parseWord(Map<String, dynamic> raw) {
    final assessmentRaw = raw['PronunciationAssessment'];
    final assessment = assessmentRaw is Map
        ? Map<String, dynamic>.from(assessmentRaw)
        : const <String, dynamic>{};
    final phonemesRaw = raw['Phonemes'];
    final phonemes = <AzurePronunciationPhoneme>[];
    if (phonemesRaw is List) {
      for (final item in phonemesRaw) {
        if (item is! Map) {
          continue;
        }
        phonemes.add(_parsePhoneme(Map<String, dynamic>.from(item)));
      }
    }

    return AzurePronunciationWord(
      word: raw['Word']?.toString() ?? '',
      accuracyScore: assessment['AccuracyScore'] == null
          ? null
          : _asDouble(assessment['AccuracyScore']),
      errorType: assessment['ErrorType']?.toString() ?? 'None',
      phonemes: phonemes,
    );
  }

  static AzurePronunciationPhoneme _parsePhoneme(Map<String, dynamic> raw) {
    final assessmentRaw = raw['PronunciationAssessment'];
    final assessment = assessmentRaw is Map
        ? Map<String, dynamic>.from(assessmentRaw)
        : const <String, dynamic>{};
    String? spoken;
    final nBest = assessment['NBestPhonemes'];
    if (nBest is List && nBest.isNotEmpty && nBest.first is Map) {
      spoken = (nBest.first as Map)['Phoneme']?.toString();
    }

    return AzurePronunciationPhoneme(
      phoneme: raw['Phoneme']?.toString() ?? '',
      accuracyScore: _asDouble(assessment['AccuracyScore']),
      spokenPhoneme: spoken,
    );
  }

  static double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class AzurePronunciationClient {
  final http.Client _httpClient;
  final String _key;
  final String _region;
  final bool _ownsClient;

  AzurePronunciationClient({
    required String key,
    required String region,
    http.Client? httpClient,
  }) : _key = key.trim(),
       _region = region.trim(),
       _httpClient = httpClient ?? http.Client(),
       _ownsClient = httpClient == null;

  factory AzurePronunciationClient.fromEnv({http.Client? httpClient}) {
    return AzurePronunciationClient(
      key: EnvConfig.azureSpeechKey,
      region: EnvConfig.azureSpeechRegion,
      httpClient: httpClient,
    );
  }

  bool get isConfigured => _key.isNotEmpty && _region.isNotEmpty;

  bool supportsMimeType(String mimeType) {
    final normalized = mimeType.toLowerCase();
    if (normalized.contains('webm')) {
      return false;
    }
    return normalized.contains('wav') ||
        normalized.contains('pcm') ||
        ((normalized.contains('ogg') || normalized.contains('opus')) &&
            !normalized.contains('webm'));
  }

  String? contentTypeForMime(String mimeType) {
    final normalized = mimeType.toLowerCase();
    if (normalized.contains('wav') || normalized.contains('pcm')) {
      return 'audio/wav; codecs=audio/pcm; samplerate=16000';
    }
    if ((normalized.contains('ogg') || normalized.contains('opus')) &&
        !normalized.contains('webm')) {
      return 'audio/ogg; codecs=opus';
    }
    return null;
  }

  Future<AzurePronunciationAssessment?> assess({
    required Uint8List audioBytes,
    required String mimeType,
    required String referenceText,
    required String locale,
  }) async {
    if (!isConfigured || audioBytes.isEmpty || referenceText.trim().isEmpty) {
      return null;
    }

    final contentType = contentTypeForMime(mimeType);
    if (contentType == null) {
      return null;
    }

    final params = jsonEncode({
      'ReferenceText': referenceText.trim(),
      'GradingSystem': 'HundredMark',
      'Granularity': 'Phoneme',
      'Dimension': 'Comprehensive',
      'EnableMiscue': 'True',
      'EnableProsodyAssessment': 'True',
      'PhonemeAlphabet': 'IPA',
      'NBestPhonemeCount': '3',
    });
    final header = base64Encode(utf8.encode(params));
    final uri = Uri.parse(
      'https://$_region.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1',
    ).replace(queryParameters: {'language': locale, 'format': 'detailed'});

    final response = await _httpClient.post(
      uri,
      headers: {
        'Ocp-Apim-Subscription-Key': _key,
        'Content-Type': contentType,
        'Accept': 'application/json',
        'Pronunciation-Assessment': header,
      },
      body: audioBytes,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      return null;
    }

    return AzurePronunciationParser.parse(
      Map<String, dynamic>.from(decoded),
      locale: locale,
    );
  }

  void close() {
    if (_ownsClient) {
      _httpClient.close();
    }
  }
}
