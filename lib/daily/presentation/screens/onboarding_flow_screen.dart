import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../v2/application/providers/v2_providers.dart';
import '../../../v2/domain/models/learner_models.dart';
import '../widgets/daily_widgets.dart';

class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final setup = ref.watch(v2LearnerSetupProvider);
    final notifier = ref.read(v2LearnerSetupProvider.notifier);
    final total = 5;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: (_step + 1) / total,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  const SizedBox(height: 28),
                  Expanded(child: _buildStep(setup, notifier)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: ValueKey(_step == total - 1
                          ? 'onboarding-finish'
                          : 'onboarding-next'),
                      onPressed: () => _next(notifier),
                      child: Text(_step == total - 1 ? '开始今日任务' : '继续'),
                    ),
                  ),
                  if (_step == 0)
                    TextButton(
                      onPressed: () => context.push('/auth?from=%2Fonboarding'),
                      child: const Text('已有账号，去登录'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(
    V2LearnerSetupState setup,
    V2LearnerSetupNotifier notifier,
  ) {
    return switch (_step) {
      0 => const _OnboardCopy(
        eyebrow: '声临其境',
        title: '每天开口 3 件事，比刷一整本单词更有用。',
        body: '先听，再说，再看识别有没有对齐。没有接上评分引擎时，我们不会编一个发音分数。',
      ),
      1 => _ChoiceStep(
        title: '你最想先解决什么？',
        subtitle: '今日第 3 个任务会按这个目标来。',
        children: LearningGoal.values.map((goal) {
          return _ChoiceCard(
            selected: setup.goal == goal,
            title: goal.title,
            subtitle: goal.subtitle,
            onTap: () => notifier.setGoal(goal),
          );
        }).toList(),
      ),
      2 => _ChoiceStep(
        title: '现在大概什么程度？',
        subtitle: '这只决定起步难度，不是考试。',
        children: PlacementLevel.values.map((level) {
          return _ChoiceCard(
            selected: setup.placementLevel == level,
            title: level.title,
            subtitle: level.subtitle,
            onTap: () => notifier.setPlacementLevel(level),
          );
        }).toList(),
      ),
      3 => _ChoiceStep(
        title: '示范音用哪种口音？',
        subtitle: '可以随时在「我的」里改。',
        children: [
          _ChoiceCard(
            selected: setup.accentPreference != 'british',
            title: '美式发音',
            subtitle: '示范和识别优先按美式走。',
            onTap: () => notifier.setAccentPreference('american'),
          ),
          _ChoiceCard(
            selected: setup.accentPreference == 'british',
            title: '英式发音',
            subtitle: '示范和识别优先按英式走。',
            onTap: () => notifier.setAccentPreference('british'),
          ),
        ],
      ),
      _ => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _OnboardCopy(
            eyebrow: '每日目标',
            title: '你每天能拿出多少分钟？',
            body: '我们会把这 3 个任务压进这个时长里：一节开口课、一次补弱、一次场景迁移。',
          ),
          const SizedBox(height: 20),
          DailyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${setup.dailyMinutes} 分钟',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Slider(
                  value: setup.dailyMinutes.toDouble(),
                  min: 10,
                  max: 30,
                  divisions: 4,
                  label: '${setup.dailyMinutes} 分钟',
                  onChanged: (value) => notifier.setDailyMinutes(value.round()),
                ),
              ],
            ),
          ),
        ],
      ),
    };
  }

  Future<void> _next(V2LearnerSetupNotifier notifier) async {
    if (_step < 4) {
      setState(() => _step += 1);
      return;
    }
    await notifier.completeOnboarding();
    if (mounted) {
      context.go('/today');
    }
  }
}

class _OnboardCopy extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String body;

  const _OnboardCopy({
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 30,
            height: 1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          body,
          style: const TextStyle(
            fontSize: 16,
            height: 1.55,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ChoiceStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _ChoiceStep({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _OnboardCopy(eyebrow: '设置', title: title, body: subtitle),
        const SizedBox(height: 20),
        ...children.map(
          (child) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DailyCard(
      color: selected ? AppColors.surfaceAccent : Colors.white,
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            selected ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: selected ? AppColors.primary : AppColors.textHint,
          ),
        ],
      ),
    );
  }
}
