import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/phoneme.dart';

class PhonemeCard extends StatelessWidget {
  final Phoneme phoneme;

  const PhonemeCard({
    super.key,
    required this.phoneme,
  });

  @override
  Widget build(BuildContext context) {
    final isVowel = phoneme.type == PhonemeType.vowel;
    final color = isVowel ? AppColors.vowelColor : AppColors.consonantColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '/${phoneme.symbol}/',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            phoneme.nameEn,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.85),
            ),
          ),
          if (phoneme.isChineseDifficulty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                '常见难点',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.errorRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
