import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/community.dart';
import '../../models/user_progress.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final authState = ref.watch(authProvider);
    final profile = authState.profile;
    final weakPhonemes = progress.phonemeScores.entries
        .where((entry) => entry.value < 70)
        .map((entry) => entry.key.replaceFirst(RegExp(r'^[vc]_'), ''))
        .take(5)
        .toList();

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfileHeader(context, progress, authState),
                const SizedBox(height: 20),
                _buildStatsGrid(progress),
                const SizedBox(height: 20),
                _buildAchievements(progress),
                const SizedBox(height: 20),
                _buildSoundSummary(progress, weakPhonemes),
                const SizedBox(height: 20),
                _buildSettingsList(context, ref, authState, profile),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProgress progress, AuthState authState) {
    final name = authState.profile?.displayName ?? '发音学习者';
    final isLoggedIn = authState.status == AuthStatus.authenticated;
    final accentText = _accentLabel(authState.profile?.accentPreference ?? 'american');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white24,
                child: Text(
                  name[0],
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'Lv.${progress.level} · ${progress.totalXp} XP · $accentText',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.84)),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress.levelProgress,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isLoggedIn ? (progress.isPro ? 'Pro' : '已登录') : '本地体验',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (!isLoggedIn) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '现在的学习进度会先保存在本地。登录后可以继续同步到云端账号。',
                      style: TextStyle(color: Colors.white, height: 1.55),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => context.push('/auth?from=%2Fprofile'),
                    child: const Text('去登录', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsGrid(UserProgress progress) {
    return Row(
      children: [
        Expanded(child: _StatBox(value: '${progress.streakDays}', label: '连练天数', icon: Icons.local_fire_department, color: AppColors.streakFlame)),
        const SizedBox(width: 10),
        Expanded(child: _StatBox(value: '${progress.completedLessons.length}', label: '完成课程', icon: Icons.check_circle, color: AppColors.successGreen)),
        const SizedBox(width: 10),
        Expanded(child: _StatBox(value: '${progress.todayAssessmentCount}', label: '今日自评', icon: Icons.analytics, color: AppColors.accentOrange)),
        const SizedBox(width: 10),
        Expanded(child: _StatBox(value: '${progress.level}', label: '当前等级', icon: Icons.star, color: AppColors.xpGold)),
      ],
    );
  }

  Widget _buildAchievements(UserProgress progress) {
    final earned = progress.earnedBadges;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('成就徽章', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 94,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _BadgeItem(symbol: '7', label: '7 天', isEarned: earned.contains('streak_bronze')),
              const SizedBox(width: 12),
              _BadgeItem(symbol: '30', label: '30 天', isEarned: earned.contains('streak_silver')),
              const SizedBox(width: 12),
              _BadgeItem(symbol: '90', label: '90 天', isEarned: earned.contains('streak_gold')),
              const SizedBox(width: 12),
              _BadgeItem(symbol: '365', label: '365 天', isEarned: earned.contains('streak_diamond')),
              const SizedBox(width: 12),
              _BadgeItem(symbol: '10', label: 'Lv.10', isEarned: earned.contains('level_10')),
              const SizedBox(width: 12),
              _BadgeItem(symbol: '25', label: 'Lv.25', isEarned: earned.contains('level_25')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSoundSummary(UserProgress progress, List<String> weakPhonemes) {
    final scores = progress.phonemeScores;
    final vowelAvg = _avgCategory(scores, 'v_');
    final consonantAvg = _avgCategory(scores, 'c_');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('发音概览', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          _PhonemeBar(label: '元音', progress: vowelAvg, color: AppColors.vowelColor),
          const SizedBox(height: 10),
          _PhonemeBar(label: '辅音', progress: consonantAvg, color: AppColors.consonantColor),
          const SizedBox(height: 10),
          _PhonemeBar(label: '综合', progress: (vowelAvg + consonantAvg) / 2, color: AppColors.primary),
          const SizedBox(height: 18),
          Text(
            weakPhonemes.isEmpty
                ? '目前还没有明显偏弱的音位记录。可以继续推进教程，或者做一次朗读自评建立新的参考。'
                : '建议优先回练：/${weakPhonemes.join('/ /')}/。',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
          ),
        ],
      ),
    );
  }

  double _avgCategory(Map<String, double> scores, String prefix) {
    final filtered = scores.entries.where((entry) => entry.key.startsWith(prefix)).toList();
    if (filtered.isEmpty) {
      return 0;
    }

    return filtered.map((entry) => entry.value).reduce((a, b) => a + b) / filtered.length / 100;
  }

  Widget _buildSettingsList(BuildContext context, WidgetRef ref, AuthState authState, UserProfile? profile) {
    final isLoggedIn = authState.status == AuthStatus.authenticated;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          if (!isLoggedIn)
            _SettingsTile(
              icon: Icons.login,
              label: '登录 / 注册',
              subtitle: '把本地学习记录同步到账号',
              color: AppColors.primary,
              onTap: () => context.push('/auth?from=%2Fprofile'),
            ),
          if (!isLoggedIn) const Divider(height: 1),
          if (isLoggedIn)
            _SettingsTile(
              icon: Icons.manage_accounts_outlined,
              label: '账号资料',
              subtitle: authState.user?.email ?? '查看和编辑昵称、用户名',
              color: AppColors.primary,
              onTap: () => context.push('/settings/account'),
            ),
          if (isLoggedIn) const Divider(height: 1),
          _SettingsTile(
            icon: Icons.language,
            label: '口音偏好',
            subtitle: _accentLabel(profile?.accentPreference ?? 'american'),
            color: AppColors.secondary,
            onTap: () => context.push('/settings/accent'),
          ),
          const Divider(height: 1),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: '提醒设置',
            subtitle: '先保存你的提醒偏好，后续接入系统通知',
            color: AppColors.primary,
            onTap: () => context.push('/settings/reminder'),
          ),
          const Divider(height: 1),
          _SettingsTile(
            icon: Icons.help_outline,
            label: '帮助与反馈',
            subtitle: '查看当前阶段说明和反馈模板',
            color: AppColors.textSecondary,
            onTap: () => context.push('/help'),
          ),
          const Divider(height: 1),
          _SettingsTile(
            icon: Icons.info_outline,
            label: '关于应用',
            subtitle: '了解产品定位、当前覆盖范围和路线',
            color: AppColors.textSecondary,
            onTap: () => context.push('/about'),
          ),
          if (isLoggedIn) ...[
            const Divider(height: 1),
            _SettingsTile(
              icon: Icons.logout,
              label: '退出登录',
              subtitle: '保留本地数据，退出当前账号',
              color: AppColors.errorRed,
              onTap: () => ref.read(authProvider.notifier).signOut(),
            ),
          ],
        ],
      ),
    );
  }

  static String _accentLabel(String accentPreference) {
    return accentPreference == 'british' ? '英式偏好' : '美式偏好';
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final String symbol;
  final String label;
  final bool isEarned;

  const _BadgeItem({
    required this.symbol,
    required this.label,
    required this.isEarned,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: isEarned ? AppColors.xpGold.withValues(alpha: 0.15) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isEarned ? AppColors.xpGold.withValues(alpha: 0.3) : Colors.grey.shade200),
          ),
          child: Center(
            child: Text(
              symbol,
              style: TextStyle(
                fontSize: symbol.length > 2 ? 14 : 18,
                fontWeight: FontWeight.w700,
                color: isEarned ? AppColors.textPrimary : Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 10, color: isEarned ? AppColors.textPrimary : AppColors.textHint)),
      ],
    );
  }
}

class _PhonemeBar extends StatelessWidget {
  final String label;
  final double progress;
  final Color color;

  const _PhonemeBar({
    required this.label,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0).toDouble();
    return Row(
      children: [
        SizedBox(width: 50, child: Text(label, style: const TextStyle(fontSize: 13))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: clamped,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${(clamped * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}
