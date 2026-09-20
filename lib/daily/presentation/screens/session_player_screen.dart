import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/user_progress.dart';
import '../../../providers/progress_provider.dart';
import '../../../services/pronunciation_practice_service.dart';
import '../../../v2/application/providers/v2_providers.dart';
import '../../../v2/domain/models/speech_models.dart';
import '../../domain/session_models.dart';
import '../../domain/word_aligner.dart';
import '../widgets/daily_widgets.dart';

class SessionPlayerScreen extends ConsumerStatefulWidget {
  final String type;
  final String id;
  final String? taskId;

  const SessionPlayerScreen({
    super.key,
    required this.type,
    required this.id,
    this.taskId,
  });

  @override
  ConsumerState<SessionPlayerScreen> createState() =>
      _SessionPlayerScreenState();
}

class _SessionPlayerScreenState extends ConsumerState<SessionPlayerScreen> {
  final _aligner = const WordAligner();
  PronunciationPracticeService? _practice;
  int _index = 0;
  String? _selectedOptionId;
  bool _answered = false;
  String? _pairWord;
  SessionAlignment? _alignment;
  bool _listening = false;
  bool _speaking = false;
  bool _finishing = false;
  bool _finished = false;
  String? _error;
  int _hitTotal = 0;
  int _wordTotal = 0;

