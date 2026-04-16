import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../domain/models/course_models.dart';
import '../../domain/models/speech_models.dart';
import 'speaking_prompt_card.dart';
import 'v2_page_scaffold.dart';

class ActivityBlueprintView extends StatelessWidget {
  final ActivityBlueprint activity;

  const ActivityBlueprintView({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    switch (activity.kind) {
      case ActivityKind.mcq:
        return _McqActivityCard(activity: activity);
      case ActivityKind.minimalPair:
        return _MinimalPairActivityCard(activity: activity);
      case ActivityKind.wordRepeat:
      case ActivityKind.sentenceReadAloud:
      case ActivityKind.shadowing:
      case ActivityKind.dialogRoleplay:
      case ActivityKind.speakingReflection:
      case ActivityKind.assessmentTask:
        return SpeakingPromptCard(
          prompt: SpeakingPrompt(
            id: activity.id,
            kind: activity.kind,
            title: activity.title,
            scenario: activity.instruction,
            instruction: activity.instruction,
            referenceText: activity.referenceText ?? activity.content ?? '',
            focusWords: activity.focusWords,
            checklist: activity.checklist,
          ),
          accentColor: AppColors.primary,
        );
      case ActivityKind.phonemeIntro:
      case ActivityKind.dictation:
        return V2InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  V2Pill(label: activity.kind.label, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      activity.instruction,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              if ((activity.content ?? '').isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  activity.content!,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.65,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        );
    }
  }
}

class _MinimalPairActivityCard extends StatelessWidget {
  final ActivityBlueprint activity;

  const _MinimalPairActivityCard({
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    final prompt = SpeakingPrompt(
      id: activity.id,
      kind: activity.kind,
      title: activity.title,
      scenario: activity.instruction,
      instruction: activity.instruction,
      referenceText: activity.referenceText ?? '',
      focusWords: activity.focusWords,
      checklist: const ['Listen for the contrast first, then repeat both sides.'],
    );

    return Column(
      children: [
        V2InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.instruction,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              ...activity.pairs.map(
                (pair) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text('${pair.word1} ${pair.phoneme1}'.trim()),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.compare_arrows_rounded),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text('${pair.word2} ${pair.phoneme2}'.trim()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SpeakingPromptCard(
          prompt: prompt,
          accentColor: AppColors.secondary,
        ),
      ],
    );
  }
}

class _McqActivityCard extends StatefulWidget {
  final ActivityBlueprint activity;

  const _McqActivityCard({
    required this.activity,
  });

  @override
  State<_McqActivityCard> createState() => _McqActivityCardState();
}

class _McqActivityCardState extends State<_McqActivityCard> {
  String? _selectedOptionId;

  @override
  Widget build(BuildContext context) {
    final explanation = widget.activity.options
        .firstWhere(
          (option) => option.id == _selectedOptionId,
          orElse: () => const ChoiceOption(id: '', label: ''),
        )
        .explanation;

    return V2InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.activity.instruction,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          if ((widget.activity.content ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.activity.content!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.55,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 16),
          ...widget.activity.options.map(
            (option) {
              final isSelected = _selectedOptionId == option.id;
              final isCorrect = option.id == widget.activity.correctOptionId;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedOptionId = option.id;
                    });
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isCorrect ? AppColors.successGreen : AppColors.accentOrange)
                              .withValues(alpha: 0.12)
                          : AppColors.bgLight,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(option.label)),
                        if (isSelected)
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.info_outline,
                            color: isCorrect ? AppColors.successGreen : AppColors.accentOrange,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if ((_selectedOptionId ?? '').isNotEmpty && (explanation ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              explanation!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
