import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/record_button.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> with SingleTickerProviderStateMixin {
  static const _starterPassages = [
    _StarterPassage(
      title: '开口热身',
      focus: '嘴巴打开 + 清楚元音',
      script: 'Today I speak slowly and clearly.\nI open my mouth and let every vowel land.',
    ),
    _StarterPassage(
      title: '节奏练习',
      focus: '重音 + 节奏',
      script: 'I want to make my English sound steady.\nNot fast. Not flat. Just clear and alive.',
    ),
    _StarterPassage(
      title: '自定义过渡',
      focus: '把教程内容迁移到真实表达',
      script: 'Pick one lesson you just finished and explain it aloud in your own words.',
    ),
  ];

  static const _followReadMaterials = [
    _FollowReadMaterial(
      title: 'Morning Reset',
      category: '日常表达',
      level: '初级',
      duration: '约 1 分钟',
      focus: '重音 + 句子节奏',
      excerpt: 'I start my morning with water, a deep breath, and one clear sentence in English.',
      checklist: ['先划出重音词', '第一遍慢读，第二遍连起来读', '结尾不要一路冲平'],
    ),
    _FollowReadMaterial(
      title: 'Small Wins',
      category: '自我表达',
      level: '初中级',
      duration: '约 90 秒',
      focus: '/i:/ /ɪ/ + 轻重变化',
      excerpt: 'Progress is small at first, but every clean sound makes the next sentence easier.',
      checklist: ['听不见标准音时先守住清晰度', '长短元音要拉开', '不要把 every、easier 读成一个节拍'],
    ),
    _FollowReadMaterial(
      title: 'Weather Check',
      category: '描述场景',
      level: '初中级',
      duration: '约 1 分钟',
      focus: '/w/ /ð/ + 自然连读',
      excerpt: 'The weather this week is warmer than before, so I want to spend more time outside.',
      checklist: ['the / this 里的 th 要分清清浊', 'warmer 里的 /w/ 用圆唇起音', 'than before 不要断得太碎'],
    ),
  ];

  static const _twisters = [
    _TongueTwisterDrill(
      text: 'She sells seashells by the seashore.',
      targetSound: '/ʃ/ vs /s/',
      level: 1,
      coaching: '先把 ship / sheep / sip 的边界读清，再追速度。',
    ),
    _TongueTwisterDrill(
      text: 'Peter Piper picked a peck of pickled peppers.',
      targetSound: '/p/',
      level: 2,
      coaching: '每个 /p/ 都要有干净起爆，不要把整句读成一团。',
    ),
    _TongueTwisterDrill(
      text: 'Red lorry, yellow lorry.',
      targetSound: '/r/ vs /l/',
      level: 2,
      coaching: '先拆成两个词组读稳，再把节奏提起来。',
    ),
    _TongueTwisterDrill(
      text: 'The thirty-three thieves thought that they thrilled the throne throughout Thursday.',
      targetSound: '/θ/ /ð/',
      level: 3,
      coaching: '这句重点不是快，而是每个 th 都别缩回成 /s/ 或 /d/。',
    ),
  ];

  late final TabController _tabController;
  late final TextEditingController _freeReadController;

  bool _isFreeReadRecording = false;
  bool _isFollowReadRecording = false;
  int _selectedStarterIndex = 0;
  int _selectedMaterialIndex = 0;
  int _freeReadRounds = 0;
  int _followReadRounds = 0;
  int _tongueTwisterRounds = 0;
  final Set<int> _completedMaterials = {};
  final Set<int> _completedTwisters = {};

  int get _sessionRounds => _freeReadRounds + _followReadRounds + _tongueTwisterRounds;
  int get _estimatedMinutes => _freeReadRounds * 2 + _followReadRounds * 3 + _tongueTwisterRounds;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _freeReadController = TextEditingController(text: _starterPassages.first.script);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _freeReadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _Header(
                  sessionRounds: _sessionRounds,
                  estimatedMinutes: _estimatedMinutes,
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
                  Tab(text: '跟读参考'),
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
        ),
      ),
    );
  }

  Widget _buildFreeReadTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final main = Column(
          children: [
            _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '把你真正想说的内容读出来',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '这里没有假波形、假评分，也不会偷偷假装保存音频。你可以把教程里的句子、自己的复述，或者一段真实英文粘过来，大声读两遍。',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.7),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _freeReadController,
                    minLines: 8,
                    maxLines: 12,
                    decoration: InputDecoration(
                      hintText: '在这里输入或粘贴你想朗读的英文内容...',
                      filled: true,
                      fillColor: AppColors.bgLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _loadStarter(_selectedStarterIndex),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('恢复当前模板'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _freeReadController.clear(),
                        icon: const Icon(Icons.edit_note, size: 16),
                        label: const Text('清空重写'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Panel(
              child: Column(
                children: [
                  RecordButton(
                    isRecording: _isFreeReadRecording,
                    onTap: _toggleFreeReadRecording,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isFreeReadRecording ? '录音中，先完整读完一遍再停。' : '点击开始一轮自由朗读。',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  const _HonestBanner(
                    title: '当前版本不会做什么',
                    body: '不会播放示范音频、不会生成 AI 分数、不会保存录音文件。它只提供诚实的自练入口和本次会话统计。',
                  ),
                ],
              ),
            ),
          ],
        );

        final side = Column(
          children: [
            _SessionCard(
              title: '本次会话',
              items: [
                _SessionMetric(label: '自由朗读', value: '$_freeReadRounds 轮'),
                _SessionMetric(label: '估算时长', value: '$_estimatedMinutes 分钟'),
                _SessionMetric(label: '总练习数', value: '$_sessionRounds 轮'),
              ],
            ),
            const SizedBox(height: 16),
            _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '快捷模板',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(_starterPassages.length, (index) {
                    final item = _starterPassages[index];
                    final isSelected = index == _selectedStarterIndex;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () => _loadStarter(index),
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.bgLight,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.focus,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 7, child: main),
                    const SizedBox(width: 16),
                    Expanded(flex: 4, child: side),
                  ],
                )
              : Column(
                  children: [
                    main,
                    const SizedBox(height: 16),
                    side,
                  ],
                ),
        );
      },
    );
  }

  Widget _buildFollowReadTab() {
    final selected = _followReadMaterials[_selectedMaterialIndex];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 960;
        final detail = _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Tag(label: selected.category, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  _Tag(label: selected.level, color: AppColors.primary),
                  const Spacer(),
                  Text(
                    selected.duration,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                selected.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                '练习重点：${selected.focus}',
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  selected.excerpt,
                  style: const TextStyle(fontSize: 18, height: 1.75, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 18),
              const _HonestBanner(
                title: '这里为什么叫“跟读参考”',
                body: '因为当前版本还没有接入真实示范音频。你现在能做的是先看脚本、按重点读，再用录音按钮完成一轮自练。',
              ),
              const SizedBox(height: 18),
              const Text(
                '推荐顺序',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ...selected.checklist.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Icon(Icons.check_circle_outline, size: 16, color: AppColors.secondary),
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
              const SizedBox(height: 22),
              Center(
                child: Column(
                  children: [
                    RecordButton(
                      isRecording: _isFollowReadRecording,
                      onTap: _toggleFollowReadRecording,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isFollowReadRecording ? '录音中，照着上面的重点读完整段。' : '点击开始一轮跟读自练。',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _markFollowReadCompleted(_selectedMaterialIndex),
                    icon: const Icon(Icons.task_alt, size: 18),
                    label: Text(
                      _completedMaterials.contains(_selectedMaterialIndex) ? '已标记练完' : '标记已练完',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showMessage('建议你再读第二遍时，重点只盯一个问题，例如长短元音或句子重音。'),
                    icon: const Icon(Icons.tips_and_updates_outlined, size: 18),
                    label: const Text('查看练习建议'),
                  ),
                ],
              ),
            ],
          ),
        );

        final list = _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '参考材料',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              ...List.generate(_followReadMaterials.length, (index) {
                final item = _followReadMaterials[index];
                final isSelected = index == _selectedMaterialIndex;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => setState(() => _selectedMaterialIndex = index),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.secondary.withValues(alpha: 0.08) : AppColors.bgLight,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected ? AppColors.secondary.withValues(alpha: 0.2) : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.focus,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          if (_completedMaterials.contains(index))
                            const Icon(Icons.task_alt, color: AppColors.successGreen),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: detail),
                    const SizedBox(width: 16),
                    Expanded(flex: 4, child: list),
                  ],
                )
              : Column(
                  children: [
                    detail,
                    const SizedBox(height: 16),
                    list,
                  ],
                ),
        );
      },
    );
  }

  Widget _buildTongueTwisterTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _HonestBanner(
          title: '绕口令的正确用法',
          body: '不要一上来追速度。先把目标音读对，再把节奏提起来。快但错，只会把旧习惯练得更牢。',
        ),
        const SizedBox(height: 16),
        ...List.generate(_twisters.length, (index) {
          final item = _twisters[index];
          final isDone = _completedTwisters.contains(index);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Tag(label: item.targetSound, color: AppColors.accentOrange),
                      const Spacer(),
                      Row(
                        children: List.generate(
                          3,
                          (star) => Icon(
                            Icons.star,
                            size: 14,
                            color: star < item.level ? AppColors.xpGold : AppColors.textHint.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.text,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.55),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.coaching,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _logTongueTwisterRound(index, completed: false),
                        icon: const Icon(Icons.slow_motion_video, size: 18),
                        label: const Text('慢速一轮'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _logTongueTwisterRound(index, completed: true),
                        icon: const Icon(Icons.bolt, size: 18),
                        label: Text(isDone ? '已完成挑战' : '完成挑战'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _loadStarter(int index) {
    setState(() {
      _selectedStarterIndex = index;
      _freeReadController.text = _starterPassages[index].script;
    });
  }

  void _toggleFreeReadRecording() {
    final finishedRound = _isFreeReadRecording;
    setState(() {
      _isFreeReadRecording = !_isFreeReadRecording;
      if (finishedRound) {
        _freeReadRounds += 1;
      }
    });

    if (finishedRound) {
      _showMessage('已完成 1 轮自由朗读。本阶段不会保存音频，你可以立刻再读第二遍。');
    }
  }

  void _toggleFollowReadRecording() {
    final finishedRound = _isFollowReadRecording;
    setState(() {
      _isFollowReadRecording = !_isFollowReadRecording;
      if (finishedRound) {
        _followReadRounds += 1;
        _completedMaterials.add(_selectedMaterialIndex);
      }
    });

    if (finishedRound) {
      _showMessage('已完成 1 轮跟读自练，建议马上回看刚才那一处最容易散掉的音。');
    }
  }

  void _markFollowReadCompleted(int index) {
    setState(() {
      _completedMaterials.add(index);
      _followReadRounds += 1;
    });
    _showMessage('这段材料已记为练完。下次可以换一段，或者回到教程主线继续推进。');
  }

  void _logTongueTwisterRound(int index, {required bool completed}) {
    setState(() {
      _tongueTwisterRounds += 1;
      if (completed) {
        _completedTwisters.add(index);
      }
    });

    _showMessage(
      completed ? '挑战已记录。记住，速度永远排在准确之后。' : '已记录一轮慢速练习，先稳住目标音再提速。',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _Header extends StatelessWidget {
  final int sessionRounds;
  final int estimatedMinutes;

  const _Header({
    required this.sessionRounds,
    required this.estimatedMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('练习中心', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text(
                '这里先把“真实可练”做好。没有接好的能力就明确告诉你，没有假播放也没有假评分。',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.55),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.xpGold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '本次已练 $sessionRounds 轮 · 约 $estimatedMinutes 分钟',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accentOrange),
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }
}

class _SessionCard extends StatelessWidget {
  final String title;
  final List<_SessionMetric> items;

  const _SessionCard({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.label,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ),
                  Text(
                    item.value,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
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

class _SessionMetric {
  final String label;
  final String value;

  const _SessionMetric({
    required this.label,
    required this.value,
  });
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({
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
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _HonestBanner extends StatelessWidget {
  final String title;
  final String body;

  const _HonestBanner({
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

class _StarterPassage {
  final String title;
  final String focus;
  final String script;

  const _StarterPassage({
    required this.title,
    required this.focus,
    required this.script,
  });
}

class _FollowReadMaterial {
  final String title;
  final String category;
  final String level;
  final String duration;
  final String focus;
  final String excerpt;
  final List<String> checklist;

  const _FollowReadMaterial({
    required this.title,
    required this.category,
    required this.level,
    required this.duration,
    required this.focus,
    required this.excerpt,
    required this.checklist,
  });
}

class _TongueTwisterDrill {
  final String text;
  final String targetSound;
  final int level;
  final String coaching;

  const _TongueTwisterDrill({
    required this.text,
    required this.targetSound,
    required this.level,
    required this.coaching,
  });
}
