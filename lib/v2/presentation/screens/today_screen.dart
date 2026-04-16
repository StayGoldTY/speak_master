import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/progress_provider.dart';
import '../../application/providers/v2_providers.dart';
import '../../domain/models/learner_models.dart';
import '../widgets/v2_page_scaffold.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final learner = ref.watch(v2LearnerProfileProvider);
    final plan = ref.watch(v2DailyPlanProvider);
    final progress = ref.watch(progressProvider);

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
                        color: _cardColor(item.route).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        _cardIcon(item.route),
                        color: _cardColor(item.route),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
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
                      child: const Text('开始'),
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

  IconData _cardIcon(String route) {
    if (route.startsWith('/lesson')) {
      return Icons.menu_book_rounded;
    }
    if (route.startsWith('/speaking')) {
      return Icons.multitrack_audio_rounded;
    }
    return Icons.play_circle_outline_rounded;
  }

  Color _cardColor(String route) {
    if (route.startsWith('/lesson')) {
      return AppColors.primary;
    }
    if (route.startsWith('/speaking')) {
      return AppColors.secondary;
    }
    return AppColors.accent;
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
