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
      appBar: AppBar(title: const Text('V2 运营后台')),
      body: V2PageScaffold(
        title: '运营后台',
        subtitle: '先承接课程版本状态、生成任务和发布准备度，后续再继续扩展内容审核与数据看板能力。',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _OpsMetric(
                  label: '草稿版本',
                  value: '${dashboard.draftCount}',
                  color: AppColors.accentOrange,
                ),
                _OpsMetric(
                  label: '已发布',
                  value: '${dashboard.publishedCount}',
                  color: AppColors.successGreen,
                ),
                _OpsMetric(
                  label: '失败任务',
                  value: '${dashboard.failedJobs}',
                  color: AppColors.errorRed,
                ),
              ],
            ),
            const SizedBox(height: 20),
            V2InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    track.subtitle,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  V2Pill(
                    label: '当前版本 ${track.version.id}',
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const V2SectionTitle(
              title: '生成任务',
              subtitle: '这里展示当前种子数据下的后台任务视图，后续会接入真实 AI 生成与人工审核流程。',
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
                            Text(
                              job.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              job.summary,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.55,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      V2Pill(
                        label: job.status.label,
                        color: _colorFor(job.status),
                      ),
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
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
