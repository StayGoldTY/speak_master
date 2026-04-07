import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            title: Text('社区', style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          SliverToBoxAdapter(child: _buildLeaderboard(context)),
          SliverToBoxAdapter(child: _buildChallenges(context)),
          SliverToBoxAdapter(child: _buildRecentPosts(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('本周排行榜', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _LeaderboardItem(rank: 1, name: '语音达人', xp: 2850, avatar: '🥇'),
                const Divider(height: 1),
                _LeaderboardItem(rank: 2, name: '朗读小王子', xp: 2340, avatar: '🥈'),
                const Divider(height: 1),
                _LeaderboardItem(rank: 3, name: '发音猎手', xp: 2100, avatar: '🥉'),
                const Divider(height: 1),
                _LeaderboardItem(rank: 12, name: '我', xp: 350, avatar: '😊', isMe: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallenges(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('每周挑战', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(child: Text('🎯', style: TextStyle(fontSize: 28))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TH 音大师赛',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '连续朗读 10 个含 /θ/ 的句子',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.4,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    const Text('+50', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('XP', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPosts(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('学习动态', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _PostCard(
            username: '语音达人',
            time: '2 小时前',
            content: '终于掌握 /θ/ 和 /ð/ 的区别了！秘诀是对着镜子确认舌头伸出齿间。',
            likes: 24,
            comments: 8,
          ),
          const SizedBox(height: 12),
          _PostCard(
            username: '朗读小王子',
            time: '5 小时前',
            content: '连续打卡 30 天！发音评分从 60 提升到 85，大声朗读真的有用！',
            likes: 42,
            comments: 15,
          ),
        ],
      ),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  final int rank;
  final String name;
  final int xp;
  final String avatar;
  final bool isMe;

  const _LeaderboardItem({
    required this.rank,
    required this.name,
    required this.xp,
    required this.avatar,
    this.isMe = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isMe ? AppColors.primary.withValues(alpha: 0.05) : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: rank <= 3 ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
          Text(avatar, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: isMe ? FontWeight.bold : FontWeight.w500,
                color: isMe ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '$xp XP',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isMe ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final String username;
  final String time;
  final String content;
  final int likes;
  final int comments;

  const _PostCard({
    required this.username,
    required this.time,
    required this.content,
    required this.likes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(username, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.favorite_border, size: 16, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text('$likes', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
              const SizedBox(width: 16),
              const Icon(Icons.comment_outlined, size: 16, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text('$comments', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
            ],
          ),
        ],
      ),
    );
  }
}
