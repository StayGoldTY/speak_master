import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../data/lessons_data.dart';
import '../../data/units_data.dart';
import '../../models/lesson.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/did_you_know_card.dart';
import 'widgets/lesson_step_content.dart';

class LessonScreen extends ConsumerStatefulWidget {
  final String lessonId;

  const LessonScreen({super.key, required this.lessonId});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  int _currentStep = 0;
  final Map<String, int> _selectedOptions = {};

  @override
  Widget build(BuildContext context) {
    final lesson = LessonsData.getLessonById(widget.lessonId);
    if (lesson == null) {
      return const _LessonStateScreen(
        title: '课程未找到',
        body: '当前链接没有对应的课程内容。你可以先返回教程地图，从已开放单元重新进入。',
      );
    }

    if (!LessonsData.isReleasedUnit(lesson.unitId)) {
      return const _LessonStateScreen(
        title: '课程暂未开放',
        body: '这个课程所在的单元还没有进入第一阶段主学习链路，因此暂时不对外开放。',
      );
    }

    final unit = UnitsData.units.firstWhere((item) => item.id == lesson.unitId);
    final block = UnitsData.blocks.firstWhere(
      (item) => item.id == unit.blockId,
    );
    final currentStepIndex = math.min(
      math.max(_currentStep, 0),
      lesson.steps.length - 1,
    );
    final currentStep = lesson.steps[currentStepIndex];
    final isWide = MediaQuery.sizeOf(context).width >= 1100;

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.titleCn),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: block.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${currentStepIndex + 1}/${lesson.steps.length}',
                  style: TextStyle(
                    color: block.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _LessonProgressBar(
              currentStep: currentStepIndex,
              totalSteps: lesson.steps.length,
              color: block.color,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 7,
                                child: _MainLessonPane(
                                  lesson: lesson,
                                  currentStep: currentStep,
                                  accentColor: block.color,
                                  selectedOption:
                                      _selectedOptions[currentStep.id],
                                  onSelectOption: (value) =>
                                      _selectOption(currentStep.id, value),
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                flex: 4,
                                child: _LessonSidebar(
                                  unitTitle: unit.titleCn,
                                  lesson: lesson,
                                  steps: lesson.steps,
                                  currentStepIndex: currentStepIndex,
                                  accentColor: block.color,
                                ),
                              ),
                            ],
                          )
                        : _MainLessonPane(
                            lesson: lesson,
                            currentStep: currentStep,
                            accentColor: block.color,
                            selectedOption: _selectedOptions[currentStep.id],
                            onSelectOption: (value) =>
                                _selectOption(currentStep.id, value),
                            sidebar: _LessonSidebar(
                              unitTitle: unit.titleCn,
                              lesson: lesson,
                              steps: lesson.steps,
                              currentStepIndex: currentStepIndex,
                              accentColor: block.color,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            _BottomBar(
              canGoBack: currentStepIndex > 0,
              onPrevious: _goPrevious,
              onNext: () => _goNext(lesson),
              isLastStep: currentStepIndex == lesson.steps.length - 1,
            ),
          ],
        ),
      ),
    );
  }

  void _selectOption(String stepId, int value) {
    setState(() {
      _selectedOptions[stepId] = value;
    });
  }

  void _goPrevious() {
    if (_currentStep == 0) {
      return;
    }

    setState(() {
      _currentStep -= 1;
    });
  }

  Future<void> _goNext(Lesson lesson) async {
    if (_currentStep < lesson.steps.length - 1) {
      setState(() {
        _currentStep += 1;
      });
      return;
    }

    final progressNotifier = ref.read(progressProvider.notifier);
    await progressNotifier.completeLesson(lesson.id);

    final progress = ref.read(progressProvider);
    final completedLessons = {...progress.completedLessons, lesson.id};
    final unitLessons = LessonsData.getLessonsForUnit(lesson.unitId);
    final isUnitCompleted = unitLessons.every(
      (item) => completedLessons.contains(item.id),
    );

    if (isUnitCompleted) {
      await progressNotifier.completeUnit(lesson.unitId);
    }

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('课程完成'),
        content: Text(
          isUnitCompleted
              ? '这一课已经完成，你也顺利走完了本单元。现在可以返回单元页，继续下一段学习。'
              : '这一课已经完成。建议回到单元页，按顺序继续下一课。',
          style: const TextStyle(height: 1.7),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _currentStep = 0);
            },
            child: const Text('再看一遍'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('返回单元'),
          ),
        ],
      ),
    );
  }
}

