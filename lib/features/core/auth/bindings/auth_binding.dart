import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

/// Binding de autenticação
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
