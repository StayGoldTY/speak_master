import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/progress_provider.dart';
import '../../domain/session_models.dart';
import '../../../v2/application/providers/v2_providers.dart';
import '../../../v2/domain/models/learner_models.dart';
import '../widgets/daily_widgets.dart';

class TodayHomeScreen extends ConsumerWidget {
  const TodayHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final learner = ref.watch(v2LearnerProfileProvider);
    final plan = ref.watch(v2DailyPlanProvider);
    final loop = ref.watch(dailyLoopProvider);
    final journey = ref.watch(journeySnapshotProvider);
    final progress = ref.watch(progressProvider);
    final doneCount = plan.items.where((item) => loop.isDone(item.id)).length;
    final goalComplete = plan.items.isNotEmpty && doneCount >= plan.items.length;
    DailyPlanItem? nextTask;
    for (final item in plan.items) {
      if (!loop.isDone(item.id)) {
        nextTask = item;
        break;
      }
    }

    return DailyPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DailyPill(
                label: '${progress.streakDays} 天连续',
                color: AppColors.streakFlame,
                icon: Icons.local_fire_department_rounded,
              ),
              const SizedBox(width: 8),
              DailyPill(
                label: '${progress.totalXp} XP',
                color: AppColors.xpGold,
                icon: Icons.bolt_rounded,
              ),
              const Spacer(),
              Text(
                learner.accentShortLabel,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            _greeting(learner.displayName),
            style: const TextStyle(
              fontSize: 30,
              height: 1.15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            goalComplete
                ? '今日 3 个开口任务都做完了，连续天数已记下。'
                : '完成这 3 个开口任务，就算今天学完。',
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          WeekStreakRow(
            streakDays: progress.streakDays,
            lastActiveDate: progress.lastActiveDate,
          ),
          const SizedBox(height: 18),
          if (goalComplete)
            DailyCard(
              cardKey: const ValueKey('today-goal-complete'),
              color: const Color(0xFFECFDF3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '今日目标完成',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '连续 ${progress.streakDays} 天。明天同一时间再来这 3 件事。',
                    style: const TextStyle(height: 1.5),
                  ),
                ],
              ),
            )
          else
            DailyCard(
              color: AppColors.ink,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '今日任务  $doneCount / ${plan.items.length}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    nextTask?.title ?? '先完成设置',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    key: const ValueKey('today-primary-cta'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.ink,
                    ),
                    onPressed: nextTask == null
                        ? null
                        : () => context.push(nextTask!.route),
                    child: Text(doneCount == 0 ? '开始第 1 个任务' : '继续下一个'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          SectionLabel(
            title: '今天这 3 件事',
            subtitle: plan.subtitle,
          ),
          ...plan.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final done = loop.isDone(item.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DailyCard(
                cardKey: ValueKey('today-task-${item.id}'),
                onTap: () => context.push(item.route),
                child: Row(
                  children: [
                    _TaskIndex(index: index + 1, done: done),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              decoration: done
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              DailyPill(label: '${item.estimatedMinutes} 分钟'),
                              DailyPill(
                                label: done ? '已完成' : '待开口',
                                color: done
                                    ? AppColors.successGreen
                                    : AppColors.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      done
                          ? Icons.check_circle_rounded
                          : Icons.chevron_right_rounded,
                      color: done
                          ? AppColors.successGreen
                          : AppColors.textHint,
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          DailyCard(
            cardKey: const ValueKey('today-journey-peek'),
            onTap: () => context.go('/progress'),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${journey.band.title} → ${journey.band.nextTitle}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  '${journey.completedLessons}/${journey.totalLessons}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _greeting(String name) {
    final hour = DateTime.now().hour;
    final when = hour < 12
        ? '早上好'
        : hour < 18
        ? '下午好'
        : '晚上好';
    return '$when，$name';
  }
}

class _TaskIndex extends StatelessWidget {
  final int index;
  final bool done;

  const _TaskIndex({required this.index, required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: done ? AppColors.successGreen : AppColors.surfaceAccent,
        shape: BoxShape.circle,
      ),
      child: done
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
          : Text(
              '$index',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
    );
  }
}
