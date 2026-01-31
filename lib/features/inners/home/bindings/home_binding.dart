import 'package:get/get.dart';

import '../../../core/auth/controllers/auth_controller.dart';
import '../../../core/lesson/controllers/lesson_controller.dart';
import '../../../core/onboarding/controllers/onboarding_controller.dart';
import '../../gamification/controllers/gamification_controller.dart';
import '../../leaderboard/controllers/leaderboard_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../shop/controllers/shop_controller.dart';
import '../../treasure/controllers/treasure_controller.dart';
import '../controllers/home_controller.dart';

/// Binding da home
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Garantir que AuthController está disponível
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }

    // Garantir que GamificationController está disponível
    if (!Get.isRegistered<GamificationController>()) {
      Get.put(GamificationController(), permanent: true);
    }

    // Instanciar ProfileController
    Get.lazyPut<ProfileController>(() => ProfileController());

    // Instanciar LessonController
    Get.lazyPut<LessonController>(() => LessonController());

    // Instanciar LeaderboardController
    Get.lazyPut<LeaderboardController>(() => LeaderboardController());

    // Instanciar ShopController
    Get.lazyPut<ShopController>(() => ShopController());

    // Instanciar TreasureController
    Get.lazyPut<TreasureController>(() => TreasureController());

    // Instanciar outros controllers
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}
