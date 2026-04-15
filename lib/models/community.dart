class UserProfile {
  final String id;
  final String? username;
  final String displayName;
  final String? avatarUrl;
  final bool isPro;
  final String accentPreference;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    this.username,
    required this.displayName,
    this.avatarUrl,
    this.isPro = false,
    this.accentPreference = 'american',
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String?,
      displayName: json['display_name'] as String? ?? '发音学习者',
      avatarUrl: json['avatar_url'] as String?,
      isPro: json['is_pro'] as bool? ?? false,
      accentPreference: json['accent_preference'] as String? ?? 'american',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'is_pro': isPro,
        'accent_preference': accentPreference,
      };

  UserProfile copyWith({
    String? username,
    String? displayName,
    String? avatarUrl,
    bool? isPro,
    String? accentPreference,
  }) {
    return UserProfile(
      id: id,
      username: username == null ? this.username : (username.isEmpty ? null : username),
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl == null ? this.avatarUrl : (avatarUrl.isEmpty ? null : avatarUrl),
      isPro: isPro ?? this.isPro,
      accentPreference: accentPreference ?? this.accentPreference,
      createdAt: createdAt,
    );
  }
}

class Post {
  final String id;
  final String userId;
  final String content;
  final String postType;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final UserProfile? author;
  final bool isLikedByMe;

  const Post({
    required this.id,
    required this.userId,
    required this.content,
    this.postType = 'share',
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    this.author,
    this.isLikedByMe = false,
  });

  factory Post.fromJson(Map<String, dynamic> json, {bool isLikedByMe = false}) {
    return Post(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      postType: json['post_type'] as String? ?? 'share',
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      author: json['profiles'] != null
          ? UserProfile.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
      isLikedByMe: isLikedByMe,
    );
  }

  Post copyWith({
    int? likesCount,
    int? commentsCount,
    bool? isLikedByMe,
  }) {
    return Post(
      id: id,
      userId: userId,
      content: content,
      postType: postType,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt,
      author: author,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }
}

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final UserProfile? author;

  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.author,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      author: json['profiles'] != null
          ? UserProfile.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LeaderboardEntry {
  final String id;
  final String? username;
  final String displayName;
  final String? avatarUrl;
  final int totalXp;
  final int streakDays;
  final int level;
  final int rank;

  const LeaderboardEntry({
    required this.id,
    this.username,
    required this.displayName,
    this.avatarUrl,
    required this.totalXp,
    required this.streakDays,
    required this.level,
    required this.rank,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'] as String,
      username: json['username'] as String?,
      displayName: json['display_name'] as String? ?? '发音学习者',
      avatarUrl: json['avatar_url'] as String?,
      totalXp: json['total_xp'] as int? ?? 0,
      streakDays: json['streak_days'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      rank: json['rank'] as int? ?? 0,
    );
  }
}

class AssessmentRecord {
  final String? id;
  final String userId;
  final String sentence;
  final double accuracyScore;
  final double fluencyScore;
  final double intonationScore;
  final double stressScore;
  final double overallScore;
  final List<String> weakPhonemes;
  final DateTime createdAt;

  const AssessmentRecord({
    this.id,
    required this.userId,
    required this.sentence,
    this.accuracyScore = 0,
    this.fluencyScore = 0,
    this.intonationScore = 0,
    this.stressScore = 0,
    this.overallScore = 0,
    this.weakPhonemes = const [],
    required this.createdAt,
  });

  factory AssessmentRecord.fromJson(Map<String, dynamic> json) {
    return AssessmentRecord(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      sentence: json['sentence'] as String,
      accuracyScore: (json['accuracy_score'] as num?)?.toDouble() ?? 0,
      fluencyScore: (json['fluency_score'] as num?)?.toDouble() ?? 0,
      intonationScore: (json['intonation_score'] as num?)?.toDouble() ?? 0,
      stressScore: (json['stress_score'] as num?)?.toDouble() ?? 0,
      overallScore: (json['overall_score'] as num?)?.toDouble() ?? 0,
      weakPhonemes: (json['weak_phonemes'] as List?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'sentence': sentence,
        'accuracy_score': accuracyScore,
        'fluency_score': fluencyScore,
        'intonation_score': intonationScore,
        'stress_score': stressScore,
        'overall_score': overallScore,
        'weak_phonemes': weakPhonemes,
      };
}
