import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/units_data.dart';
import '../../data/phonemes_data.dart';
import '../../widgets/phoneme_card.dart';

class UnitDetailScreen extends StatelessWidget {
  final String unitId;

  const UnitDetailScreen({super.key, required this.unitId});

  @override
  Widget build(BuildContext context) {
    final unit = UnitsData.units.firstWhere((u) => u.id == unitId);
    final block = UnitsData.blocks.firstWhere((b) => b.id == unit.blockId);
    final phonemes = unit.targetPhonemes
        .map((id) => PhonemesData.allPhonemes.where((p) => p.id == id))
        .expand((e) => e)
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(unit.titleCn, style: const TextStyle(fontWeight: FontWeight.bold)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [block.color, block.color.withValues(alpha: 0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(block.icon, color: Colors.white.withValues(alpha: 0.3), size: 80),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '单元 ${unit.order}：${unit.titleEn}',
                    style: TextStyle(fontSize: 14, color: block.color, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(unit.description, style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  if (phonemes.isNotEmpty) ...[
                    const Text('目标音素', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: phonemes.map((p) => PhonemeCard(phoneme: p)).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  const Text('课程列表', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _LessonTile(
                  index: index + 1,
                  color: block.color,
                  onTap: () => context.push('/lesson/${unit.id}_lesson_${index + 1}'),
                );
              },
              childCount: unit.lessonCount,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final int index;
  final Color color;
  final VoidCallback onTap;

  const _LessonTile({required this.index, required this.color, required this.onTap});

  static const _icons = [Icons.visibility, Icons.headphones, Icons.mic, Icons.quiz, Icons.games];
  static const _labels = ['看：发音原理', '听：标准发音', '说：跟读练习', '辨：听辨测试', '玩：趣味闯关'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icons[(index - 1) % _icons.length], color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '课 $index',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                    ),
                    Text(
                      _labels[(index - 1) % _labels.length],
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const Text('5分钟', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
