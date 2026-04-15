import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/community.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import '../../providers/service_providers.dart';

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
    final myRankAsync = ref.watch(myRankProvider);
    final auth = ref.watch(authProvider);
    final communityService = ref.watch(communityServiceProvider);
    final isConnected = communityService != null;
    final isLoggedIn = auth.status == AuthStatus.authenticated;
    final currentUserId = auth.user?.id;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: RefreshIndicator(
            onRefresh: _refreshCommunity,
            child: CustomScrollView(
              slivers: [
                const SliverAppBar(
                  floating: true,
                  centerTitle: true,
                  title: Text('社区', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _HeroCard(isConnected: isConnected),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _buildLeaderboard(leaderboardAsync),
                  ),
                ),
                if (isConnected && isLoggedIn)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: _buildMyRankCard(myRankAsync),
                    ),
                  ),
                if (!isConnected)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: _InfoBanner(
                        title: '社区能力当前未接入',
                        body: '当前环境没有连接到云端社区服务，所以排行榜、动态流和互动能力都会保持只读空态。等 Supabase 连上后，这里会自动恢复为真实内容。',
                      ),
                    ),
                  ),
                if (isConnected && !isLoggedIn)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: _LoginPrompt(onLogin: _goToAuth),
                    ),
                  ),
                if (isConnected && isLoggedIn)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: _buildPostInput(),
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Text('学习动态', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                postsAsync.when(
                  loading: () => const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (error, _) => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _InfoBanner(
                        title: '动态加载失败',
                        body: '$error',
                      ),
                    ),
                  ),
                  data: (posts) {
                    if (!isConnected) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: _EmptyState(
                            title: '社区暂不可用',
                            body: '等后端接入后，你可以在这里分享练习心得、给别人的动态点赞，并查看自己的练习反馈。',
                          ),
                        ),
                      );
                    }

                    if (posts.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _EmptyState(
                            title: isLoggedIn ? '还没有动态' : '先登录，再加入社区',
                            body: isLoggedIn ? '你可以发第一条学习心得，记录今天练了什么、卡在哪里、准备怎么改。' : '登录后就可以发布动态、点赞和参与排行榜。',
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = posts[index];
                          final isMine = currentUserId != null && currentUserId == post.userId;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                            child: _PostCard(
                              post: post,
                              isMine: isMine,
                              onLike: isLoggedIn ? () => ref.read(postsProvider.notifier).toggleLike(post.id) : _goToAuth,
                              onOpenComments: () => _openCommentsSheet(post, currentUserId),
                              onDelete: isMine ? () => _deletePost(post.id) : null,
                            ),
                          );
                        },
                        childCount: posts.length,
                      ),
                    );
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboard(AsyncValue<List<LeaderboardEntry>> leaderboardAsync) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('排行榜', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          leaderboardAsync.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
            error: (_, __) => const Text('排行榜暂时加载失败', style: TextStyle(color: AppColors.textSecondary)),
            data: (entries) {
              if (entries.isEmpty) {
                return const Text('当前还没有可显示的排行榜数据。', style: TextStyle(color: AppColors.textSecondary));
              }

              return Column(
                children: entries.take(5).map((entry) {
                  return _LeaderboardTile(rank: entry.rank, name: entry.displayName, xp: entry.totalXp);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMyRankCard(AsyncValue<LeaderboardEntry?> myRankAsync) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: myRankAsync.when(
        loading: () => const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('正在同步你的当前排名...'),
          ],
        ),
        error: (_, __) => const Text(
          '暂时还取不到你的个人排名。',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        data: (entry) {
          if (entry == null) {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('我的排名', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                  '当前排行榜里还没有你的数据。发一条动态或继续练习拿到新的 XP 后，再回来刷新看看。',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
                ),
              ],
            );
          }

          return Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '#${entry.rank}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('我的排名', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.displayName} · ${entry.totalXp} XP · Lv.${entry.level} · 连练 ${entry.streakDays} 天',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _refreshCommunity,
                child: const Text('刷新'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPostInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _postController,
              maxLength: 280,
              maxLines: 3,
              minLines: 1,
              decoration: const InputDecoration(
                hintText: '分享一下你今天练了什么、哪里卡住了、下一轮准备怎么改...',
                border: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
          IconButton(
            onPressed: _submitPost,
            icon: const Icon(Icons.send, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Future<void> _submitPost() async {
    final content = _postController.text.trim();
    if (content.isEmpty) {
      return;
    }

    final success = await ref.read(postsProvider.notifier).createPost(content);
    if (!mounted) {
      return;
    }

    if (success) {
      _postController.clear();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('动态已发布'), backgroundColor: AppColors.successGreen),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('发布失败，请稍后再试'), backgroundColor: AppColors.errorRed),
      );
    }
  }

  Future<void> _deletePost(String postId) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('删除这条动态？'),
            content: const Text('删除后将无法恢复，这里只允许你管理自己的内容。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('删除'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    final success = await ref.read(postsProvider.notifier).deletePost(postId);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? '动态已删除' : '删除失败，请稍后再试'),
        backgroundColor: success ? AppColors.successGreen : AppColors.errorRed,
      ),
    );
  }

  Future<void> _openCommentsSheet(Post post, String? currentUserId) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => _CommentsSheet(
        post: post,
        currentUserId: currentUserId,
        onRequireLogin: () {
          Navigator.of(sheetContext).pop();
          _goToAuth();
        },
      ),
    );
  }

  void _goToAuth() {
    context.push('/auth?from=%2Fcommunity');
  }

  Future<void> _refreshCommunity() async {
    await ref.read(postsProvider.notifier).loadPosts();
    ref.invalidate(leaderboardProvider);
    ref.invalidate(myRankProvider);
    await ref.read(leaderboardProvider.future);

    if (ref.read(authProvider).status == AuthStatus.authenticated) {
      await ref.read(myRankProvider.future);
    }
  }
}

