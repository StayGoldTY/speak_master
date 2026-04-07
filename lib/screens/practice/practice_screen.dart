import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/record_button.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                const Text('练习中心', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.xpGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_fire_department, color: AppColors.accentOrange, size: 16),
                      SizedBox(width: 4),
                      Text('今日 2/3', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accentOrange)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textHint,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: '自由朗读'),
              Tab(text: '跟读训练'),
              Tab(text: '绕口令'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFreeReadTab(),
                _buildFollowReadTab(),
                _buildTongueTwisterTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeReadTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                const Text(
                  '自由朗读模式',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '大声朗读任何英文内容\nAI 实时分析你的发音',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('实时波形显示区域', style: TextStyle(color: AppColors.textHint)),
                  ),
                ),
                const SizedBox(height: 24),
                RecordButton(
                  isRecording: _isRecording,
                  onTap: () => setState(() => _isRecording = !_isRecording),
                ),
                const SizedBox(height: 12),
                Text(
                  _isRecording ? '正在录音...' : '点击开始录音',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildTodayStats(),
        ],
      ),
    );
  }

  Widget _buildFollowReadTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _MaterialCard(
          category: 'TED 演讲',
          title: 'The Power of Vulnerability',
          speaker: 'Brené Brown',
          difficulty: '中级',
          duration: '3 min',
          color: AppColors.primary,
        ),
        const SizedBox(height: 12),
        _MaterialCard(
          category: '经典文学',
          title: 'To be, or not to be',
          speaker: 'Shakespeare',
          difficulty: '高级',
          duration: '2 min',
          color: AppColors.grammarColor,
        ),
        const SizedBox(height: 12),
        _MaterialCard(
          category: '日常对话',
          title: 'Ordering Coffee',
          speaker: '情景对话',
          difficulty: '初级',
          duration: '1 min',
          color: AppColors.secondary,
        ),
        const SizedBox(height: 12),
        _MaterialCard(
          category: '新闻播报',
          title: 'BBC News Report',
          speaker: 'BBC Anchor',
          difficulty: '高级',
          duration: '2 min',
          color: AppColors.accentOrange,
        ),
      ],
    );
  }

  Widget _buildTongueTwisterTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        _TongueTwisterCard(
          text: 'She sells seashells by the seashore.',
          targetSound: '/ʃ/ vs /s/',
          difficulty: 1,
        ),
        SizedBox(height: 12),
        _TongueTwisterCard(
          text: 'Peter Piper picked a peck of pickled peppers.',
          targetSound: '/p/',
          difficulty: 2,
        ),
        SizedBox(height: 12),
        _TongueTwisterCard(
          text: 'Red lorry, yellow lorry.',
          targetSound: '/r/ vs /l/',
          difficulty: 2,
        ),
        SizedBox(height: 12),
        _TongueTwisterCard(
          text: 'The thirty-three thieves thought that they thrilled the throne throughout Thursday.',
          targetSound: '/θ/ vs /ð/',
          difficulty: 3,
        ),
        SizedBox(height: 12),
        _TongueTwisterCard(
          text: 'How much wood would a woodchuck chuck if a woodchuck could chuck wood?',
          targetSound: '/w/ /ʊ/',
          difficulty: 3,
        ),
      ],
    );
  }

  Widget _buildTodayStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: '今日朗读', value: '5 次', icon: Icons.mic),
          _StatItem(label: '总时长', value: '12 分', icon: Icons.timer),
          _StatItem(label: '平均评分', value: '78', icon: Icons.score),
        ],
      ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final String category;
  final String title;
  final String speaker;
  final String difficulty;
  final String duration;
  final Color color;

  const _MaterialCard({
    required this.category,
    required this.title,
    required this.speaker,
    required this.difficulty,
    required this.duration,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.play_circle_filled, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text('$speaker · $difficulty · $duration', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: color, size: 20),
        ],
      ),
    );
  }
}

class _TongueTwisterCard extends StatelessWidget {
  final String text;
  final String targetSound;
  final int difficulty;

  const _TongueTwisterCard({required this.text, required this.targetSound, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(targetSound, style: const TextStyle(fontSize: 12, color: AppColors.accentOrange, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              Row(
                children: List.generate(3, (i) => Icon(
                  Icons.star,
                  size: 14,
                  color: i < difficulty ? AppColors.xpGold : AppColors.textHint.withValues(alpha: 0.3),
                )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.5)),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.volume_up, size: 16),
                label: const Text('听标准', style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.mic, size: 16),
                label: const Text('开始挑战', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}
