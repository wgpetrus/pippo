import 'package:get/get.dart';

import '../../../core/auth/controllers/auth_credentials_controller.dart';
import '../../../core/auth/controllers/auth_providers_controller.dart';
import '../../../core/lesson/controllers/lesson_flow_controller.dart';
import '../../../core/lesson/controllers/lesson_exercise_controller.dart';
import '../../../core/lesson/controllers/lesson_progress_controller.dart';
import '../../../core/lesson/controllers/lesson_rewards_controller.dart';
import '../../../core/onboarding/controllers/onboarding_data_controller.dart';
import '../../../core/onboarding/controllers/onboarding_flow_controller.dart';
import '../../../core/onboarding/controllers/onboarding_validation_controller.dart';
import '../../gamification/controllers/gems_controller.dart';
import '../../gamification/controllers/energy_controller.dart';
import '../../gamification/controllers/streak_controller.dart';
import '../../gamification/controllers/xp_level_controller.dart';
import '../../leaderboard/controllers/leaderboard_controller.dart';
import '../../profile/controllers/profile_auth_controller.dart';
import '../../profile/controllers/profile_courses_controller.dart';
import '../../profile/controllers/profile_data_controller.dart';
import '../../profile/controllers/profile_search_controller.dart';
import '../../profile/controllers/profile_settings_controller.dart';
import '../../profile/controllers/profile_social_controller.dart';
import '../../shop/controllers/shop_controller.dart';
import '../../treasure/controllers/treasure_challenges_controller.dart';
import '../../treasure/controllers/treasure_rewards_controller.dart';
import '../controllers/home_navigation_controller.dart';
import '../controllers/home_stats_controller.dart';

/// Binding da home
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Garantir que AuthControllers estão disponíveis
    if (!Get.isRegistered<AuthCredentialsController>()) {
      Get.put(AuthCredentialsController(), permanent: true);
    }
    if (!Get.isRegistered<AuthProvidersController>()) {
      Get.put(AuthProvidersController(), permanent: true);
    }

    // Garantir que GemsController está disponível (primeiro - sem dependências)
    if (!Get.isRegistered<GemsController>()) {
      Get.put(GemsController(), permanent: true);
    }

    // Garantir que EnergyController está disponível
    if (!Get.isRegistered<EnergyController>()) {
      Get.put(EnergyController(), permanent: true);
    }

    // Garantir que StreakController está disponível (depende de GemsController)
    if (!Get.isRegistered<StreakController>()) {
      Get.put(StreakController(), permanent: true);
    }

    // Garantir que XpLevelController está disponível (depende de GemsController)
    if (!Get.isRegistered<XpLevelController>()) {
      Get.put(XpLevelController(), permanent: true);
    }

    // Instanciar ProfileControllers (6 controllers)
    Get.lazyPut<ProfileDataController>(() => ProfileDataController());
    Get.lazyPut<ProfileSettingsController>(() => ProfileSettingsController());
    Get.lazyPut<ProfileAuthController>(() => ProfileAuthController());
    Get.lazyPut<ProfileSocialController>(() => ProfileSocialController());
    Get.lazyPut<ProfileSearchController>(() => ProfileSearchController());
    Get.lazyPut<ProfileCoursesController>(() => ProfileCoursesController());

    // Instanciar LessonControllers (4 novos controllers)
    Get.lazyPut<LessonFlowController>(() => LessonFlowController());
    Get.lazyPut<LessonExerciseController>(() => LessonExerciseController());
    Get.lazyPut<LessonProgressController>(() => LessonProgressController());
    Get.lazyPut<LessonRewardsController>(() => LessonRewardsController());

    // Instanciar LeaderboardController
    Get.lazyPut<LeaderboardController>(() => LeaderboardController());

    // Instanciar ShopController
    Get.lazyPut<ShopController>(() => ShopController());

    // Instanciar TreasureControllers (2 novos controllers)
    Get.lazyPut<TreasureChallengesController>(() => TreasureChallengesController());
    Get.lazyPut<TreasureRewardsController>(() => TreasureRewardsController());

    // Instanciar Home controllers (2 controllers)
    Get.lazyPut<HomeNavigationController>(() => HomeNavigationController());
    Get.lazyPut<HomeStatsController>(() => HomeStatsController());
    
    // Instanciar OnboardingControllers (3 novos controllers)
    Get.lazyPut<OnboardingDataController>(() => OnboardingDataController());
    Get.lazyPut<OnboardingValidationController>(() => OnboardingValidationController());
    Get.lazyPut<OnboardingFlowController>(() => OnboardingFlowController());
  }
}
