import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/progress_provider.dart';
import '../tutorial/widgets/pronunciation_coach_panel.dart';

const _assessmentPrompts = [
  _AssessmentPrompt(
    id: 'assessment_1',
    sentence: 'The weather is beautiful today.',
    translation: '今天天气很好。',
    focus: '/w/ + voiced th',
    progressKey: 'c_th_voiced',
    checklist: ['the weather 里的 th 要有声带振动', 'weather 的 /w/ 用圆唇起音', 'today 尾音不要一带而过'],
  ),
  _AssessmentPrompt(
    id: 'assessment_2',
    sentence: 'She thinks three thousand thoughts.',
    translation: '她在想很多很多的念头。',
    focus: '/θ/ /ð/ + 节奏',
    progressKey: 'c_th_unvoiced',
    checklist: ['three 和 thousand 里的 th 不要缩回成 /s/', 'thoughts 结尾辅音要收住', '不要为了快把重音读丢'],
  ),
  _AssessmentPrompt(
    id: 'assessment_3',
    sentence: 'I would like a cup of coffee, please.',
    translation: '我想来一杯咖啡，谢谢。',
    focus: '弱读 + 句子连贯',
    progressKey: 'rhythm_sentence',
    checklist: ['a cup of 这段不要每个词都一样重', 'coffee 的重音要落在前面', 'please 尾音单独收干净'],
  ),
  _AssessmentPrompt(
    id: 'assessment_4',
    sentence: 'The red car drove very fast.',
    translation: '那辆红色的车开得很快。',
    focus: '/r/ /v/ + 重音',
    progressKey: 'c_r',
    checklist: ['red / drove / very 的起音要清楚', 'very 不要读成 wery', '句子重心放在 drove 和 fast'],
  ),
];

