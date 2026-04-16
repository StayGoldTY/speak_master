import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/service_providers.dart';
import '../../application/providers/v2_providers.dart';
import '../../domain/models/learner_models.dart';
import '../widgets/v2_page_scaffold.dart';

class ProfileScreenV2 extends ConsumerWidget {
  const ProfileScreenV2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final learner = ref.watch(v2LearnerProfileProvider);
    final avatarLabel = learner.displayName.trim().isEmpty
        ? '学'
        : learner.displayName.trim().substring(0, 1).toUpperCase();

    return V2PageScaffold(
      title: learner.displayName,
      subtitle: '管理账号状态、发音偏好和学习设置。后续这里也会承接会员、学习报告和更多个性化能力。',
      actions: [
        TextButton(
          onPressed: () => context.push('/ops'),
          child: const Text('运营后台'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          V2InfoCard(
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientPrimary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    avatarLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.status == AuthStatus.authenticated
                            ? '已登录'
                            : '游客模式',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        auth.status == AuthStatus.authenticated
                            ? '已开启账号同步，可承接云端进度、发音记录和后续个性化服务。'
                            : '现在也可以本地体验，之后再绑定账号继续保留学习记录。',
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
                if (auth.status == AuthStatus.authenticated)
                  OutlinedButton(
                    onPressed: () => ref.read(authProvider.notifier).signOut(),
                    child: const Text('退出登录'),
                  )
                else
                  FilledButton(
                    onPressed: () => context.push('/auth?from=%2Fprofile'),
                    child: const Text('去登录'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const V2SectionTitle(
            title: '参考发音偏好',
            subtitle: '参考音频、识别配置和口语任务都会跟随你的口音偏好。',
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ['american', 'british'].map((accent) {
              final selected = learner.accentPreference == accent;
              final label = accent == 'british' ? '英式发音' : '美式发音';

              return ChoiceChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) async {
                  await ref
                      .read(storageServiceProvider)
                      .saveAccentPreference(accent);
                  if (ref.read(authProvider).status ==
                      AuthStatus.authenticated) {
                    await ref
                        .read(authProvider.notifier)
                        .updateAccentPreference(accent);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          V2InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '当前学习设置',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    V2Pill(label: learner.goal.title, color: AppColors.primary),
                    V2Pill(
                      label: learner.placementLevel.title,
                      color: AppColors.secondary,
                    ),
                    V2Pill(
                      label: '${learner.dailyMinutes} 分钟/天',
                      color: AppColors.accentOrange,
                    ),
                    V2Pill(
                      label: learner.accentLabel,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: () => context.go('/onboarding'),
                  child: const Text('修改学习设置'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
