import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/record_button.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  int _currentQuestion = 0;
  bool _isRecording = false;
  bool _showResult = false;

  static const _testSentences = [
    'The weather is beautiful today.',
    'She thinks three thousand thoughts.',
    'I would like a cup of coffee, please.',
    'The red car drove very fast.',
    'Can you hear the birds singing?',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发音测评', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
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
                  '${_currentQuestion + 1}/${_testSentences.length}',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _showResult ? _buildResultView() : _buildTestView(),
    );
  }

  Widget _buildTestView() {
    return Column(
      children: [
        _buildProgressIndicator(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '请大声朗读以下句子',
                  style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _testSentences[_currentQuestion],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.volume_up, color: AppColors.primary),
                        tooltip: '听标准发音',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _isRecording ? '录音中...' : '波形显示区域',
                      style: const TextStyle(color: AppColors.textHint),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                RecordButton(
                  isRecording: _isRecording,
                  onTap: () {
                    setState(() => _isRecording = !_isRecording);
                    if (!_isRecording) {
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (_currentQuestion < _testSentences.length - 1) {
                          setState(() => _currentQuestion++);
                        } else {
                          setState(() => _showResult = true);
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  _isRecording ? '点击停止' : '点击录音',
                  style: const TextStyle(color: AppColors.textHint, fontSize: 13),
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
        children: List.generate(_testSentences.length, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: index <= _currentQuestion
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildResultView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text('测评完成', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                const Text('综合评分', style: TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 4),
                const Text('82', style: TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('良好', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 12),
                const Text('+20 XP', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailScores(),
          const SizedBox(height: 20),
          _buildWeakPhonemes(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('返回'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => setState(() {
                _showResult = false;
                _currentQuestion = 0;
              }),
              child: const Text('重新测试'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailScores() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('详细评分', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),
          _ScoreRow(label: '准确度', score: 85, color: AppColors.successGreen),
          const SizedBox(height: 8),
          _ScoreRow(label: '流利度', score: 78, color: AppColors.accentOrange),
          const SizedBox(height: 8),
          _ScoreRow(label: '语调', score: 80, color: AppColors.primary),
          const SizedBox(height: 8),
          _ScoreRow(label: '重音', score: 84, color: AppColors.suprasegmentalColor),
        ],
      ),
    );
  }

  Widget _buildWeakPhonemes() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber, color: AppColors.errorRed, size: 18),
              SizedBox(width: 6),
              Text('需要加强的音素', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.errorRed)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _WeakPhonemeChip(symbol: '/θ/', score: 62),
              _WeakPhonemeChip(symbol: '/ð/', score: 65),
              _WeakPhonemeChip(symbol: '/r/', score: 68),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final int score;
  final Color color;

  const _ScoreRow({required this.label, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
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
        Text('$score', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

class _WeakPhonemeChip extends StatelessWidget {
  final String symbol;
  final int score;

  const _WeakPhonemeChip({required this.symbol, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.errorRed)),
          const SizedBox(width: 6),
          Text('$score分', style: const TextStyle(fontSize: 12, color: AppColors.errorRed)),
        ],
      ),
    );
  }
}
