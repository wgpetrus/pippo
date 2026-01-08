import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

/// Binding da splash screen
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
