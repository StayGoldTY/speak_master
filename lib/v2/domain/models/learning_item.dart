import '../../../models/srs_memory.dart';
import 'course_models.dart';
import 'learner_models.dart';

enum SkillTrack { vocabulary, grammar, speaking }

extension SkillTrackX on SkillTrack {
  String get key => name;

  String get label => switch (this) {
    SkillTrack.vocabulary => '词汇',
    SkillTrack.grammar => '语法',
    SkillTrack.speaking => '开口',
  };

  String get loopHint => switch (this) {
    SkillTrack.vocabulary => '先提取意义，再放回句子里。',
    SkillTrack.grammar => '先注意到形式，再用同一场景说出来。',
    SkillTrack.speaking => '发音是动作记忆：短、分散、带反馈。',
  };

  static SkillTrack fromKey(String? value) {
    return SkillTrack.values.firstWhere(
      (item) => item.key == value,
      orElse: () => SkillTrack.vocabulary,
    );
  }
}

enum LearningItemKind {
  retrieveMeaning,
  generateEnglish,
  grammarNotice,
  grammarProduce,
  speakingMotor,
}

extension LearningItemKindX on LearningItemKind {
  String get key => name;

  String get label => switch (this) {
    LearningItemKind.retrieveMeaning => '提取词义',
    LearningItemKind.generateEnglish => '主动产出',
    LearningItemKind.grammarNotice => '形式注意',
    LearningItemKind.grammarProduce => '句型产出',
    LearningItemKind.speakingMotor => '开口动作',
  };

  static LearningItemKind fromKey(String? value) {
    return LearningItemKind.values.firstWhere(
      (item) => item.key == value,
      orElse: () => LearningItemKind.retrieveMeaning,
    );
  }
}

class LearningItem {
  final String id;
  final SkillTrack track;
  final LearningItemKind kind;
  final String title;
  final String cue;
  final String target;
  final String contextSentence;
  final String contextCueZh;
  final String explanation;
  final String? morphologyNote;
  final String? dualCodeHint;
  final String? speakingPromptId;
  final List<String> sourceLessonIds;
  final List<LearningGoal> goals;
  final List<ChoiceOption> options;
  final String? correctOptionId;
  final List<String> acceptedAnswers;

  const LearningItem({
    required this.id,
    required this.track,
    required this.kind,
    required this.title,
    required this.cue,
    required this.target,
    required this.contextSentence,
    required this.contextCueZh,
    required this.explanation,
    this.morphologyNote,
    this.dualCodeHint,
    this.speakingPromptId,
    this.sourceLessonIds = const [],
    this.goals = const [],
    this.options = const [],
    this.correctOptionId,
    this.acceptedAnswers = const [],
  });

  bool matchesGoal(LearningGoal goal) {
    return goals.isEmpty || goals.contains(goal);
  }

  bool matchesInput(String raw) {
    final normalized = _normalize(raw);
    if (normalized.isEmpty) {
      return false;
    }

    final candidates = <String>{
      _normalize(target),
      ...acceptedAnswers.map(_normalize),
    };

    for (final candidate in candidates) {
      if (candidate.isEmpty) {
        continue;
      }
      if (normalized == candidate) {
        return true;
      }
      if (candidate.split(' ').every(normalized.contains) &&
          normalized.length + 8 >= candidate.length) {
        return true;
      }
    }
    return false;
  }

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9\u4e00-\u9fff\s]"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class SessionPlan {
  final List<LearningItem> items;
  final int dueCount;
  final int newCount;
  final String headline;
  final String subtitle;
  final int estimatedMinutes;

  const SessionPlan({
    required this.items,
    required this.dueCount,
    required this.newCount,
    required this.headline,
    required this.subtitle,
    required this.estimatedMinutes,
  });

  bool get isEmpty => items.isEmpty;
}

class SrsOutcome {
  final SrsMemory memory;
  final RecallGrade grade;
  final String dueLabel;
  final bool sameSessionRetry;
  final String teacherNote;

  const SrsOutcome({
    required this.memory,
    required this.grade,
    required this.dueLabel,
    required this.sameSessionRetry,
    required this.teacherNote,
  });
}
