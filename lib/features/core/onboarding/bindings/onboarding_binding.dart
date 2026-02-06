import 'package:get/get.dart';

import '../controllers/onboarding_data_controller.dart';
import '../controllers/onboarding_flow_controller.dart';
import '../controllers/onboarding_validation_controller.dart';

/// Binding do onboarding
class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    // Instantiate in dependency order
    // DataController first (no dependencies)
    Get.lazyPut<OnboardingDataController>(() => OnboardingDataController());
    
    // ValidationController (depends on DataController)
    Get.lazyPut<OnboardingValidationController>(() => OnboardingValidationController());
    
    // FlowController last (depends on DataController)
    Get.lazyPut<OnboardingFlowController>(() => OnboardingFlowController());
  }
}
