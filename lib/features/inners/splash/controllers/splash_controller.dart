import 'package:get/get.dart';

/// Controller da splash screen
class SplashController extends GetxController {
  // Estados
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    _navigate();
  }

  // Métodos privados
  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    // TODO: Implementar lógica de autenticação
    // 1. Não autenticado? → /onboarding (primeiro acesso) ou /auth (já tem conta)
    // 2. Autenticado, setup incompleto? → /setup
    // 3. Autenticado, setup completo? → /home

    // Por enquanto, vai para home (temporário)
    Get.offAllNamed('/home');
  }
}
