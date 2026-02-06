import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../profile/controllers/profile_data_controller.dart';
import '../../profile/controllers/profile_social_controller.dart';
import '../../treasure/controllers/treasure_challenges_controller.dart';

/// Controller de navegação da home
class HomeNavigationController extends GetxController {
  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Estados de navegação
  final currentNavIndex = 0.obs;

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
  }

  // Métodos públicos

  /// Muda a tab ativa
  void onNavTap(int index) {
    final previousIndex = currentNavIndex.value;
    currentNavIndex.value = index;
    
    // Se navegando para a tab Treasure (index 3), recarregar desafios
    if (index == 3 && previousIndex != 3) {
      _refreshTreasurePage();
    }
    
    // Se navegando para a tab Profile (index 4), recarregar perfil e progresso
    if (index == 4 && previousIndex != 4) {
      _refreshProfilePage();
    }
  }

  /// Navega para a loja (tab 2)
  void goToShop() {
    currentNavIndex.value = 2; // Tab 2 = Shop
  }

  // Métodos privados

  /// Recarrega dados da página Treasure quando usuário retorna à tab
  void _refreshTreasurePage() {
    try {
      if (Get.isRegistered<TreasureChallengesController>()) {
        final challengesController = Get.find<TreasureChallengesController>();
        challengesController.loadChallenges();
      }
    } catch (e) {
      // TreasureChallengesController não registrado - não é crítico
    }
  }

  /// Recarrega dados da página Profile quando usuário retorna à tab
  void _refreshProfilePage() {
    try {
      final profileDataController = Get.find<ProfileDataController>();
      final profileSocialController = Get.find<ProfileSocialController>();
      
      profileDataController.loadOwnProfile();
      profileSocialController.loadWeeklyProgress();
      
      debugPrint('🔄 Profile atualizado ao trocar de aba');
    } catch (e) {
      debugPrint('⚠️ Erro ao atualizar Profile: $e');
      // Controllers não registrados - não é crítico
    }
  }
}
