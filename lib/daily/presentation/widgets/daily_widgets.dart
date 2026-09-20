import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../domain/word_aligner.dart';

class DailyPage extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const DailyPage({
    super.key,
    required this.child,
    this.maxWidth = 760,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 168),
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.bgLight,
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SingleChildScrollView(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

class DailyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;
  final Key? cardKey;

  const DailyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
    this.onTap,
    this.cardKey,
  });

  @override
  Widget build(BuildContext context) {
    final body = Container(
      key: cardKey,
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: child,
    );
    if (onTap == null) {
      return body;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: body,
      ),
    );
  }
}

class DailyPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const DailyPill({
    super.key,
    required this.label,
    this.color = AppColors.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class DailyEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;

  const DailyEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon = Icons.mic_none_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return DailyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              height: 1.55,
              color: AppColors.textSecondary,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class DailyErrorState extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const DailyErrorState({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return DailyCard(
      color: const Color(0xFFFFF4F2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.errorRed),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class WordChipRow extends StatelessWidget {
  final List<AlignedWord> words;

  const WordChipRow({super.key, required this.words});

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: words.map((word) {
        final color = switch (word.status) {
          WordAlignStatus.hit => AppColors.hit,
          WordAlignStatus.subst => AppColors.partial,
          WordAlignStatus.miss => AppColors.miss,
        };
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Text(
            word.expected,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class WeekStreakRow extends StatelessWidget {
  final int streakDays;
  final DateTime? lastActiveDate;

  const WeekStreakRow({
    super.key,
    required this.streakDays,
    this.lastActiveDate,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = lastActiveDate == null
        ? null
        : DateTime(
            lastActiveDate!.year,
            lastActiveDate!.month,
            lastActiveDate!.day,
          );
    final labels = const ['一', '二', '三', '四', '五', '六', '日'];
    return Row(
      children: List.generate(7, (index) {
        final weekday = index + 1;
        final day = today.subtract(Duration(days: today.weekday - weekday));
        final isFuture = day.isAfter(today);
        final isFilled =
            !isFuture &&
            streakDays > 0 &&
            last != null &&
            !day.isAfter(last) &&
            today.difference(day).inDays < streakDays;
        return Expanded(
          child: Column(
            children: [
              Text(
                labels[index],
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled
                      ? AppColors.streakFlame
                      : AppColors.surfaceAccent,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionLabel({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
