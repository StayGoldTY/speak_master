import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../application/providers/v2_providers.dart';
import '../widgets/activity_blueprint_view.dart';
import '../widgets/v2_page_scaffold.dart';

class LessonPlayerScreen extends ConsumerWidget {
  final String lessonId;

  const LessonPlayerScreen({
    super.key,
    required this.lessonId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lesson = ref.watch(v2LessonProvider(lessonId));

    if (lesson == null) {
      return const Scaffold(
        body: SafeArea(
          child: Center(child: Text('Lesson not found.')),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: V2PageScaffold(
        title: lesson.title,
        subtitle: lesson.description,
        actions: [
          V2Pill(label: lesson.subtitle, color: AppColors.primary),
          V2Pill(label: '${lesson.estimatedMinutes} min', color: AppColors.secondary),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: lesson.activities
              .map(
                (activity) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ActivityBlueprintView(activity: activity),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
