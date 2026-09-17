import '../../../models/srs_memory.dart';
import '../../domain/models/learning_item.dart';
import '../../domain/models/speech_models.dart';
import '../../data/unified_learning_catalog.dart';
import 'srs_scheduler.dart';

class LearningLoopBridge {
  const LearningLoopBridge({this.scheduler = const SrsScheduler()});

  final SrsScheduler scheduler;

  List<SrsMemory> fromSpeakingFeedback({
    required Map<String, SrsMemory> existing,
    required String promptId,
    required SpeechFeedback feedback,
    DateTime? now,
    List<LearningItem> catalog = UnifiedLearningCatalog.items,
  }) {
    final timestamp = now ?? DateTime.now();
    final coverageGrade = SrsScheduler.gradeFromPronunciation(
      coverage: feedback.coverageScore,
      acousticScore: feedback.overallAcousticScore,
    );
    final updates = <String, SrsMemory>{};

    void apply(LearningItem item, RecallGrade grade) {
      final current =
          existing[item.id] ?? scheduler.fresh(item.id, now: timestamp);
      updates[item.id] = scheduler
          .review(
            memory: current,
            grade: grade,
            track: item.track,
            now: timestamp,
          )
          .memory;
    }

    for (final item in catalog) {
      if (item.speakingPromptId == promptId &&
          item.kind == LearningItemKind.speakingMotor) {
        apply(item, coverageGrade);
      }
    }

    final weak = feedback.weakWords.map((word) => word.toLowerCase()).toSet();
    if (weak.isEmpty) {
      return updates.values.toList();
    }

    for (final item in catalog) {
      if (item.speakingPromptId != promptId) {
        continue;
      }
      final haystack =
          '${item.title} ${item.target} ${item.cue} ${item.contextSentence}'
              .toLowerCase();
      final hit = weak.any(haystack.contains);
      if (hit && item.track != SkillTrack.speaking) {
        apply(item, RecallGrade.again);
      }
    }

    return updates.values.toList();
  }

  List<SrsMemory> unlockForLesson({
    required String lessonId,
    required Map<String, SrsMemory> existing,
    DateTime? now,
    List<LearningItem> catalog = UnifiedLearningCatalog.items,
  }) {
    final timestamp = now ?? DateTime.now();
    final unlocked = <SrsMemory>[];
    for (final item in catalog) {
      if (!item.sourceLessonIds.contains(lessonId)) {
        continue;
      }
      if (existing.containsKey(item.id)) {
        continue;
      }
      unlocked.add(scheduler.fresh(item.id, now: timestamp));
    }
    return unlocked;
  }
}
