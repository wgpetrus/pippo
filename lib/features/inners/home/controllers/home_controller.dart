import 'package:get/get.dart';

import '../../../core/lesson/views/sections_page.dart';
import '../../../core/onboarding/controllers/onboarding_controller.dart';
import '../widgets/home_appbar.dart';

/// Controller da home
class HomeController extends GetxController {
  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Estados de UI
  final currentNavIndex = 0.obs;
  final selectedStat = Rxn<StatType>();
  final showContinue = false.obs;

  // Métodos
  void onNavTap(int index) {
    currentNavIndex.value = index;
  }

  void onStatTap(StatType stat) {
    selectedStat.value = selectedStat.value == stat ? null : stat;
  }

  void onStartTap() {
    showContinue.value = true;
    Get.to(() => const SectionsPage(courseName: 'French'));
  }

  void onAddCourse() {
    // Marca que está adicionando curso e navega para onboarding
    final onboardingController = Get.find<OnboardingController>();
    onboardingController.isAddingCourse.value = true;
    onboardingController.nav.goToSelectLanguage();
  }
}
