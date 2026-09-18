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
    final compact = MediaQuery.sizeOf(context).width < 760;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
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
                final selected = setup.goal == goal;
                return _SetupCard(
                  width: compact ? double.infinity : 280,
                  selected: selected,
                  title: goal.title,
                  subtitle: goal.subtitle,
                  onTap: () => notifier.setGoal(goal),
                );
              }).toList(),
            ),
            SizedBox(height: compact ? 36 : 56),
            const V2SectionTitle(
              title: '当前大致水平',
              subtitle: '这会影响前期中文说明的密度、课程难度和练习节奏。',
            ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: PlacementLevel.values.map((level) {
                final selected = setup.placementLevel == level;
                return _SetupCard(
                  width: compact ? double.infinity : 280,
                  selected: selected,
                  title: level.title,
                  subtitle: level.subtitle,
                  onTap: () => notifier.setPlacementLevel(level),
                );
              }).toList(),
            ),
            SizedBox(height: compact ? 36 : 56),
            V2InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '每天准备学多久',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${setup.dailyMinutes} 分钟 / 天',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1.4,
                      height: 1.05,
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
                      fontSize: 17,
                      color: AppColors.textSecondary,
                      height: 1.47,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: compact ? double.infinity : 280,
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

class _SetupCard extends StatelessWidget {
  final double width;
  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SetupCard({
    required this.width,
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: selected ? AppColors.ink : Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: selected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: selected
                        ? Colors.white.withValues(alpha: 0.72)
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
