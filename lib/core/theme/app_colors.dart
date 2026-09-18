import 'package:flutter/material.dart';

/// Visual tokens for Speak Master.
///
/// The learner UI follows apple.com / HIG: graphite type on a cool gray
/// canvas, one interactive blue, black fills for primary actions, and
/// semantic color used sparingly for status — not a rainbow dashboard.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF0071E3);
  static const primaryDark = Color(0xFF0058B0);
  static const primaryLight = Color(0xFF2997FF);

  static const secondary = Color(0xFF424245);
  static const secondaryDark = Color(0xFF1D1D1F);
  static const secondaryLight = Color(0xFFD2D2D7);

  static const accent = Color(0xFF0071E3);
  static const accentOrange = Color(0xFFE68600);

  static const streakFlame = Color(0xFFE68600);
  static const xpGold = Color(0xFF6E6E73);
  static const successGreen = Color(0xFF248A3D);
  static const errorRed = Color(0xFFD70015);
  static const warningYellow = Color(0xFFE68600);

  static const bgLight = Color(0xFFF5F5F7);
  static const bgDark = Color(0xFF000000);
  static const cardLight = Color(0xFFFFFFFF);
  static const cardDark = Color(0xFF1D1D1F);
  static const surfaceMuted = Color(0xFFFBFBFD);
  static const surfaceAccent = Color(0xFFF2F2F7);
  static const glassBorder = Color(0xFFD2D2D7);

  static const ink = Color(0xFF1D1D1F);
  static const fillTertiary = Color(0xFFE8E8ED);
  static const hairline = Color(0x1F000000);

  static const textPrimary = Color(0xFF1D1D1F);
  static const textSecondary = Color(0xFF6E6E73);
  static const textHint = Color(0xFF86868B);
  static const textOnPrimary = Color(0xFFFFFFFF);

  static const vowelColor = Color(0xFFD70015);
  static const consonantColor = primary;
  static const suprasegmentalColor = secondary;
  static const phonicsColor = Color(0xFFE68600);
  static const grammarColor = Color(0xFF0071E3);

  static const gradientPrimary = LinearGradient(
    colors: [Color(0xFF1D1D1F), Color(0xFF3A3A3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientSuccess = LinearGradient(
    colors: [Color(0xFF1D1D1F), Color(0xFF424245)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientStreak = LinearGradient(
    colors: [Color(0xFF1D1D1F), Color(0xFF3A3A3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientCanvas = LinearGradient(
    colors: [Color(0xFFF5F5F7), Color(0xFFF5F5F7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const gradientSunrise = LinearGradient(
    colors: [Color(0xFFE8EEF4), Color(0xFFF5F5F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientCinematic = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF1D1D1F), Color(0xFF2C2C2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: const Color(0x14000000),
      blurRadius: 28,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get faintShadow => [
    BoxShadow(
      color: const Color(0x0A000000),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];
}
