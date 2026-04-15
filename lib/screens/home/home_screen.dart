import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../data/lessons_data.dart';
import '../../data/units_data.dart';
import '../../models/lesson.dart';
import '../../models/user_progress.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/streak_card.dart';
import '../../widgets/xp_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final authState = ref.watch(authProvider);
    final releasedUnits = UnitsData.units
        .where((unit) => LessonsData.isReleasedUnit(unit.id) && LessonsData.hasAuthoredLessons(unit.id))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    final nextLesson = _findNextLesson(progress.completedLessons);
    final totalReleasedLessons = releasedUnits.fold<int>(
      0,
      (sum, unit) => sum + LessonsData.getAuthoredLessonCount(unit.id),
    );
    final completedReleasedLessons = releasedUnits.fold<int>(
      0,
      (sum, unit) =>
          sum +
          LessonsData.getLessonsForUnit(unit.id)
              .where((lesson) => progress.completedLessons.contains(lesson.id))
              .length,
    );
    final weakPhonemes = progress.phonemeScores.entries
        .where((entry) => entry.value < 70)
        .map((entry) => entry.key.replaceFirst(RegExp(r'^[vc]_'), ''))
        .take(4)
        .toList();

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: _Header(
                    displayName: authState.profile?.displayName ?? '朗读学习者',
                    xp: progress.totalXp,
                    level: progress.level,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: StreakCard(streakDays: progress.streakDays),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _ContinueCard(
                    nextLesson: nextLesson,
                    completedReleasedLessons: completedReleasedLessons,
                    totalReleasedLessons: totalReleasedLessons,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _QuickActions(
                    onLearn: () => context.go('/learn'),
                    onPractice: () => context.go('/practice'),
                    onAssessment: () => context.push('/assessment'),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _RecommendationSection(
                    progress: progress,
                    nextLesson: nextLesson,
                    weakPhonemes: weakPhonemes,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: _WeakSoundSection(weakPhonemes: weakPhonemes),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Lesson? _findNextLesson(Set<String> completedLessonIds) {
    final releasedUnits = [...UnitsData.units]..sort((a, b) => a.order.compareTo(b.order));

    for (final unit in releasedUnits) {
      if (!LessonsData.isReleasedUnit(unit.id) || !LessonsData.hasAuthoredLessons(unit.id)) {
        continue;
      }

      for (final lesson in LessonsData.getLessonsForUnit(unit.id)) {
        if (!completedLessonIds.contains(lesson.id)) {
          return lesson;
        }
      }
    }

    return null;
  }
}

class _Header extends StatelessWidget {
  final String displayName;
  final int xp;
  final int level;

  const _Header({
    required this.displayName,
    required this.xp,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '你好，$displayName',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 6),
              const Text(
                '今天继续把嘴巴打开一点，把发音边界练清楚一点。',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        XpBar(currentXp: xp, level: level),
      ],
    );
  }
}

class _ContinueCard extends StatelessWidget {
  final Lesson? nextLesson;
  final int completedReleasedLessons;
  final int totalReleasedLessons;

  const _ContinueCard({
    required this.nextLesson,
    required this.completedReleasedLessons,
    required this.totalReleasedLessons,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalReleasedLessons == 0 ? 0.0 : completedReleasedLessons / totalReleasedLessons;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '继续学习',
            style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            nextLesson?.titleCn ?? '第一阶段课程已经全部完成',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, height: 1.25),
          ),
          const SizedBox(height: 10),
          Text(
            nextLesson?.description ?? '可以回到练习中心继续做自由朗读、跟读练习或自评巩固。',
            style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.7),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$completedReleasedLessons / $totalReleasedLessons 节已完成',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: nextLesson == null
                ? () => context.go('/practice')
                : () => context.push('/lesson/${nextLesson!.id}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
            ),
            child: Text(nextLesson == null ? '去练习中心' : '继续这节课'),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onLearn;
  final VoidCallback onPractice;
  final VoidCallback onAssessment;

  const _QuickActions({
    required this.onLearn,
    required this.onPractice,
    required this.onAssessment,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 760;
        final items = [
          _ActionCardData(
            title: '教程地图',
            subtitle: '回到主线单元，继续按顺序推进',
            icon: Icons.school_outlined,
            color: AppColors.primary,
            onTap: onLearn,
          ),
          _ActionCardData(
            title: '练习中心',
            subtitle: '自由朗读、跟读参考和绕口令挑战',
            icon: Icons.mic_none_rounded,
            color: AppColors.secondary,
            onTap: onPractice,
          ),
          _ActionCardData(
            title: '朗读自评',
            subtitle: '做一次诚实自查，看看下一轮该练什么',
            icon: Icons.analytics_outlined,
            color: AppColors.accentOrange,
            onTap: onAssessment,
          ),
        ];

        if (isWide) {
          return Row(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                Expanded(child: _ActionCard(data: items[i])),
                if (i != items.length - 1) const SizedBox(width: 12),
              ],
            ],
          );
        }

        return Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              _ActionCard(data: items[i]),
              if (i != items.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _ActionCardData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _ActionCard extends StatelessWidget {
  final _ActionCardData data;

  const _ActionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: data.color.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(data.icon, color: data.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.subtitle,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.55),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: data.color),
          ],
        ),
      ),
    );
  }
}

class _RecommendationSection extends StatelessWidget {
  final UserProgress progress;
  final Lesson? nextLesson;
  final List<String> weakPhonemes;

  const _RecommendationSection({
    required this.progress,
    required this.nextLesson,
    required this.weakPhonemes,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _RecommendationCardData(
        title: '主线优先',
        subtitle: nextLesson != null ? '先推进 ${nextLesson!.titleCn}' : '主线课程已清空，转去练习中心巩固即可',
        accent: AppColors.primary,
      ),
      _RecommendationCardData(
        title: '今天做一次自评',
        subtitle: progress.todayAssessmentCount > 0 ? '你今天已经完成过一次自评，可以按结果回练' : '至少拿到一份今天的自查结果，才能知道下一轮怎么练',
        accent: AppColors.accentOrange,
      ),
      _RecommendationCardData(
        title: '回看薄弱音',
        subtitle: weakPhonemes.isEmpty ? '目前没有明显偏弱音位记录，继续按主线推进' : '优先回练 /${weakPhonemes.join('/ /')}/ 这些位置',
        accent: AppColors.secondary,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '今日建议',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        ...cards.map(
          (card) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: card.accent.withValues(alpha: 0.18)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: card.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.title,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          card.subtitle,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.55),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecommendationCardData {
  final String title;
  final String subtitle;
  final Color accent;

  const _RecommendationCardData({
    required this.title,
    required this.subtitle,
    required this.accent,
  });
}

class _WeakSoundSection extends StatelessWidget {
  final List<String> weakPhonemes;

  const _WeakSoundSection({required this.weakPhonemes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '建议强化',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            weakPhonemes.isEmpty
                ? '你目前还没有明显偏弱的音位记录，可以继续按教程顺序推进，或者做一轮自评建立基线。'
                : '优先复习这些偏弱音位：/${weakPhonemes.join('/ /')}/。',
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.7),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: weakPhonemes.isEmpty
                ? const [
                    _StrengthChip(label: '继续保持'),
                    _StrengthChip(label: '去做一次自评'),
                  ]
                : weakPhonemes.map((item) => _StrengthChip(label: '/$item/')).toList(),
          ),
        ],
      ),
    );
  }
}

class _StrengthChip extends StatelessWidget {
  final String label;

  const _StrengthChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.primary),
      ),
    );
  }
}
