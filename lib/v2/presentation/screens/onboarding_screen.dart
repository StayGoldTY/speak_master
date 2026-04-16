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
        title: '先完成你的学习设置',
        subtitle: '告诉我们你的目标、当前水平和每日可投入时间，系统会据此生成中文引导更强、发音训练更聚焦的学习计划。',
        actions: [
          TextButton(
            onPressed: () => context.push('/auth?from=%2Fprofile'),
            child: const Text('登录账号'),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const V2SectionTitle(
              title: '你最想先解决什么',
              subtitle: '先锁定一个主要目标，系统会优先安排相关的练习和口语任务。',
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
                        Text(
                          goal.subtitle,
                          style: const TextStyle(fontSize: 12),
                        ),
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
              title: '当前大致水平',
              subtitle: '这会影响前期中文说明的密度、课程难度和练习节奏。',
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
                        Text(
                          level.subtitle,
                          style: const TextStyle(fontSize: 12),
                        ),
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
                    '每天准备学多久',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${setup.dailyMinutes} 分钟 / 天',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Slider(
                    value: setup.dailyMinutes.toDouble(),
                    min: 10,
                    max: 30,
                    divisions: 4,
                    label: '${setup.dailyMinutes} 分钟',
                    onChanged: (value) =>
                        notifier.setDailyMinutes(value.round()),
                  ),
                  const Text(
                    '首期计划会保持足够聚焦：1 节主线课 + 1 次补弱训练 + 1 次口语迁移，既能稳步推进，也不容易中断。',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.6,
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
                child: const Text('生成我的今日计划'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
