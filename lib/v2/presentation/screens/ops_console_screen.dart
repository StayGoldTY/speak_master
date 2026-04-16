import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../application/providers/v2_providers.dart';
import '../../domain/models/course_models.dart';
import '../widgets/v2_page_scaffold.dart';

class OpsConsoleScreen extends ConsumerWidget {
  const OpsConsoleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(v2OpsDashboardProvider);
    final track = ref.watch(v2PrimaryTrackProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('V2 Ops Console')),
      body: V2PageScaffold(
        title: 'Ops console',
        subtitle: 'A first admin-facing slice for version status, generation jobs, and publish readiness.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _OpsMetric(label: 'Drafts', value: '${dashboard.draftCount}', color: AppColors.accentOrange),
                _OpsMetric(label: 'Published', value: '${dashboard.publishedCount}', color: AppColors.successGreen),
                _OpsMetric(label: 'Failed jobs', value: '${dashboard.failedJobs}', color: AppColors.errorRed),
              ],
            ),
            const SizedBox(height: 20),
            V2InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(track.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(track.subtitle, style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  V2Pill(label: track.version.id, color: AppColors.primary),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const V2SectionTitle(
              title: 'Generation jobs',
              subtitle: 'This is a seeded V2 dashboard view for the upcoming AI and content workflow.',
            ),
            ...dashboard.jobs.map(
              (job) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: V2InfoCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(job.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 6),
                            Text(job.summary, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      V2Pill(label: job.status.name, color: _colorFor(job.status)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorFor(GenerationJobStatus status) {
    return switch (status) {
      GenerationJobStatus.ready => AppColors.successGreen,
      GenerationJobStatus.reviewing => AppColors.primary,
      GenerationJobStatus.failed => AppColors.errorRed,
      GenerationJobStatus.queued => AppColors.accentOrange,
    };
  }
}

class _OpsMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _OpsMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: V2InfoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }
}
