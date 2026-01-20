import 'package:get/get.dart';

import '../controllers/lesson_controller.dart';

/// Binding para injeção de dependência do LessonController
class LessonBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LessonController>(() => LessonController());
  }
}
