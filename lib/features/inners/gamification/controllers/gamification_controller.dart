import 'package:get/get.dart';

abstract class GamificationController {
  bool get hasUnlimitedEnergy;

  bool canStartLesson();

  Future<void> onLessonStart();

  Future<void> onLessonComplete(
    int baseXp,
    int baseGems,
    bool isPerfect, {
    String lessonId = '',
  });
}