class AssessmentScreen extends ConsumerStatefulWidget {
  const AssessmentScreen({super.key});

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen> {
  int _currentIndex = 0;
  bool _isRecording = false;
  bool _isSaving = false;
  bool _showResult = false;
  late final Map<String, _SelfRating> _ratings;
  _AssessmentSummary? _summary;

  @override
  void initState() {
    super.initState();
    _ratings = {
      for (final prompt in _assessmentPrompts) prompt.id: const _SelfRating(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('朗读自评', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (!_showResult)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentIndex + 1}/${_assessmentPrompts.length}',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _showResult ? _buildResultView() : _buildPromptView(),
    );
  }

  Widget _buildPromptView() {
    final prompt = _assessmentPrompts[_currentIndex];
    final rating = _ratings[prompt.id]!;

    return Column(
      children: [
        _buildProgressIndicator(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _InfoBanner(
                      title: '这里是识别检查 + 引导式自评',
                      body: '你可以先听标准发音并完成浏览器识别检查，再根据提示给自己打分。当前仍不是声学自动评分，所以结果会明确区分“识别反馈”和“自评分数”。',
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _Pill(label: prompt.focus, color: AppColors.accentOrange),
                              const SizedBox(width: 8),
                              _Pill(label: '本句自评', color: AppColors.primary),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            prompt.sentence,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.45),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            prompt.translation,
                            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            '读前提醒',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 10),
                          ...prompt.checklist.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Icon(Icons.check_circle_outline, size: 16, color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.55),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: PronunciationCoachPanel(
                        key: ValueKey('assessment-coach-${prompt.id}'),
                        panelId: 'assessment_${prompt.id}',
                        referenceText: prompt.sentence,
                        accentColor: AppColors.primary,
                        mode: PronunciationCoachMode.readAloud,
                        title: '先听标准发音，再完成这一句朗读',
                        description:
                            '这里会先播放系统标准发音，再用浏览器语音识别检查你是否把整句和重点词读出来。',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '读完后，给自己打个分',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 16),
                          _RatingRow(
                            label: '清晰度',
                            value: rating.clarity,
                            onChanged: (value) => _updateRating(prompt.id, rating.copyWith(clarity: value)),
                          ),
                          const SizedBox(height: 14),
                          _RatingRow(
                            label: '节奏感',
                            value: rating.rhythm,
                            onChanged: (value) => _updateRating(prompt.id, rating.copyWith(rhythm: value)),
                          ),
                          const SizedBox(height: 14),
                          _RatingRow(
                            label: '稳定度',
                            value: rating.control,
                            onChanged: (value) => _updateRating(prompt.id, rating.copyWith(control: value)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Row(
              children: [
                if (_currentIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : _goPrevious,
                      child: const Text('上一句'),
                    ),
                  ),
                if (_currentIndex > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _goNext,
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_currentIndex == _assessmentPrompts.length - 1 ? '生成自评结果' : '下一句'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: List.generate(_assessmentPrompts.length, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: index <= _currentIndex ? AppColors.primary : AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildResultView() {
    final summary = _summary!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Text('自评完成', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    const Text('综合分数', style: TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      '${summary.overall.round()}',
                      style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        summary.levelLabel,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '+20 XP 已记录，这个结果基于你刚才的自评，不是自动评分。',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('维度拆分', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),
                    _ScoreRow(label: '清晰度', score: summary.clarity, color: AppColors.successGreen),
                    const SizedBox(height: 10),
                    _ScoreRow(label: '节奏感', score: summary.rhythm, color: AppColors.accentOrange),
                    const SizedBox(height: 10),
                    _ScoreRow(label: '稳定度', score: summary.control, color: AppColors.primary),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('下一轮优先练什么', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    ...summary.recommendations.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Icon(Icons.arrow_right_alt, color: AppColors.primary),
                            ),
                            Expanded(
                              child: Text(
                                item,
                                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (summary.weakTargets.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: summary.weakTargets
                            .map((item) => _WeakTargetChip(label: item.label, score: item.score.round()))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/practice'),
                  child: const Text('去练习中心继续巩固'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _resetAssessment,
                  child: const Text('再测一次'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  void _toggleRecording() {
    final justFinished = _isRecording;
    setState(() {
      _isRecording = !_isRecording;
    });

    if (justFinished) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('这一句已经读完了，接下来按照感受给自己打分就好。')),
      );
    }
  }

  void _updateRating(String promptId, _SelfRating rating) {
    setState(() {
      _ratings[promptId] = rating;
    });
  }

  void _goPrevious() {
    if (_currentIndex == 0) return;
    setState(() {
      _isRecording = false;
      _currentIndex -= 1;
    });
  }

  Future<void> _goNext() async {
    if (_currentIndex < _assessmentPrompts.length - 1) {
      setState(() {
        _isRecording = false;
        _currentIndex += 1;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _isRecording = false;
    });

    final summary = _buildSummary();
    final phonemeUpdates = {
      for (final prompt in _assessmentPrompts) prompt.progressKey: _ratings[prompt.id]!.overallScore,
    };

    await ref.read(progressProvider.notifier).completeAssessment(
          xp: 20,
          phonemeUpdates: phonemeUpdates,
        );

    if (!mounted) {
      return;
    }

    setState(() {
      _summary = summary;
      _showResult = true;
      _isSaving = false;
    });
  }

  _AssessmentSummary _buildSummary() {
    final clarity = _ratings.values.map((item) => item.clarityScore).reduce((a, b) => a + b) / _ratings.length;
    final rhythm = _ratings.values.map((item) => item.rhythmScore).reduce((a, b) => a + b) / _ratings.length;
    final control = _ratings.values.map((item) => item.controlScore).reduce((a, b) => a + b) / _ratings.length;
    final weakTargets = _assessmentPrompts
        .map(
          (prompt) => _WeakTarget(
            label: prompt.focus,
            score: _ratings[prompt.id]!.overallScore,
          ),
        )
        .toList()
      ..sort((a, b) => a.score.compareTo(b.score));

    final recommendations = <String>[
      weakTargets.first.score < 75
          ? '先回练“${weakTargets.first.label}”这一项，不要急着换更多材料。'
          : '整体状态不错，可以继续推进教程主线，再回练细节。',
      rhythm < 75
          ? '下一轮读慢一点，把重音词单独拎出来再连回句子。'
          : '节奏基本稳定，下一轮可以开始关注句尾收音。 ',
      clarity < 75
          ? '优先盯住元音开口和辅音收尾，不要为了快牺牲边界。'
          : '清晰度已经有基础，下一轮重点放在稳定复现上。',
    ];

    return _AssessmentSummary(
      clarity: clarity,
      rhythm: rhythm,
      control: control,
      weakTargets: weakTargets.take(3).toList(),
      recommendations: recommendations,
    );
  }

  void _resetAssessment() {
    setState(() {
      _currentIndex = 0;
      _isRecording = false;
      _showResult = false;
      _summary = null;
      _ratings.updateAll((key, value) => const _SelfRating());
    });
  }
}

class _InfoBanner extends StatelessWidget {
  final String title;
  final String body;

  const _InfoBanner({
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
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

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _RatingRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(5, (index) {
            final score = index + 1;
            final selected = value == score;
            return ChoiceChip(
              label: Text('$score'),
              selected: selected,
              onSelected: (_) => onChanged(score),
            );
          }),
        ),
      ],
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final double score;
  final Color color;

  const _ScoreRow({required this.label, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 64, child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${score.round()}', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

class _WeakTargetChip extends StatelessWidget {
  final String label;
  final int score;

  const _WeakTargetChip({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accentOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentOrange)),
          const SizedBox(width: 6),
          Text('$score 分', style: const TextStyle(fontSize: 12, color: AppColors.accentOrange)),
        ],
      ),
    );
  }
}

class _AssessmentPrompt {
  final String id;
  final String sentence;
  final String translation;
  final String focus;
  final String progressKey;
  final List<String> checklist;

  const _AssessmentPrompt({
    required this.id,
    required this.sentence,
    required this.translation,
    required this.focus,
    required this.progressKey,
    required this.checklist,
  });
}

class _SelfRating {
  final int clarity;
  final int rhythm;
  final int control;

  const _SelfRating({
    this.clarity = 3,
    this.rhythm = 3,
    this.control = 3,
  });

  _SelfRating copyWith({
    int? clarity,
    int? rhythm,
    int? control,
  }) {
    return _SelfRating(
      clarity: clarity ?? this.clarity,
      rhythm: rhythm ?? this.rhythm,
      control: control ?? this.control,
    );
  }

  double get clarityScore => clarity * 20.0;
  double get rhythmScore => rhythm * 20.0;
  double get controlScore => control * 20.0;
  double get overallScore => (clarityScore + rhythmScore + controlScore) / 3;
}

class _AssessmentSummary {
  final double clarity;
  final double rhythm;
  final double control;
  final List<_WeakTarget> weakTargets;
  final List<String> recommendations;

  const _AssessmentSummary({
    required this.clarity,
    required this.rhythm,
    required this.control,
    required this.weakTargets,
    required this.recommendations,
  });

  double get overall => (clarity + rhythm + control) / 3;

  String get levelLabel {
    if (overall >= 85) return '状态很好';
    if (overall >= 70) return '继续巩固';
    return '先稳住基础';
  }
}

class _WeakTarget {
  final String label;
  final double score;

  const _WeakTarget({
    required this.label,
    required this.score,
  });
}
