import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/progress_provider.dart';
import '../../../v2/application/providers/v2_providers.dart';
import '../../../v2/domain/models/course_models.dart';
import '../widgets/daily_widgets.dart';

class LearnPathScreen extends ConsumerWidget {
  const LearnPathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(v2PrimaryTrackProvider);
    final progress = ref.watch(progressProvider);
    final current = _currentUnit(track, progress.completedLessons);

    return DailyPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '开口路径',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            '一次只打开当前这一站。做完这一单元，下一站才会亮。',
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),
          if (current == null)
            DailyEmptyState(
              title: '主线暂时走完了',
              message: '当前版本的 10 个开口单元都完成了。去「开口」把弱项和场景再练一轮。',
              actionLabel: '去开口练习',
              onAction: () => context.go('/speaking'),
              icon: Icons.flag_rounded,
            )
          else
            DailyCard(
              color: AppColors.ink,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '现在学这个',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    current.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    current.description,
                    style: const TextStyle(color: Colors.white70, height: 1.45),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    key: const ValueKey('learn-start-lesson'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.ink,
                    ),
                    onPressed: () {
                      final lesson = _nextLesson(
                        current,
                        progress.completedLessons,
                      );
                      if (lesson != null) {
                        context.push('/session?type=lesson&id=${lesson.id}');
                      }
                    },
                    child: const Text('继续这一站'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 28),
          const SectionLabel(title: '技能路径'),
          ...track.units.asMap().entries.map((entry) {
            final unit = entry.value;
            final status = _statusFor(
              track: track,
              unit: unit,
              completedLessons: progress.completedLessons,
              completedUnits: progress.completedUnits,
            );
            final doneCount = unit.lessons
                .where((lesson) => progress.completedLessons.contains(lesson.id))
                .length;
            return _PathNode(
              unit: unit,
              status: status,
              doneCount: doneCount,
              onPressed: status == _UnitStatus.locked
                  ? null
                  : () {
                      final lesson =
                          _nextLesson(unit, progress.completedLessons) ??
                          unit.lessons.firstOrNull;
                      if (lesson != null) {
                        context.push('/session?type=lesson&id=${lesson.id}');
                      }
                    },
            );
          }),
        ],
      ),
    );
  }

  UnitBlueprint? _currentUnit(CourseTrack track, Set<String> completedLessons) {
    for (final unit in track.units) {
      final unfinished = unit.lessons.any(
        (lesson) => !completedLessons.contains(lesson.id),
      );
      if (unfinished) {
        return unit;
      }
    }
    return null;
  }

  LessonBlueprint? _nextLesson(
    UnitBlueprint unit,
    Set<String> completedLessons,
  ) {
    for (final lesson in unit.lessons) {
      if (!completedLessons.contains(lesson.id)) {
        return lesson;
      }
    }
    return unit.lessons.firstOrNull;
  }

  _UnitStatus _statusFor({
    required CourseTrack track,
    required UnitBlueprint unit,
    required Set<String> completedLessons,
    required Set<String> completedUnits,
  }) {
    final allDone = unit.lessons.every(
      (lesson) => completedLessons.contains(lesson.id),
    );
    if (allDone || completedUnits.contains(unit.id)) {
      return _UnitStatus.done;
    }
    final index = track.units.indexWhere((item) => item.id == unit.id);
    if (index <= 0) {
      return _UnitStatus.current;
    }
    final previous = track.units[index - 1];
    final previousDone = previous.lessons.every(
      (lesson) => completedLessons.contains(lesson.id),
    );
    return previousDone ? _UnitStatus.current : _UnitStatus.locked;
  }
}

enum _UnitStatus { done, current, locked }

class _PathNode extends StatelessWidget {
  final UnitBlueprint unit;
  final _UnitStatus status;
  final int doneCount;
  final VoidCallback? onPressed;

  const _PathNode({
    required this.unit,
    required this.status,
    required this.doneCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      _UnitStatus.done => AppColors.successGreen,
      _UnitStatus.current => AppColors.primary,
      _UnitStatus.locked => AppColors.textHint,
    };
    final label = switch (status) {
      _UnitStatus.done => '已完成',
      _UnitStatus.current => '可开始',
      _UnitStatus.locked => '待解锁',
    };

    return Padding(
      padding: EdgeInsets.only(
        bottom: 10,
        left: unit.order.isEven ? 28 : 0,
        right: unit.order.isEven ? 0 : 28,
      ),
      child: DailyCard(
        onTap: onPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: color.withValues(alpha: 0.14),
                  child: Icon(
                    status == _UnitStatus.locked
                        ? Icons.lock_rounded
                        : Icons.graphic_eq_rounded,
                    color: color,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                DailyPill(label: label, color: color),
                const Spacer(),
                Text(
                  '$doneCount/${unit.lessons.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              unit.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              unit.subtitle,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: ValueKey('unit-cta-${unit.id}'),
              onPressed: onPressed,
              child: Text(
                status == _UnitStatus.locked ? '还没到这一站' : '开始练习',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
