import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

/// Binding de autenticação
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Garantir que AuthController está disponível
    // Se já foi registrado no main.dart, não faz nada
    // Se não, registra agora
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }
  }
}
