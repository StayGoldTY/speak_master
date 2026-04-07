import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/progress_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/streak_card.dart';
import '../../widgets/daily_task_card.dart';
import '../../widgets/xp_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final authState = ref.watch(authProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, progress, authState)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: StreakCard(streakDays: progress.streakDays),
            ),
          ),
          SliverToBoxAdapter(child: _buildDailyTasks(context, progress)),
          SliverToBoxAdapter(child: _buildQuickActions(context)),
          SliverToBoxAdapter(child: _buildRecommendSection(context, progress)),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, progress, AuthState authState) {
    final name = authState.profile?.displayName ?? '发音学习者';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '你好，$name',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '今天也要大声朗读哦！',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          XpBar(currentXp: progress.totalXp, level: progress.level),
        ],
      ),
    );
  }

  Widget _buildDailyTasks(BuildContext context, progress) {
    final completedCount = progress.completedLessons.length % 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('今日任务', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text('$completedCount/3 完成', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          DailyTaskCard(
            title: '音素练习',
            subtitle: '今日重点：/θ/ 和 /ð/ 的舌齿摩擦',
            icon: Icons.record_voice_over,
            color: AppColors.vowelColor,
            isCompleted: completedCount > 0,
            xpReward: 10,
          ),
          const SizedBox(height: 8),
          DailyTaskCard(
            title: '朗读训练',
            subtitle: '跟读一段 TED 演讲片段',
            icon: Icons.menu_book,
            color: AppColors.primary,
            isCompleted: completedCount > 1,
            xpReward: 10,
          ),
          const SizedBox(height: 8),
          DailyTaskCard(
            title: '发音测试',
            subtitle: '5 道最小对立体听辨题',
            icon: Icons.quiz,
            color: AppColors.suprasegmentalColor,
            isCompleted: completedCount > 2,
            xpReward: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionButton(
              icon: Icons.school, label: '继续学习', color: AppColors.primary,
              onTap: () => context.go('/learn'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.mic, label: '自由朗读', color: AppColors.secondary,
              onTap: () => context.go('/practice'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.assessment, label: '发音测评', color: AppColors.accent,
              onTap: () => context.push('/assessment'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendSection(BuildContext context, progress) {
    final weakPhonemes = progress.phonemeScores.entries
        .where((e) => e.value < 70)
        .map((e) => e.key)
        .take(3)
        .join('、');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('推荐练习', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: AppColors.gradientPrimary, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.trending_up, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('薄弱音素强化', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        weakPhonemes.isNotEmpty ? '需要加强：$weakPhonemes' : '坚持练习，不断进步！',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