class _HeroCard extends StatelessWidget {
  final bool isConnected;

  const _HeroCard({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '和别人一起把练习坚持下去',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            isConnected
                ? '社区页现在支持真实动态、评论、点赞和排行榜。如果你今天练到一个特别容易卡住的音，这里就是最适合记录和交流的地方。'
                : '社区页已经预留好了真实动态、评论、点赞和排行榜的结构；当前环境没连云端时，会明确告诉你哪些能力暂不可用。',
            style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.65),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String title;
  final String body;

  const _InfoBanner({
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  final VoidCallback onLogin;

  const _LoginPrompt({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '登录后可以发布学习动态、参与点赞评论互动，并在排行榜里看到自己的位置。',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onLogin,
            child: const Text('去登录'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String body;

  const _EmptyState({
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.forum_outlined, size: 32, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final String name;
  final int xp;

  const _LeaderboardTile({
    required this.rank,
    required this.name,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    final medalColor = switch (rank) {
      1 => AppColors.xpGold,
      2 => Colors.blueGrey,
      3 => AppColors.accentOrange,
      _ => AppColors.textSecondary,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: medalColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$rank',
              style: TextStyle(fontWeight: FontWeight.bold, color: medalColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600))),
          Text('$xp XP', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  final bool isMine;
  final VoidCallback onLike;
  final VoidCallback onOpenComments;
  final VoidCallback? onDelete;

  const _PostCard({
    required this.post,
    required this.isMine,
    required this.onLike,
    required this.onOpenComments,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final authorAvatarUrl = post.author?.avatarUrl ?? '';
    final hasAuthorAvatar = authorAvatarUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                foregroundImage: hasAuthorAvatar ? NetworkImage(authorAvatarUrl) : null,
                child: !hasAuthorAvatar
                    ? Text(
                        (post.author?.displayName ?? '发')[0],
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      )
                    : null,
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
              if (isMine && onDelete != null)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      onDelete!();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('删除我的动态'),
                    ),
                  ],
                  icon: const Icon(Icons.more_horiz, color: AppColors.textHint),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.content, style: const TextStyle(fontSize: 14, height: 1.6)),
          const SizedBox(height: 12),
          Row(
            children: [
              InkWell(
                onTap: onLike,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        post.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: post.isLikedByMe ? AppColors.accent : AppColors.textHint,
                      ),
                      const SizedBox(width: 4),
                      Text('${post.likesCount}', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: onOpenComments,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.comment_outlined, size: 16, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text('${post.commentsCount}', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays} 天前';
    if (diff.inHours > 0) return '${diff.inHours} 小时前';
    if (diff.inMinutes > 0) return '${diff.inMinutes} 分钟前';
    return '刚刚';
  }
}

class _CommentsSheet extends ConsumerStatefulWidget {
  final Post post;
  final String? currentUserId;
  final VoidCallback onRequireLogin;

  const _CommentsSheet({
    required this.post,
    required this.currentUserId,
    required this.onRequireLogin,
  });

  @override
  ConsumerState<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<_CommentsSheet> {
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  bool get _isLoggedIn => widget.currentUserId != null;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.post.id));
    final count = commentsAsync.valueOrNull?.length ?? widget.post.commentsCount;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.82,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('评论', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text('$count 条互动', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('关闭'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: commentsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          '评论加载失败：$error',
                          style: const TextStyle(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    data: (comments) {
                      if (comments.isEmpty) {
                        return ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          children: const [
                            _CommentEmptyState(),
                          ],
                        );
                      }

                      return ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final isMine = widget.currentUserId != null && comment.userId == widget.currentUserId;

                          return _CommentTile(
                            comment: comment,
                            isMine: isMine,
                            onDelete: isMine ? () => _deleteComment(comment.id) : null,
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemCount: comments.length,
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                if (!_isLoggedIn)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            '登录后就能评论并管理自己的留言。',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: widget.onRequireLogin,
                          child: const Text('去登录'),
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            maxLength: 180,
                            minLines: 1,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: '补充你的练习观察或给对方一点建议...',
                              counterText: '',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: _isSubmitting ? null : _submitComment,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('发送'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) {
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await ref.read(commentsProvider(widget.post.id).notifier).addComment(content);
    if (!mounted) {
      return;
    }

    setState(() => _isSubmitting = false);
    if (success) {
      _commentController.clear();
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('评论发送失败，请稍后再试'), backgroundColor: AppColors.errorRed),
      );
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final success = await ref.read(commentsProvider(widget.post.id).notifier).deleteComment(commentId);
    if (!mounted || success) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('评论删除失败，请稍后再试'), backgroundColor: AppColors.errorRed),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final Comment comment;
  final bool isMine;
  final VoidCallback? onDelete;

  const _CommentTile({
    required this.comment,
    required this.isMine,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final authorAvatarUrl = comment.author?.avatarUrl ?? '';
    final hasAuthorAvatar = authorAvatarUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            foregroundImage: hasAuthorAvatar ? NetworkImage(authorAvatarUrl) : null,
            child: !hasAuthorAvatar
                ? Text(
                    (comment.author?.displayName ?? '评')[0],
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.author?.displayName ?? '发音学习者',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      _timeAgo(comment.createdAt),
                      style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                    ),
                    if (isMine && onDelete != null) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: onDelete,
                        borderRadius: BorderRadius.circular(16),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.delete_outline, size: 18, color: AppColors.textHint),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.content,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.55),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays} 天前';
    if (diff.inHours > 0) return '${diff.inHours} 小时前';
    if (diff.inMinutes > 0) return '${diff.inMinutes} 分钟前';
    return '刚刚';
  }
}

class _CommentEmptyState extends StatelessWidget {
  const _CommentEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        '还没有评论。你可以补一句自己今天的练习观察，或者给对方一点具体建议。',
        style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
        textAlign: TextAlign.center,
      ),
    );
  }
}
