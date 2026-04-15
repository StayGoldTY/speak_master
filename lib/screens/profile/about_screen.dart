import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关于 Speak Master')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              _AboutHero(),
              SizedBox(height: 16),
              _InfoCard(
                title: '产品定位',
                body: 'Speak Master 想做的不是一堆孤立的音标卡片，而是一条从教程学习、到开口练习、再到反馈回路的发音学习链路。',
              ),
              SizedBox(height: 12),
              _InfoCard(
                title: '当前完成度',
                body: '目前最扎实的是教程主线第一阶段，也就是 u1-u10。练习中心和朗读自评页已经改成更诚实的自练体验，但真正的自动评分、标准音频和通知能力还在后续阶段。',
              ),
              SizedBox(height: 12),
              _InfoCard(
                title: '运行形态',
                body: '这个项目基于 Flutter 构建，可以作为 Web 学习站点运行，也保留移动端能力。当前体验重点偏桌面网页，同时兼顾手机可用。',
              ),
              SizedBox(height: 12),
              _InfoCard(
                title: '接下来会继续补什么',
                body: '- 后续单元逐步开放\n- 真实音频与可回放练习\n- 更可信的测评闭环\n- 更细的学习偏好和账号能力',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutHero extends StatelessWidget {
  const _AboutHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Speak Master',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          SizedBox(height: 10),
          Text(
            '一个以英语发音、朗读和持续练习为核心的学习应用。当前版本重点在“先把核心学习链路做扎实”，而不是堆很多看起来很满、其实不能用的功能。',
            style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.75),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String body;

  const _InfoCard({
    required this.title,
    required this.body,
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
        ],
      ),
    );
  }
}
