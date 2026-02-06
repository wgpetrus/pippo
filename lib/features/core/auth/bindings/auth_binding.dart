import 'package:get/get.dart';

import '../controllers/auth_credentials_controller.dart';
import '../controllers/auth_providers_controller.dart';

/// Binding de autenticação
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Registrar controllers de autenticação
    Get.lazyPut(() => AuthCredentialsController());
    Get.lazyPut(() => AuthProvidersController());
  }
}
