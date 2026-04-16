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
      title: 'Today',
      subtitle: 'Your V2 loop keeps one lesson, one weak-point rebuild, and one speaking transfer task in motion.',
      actions: [
        V2Pill(label: '${progress.streakDays} day streak', color: AppColors.streakFlame),
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
                      'Finish onboarding so the daily plan can adapt to your goal and placement.',
                      style: TextStyle(height: 1.55),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () => context.go('/onboarding'),
                    child: const Text('Resume'),
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
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.headline,
                  style: const TextStyle(
                    fontSize: 28,
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
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 18),
                V2Pill(
                  label: '${learner.goal.title} • ${learner.placementLevel.title} • ${learner.accentPreference}',
                  color: Colors.white,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const V2SectionTitle(
            title: 'Daily plan',
            subtitle: 'Complete the cards in order to keep your pronunciation loop balanced.',
          ),
          ...plan.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: V2InfoCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          Text(
                            item.subtitle,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.55),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              V2Pill(label: '${item.estimatedMinutes} min', color: AppColors.primary),
                              V2Pill(label: '+${item.xpReward} XP', color: AppColors.secondary),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () => context.push(item.route),
                      child: const Text('Start'),
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
