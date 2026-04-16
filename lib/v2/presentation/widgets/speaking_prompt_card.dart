import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../screens/tutorial/widgets/pronunciation_coach_panel.dart';
import '../../../services/pronunciation_check_engine.dart';
import '../../application/providers/v2_providers.dart';
import '../../domain/models/course_models.dart';
import '../../domain/models/speech_models.dart';
import 'v2_page_scaffold.dart';

class SpeakingPromptCard extends ConsumerStatefulWidget {
  final SpeakingPrompt prompt;
  final Color accentColor;

  const SpeakingPromptCard({
    super.key,
    required this.prompt,
    required this.accentColor,
  });

  @override
  ConsumerState<SpeakingPromptCard> createState() => _SpeakingPromptCardState();
}

class _SpeakingPromptCardState extends ConsumerState<SpeakingPromptCard> {
  SpeechFeedback? _latestFeedback;
  SpeechAssessmentReport? _latestReport;
  final List<SpeakingAttemptRecord> _sessionAttempts = [];
  bool _isSubmitting = false;
  String? _submissionStatus;

  @override
  Widget build(BuildContext context) {
    final learner = ref.watch(v2LearnerProfileProvider);
    final persistedHistory = ref.watch(
      v2RecentSpeakingAttemptsProvider(widget.prompt),
    );
    final history = _mergeHistory(persistedHistory.valueOrNull ?? const []);

    return V2InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              V2Pill(
                label: widget.prompt.kind.label,
                color: widget.accentColor,
              ),
              ...widget.prompt.focusWords
                  .take(3)
                  .map(
                    (word) => V2Pill(label: word, color: AppColors.secondary),
                  ),
              V2Pill(
                label: learner.accentShortLabel,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            widget.prompt.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            widget.prompt.scenario,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          if (widget.prompt.checklist.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...widget.prompt.checklist.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(Icons.check_circle_outline, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 6),
          const Text(
            '如果你希望走云端转写和结构化测评，先录下自己的声音再开始检查。云端暂时不可用时，系统会自动回退到本地识别反馈，并明确告诉你当前反馈类型。',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.55,
            ),
          ),
          PronunciationCoachPanel(
            panelId: widget.prompt.id,
            referenceText: widget.prompt.referenceText,
            focusWords: widget.prompt.focusWords,
            title: widget.prompt.title,
            description: widget.prompt.instruction,
            accentColor: widget.accentColor,
            mode: _coachMode(widget.prompt.kind),
            onCheckCompleted: _handleLocalCheck,
            onAttemptReady: _handleAttemptReady,
          ),
          if (_isSubmitting) ...[
            const SizedBox(height: 14),
            const LinearProgressIndicator(minHeight: 4),
            const SizedBox(height: 8),
            const Text(
              '正在上传本次口语尝试，并生成结构化发音反馈...',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
          if (_submissionStatus != null) ...[
            const SizedBox(height: 14),
            Text(
              _submissionStatus!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          if (_latestFeedback != null) ...[
            const SizedBox(height: 16),
            _SpeechFeedbackSummary(
              feedback: _latestFeedback!,
              historyCount: history.length,
            ),
          ],
          if (_latestReport != null) ...[
            const SizedBox(height: 16),
            _AssessmentReportSummary(report: _latestReport!),
          ],
          if (history.isNotEmpty) ...[
            const SizedBox(height: 16),
            _AttemptHistorySummary(attempts: history.take(3).toList()),
          ],
        ],
      ),
    );
  }

  PronunciationCoachMode _coachMode(ActivityKind kind) {
    return switch (kind) {
      ActivityKind.assessmentTask => PronunciationCoachMode.readAloud,
      ActivityKind.shadowing ||
      ActivityKind.dialogRoleplay ||
      ActivityKind.wordRepeat => PronunciationCoachMode.guidedRepeat,
      _ => PronunciationCoachMode.readAloud,
    };
  }

  void _handleLocalCheck(PronunciationCheckResult result) {
    final feedback = ref
        .read(v2SpeechFeedbackEngineProvider)
        .build(
          result: result,
          focusWords: widget.prompt.focusWords,
          fallbackUsed: true,
        );

    setState(() {
      _latestFeedback = feedback;
      _latestReport = ref
          .read(v2LocalAssessmentReportBuilderProvider)
          .build(feedback: feedback, recommendedRoute: '/speaking');
    });
  }

  Future<void> _handleAttemptReady(
    PronunciationCheckResult result,
    dynamic recording,
  ) async {
    final learner = ref.read(v2LearnerProfileProvider);

    setState(() {
      _isSubmitting = true;
      _submissionStatus = '正在准备云端语音评测...';
    });

    final assessment = await ref
        .read(v2SpeechAssessmentServiceProvider)
        .submitAttempt(
          prompt: widget.prompt,
          accentPreference: learner.accentPreference,
          localResult: result,
          learnerRecording: recording,
        );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
      _latestFeedback = assessment.attempt.feedback;
      _latestReport = assessment.report;
      _sessionAttempts.insert(0, assessment.attempt);
      _submissionStatus = assessment.attempt.source == SpeechAttemptSource.cloud
          ? '云端评测已保存，本次练习的反馈和测评报告已经更新。'
          : '云端评测暂时不可用，这一轮已保留为本地回退反馈。';
    });
  }

