import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../domain/session_models.dart';
import '../../../providers/progress_provider.dart';
import '../../../v2/application/providers/v2_providers.dart';
import '../widgets/daily_widgets.dart';

class ProgressJourneyScreen extends ConsumerWidget {
  const ProgressJourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final journey = ref.watch(journeySnapshotProvider);
    final snapshot = ref.watch(v2MasterySnapshotProvider);
    final loop = ref.watch(dailyLoopProvider);
    final log = ref.watch(practiceLogProvider);
    final plan = ref.watch(v2DailyPlanProvider);
    final todayDone = plan.items.where((item) => loop.isDone(item.id)).length;

    return DailyPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '进度',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            '这里看连续天数、课次和弱项。没有接上评分引擎时，不会出现总体发音分。',
            style: TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: '连续',
                  value: '${progress.streakDays} 天',
                  color: AppColors.streakFlame,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Metric(
                  label: '今日任务',
                  value: '$todayDone / ${plan.items.length}',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Metric(
                  label: 'XP',
                  value: '${progress.totalXp}',
                  color: AppColors.xpGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DailyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '本周连续',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                WeekStreakRow(
                  streakDays: progress.streakDays,
                  lastActiveDate: progress.lastActiveDate,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DailyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '开口旅程',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  '${journey.band.title} → ${journey.band.nextTitle}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: journey.progressToNext,
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  journey.summary,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionLabel(
            title: '当前弱项',
            subtitle: '来自识别对齐，不是声学打分。',
          ),
          if (snapshot.weakPoints.isEmpty)
            DailyEmptyState(
              title: '还没有弱项',
              message: '先开口一轮。对不齐的词会留在这里，方便明天复练。',
              actionLabel: '去开口',
              onAction: () => context.go('/speaking'),
            )
          else
            ...snapshot.weakPoints.take(5).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DailyCard(
                  onTap: () => context.go('/speaking'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 16),
          const SectionLabel(
            title: '最近练习',
            subtitle: '只记录对齐次数，不生成假分数。',
          ),
          if (log.isEmpty)
            const DailyEmptyState(
              title: '练习记录是空的',
              message: '完成一节开口课后，这里会出现对齐摘要。',
              icon: Icons.history_rounded,
            )
          else
            ...log.take(8).map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DailyCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              entry.source,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        entry.alignedTotal == 0
                            ? '听练'
                            : '${entry.alignedHits}/${entry.alignedTotal}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Metric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DailyCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
