import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';

class HelpFeedbackScreen extends StatelessWidget {
  const HelpFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('帮助与反馈')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const _HeroPanel(),
              const SizedBox(height: 16),
              const _SectionCard(
                title: '怎么用这个应用更有效',
                body:
                    '1. 先走教程主线，建立正确的发音边界。\n'
                    '2. 再去练习中心做自由朗读和跟读参考，保持开口频率。\n'
                    '3. 最后做一次朗读自评，用结果反推下一轮复习重点。',
              ),
              const SizedBox(height: 12),
              const _SectionCard(
                title: '当前最完整的内容在哪里',
                body: '当前优先完善的是教程主线第一阶段，也就是 u1-u10。你会在教程地图里看到已开放与即将开放的清晰边界，避免误点进占位课。',
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: '怎样反馈会更有帮助',
                body:
                    '如果你要反馈问题，最好附上这三类信息：\n'
                    '- 你当时在什么页面\n'
                    '- 你原本期待发生什么\n'
                    '- 实际发生了什么',
                actionLabel: '复制反馈模板',
                onAction: () async {
                  await Clipboard.setData(
                    const ClipboardData(
                      text: '页面：\n预期：\n实际：\n复现步骤：\n设备 / 浏览器：',
                    ),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('反馈模板已复制。')),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              const _SectionCard(
                title: '哪些地方仍然是原型能力',
                body: '目前练习录音、课程音频和测评结果都已经改成了更诚实的表达：会明确告诉你哪些是自练入口，哪些还没有接入真正的自动评分、回放或标准音频。',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '遇到问题时，先帮你定位，再帮你反馈',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          SizedBox(height: 10),
          Text(
            '这页不是一堆空链接，而是把“怎么继续学、怎么判断是不是 bug、怎么提交有效反馈”整理在一起，帮你少走弯路。',
            style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.7),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionCard({
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.75),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
