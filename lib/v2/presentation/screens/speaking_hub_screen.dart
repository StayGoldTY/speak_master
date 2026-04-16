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
      title: '口语训练中心',
      subtitle: '把参考音、录音、回放、转写、反馈和历史结果放在同一处，围绕发音和开口做更完整的闭环训练。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const V2SectionTitle(
            title: '高频发音难点',
            subtitle: '优先展示中国成人学习者最容易卡住的目标音，先把嘴形和发音动作练对。',
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: targets.map((target) {
              return SizedBox(
                width: 270,
                child: V2InfoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          V2Pill(
                            label: target.symbol,
                            color: AppColors.primary,
                          ),
                          V2Pill(
                            label: target.title,
                            color: AppColors.secondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        target.subtitle,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        target.mouthPosition,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '示例词：${target.examples.join('、')}',
                        style: const TextStyle(fontSize: 13, height: 1.55),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          const V2SectionTitle(
            title: '引导式口语模式',
            subtitle: '先从影子跟读、场景对话和测评模式切入，逐步把训练做成完整的口语闭环。',
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
