import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF143A5A);
  static const primaryDark = Color(0xFF0D273D);
  static const primaryLight = Color(0xFF2E6B8F);

  static const secondary = Color(0xFF1D9A87);
  static const secondaryDark = Color(0xFF157667);
  static const secondaryLight = Color(0xFF73D3C0);

  static const accent = Color(0xFFFF7A59);
  static const accentOrange = Color(0xFFF4B15C);

  static const streakFlame = Color(0xFFFF8A4C);
  static const xpGold = Color(0xFFE9BD56);
  static const successGreen = Color(0xFF2FA67A);
  static const errorRed = Color(0xFFD85A63);
  static const warningYellow = Color(0xFFFFC857);

  static const bgLight = Color(0xFFF3F6F8);
  static const bgDark = Color(0xFF0F1C28);
  static const cardLight = Color(0xFFFFFFFF);
  static const cardDark = Color(0xFF172635);

  static const textPrimary = Color(0xFF13212F);
  static const textSecondary = Color(0xFF5C6C7A);
  static const textHint = Color(0xFFA3AFB8);
  static const textOnPrimary = Color(0xFFFFFFFF);

  static const vowelColor = Color(0xFFE86F6B);
  static const consonantColor = primary;
  static const suprasegmentalColor = secondary;
  static const phonicsColor = Color(0xFFEE9C43);
  static const grammarColor = Color(0xFF6C86DA);

  static const gradientPrimary = LinearGradient(
    colors: [Color(0xFF143A5A), Color(0xFF2E6B8F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientSuccess = LinearGradient(
    colors: [Color(0xFF1D9A87), Color(0xFF73D3C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientStreak = LinearGradient(
    colors: [Color(0xFFFF8A4C), Color(0xFFFFC857)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
