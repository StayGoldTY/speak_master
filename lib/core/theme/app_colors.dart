import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF5B4DFF);
  static const primaryDark = Color(0xFF3B2FD4);
  static const primaryLight = Color(0xFF8B80FF);

  static const secondary = Color(0xFF0F8F7A);
  static const secondaryDark = Color(0xFF0B6B5C);
  static const secondaryLight = Color(0xFF5ED0BE);

  static const accent = Color(0xFFFF6B4A);
  static const accentOrange = Color(0xFFF5A524);

  static const streakFlame = Color(0xFFFF6B2C);
  static const xpGold = Color(0xFFF5B544);
  static const successGreen = Color(0xFF12B76A);
  static const errorRed = Color(0xFFF04438);
  static const warningYellow = Color(0xFFF79009);

  static const hit = Color(0xFF12B76A);
  static const partial = Color(0xFFF79009);
  static const miss = Color(0xFFF04438);

  static const ink = Color(0xFF161326);
  static const bgLight = Color(0xFFF4F2FB);
  static const bgDark = Color(0xFF120F1C);
  static const cardLight = Color(0xFFFFFFFF);
  static const cardDark = Color(0xFF1C1730);
  static const surfaceMuted = Color(0xFFF7F5FF);
  static const surfaceAccent = Color(0xFFEEE9FF);
  static const glassBorder = Color(0xFFE4DFF5);

  static const textPrimary = Color(0xFF161326);
  static const textSecondary = Color(0xFF5E5873);
  static const textHint = Color(0xFF9A94B0);
  static const textOnPrimary = Color(0xFFFFFFFF);

  static const vowelColor = Color(0xFFE86F6B);
  static const consonantColor = primary;
  static const suprasegmentalColor = secondary;
  static const phonicsColor = Color(0xFFEE9C43);
  static const grammarColor = Color(0xFF6C86DA);

  static const gradientPrimary = LinearGradient(
    colors: [Color(0xFF3B2FD4), Color(0xFF5B4DFF), Color(0xFF8B80FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientSuccess = LinearGradient(
    colors: [Color(0xFF0F8F7A), Color(0xFF5ED0BE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientStreak = LinearGradient(
    colors: [Color(0xFFFF6B2C), Color(0xFFF5B544)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientCanvas = LinearGradient(
    colors: [Color(0xFFF7F5FF), Color(0xFFF4F2FB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const gradientSunrise = LinearGradient(
    colors: [Color(0xFFFFE4D6), Color(0xFFF7F5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
