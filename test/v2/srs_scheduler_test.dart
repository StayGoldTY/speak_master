import 'package:flutter_test/flutter_test.dart';
import 'package:speak_master/models/srs_memory.dart';
import 'package:speak_master/v2/application/services/srs_scheduler.dart';
import 'package:speak_master/v2/domain/models/learning_item.dart';

void main() {
  const scheduler = SrsScheduler();
  final now = DateTime(2026, 9, 17, 9, 30);

  test('failed recall comes back later in the session, not immediately', () {
    final fresh = scheduler.fresh('vocab_1', now: now);
    final outcome = scheduler.review(
      memory: fresh,
      grade: RecallGrade.again,
      track: SkillTrack.vocabulary,
      now: now,
    );

    expect(outcome.sameSessionRetry, isTrue);
    expect(outcome.memory.repetitions, 0);
    expect(outcome.memory.lapses, 1);
    expect(outcome.memory.dueAt, now.add(const Duration(minutes: 10)));
    expect(outcome.dueLabel, contains('10'));
  });

  test('first successful recall is due the next morning', () {
    final fresh = scheduler.fresh('vocab_1', now: now);
    final outcome = scheduler.review(
      memory: fresh,
      grade: RecallGrade.good,
      track: SkillTrack.vocabulary,
      now: now,
    );

    expect(outcome.sameSessionRetry, isFalse);
    expect(outcome.memory.repetitions, 1);
    expect(outcome.memory.intervalDays, 1);
    expect(outcome.memory.dueAt, DateTime(2026, 9, 18, 4));
    expect(outcome.dueLabel, contains('明天'));
    expect(outcome.teacherNote, contains('睡眠'));
  });

  test('second successful vocabulary recall jumps to a multi-day gap', () {
    final first = scheduler.review(
      memory: scheduler.fresh('vocab_1', now: now),
      grade: RecallGrade.good,
      track: SkillTrack.vocabulary,
      now: now,
    );
    final second = scheduler.review(
      memory: first.memory,
      grade: RecallGrade.good,
      track: SkillTrack.vocabulary,
      now: DateTime(2026, 9, 18, 9),
    );

    expect(second.memory.intervalDays, 6);
  });

  test('speaking uses a shorter second interval than vocabulary', () {
    final first = scheduler.review(
      memory: scheduler.fresh('speak_1', now: now),
      grade: RecallGrade.good,
      track: SkillTrack.speaking,
      now: now,
    );
    final second = scheduler.review(
      memory: first.memory,
      grade: RecallGrade.good,
      track: SkillTrack.speaking,
      now: DateTime(2026, 9, 18, 9),
    );

    expect(second.memory.intervalDays, 3);
  });

  test('ease never drops below 1.3', () {
    var memory = scheduler.fresh('hard_1', now: now);
    for (var i = 0; i < 12; i++) {
      memory = scheduler
          .review(
            memory: memory,
            grade: RecallGrade.again,
            track: SkillTrack.grammar,
            now: now.add(Duration(minutes: i)),
          )
          .memory;
    }
    expect(memory.ease, greaterThanOrEqualTo(1.3));
  });
}
