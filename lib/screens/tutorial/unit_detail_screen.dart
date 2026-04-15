import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../data/lessons_data.dart';
import '../../data/phonemes_data.dart';
import '../../data/unit_roadmaps_data.dart';
import '../../data/units_data.dart';
import '../../models/lesson.dart';
import '../../models/phoneme.dart';
import '../../models/unit.dart';
import '../../widgets/phoneme_card.dart';

class UnitDetailScreen extends StatelessWidget {
  final String unitId;

  const UnitDetailScreen({super.key, required this.unitId});

  @override
  Widget build(BuildContext context) {
    final unit = UnitsData.units.firstWhere((item) => item.id == unitId);
    final block = UnitsData.blocks.firstWhere(
      (item) => item.id == unit.blockId,
    );
    final isReleased =
        LessonsData.isReleasedUnit(unit.id) &&
        LessonsData.hasAuthoredLessons(unit.id);
    final phonemes = unit.targetPhonemes
        .map(
          (id) => PhonemesData.allPhonemes.where((phoneme) => phoneme.id == id),
        )
        .expand((items) => items)
        .toList();

    if (!isReleased) {
      return _UpcomingUnitScreen(
        unit: unit,
        block: block,
        roadmap: UnitRoadmapsData.maybeOf(unit.id),
      );
    }

    final lessons = LessonsData.getLessonsForUnit(unit.id);
    final totalMinutes = lessons.fold<int>(
      0,
      (sum, lesson) => sum + lesson.estimatedMinutes,
    );

    return Scaffold(
      appBar: AppBar(title: Text(unit.titleCn)),
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
                      stageLabel: 'Released Unit',
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
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
  final LearningUnit unit;
  final LearningBlock block;
  final UnitRoadmap? roadmap;

  const _UpcomingUnitScreen({
    required this.unit,
    required this.block,
    required this.roadmap,
  });

  @override
  Widget build(BuildContext context) {
    final previewLessons = _buildPreviewLessons(unit.id, roadmap);
    final hasAuthoredPreview = LessonsData.hasAuthoredLessons(unit.id);
    final isWide = MediaQuery.sizeOf(context).width >= 920;

    return Scaffold(
      appBar: AppBar(title: Text(unit.titleCn)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroCard(
                  unitTitle: unit.titleCn,
                  unitOrder: unit.order,
                  blockColor: block.color,
                  blockIcon: block.icon,
                  description: roadmap?.coreSkill ?? unit.description,
                  stageLabel: hasAuthoredPreview
                      ? 'Preview Ready'
                      : 'Roadmap Preview',
                ),
                const SizedBox(height: 18),
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _RoadmapCard(
                          key: ValueKey('upcoming-roadmap-${unit.id}'),
                          title: '你会学到什么',
                          items:
                              roadmap?.outcomes ??
                              const ['核心口型与气流动作', '高频最小对立对比', '带进短句和真实表达'],
                          accentColor: block.color,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        flex: 2,
                        child: _PreviewStatusCard(
                          roadmap: roadmap,
                          blockTitle: block.titleCn,
                          hasAuthoredPreview: hasAuthoredPreview,
                        ),
                      ),
                    ],
                  )
                else ...[
                  _RoadmapCard(
                    key: ValueKey('upcoming-roadmap-${unit.id}'),
                    title: '你会学到什么',
                    items:
                        roadmap?.outcomes ??
                        const ['核心口型与气流动作', '高频最小对立对比', '带进短句和真实表达'],
                    accentColor: block.color,
                  ),
                  const SizedBox(height: 16),
                  _PreviewStatusCard(
                    roadmap: roadmap,
                    blockTitle: block.titleCn,
                    hasAuthoredPreview: hasAuthoredPreview,
                  ),
                ],
                const SizedBox(height: 18),
                _RoadmapCard(
                  title: '常见误区',
                  items:
                      roadmap?.pitfalls ??
                      const [
                        '先学会慢速对比，再追求速度',
                        '不要把中文近似音直接套进去',
                        '不要因为未开放就完全跳过后续概念',
                      ],
                  accentColor: AppColors.accentOrange,
                ),
                const SizedBox(height: 18),
                _RoadmapCard(
                  title: '真实场景',
                  items:
                      roadmap?.practiceScenes ?? const ['日常对话', '短句朗读', '自我表达'],
                  accentColor: AppColors.secondary,
                ),
                const SizedBox(height: 24),
                Text(
                  hasAuthoredPreview ? '计划中的 3 节结构（已写好草稿）' : '计划中的 3 节结构',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                ...previewLessons.map(
                  (lesson) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PreviewLessonTile(
                      lesson: lesson,
                      accentColor: block.color,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '这里展示的是路线图和课程预告，不是假装可学的占位课。当前未开放单元仍不会进入 lesson 页面；等真正开放时，你看到的会是可完成、可记录进度的真实课程。',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.7,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton(
                      onPressed: () => context.go('/learn'),
                      child: const Text('返回教程地图'),
                    ),
                    OutlinedButton(
                      onPressed: () => context.go('/practice'),
                      child: const Text('先去练习中心'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static List<_PreviewLesson> _buildPreviewLessons(
    String unitId,
    UnitRoadmap? roadmap,
  ) {
    if (LessonsData.hasAuthoredLessons(unitId)) {
      return LessonsData.getLessonsForUnit(unitId)
          .map(
            (lesson) => _PreviewLesson(
              title: lesson.titleCn,
              description: lesson.description,
            ),
          )
          .toList();
    }

    final titles =
        roadmap?.lessonPreviewTitles ?? const ['核心概念拆解', '对比训练', '迁移到句子'];

    return List.generate(
      titles.length,
      (index) => _PreviewLesson(
        title: titles[index],
        description: index == 0
            ? '先理解这个单元真正要解决的动作或规则。'
            : index == 1
            ? '通过最小对立或结构对比把边界练清楚。'
            : '把技能带进短句、朗读或自我表达里。',
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
  final String stageLabel;

  const _HeroCard({
    required this.unitTitle,
    required this.unitOrder,
    required this.blockColor,
    required this.blockIcon,
    required this.description,
    required this.stageLabel,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$stageLabel · Unit $unitOrder',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  unitTitle,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.6,
                  ),
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.7,
            ),
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
              children: phonemes
                  .map((phoneme) => PhonemeCard(phoneme: phoneme))
                  .toList(),
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
              '建议按顺序完成 3 节课，再进入下一单元。每节课都提供诚实的自练入口，不会假装已经接入自动评分或标准音频。',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.65,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoadmapCard extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color accentColor;

  const _RoadmapCard({
    super.key,
    required this.title,
    required this.items,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentColor.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewStatusCard extends StatelessWidget {
  final UnitRoadmap? roadmap;
  final String blockTitle;
  final bool hasAuthoredPreview;

  const _PreviewStatusCard({
    required this.roadmap,
    required this.blockTitle,
    required this.hasAuthoredPreview,
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
            '开放状态',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          _MetaRow(label: '所在模块', value: blockTitle),
          _MetaRow(
            label: '当前状态',
            value: hasAuthoredPreview ? '已写课程预告，尚未发布' : '路线预告，尚未发布',
          ),
          if (roadmap != null)
            _MetaRow(label: '解锁建议', value: roadmap!.unlockHint),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              roadmap?.completionSignal ?? '等这组内容开放后，你会在这里看到更明确的完成标志。',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.65,
              ),
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

  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 74,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.55,
                    ),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
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

class _PreviewLessonTile extends StatelessWidget {
  final _PreviewLesson lesson;
  final Color accentColor;

  const _PreviewLessonTile({required this.lesson, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.visibility_outlined,
              color: accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  lesson.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.55,
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

class _PreviewLesson {
  final String title;
  final String description;

  const _PreviewLesson({required this.title, required this.description});
}
