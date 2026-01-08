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
    // Por enquanto sempre vai para onboarding
    Get.offAllNamed('/onboarding');
  }
}
