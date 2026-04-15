import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../data/lessons_data.dart';
import '../../data/unit_roadmaps_data.dart';
import '../../data/units_data.dart';
import '../../models/unit.dart';

class TutorialMapScreen extends StatelessWidget {
  const TutorialMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final releasedUnits = UnitsData.units
        .where(
          (unit) =>
              LessonsData.isReleasedUnit(unit.id) &&
              LessonsData.hasAuthoredLessons(unit.id),
        )
        .toList();
    final releasedLessons = releasedUnits.fold<int>(
      0,
      (sum, unit) => sum + LessonsData.getAuthoredLessonCount(unit.id),
    );
    final previewUnits = UnitsData.units
        .where((unit) => !LessonsData.isReleasedUnit(unit.id))
        .length;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            centerTitle: true,
            title: Text('发音教程', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SliverToBoxAdapter(
            child: _PageFrame(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: _IntroCard(
                  releasedUnitCount: releasedUnits.length,
                  releasedLessonCount: releasedLessons,
                  previewUnitCount: previewUnits,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: _PageFrame(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: _MethodStrip(),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _PageFrame(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: _BlockSection(block: UnitsData.blocks[index]),
                ),
              ),
              childCount: UnitsData.blocks.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _PageFrame extends StatelessWidget {
  final Widget child;

  const _PageFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: child,
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  final int releasedUnitCount;
  final int releasedLessonCount;
  final int previewUnitCount;

  const _IntroCard({
    required this.releasedUnitCount,
    required this.releasedLessonCount,
    required this.previewUnitCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 760;

          return isWide
              ? Row(
                  children: [
                    const Expanded(child: _IntroCopy()),
                    const SizedBox(width: 24),
                    _IntroStats(
                      releasedUnitCount: releasedUnitCount,
                      releasedLessonCount: releasedLessonCount,
                      previewUnitCount: previewUnitCount,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _IntroCopy(),
                    const SizedBox(height: 18),
                    _IntroStats(
                      releasedUnitCount: releasedUnitCount,
                      releasedLessonCount: releasedLessonCount,
                      previewUnitCount: previewUnitCount,
                    ),
                  ],
                );
        },
      ),
    );
  }
}

class _IntroCopy extends StatelessWidget {
  const _IntroCopy();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phase 1 Main Track',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 0.5,
            color: Colors.white70,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '先把 Foundation 与 Vowels 主线走扎实，再进入辅音、节奏、语法发音和 Phonics。',
          style: TextStyle(
            fontSize: 24,
            height: 1.35,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'u1-u10 现在是完整可学链路。u11-u32 仍然不会冒充“已上线课程”，但现在都能点进去看清楚：将学什么、常见误区、真实场景和完成标志。',
          style: TextStyle(fontSize: 14, height: 1.7, color: Colors.white70),
        ),
      ],
    );
  }
}

class _IntroStats extends StatelessWidget {
  final int releasedUnitCount;
  final int releasedLessonCount;
  final int previewUnitCount;

  const _IntroStats({
    required this.releasedUnitCount,
    required this.releasedLessonCount,
    required this.previewUnitCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatLine(label: '已开放单元', value: '$releasedUnitCount'),
          const SizedBox(height: 12),
          _StatLine(label: '真实课程数', value: '$releasedLessonCount'),
          const SizedBox(height: 12),
          const _StatLine(label: '当前阶段', value: 'u1-u10'),
          const SizedBox(height: 12),
          _StatLine(label: '可预览单元', value: '$previewUnitCount'),
        ],
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  final String label;
  final String value;

  const _StatLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _MethodStrip extends StatelessWidget {
  const _MethodStrip();

  @override
  Widget build(BuildContext context) {
    const items = [
      _MethodCardData(
        title: 'Observe',
        subtitle: '先看口型、气流和重音落点',
        icon: Icons.visibility_outlined,
        color: AppColors.primary,
      ),
      _MethodCardData(
        title: 'Contrast',
        subtitle: '再做最小对立，把边界练出来',
        icon: Icons.compare_arrows_rounded,
        color: AppColors.accentOrange,
      ),
      _MethodCardData(
        title: 'Transfer',
        subtitle: '最后带进短句、朗读和真实表达',
        icon: Icons.rocket_launch_outlined,
        color: AppColors.secondary,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 860) {
            return Row(
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  Expanded(child: _MethodCard(data: items[index])),
                  if (index != items.length - 1) const SizedBox(width: 12),
                ],
              ],
            );
          }

          return Column(
            children: [
              for (var index = 0; index < items.length; index++) ...[
                _MethodCard(data: items[index]),
                if (index != items.length - 1) const SizedBox(height: 10),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MethodCardData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _MethodCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class _MethodCard extends StatelessWidget {
  final _MethodCardData data;

  const _MethodCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data.icon, color: data.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
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

class _BlockSection extends StatelessWidget {
  final LearningBlock block;

  const _BlockSection({required this.block});

  @override
  Widget build(BuildContext context) {
    final units = UnitsData.getUnitsForBlock(block.id);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BlockHeader(block: block, units: units),
            const SizedBox(height: 14),
            if (isWide)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 154,
                ),
                itemCount: units.length,
                itemBuilder: (context, index) =>
                    _UnitTile(unit: units[index], color: block.color),
              )
            else
              ...units.map(
                (unit) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _UnitTile(unit: unit, color: block.color),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BlockHeader extends StatelessWidget {
  final LearningBlock block;
  final List<LearningUnit> units;

  const _BlockHeader({required this.block, required this.units});

  @override
  Widget build(BuildContext context) {
    final releasedCount = units
        .where((unit) => LessonsData.isReleasedUnit(unit.id))
        .length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: block.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: block.color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: block.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(block.icon, color: block.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  block.titleCn,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  block.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$releasedCount / ${block.unitCount}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: block.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitTile extends StatelessWidget {
  final LearningUnit unit;
  final Color color;

  const _UnitTile({required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    final isReleased =
        LessonsData.isReleasedUnit(unit.id) &&
        LessonsData.hasAuthoredLessons(unit.id);
    final hasAuthoredContent = LessonsData.hasAuthoredLessons(unit.id);
    final roadmap = UnitRoadmapsData.maybeOf(unit.id);

    final statusLabel = isReleased
        ? '已开放'
        : hasAuthoredContent
        ? '内容预告'
        : '路线预告';
    final supportLine = isReleased
        ? '${LessonsData.getAuthoredLessonCount(unit.id)} 节真实课程'
        : roadmap?.coreSkill ?? '当前不会开放进入，但可以先浏览学习路线。';

    return InkWell(
      key: ValueKey('unit-tile-${unit.id}'),
      onTap: () => context.push('/unit/${unit.id}'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isReleased
                ? color.withValues(alpha: 0.18)
                : color.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isReleased ? 0.12 : 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  '${unit.order}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isReleased ? color : color.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          unit.titleCn,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        key: ValueKey('status-${unit.id}'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(
                            alpha: isReleased ? 0.12 : 0.08,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isReleased
                                ? color
                                : color.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    unit.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (!isReleased && roadmap != null) ...[
                    Text(
                      roadmap.stageLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    supportLine,
                    style: TextStyle(
                      fontSize: 12,
                      color: isReleased ? color : AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              isReleased ? Icons.chevron_right : Icons.visibility_outlined,
              color: isReleased ? color : color.withValues(alpha: 0.72),
            ),
          ],
        ),
      ),
    );
  }
}
