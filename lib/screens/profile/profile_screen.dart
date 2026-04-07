import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 20),
            _buildStatsGrid(),
            const SizedBox(height: 20),
            _buildAchievements(context),
            const SizedBox(height: 20),
            _buildPhonemeRadar(context),
            const SizedBox(height: 20),
            _buildSettingsList(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '发音学习者',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lv.5 · 350 XP',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.7,
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
            child: const Text(
              '免费版',
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(child: _StatBox(value: '12', label: '连续天数', icon: Icons.local_fire_department, color: AppColors.streakFlame)),
        const SizedBox(width: 10),
        Expanded(child: _StatBox(value: '48', label: '已完成课程', icon: Icons.check_circle, color: AppColors.successGreen)),
        const SizedBox(width: 10),
        Expanded(child: _StatBox(value: '78', label: '平均评分', icon: Icons.star, color: AppColors.xpGold)),
      ],
    );
  }

  Widget _buildAchievements(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('成就徽章', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: const Text('查看全部')),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _BadgeItem(emoji: '🔥', label: '7天连续', isEarned: true),
              SizedBox(width: 12),
              _BadgeItem(emoji: '🎯', label: '首次满分', isEarned: true),
              SizedBox(width: 12),
              _BadgeItem(emoji: '👂', label: '听辨达人', isEarned: true),
              SizedBox(width: 12),
              _BadgeItem(emoji: '🥈', label: '30天连续', isEarned: false),
              SizedBox(width: 12),
              _BadgeItem(emoji: '🏆', label: '元音大师', isEarned: false),
              SizedBox(width: 12),
              _BadgeItem(emoji: '💎', label: '365天', isEarned: false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhonemeRadar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('音素掌握度', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _PhonemeBar(label: '元音', progress: 0.72, color: AppColors.vowelColor),
          const SizedBox(height: 10),
          _PhonemeBar(label: '辅音', progress: 0.58, color: AppColors.consonantColor),
          const SizedBox(height: 10),
          _PhonemeBar(label: '双元音', progress: 0.65, color: AppColors.primary),
          const SizedBox(height: 10),
          _PhonemeBar(label: '超音段', progress: 0.45, color: AppColors.suprasegmentalColor),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.analytics, size: 18),
              label: const Text('查看详细报告'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _SettingsTile(icon: Icons.workspace_premium, label: '升级 Pro', color: AppColors.xpGold, showBadge: true),
          const Divider(height: 1),
          _SettingsTile(icon: Icons.notifications_outlined, label: '提醒设置', color: AppColors.primary),
          const Divider(height: 1),
          _SettingsTile(icon: Icons.language, label: '口音偏好', color: AppColors.secondary),
          const Divider(height: 1),
          _SettingsTile(icon: Icons.download, label: '离线包管理', color: AppColors.consonantColor),
          const Divider(height: 1),
          _SettingsTile(icon: Icons.help_outline, label: '帮助与反馈', color: AppColors.textSecondary),
          const Divider(height: 1),
          _SettingsTile(icon: Icons.info_outline, label: '关于', color: AppColors.textSecondary),
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
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
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
  final String emoji;
  final String label;
  final bool isEarned;

  const _BadgeItem({required this.emoji, required this.label, required this.isEarned});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isEarned ? AppColors.xpGold.withValues(alpha: 0.15) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isEarned ? AppColors.xpGold.withValues(alpha: 0.3) : Colors.grey.shade200,
            ),
          ),
          child: Center(
            child: Text(
              emoji,
              style: TextStyle(fontSize: 24, color: isEarned ? null : Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: isEarned ? AppColors.textPrimary : AppColors.textHint),
        ),
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
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label, style: const TextStyle(fontSize: 13))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${(progress * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool showBadge;

  const _SettingsTile({required this.icon, required this.label, required this.color, this.showBadge = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.xpGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('推荐', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.accentOrange)),
            ),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.textHint),
        ],
      ),
      onTap: () {},
    );
  }
}
