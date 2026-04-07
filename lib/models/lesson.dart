enum LessonType {
  theory,
  listen,
  practice,
  discrimination,
  game,
}

enum LessonStatus { locked, available, completed }

class Lesson {
  final String id;
  final String unitId;
  final int order;
  final String titleCn;
  final String titleEn;
  final String description;
  final LessonType type;
  final int estimatedMinutes;
  final List<LessonStep> steps;
  final String? didYouKnowText;
  final String? didYouKnowSource;

  const Lesson({
    required this.id,
    required this.unitId,
    required this.order,
    required this.titleCn,
    required this.titleEn,
    required this.description,
    required this.type,
    this.estimatedMinutes = 5,
    required this.steps,
    this.didYouKnowText,
    this.didYouKnowSource,
  });
}

enum StepType {
  text,
  animation,
  audio,
  recordAndCompare,
  minimalPairQuiz,
  dragAndDrop,
  multipleChoice,
  readAloud,
}

class LessonStep {
  final String id;
  final StepType type;
  final String instruction;
  final String? content;
  final String? audioAsset;
  final String? targetPhoneme;
  final Map<String, dynamic>? metadata;

  const LessonStep({
    required this.id,
    required this.type,
    required this.instruction,
    this.content,
    this.audioAsset,
    this.targetPhoneme,
    this.metadata,
  });
}
