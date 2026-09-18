import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class RecordButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onTap;

  const RecordButton({super.key, required this.isRecording, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: isRecording ? 84 : 76,
        height: isRecording ? 84 : 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isRecording ? AppColors.errorRed : AppColors.ink,
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: isRecording ? 0.12 : 0.18),
              blurRadius: isRecording ? 24 : 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          isRecording ? Icons.stop_rounded : Icons.mic_rounded,
          color: Colors.white,
          size: isRecording ? 34 : 30,
        ),
      ),
    );
  }
}
