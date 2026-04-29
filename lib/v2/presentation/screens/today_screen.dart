import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/progress_provider.dart';
import '../../application/providers/v2_providers.dart';
import '../../domain/models/course_models.dart';
import '../../domain/models/learner_models.dart';
import '../widgets/v2_page_scaffold.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final learner = ref.watch(v2LearnerProfileProvider);
    final plan = ref.watch(v2DailyPlanProvider);
    final progress = ref.watch(progressProvider);
    final track = ref.watch(v2PrimaryTrackProvider);
    final mastery = ref.watch(v2MasterySnapshotProvider);

    final nextLesson = _findNextLesson(track, progress.completedLessons);
    final currentUnit = nextLesson == null
        ? null
        : track.units.where((unit) => unit.id == nextLesson.unitId).firstOrNull;
    final completedTotal = progress.completedLessons.length;
    final totalLessons = track.units.fold<int>(
      0,
      (sum, unit) => sum + unit.lessons.length,
    );
    final unitCompletedCount = currentUnit == null
        ? 0
        : currentUnit.lessons
              .where((lesson) => progress.completedLessons.contains(lesson.id))
              .length;

    return V2PageScaffold(
      title: '今日学习',
      subtitle: '把主线课、补弱训练和口语迁移排进同一条日计划，让每天的学习更稳、更有连续性。',
      actions: [
        V2Pill(
          label: '已坚持 ${progress.streakDays} 天',
          color: AppColors.streakFlame,
        ),
        V2Pill(label: '${progress.totalXp} XP', color: AppColors.xpGold),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!learner.onboardingComplete) ...[
            V2InfoCard(
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '先完成学习设置，我们才能根据你的目标、水平和每日时长生成更合适的今日计划。',
                      style: TextStyle(height: 1.6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () => context.go('/onboarding'),
                    child: const Text('继续完善'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 28,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.headline,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  plan.subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    V2Pill(label: learner.goal.title, color: Colors.white),
                    V2Pill(
                      label: learner.placementLevel.title,
                      color: Colors.white,
                    ),
                    V2Pill(label: learner.accentLabel, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _HeroMetric(
                      label: '每日目标',
                      value: '${learner.dailyMinutes} 分钟',
                    ),
                    _HeroMetric(
                      label: '连续学习',
                      value: '${progress.streakDays} 天',
                    ),
                    _HeroMetric(label: '当前积分', value: '${progress.totalXp} XP'),
                    _HeroMetric(
                      label: '主线进度',
                      value: '$completedTotal / $totalLessons',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          V2InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nextLesson == null ? '主线已全部完成' : '继续主线课程',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  nextLesson == null
                      ? '你已经完成当前全部主线课程，接下来更适合回到口语迁移和弱项补强，等待下一版课程扩展。'
                      : '别让首页只剩“任务列表”。先把下一节主线课顶到最前面，用户一进来就知道该从哪里继续。',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                if (nextLesson != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.14),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            V2Pill(
                              label: currentUnit == null
                                  ? '下一节主线课'
                                  : '第 ${currentUnit.order} 单元',
                              color: AppColors.primary,
                            ),
                            if (currentUnit != null)
                              V2Pill(
                                label:
                                    '已完成 $unitCompletedCount / ${currentUnit.lessons.length} 节',
                                color: AppColors.secondary,
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          nextLesson.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          nextLesson.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _ProgressChip(
                              label: currentUnit == null
                                  ? '继续主线'
                                  : '单元进度 $unitCompletedCount/${currentUnit.lessons.length}',
                              icon: Icons.timeline_rounded,
                            ),
                            _ProgressChip(
                              label: '${nextLesson.estimatedMinutes} 分钟',
                              icon: Icons.schedule_rounded,
                            ),
                            _ProgressChip(
                              label: nextLesson.subtitle,
                              icon: Icons.translate_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          key: const ValueKey('today-primary-cta'),
                          onPressed: () =>
                              context.push('/lesson/${nextLesson.id}'),
                          icon: const Icon(Icons.play_circle_fill_rounded),
                          label: const Text('继续主线'),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  FilledButton.icon(
                    key: const ValueKey('today-primary-cta'),
                    onPressed: () => context.push('/speaking'),
                    icon: const Icon(Icons.mic_rounded),
                    label: const Text('进入口语迁移'),
                  ),
                ],
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _SummaryBadge(
                      label: '已完成课程',
                      value: '$completedTotal 节',
                      color: AppColors.successGreen,
                    ),
                    _SummaryBadge(
                      label: '待补弱项',
                      value: '${mastery.weakPoints.length} 项',
                      color: AppColors.accentOrange,
                    ),
                    _SummaryBadge(
                      label: '推荐重点',
                      value: mastery.weakPoints.isEmpty
                          ? '保持输出'
                          : mastery.weakPoints.first.label,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const V2SectionTitle(
            title: '今日任务',
            subtitle: '建议按顺序完成，先进入主线，再补弱，最后做一次场景迁移。',
          ),
          ...plan.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: V2InfoCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _cardColor(item.kind).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        _cardIcon(item.kind),
                        color: _cardColor(item.kind),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                item.kind == DailyPlanItemKind.lesson &&
                                        nextLesson != null &&
                                        item.title == nextLesson.title
                                    ? '主线继续任务'
                                    : item.title,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              V2Pill(
                                label: _statusLabel(
                                  item: item,
                                  nextLesson: nextLesson,
                                  mastery: mastery,
                                ),
                                color: _statusColor(
                                  item: item,
                                  nextLesson: nextLesson,
                                  mastery: mastery,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.subtitle,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              V2Pill(
                                label: '${item.estimatedMinutes} 分钟',
                                color: AppColors.primary,
                              ),
                              V2Pill(
                                label: '+${item.xpReward} XP',
                                color: AppColors.secondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () => context.push(item.route),
                      child: Text(
                        item.kind == DailyPlanItemKind.lesson ? '继续' : '开始',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LessonBlueprint? _findNextLesson(
    CourseTrack track,
    Set<String> completedLessons,
  ) {
    for (final unit in track.units) {
      for (final lesson in unit.lessons) {
        if (!completedLessons.contains(lesson.id)) {
          return lesson;
        }
      }
    }
    return null;
  }

  IconData _cardIcon(DailyPlanItemKind kind) {
    return switch (kind) {
      DailyPlanItemKind.lesson => Icons.menu_book_rounded,
      DailyPlanItemKind.review => Icons.tune_rounded,
      DailyPlanItemKind.speaking ||
      DailyPlanItemKind.assessment ||
      DailyPlanItemKind.dialogue => Icons.multitrack_audio_rounded,
    };
  }

  Color _cardColor(DailyPlanItemKind kind) {
    return switch (kind) {
      DailyPlanItemKind.lesson => AppColors.primary,
      DailyPlanItemKind.review => AppColors.accentOrange,
      DailyPlanItemKind.speaking ||
      DailyPlanItemKind.assessment ||
      DailyPlanItemKind.dialogue => AppColors.secondary,
    };
  }

  String _statusLabel({
    required DailyPlanItem item,
    required LessonBlueprint? nextLesson,
    required MasterySnapshot mastery,
  }) {
    return switch (item.kind) {
      DailyPlanItemKind.lesson => nextLesson == null ? '主线已清空' : '主线优先',
      DailyPlanItemKind.review => mastery.weakPoints.isEmpty ? '已达标' : '建议完成',
      DailyPlanItemKind.speaking ||
      DailyPlanItemKind.assessment ||
      DailyPlanItemKind.dialogue => '迁移输出',
    };
  }

  Color _statusColor({
    required DailyPlanItem item,
    required LessonBlueprint? nextLesson,
    required MasterySnapshot mastery,
  }) {
    return switch (item.kind) {
      DailyPlanItemKind.lesson =>
        nextLesson == null ? AppColors.successGreen : AppColors.primary,
      DailyPlanItemKind.review =>
        mastery.weakPoints.isEmpty
            ? AppColors.successGreen
            : AppColors.accentOrange,
      DailyPlanItemKind.speaking ||
      DailyPlanItemKind.assessment ||
      DailyPlanItemKind.dialogue => AppColors.secondary,
    };
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;

  const _HeroMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 132),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _ProgressChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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

class _SummaryBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 132),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.16)),
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
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
