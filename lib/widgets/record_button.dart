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
        duration: const Duration(milliseconds: 200),
        width: isRecording ? 80 : 72,
        height: isRecording ? 80 : 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isRecording ? AppColors.errorRed : AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: (isRecording ? AppColors.errorRed : AppColors.primary).withValues(alpha: 0.3),
              blurRadius: isRecording ? 20 : 12,
              spreadRadius: isRecording ? 4 : 0,
            ),
          ],
        ),
        child: Icon(
          isRecording ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: isRecording ? 36 : 32,
        ),
      ),
    );
  }
}
