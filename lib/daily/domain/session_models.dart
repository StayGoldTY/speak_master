import '../../v2/domain/models/course_models.dart';
import 'word_aligner.dart';

enum SessionKind { lesson, prompt, review, sound }

enum SessionStepKind { tip, listenSpeak, multipleChoice, minimalPair }

class SessionStep {
  final String id;
  final SessionStepKind kind;
  final String title;
  final String instruction;
  final String prompt;
  final String hint;
  final List<String> focusWords;
  final List<ChoiceOption> options;
  final String? correctOptionId;
  final List<MinimalPairExample> pairs;

  const SessionStep({
    required this.id,
    required this.kind,
    required this.title,
    required this.instruction,
    this.prompt = '',
    this.hint = '',
    this.focusWords = const [],
    this.options = const [],
    this.correctOptionId,
    this.pairs = const [],
  });

  bool get hasSpeakablePrompt => prompt.trim().isNotEmpty;
}

class SessionBlueprint {
  final String id;
  final SessionKind kind;
  final String title;
  final String subtitle;
  final String? lessonId;
  final String? promptId;
  final String? dailyTaskId;
  final List<SessionStep> steps;

  const SessionBlueprint({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.steps,
    this.lessonId,
    this.promptId,
    this.dailyTaskId,
  });
}

class SessionAlignment {
  final List<AlignedWord> words;
  final String transcript;
  final String honestyNote;

  const SessionAlignment({
    required this.words,
    required this.transcript,
    required this.honestyNote,
  });

  int get hitCount =>
      words.where((word) => word.status == WordAlignStatus.hit).length;

  int get totalCount => words.length;

  String get summary {
    if (transcript.trim().isEmpty) {
      return '没有识别到有效英文。这不是声学评分。';
    }
    return '识别对齐到 $hitCount / $totalCount 个词。这不是声学评分。';
  }
}

enum JourneyBand { starter, elementary, intermediate, confident }

extension JourneyBandX on JourneyBand {
  String get title => switch (this) {
    JourneyBand.starter => '起步',
    JourneyBand.elementary => '入门',
    JourneyBand.intermediate => '进阶',
    JourneyBand.confident => '稳定开口',
  };

  String get nextTitle => switch (this) {
    JourneyBand.starter => JourneyBand.elementary.title,
    JourneyBand.elementary => JourneyBand.intermediate.title,
    JourneyBand.intermediate => JourneyBand.confident.title,
    JourneyBand.confident => '保持输出',
  };
}

class JourneySnapshot {
  final JourneyBand band;
  final double progressToNext;
  final int completedLessons;
  final int totalLessons;
  final int recommendedMinutes;
  final String summary;

  const JourneySnapshot({
    required this.band,
    required this.progressToNext,
    required this.completedLessons,
    required this.totalLessons,
    required this.recommendedMinutes,
    required this.summary,
  });
}

class DailyLoopState {
  final String dateKey;
  final Set<String> completedTaskIds;

  const DailyLoopState({required this.dateKey, required this.completedTaskIds});

  int get doneCount => completedTaskIds.length;

  bool isDone(String taskId) => completedTaskIds.contains(taskId);

  DailyLoopState copyWith({String? dateKey, Set<String>? completedTaskIds}) {
    return DailyLoopState(
      dateKey: dateKey ?? this.dateKey,
      completedTaskIds: completedTaskIds ?? this.completedTaskIds,
    );
  }
}

class PracticeLogEntry {
  final String id;
  final String title;
  final String source;
  final int alignedHits;
  final int alignedTotal;
  final DateTime createdAt;

  const PracticeLogEntry({
    required this.id,
    required this.title,
    required this.source,
    required this.alignedHits,
    required this.alignedTotal,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'source': source,
      'alignedHits': alignedHits,
      'alignedTotal': alignedTotal,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PracticeLogEntry.fromJson(Map<String, dynamic> json) {
    return PracticeLogEntry(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      alignedHits: (json['alignedHits'] as num?)?.toInt() ?? 0,
      alignedTotal: (json['alignedTotal'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
