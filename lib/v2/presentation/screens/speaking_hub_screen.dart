import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../application/providers/v2_providers.dart';
import '../../domain/models/course_models.dart';
import '../widgets/speaking_prompt_card.dart';
import '../widgets/v2_page_scaffold.dart';

class SpeakingHubScreen extends ConsumerWidget {
  const SpeakingHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targets = ref.watch(v2FeaturedTargetsProvider);
    final prompts = ref.watch(v2SpeakingPromptsProvider);

    return V2PageScaffold(
      title: 'Speaking Lab',
      subtitle: 'The V2 speaking system keeps reference audio, recording, playback, transcript-based feedback, structured retry advice, and in-session history together.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const V2SectionTitle(
            title: 'Phoneme clinic',
            subtitle: 'These high-friction sounds are surfaced first for Chinese adult learners.',
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: targets.map((target) {
              return SizedBox(
                width: 260,
                child: V2InfoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        children: [
                          V2Pill(label: target.symbol, color: AppColors.primary),
                          V2Pill(label: target.title, color: AppColors.secondary),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(target.subtitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(
                        target.mouthPosition,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.55),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try: ${target.examples.join(', ')}',
                        style: const TextStyle(fontSize: 13, height: 1.55),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const V2SectionTitle(
            title: 'Guided speaking modes',
            subtitle: 'This is the first V2 slice of shadowing, dialog practice, and assessment loops.',
          ),
          ...prompts.map(
            (prompt) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SpeakingPromptCard(
                prompt: prompt,
                accentColor: prompt.kind == ActivityKind.dialogRoleplay
                    ? AppColors.secondary
                    : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
