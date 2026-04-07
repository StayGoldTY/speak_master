import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/did_you_know_card.dart';
import '../../widgets/record_button.dart';

class LessonScreen extends StatefulWidget {
  final String lessonId;
  const LessonScreen({super.key, required this.lessonId});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _currentStep = 0;
  bool _isRecording = false;
  double? _score;

  static const _steps = [
    _LessonStepData('看：发音原理', '观察口腔动画，了解发声位置', Icons.visibility),
    _LessonStepData('听：标准发音', '聆听标准发音，注意细节', Icons.headphones),
    _LessonStepData('说：跟读练习', '录音并与标准发音对比', Icons.mic),
    _LessonStepData('辨：听辨测试', '选择你听到的正确发音', Icons.quiz),
    _LessonStepData('玩：趣味闯关', '完成游戏化练习', Icons.games),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('课程 ${widget.lessonId.split('_').last}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentStep + 1}/${_steps.length}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(child: _buildStepContent()),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: List.generate(_steps.length, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: index <= _currentStep
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    final step = _steps[_currentStep];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(step.icon, color: AppColors.primary, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            step.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            step.subtitle,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (_currentStep == 0) _buildTheoryContent(),
          if (_currentStep == 1) _buildListenContent(),
          if (_currentStep == 2) _buildPracticeContent(),
          if (_currentStep == 3) _buildQuizContent(),
          if (_currentStep == 4) _buildGameContent(),
        ],
      ),
    );
  }

  Widget _buildTheoryContent() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.face, size: 64, color: AppColors.primary),
                SizedBox(height: 12),
                Text('口腔动画区域', style: TextStyle(color: AppColors.textSecondary)),
                Text('舌位·唇形·气流可视化', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('发音要点', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              SizedBox(height: 8),
              Text(
                '舌尖轻轻伸出上下齿之间，气流从舌面和上齿间的缝隙中挤出。声带不振动（清音）。',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const DidYouKnowCard(
          text: '英语的 /θ/ 音在全世界的语言中其实很少见！只有约 4% 的语言有这个音。这也是为什么它对大多数非英语母语者来说都很难。',
          source: 'Maddieson (1984), Patterns of Sounds',
        ),
      ],
    );
  }

  Widget _buildListenContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.suprasegmentalColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text(
                'think',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text('/θɪŋk/', style: TextStyle(fontSize: 18, color: AppColors.primary)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SpeedButton(label: '0.5x', isSelected: false),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: () {},
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 8),
                  _SpeedButton(label: '1.0x', isSelected: true),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            _AccentChip(label: '美式', isSelected: true),
            SizedBox(width: 8),
            _AccentChip(label: '英式', isSelected: false),
          ],
        ),
      ],
    );
  }

  Widget _buildPracticeContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              const Text(
                'Thirty-three thin thieves thought.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('波形对比区域', style: TextStyle(color: AppColors.textHint)),
                ),
              ),
              const SizedBox(height: 24),
              RecordButton(
                isRecording: _isRecording,
                onTap: () => setState(() => _isRecording = !_isRecording),
              ),
              if (_score != null) ...[
                const SizedBox(height: 16),
                _ScoreDisplay(score: _score!),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuizContent() {
    return Column(
      children: [
        const Text('你听到的是哪个？', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.volume_up, size: 40, color: AppColors.primary),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _QuizOption(label: 'think /θɪŋk/', onTap: () {})),
            const SizedBox(width: 12),
            Expanded(child: _QuizOption(label: 'sink /sɪŋk/', onTap: () {})),
          ],
        ),
      ],
    );
  }

  Widget _buildGameContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.xpGold.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.xpGold.withValues(alpha: 0.2)),
      ),
      child: const Column(
        children: [
          Icon(Icons.emoji_events, size: 64, color: AppColors.xpGold),
          SizedBox(height: 16),
          Text('绕口令闯关', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(
            '大声朗读绕口令，AI 为你的发音评分！',
            style: TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep--),
                  child: const Text('上一步'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentStep < _steps.length - 1) {
                    setState(() => _currentStep++);
                  } else {
                    _showCompletionDialog();
                  }
                },
                child: Text(_currentStep < _steps.length - 1 ? '下一步' : '完成课程'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text('课程完成！', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.xpGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('+10 XP', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentOrange)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonStepData {
  final String title;
  final String subtitle;
  final IconData icon;
  const _LessonStepData(this.title, this.subtitle, this.icon);
}

class _SpeedButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _SpeedButton({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textHint, fontSize: 13)),
    );
  }
}

class _AccentChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _AccentChip({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.primary, fontSize: 13)),
    );
  }
}

class _QuizOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuizOption({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
      ),
    );
  }
}

class _ScoreDisplay extends StatelessWidget {
  final double score;
  const _ScoreDisplay({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = score >= 80 ? AppColors.successGreen : score >= 60 ? AppColors.accentOrange : AppColors.errorRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('发音评分：${score.toInt()}分', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}
