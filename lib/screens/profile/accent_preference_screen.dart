import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_providers.dart';

class AccentPreferenceScreen extends ConsumerStatefulWidget {
  const AccentPreferenceScreen({super.key});

  @override
  ConsumerState<AccentPreferenceScreen> createState() => _AccentPreferenceScreenState();
}

class _AccentPreferenceScreenState extends ConsumerState<AccentPreferenceScreen> {
  late String _selectedAccent;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authProvider);
    final storage = ref.read(storageServiceProvider);
    _selectedAccent = authState.profile?.accentPreference ?? storage.loadAccentPreference(fallback: 'american');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.status == AuthStatus.authenticated;

    return Scaffold(
      appBar: AppBar(title: const Text('口音偏好')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const _IntroCard(
                title: '选择你的默认参考口音',
                body: '这个设置会影响教程说明、练习文案和部分资料页里的默认标注方式。当前阶段它主要用于学习偏好和内容呈现，不会强行改写所有课程文本。',
              ),
              const SizedBox(height: 16),
              _AccentOptionCard(
                title: '美式 English',
                subtitle: '更适合想靠近美剧、TED、北美求学或职场表达风格的学习者。',
                isSelected: _selectedAccent == 'american',
                onTap: () => setState(() => _selectedAccent = 'american'),
              ),
              const SizedBox(height: 12),
              _AccentOptionCard(
                title: '英式 English',
                subtitle: '更适合想靠近 Cambridge、BBC 或英式课堂示例风格的学习者。',
                isSelected: _selectedAccent == 'british',
                onTap: () => setState(() => _selectedAccent = 'british'),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isLoggedIn
                      ? '你当前已登录，保存后会同时写入本地和云端资料。'
                      : '你当前未登录，保存后会先写入本地。登录后仍可继续同步到云端。',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.65),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePreference,
                child: const Text('保存偏好'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _savePreference() async {
    final storage = ref.read(storageServiceProvider);
    await storage.saveAccentPreference(_selectedAccent);
    await ref.read(authProvider.notifier).updateAccentPreference(_selectedAccent);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_selectedAccent == 'american' ? '已切换为美式偏好。' : '已切换为英式偏好。'),
      ),
    );
  }
}

class _AccentOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccentOptionCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : AppColors.textHint,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.65),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  final String title;
  final String body;

  const _IntroCard({
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.7),
          ),
        ],
      ),
    );
  }
}
