import 'package:get/get.dart';

import '../../../core/auth/controllers/auth_controller.dart';
import '../../../core/lesson/controllers/lesson_flow_controller.dart';
import '../../../core/lesson/controllers/lesson_exercise_controller.dart';
import '../../../core/lesson/controllers/lesson_progress_controller.dart';
import '../../../core/lesson/controllers/lesson_rewards_controller.dart';
import '../../../core/onboarding/controllers/onboarding_controller.dart';
import '../../gamification/controllers/gamification_controller.dart';
import '../../leaderboard/controllers/leaderboard_controller.dart';
import '../../profile/controllers/profile_auth_controller.dart';
import '../../profile/controllers/profile_courses_controller.dart';
import '../../profile/controllers/profile_data_controller.dart';
import '../../profile/controllers/profile_settings_controller.dart';
import '../../profile/controllers/profile_social_controller.dart';
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

    // Instanciar ProfileControllers (5 novos controllers)
    Get.lazyPut<ProfileDataController>(() => ProfileDataController());
    Get.lazyPut<ProfileSettingsController>(() => ProfileSettingsController());
    Get.lazyPut<ProfileSocialController>(() => ProfileSocialController());
    Get.lazyPut<ProfileCoursesController>(() => ProfileCoursesController());
    Get.lazyPut<ProfileAuthController>(() => ProfileAuthController());

    // Instanciar LessonControllers (4 novos controllers)
    Get.lazyPut<LessonFlowController>(() => LessonFlowController());
    Get.lazyPut<LessonExerciseController>(() => LessonExerciseController());
    Get.lazyPut<LessonProgressController>(() => LessonProgressController());
    Get.lazyPut<LessonRewardsController>(() => LessonRewardsController());

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
