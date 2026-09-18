import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../application/providers/v2_providers.dart';
import '../../domain/models/course_models.dart';
import '../../domain/models/speech_models.dart';
import '../widgets/speaking_prompt_card.dart';
import '../widgets/v2_page_scaffold.dart';

class SpeakingHubScreen extends ConsumerStatefulWidget {
  final String? focusPromptId;

  const SpeakingHubScreen({super.key, this.focusPromptId});

  @override
  ConsumerState<SpeakingHubScreen> createState() => _SpeakingHubScreenState();
}

class _SpeakingHubScreenState extends ConsumerState<SpeakingHubScreen> {
  ActivityKind? _selectedKind;
  String? _focusedPromptId;

  @override
  void initState() {
    super.initState();
    _focusedPromptId = widget.focusPromptId;
  }

  @override
  void didUpdateWidget(covariant SpeakingHubScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusPromptId != widget.focusPromptId) {
      _focusedPromptId = widget.focusPromptId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final targets = ref.watch(v2FeaturedTargetsProvider);
    final prompts = ref.watch(v2SpeakingPromptsProvider);
    final availableKinds = prompts
        .map((prompt) => prompt.kind)
        .toSet()
        .toList();
    final filteredPrompts = _selectedKind == null
        ? prompts
        : prompts.where((prompt) => prompt.kind == _selectedKind).toList();
    final focusedPrompt = _findPrompt(prompts, _focusedPromptId);
    final recommendedPrompt =
        focusedPrompt ??
        (filteredPrompts.isNotEmpty
            ? filteredPrompts.first
            : prompts.isNotEmpty
            ? prompts.first
            : null);
    final compact = MediaQuery.sizeOf(context).width < 760;

    return V2PageScaffold(
      title: '口语训练中心',
      subtitle: '把参考音、录音、回放、转写、反馈和历史结果放在同一处，围绕发音和开口做更完整的闭环训练。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recommendedPrompt != null) ...[
            _SpeakingHubHero(
              prompt: recommendedPrompt,
              totalCount: filteredPrompts.length,
              onQuickStart: () => setState(() {
                _selectedKind = recommendedPrompt.kind;
                _focusedPromptId = recommendedPrompt.id;
              }),
            ),
            SizedBox(height: compact ? 36 : 56),
          ],
          const V2SectionTitle(
            title: '高频发音难点',
            subtitle: '优先展示中国成人学习者最容易卡住的目标音，先把嘴形和发音动作练对。',
          ),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: targets.map((target) {
              return SizedBox(
                width: compact ? double.infinity : 300,
                child: V2InfoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        target.symbol,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        target.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        target.subtitle,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        target.mouthPosition,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '示例词：${target.examples.join('、')}',
                        style: const TextStyle(fontSize: 15, height: 1.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '纠音提示：${target.correctionTip}',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: compact ? 36 : 56),
          const V2SectionTitle(
            title: '引导式口语模式',
            subtitle: '先从影子跟读、场景对话和测评模式切入，逐步把训练做成完整的口语闭环。',
          ),
          Material(
            color: Colors.transparent,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  key: const ValueKey('speaking-filter-全部'),
                  label: const Text('全部'),
                  selected: _selectedKind == null,
                  onSelected: (_) => setState(() => _selectedKind = null),
                ),
                ...availableKinds.map(
                  (kind) => ChoiceChip(
                    key: ValueKey('speaking-filter-${kind.label}'),
                    label: Text(kind.label),
                    selected: _selectedKind == kind,
                    onSelected: (_) => setState(() {
                      _selectedKind = _selectedKind == kind ? null : kind;
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '共 ${filteredPrompts.length} 个训练',
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          if (filteredPrompts.isEmpty)
            const V2EmptyState(
              title: '这个模式下还没有训练',
              body: '换一个筛选，或回到全部，继续开口。',
            )
          else
            ...filteredPrompts.map(
              (prompt) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: SpeakingPromptCard(
                  prompt: prompt,
                  highlighted: prompt.id == _focusedPromptId,
                  accentColor: AppColors.ink,
                ),
              ),
            ),
        ],
      ),
    );
  }

  SpeakingPrompt? _findPrompt(List<SpeakingPrompt> prompts, String? promptId) {
    if (promptId == null || promptId.trim().isEmpty) {
      return null;
    }

    for (final prompt in prompts) {
      if (prompt.id == promptId) {
        return prompt;
      }
    }
    return null;
  }
}

class _SpeakingHubHero extends StatelessWidget {
  final SpeakingPrompt prompt;
  final int totalCount;
  final VoidCallback onQuickStart;

  const _SpeakingHubHero({
    required this.prompt,
    required this.totalCount,
    required this.onQuickStart,
  });

  @override
  Widget build(BuildContext context) {
    return V2CinematicBand(
      kicker: '推荐训练',
      headline: prompt.title,
      body: '${prompt.scenario}\n先从这一条开始，3 分钟进入开口状态。',
      metrics: [
        V2SpecMetric(
          label: '模式',
          value: prompt.kind.label,
          inverted: true,
        ),
        V2SpecMetric(
          label: '当前列表',
          value: '$totalCount 条',
          inverted: true,
        ),
      ],
      action: FilledButton.icon(
        key: const ValueKey('speaking-quick-start'),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.ink,
        ),
        onPressed: onQuickStart,
        icon: const Icon(Icons.mic_none_rounded),
        label: const Text('开始推荐训练'),
      ),
    );
  }
}
