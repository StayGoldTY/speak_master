import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/srs_memory.dart';
import '../../../providers/progress_provider.dart';
import '../../application/providers/v2_providers.dart';
import '../../application/services/srs_scheduler.dart';
import '../../domain/models/learning_item.dart';
import '../../domain/models/speech_models.dart';
import '../widgets/speaking_prompt_card.dart';
import '../widgets/v2_page_scaffold.dart';

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  static const _scheduler = SrsScheduler();

  List<LearningItem> _queue = const [];
  SessionPlan? _plan;
  int _index = 0;
  int _reviewed = 0;
  bool _revealed = false;
  bool _finished = false;
  String _typed = '';
  String? _selectedOptionId;
  String? _lastDueLabel;
  String? _lastTeacherNote;
  bool _generationChecked = false;

  bool _didLoadQueue = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadQueue) {
      return;
    }
    _didLoadQueue = true;
    final plan = ref.read(v2SessionPlanProvider);
    _plan = plan;
    _queue = [...plan.items];
    _finished = _queue.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan;
    if (plan == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_finished || _index >= _queue.length) {
      return _SessionSummary(
        reviewed: _reviewed,
        lastDueLabel: _lastDueLabel,
        lastTeacherNote: _lastTeacherNote,
        dueTodayCount: ref.watch(v2MasterySnapshotProvider).dueTodayCount,
        upcomingCount: ref.watch(v2MasterySnapshotProvider).upcomingCount,
        recommendedFocus: ref.watch(v2MasterySnapshotProvider).recommendedFocus,
      );
    }

    final item = _queue[_index];
    final memory =
        ref.watch(progressProvider).srsMemories[item.id] ??
        _scheduler.fresh(item.id);
    final prompts = ref.watch(v2SpeakingPromptsProvider);
    SpeakingPrompt? prompt;
    for (final candidate in prompts) {
      if (candidate.id == item.speakingPromptId) {
        prompt = candidate;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('今日学习循环'),
        leading: IconButton(
          onPressed: () => context.go('/today'),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: V2PageScaffold(
        title: '一条循环，三种技能',
        subtitle: plan.subtitle,
        actions: [
          V2Pill(
            label: '${_index + 1} / ${_queue.length}',
            color: AppColors.primary,
          ),
          V2Pill(label: item.track.label, color: AppColors.secondary),
          V2Pill(
            label: _isNew(item) ? '新项目' : '到期提取',
            color: _isNew(item)
                ? AppColors.accentOrange
                : AppColors.successGreen,
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: _queue.isEmpty ? 0 : _index / _queue.length,
              minHeight: 8,
              borderRadius: BorderRadius.circular(99),
            ),
            const SizedBox(height: 16),
            V2InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.kind.label,
                    key: const ValueKey('session-kind-label'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.contextCueZh,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _PromptBody(
              item: item,
              prompt: prompt,
              revealed: _revealed,
              typed: _typed,
              selectedOptionId: _selectedOptionId,
              generationChecked: _generationChecked,
              onTyped: (value) => setState(() => _typed = value),
              onSelectOption: (id) => setState(() => _selectedOptionId = id),
              onReveal: _reveal,
              onCheckGeneration: () => setState(() {
                _generationChecked = true;
                _revealed = true;
              }),
            ),
            if (_revealed) ...[
              const SizedBox(height: 16),
              _FeedbackPanel(
                item: item,
                typed: _typed,
                selectedOptionId: _selectedOptionId,
              ),
              const SizedBox(height: 16),
              _GradeRow(memory: memory, item: item, onGrade: _grade),
            ],
          ],
        ),
      ),
    );
  }

  bool _isNew(LearningItem item) {
    return !ref.read(progressProvider).srsMemories.containsKey(item.id);
  }

  void _reveal() {
    setState(() => _revealed = true);
  }

  Future<void> _grade(RecallGrade grade) async {
    if (_index >= _queue.length) {
      return;
    }
    final item = _queue[_index];
    final existing =
        ref.read(progressProvider).srsMemories[item.id] ??
        _scheduler.fresh(item.id);
    final outcome = _scheduler.review(
      memory: existing,
      grade: grade,
      track: item.track,
    );

    await ref.read(progressProvider.notifier).upsertSrsMemories([
      outcome.memory,
    ], xp: 2);

    setState(() {
      _reviewed += 1;
      _lastDueLabel = outcome.dueLabel;
      _lastTeacherNote = outcome.teacherNote;
      if (outcome.sameSessionRetry) {
        final insertAt = (_index + 3).clamp(0, _queue.length);
        _queue.insert(insertAt, item);
      }
      _index += 1;
      _revealed = false;
      _typed = '';
      _selectedOptionId = null;
      _generationChecked = false;
      if (_index >= _queue.length) {
        _finished = true;
      }
    });

    if (_finished) {
      await ref.read(progressProvider.notifier).completeLearningSession();
    }
  }
}

