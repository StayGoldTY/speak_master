import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class StreakCard extends StatelessWidget {
  final int streakDays;

  const StreakCard({
    super.key,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.gradientStreak,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.streakFlame.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(_streakIcon(streakDays), color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '连续练习',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  '$streakDays 天',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _WeekDots(streakDays: streakDays),
              const SizedBox(height: 10),
              Text(
                _badgeLabel(streakDays),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static IconData _streakIcon(int days) {
    if (days >= 365) return Icons.diamond_outlined;
    if (days >= 90) return Icons.workspace_premium_outlined;
    if (days >= 30) return Icons.local_fire_department_outlined;
    return Icons.auto_awesome_outlined;
  }

  static String _badgeLabel(int days) {
    if (days >= 365) return '钻石连练';
    if (days >= 90) return '黄金连练';
    if (days >= 30) return '白银连练';
    if (days >= 7) return '青铜连练';
    return '继续保持';
  }
}

class _WeekDots extends StatelessWidget {
  final int streakDays;

  const _WeekDots({required this.streakDays});

  @override
  Widget build(BuildContext context) {
    final activeCount = streakDays % 7 == 0 && streakDays > 0 ? 7 : streakDays % 7;

    return Row(
      children: List.generate(
        7,
        (index) => Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < activeCount ? Colors.white : Colors.white.withValues(alpha: 0.28),
          ),
        ),
      ),
    );
  }
}