class _LessonStateScreen extends StatelessWidget {
  final String title;
  final String body;

  const _LessonStateScreen({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                body,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.8,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color color;

  const _LessonProgressBar({
    required this.currentStep,
    required this.totalSteps,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: List.generate(
          totalSteps,
          (index) => Expanded(
            child: Container(
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: index <= currentStep
                    ? color
                    : color.withValues(alpha: 0.16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MainLessonPane extends StatelessWidget {
  final Lesson lesson;
  final LessonStep currentStep;
  final Color accentColor;
  final int? selectedOption;
  final ValueChanged<int> onSelectOption;
  final Widget? sidebar;

  const _MainLessonPane({
    required this.lesson,
    required this.currentStep,
    required this.accentColor,
    required this.selectedOption,
    required this.onSelectOption,
    this.sidebar,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LessonHero(lesson: lesson, accentColor: accentColor),
          const SizedBox(height: 16),
          if (sidebar != null) ...[sidebar!, const SizedBox(height: 16)],
          _StepHeader(
            instruction: currentStep.instruction,
            stepType: currentStep.type,
          ),
          const SizedBox(height: 14),
          LessonStepContent(
            step: currentStep,
            accentColor: accentColor,
            selectedOption: selectedOption,
            onSelectOption: onSelectOption,
          ),
        ],
      ),
    );
  }
}

class _LessonHero extends StatelessWidget {
  final Lesson lesson;
  final Color accentColor;

  const _LessonHero({required this.lesson, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lesson.titleEn,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lesson.description,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetaPill(label: '${lesson.estimatedMinutes} 分钟'),
              _MetaPill(label: '${lesson.steps.length} 个步骤'),
              _MetaPill(label: _lessonTypeLabel(lesson.type)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String label;

  const _MetaPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  final String instruction;
  final StepType stepType;

  const _StepHeader({required this.instruction, required this.stepType});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          instruction,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _stepTypeLabel(stepType),
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _LessonSidebar extends StatelessWidget {
  final String unitTitle;
  final Lesson lesson;
  final List<LessonStep> steps;
  final int currentStepIndex;
  final Color accentColor;

  const _LessonSidebar({
    required this.unitTitle,
    required this.lesson,
    required this.steps,
    required this.currentStepIndex,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('lesson-sidebar'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accentColor.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                unitTitle,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '本课步骤',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              ...List.generate(steps.length, (index) {
                final step = steps[index];
                final isCurrent = index == currentStepIndex;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? accentColor.withValues(alpha: 0.08)
                          : AppColors.bgLight,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isCurrent ? accentColor : Colors.white,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isCurrent
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.instruction,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _stepTypeLabel(step.type),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        if (lesson.didYouKnowText != null &&
            lesson.didYouKnowSource != null) ...[
          const SizedBox(height: 16),
          DidYouKnowCard(
            text: lesson.didYouKnowText!,
            source: lesson.didYouKnowSource!,
          ),
        ],
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  final bool canGoBack;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool isLastStep;

  const _BottomBar({
    required this.canGoBack,
    required this.onPrevious,
    required this.onNext,
    required this.isLastStep,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Row(
          children: [
            if (canGoBack)
              Expanded(
                child: OutlinedButton(
                  onPressed: onPrevious,
                  child: const Text('上一步'),
                ),
              ),
            if (canGoBack) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: onNext,
                child: Text(isLastStep ? '完成课程' : '下一步'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _lessonTypeLabel(LessonType type) {
  return switch (type) {
    LessonType.theory => '概念讲解',
    LessonType.listen => '听音训练',
    LessonType.practice => '开口练习',
    LessonType.discrimination => '辨音训练',
    LessonType.game => '闯关练习',
  };
}

String _stepTypeLabel(StepType type) {
  return switch (type) {
    StepType.text => '阅读讲解',
    StepType.animation => '动态演示',
    StepType.audio => '听音准备',
    StepType.recordAndCompare => '录音自练',
    StepType.minimalPairQuiz => '最小对立体',
    StepType.dragAndDrop => '拖拽练习',
    StepType.multipleChoice => '选择题',
    StepType.readAloud => '朗读练习',
  };
}
