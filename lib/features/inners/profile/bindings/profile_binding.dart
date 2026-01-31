import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

/// ProfileBinding - Dependency injection for ProfileController
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
