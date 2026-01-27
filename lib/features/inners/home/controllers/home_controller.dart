import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../core/lesson/controllers/lesson_controller.dart';
import '../../../core/lesson/views/sections_page.dart';
import '../../../core/onboarding/controllers/onboarding_controller.dart';
import '../../treasure/controllers/treasure_controller.dart';
import '../widgets/home_appbar.dart';

/// Controller da home
class HomeController extends GetxController {
  // Firebase instances
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Estados de UI
  final currentNavIndex = 0.obs;
  final selectedStat = Rxn<StatType>();
  final showContinue = false.obs;

  // Estados de progresso das lições
  final completedLessons = <String>[].obs; // IDs das lições completadas
  final isLoadingProgress = false.obs;

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    _loadLessonProgress();
  }

  // Métodos privados
  Future<void> _loadLessonProgress() async {
    isLoadingProgress.value = true;

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Buscar curso ativo
      final coursesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (coursesSnapshot.docs.isEmpty) return;

      final courseId = coursesSnapshot.docs.first.id;

      // Buscar progresso das lições
      final progressSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .collection('progress')
          .where('status', isEqualTo: 'completed')
          .get();

      completedLessons.value = progressSnapshot.docs
          .map((doc) => doc.data()['lessonId'] as String)
          .toList();
    } catch (e) {
      // Silenciosamente falhar - não é crítico
    } finally {
      isLoadingProgress.value = false;
    }
  }

  // Métodos públicos
  void onNavTap(int index) {
    final previousIndex = currentNavIndex.value;
    currentNavIndex.value = index;
    
    // Se navegando para a tab Treasure (index 3), recarregar desafios
    if (index == 3 && previousIndex != 3) {
      _refreshTreasurePage();
    }
  }

  /// Recarrega dados da página Treasure quando usuário retorna à tab
  void _refreshTreasurePage() {
    try {
      if (Get.isRegistered<TreasureController>()) {
        final treasureController = Get.find<TreasureController>();
        treasureController.loadChallenges();
      }
    } catch (e) {
      // TreasureController não registrado - não é crítico
    }
  }

  void onStatTap(StatType stat) {
    selectedStat.value = selectedStat.value == stat ? null : stat;
  }

  void onStartTap() {
    showContinue.value = true;
    
    // Garantir que o LessonController está registrado antes de navegar
    if (!Get.isRegistered<LessonController>()) {
      Get.put(LessonController());
    }
    
    Get.to(() => const SectionsPage(courseName: 'French'));
  }

  void onAddCourse() {
    // Marca que está adicionando curso e navega para onboarding
    final onboardingController = Get.find<OnboardingController>();
    onboardingController.isAddingCourse.value = true;
    onboardingController.nav.goToSelectLanguage();
  }

  void goToShop() {
    currentNavIndex.value = 2; // Tab 2 = Shop
  }

  /// Recarrega o progresso das lições (chamar após completar uma lição)
  Future<void> reloadProgress() async {
    await _loadLessonProgress();
  }
}
