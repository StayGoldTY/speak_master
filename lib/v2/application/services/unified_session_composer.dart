import '../../../models/user_progress.dart';
import '../../domain/models/learner_models.dart';
import '../../domain/models/learning_item.dart';

class UnifiedSessionComposer {
  const UnifiedSessionComposer();

  SessionPlan compose({
    required List<LearningItem> catalog,
    required UserProgress progress,
    required LearnerProfileV2 learner,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    final due = <LearningItem>[];
    final fresh = <LearningItem>[];

    for (final item in catalog) {
      final memory = progress.srsMemories[item.id];
      if (memory == null) {
        fresh.add(item);
      } else if (memory.isDueAt(timestamp)) {
        due.add(item);
      }
    }

    fresh.sort((a, b) {
      final byGoal = (a.matchesGoal(learner.goal) ? 0 : 1).compareTo(
        b.matchesGoal(learner.goal) ? 0 : 1,
      );
      if (byGoal != 0) {
        return byGoal;
      }
      return a.track.index.compareTo(b.track.index);
    });

    due.sort((a, b) {
      final aDue = progress.srsMemories[a.id]!.dueAt;
      final bDue = progress.srsMemories[b.id]!.dueAt;
      return aDue.compareTo(bDue);
    });

    final budget = _cardBudget(learner.dailyMinutes);
    final maxNew = learner.dailyMinutes <= 10
        ? 3
        : learner.dailyMinutes <= 15
        ? 4
        : 6;
    final dueTake = due.take(budget).toList();
    final remaining = budget - dueTake.length;
    final newTake = remaining <= 0
        ? const <LearningItem>[]
        : _preferCurrentLesson(
            fresh,
            progress,
          ).take(remaining < maxNew ? remaining : maxNew).toList();

    final queue = [..._interleave(dueTake), ..._interleave(newTake)];

    return SessionPlan(
      items: queue,
      dueCount: dueTake.length,
      newCount: newTake.length,
      headline: '${learner.displayName.trim()}的今日循环',
      subtitle: dueTake.isEmpty
          ? '先学一点点新内容，词汇、语法和开口交错进行；成功提取后会排到明天，让睡眠帮忙巩固。'
          : '先提取到期复习（${dueTake.length}），再加入 ${newTake.length} 个新项目。到期项优先，避免只往前赶新课。',
      estimatedMinutes: _estimateMinutes(queue.length, learner.dailyMinutes),
    );
  }

  List<LearningItem> _preferCurrentLesson(
    List<LearningItem> fresh,
    UserProgress progress,
  ) {
    final related = <LearningItem>[];
    final rest = <LearningItem>[];
    for (final item in fresh) {
      final tiedToCompleted = item.sourceLessonIds.any(
        progress.completedLessons.contains,
      );
      if (tiedToCompleted) {
        related.add(item);
      } else {
        rest.add(item);
      }
    }
    return [...related, ...rest];
  }

  List<LearningItem> _interleave(List<LearningItem> source) {
    final buckets = <SkillTrack, List<LearningItem>>{
      SkillTrack.vocabulary: [],
      SkillTrack.grammar: [],
      SkillTrack.speaking: [],
    };
    for (final item in source) {
      buckets[item.track]!.add(item);
    }

    final order = [
      SkillTrack.vocabulary,
      SkillTrack.grammar,
      SkillTrack.speaking,
    ];
    final mixed = <LearningItem>[];
    var added = true;
    while (added) {
      added = false;
      for (final track in order) {
        final bucket = buckets[track]!;
        if (bucket.isNotEmpty) {
          mixed.add(bucket.removeAt(0));
          added = true;
        }
      }
    }
    return mixed;
  }

  int _cardBudget(int dailyMinutes) {
    final estimated = (dailyMinutes / 1.8).round();
    if (estimated < 6) {
      return 6;
    }
    if (estimated > 16) {
      return 16;
    }
    return estimated;
  }

  int _estimateMinutes(int cardCount, int dailyMinutes) {
    final minutes = (cardCount * 1.6).round();
    if (minutes < 6) {
      return 6;
    }
    if (minutes > dailyMinutes) {
      return dailyMinutes;
    }
    return minutes;
  }
}
