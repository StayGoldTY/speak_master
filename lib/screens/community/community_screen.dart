import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/community_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/community.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final _postController = TextEditingController();

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(postsProvider);
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final auth = ref.watch(authProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            title: Text('社区', style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          SliverToBoxAdapter(child: _buildLeaderboard(leaderboardAsync)),
          SliverToBoxAdapter(child: _buildChallenge()),
          if (auth.status == AuthStatus.authenticated)
            SliverToBoxAdapter(child: _buildPostInput()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: const Text('学习动态', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          postsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(child: Padding(padding: const EdgeInsets.all(32), child: Text('加载失败: $e'))),
            ),
            data: (posts) {
              if (posts.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(child: Padding(padding: EdgeInsets.all(40), child: Text('还没有动态，来发第一条吧！', style: TextStyle(color: AppColors.textHint)))),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: _PostCard(post: posts[index], onLike: () => ref.read(postsProvider.notifier).toggleLike(posts[index].id)),
                  ),
                  childCount: posts.length,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(AsyncValue<List<LeaderboardEntry>> leaderboardAsync) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('排行榜', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: leaderboardAsync.when(
              loading: () => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const Padding(padding: EdgeInsets.all(24), child: Text('加载排行榜失败')),
              data: (entries) {
                if (entries.isEmpty) {
                  return const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('暂无数据', style: TextStyle(color: AppColors.textHint))));
                }
                return Column(
                  children: entries.take(5).map((entry) {
                    final rankEmoji = entry.rank == 1 ? '🥇' : entry.rank == 2 ? '🥈' : entry.rank == 3 ? '🥉' : '  ';
                    return _LeaderboardTile(rank: entry.rank, name: entry.displayName, xp: entry.totalXp, emoji: rankEmoji);
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallenge() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: AppColors.gradientPrimary, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
              child: const Center(child: Text('🎯', style: TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TH 音大师赛', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('连续朗读 10 个含 /θ/ 的句子', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: 0.4, backgroundColor: Colors.white.withValues(alpha: 0.2), valueColor: const AlwaysStoppedAnimation(Colors.white), minHeight: 6),
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
    );
  }

  Widget _buildPostInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _postController,
                maxLength: 500,
                maxLines: 2,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: '分享你的学习心得...',
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                final content = _postController.text.trim();
                if (content.isEmpty) return;
                ref.read(postsProvider.notifier).createPost(content);
                _postController.clear();
                FocusScope.of(context).unfocus();
              },
              icon: const Icon(Icons.send, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final String name;
  final int xp;
  final String emoji;

  const _LeaderboardTile({required this.rank, required this.name, required this.xp, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(width: 28, child: Text('$rank', style: TextStyle(fontWeight: FontWeight.bold, color: rank <= 3 ? AppColors.primary : AppColors.textSecondary))),
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w500))),
          Text('$xp XP', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;

  const _PostCard({required this.post, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16, backgroundColor: AppColors.primary,
                child: Text(
                  (post.author?.displayName ?? '?')[0],
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.author?.displayName ?? '发音学习者', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(_timeAgo(post.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.content, style: const TextStyle(fontSize: 14, height: 1.5)),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: onLike,
                child: Row(
                  children: [
                    Icon(post.isLikedByMe ? Icons.favorite : Icons.favorite_border, size: 16, color: post.isLikedByMe ? AppColors.accent : AppColors.textHint),
                    const SizedBox(width: 4),
                    Text('${post.likesCount}', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.comment_outlined, size: 16, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text('${post.commentsCount}', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays} 天前';
    if (diff.inHours > 0) return '${diff.inHours} 小时前';
    if (diff.inMinutes > 0) return '${diff.inMinutes} 分钟前';
    return '刚刚';
  }
}
