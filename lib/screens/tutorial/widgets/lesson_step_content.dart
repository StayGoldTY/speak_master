import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/lesson.dart';
import '../../../widgets/record_button.dart';

class LessonStepContent extends StatelessWidget {
  final LessonStep step;
  final Color accentColor;
  final bool isRecording;
  final VoidCallback onToggleRecording;
  final int? selectedOption;
  final ValueChanged<int> onSelectOption;

  const LessonStepContent({
    super.key,
    required this.step,
    required this.accentColor,
    required this.isRecording,
    required this.onToggleRecording,
    required this.selectedOption,
    required this.onSelectOption,
  });

  @override
  Widget build(BuildContext context) {
    return _StepCard(
      accentColor: accentColor,
      child: switch (step.type) {
        StepType.text => _TextStep(step: step),
        StepType.audio => _AudioStep(step: step),
        StepType.recordAndCompare => _RecordStep(
            step: step,
            isRecording: isRecording,
            onToggleRecording: onToggleRecording,
          ),
        StepType.minimalPairQuiz => _MinimalPairStep(step: step),
        StepType.multipleChoice => _MultipleChoiceStep(
            step: step,
            accentColor: accentColor,
            selectedOption: selectedOption,
            onSelectOption: onSelectOption,
          ),
        StepType.readAloud => _ReadAloudStep(
            step: step,
            isRecording: isRecording,
            onToggleRecording: onToggleRecording,
          ),
        _ => _TextStep(step: step),
      },
    );
  }
}

class _StepCard extends StatelessWidget {
  final Widget child;
  final Color accentColor;

  const _StepCard({required this.child, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _TextStep extends StatelessWidget {
  final LessonStep step;

  const _TextStep({required this.step});

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Text(
        step.content ?? '这一部分暂时还没有补充说明。',
        key: ValueKey('step-text-${step.id}'),
        style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.75),
      ),
    );
  }
}

class _AudioStep extends StatelessWidget {
  final LessonStep step;

  const _AudioStep({required this.step});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(
          icon: Icons.headphones_outlined,
          title: '当前阶段说明',
        ),
        const SizedBox(height: 12),
        const Text(
          '这一课保留了“听一听标准示范”的学习意图，但当前版本还没有接入站内标准音频。你可以先按文字提示自读，再结合后面的录音步骤做自练。',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.7),
        ),
        if ((step.content ?? '').isNotEmpty) ...[
          const SizedBox(height: 20),
          SelectionArea(
            child: Text(
              step.content!,
              key: ValueKey('step-audio-${step.id}'),
              style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.7),
            ),
          ),
        ],
        const SizedBox(height: 20),
        const _HonestHint(
          title: '后续会补什么',
          body: '等音频资产就绪后，这里会升级成真实可听、可对照的入口，而不是假装能播放的按钮。',
        ),
      ],
    );
  }
}

class _RecordStep extends StatelessWidget {
  final LessonStep step;
  final bool isRecording;
  final VoidCallback onToggleRecording;

  const _RecordStep({
    required this.step,
    required this.isRecording,
    required this.onToggleRecording,
  });

