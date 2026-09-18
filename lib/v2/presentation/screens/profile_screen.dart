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
    final compact = MediaQuery.sizeOf(context).width < 760;
    final signedIn = auth.status == AuthStatus.authenticated;

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
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Avatar(label: avatarLabel),
                      const SizedBox(height: 18),
                      _AccountCopy(signedIn: signedIn),
                      const SizedBox(height: 18),
                      _AccountAction(signedIn: signedIn),
                    ],
                  )
                : Row(
                    children: [
                      _Avatar(label: avatarLabel),
                      const SizedBox(width: 20),
                      Expanded(child: _AccountCopy(signedIn: signedIn)),
                      const SizedBox(width: 16),
                      _AccountAction(signedIn: signedIn),
                    ],
                  ),
          ),
          SizedBox(height: compact ? 36 : 56),
          const V2SectionTitle(
            title: '参考发音偏好',
            subtitle: '参考音频、识别配置和口语任务都会跟随你的口音偏好。',
          ),
          Material(
            color: Colors.transparent,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
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
          ),
          SizedBox(height: compact ? 36 : 56),
          V2InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '当前学习设置',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  children: [
                    V2SpecMetric(label: '目标', value: learner.goal.title),
                    V2SpecMetric(
                      label: '水平',
                      value: learner.placementLevel.title,
                    ),
                    V2SpecMetric(
                      label: '每日',
                      value: '${learner.dailyMinutes} 分钟',
                    ),
                    V2SpecMetric(label: '口音', value: learner.accentLabel),
                  ],
                ),
                const SizedBox(height: 22),
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

class _Avatar extends StatelessWidget {
  final String label;

  const _Avatar({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: const BoxDecoration(
        color: AppColors.ink,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AccountCopy extends StatelessWidget {
  final bool signedIn;

  const _AccountCopy({required this.signedIn});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          signedIn ? '已登录' : '游客模式',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          signedIn
              ? '已开启账号同步，可承接云端进度、发音记录和后续个性化服务。'
              : '现在也可以本地体验，之后再绑定账号继续保留学习记录。',
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _AccountAction extends ConsumerWidget {
  final bool signedIn;

  const _AccountAction({required this.signedIn});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (signedIn) {
      return OutlinedButton(
        onPressed: () => ref.read(authProvider.notifier).signOut(),
        child: const Text('退出登录'),
      );
    }
    return FilledButton(
      onPressed: () => context.push('/auth?from=%2Fprofile'),
      child: const Text('去登录'),
    );
  }
}
