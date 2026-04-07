import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/community.dart';
import 'service_providers.dart';

class PostsNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  final Ref _ref;

  PostsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadPosts();
  }

  Future<void> loadPosts({int page = 0}) async {
    try {
      if (page == 0) state = const AsyncValue.loading();
      final posts = await _ref.read(communityServiceProvider).getPosts(page: page);
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createPost(String content, {String postType = 'share'}) async {
    try {
      final post = await _ref.read(communityServiceProvider).createPost(
        content: content,
        postType: postType,
      );
      if (post != null && state.hasValue) {
        state = AsyncValue.data([post, ...state.value!]);
      }
    } catch (e) {
      debugPrint('Failed to create post: $e');
    }
  }

  Future<void> toggleLike(String postId) async {
    if (!state.hasValue) return;

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

    await _ref.read(communityServiceProvider).toggleLike(postId);
  }

  Future<void> deletePost(String postId) async {
    if (!state.hasValue) return;

    await _ref.read(communityServiceProvider).deletePost(postId);
    final updatedPosts = state.value!.where((p) => p.id != postId).toList();
    state = AsyncValue.data(updatedPosts);
  }
}

final postsProvider = StateNotifierProvider<PostsNotifier, AsyncValue<List<Post>>>((ref) {
  return PostsNotifier(ref);
});

final leaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  return ref.read(communityServiceProvider).getLeaderboard();
});

final myRankProvider = FutureProvider<LeaderboardEntry?>((ref) async {
  return ref.read(communityServiceProvider).getMyRank();
});

final commentsProvider = FutureProvider.family<List<Comment>, String>((ref, postId) async {
  return ref.read(communityServiceProvider).getComments(postId);
});
