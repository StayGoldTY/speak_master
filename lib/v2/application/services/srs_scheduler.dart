import '../../../models/srs_memory.dart';
import '../../domain/models/learning_item.dart';

/// SM-2 style scheduler (SuperMemo 2 / Anki family).
///
/// First successful recall is due the next local morning so overnight
/// consolidation can happen. Failures are not restudied immediately:
/// they return later in the same session, then about 10 minutes later.
class SrsScheduler {
  static const minEase = 1.3;
  static const defaultEase = 2.5;
  static const againGap = Duration(minutes: 10);

  const SrsScheduler();

  SrsMemory fresh(String itemId, {DateTime? now}) {
    final timestamp = now ?? DateTime.now();
    return SrsMemory(itemId: itemId, ease: defaultEase, dueAt: timestamp);
  }

  SrsOutcome review({
    required SrsMemory memory,
    required RecallGrade grade,
    required SkillTrack track,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    var ease = memory.ease;
    var repetitions = memory.repetitions;
    var intervalDays = memory.intervalDays;
    var lapses = memory.lapses;
    var sameSessionRetry = false;
    late DateTime dueAt;

    switch (grade) {
      case RecallGrade.again:
        repetitions = 0;
        intervalDays = 0;
        lapses += 1;
        ease = _clampEase(ease - 0.2);
        dueAt = timestamp.add(againGap);
        sameSessionRetry = true;
      case RecallGrade.hard:
        ease = _clampEase(ease - 0.15);
        if (repetitions == 0) {
          repetitions = 1;
          intervalDays = 1;
        } else {
          intervalDays = _atLeastOne((intervalDays * 1.2).round());
          repetitions += 1;
        }
        dueAt = _dueAfterDays(timestamp, _scaleInterval(intervalDays, track));
      case RecallGrade.good:
        ease = _clampEase(ease);
        if (repetitions == 0) {
          repetitions = 1;
          intervalDays = 1;
        } else if (repetitions == 1) {
          repetitions = 2;
          intervalDays = track == SkillTrack.speaking ? 3 : 6;
        } else {
          repetitions += 1;
          intervalDays = _atLeastOne((intervalDays * ease).round());
        }
        dueAt = _dueAfterDays(timestamp, _scaleInterval(intervalDays, track));
      case RecallGrade.easy:
        ease = _clampEase(ease + 0.15);
        if (repetitions == 0) {
          repetitions = 1;
          intervalDays = 3;
        } else if (repetitions == 1) {
          repetitions = 2;
          intervalDays = track == SkillTrack.speaking ? 4 : 8;
        } else {
          repetitions += 1;
          intervalDays = _atLeastOne((intervalDays * ease * 1.3).round());
        }
        dueAt = _dueAfterDays(timestamp, _scaleInterval(intervalDays, track));
    }

    final updated = memory.copyWith(
      repetitions: repetitions,
      ease: ease,
      intervalDays: intervalDays,
      dueAt: dueAt,
      lastReviewedAt: timestamp,
      lapses: lapses,
      lastGradeKey: grade.key,
    );

    return SrsOutcome(
      memory: updated,
      grade: grade,
      dueLabel: formatDue(dueAt, timestamp),
      sameSessionRetry: sameSessionRetry,
      teacherNote: _teacherNote(
        grade: grade,
        track: track,
        dueLabel: formatDue(dueAt, timestamp),
      ),
    );
  }

  SrsOutcome preview({
    required SrsMemory memory,
    required RecallGrade grade,
    required SkillTrack track,
    DateTime? now,
  }) {
    return review(memory: memory, grade: grade, track: track, now: now);
  }

  static RecallGrade gradeFromCoverage(double coverage) {
    if (coverage < 0.56) {
      return RecallGrade.again;
    }
    if (coverage < 0.82) {
      return RecallGrade.hard;
    }
    return RecallGrade.good;
  }

  /// Azure PronScore/Accuracy is 0-100. Coverage-only paths leave
  /// [acousticScore] null so we never treat recognition overlap as pronunciation.
  static RecallGrade gradeFromPronunciation({
    required double coverage,
    double? acousticScore,
  }) {
    final score = acousticScore;
    if (score == null) {
      return gradeFromCoverage(coverage);
    }
    if (score < 60) {
      return RecallGrade.again;
    }
    if (score < 80) {
      return RecallGrade.hard;
    }
    return RecallGrade.good;
  }

  String formatDue(DateTime dueAt, DateTime now) {
    if (dueAt.difference(now) <= const Duration(minutes: 45) &&
        _isSameDay(dueAt, now)) {
      return '本轮稍后 / 约 10 分钟';
    }

    final startTomorrow = _startOfNextMorning(now);
    if (!_isAfterDay(dueAt, startTomorrow) &&
        !dueAt.isBefore(startTomorrow.subtract(const Duration(hours: 6)))) {
      return '明天（睡眠巩固）';
    }

    final days = dueAt.difference(_startOfLocalDay(now)).inDays;
    if (days <= 1) {
      return '明天';
    }
    if (days < 7) {
      return '$days 天后';
    }
    if (days < 30) {
      final weeks = (days / 7).round().clamp(1, 4);
      return '约 $weeks 周后';
    }
    final months = (days / 30).round().clamp(1, 18);
    return '约 $months 个月后';
  }

  double _clampEase(double value) => value < minEase ? minEase : value;

  int _atLeastOne(int value) => value < 1 ? 1 : value;

  int _scaleInterval(int days, SkillTrack track) {
    if (track != SkillTrack.speaking || days <= 1) {
      return days;
    }
    return _atLeastOne((days * 0.75).round());
  }

  DateTime _dueAfterDays(DateTime now, int days) {
    final targetDay = _startOfLocalDay(now).add(Duration(days: days));
    return DateTime(targetDay.year, targetDay.month, targetDay.day, 4);
  }

  DateTime _startOfLocalDay(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  DateTime _startOfNextMorning(DateTime now) {
    final next = _startOfLocalDay(now).add(const Duration(days: 1));
    return DateTime(next.year, next.month, next.day, 4);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isAfterDay(DateTime dueAt, DateTime morning) {
    return dueAt.isAfter(morning.add(const Duration(hours: 20)));
  }

  String _teacherNote({
    required RecallGrade grade,
    required SkillTrack track,
    required String dueLabel,
  }) {
    return switch (grade) {
      RecallGrade.again => '这次没提取出来很正常。隔几张再试，而不是立刻重来。下次：$dueLabel。',
      RecallGrade.hard => '提取成功但还费力。${track.loopHint}下次：$dueLabel。',
      RecallGrade.good => '提取成功。下次：$dueLabel。间隔拉长，是为了让遗忘刚好发生在复习前。',
      RecallGrade.easy => '很稳。下次：$dueLabel。仍会和其他技能交错，避免只刷会的。',
    };
  }
}
