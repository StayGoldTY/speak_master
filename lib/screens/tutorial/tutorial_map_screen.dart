import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/units_data.dart';
import '../../models/unit.dart';

class TutorialMapScreen extends StatelessWidget {
  const TutorialMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text('发音教程', style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.map_outlined),
                onPressed: () {},
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final block = UnitsData.blocks[index];
                return _BlockSection(block: block);
              },
              childCount: UnitsData.blocks.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBlockHeader(context),
          const SizedBox(height: 12),
          ...units.map((unit) => _UnitTile(unit: unit, color: block.color)),
        ],
      ),
    );
  }

  Widget _buildBlockHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: block.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: block.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: block.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(block.icon, color: block.color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '板块 ${UnitsData.blocks.indexOf(block) + 1}',
                  style: TextStyle(fontSize: 11, color: block.color, fontWeight: FontWeight.w600),
                ),
                Text(
                  block.titleCn,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Text(
                  block.subtitle,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '${block.unitCount} 单元',
            style: TextStyle(fontSize: 12, color: block.color, fontWeight: FontWeight.w500),
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
    final isLocked = unit.order > 4;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: isLocked ? null : () => context.push('/unit/${unit.id}'),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isLocked ? Colors.grey.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isLocked ? Colors.grey.shade200 : color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey.shade100 : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: isLocked
                      ? Icon(Icons.lock, color: Colors.grey.shade400, size: 18)
                      : Text(
                          '${unit.order}',
                          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit.titleCn,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isLocked ? AppColors.textHint : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      unit.description,
                      style: TextStyle(fontSize: 12, color: isLocked ? AppColors.textHint : AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (!isLocked) ...[
                Text(
                  '${unit.lessonCount} 课',
                  style: TextStyle(fontSize: 12, color: color),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: color, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
