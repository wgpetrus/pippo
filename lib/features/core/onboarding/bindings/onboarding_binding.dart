import 'package:get/get.dart';

import '../controllers/onboarding_controller.dart';

/// Binding do onboarding
class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}
