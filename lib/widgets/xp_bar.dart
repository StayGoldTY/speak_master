import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class XpBar extends StatelessWidget {
  final int currentXp;
  final int level;

  const XpBar({super.key, required this.currentXp, required this.level});

  @override
  Widget build(BuildContext context) {
    final xpForNext = level * 100;
    final progress = (currentXp % xpForNext) / xpForNext;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.gradientPrimary,
            ),
            child: Center(
              child: Text(
                'Lv$level',
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$currentXp XP',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