class _PromptBody extends StatelessWidget {
  final LearningItem item;
  final SpeakingPrompt? prompt;
  final bool revealed;
  final String typed;
  final String? selectedOptionId;
  final bool generationChecked;
  final ValueChanged<String> onTyped;
  final ValueChanged<String> onSelectOption;
  final VoidCallback onReveal;
  final VoidCallback onCheckGeneration;

  const _PromptBody({
    required this.item,
    required this.prompt,
    required this.revealed,
    required this.typed,
    required this.selectedOptionId,
    required this.generationChecked,
    required this.onTyped,
    required this.onSelectOption,
    required this.onReveal,
    required this.onCheckGeneration,
  });

  @override
  Widget build(BuildContext context) {
    if (item.kind == LearningItemKind.speakingMotor) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          V2InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.cue,
                  key: const ValueKey('session-cue'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.target,
                  style: const TextStyle(fontSize: 16, height: 1.6),
                ),
              ],
            ),
          ),
          if (prompt != null) ...[
            const SizedBox(height: 12),
            SpeakingPromptCard(
              prompt: prompt!,
              accentColor: AppColors.secondary,
              compact: true,
            ),
          ],
          const SizedBox(height: 12),
          if (!revealed)
            FilledButton(
              key: const ValueKey('session-reveal-button'),
              onPressed: onReveal,
              child: const Text('开口后安排下次复习'),
            ),
        ],
      );
    }

    if (item.kind == LearningItemKind.grammarNotice &&
        item.options.isNotEmpty) {
      return V2InfoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.cue,
              key: const ValueKey('session-cue'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.contextSentence,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            ...item.options.map((option) {
              final selected = selectedOptionId == option.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  key: ValueKey('session-option-${option.id}'),
                  onTap: revealed
                      ? null
                      : () {
                          onSelectOption(option.id);
                          onReveal();
                        },
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.bgLight,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(option.label),
                  ),
                ),
              );
            }),
          ],
        ),
      );
    }

    if (item.kind == LearningItemKind.generateEnglish ||
        item.kind == LearningItemKind.grammarProduce) {
      return V2InfoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.cue,
              key: const ValueKey('session-cue'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey('session-generate-field'),
              enabled: !revealed,
              onChanged: onTyped,
              decoration: const InputDecoration(
                hintText: '先自己写，再揭晓',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (!revealed)
              FilledButton(
                key: const ValueKey('session-check-generation'),
                onPressed: onCheckGeneration,
                child: const Text('对照答案'),
              ),
          ],
        ),
      );
    }

    return V2InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.cue,
            key: const ValueKey('session-cue'),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            item.contextSentence,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          if (!revealed)
            FilledButton(
              key: const ValueKey('session-reveal-button'),
              onPressed: onReveal,
              child: const Text('我想好了，揭晓'),
            ),
        ],
      ),
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  final LearningItem item;
  final String typed;
  final String? selectedOptionId;

  const _FeedbackPanel({
    required this.item,
    required this.typed,
    required this.selectedOptionId,
  });

  @override
  Widget build(BuildContext context) {
    final generatedOk =
        (item.kind == LearningItemKind.generateEnglish ||
            item.kind == LearningItemKind.grammarProduce) &&
        item.matchesInput(typed);
    final noticedOk =
        item.kind == LearningItemKind.grammarNotice &&
        selectedOptionId != null &&
        selectedOptionId == item.correctOptionId;

    return V2InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.target,
            key: const ValueKey('session-target'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          if (item.kind == LearningItemKind.generateEnglish ||
              item.kind == LearningItemKind.grammarProduce) ...[
            const SizedBox(height: 8),
            Text(
              typed.trim().isEmpty
                  ? '你还没写出答案。没关系，按真实提取难度打分。'
                  : generatedOk
                  ? '你的产出已经贴近目标。'
                  : '先记住这次没提取完整，稍后再试，不必立刻重抄。',
              style: const TextStyle(height: 1.55),
            ),
          ],
          if (item.kind == LearningItemKind.grammarNotice) ...[
            const SizedBox(height: 8),
            Text(
              noticedOk ? '你注意到了关键形式。' : '这次没注意到也正常。看完解释，按费力程度安排下次。',
              style: const TextStyle(height: 1.55),
            ),
          ],
          const SizedBox(height: 10),
          Text(item.explanation, style: const TextStyle(height: 1.65)),
          if ((item.morphologyNote ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '构词：${item.morphologyNote}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
          ],
          if ((item.dualCodeHint ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '画面 / 口型：${item.dualCodeHint}',
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

class _GradeRow extends StatelessWidget {
  final SrsMemory memory;
  final LearningItem item;
  final ValueChanged<RecallGrade> onGrade;

  const _GradeRow({
    required this.memory,
    required this.item,
    required this.onGrade,
  });

  @override
  Widget build(BuildContext context) {
    const scheduler = SrsScheduler();
    final grades = RecallGrade.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '这次提取有多费力？下次见面时间会按此安排。',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: grades.map((grade) {
            final preview = scheduler.preview(
              memory: memory,
              grade: grade,
              track: item.track,
            );
            return SizedBox(
              width: 150,
              child: OutlinedButton(
                key: ValueKey('session-grade-${grade.key}'),
                onPressed: () => onGrade(grade),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Text(grade.label),
                      const SizedBox(height: 4),
                      Text(
                        preview.dueLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SessionSummary extends ConsumerWidget {
  final int reviewed;
  final String? lastDueLabel;
  final String? lastTeacherNote;
  final int dueTodayCount;
  final int upcomingCount;
  final String recommendedFocus;

  const _SessionSummary({
    required this.reviewed,
    required this.lastDueLabel,
    required this.lastTeacherNote,
    required this.dueTodayCount,
    required this.upcomingCount,
    required this.recommendedFocus,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(v2MasterySnapshotProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('本轮结束')),
      body: V2PageScaffold(
        title: '提取完成，间隔开始生效',
        subtitle: '成功提取的项目会排到明天或更晚；没提取出来的会在短间隔后再见。不要熬夜加练同一张。',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            V2InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '本轮完成 $reviewed 个项目',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lastTeacherNote ?? recommendedFocus,
                    key: const ValueKey('session-next-due-label'),
                    style: const TextStyle(height: 1.65),
                  ),
                  if (lastDueLabel != null) ...[
                    const SizedBox(height: 12),
                    V2Pill(
                      label: '最近一次安排：$lastDueLabel',
                      color: AppColors.primary,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                V2Pill(
                  label: '仍到期 $dueTodayCount',
                  color: AppColors.accentOrange,
                ),
                V2Pill(
                  label: '已排期 $upcomingCount',
                  color: AppColors.successGreen,
                ),
                V2Pill(
                  label: '${snapshot.totalXp} XP',
                  color: AppColors.xpGold,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const V2SectionTitle(
              title: '接下来怎么复习',
              subtitle: '打开进度页可以看到每张卡片的下次见面时间。睡眠本身就是学习循环的一部分。',
            ),
            V2InfoCard(
              child: Column(
                children: snapshot.reviewQueue.isEmpty
                    ? const [Text('当前没有待提取队列。明天同一时间回来即可。')]
                    : snapshot.reviewQueue
                          .take(5)
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.label,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  V2Pill(
                                    label:
                                        item.dueLabel ??
                                        item.trackLabel ??
                                        '已安排',
                                    color: AppColors.secondary,
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: () => context.go('/today'),
                  icon: const Icon(Icons.today_rounded),
                  label: const Text('返回今日'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go('/progress'),
                  icon: const Icon(Icons.auto_graph_rounded),
                  label: const Text('查看复习排期'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
