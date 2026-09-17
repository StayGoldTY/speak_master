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
        subtitle: '目标、水平和每日时长会决定循环里先出现哪些词、句型和开口。词汇、语法和发音走同一条提取循环，而不是三个互不相干的功能。',
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
                    '首期每天会走同一条循环：先提取到期复习，再学一点点新内容，词汇、语法和开口交错进行。成功提取会排到明天，让睡眠帮忙巩固。',
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
                child: const Text('开始我的学习循环'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
