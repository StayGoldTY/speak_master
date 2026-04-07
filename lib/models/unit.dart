import 'package:flutter/material.dart';

enum BlockType {
  foundation,
  vowels,
  consonants,
  suprasegmental,
  grammarPronunciation,
  phonics,
}

class LearningBlock {
  final String id;
  final BlockType type;
  final String titleCn;
  final String titleEn;
  final String subtitle;
  final int unitCount;
  final Color color;
  final IconData icon;

  const LearningBlock({
    required this.id,
    required this.type,
    required this.titleCn,
    required this.titleEn,
    required this.subtitle,
    required this.unitCount,
    required this.color,
    required this.icon,
  });
}

class LearningUnit {
  final String id;
  final String blockId;
  final int order;
  final String titleCn;
  final String titleEn;
  final String description;
  final int lessonCount;
  final List<String> targetPhonemes;
  final String? badgeId;

  const LearningUnit({
    required this.id,
    required this.blockId,
    required this.order,
    required this.titleCn,
    required this.titleEn,
    required this.description,
    required this.lessonCount,
    required this.targetPhonemes,
    this.badgeId,
  });
}
