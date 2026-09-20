import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../v2/application/providers/v2_providers.dart';
import '../../../v2/domain/models/learner_models.dart';
import '../widgets/daily_widgets.dart';

class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final learner = ref.watch(v2LearnerProfileProvider);
    final setup = ref.read(v2LearnerSetupProvider.notifier);
    final loggedIn = auth.status == AuthStatus.authenticated;

    return DailyPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '我的',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          DailyCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    learner.displayName.trim().isEmpty
                        ? '学'
                        : learner.displayName.trim().substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        learner.displayName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        loggedIn ? '已登录，可同步进度' : '游客模式，进度先记在这台设备',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DailyCard(
            onTap: () => context.push('/auth?from=%2Fprofile'),
            child: Text(loggedIn ? '管理账号资料' : '登录或注册'),
          ),
          const SizedBox(height: 22),
          const SectionLabel(title: '学习设置'),
          DailyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('口音', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('美式'),
                      selected: learner.accentPreference != 'british',
                      onSelected: (_) => setup.setAccentPreference('american'),
                    ),
                    ChoiceChip(
                      label: const Text('英式'),
                      selected: learner.accentPreference == 'british',
                      onSelected: (_) => setup.setAccentPreference('british'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '每日 ${learner.dailyMinutes} 分钟',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Slider(
                  value: learner.dailyMinutes.toDouble(),
                  min: 10,
                  max: 30,
                  divisions: 4,
                  label: '${learner.dailyMinutes} 分钟',
                  onChanged: (value) => setup.setDailyMinutes(value.round()),
                ),
                const Text(
                  '目标',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: LearningGoal.values.map((goal) {
                    return ChoiceChip(
                      label: Text(goal.title),
                      selected: learner.goal == goal,
                      onSelected: (_) => setup.setGoal(goal),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DailyCard(
            child: const Text(
              '开口反馈只在接上评分引擎时显示声学分数。现在没有密钥，界面只会做识别对齐，不会编分。',
              style: TextStyle(height: 1.5, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.push('/ops'),
            child: const Text('运营后台'),
          ),
          if (loggedIn)
            TextButton(
              onPressed: () => ref.read(authProvider.notifier).signOut(),
              child: const Text('退出登录'),
            ),
        ],
      ),
    );
  }
}
