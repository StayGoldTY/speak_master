import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF6C63FF);
  static const primaryDark = Color(0xFF4A42D4);
  static const primaryLight = Color(0xFF9D97FF);

  static const secondary = Color(0xFF00C9A7);
  static const secondaryDark = Color(0xFF00A389);
  static const secondaryLight = Color(0xFF5DFFDA);

  static const accent = Color(0xFFFF6B6B);
  static const accentOrange = Color(0xFFFF9F43);

  static const streakFlame = Color(0xFFFF6B35);
  static const xpGold = Color(0xFFFFD700);
  static const successGreen = Color(0xFF2ED573);
  static const errorRed = Color(0xFFFF4757);
  static const warningYellow = Color(0xFFFFC312);

  static const bgLight = Color(0xFFF8F9FE);
  static const bgDark = Color(0xFF1A1A2E);
  static const cardLight = Color(0xFFFFFFFF);
  static const cardDark = Color(0xFF16213E);

  static const textPrimary = Color(0xFF2D3436);
  static const textSecondary = Color(0xFF636E72);
  static const textHint = Color(0xFFB2BEC3);
  static const textOnPrimary = Color(0xFFFFFFFF);

  static const vowelColor = Color(0xFFFF6B6B);
  static const consonantColor = Color(0xFF6C63FF);
  static const suprasegmentalColor = Color(0xFF00C9A7);
  static const phonicsColor = Color(0xFFFF9F43);
  static const grammarColor = Color(0xFFA29BFE);

  static const gradientPrimary = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9D97FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientSuccess = LinearGradient(
    colors: [Color(0xFF2ED573), Color(0xFF7BED9F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientStreak = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFFD700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
