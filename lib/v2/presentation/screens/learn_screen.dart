import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/progress_provider.dart';
import '../../application/providers/v2_providers.dart';
import '../../domain/models/course_models.dart';
import '../widgets/v2_page_scaffold.dart';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(v2PrimaryTrackProvider);
    final progress = ref.watch(progressProvider);

    return V2PageScaffold(
      title: track.title,
      subtitle: track.subtitle,
      actions: const [V2Pill(label: '主线课程', color: AppColors.primary)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          V2InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    V2Pill(label: '当前版本 V1', color: AppColors.primary),
                    V2Pill(
                      label: '共 ${track.units.length} 个单元',
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const V2SectionTitle(
            title: '课程单元',
            subtitle: '主线内容已经改造成可发布单元，支持继续学习、补弱训练和后续版本迭代。',
          ),
          ...track.units.map((unit) {
            final completedCount = unit.lessons
                .where(
                  (lesson) => progress.completedLessons.contains(lesson.id),
                )
                .length;
            final nextLesson =
                _nextLesson(unit, progress.completedLessons) ??
                unit.lessons.first;
            final progressValue = unit.lessons.isEmpty
                ? 0.0
                : completedCount / unit.lessons.length;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: V2InfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: AppColors.gradientPrimary,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${unit.order}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                unit.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                unit.subtitle,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FilledButton(
                          onPressed: () =>
                              context.push('/lesson/${nextLesson.id}'),
                          child: Text(completedCount == 0 ? '开始单元' : '继续学习'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      unit.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.65,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: progressValue,
                              minHeight: 8,
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.08,
                              ),
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$completedCount/${unit.lessons.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        V2Pill(
                          label: '已完成 $completedCount 节',
                          color: AppColors.secondary,
                        ),
                        ...unit.targetPhonemes
                            .take(4)
                            .map(
                              (item) => V2Pill(
                                label: item,
                                color: AppColors.accentOrange,
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  LessonBlueprint? _nextLesson(
    UnitBlueprint unit,
    Set<String> completedLessons,
  ) {
    for (final lesson in unit.lessons) {
      if (!completedLessons.contains(lesson.id)) {
        return lesson;
      }
    }
    return null;
  }
}
