import '../../../models/user_progress.dart';
import '../models/course_models.dart';
import '../models/learner_models.dart';
import '../models/speech_models.dart';

abstract class V2LearningRepository {
  CourseTrack getPrimaryTrack();

  UnitBlueprint? getUnitById(String unitId);

  LessonBlueprint? getLessonById(String lessonId);

  List<PronunciationTarget> getFeaturedTargets();

  List<SpeakingPrompt> getSpeakingPrompts();

  DailyPlan buildDailyPlan({
    required UserProgress progress,
    required String learnerName,
  });

  MasterySnapshot buildMasterySnapshot(UserProgress progress);

  OpsDashboard buildOpsDashboard();
}
