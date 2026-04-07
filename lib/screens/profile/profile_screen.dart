import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/progress_provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final authState = ref.watch(authProvider);

    return SafeArea(
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
            _buildPhonemeRadar(progress),
            const SizedBox(height: 20),
            _buildSettingsList(context, ref, authState),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, progress, AuthState authState) {
    final name = authState.profile?.displayName ?? '发音学习者';
    final isLoggedIn = authState.status == AuthStatus.authenticated;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: AppColors.gradientPrimary, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32, backgroundColor: Colors.white24,
            child: Text(name[0], style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Lv.${progress.level} · ${progress.totalXp} XP', style: TextStyle(color: Colors.white.withValues(alpha: 0.8))),
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
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
            child: Text(
              isLoggedIn ? (progress.isPro ? 'Pro' : '免费版') : '未登录',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(progress) {
    return Row(
      children: [
        Expanded(child: _StatBox(value: '${progress.streakDays}', label: '连续天数', icon: Icons.local_fire_department, color: AppColors.streakFlame)),
        const SizedBox(width: 10),
        Expanded(child: _StatBox(value: '${progress.completedLessons.length}', label: '已完成课程', icon: Icons.check_circle, color: AppColors.successGreen)),
        const SizedBox(width: 10),
        Expanded(child: _StatBox(value: '${progress.level}', label: '当前等级', icon: Icons.star, color: AppColors.xpGold)),
      ],
    );
  }

  Widget _buildAchievements(progress) {
    final earned = progress.earnedBadges as Set<String>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('成就徽章', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _BadgeItem(emoji: '🔥', label: '7天连续', isEarned: earned.contains('streak_bronze')),
              const SizedBox(width: 12),
              _BadgeItem(emoji: '🥈', label: '30天连续', isEarned: earned.contains('streak_silver')),
              const SizedBox(width: 12),
              _BadgeItem(emoji: '🥇', label: '90天连续', isEarned: earned.contains('streak_gold')),
              const SizedBox(width: 12),
              _BadgeItem(emoji: '💎', label: '365天', isEarned: earned.contains('streak_diamond')),
              const SizedBox(width: 12),
              _BadgeItem(emoji: '🎓', label: 'Lv.10', isEarned: earned.contains('level_10')),
              const SizedBox(width: 12),
              _BadgeItem(emoji: '🏆', label: 'Lv.25', isEarned: earned.contains('level_25')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhonemeRadar(progress) {
    final scores = progress.phonemeScores as Map<String, double>;
    final vowelAvg = _avgCategory(scores, 'v_');
    final consAvg = _avgCategory(scores, 'c_');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('音素掌握度', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _PhonemeBar(label: '元音', progress: vowelAvg, color: AppColors.vowelColor),
          const SizedBox(height: 10),
          _PhonemeBar(label: '辅音', progress: consAvg, color: AppColors.consonantColor),
          const SizedBox(height: 10),
          _PhonemeBar(label: '综合', progress: (vowelAvg + consAvg) / 2, color: AppColors.primary),
        ],
      ),
    );
  }

  double _avgCategory(Map<String, double> scores, String prefix) {
    final filtered = scores.entries.where((e) => e.key.startsWith(prefix));
    if (filtered.isEmpty) return 0;
    return filtered.map((e) => e.value).reduce((a, b) => a + b) / filtered.length / 100;
  }

  Widget _buildSettingsList(BuildContext context, WidgetRef ref, AuthState authState) {
    final isLoggedIn = authState.status == AuthStatus.authenticated;

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          if (!isLoggedIn)
            _SettingsTile(
              icon: Icons.login, label: '登录 / 注册', color: AppColors.primary,
              onTap: () => context.push('/auth'),
            ),
          if (!isLoggedIn) const Divider(height: 1),
          _SettingsTile(icon: Icons.language, label: '口音偏好', color: AppColors.secondary, onTap: () {}),
          const Divider(height: 1),
          _SettingsTile(icon: Icons.notifications_outlined, label: '提醒设置', color: AppColors.primary, onTap: () {}),
          const Divider(height: 1),
          _SettingsTile(icon: Icons.help_outline, label: '帮助与反馈', color: AppColors.textSecondary, onTap: () {}),
          const Divider(height: 1),
          _SettingsTile(icon: Icons.info_outline, label: '关于声临其境', color: AppColors.textSecondary, onTap: () {}),
          if (isLoggedIn) ...[
            const Divider(height: 1),
            _SettingsTile(
              icon: Icons.logout, label: '退出登录', color: AppColors.errorRed,
              onTap: () => ref.read(authProvider.notifier).signOut(),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _StatBox({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
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
  final String emoji;
  final String label;
  final bool isEarned;
  const _BadgeItem({required this.emoji, required this.label, required this.isEarned});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: isEarned ? AppColors.xpGold.withValues(alpha: 0.15) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isEarned ? AppColors.xpGold.withValues(alpha: 0.3) : Colors.grey.shade200),
          ),
          child: Center(child: Text(emoji, style: TextStyle(fontSize: 24, color: isEarned ? null : Colors.grey))),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: isEarned ? AppColors.textPrimary : AppColors.textHint)),
      ],
    );
  }
}

class _PhonemeBar extends StatelessWidget {
  final String label;
  final double progress;
  final Color color;
  const _PhonemeBar({required this.label, required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(width: 50, child: Text(label, style: const TextStyle(fontSize: 13))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: clamped, backgroundColor: color.withValues(alpha: 0.1), valueColor: AlwaysStoppedAnimation(color), minHeight: 10),
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
  final Color color;
  final VoidCallback onTap;
  const _SettingsTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}
