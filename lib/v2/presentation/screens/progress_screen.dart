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
      title: 'Progress',
      subtitle: 'V2 progress is built around weak-point recovery, review queue health, and daily speaking consistency.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricCard(label: 'Streak', value: '${snapshot.streakDays}', accent: AppColors.streakFlame),
              _MetricCard(label: 'XP', value: '${snapshot.totalXp}', accent: AppColors.xpGold),
              _MetricCard(label: 'Completed lessons', value: '${snapshot.completedLessons}', accent: AppColors.primary),
            ],
          ),
          const SizedBox(height: 20),
          V2InfoCard(
            child: Text(
              snapshot.recommendedFocus,
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),
          ),
          const SizedBox(height: 20),
          const V2SectionTitle(
            title: 'Weak points',
            subtitle: 'The queue below is generated from the current local mastery snapshot.',
          ),
          if (snapshot.weakPoints.isEmpty)
            const V2InfoCard(
              child: Text('No weak points have been detected yet. Complete a speaking drill or assessment to build the first snapshot.'),
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
                            Text(item.label, style: const TextStyle(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 6),
                            Text(item.description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      V2Pill(label: '${item.score.round()}%', color: AppColors.accentOrange),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          const V2SectionTitle(
            title: 'Review queue',
            subtitle: 'These items should be recycled before new pronunciation load becomes too heavy.',
          ),
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
                          Text(item.label, style: const TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          Text(item.reason, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    V2Pill(label: item.recommendedActivityKind.label, color: AppColors.secondary),
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
            Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: accent)),
          ],
        ),
      ),
    );
  }
}
