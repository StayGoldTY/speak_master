import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../data/lessons_data.dart';
import '../../data/phonemes_data.dart';
import '../../data/units_data.dart';
import '../../models/lesson.dart';
import '../../models/phoneme.dart';
import '../../widgets/phoneme_card.dart';

class UnitDetailScreen extends StatelessWidget {
  final String unitId;

  const UnitDetailScreen({
    super.key,
    required this.unitId,
  });

  @override
  Widget build(BuildContext context) {
    final unit = UnitsData.units.firstWhere((item) => item.id == unitId);
    final block = UnitsData.blocks.firstWhere((item) => item.id == unit.blockId);
    final isReleased = LessonsData.isReleasedUnit(unit.id) && LessonsData.hasAuthoredLessons(unit.id);
    final phonemes = unit.targetPhonemes
        .map((id) => PhonemesData.allPhonemes.where((phoneme) => phoneme.id == id))
        .expand((items) => items)
        .toList();

    if (!isReleased) {
      return _UpcomingUnitScreen(unitTitle: unit.titleCn, blockTitle: block.titleCn);
    }

    final lessons = LessonsData.getLessonsForUnit(unit.id);
    final totalMinutes = lessons.fold<int>(0, (sum, lesson) => sum + lesson.estimatedMinutes);

    return Scaffold(
      appBar: AppBar(
        title: Text(unit.titleCn),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 920;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroCard(
                      unitTitle: unit.titleCn,
                      unitOrder: unit.order,
                      blockColor: block.color,
                      blockIcon: block.icon,
                      description: unit.description,
                    ),
                    const SizedBox(height: 18),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _SummaryCard(
                              titleEn: unit.titleEn,
                              description: unit.description,
                              phonemes: phonemes,
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            flex: 2,
                            child: _ProgressCard(
                              blockTitle: block.titleCn,
                              lessonCount: lessons.length,
                              totalMinutes: totalMinutes,
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _SummaryCard(
                        titleEn: unit.titleEn,
                        description: unit.description,
                        phonemes: phonemes,
                      ),
                      const SizedBox(height: 16),
                      _ProgressCard(
                        blockTitle: block.titleCn,
                        lessonCount: lessons.length,
                        totalMinutes: totalMinutes,
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      '课程列表',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    ...lessons.map(
                      (lesson) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _LessonTile(
                          lesson: lesson,
                          accentColor: block.color,
                          onTap: () => context.push('/lesson/${lesson.id}'),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _UpcomingUnitScreen extends StatelessWidget {
  final String unitTitle;
  final String blockTitle;

  const _UpcomingUnitScreen({
    required this.unitTitle,
    required this.blockTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(unitTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.schedule, color: AppColors.primary, size: 32),
                  const SizedBox(height: 16),
                  Text(
                    '$unitTitle 暂未开放',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '这个单元属于 $blockTitle 的后续阶段内容。为了避免你误入占位课或半成品页面，当前统一显示为“即将开放”。',
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.7),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('返回教程地图'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String unitTitle;
  final int unitOrder;
  final Color blockColor;
  final IconData blockIcon;
  final String description;

  const _HeroCard({
    required this.unitTitle,
    required this.unitOrder,
    required this.blockColor,
    required this.blockIcon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [blockColor, blockColor.withValues(alpha: 0.65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unit $unitOrder',
                  style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  unitTitle,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(blockIcon, color: Colors.white, size: 34),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String titleEn;
  final String description;
  final List<Phoneme> phonemes;

  const _SummaryCard({
    required this.titleEn,
    required this.description,
    required this.phonemes,
  });

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
          Text(
            titleEn,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.7),
          ),
          if (phonemes.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              '目标音位',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: phonemes.map((phoneme) => PhonemeCard(phoneme: phoneme)).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String blockTitle;
  final int lessonCount;
  final int totalMinutes;

  const _ProgressCard({
    required this.blockTitle,
    required this.lessonCount,
    required this.totalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            '学习概览',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          _MetaRow(label: '所属模块', value: blockTitle),
          _MetaRow(label: '真实课程', value: '$lessonCount 节'),
          _MetaRow(label: '预计时长', value: '$totalMinutes 分钟'),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              '建议按顺序完成三节课，再进入下一单元。每节课都提供诚实的自练入口，不会假装已经接入自动评分或标准音频。',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.65),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetaRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 74,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final Lesson lesson;
  final Color accentColor;
  final VoidCallback onTap;

  const _LessonTile({
    required this.lesson,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('lesson-tile-${lesson.id}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_iconForType(lesson.type), color: accentColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.titleCn,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson.description,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.55),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${lesson.estimatedMinutes} 分钟',
                  style: TextStyle(fontSize: 12, color: accentColor, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Icon(Icons.chevron_right, color: accentColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static IconData _iconForType(LessonType type) {
    return switch (type) {
      LessonType.theory => Icons.menu_book_outlined,
      LessonType.listen => Icons.headphones_outlined,
      LessonType.practice => Icons.mic_none_rounded,
      LessonType.discrimination => Icons.hearing_outlined,
      LessonType.game => Icons.extension_outlined,
    };
  }
}
