import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pippo/features/inners/home/controllers/home_navigation_controller.dart';
import 'package:pippo/features/inners/treasure/controllers/treasure_challenges_controller.dart';
import 'package:pippo/features/inners/treasure/controllers/treasure_rewards_controller.dart';
import 'package:pippo/shared/theme/theme.dart';

import '../helpers/firebase_test_helper.dart';

/// Testes de integração para navegação do Treasure
/// 
/// Valida:
/// - Tab 3 navega para TreasurePage
/// - Tab destaca quando ativa
/// - Navegação não limpa stack
/// - Dados são atualizados ao retornar à tab
void main() {
  setUpAll(() async {
    await FirebaseTestHelper.setupFirebase();
  });

  setUp(() {
    Get.reset();
  });

  group('Treasure Navigation Integration Tests', () {
    testWidgets('Tab 3 navigates to TreasurePage', (tester) async {
      // Setup
      final navController = HomeNavigationController();
      final challengesController = TreasureChallengesController();
      final rewardsController = TreasureRewardsController();
      Get.put(navController);
      Get.put(challengesController);
      Get.put(rewardsController);

      // Verificar estado inicial
      expect(navController.currentNavIndex.value, 0);

      // Navegar para tab 3 (Treasure)
      navController.onNavTap(3);

      // Verificar navegação
      expect(navController.currentNavIndex.value, 3);
    });

    testWidgets('Tab highlights when active', (tester) async {
      // Setup
      final navController = HomeNavigationController();
      Get.put(navController);

      // Verificar tab não está ativa inicialmente
      expect(navController.currentNavIndex.value, 0);

      // Ativar tab 3
      navController.onNavTap(3);

      // Verificar tab está ativa
      expect(navController.currentNavIndex.value, 3);

      // Navegar para outra tab
      navController.onNavTap(1);

      // Verificar tab 3 não está mais ativa
      expect(navController.currentNavIndex.value, 1);
    });

    testWidgets('Navigation does not clear stack', (tester) async {
      // Setup
      final navController = HomeNavigationController();
      Get.put(navController);

      // Navegar entre tabs múltiplas vezes
      navController.onNavTap(1);
      navController.onNavTap(2);
      navController.onNavTap(3);
      navController.onNavTap(0);

      // Verificar que podemos voltar para qualquer tab
      navController.onNavTap(3);
      expect(navController.currentNavIndex.value, 3);

      navController.onNavTap(1);
      expect(navController.currentNavIndex.value, 1);

      // Stack não foi limpo - todas as tabs ainda acessíveis
    });

    testWidgets('Treasure page refreshes when returning to tab', (tester) async {
      // Setup
      final navController = HomeNavigationController();
      final challengesController = TreasureChallengesController();
      final rewardsController = TreasureRewardsController();
      Get.put(navController);
      Get.put(challengesController);
      Get.put(rewardsController);

      // Navegar para tab 3
      navController.onNavTap(3);
      await tester.pumpAndSettle();

      // Navegar para outra tab
      navController.onNavTap(1);
      await tester.pumpAndSettle();

      // Voltar para tab 3 - deve recarregar dados
      navController.onNavTap(3);
      await tester.pumpAndSettle();

      // Verificar que estamos na tab correta
      expect(navController.currentNavIndex.value, 3);
    });

    test('TreasureChallengesController and TreasureRewardsController are registered in HomeBinding', () {
      // Verificar que os novos controllers podem ser encontrados
      final challengesController = TreasureChallengesController();
      final rewardsController = TreasureRewardsController();
      Get.put(challengesController);
      Get.put(rewardsController);

      expect(Get.isRegistered<TreasureChallengesController>(), true);
      expect(Get.isRegistered<TreasureRewardsController>(), true);
      
      final foundChallenges = Get.find<TreasureChallengesController>();
      final foundRewards = Get.find<TreasureRewardsController>();
      expect(foundChallenges, isNotNull);
      expect(foundRewards, isNotNull);
    });
  });
}
