import 'package:get/get.dart';

import '../navigation/onboarding_navigation.dart';

/// Controller do onboarding
class OnboardingController extends GetxController {
  // Estados
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Navegação
  final nav = OnboardingNavigation();

  // Dados do onboarding - Idioma
  final selectedLanguage = ''.obs;
  final languageLevel = ''.obs;
  final learningReason = ''.obs;

  // Dados do onboarding - Tempo
  final studyTime = ''.obs;

  // Dados do onboarding - Perfil
  final userName = ''.obs;
  final userAge = ''.obs;
  final userEmail = ''.obs;
  final userPassword = ''.obs;
}
