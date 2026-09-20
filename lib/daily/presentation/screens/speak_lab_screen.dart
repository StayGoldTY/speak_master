import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../v2/application/providers/v2_providers.dart';
import '../../../v2/domain/models/course_models.dart';
import '../../../v2/domain/models/speech_models.dart';
import '../widgets/daily_widgets.dart';

class SpeakLabScreen extends ConsumerWidget {
  final String? focusPromptId;

  const SpeakLabScreen({super.key, this.focusPromptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prompts = ref.watch(v2SpeakingPromptsProvider);
    final targets = ref.watch(v2FeaturedTargetsProvider);
    final snapshot = ref.watch(v2MasterySnapshotProvider);
    final focused = prompts
        .where((prompt) => prompt.id == focusPromptId)
        .firstOrNull;

    return DailyPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '开口实验室',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            '复习卡住的词，或者直接进一段场景。这里只做听、说、对齐，不编发音分。',
            style: TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 22),
          const SectionLabel(
            title: '需要再开口的地方',
            subtitle: '从最近一次对齐里留下来的弱项。',
          ),
          if (snapshot.reviewQueue.isEmpty)
            DailyEmptyState(
              key: const ValueKey('speak-review-empty'),
              title: '还没有复练队列',
              message: '先做今日任务或下面的场景开口。识别对不齐的词会出现在这里。',
              actionLabel: '回去做今日任务',
              onAction: () => context.go('/today'),
              icon: Icons.replay_rounded,
            )
          else
            ...snapshot.reviewQueue.take(4).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DailyCard(
                  cardKey: ValueKey('speak-review-${item.id}'),
                  onTap: () => context.push(
                    '/session?type=review&id=${Uri.encodeQueryComponent(item.id)}',
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.replay_rounded, color: AppColors.accent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              item.reason,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 18),
          const SectionLabel(
            title: '场景开口',
            subtitle: '点单、入住、会议：把句子说成一口气。',
          ),
          if (focused != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PromptCard(prompt: focused, highlighted: true),
            ),
          ...prompts
              .where((prompt) => prompt.id != focused?.id)
              .map(
                (prompt) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PromptCard(prompt: prompt),
                ),
              ),
          const SizedBox(height: 12),
          const SectionLabel(
            title: '容易卡住的音',
            subtitle: '只练口型和跟读，没有声学分数。',
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: targets.map((target) {
              return SizedBox(
                width: 220,
                child: DailyCard(
                  onTap: () =>
                      context.push('/session?type=sound&id=${target.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        target.symbol,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(target.subtitle),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  final SpeakingPrompt prompt;
  final bool highlighted;

  const _PromptCard({required this.prompt, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return DailyCard(
      color: highlighted ? AppColors.surfaceAccent : Colors.white,
      onTap: () => context.push('/session?type=prompt&id=${prompt.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (highlighted)
                const DailyPill(label: '从这里开始', color: AppColors.accent),
              DailyPill(label: prompt.kind.label),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            prompt.title,
            key: ValueKey('speak-start-${prompt.id}'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            prompt.scenario,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
