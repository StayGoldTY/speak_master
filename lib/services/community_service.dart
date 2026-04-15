import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/community.dart';

class CommunityService {
  final SupabaseClient _client;

  CommunityService(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  // ── Posts ──

  Future<List<Post>> getPosts({int page = 0, int pageSize = 20}) async {
    try {
      final data = await _client
          .from('posts')
          .select('*, profiles(*)')
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      final likedPostIds = await _getMyLikedPostIds();

      return (data as List).map((e) {
        return Post.fromJson(e, isLikedByMe: likedPostIds.contains(e['id']));
      }).toList();
    } catch (e) {
      debugPrint('Failed to load posts: $e');
      return [];
    }
  }

  Future<Post?> createPost({required String content, String postType = 'share'}) async {
    if (_userId == null) return null;

    try {
      final data = await _client.from('posts').insert({
        'user_id': _userId!,
        'content': content,
        'post_type': postType,
      }).select('*, profiles(*)').single();

      return Post.fromJson(data);
    } catch (e) {
      debugPrint('Failed to create post: $e');
      return null;
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      await _client.from('posts').delete().eq('id', postId);
      return true;
    } catch (e) {
      debugPrint('Failed to delete post: $e');
      return false;
    }
  }

  // ── Likes ──

  Future<bool> toggleLike(String postId) async {
    if (_userId == null) return false;

    try {
      final existing = await _client
          .from('likes')
          .select()
          .eq('user_id', _userId!)
          .eq('post_id', postId)
          .maybeSingle();

      if (existing != null) {
        await _client.from('likes')
            .delete()
            .eq('user_id', _userId!)
            .eq('post_id', postId);
        return false;
      } else {
        await _client.from('likes').insert({
          'user_id': _userId!,
          'post_id': postId,
        });
        return true;
      }
    } catch (e) {
      debugPrint('Failed to toggle like: $e');
      return false;
    }
  }

  Future<Set<String>> _getMyLikedPostIds() async {
    if (_userId == null) return {};

    try {
      final data = await _client
          .from('likes')
          .select('post_id')
          .eq('user_id', _userId!);

      return (data as List).map((e) => e['post_id'] as String).toSet();
    } catch (e) {
      return {};
    }
  }

  // ── Comments ──

  Future<List<Comment>> getComments(String postId) async {
    try {
      final data = await _client
          .from('comments')
          .select('*, profiles(*)')
          .eq('post_id', postId)
          .order('created_at', ascending: true);

      return (data as List).map((e) => Comment.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Failed to load comments: $e');
      return [];
    }
  }

  Future<Comment?> addComment({required String postId, required String content}) async {
    if (_userId == null) return null;

    try {
      final data = await _client.from('comments').insert({
        'post_id': postId,
        'user_id': _userId!,
        'content': content,
      }).select('*, profiles(*)').single();

      return Comment.fromJson(data);
    } catch (e) {
      debugPrint('Failed to add comment: $e');
      return null;
    }
  }

  Future<bool> deleteComment(String commentId) async {
    try {
      await _client.from('comments').delete().eq('id', commentId);
      return true;
    } catch (e) {
      debugPrint('Failed to delete comment: $e');
      return false;
    }
  }

  // ── Leaderboard ──

  Future<List<LeaderboardEntry>> getLeaderboard() async {
    try {
      final data = await _client.from('leaderboard').select().limit(50);
      return (data as List).map((e) => LeaderboardEntry.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Failed to load leaderboard: $e');
      return [];
    }
  }

  Future<LeaderboardEntry?> getMyRank() async {
    if (_userId == null) return null;

    try {
      final data = await _client
          .from('leaderboard')
          .select()
          .eq('id', _userId!)
          .maybeSingle();

      return data != null ? LeaderboardEntry.fromJson(data) : null;
    } catch (e) {
      debugPrint('Failed to get my rank: $e');
      return null;
    }
  }

  // ── Realtime ──

  RealtimeChannel subscribeToPosts(void Function(List<Post>) onData) {
    return _client.channel('public:posts').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'posts',
      callback: (payload) async {
        final posts = await getPosts();
        onData(posts);
      },
    ).subscribe();
  }
}
