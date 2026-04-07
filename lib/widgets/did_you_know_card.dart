import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class DidYouKnowCard extends StatefulWidget {
  final String text;
  final String source;

  const DidYouKnowCard({super.key, required this.text, required this.source});

  @override
  State<DidYouKnowCard> createState() => _DidYouKnowCardState();
}

class _DidYouKnowCardState extends State<DidYouKnowCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 16),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    '你知道吗？',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 12),
              Text(
                widget.text,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.6),
              ),
              const SizedBox(height: 8),
              Text(
                '— ${widget.source}',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
