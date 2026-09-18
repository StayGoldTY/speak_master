import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/progress_provider.dart';
import '../../application/providers/v2_providers.dart';
import '../../domain/models/course_models.dart';
import '../widgets/v2_page_scaffold.dart';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(v2PrimaryTrackProvider);
    final progress = ref.watch(progressProvider);
    final compact = MediaQuery.sizeOf(context).width < 760;

    final recommendedUnit = _recommendedUnit(track, progress.completedLessons);
    final recommendedLesson = recommendedUnit == null
        ? null
        : _nextLesson(recommendedUnit, progress.completedLessons) ??
              recommendedUnit.lessons.firstOrNull;
    final activeUnitIndex = _activeUnitIndex(track, progress.completedUnits);

    return V2PageScaffold(
      title: track.title,
      subtitle: track.subtitle,
      actions: const [
        V2Pill(label: '主线课程', color: AppColors.textSecondary),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          V2InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.description,
                  style: const TextStyle(
                    fontSize: 17,
                    color: AppColors.textSecondary,
                    height: 1.47,
                  ),
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 28,
                  runSpacing: 16,
                  children: [
                    V2SpecMetric(
                      label: '单元',
                      value: '${track.units.length}',
                    ),
                    V2SpecMetric(
                      label: '已完成',
                      value: '${progress.completedUnits.length}',
                    ),
                    V2SpecMetric(
                      label: '地图',
                      value: '按单元解锁',
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: compact ? 36 : 56),
          const V2SectionTitle(
            title: '当前推荐',
            subtitle: '学习页不只是课程列表，而是一个清晰的通关地图：告诉用户现在该学什么、后面为什么还没解锁。',
          ),
          V2InfoCard(
            child: recommendedUnit == null || recommendedLesson == null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '主线课程已全部完成',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '当前版本的主线已跑通，可以回到 Today 和 Speaking 继续做迁移输出与复盘。',
                        style: TextStyle(
                          fontSize: 17,
                          color: AppColors.textSecondary,
                          height: 1.47,
                        ),
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: () => context.push('/speaking'),
                        icon: const Icon(Icons.mic_rounded),
                        label: const Text('转入口语迁移'),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          V2Pill(
                            label: '第 ${recommendedUnit.order} 单元',
                            color: AppColors.textSecondary,
                          ),
                          const V2Pill(label: '可开始', color: AppColors.ink),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        recommendedLesson.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recommendedLesson.description,
                        style: const TextStyle(
                          fontSize: 17,
                          color: AppColors.textSecondary,
                          height: 1.47,
                        ),
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: () =>
                            context.push('/lesson/${recommendedLesson.id}'),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('开始当前推荐'),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 24,
                        runSpacing: 12,
                        children: [
                          V2SpecMetric(
                            label: '课次',
                            value: '${recommendedUnit.lessons.length} 节',
                          ),
                          V2SpecMetric(
                            label: '目标音',
                            value: recommendedUnit.targetPhonemes
                                .take(2)
                                .join(' · '),
                          ),
                          V2SpecMetric(
                            label: '时长',
                            value:
                                '${recommendedLesson.estimatedMinutes} 分钟',
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          SizedBox(height: compact ? 36 : 56),
          const V2SectionTitle(
            title: '课程单元',
            subtitle: '已完成的单元保留复习入口，当前单元直接开学，未来单元明确告诉用户为什么还没到。',
          ),
          ...track.units.asMap().entries.map((entry) {
            final index = entry.key;
            final unit = entry.value;
            final completedCount = unit.lessons
                .where(
                  (lesson) => progress.completedLessons.contains(lesson.id),
                )
                .length;
            final nextLesson =
                _nextLesson(unit, progress.completedLessons) ??
                unit.lessons.first;
            final progressValue = unit.lessons.isEmpty
                ? 0.0
                : completedCount / unit.lessons.length;
            final isLocked = index > activeUnitIndex;
            final status = _unitStatus(
              unit: unit,
              completedLessons: progress.completedLessons,
              completedUnits: progress.completedUnits,
              activeUnitIndex: activeUnitIndex,
              unitIndex: index,
            );
            final ctaLabel = isLocked
                ? '待解锁'
                : completedCount == 0
                ? '可开始'
                : progress.completedUnits.contains(unit.id)
                ? '复习单元'
                : '继续学习';

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: V2InfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    compact
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _UnitHeading(
                                unit: unit,
                                isLocked: isLocked,
                                status: status,
                                nextLesson: nextLesson,
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                key: ValueKey('unit-cta-${unit.id}'),
                                onPressed: isLocked
                                    ? null
                                    : () =>
                                          context.push('/lesson/${nextLesson.id}'),
                                child: Text(ctaLabel),
                              ),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _UnitHeading(
                                  unit: unit,
                                  isLocked: isLocked,
                                  status: status,
                                  nextLesson: nextLesson,
                                ),
                              ),
                              FilledButton(
                                key: ValueKey('unit-cta-${unit.id}'),
                                onPressed: isLocked
                                    ? null
                                    : () =>
                                          context.push('/lesson/${nextLesson.id}'),
                                child: Text(ctaLabel),
                              ),
                            ],
                          ),
                    const SizedBox(height: 16),
                    Text(
                      unit.description,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: progressValue,
                              minHeight: 4,
                              backgroundColor: AppColors.fillTertiary,
                              color: isLocked
                                  ? AppColors.textHint
                                  : AppColors.ink,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$completedCount/${unit.lessons.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        V2Pill(
                          label: '已完成 $completedCount 节',
                          color: AppColors.textSecondary,
                        ),
                        ...unit.targetPhonemes.take(4).map(
                          (item) => V2Pill(
                            label: item,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (isLocked) ...[
                      const SizedBox(height: 14),
                      const Text(
                        '完成前一个单元后自动解锁，避免用户在未建立关键发音动作前过早跳关。',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  UnitBlueprint? _recommendedUnit(
    CourseTrack track,
    Set<String> completedLessons,
  ) {
    for (final unit in track.units) {
      final next = _nextLesson(unit, completedLessons);
      if (next != null) {
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
    return null;
  }

  int _activeUnitIndex(CourseTrack track, Set<String> completedUnits) {
    for (var i = 0; i < track.units.length; i++) {
      if (!completedUnits.contains(track.units[i].id)) {
        return i;
      }
    }
    return track.units.isEmpty ? 0 : track.units.length - 1;
  }

  String _unitStatus({
    required UnitBlueprint unit,
    required Set<String> completedLessons,
    required Set<String> completedUnits,
    required int activeUnitIndex,
    required int unitIndex,
  }) {
    if (completedUnits.contains(unit.id)) {
      return '已完成';
    }
    if (unitIndex > activeUnitIndex) {
      return '待解锁';
    }
    final completedCount = unit.lessons
        .where((lesson) => completedLessons.contains(lesson.id))
        .length;
    if (completedCount == 0) {
      return '可开始';
    }
    return '进行中';
  }
}

class _UnitHeading extends StatelessWidget {
  final UnitBlueprint unit;
  final bool isLocked;
  final String status;
  final LessonBlueprint nextLesson;

  const _UnitHeading({
    required this.unit,
    required this.isLocked,
    required this.status,
    required this.nextLesson,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isLocked ? AppColors.fillTertiary : AppColors.ink,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: isLocked
              ? const Icon(Icons.lock_rounded, color: AppColors.textHint)
              : Text(
                  '${unit.order}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                unit.title,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                unit.subtitle,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  V2Pill(label: status, color: _statusColor(status)),
                  if (!isLocked)
                    V2Pill(
                      label: '下一课 ${nextLesson.title}',
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      '已完成' => AppColors.successGreen,
      '待解锁' => AppColors.textHint,
      '可开始' => AppColors.ink,
      _ => AppColors.primary,
    };
  }
}
