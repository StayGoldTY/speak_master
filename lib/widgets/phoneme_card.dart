import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/phoneme.dart';

class PhonemeCard extends StatelessWidget {
  final Phoneme phoneme;

  const PhonemeCard({super.key, required this.phoneme});

  @override
  Widget build(BuildContext context) {
    final isVowel = phoneme.type == PhonemeType.vowel;
    final color = isVowel ? AppColors.vowelColor : AppColors.consonantColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '/${phoneme.symbol}/',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            phoneme.nameCn.replaceAll(RegExp(r'.*音\s*/'), '').replaceAll('/', ''),
            style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.7)),
            maxLines: 1,
          ),
          if (phoneme.isChineseDifficulty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '难点',
                style: TextStyle(fontSize: 9, color: AppColors.errorRed, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
