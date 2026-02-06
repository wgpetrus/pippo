import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pippo/features/core/lesson/controllers/lesson_rewards_controller.dart';
import 'package:pippo/features/core/lesson/controllers/lesson_progress_controller.dart';
import 'package:pippo/features/inners/gamification/controllers/gamification_controller.dart';

import '../../../../helpers/firebase_test_helper.dart';

/// Testes unitários para cálculos de XP no LessonRewardsController
/// 
/// Verifica a lógica de cálculo pura sem necessidade de
/// inicialização completa do Firebase ou estado do controller.
void main() {
  // Setup
  setUpAll(() async {
    await FirebaseTestHelper.setupFirebase();
  });

  group('LessonRewardsController - Cálculos de XP', () {
    test('calculateXPForNextLevel segue fórmula: currentLevel * 100', () {
      Get.testMode = true;
      
      // Registrar controllers necessários
      Get.put<GamificationController>(
        GamificationController(),
        permanent: true,
      );
      Get.put<LessonProgressController>(
        LessonProgressController(),
        permanent: true,
      );
      
      final controller = LessonRewardsController();
      
      // Testar fórmula para vários níveis
      expect(controller.calculateXPForNextLevel(1), equals(100));
      expect(controller.calculateXPForNextLevel(2), equals(200));
      expect(controller.calculateXPForNextLevel(5), equals(500));
      expect(controller.calculateXPForNextLevel(10), equals(1000));
      expect(controller.calculateXPForNextLevel(50), equals(5000));
      expect(controller.calculateXPForNextLevel(100), equals(10000));
      
      Get.reset();
    });

    test('calculateXPForNextLevel nunca retorna negativo ou zero', () {
      Get.testMode = true;
      
      Get.put<GamificationController>(
        GamificationController(),
        permanent: true,
      );
      Get.put<LessonProgressController>(
        LessonProgressController(),
        permanent: true,
      );
      
      final controller = LessonRewardsController();
      
      // Testar que todos os valores são positivos
      for (int level = 1; level <= 100; level++) {
        final xp = controller.calculateXPForNextLevel(level);
        expect(xp, greaterThan(0), reason: 'Nível $level deve ter XP positivo');
        expect(xp, greaterThanOrEqualTo(100), reason: 'Nível $level deve requerer pelo menos 100 XP');
      }
      
      Get.reset();
    });

    test('calculateXPForNextLevel é determinístico', () {
      Get.testMode = true;
      
      Get.put<GamificationController>(
        GamificationController(),
        permanent: true,
      );
      Get.put<LessonProgressController>(
        LessonProgressController(),
        permanent: true,
      );
      
      final controller = LessonRewardsController();
      
      // Testar que o mesmo input sempre produz o mesmo output
      for (int level = 1; level <= 50; level++) {
        final xp1 = controller.calculateXPForNextLevel(level);
        final xp2 = controller.calculateXPForNextLevel(level);
        final xp3 = controller.calculateXPForNextLevel(level);
        
        expect(xp1, equals(xp2), reason: 'Fórmula deve ser determinística');
        expect(xp2, equals(xp3), reason: 'Fórmula deve ser determinística');
        expect(xp1, equals(level * 100), reason: 'Fórmula deve seguir especificação');
      }
      
      Get.reset();
    });

    test('Requisitos de XP aumentam monotonicamente', () {
      Get.testMode = true;
      
      Get.put<GamificationController>(
        GamificationController(),
        permanent: true,
      );
      Get.put<LessonProgressController>(
        LessonProgressController(),
        permanent: true,
      );
      
      final controller = LessonRewardsController();
      
      // Testar que cada nível requer mais XP que o anterior
      for (int level = 1; level < 100; level++) {
        final currentXp = controller.calculateXPForNextLevel(level);
        final nextXp = controller.calculateXPForNextLevel(level + 1);
        
        expect(nextXp, greaterThan(currentXp),
            reason: 'Nível ${level + 1} deve requerer mais XP que nível $level');
        expect(nextXp - currentXp, equals(100),
            reason: 'Aumento de XP deve ser exatamente 100 por nível');
      }
      
      Get.reset();
    });

    test('calculateXPForNextLevel escala corretamente para níveis altos', () {
      Get.testMode = true;
      
      Get.put<GamificationController>(
        GamificationController(),
        permanent: true,
      );
      Get.put<LessonProgressController>(
        LessonProgressController(),
        permanent: true,
      );
      
      final controller = LessonRewardsController();
      
      final highLevels = [100, 500, 1000, 5000, 10000];
      
      for (final level in highLevels) {
        final xp = controller.calculateXPForNextLevel(level);
        
        expect(xp, equals(level * 100),
            reason: 'Fórmula deve funcionar para nível $level');
        
        // Testar escala linear
        final doubleLevel = level * 2;
        final doubleXp = controller.calculateXPForNextLevel(doubleLevel);
        expect(doubleXp, equals(xp * 2),
            reason: 'XP deve escalar linearmente com o nível');
      }
      
      Get.reset();
    });
  });
}
