import 'package:get/get.dart';

import '../../../core/onboarding/controllers/onboarding_controller.dart';
import '../controllers/home_controller.dart';

/// Binding da home
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}
