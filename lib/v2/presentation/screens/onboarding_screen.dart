import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../application/providers/v2_providers.dart';
import '../../domain/models/learner_models.dart';
import '../widgets/v2_page_scaffold.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setup = ref.watch(v2LearnerSetupProvider);
    final notifier = ref.read(v2LearnerSetupProvider.notifier);

    return Scaffold(
      body: V2PageScaffold(
        title: 'Welcome to Speak Master V2',
        subtitle: 'Set your speaking goal, current level, and daily pace. We will use this to shape your daily plan and pronunciation loop.',
        actions: [
          TextButton(
            onPressed: () => context.push('/auth?from=%2Fprofile'),
            child: const Text('Sign in'),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const V2SectionTitle(
              title: 'Primary goal',
              subtitle: 'Choose the speaking outcome you care about most right now.',
            ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: LearningGoal.values.map((goal) {
                return ChoiceChip(
                  label: SizedBox(
                    width: 220,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(goal.title),
                        const SizedBox(height: 4),
                        Text(goal.subtitle, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  selected: setup.goal == goal,
                  onSelected: (_) => notifier.setGoal(goal),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const V2SectionTitle(
              title: 'Placement',
              subtitle: 'This controls how much foundation support the V2 learner flow should add.',
            ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: PlacementLevel.values.map((level) {
                return ChoiceChip(
                  label: SizedBox(
                    width: 220,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(level.title),
                        const SizedBox(height: 4),
                        Text(level.subtitle, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  selected: setup.placementLevel == level,
                  onSelected: (_) => notifier.setPlacementLevel(level),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            V2InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily commitment',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${setup.dailyMinutes} minutes per day',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  Slider(
                    value: setup.dailyMinutes.toDouble(),
                    min: 10,
                    max: 30,
                    divisions: 4,
                    label: '${setup.dailyMinutes} min',
                    onChanged: (value) => notifier.setDailyMinutes(value.round()),
                  ),
                  const Text(
                    'We will keep the first V2 plan focused: one main lesson, one weak-point drill, and one speaking transfer task.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await notifier.completeOnboarding();
                  if (context.mounted) {
                    context.go('/today');
                  }
                },
                child: const Text('Build my V2 learning plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
