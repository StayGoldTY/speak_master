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

  Future<void> createPost(String content, {String postType = 'share'}) async {
    final service = _ref.read(communityServiceProvider);
    if (service == null) return;

    try {
      final post = await service.createPost(content: content, postType: postType);
      if (post != null && state.hasValue) {
        state = AsyncValue.data([post, ...state.value!]);
      }
    } catch (e) {
      debugPrint('Failed to create post: $e');
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

  Future<void> deletePost(String postId) async {
    final service = _ref.read(communityServiceProvider);
    if (service == null) return;

    await service.deletePost(postId);
    if (state.hasValue) {
      state = AsyncValue.data(state.value!.where((p) => p.id != postId).toList());
    }
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

final commentsProvider = FutureProvider.family<List<Comment>, String>((ref, postId) async {
  final service = ref.read(communityServiceProvider);
  if (service == null) return [];
  return service.getComments(postId);
});
