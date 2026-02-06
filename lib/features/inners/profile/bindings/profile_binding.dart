import 'package:get/get.dart';

import '../controllers/profile_auth_controller.dart';
import '../controllers/profile_courses_controller.dart';
import '../controllers/profile_data_controller.dart';
import '../controllers/profile_search_controller.dart';
import '../controllers/profile_settings_controller.dart';
import '../controllers/profile_social_controller.dart';

/// ProfileBinding - Dependency injection for Profile controllers
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // Instantiate in dependency order (no dependencies first)
    Get.lazyPut<ProfileDataController>(() => ProfileDataController());
    Get.lazyPut<ProfileSettingsController>(() => ProfileSettingsController());
    Get.lazyPut<ProfileSocialController>(() => ProfileSocialController());
    Get.lazyPut<ProfileSearchController>(() => ProfileSearchController());
    Get.lazyPut<ProfileCoursesController>(() => ProfileCoursesController());
    Get.lazyPut<ProfileAuthController>(() => ProfileAuthController());
  }
}
