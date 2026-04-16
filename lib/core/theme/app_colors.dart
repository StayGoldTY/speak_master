import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF114B6B);
  static const primaryDark = Color(0xFF0C334C);
  static const primaryLight = Color(0xFF4F7FA3);

  static const secondary = Color(0xFF1D9A87);
  static const secondaryDark = Color(0xFF166F63);
  static const secondaryLight = Color(0xFF7BD5C4);

  static const accent = Color(0xFFFF7A59);
  static const accentOrange = Color(0xFFF1B24A);

  static const streakFlame = Color(0xFFFF8A4C);
  static const xpGold = Color(0xFFE9BD56);
  static const successGreen = Color(0xFF2FA67A);
  static const errorRed = Color(0xFFD85A63);
  static const warningYellow = Color(0xFFFFC857);

  static const bgLight = Color(0xFFF8F4EE);
  static const bgDark = Color(0xFF0F1C28);
  static const cardLight = Color(0xFFFFFFFF);
  static const cardDark = Color(0xFF172635);
  static const surfaceMuted = Color(0xFFFFFBF6);
  static const surfaceAccent = Color(0xFFF7EFE3);
  static const glassBorder = Color(0xFFE7DED1);

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
    colors: [Color(0xFF0D3B59), Color(0xFF1A6F7C), Color(0xFF46A792)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientSuccess = LinearGradient(
    colors: [Color(0xFF1D9A87), Color(0xFF6FD0BB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientStreak = LinearGradient(
    colors: [Color(0xFFFF8A4C), Color(0xFFFFC857)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientCanvas = LinearGradient(
    colors: [Color(0xFFFFF9F3), Color(0xFFF5F7FB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const gradientSunrise = LinearGradient(
    colors: [Color(0xFFFFE6D4), Color(0xFFFFF3E7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
