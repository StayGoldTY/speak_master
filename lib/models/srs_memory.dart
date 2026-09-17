enum RecallGrade { again, hard, good, easy }

extension RecallGradeX on RecallGrade {
  String get key => name;

  String get label => switch (this) {
    RecallGrade.again => '没提取出来',
    RecallGrade.hard => '有点费力',
    RecallGrade.good => '提取成功',
    RecallGrade.easy => '很轻松',
  };

  static RecallGrade fromKey(String? value) {
    return RecallGrade.values.firstWhere(
      (item) => item.key == value,
      orElse: () => RecallGrade.good,
    );
  }
}

class SrsMemory {
  final String itemId;
  final int repetitions;
  final double ease;
  final int intervalDays;
  final DateTime dueAt;
  final DateTime? lastReviewedAt;
  final int lapses;
  final String? lastGradeKey;

  const SrsMemory({
    required this.itemId,
    this.repetitions = 0,
    this.ease = 2.5,
    this.intervalDays = 0,
    required this.dueAt,
    this.lastReviewedAt,
    this.lapses = 0,
    this.lastGradeKey,
  });

  bool isDueAt(DateTime now) => !dueAt.isAfter(now);

  SrsMemory copyWith({
    String? itemId,
    int? repetitions,
    double? ease,
    int? intervalDays,
    DateTime? dueAt,
    DateTime? lastReviewedAt,
    int? lapses,
    String? lastGradeKey,
  }) {
    return SrsMemory(
      itemId: itemId ?? this.itemId,
      repetitions: repetitions ?? this.repetitions,
      ease: ease ?? this.ease,
      intervalDays: intervalDays ?? this.intervalDays,
      dueAt: dueAt ?? this.dueAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      lapses: lapses ?? this.lapses,
      lastGradeKey: lastGradeKey ?? this.lastGradeKey,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'repetitions': repetitions,
      'ease': ease,
      'interval_days': intervalDays,
      'due_at': dueAt.toIso8601String(),
      'last_reviewed_at': lastReviewedAt?.toIso8601String(),
      'lapses': lapses,
      'last_grade_key': lastGradeKey,
    };
  }

  factory SrsMemory.fromJson(Map<String, dynamic> json) {
    return SrsMemory(
      itemId: json['item_id']?.toString() ?? json['itemId']?.toString() ?? '',
      repetitions: (json['repetitions'] as num?)?.toInt() ?? 0,
      ease: (json['ease'] as num?)?.toDouble() ?? 2.5,
      intervalDays: (json['interval_days'] as num?)?.toInt() ?? 0,
      dueAt:
          DateTime.tryParse(json['due_at']?.toString() ?? '') ?? DateTime.now(),
      lastReviewedAt: DateTime.tryParse(
        json['last_reviewed_at']?.toString() ?? '',
      ),
      lapses: (json['lapses'] as num?)?.toInt() ?? 0,
      lastGradeKey: json['last_grade_key']?.toString(),
    );
  }
}
