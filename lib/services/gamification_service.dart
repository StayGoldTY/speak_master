import '../models/user_progress.dart';
import '../core/constants/app_constants.dart';

class GamificationService {
  UserProgress updateStreak(UserProgress progress) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (progress.lastActiveDate == null) {
      return progress.copyWith(streakDays: 1, lastActiveDate: today);
    }

    final lastActive = DateTime(
      progress.lastActiveDate!.year,
      progress.lastActiveDate!.month,
      progress.lastActiveDate!.day,
    );

    final difference = today.difference(lastActive).inDays;

    if (difference == 0) return progress;

    if (difference == 1) {
      return progress.copyWith(
        streakDays: progress.streakDays + 1,
        lastActiveDate: today,
      );
    }

    if (difference == 2 && progress.streakFreezeRemaining > 0) {
      return progress.copyWith(
        streakDays: progress.streakDays + 1,
        lastActiveDate: today,
        streakFreezeRemaining: progress.streakFreezeRemaining - 1,
      );
    }

    return progress.copyWith(streakDays: 1, lastActiveDate: today);
  }

  UserProgress addXp(UserProgress progress, int xp) {
    final newXp = progress.totalXp + xp;
    var newLevel = progress.level;

    while (newXp >= newLevel * 100) {
      newLevel++;
    }

    return progress.copyWith(totalXp: newXp, level: newLevel);
  }

  UserProgress checkBadges(UserProgress progress) {
    final badges = Set<String>.from(progress.earnedBadges);

    if (progress.streakDays >= AppConstants.streakBronze) badges.add('streak_bronze');
    if (progress.streakDays >= AppConstants.streakSilver) badges.add('streak_silver');
    if (progress.streakDays >= AppConstants.streakGold) badges.add('streak_gold');
    if (progress.streakDays >= AppConstants.streakDiamond) badges.add('streak_diamond');

    if (progress.level >= 10) badges.add('level_10');
    if (progress.level >= 25) badges.add('level_25');
    if (progress.level >= 50) badges.add('level_50');

    return progress.copyWith(earnedBadges: badges);
  }

  List<DailyTask> generateDailyTasks(UserProgress progress) {
    return [
      DailyTask(
        id: 'daily_phoneme',
        title: '音素练习',
        description: '完成今日重点音素的跟读训练',
        type: TaskType.phonemePractice,
        xpReward: AppConstants.xpPerReadAloud,
      ),
      DailyTask(
        id: 'daily_read',
        title: '朗读训练',
        description: '跟读一段精选英文文章',
        type: TaskType.readAloud,
        xpReward: AppConstants.xpPerReadAloud,
      ),
      DailyTask(
        id: 'daily_quiz',
        title: '发音测试',
        description: '完成5道听辨选择题',
        type: TaskType.assessmentQuiz,
        xpReward: AppConstants.xpPerPerfectScore,
      ),
    ];
  }

  String getStreakEmoji(int days) {
    if (days >= 365) return '💎';
    if (days >= 90) return '🥇';
    if (days >= 30) return '🥈';
    if (days >= 7) return '🥉';
    if (days > 0) return '🔥';
    return '⭐';
  }
}
