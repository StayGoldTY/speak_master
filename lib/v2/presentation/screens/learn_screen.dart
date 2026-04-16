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
      actions: [
        V2Pill(label: track.version.id, color: AppColors.primary),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          V2InfoCard(
            child: Text(
              track.description,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
            ),
          ),
          const SizedBox(height: 20),
          const V2SectionTitle(
            title: 'Units',
            subtitle: 'Legacy seed content is now mapped into versioned V2 units and lessons.',
          ),
          ...track.units.map((unit) {
            final completedCount = unit.lessons
                .where((lesson) => progress.completedLessons.contains(lesson.id))
                .length;
            final nextLesson = _nextLesson(unit, progress.completedLessons) ?? unit.lessons.first;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: V2InfoCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${unit.order}. ${unit.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(unit.subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          const SizedBox(height: 10),
                          Text(
                            unit.description,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.55),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              V2Pill(label: '$completedCount/${unit.lessons.length} lessons', color: AppColors.secondary),
                              ...unit.targetPhonemes.take(3).map((item) => V2Pill(label: item, color: AppColors.accentOrange)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () => context.push('/lesson/${nextLesson.id}'),
                      child: Text(completedCount == 0 ? 'Start' : 'Continue'),
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

  LessonBlueprint? _nextLesson(UnitBlueprint unit, Set<String> completedLessons) {
    for (final lesson in unit.lessons) {
      if (!completedLessons.contains(lesson.id)) {
        return lesson;
      }
    }
    return null;
  }
}
