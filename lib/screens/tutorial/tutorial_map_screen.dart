import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../data/lessons_data.dart';
import '../../data/units_data.dart';
import '../../models/unit.dart';

class TutorialMapScreen extends StatelessWidget {
  const TutorialMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final releasedUnits = UnitsData.units
        .where((unit) => LessonsData.isReleasedUnit(unit.id) && LessonsData.hasAuthoredLessons(unit.id))
        .toList();
    final releasedLessons = releasedUnits.fold<int>(
      0,
      (sum, unit) => sum + LessonsData.getAuthoredLessonCount(unit.id),
    );

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            centerTitle: true,
            title: Text(
              '发音教程',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SliverToBoxAdapter(
            child: _PageFrame(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: _IntroCard(
                  releasedUnitCount: releasedUnits.length,
                  releasedLessonCount: releasedLessons,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _PageFrame(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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

  const _IntroCard({
    required this.releasedUnitCount,
    required this.releasedLessonCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
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
          '第一阶段主线',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 0.4,
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '先把 Foundation + Vowels 这一段主线走扎实，再逐步开放更难的模块。',
          style: TextStyle(
            fontSize: 24,
            height: 1.35,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12),
        Text(
          '当前公开学习链路固定为 u1-u10。后续单元统一展示为“即将开放”，避免你误点进占位课或半成品页面。',
          style: TextStyle(
            fontSize: 14,
            height: 1.7,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _IntroStats extends StatelessWidget {
  final int releasedUnitCount;
  final int releasedLessonCount;

  const _IntroStats({
    required this.releasedUnitCount,
    required this.releasedLessonCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
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
            _BlockHeader(block: block),
            const SizedBox(height: 14),
            if (isWide)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 132,
                ),
                itemCount: units.length,
                itemBuilder: (context, index) => _UnitTile(
                  unit: units[index],
                  color: block.color,
                ),
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

  const _BlockHeader({required this.block});

  @override
  Widget build(BuildContext context) {
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
            '${block.unitCount} 单元',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
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

  const _UnitTile({
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isReleased = LessonsData.isReleasedUnit(unit.id) && LessonsData.hasAuthoredLessons(unit.id);
    final hasAuthoredContent = LessonsData.hasAuthoredLessons(unit.id);
    final statusLabel = isReleased
        ? '已开放'
        : hasAuthoredContent
            ? '下一阶段'
            : '即将开放';

    return InkWell(
      key: ValueKey('unit-tile-${unit.id}'),
      onTap: isReleased ? () => context.push('/unit/${unit.id}') : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isReleased ? Colors.white : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isReleased ? color.withValues(alpha: 0.2) : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isReleased ? color.withValues(alpha: 0.1) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  '${unit.order}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isReleased ? color : Colors.grey.shade500,
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
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isReleased ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Container(
                        key: ValueKey('status-${unit.id}'),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isReleased ? color.withValues(alpha: 0.1) : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isReleased ? color : AppColors.textSecondary,
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
                  Text(
                    isReleased
                        ? '${LessonsData.getAuthoredLessonCount(unit.id)} 节真实课程'
                        : '本阶段不开放进入，避免占位内容打断学习节奏。',
                    style: TextStyle(
                      fontSize: 12,
                      color: isReleased ? color : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              isReleased ? Icons.chevron_right : Icons.schedule,
              color: isReleased ? color : AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
