import 'package:get/get.dart';

import '../../../core/auth/controllers/auth_controller.dart';
import '../../../core/lesson/controllers/lesson_controller.dart';
import '../../../core/onboarding/controllers/onboarding_controller.dart';
import '../controllers/home_controller.dart';

/// Binding da home
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Instanciar AuthController primeiro (se não estiver registrado)
    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut<AuthController>(() => AuthController());
    }

    // GamificationController is already registered globally in main.dart

    // Instanciar LessonController
    Get.lazyPut<LessonController>(() => LessonController());

    // Instanciar outros controllers
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}