  @override
  void dispose() {
    _practice?.stopSpeaking();
    _practice?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = _resolveSession();
    if (session == null) {
      return Scaffold(
        backgroundColor: AppColors.bgLight,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: DailyErrorState(
              title: '找不到这一课',
              message: '内容可能已经下线，先回到今日任务另选一项。',
              actionLabel: '回到今日',
              onAction: () => context.go('/today'),
            ),
          ),
        ),
      );
    }

    if (_finished) {
      return _FinishedView(
        session: session,
        onDone: () => context.go('/today'),
      );
    }

    if (session.steps.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.bgLight,
        body: const SafeArea(
          child: Center(child: Text('这节课还没有可练习的步骤。')),
        ),
      );
    }

    final step = session.steps[_index.clamp(0, session.steps.length - 1)];
    final progress = (_index + 1) / session.steps.length;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/today');
                          }
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_index + 1}/${session.steps.length}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _StepBody(
                        step: step,
                        selectedOptionId: _selectedOptionId,
                        answered: _answered,
                        pairWord: _pairWord,
                        alignment: _alignment,
                        listening: _listening,
                        speaking: _speaking,
                        error: _error,
                        onSelectOption: (id) {
                          setState(() {
                            _selectedOptionId = id;
                            _answered = true;
                          });
                        },
                        onSelectPair: (word) => setState(() => _pairWord = word),
                        onPlay: () => _play(step),
                        onSpeak: () => _speak(step),
                        onSkipSpeak: () => setState(() {
                          _error = null;
                          _alignment = SessionAlignment(
                            words: const [],
                            transcript: '',
                            honestyNote: '这一步先听过，还没有识别对齐。',
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: ValueKey(
                        _index >= session.steps.length - 1
                            ? 'session-finish'
                            : 'session-continue',
                      ),
                      onPressed: _canContinue(step)
                          ? () => _continue(session)
                          : null,
                      child: Text(
                        _index >= session.steps.length - 1 ? '完成这节' : '继续',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _canContinue(SessionStep step) {
    if (_finishing) {
      return false;
    }
    return switch (step.kind) {
      SessionStepKind.tip => true,
      SessionStepKind.multipleChoice => _answered,
      SessionStepKind.minimalPair => true,
      SessionStepKind.listenSpeak => _alignment != null,
    };
  }

  Future<void> _continue(SessionBlueprint session) async {
    if (_index < session.steps.length - 1) {
      setState(() {
        _index += 1;
        _selectedOptionId = null;
        _answered = false;
        _pairWord = null;
        _alignment = null;
        _error = null;
      });
      return;
    }
    await _finish(session);
  }

  Future<void> _finish(SessionBlueprint session) async {
    if (_finishing) {
      return;
    }
    setState(() => _finishing = true);
    final progress = ref.read(progressProvider.notifier);
    if (session.lessonId != null) {
      await progress.completeLesson(session.lessonId!);
      final track = ref.read(v2PrimaryTrackProvider);
      final unit = track.units
          .where((item) => item.lessons.any((lesson) => lesson.id == session.lessonId))
          .firstOrNull;
      if (unit != null) {
        final completed = ref.read(progressProvider).completedLessons;
        final allDone = unit.lessons.every((lesson) => completed.contains(lesson.id));
        if (allDone) {
          await progress.completeUnit(unit.id);
        }
      }
    } else {
      await progress.recordSpeakingPractice(
        xp: 8,
        reviewEntries: _reviewEntries(session),
      );
    }
    if (session.dailyTaskId != null) {
      await ref.read(dailyLoopProvider.notifier).completeTask(session.dailyTaskId!);
    }
    await ref.read(practiceLogProvider.notifier).add(
      PracticeLogEntry(
        id: '${session.id}-${DateTime.now().millisecondsSinceEpoch}',
        title: session.title,
        source: session.kind.name,
        alignedHits: _hitTotal,
        alignedTotal: _wordTotal,
        createdAt: DateTime.now(),
      ),
    );
    if (mounted) {
      setState(() {
        _finished = true;
        _finishing = false;
      });
    }
  }

  List<PronunciationReviewEntry> _reviewEntries(SessionBlueprint session) {
    if (_alignment == null) {
      return const [];
    }
    return _alignment!.words
        .where((word) => word.status != WordAlignStatus.hit)
        .take(3)
        .map(
          (word) => PronunciationReviewEntry(
            id: '${session.id}_${word.expected}',
            label: word.expected,
            reason: '识别没有对齐到这个词，建议单独再开口一次。',
            recommendedActivityKindKey: 'wordRepeat',
            recommendedActivityLabel: '单词跟读',
            sourcePromptId: session.promptId ?? session.id,
            weaknessScore: 40,
            createdAt: DateTime.now(),
          ),
        )
        .toList();
  }

  Future<void> _play(SessionStep step) async {
    final text = _pairWord ?? step.prompt;
    if (text.trim().isEmpty) {
      return;
    }
    setState(() {
      _speaking = true;
      _error = null;
    });
    try {
      _practice ??= PronunciationPracticeService();
      await _practice!.speakReference(
        text: text,
        accentPreference: ref.read(v2LearnerProfileProvider).accentPreference,
      );
    } catch (error) {
      setState(() => _error = '示范音暂时播不出来。仍可以自己开口，或先继续下一步。');
    } finally {
      if (mounted) {
        setState(() => _speaking = false);
      }
    }
  }

  Future<void> _speak(SessionStep step) async {
    final text = _pairWord ?? step.prompt;
    setState(() {
      _listening = true;
      _error = null;
    });
    try {
      _practice ??= PronunciationPracticeService();
      final started = await _practice!.startListening(
        accentPreference: ref.read(v2LearnerProfileProvider).accentPreference,
        onResult: (SpeechRecognitionResult result) {
          if (!result.finalResult && result.recognizedWords.trim().isEmpty) {
            return;
          }
          _applyTranscript(text, result.recognizedWords);
        },
        onError: (message) {
          if (mounted) {
            setState(() {
              _listening = false;
              _error = '没有识别到语音。检查麦克风权限后重试，或先听示范再继续。';
            });
          }
        },
      );
      if (!started && mounted) {
        setState(() {
          _listening = false;
          _error = '这个浏览器还不能听你说。你可以先听示范，这一步不编分数。';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _listening = false;
          _error = '开口识别失败。没有分数被编出来。';
        });
      }
    }
  }

  void _applyTranscript(String expected, String transcript) {
    final words = _aligner.align(expected: expected, spoken: transcript);
    final alignment = SessionAlignment(
      words: words,
      transcript: transcript,
      honestyNote: '这是识别对齐，不是声学发音评分。',
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _listening = false;
      _alignment = alignment;
      _hitTotal += alignment.hitCount;
      _wordTotal += alignment.totalCount;
    });
  }

  SessionBlueprint? _resolveSession() {
    final composer = ref.read(sessionComposerProvider);
    final repo = ref.read(v2LearningRepositoryProvider);
    switch (widget.type) {
      case 'lesson':
        final lesson = repo.getLessonById(widget.id);
        if (lesson == null) {
          return null;
        }
        return composer.fromLesson(lesson: lesson, dailyTaskId: widget.taskId);
      case 'prompt':
        final prompt = repo
            .getSpeakingPrompts()
            .where((item) => item.id == widget.id)
            .firstOrNull;
        if (prompt == null) {
          return null;
        }
        return composer.fromPrompt(prompt: prompt, dailyTaskId: widget.taskId);
      case 'review':
        final snapshot = repo.buildMasterySnapshot(ref.read(progressProvider));
        final review = snapshot.reviewQueue
            .where((item) => item.id == widget.id || item.label == widget.id)
            .firstOrNull;
        final sourceId = ref
            .read(progressProvider)
            .pronunciationReviewEntries
            .where((item) => item.id == widget.id)
            .map((item) => item.sourcePromptId)
            .firstOrNull;
        final prompt = repo
            .getSpeakingPrompts()
            .where((item) => item.id == sourceId)
            .firstOrNull;
        return composer.fromReview(
          id: widget.id,
          label: review?.label ?? widget.id,
          reason: review?.reason ?? '把这个词再开口一次。',
          dailyTaskId: widget.taskId,
          sourcePrompt: prompt,
        );
      case 'sound':
        final target = repo
            .getFeaturedTargets()
            .where((item) => item.id == widget.id)
            .firstOrNull ??
            PronunciationTarget(
              id: widget.id,
              symbol: widget.id,
              title: '对比音',
              subtitle: '先听再跟读。',
              examples: const ['think', 'three', 'both'],
              mouthPosition: '舌尖轻触齿间。',
              correctionTip: '送气，不要把这个音咬扁。',
            );
        return composer.fromSound(target: target, dailyTaskId: widget.taskId);
      default:
        return null;
    }
  }
}

class _StepBody extends StatelessWidget {
  final SessionStep step;
  final String? selectedOptionId;
  final bool answered;
  final String? pairWord;
  final SessionAlignment? alignment;
  final bool listening;
  final bool speaking;
  final String? error;
  final ValueChanged<String> onSelectOption;
  final ValueChanged<String> onSelectPair;
  final VoidCallback onPlay;
  final VoidCallback onSpeak;
  final VoidCallback onSkipSpeak;

  const _StepBody({
    required this.step,
    required this.selectedOptionId,
    required this.answered,
    required this.pairWord,
    required this.alignment,
    required this.listening,
    required this.speaking,
    required this.error,
    required this.onSelectOption,
    required this.onSelectPair,
    required this.onPlay,
    required this.onSpeak,
    required this.onSkipSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.title,
          style: const TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          step.instruction,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.2),
        ),
        if (step.hint.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            step.hint,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
        ],
        const SizedBox(height: 24),
        if (step.kind == SessionStepKind.multipleChoice)
          ...step.options.map((option) {
            final selected = selectedOptionId == option.id;
            final correct = option.id == step.correctOptionId;
            Color? color;
            if (answered && selected) {
              color = correct ? AppColors.hit : AppColors.miss;
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DailyCard(
                cardKey: ValueKey('mc-option-${option.id}'),
                color: color?.withValues(alpha: 0.12),
                onTap: answered ? null : () => onSelectOption(option.id),
                child: Text(
                  option.label,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            );
          }),
        if (step.kind == SessionStepKind.minimalPair)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: step.pairs.take(6).expand((pair) {
              return [pair.word1, pair.word2].where((word) => word.trim().isNotEmpty);
            }).map((word) {
              final selected = pairWord == word;
              return ChoiceChip(
                label: Text(word),
                selected: selected,
                onSelected: (_) => onSelectPair(word),
              );
            }).toList(),
          ),
        if (step.kind == SessionStepKind.tip && step.prompt.isNotEmpty) ...[
          DailyCard(
            child: Text(
              step.prompt,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (step.kind == SessionStepKind.listenSpeak ||
            step.kind == SessionStepKind.minimalPair ||
            (step.kind == SessionStepKind.tip && step.hasSpeakablePrompt)) ...[
          if (step.prompt.isNotEmpty && step.kind == SessionStepKind.listenSpeak)
            DailyCard(
              child: Text(
                pairWord ?? step.prompt,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.3),
              ),
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: speaking ? null : onPlay,
                icon: Icon(speaking ? Icons.volume_up_rounded : Icons.play_arrow_rounded),
                label: Text(speaking ? '正在示范' : '听示范'),
              ),
              if (step.kind != SessionStepKind.tip)
                FilledButton.tonalIcon(
                  onPressed: listening ? null : onSpeak,
                  icon: Icon(listening ? Icons.graphic_eq_rounded : Icons.mic_rounded),
                  label: Text(listening ? '正在听你说' : '开口'),
                ),
              if (step.kind == SessionStepKind.listenSpeak)
                TextButton(
                  key: const ValueKey('session-skip-speak'),
                  onPressed: onSkipSpeak,
                  child: const Text('这一步先听，稍后再开口'),
                ),
            ],
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: 16),
          DailyCard(
            color: const Color(0xFFFFF4F2),
            child: Text(error!, style: const TextStyle(height: 1.45)),
          ),
        ],
        if (alignment != null) ...[
          const SizedBox(height: 18),
          WordChipRow(words: alignment!.words),
          const SizedBox(height: 10),
          Text(
            alignment!.summary,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            alignment!.honestyNote,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (alignment!.transcript.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '识别到：${alignment!.transcript}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ],
      ],
    );
  }
}

class _FinishedView extends StatelessWidget {
  final SessionBlueprint session;
  final VoidCallback onDone;

  const _FinishedView({required this.session, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Text(
                '这节完成了',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                session.title,
                style: const TextStyle(fontSize: 18, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              const Text(
                '进度已记下。没有接上评分引擎，所以这里不会出现发音总分。',
                style: TextStyle(height: 1.5),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const ValueKey('session-back-today'),
                  onPressed: onDone,
                  child: const Text('回到今日'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
