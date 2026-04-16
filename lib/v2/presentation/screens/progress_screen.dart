import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../application/providers/v2_providers.dart';
import '../../domain/models/course_models.dart';
import '../widgets/v2_page_scaffold.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(v2MasterySnapshotProvider);

    return V2PageScaffold(
      title: '学习进度',
      subtitle: '这里会跟踪你的连续学习、掌握度变化和补弱队列，帮助你更清楚地看到自己在口语上的提升。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricCard(
                label: '连续学习',
                value: '${snapshot.streakDays} 天',
                accent: AppColors.streakFlame,
              ),
              _MetricCard(
                label: '累计 XP',
                value: '${snapshot.totalXp}',
                accent: AppColors.xpGold,
              ),
              _MetricCard(
                label: '完成课程',
                value: '${snapshot.completedLessons} 节',
                accent: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 20),
          V2InfoCard(
            child: Text(
              snapshot.recommendedFocus,
              style: const TextStyle(fontSize: 15, height: 1.65),
            ),
          ),
          const SizedBox(height: 20),
          const V2SectionTitle(
            title: '当前弱项',
            subtitle: '这些项目会优先进入补弱逻辑，建议先练稳再继续往下走。',
          ),
          if (snapshot.weakPoints.isEmpty)
            const V2InfoCard(
              child: Text('暂时还没有生成弱项快照。先完成一次口语练习或测评，我们就能开始给你建立补弱视图。'),
            )
          else
            ...snapshot.weakPoints.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: V2InfoCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.description,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.55,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      V2Pill(
                        label: '${item.score.round()}%',
                        color: AppColors.accentOrange,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          const V2SectionTitle(
            title: '补弱队列',
            subtitle: '这些内容会被优先安排到复习和口语训练里，帮助你持续补齐短板。',
          ),
          if (snapshot.reviewQueue.isEmpty)
            const V2InfoCard(child: Text('补弱队列还是空的，继续完成练习后这里会逐渐丰富起来。'))
          else
            ...snapshot.reviewQueue.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: V2InfoCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.reason,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.55,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      V2Pill(
                        label: item.recommendedActivityKind.label,
                        color: AppColors.secondary,
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
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: V2InfoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