  @override
  Widget build(BuildContext context) {
    final pairs = _stringList(step.metadata?['pairs']);
    final note = step.metadata?['note']?.toString();
    final focus = _stringList(step.metadata?['focus']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((step.content ?? '').isNotEmpty)
          SelectionArea(
            child: Text(
              step.content!,
              key: ValueKey('step-record-${step.id}'),
              style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.75),
            ),
          ),
        if (pairs.isNotEmpty) ...[
          const SizedBox(height: 20),
          _ChipGroup(
            title: '本步练习词',
            values: pairs,
          ),
        ],
        if (focus.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ChipGroup(
            title: '重点关注',
            values: focus,
          ),
        ],
        const SizedBox(height: 28),
        Center(
          child: Column(
            children: [
              RecordButton(
                isRecording: isRecording,
                onTap: onToggleRecording,
              ),
              const SizedBox(height: 12),
              Text(
                isRecording ? '录音中，完成后建议你回听一遍。' : '点击开始一轮自练录音。',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _HonestHint(
          title: '当前能力边界',
          body: note ?? '本阶段不做自动评分，请以回听和自查为主。',
        ),
      ],
    );
  }
}

class _MinimalPairStep extends StatelessWidget {
  final LessonStep step;

  const _MinimalPairStep({required this.step});

  @override
  Widget build(BuildContext context) {
    final pairs = (step.metadata?['pairs'] as List<dynamic>? ?? const [])
        .map((item) => item is Map ? item.map((key, value) => MapEntry(key.toString(), value.toString())) : const <String, String>{})
        .where((pair) => pair.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '这一步先做“可视化辨音”，帮你把两个音的边界看清楚。当前版本不播放隐藏音频，也不做自动判分。',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.7),
        ),
        const SizedBox(height: 18),
        ...pairs.map(
          (pair) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              key: ValueKey('pair-${step.id}-${pair['word1']}-${pair['word2']}'),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgLight,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _PairWord(
                      word: pair['word1'] ?? '',
                      phoneme: pair['phoneme1'] ?? '',
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.compare_arrows, color: AppColors.textHint),
                  ),
                  Expanded(
                    child: _PairWord(
                      word: pair['word2'] ?? '',
                      phoneme: pair['phoneme2'] ?? '',
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

class _MultipleChoiceStep extends StatelessWidget {
  final LessonStep step;
  final Color accentColor;
  final int? selectedOption;
  final ValueChanged<int> onSelectOption;

  const _MultipleChoiceStep({
    required this.step,
    required this.accentColor,
    required this.selectedOption,
    required this.onSelectOption,
  });

  @override
  Widget build(BuildContext context) {
    final options = _stringList(step.metadata?['options']);
    final correct = step.metadata?['correct'] is int ? step.metadata!['correct'] as int : null;
    final explanation = step.metadata?['explanation']?.toString();
    final isAnswered = selectedOption != null;
    final isCorrect = isAnswered && correct != null && selectedOption == correct;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((step.content ?? '').isNotEmpty)
          Text(
            step.content!,
            key: ValueKey('mc-question-${step.id}'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.6),
          ),
        const SizedBox(height: 20),
        ...List.generate(options.length, (index) {
          final isSelected = selectedOption == index;
          final showCorrect = isAnswered && correct == index;
          final borderColor = showCorrect
              ? AppColors.successGreen
              : isSelected
                  ? accentColor
                  : Colors.grey.shade200;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              key: ValueKey('mc-option-${step.id}-$index'),
              onTap: () => onSelectOption(index),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: isSelected || showCorrect ? 1.6 : 1),
                  color: isSelected ? accentColor.withValues(alpha: 0.06) : Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        options[index],
                        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      ),
                    ),
                    if (showCorrect)
                      const Icon(Icons.check_circle, color: AppColors.successGreen, size: 18),
                  ],
                ),
              ),
            ),
          );
        }),
        if (isAnswered && explanation != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isCorrect ? AppColors.successGreen : AppColors.accentOrange).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              explanation,
              key: ValueKey('mc-explanation-${step.id}'),
              style: TextStyle(
                fontSize: 14,
                color: isCorrect ? AppColors.successGreen : AppColors.accentOrange,
                height: 1.65,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ReadAloudStep extends StatelessWidget {
  final LessonStep step;
  final bool isRecording;
  final VoidCallback onToggleRecording;

  const _ReadAloudStep({
    required this.step,
    required this.isRecording,
    required this.onToggleRecording,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.bgLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SelectionArea(
            child: Text(
              step.content ?? '',
              key: ValueKey('step-read-${step.id}'),
              style: const TextStyle(fontSize: 18, color: AppColors.textPrimary, height: 1.8),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              RecordButton(
                isRecording: isRecording,
                onTap: onToggleRecording,
              ),
              const SizedBox(height: 12),
              Text(
                isRecording ? '保持自然语速，读完再回头检查。' : '点击开始一轮朗读自练。',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _HonestHint(
          title: '自查建议',
          body: '回顾时优先看三个点：重音有没有落稳、元音有没有读扁、句子节奏有没有一路冲平。',
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionLabel({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
        ),
      ],
    );
  }
}

class _ChipGroup extends StatelessWidget {
  final String title;
  final List<String> values;

  const _ChipGroup({required this.title, required this.values});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values
              .map(
                (value) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _PairWord extends StatelessWidget {
  final String word;
  final String phoneme;

  const _PairWord({required this.word, required this.phoneme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          word,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          '/$phoneme/',
          style: const TextStyle(fontSize: 13, color: AppColors.primary),
        ),
      ],
    );
  }
}

class _HonestHint extends StatelessWidget {
  final String title;
  final String body;

  const _HonestHint({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.65),
          ),
        ],
      ),
    );
  }
}

List<String> _stringList(dynamic value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }
  return const [];
}
