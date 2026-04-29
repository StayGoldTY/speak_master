import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/progress_provider.dart';
import '../../application/providers/v2_providers.dart';
import '../../domain/models/course_models.dart';
import '../widgets/activity_blueprint_view.dart';
import '../widgets/v2_page_scaffold.dart';

class LessonPlayerScreen extends ConsumerStatefulWidget {
  final String lessonId;

  const LessonPlayerScreen({super.key, required this.lessonId});

  @override
  ConsumerState<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends ConsumerState<LessonPlayerScreen> {
  final Set<String> _completedActivities = <String>{};
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final lesson = ref.watch(v2LessonProvider(widget.lessonId));
    final track = ref.watch(v2PrimaryTrackProvider);
    final progress = ref.watch(progressProvider);

    if (lesson == null) {
      return const Scaffold(
        body: SafeArea(child: Center(child: Text('没有找到这节课程。'))),
      );
    }

    final unit = track.units
        .where((item) => item.id == lesson.unitId)
        .firstOrNull;
    final unitLessons = unit?.lessons ?? const <LessonBlueprint>[];
    final lessonIndex = unitLessons.indexWhere((item) => item.id == lesson.id);
    final completedCount = _completedActivities.length;
    final totalCount = lesson.activities.length;
    final activityProgress = totalCount == 0
        ? 1.0
        : completedCount / totalCount;
    final lessonCompleted = progress.completedLessons.contains(lesson.id);
    final nextLesson = _findNextLesson(track, lesson);
    final allActivitiesDone = completedCount >= totalCount;
    final canFinishLesson =
        !lessonCompleted && allActivitiesDone && !_submitting;

    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: V2PageScaffold(
        title: lesson.title,
        subtitle: lesson.description,
        actions: [
          V2Pill(label: lesson.subtitle, color: AppColors.primary),
          V2Pill(
            label: '${lesson.estimatedMinutes} 分钟',
            color: AppColors.secondary,
          ),
          V2Pill(
            label: lessonCompleted ? '已完成' : '进行中',
            color: lessonCompleted
                ? AppColors.successGreen
                : AppColors.accentOrange,
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            V2InfoCard(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 720;
                  final content = [
                    _LessonMetric(
                      label: '活动进度',
                      value: '$completedCount / $totalCount',
                      helper: totalCount == 0 ? '已准备完成' : '完成所有活动后可结课',
                    ),
                    _LessonMetric(
                      label: '所在单元',
                      value: unit == null ? '未知单元' : '第 ${unit.order} 单元',
                      helper: unit?.title ?? '课程结构信息缺失',
                    ),
                    _LessonMetric(
                      label: '单元课次',
                      value: lessonIndex >= 0 ? '第 ${lessonIndex + 1} 节' : '课程',
                      helper: nextLesson == null ? '完成后将回到课程地图' : '完成后建议继续下一课',
                    ),
                  ];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lessonCompleted ? '本课已完成' : '按步骤完成这节课',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  lessonCompleted
                                      ? '你已经拿到本课进度，可以直接复习本页内容，或者继续进入下一节。'
                                      : '先看路线卡，再逐个完成活动。完成整课后会自动记录进度并累计 XP。',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!compact) ...[
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 220,
                              child: _ProgressSummary(
                                progress: activityProgress,
                                label: '$completedCount / $totalCount',
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (compact) ...[
                        const SizedBox(height: 18),
                        _ProgressSummary(
                          progress: activityProgress,
                          label: '$completedCount / $totalCount',
                        ),
                      ],
                      const SizedBox(height: 18),
                      Wrap(spacing: 12, runSpacing: 12, children: content),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const V2SectionTitle(
              title: '学习路线',
              subtitle: '每完成一个活动就勾选一次，形成清晰的完成反馈，而不是只看一堆内容。',
            ),
            ...lesson.activities.asMap().entries.map((entry) {
              final index = entry.key;
              final activity = entry.value;
              final isDone = _completedActivities.contains(activity.id);

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: V2InfoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color:
                                  (isDone
                                          ? AppColors.successGreen
                                          : AppColors.primary)
                                      .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: isDone
                                    ? AppColors.successGreen
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        activity.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    V2Pill(
                                      label: activity.kind.label,
                                      color: isDone
                                          ? AppColors.successGreen
                                          : AppColors.primary,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  activity.instruction,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ActivityBlueprintView(activity: activity),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          key: ValueKey('complete-activity-${activity.id}'),
                          onPressed: () {
                            setState(() {
                              if (isDone) {
                                _completedActivities.remove(activity.id);
                              } else {
                                _completedActivities.add(activity.id);
                              }
                            });
                          },
                          icon: Icon(
                            isDone
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                          ),
                          label: Text(isDone ? '已完成此活动' : '标记为已完成'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const V2SectionTitle(
              title: '单元内课程',
              subtitle: '学完本节后不要中断，继续主线才能真正形成留存。',
            ),
            V2InfoCard(
              child: Column(
                children: unitLessons.map((item) {
                  final isCurrent = item.id == lesson.id;
                  final isCompleted = progress.completedLessons.contains(
                    item.id,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: (isCurrent ? AppColors.primary : Colors.white)
                            .withValues(alpha: isCurrent ? 0.08 : 0.72),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color:
                              (isCompleted
                                      ? AppColors.successGreen
                                      : isCurrent
                                      ? AppColors.primary
                                      : AppColors.glassBorder)
                                  .withValues(alpha: 0.45),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCompleted
                                ? Icons.check_circle
                                : isCurrent
                                ? Icons.play_circle_fill_rounded
                                : Icons.menu_book_outlined,
                            color: isCompleted
                                ? AppColors.successGreen
                                : isCurrent
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.subtitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isCurrent)
                            TextButton(
                              onPressed: () =>
                                  context.push('/lesson/${item.id}'),
                              child: Text(isCompleted ? '复习' : '进入'),
                            )
                          else
                            const Text(
                              '当前课程',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            V2InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lessonCompleted ? '继续学习' : '完成本课',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lessonCompleted
                        ? '本课进度已经记录，建议继续下一课，保持主线连续。'
                        : allActivitiesDone
                        ? '所有活动都已完成，现在可以结课并记录到学习进度。'
                        : '还差 ${totalCount - completedCount} 个活动未完成，结课按钮会在全部勾选后解锁。',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        key: const ValueKey('finish-lesson-button'),
                        onPressed: canFinishLesson
                            ? () => _finishLesson(lesson, unitLessons)
                            : null,
                        icon: _submitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                lessonCompleted
                                    ? Icons.check_circle
                                    : Icons.emoji_events_rounded,
                              ),
                        label: Text(
                          lessonCompleted ? '本课已完成' : '完成本课并领取 10 XP',
                        ),
                      ),
                      if (nextLesson != null)
                        OutlinedButton.icon(
                          key: const ValueKey('next-lesson-button'),
                          onPressed: () =>
                              context.push('/lesson/${nextLesson.id}'),
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: Text('继续下一课：${nextLesson.title}'),
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: () => context.go('/learn'),
                          icon: const Icon(Icons.map_rounded),
                          label: const Text('返回课程地图'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finishLesson(
    LessonBlueprint lesson,
    List<LessonBlueprint> unitLessons,
  ) async {
    setState(() {
      _submitting = true;
    });

    try {
      final notifier = ref.read(progressProvider.notifier);
      await notifier.completeLesson(lesson.id);

      final updatedProgress = ref.read(progressProvider);
      final unitFullyCompleted =
          unitLessons.isNotEmpty &&
          unitLessons.every(
            (item) => updatedProgress.completedLessons.contains(item.id),
          );
      if (unitFullyCompleted) {
        await notifier.completeUnit(lesson.unitId);
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            unitFullyCompleted
                ? '已完成 ${lesson.title}，并解锁整单元完成记录。'
                : '已完成 ${lesson.title}，进度和 XP 已记录。',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  LessonBlueprint? _findNextLesson(CourseTrack track, LessonBlueprint lesson) {
    LessonBlueprint? firstLesson;
    var seenCurrent = false;

    for (final unit in track.units) {
      for (final item in unit.lessons) {
        firstLesson ??= item;
        if (seenCurrent) {
          return item;
        }
        if (item.id == lesson.id) {
          seenCurrent = true;
        }
      }
    }

    return seenCurrent ? null : firstLesson;
  }
}

class _ProgressSummary extends StatelessWidget {
  final double progress;
  final String label;

  const _ProgressSummary({required this.progress, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '本课完成度',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonMetric extends StatelessWidget {
  final String label;
  final String value;
  final String helper;

  const _LessonMetric({
    required this.label,
    required this.value,
    required this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 180),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.glassBorder.withValues(alpha: 0.56),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            helper,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
