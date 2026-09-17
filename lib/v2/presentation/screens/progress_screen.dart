import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      subtitle: '连续学习、到期提取和下次见面时间都在这里。复习排期来自你刚才的提取难度，而不是另做一本错题本。',
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
              _MetricCard(
                label: '今日到期',
                value: '${snapshot.dueTodayCount}',
                accent: AppColors.accentOrange,
              ),
              _MetricCard(
                label: '已排期',
                value: '${snapshot.upcomingCount}',
                accent: AppColors.successGreen,
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
          FilledButton.icon(
            onPressed: () => GoRouter.of(context).push('/session'),
            icon: const Icon(Icons.psychology_alt_rounded),
            label: const Text('进入今日循环'),
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
            title: '复习排期',
            subtitle: '这些项目已经进入间隔重复。点进今日循环，按到期顺序提取，而不是按题型分三个入口。',
          ),
          if (snapshot.reviewQueue.isEmpty)
            const V2InfoCard(child: Text('还没有排期。先完成一轮今日循环，成功提取的项目会出现下次见面时间。'))
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
                        label:
                            item.dueLabel ?? item.recommendedActivityKind.label,
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
