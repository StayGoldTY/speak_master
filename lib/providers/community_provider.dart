import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/community.dart';
import 'service_providers.dart';

class PostsNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  final Ref _ref;

  PostsNotifier(this._ref) : super(const AsyncValue.data([])) {
    loadPosts();
  }

  Future<void> loadPosts({int page = 0}) async {
    final service = _ref.read(communityServiceProvider);
    if (service == null) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      if (page == 0) state = const AsyncValue.loading();
      final posts = await service.getPosts(page: page);
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> createPost(String content, {String postType = 'share'}) async {
    final service = _ref.read(communityServiceProvider);
    if (service == null) return false;

    try {
      final post = await service.createPost(content: content, postType: postType);
      if (post != null && state.hasValue) {
        state = AsyncValue.data([post, ...state.value!]);
        return true;
      }
      return post != null;
    } catch (e) {
      debugPrint('Failed to create post: $e');
      return false;
    }
  }

  Future<void> toggleLike(String postId) async {
    final service = _ref.read(communityServiceProvider);
    if (service == null || !state.hasValue) return;

    final posts = state.value!;
    final index = posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = posts[index];
    final nowLiked = !post.isLikedByMe;
    final updatedPost = post.copyWith(
      isLikedByMe: nowLiked,
      likesCount: nowLiked ? post.likesCount + 1 : post.likesCount - 1,
    );

    final updatedPosts = [...posts];
    updatedPosts[index] = updatedPost;
    state = AsyncValue.data(updatedPosts);

    await service.toggleLike(postId);
  }

  Future<bool> deletePost(String postId) async {
    final service = _ref.read(communityServiceProvider);
    if (service == null) return false;

    try {
      final deleted = await service.deletePost(postId);
      if (!deleted) {
        return false;
      }
      if (state.hasValue) {
        state = AsyncValue.data(state.value!.where((p) => p.id != postId).toList());
      }
      return true;
    } catch (e) {
      debugPrint('Failed to delete post: $e');
      return false;
    }
  }

  void applyCommentDelta(String postId, int delta) {
    if (!state.hasValue) return;

    final posts = state.value!;
    final index = posts.indexWhere((post) => post.id == postId);
    if (index == -1) return;

    final updatedPosts = [...posts];
    final post = updatedPosts[index];
    final nextCount = post.commentsCount + delta;
    updatedPosts[index] = post.copyWith(commentsCount: nextCount < 0 ? 0 : nextCount);
    state = AsyncValue.data(updatedPosts);
  }
}

final postsProvider = StateNotifierProvider<PostsNotifier, AsyncValue<List<Post>>>((ref) {
  return PostsNotifier(ref);
});

final leaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final service = ref.read(communityServiceProvider);
  if (service == null) return [];
  return service.getLeaderboard();
});

final myRankProvider = FutureProvider<LeaderboardEntry?>((ref) async {
  final service = ref.read(communityServiceProvider);
  if (service == null) return null;
  return service.getMyRank();
});

class CommentsNotifier extends StateNotifier<AsyncValue<List<Comment>>> {
  final Ref _ref;
  final String _postId;

  CommentsNotifier(this._ref, this._postId) : super(const AsyncValue.loading()) {
    loadComments();
  }

  Future<void> loadComments() async {
    final service = _ref.read(communityServiceProvider);
    if (service == null) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      final comments = await service.getComments(_postId);
      state = AsyncValue.data(comments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> addComment(String content) async {
    final service = _ref.read(communityServiceProvider);
    if (service == null) return false;

    try {
      final comment = await service.addComment(postId: _postId, content: content);
      if (comment == null) {
        return false;
      }

      if (state.hasValue) {
        state = AsyncValue.data([...state.value!, comment]);
      } else {
        state = AsyncValue.data([comment]);
      }

      _ref.read(postsProvider.notifier).applyCommentDelta(_postId, 1);
      return true;
    } catch (e) {
      debugPrint('Failed to add comment: $e');
      return false;
    }
  }

  Future<bool> deleteComment(String commentId) async {
    final service = _ref.read(communityServiceProvider);
    if (service == null) return false;

    try {
      final deleted = await service.deleteComment(commentId);
      if (!deleted) {
        return false;
      }
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.where((comment) => comment.id != commentId).toList(),
        );
      }
      _ref.read(postsProvider.notifier).applyCommentDelta(_postId, -1);
      return true;
    } catch (e) {
      debugPrint('Failed to delete comment: $e');
      return false;
    }
  }
}

final commentsProvider = StateNotifierProvider.family<CommentsNotifier, AsyncValue<List<Comment>>, String>((ref, postId) {
  return CommentsNotifier(ref, postId);
});
