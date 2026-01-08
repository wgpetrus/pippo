import 'package:get/get.dart';

import '../views/forgot_password_view.dart';
import '../views/new_password_view.dart';
import '../views/verify_code_view.dart';

/// Controller de autenticação
class AuthController extends GetxController {
  // Estados
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Navegação
  void goToForgotPassword() => Get.to(() => const ForgotPasswordView());
  void goToVerifyCode() => Get.to(() => const VerifyCodeView());
  void goToNewPassword() => Get.to(() => const NewPasswordView());
  void backToSignin() => Get.offAllNamed('/auth');
}
