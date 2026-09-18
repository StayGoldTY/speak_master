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
    final compact = MediaQuery.sizeOf(context).width < 760;

    return V2PageScaffold(
      title: '今日学习',
      subtitle: '把主线课、提取复习和口语迁移收进同一条学习循环。',
      actions: [
        V2Pill(
          label: '已坚持 ${progress.streakDays} 天',
          color: AppColors.textSecondary,
        ),
        V2Pill(label: '${progress.totalXp} XP', color: AppColors.textSecondary),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!learner.onboardingComplete) ...[
            V2InfoCard(
              child: compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '先完成学习设置，我们才能根据你的目标、水平和每日时长生成更合适的今日计划。',
                          style: TextStyle(
                            fontSize: 17,
                            height: 1.47,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 18),
                        FilledButton(
                          onPressed: () => context.go('/onboarding'),
                          child: const Text('继续完善'),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        const Expanded(
                          child: Text(
                            '先完成学习设置，我们才能根据你的目标、水平和每日时长生成更合适的今日计划。',
                            style: TextStyle(
                              fontSize: 17,
                              height: 1.47,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        FilledButton(
                          onPressed: () => context.go('/onboarding'),
                          child: const Text('继续完善'),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 28),
          ],
          V2CinematicBand(
            kicker: '今日循环',
            headline: plan.headline,
            body: plan.subtitle,
            metrics: [
              V2SpecMetric(
                label: '每日目标',
                value: '${learner.dailyMinutes} 分钟',
                inverted: true,
              ),
              V2SpecMetric(
                label: '连续学习',
                value: '${progress.streakDays} 天',
                inverted: true,
              ),
              V2SpecMetric(
                label: '当前积分',
                value: '${progress.totalXp} XP',
                inverted: true,
              ),
              V2SpecMetric(
                label: '主线进度',
                value: '$completedTotal / $totalLessons',
                inverted: true,
              ),
            ],
            action: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                V2Pill(label: learner.goal.title, color: Colors.white),
                V2Pill(
                  label: learner.placementLevel.title,
                  color: Colors.white,
                ),
                V2Pill(label: learner.accentLabel, color: Colors.white),
              ],
            ),
          ),
          SizedBox(height: compact ? 36 : 56),
          V2InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '今日学习循环',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.8,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  plan.subtitle,
                  style: const TextStyle(
                    fontSize: 17,
                    color: AppColors.textSecondary,
                    height: 1.47,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    V2Pill(
                      label: mastery.dueTodayCount > 0
                          ? '${mastery.dueTodayCount} 个到期提取'
                          : '先学新项目，再排到明天',
                      color: AppColors.accentOrange,
                    ),
                    V2Pill(
                      label: '词汇 / 语法 / 开口交错',
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  key: const ValueKey('today-session-cta'),
                  onPressed: () => context.push('/session'),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('开始今日循环'),
                ),
              ],
            ),
          ),
          SizedBox(height: compact ? 36 : 56),
          V2InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nextLesson == null ? '主线已全部完成' : '继续主线课程',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.8,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  nextLesson == null
                      ? '你已经完成当前全部主线课程，接下来更适合回到口语迁移和弱项补强，等待下一版课程扩展。'
                      : '主线课用来编码新的发音知识。真正的记住，发生在上面的提取循环里。',
                  style: const TextStyle(
                    fontSize: 17,
                    color: AppColors.textSecondary,
                    height: 1.47,
                  ),
                ),
                const SizedBox(height: 24),
                if (nextLesson != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(22),
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
                              color: AppColors.textSecondary,
                            ),
                            if (currentUnit != null)
                              V2Pill(
                                label:
                                    '已完成 $unitCompletedCount / ${currentUnit.lessons.length} 节',
                                color: AppColors.textSecondary,
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          nextLesson.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          nextLesson.description,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 18,
                          runSpacing: 12,
                          children: [
                            V2SpecMetric(
                              label: currentUnit == null ? '主线' : '单元进度',
                              value: currentUnit == null
                                  ? '继续'
                                  : '$unitCompletedCount/${currentUnit.lessons.length}',
                            ),
                            V2SpecMetric(
                              label: '时长',
                              value: '${nextLesson.estimatedMinutes} 分钟',
                            ),
                            V2SpecMetric(
                              label: '重点',
                              value: nextLesson.subtitle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        FilledButton.icon(
                          key: const ValueKey('today-primary-cta'),
                          onPressed: () =>
                              context.push('/lesson/${nextLesson.id}'),
                          icon: const Icon(Icons.play_arrow_rounded),
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
                const SizedBox(height: 22),
                Wrap(
                  spacing: 28,
                  runSpacing: 16,
                  children: [
                    V2SpecMetric(
                      label: '已完成课程',
                      value: '$completedTotal 节',
                    ),
                    V2SpecMetric(
                      label: '待补弱项',
                      value: '${mastery.weakPoints.length} 项',
                    ),
                    V2SpecMetric(
                      label: '推荐重点',
                      value: mastery.weakPoints.isEmpty
                          ? '保持输出'
                          : mastery.weakPoints.first.label,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: compact ? 36 : 56),
          const V2SectionTitle(
            title: '今日任务',
            subtitle:
                '先走统一循环：到期提取 → 少量新内容 → 场景开口。主线课和迁移是同一条学习环的两端，不是三个互不相关的功能。',
          ),
          ...plan.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: V2InfoCard(
                padding: const EdgeInsets.all(22),
                child: compact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TaskCopy(
                            item: item,
                            nextLesson: nextLesson,
                            mastery: mastery,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => context.push(item.route),
                            child: Text(_taskCta(item.kind)),
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _TaskCopy(
                              item: item,
                              nextLesson: nextLesson,
                              mastery: mastery,
                            ),
                          ),
                          const SizedBox(width: 16),
                          FilledButton(
                            onPressed: () => context.push(item.route),
                            child: Text(_taskCta(item.kind)),
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

  String _taskCta(DailyPlanItemKind kind) {
    return switch (kind) {
      DailyPlanItemKind.session => '开始循环',
      DailyPlanItemKind.lesson => '继续',
      _ => '开始',
    };
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
}

class _TaskCopy extends StatelessWidget {
  final DailyPlanItem item;
  final LessonBlueprint? nextLesson;
  final MasterySnapshot mastery;

  const _TaskCopy({
    required this.item,
    required this.nextLesson,
    required this.mastery,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
                      item.title == nextLesson!.title
                  ? '主线继续任务'
                  : item.title,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
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
        const SizedBox(height: 8),
        Text(
          item.subtitle,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            V2Pill(
              label: '${item.estimatedMinutes} 分钟',
              color: AppColors.textSecondary,
            ),
            V2Pill(
              label: '+${item.xpReward} XP',
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ],
    );
  }

  String _statusLabel({
    required DailyPlanItem item,
    required LessonBlueprint? nextLesson,
    required MasterySnapshot mastery,
  }) {
    return switch (item.kind) {
      DailyPlanItemKind.session => mastery.dueTodayCount > 0 ? '到期优先' : '今日主循环',
      DailyPlanItemKind.lesson => nextLesson == null ? '主线已清空' : '编码新知识',
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
      DailyPlanItemKind.session => AppColors.ink,
      DailyPlanItemKind.lesson =>
        nextLesson == null ? AppColors.successGreen : AppColors.textSecondary,
      DailyPlanItemKind.review =>
        mastery.weakPoints.isEmpty
            ? AppColors.successGreen
            : AppColors.accentOrange,
      DailyPlanItemKind.speaking ||
      DailyPlanItemKind.assessment ||
      DailyPlanItemKind.dialogue => AppColors.textSecondary,
    };
  }
}