  List<SpeakingAttemptRecord> _mergeHistory(
    List<SpeakingAttemptRecord> persisted,
  ) {
    final merged = <SpeakingAttemptRecord>[];
    final seen = <String>{};

    for (final attempt in [..._sessionAttempts, ...persisted]) {
      final identity =
          attempt.id ??
          '${attempt.promptId}:${attempt.createdAt.toIso8601String()}:${attempt.feedback.recognizedText}';
      if (seen.add(identity)) {
        merged.add(attempt);
      }
    }

    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return merged;
  }
}

class _SpeechFeedbackSummary extends StatelessWidget {
  final SpeechFeedback feedback;
  final int historyCount;

  const _SpeechFeedbackSummary({
    required this.feedback,
    required this.historyCount,
  });

  @override
  Widget build(BuildContext context) {
    final coveragePercent = (feedback.coverageScore * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '本次学习反馈',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              V2Pill(label: '覆盖率 $coveragePercent%', color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            feedback.teacherExplanation,
            style: const TextStyle(fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              V2Pill(
                label: feedback.fluencyBand.label,
                color: AppColors.successGreen,
              ),
              V2Pill(
                label: feedback.paceBand.label,
                color: AppColors.accentOrange,
              ),
              V2Pill(
                label: feedback.fallbackUsed ? '本地回退' : '云端评测',
                color: feedback.fallbackUsed
                    ? AppColors.textSecondary
                    : AppColors.secondary,
              ),
            ],
          ),
          if (feedback.weakWords.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '不稳定词：${feedback.weakWords.join('、')}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (feedback.retrySuggestions.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...feedback.retrySuggestions.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• $item',
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            historyCount > 0 ? '这个练习已保留 $historyCount 条最近记录。' : '这是当前练习的最新结果。',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssessmentReportSummary extends StatelessWidget {
  final SpeechAssessmentReport report;

  const _AssessmentReportSummary({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '测评报告',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              V2Pill(label: report.source.label, color: AppColors.secondary),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            report.overallLabel,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            report.overview,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          if (report.weakTargets.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: report.weakTargets
                  .map(
                    (tag) =>
                        V2Pill(label: tag.label, color: AppColors.accentOrange),
                  )
                  .toList(),
            ),
          ],
          if (report.nextSteps.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...report.nextSteps.map(
              (step) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• $step',
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AttemptHistorySummary extends StatelessWidget {
  final List<SpeakingAttemptRecord> attempts;

  const _AttemptHistorySummary({required this.attempts});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '最近记录',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...attempts.map(
            (attempt) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      attempt.createdAt.toLocal().toString().substring(0, 16),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  V2Pill(
                    label:
                        '覆盖率 ${(attempt.feedback.coverageScore * 100).round()}%',
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  V2Pill(
                    label: attempt.source.label,
                    color: attempt.source == SpeechAttemptSource.cloud
                        ? AppColors.secondary
                        : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
