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

    final recommendedUnit = _recommendedUnit(track, progress.completedLessons);
    final recommendedLesson = recommendedUnit == null
        ? null
        : _nextLesson(recommendedUnit, progress.completedLessons) ??
              recommendedUnit.lessons.firstOrNull;
    final activeUnitIndex = _activeUnitIndex(track, progress.completedUnits);

    return V2PageScaffold(
      title: track.title,
      subtitle: track.subtitle,
      actions: const [V2Pill(label: '主线课程', color: AppColors.primary)],
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
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    V2Pill(label: '课程地图', color: AppColors.primary),
                    V2Pill(
                      label: '共 ${track.units.length} 个单元',
                      color: AppColors.secondary,
                    ),
                    V2Pill(
                      label: '已完成 ${progress.completedUnits.length} 个单元',
                      color: AppColors.successGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '当前版本的主线已跑通，可以回到 Today 和 Speaking 继续做迁移输出与复盘。',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 16),
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
                            color: AppColors.primary,
                          ),
                          V2Pill(label: '可开始', color: AppColors.secondary),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        recommendedLesson.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        recommendedLesson.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _SummaryPill(
                            icon: Icons.menu_book_rounded,
                            label: '${recommendedUnit.lessons.length} 节课',
                          ),
                          _SummaryPill(
                            icon: Icons.tips_and_updates_rounded,
                            label: recommendedUnit.targetPhonemes
                                .take(2)
                                .join(' · '),
                          ),
                          _SummaryPill(
                            icon: Icons.schedule_rounded,
                            label: '${recommendedLesson.estimatedMinutes} 分钟',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () =>
                            context.push('/lesson/${recommendedLesson.id}'),
                        icon: const Icon(Icons.play_circle_fill_rounded),
                        label: const Text('开始当前推荐'),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 24),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: isLocked
                                ? LinearGradient(
                                    colors: [
                                      Colors.grey.shade300,
                                      Colors.grey.shade400,
                                    ],
                                  )
                                : AppColors.gradientPrimary,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          alignment: Alignment.center,
                          child: isLocked
                              ? const Icon(
                                  Icons.lock_rounded,
                                  color: Colors.white,
                                )
                              : Text(
                                  '${unit.order}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                unit.subtitle,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  V2Pill(
                                    label: status,
                                    color: _statusColor(status),
                                  ),
                                  if (!isLocked)
                                    V2Pill(
                                      label: '下一课 ${nextLesson.title}',
                                      color: AppColors.secondary,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        FilledButton(
                          key: ValueKey('unit-cta-${unit.id}'),
                          onPressed: isLocked
                              ? null
                              : () => context.push('/lesson/${nextLesson.id}'),
                          child: Text(ctaLabel),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      unit.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.65,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: progressValue,
                              minHeight: 8,
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.08,
                              ),
                              valueColor: AlwaysStoppedAnimation(
                                isLocked
                                    ? Colors.grey.shade400
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$completedCount/${unit.lessons.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
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
                          color: AppColors.secondary,
                        ),
                        ...unit.targetPhonemes
                            .take(4)
                            .map(
                              (item) => V2Pill(
                                label: item,
                                color: AppColors.accentOrange,
                              ),
                            ),
                      ],
                    ),
                    if (isLocked) ...[
                      const SizedBox(height: 12),
                      const Text(
                        '完成前一个单元后自动解锁，避免用户在未建立关键发音动作前过早跳关。',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.6,
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

  Color _statusColor(String status) {
    return switch (status) {
      '已完成' => AppColors.successGreen,
      '待解锁' => AppColors.textSecondary,
      '可开始' => AppColors.primary,
      _ => AppColors.secondary,
    };
  }
}

class _SummaryPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SummaryPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
