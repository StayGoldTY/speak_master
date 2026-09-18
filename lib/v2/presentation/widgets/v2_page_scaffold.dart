import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';

class V2PageScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget> actions;
  final bool compactHeader;
  final bool includeSafeArea;
  final String? eyebrow;

  const V2PageScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.actions = const [],
    this.compactHeader = false,
    this.includeSafeArea = true,
    this.eyebrow,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;
    final titleSize = compactHeader
        ? (compact ? 28.0 : 34.0)
        : (compact ? 36.0 : 52.0);
    final horizontal = compact ? 22.0 : 40.0;
    final top = compactHeader ? 12.0 : (compact ? 28.0 : 44.0);

    final content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(horizontal, top, horizontal, 132),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PageHeader(
                title: title,
                subtitle: subtitle,
                actions: actions,
                compact: compact,
                titleSize: titleSize,
                eyebrow: eyebrow ?? '声临其境',
              ),
              SizedBox(height: compactHeader ? 28 : (compact ? 36 : 56)),
              child,
            ],
          ),
        ),
      ),
    );

    final painted = Stack(
      children: [
        const Positioned.fill(child: _CanvasAtmosphere()),
        includeSafeArea ? SafeArea(bottom: false, child: content) : content,
      ],
    );

    return ColoredBox(color: AppColors.bgLight, child: painted);
  }
}

class _PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> actions;
  final bool compact;
  final double titleSize;
  final String eyebrow;

  const _PageHeader({
    required this.title,
    required this.subtitle,
    required this.actions,
    required this.compact,
    required this.titleSize,
    required this.eyebrow,
  });

  @override
  Widget build(BuildContext context) {
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.6,
            color: AppColors.textHint,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w600,
            letterSpacing: titleSize > 40 ? -1.6 : -0.8,
            height: 1.05,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: compact ? 17 : 19,
              height: 1.47,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(height: 22),
          Wrap(spacing: 8, runSpacing: 8, children: actions),
        ],
      ],
    );

    return header
        .animate()
        .fadeIn(duration: 560.ms, curve: Curves.easeOutCubic)
        .moveY(begin: 10, end: 0, duration: 720.ms, curve: Curves.easeOutCubic);
  }
}

class _CanvasAtmosphere extends StatelessWidget {
  const _CanvasAtmosphere();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFE9EEF3).withValues(alpha: 0.9),
              AppColors.bgLight,
              AppColors.bgLight,
            ],
            stops: const [0, 0.28, 1],
          ),
        ),
      ),
    );
  }
}

class V2InfoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const V2InfoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(28),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppColors.faintShadow,
      ),
      child: child,
    );
  }
}

class V2SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const V2SectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 18 : 22, top: compact ? 8 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: compact ? 26 : 32,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.7,
              height: 1.1,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 17,
                color: AppColors.textSecondary,
                height: 1.47,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class V2Pill extends StatelessWidget {
  final String label;
  final Color color;

  const V2Pill({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final isLight = color.computeLuminance() > 0.72;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: isLight
            ? Colors.white.withValues(alpha: 0.14)
            : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isLight ? Colors.white : color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}

class V2CinematicBand extends StatelessWidget {
  final String kicker;
  final String headline;
  final String body;
  final Widget? action;
  final List<Widget> metrics;

  const V2CinematicBand({
    super.key,
    required this.kicker,
    required this.headline,
    required this.body,
    this.action,
    this.metrics = const [],
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        compact ? 28 : 40,
        compact ? 36 : 48,
        compact ? 28 : 40,
        compact ? 32 : 40,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.gradientCinematic,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kicker.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.8,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            headline,
            style: TextStyle(
              fontSize: compact ? 34 : 48,
              fontWeight: FontWeight.w600,
              letterSpacing: compact ? -1.0 : -1.6,
              height: 1.05,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              body,
              style: TextStyle(
                fontSize: compact ? 16 : 18,
                height: 1.47,
                color: Colors.white.withValues(alpha: 0.72),
              ),
            ),
          ),
          if (metrics.isNotEmpty) ...[
            const SizedBox(height: 28),
            Wrap(spacing: 28, runSpacing: 18, children: metrics),
          ],
          if (action != null) ...[const SizedBox(height: 28), action!],
        ],
      ),
    ).animate().fadeIn(duration: 700.ms, curve: Curves.easeOutCubic);
  }
}

class V2EmptyState extends StatelessWidget {
  final String title;
  final String body;
  final Widget? action;

  const V2EmptyState({
    super.key,
    required this.title,
    required this.body,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return V2InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              fontSize: 17,
              height: 1.47,
              color: AppColors.textSecondary,
            ),
          ),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    );
  }
}

class V2SpecMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool inverted;

  const V2SpecMetric({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.inverted = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = inverted
        ? Colors.white.withValues(alpha: 0.55)
        : AppColors.textHint;
    final numberColor =
        valueColor ?? (inverted ? Colors.white : AppColors.textPrimary);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 108),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              color: numberColor,
            ),
          ),
        ],
      ),
    );
  }
}
