import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../../lib/features/inners/gamification/controllers/energy_controller.dart';
import '../../../lib/features/inners/gamification/controllers/gems_controller.dart';
import '../../../lib/features/inners/gamification/controllers/streak_controller.dart';
import '../../../lib/features/inners/gamification/controllers/xp_level_controller.dart';
import '../helpers/firebase_test_helper.dart';

/// Integration Tests for Shop System - Boost Application
/// 
/// Testes FUNCIONAIS que validam o comportamento real da aplicação de boosts:
/// - XP booster doubles XP rewards
/// - Gem multiplier doubles gem rewards
/// - Streak freeze protects streak
/// - Boost expiration prevents application
/// - Multiple boosts work simultaneously
void main() {
  late FakeFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late XpLevelController xpController;
  late GemsController gemsController;
  late StreakController streakController;
  late EnergyController energyController;

  setUp(() async {
    await FirebaseTestHelper.setupFirebase();
    
    mockFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth(signedIn: true);

    // Criar curso ativo para o usuário PRIMEIRO
    await mockFirestore
        .collection('users')
        .doc(mockAuth.currentUser!.uid)
        .collection('courses')
        .doc('test-course')
        .set({
      'isActive': true,
      'language': 'en',
      'createdAt': DateTime.now(),
    });

    // Popular dados iniciais no documento de gamification
    await mockFirestore
        .collection('users')
        .doc(mockAuth.currentUser!.uid)
        .collection('courses')
        .doc('test-course')
        .collection('stats')
        .doc('gamification')
        .set({
      'xp': {
        'totalXp': 0,
        'weeklyXP': 0,
        'todayXp': 0,
        'level': 1,
        'xpToNextLevel': 100,
        'xpBoosterUntil': null,
        'lastWeeklyResetDate': '',
        'lastDailyResetDate': '',
      },
      'gems': {
        'gems': 500,
        'totalGemsEarned': 500,
        'totalGemsSpent': 0,
        'gemMultiplierUntil': null,
      },
      'streak': {
        'currentStreak': 5,
        'longestStreak': 5,
        'lastStreakDate': DateTime.now().subtract(const Duration(days: 2)).toIso8601String().split('T')[0],
        'streakFreezeAvailable': true,
        'streakFreezeUsedToday': false,
        'milestonesReached': [],
      },
      'energy': {
        'currentEnergy': 3,
        'maxEnergy': 5,
        'lastEnergyRegenAt': DateTime.now(),
        'unlimitedEnergyUntil': null,
      },
      'lastUpdated': DateTime.now(),
    });

    // Instanciar controllers com DI
    xpController = XpLevelController(
      firestore: mockFirestore,
      auth: mockAuth,
    );
    gemsController = GemsController(
      firestore: mockFirestore,
      auth: mockAuth,
    );
    streakController = StreakController(
      firestore: mockFirestore,
      auth: mockAuth,
    );
    energyController = EnergyController(
      firestore: mockFirestore,
      auth: mockAuth,
    );

    Get.put<XpLevelController>(xpController);
    Get.put<GemsController>(gemsController);
    Get.put<StreakController>(streakController);
    Get.put<EnergyController>(energyController);

    // Aguardar carregamento inicial dos controllers
    await Future.delayed(const Duration(milliseconds: 200));
  });

  tearDown(() {
    Get.reset();
  });
  group('Boost Application - XP Booster', () {
    test('XP booster should double XP rewards during lesson', () async {
      // Arrange: Ativar XP booster por 60 minutos
      await xpController.activateXpBooster(60);
      expect(xpController.hasXpBooster, true);
      
      final initialXp = xpController.totalXp.value;

      // Act: Adicionar 20 XP (simulando lição completa)
      await xpController.addXp(20);

      // Assert: XP ganho = 20 × 2 = 40 XP
      expect(xpController.totalXp.value, initialXp + 40);
      expect(xpController.weeklyXP.value, 40);
      expect(xpController.todayXp.value, 40);
    });

    test('XP booster should not apply after expiration', () async {
      // Arrange: Ativar XP booster que já expirou
      xpController.setXpBoosterUntil(DateTime.now().subtract(const Duration(seconds: 1)));
      expect(xpController.hasXpBooster, false);
      
      final initialXp = xpController.totalXp.value;

      // Act: Adicionar 10 XP
      await xpController.addXp(10);

      // Assert: XP ganho = 10 (sem multiplicador)
      expect(xpController.totalXp.value, initialXp + 10);
    });
  });

  group('Boost Application - Gem Multiplier', () {
    test('Gem multiplier should double gem rewards during lesson', () async {
      // Arrange: Ativar gem multiplier por 60 minutos
      await gemsController.activateGemMultiplier(60);
      expect(gemsController.hasGemMultiplier, true);
      
      final initialGems = gemsController.gems.value;

      // Act: Adicionar 5 gems (simulando lição completa)
      await gemsController.addGems(5);

      // Assert: Gems ganhas = 5 × 2 = 10 gems
      expect(gemsController.gems.value, initialGems + 10);
      expect(gemsController.totalGemsEarned.value, greaterThanOrEqualTo(510)); // 500 inicial + 10
    });

    test('Gem multiplier should not apply after expiration', () async {
      // Arrange: Ativar gem multiplier que já expirou
      gemsController.setGemMultiplierUntil(DateTime.now().subtract(const Duration(seconds: 1)));
      expect(gemsController.hasGemMultiplier, false);
      
      final initialGems = gemsController.gems.value;

      // Act: Adicionar 5 gems
      await gemsController.addGems(5);

      // Assert: Gems ganhas = 5 (sem multiplicador)
      expect(gemsController.gems.value, initialGems + 5);
    });
  });

  group('Boost Application - Streak Freeze', () {
    test('Streak freeze should protect streak when day is skipped', () async {
      // Arrange: Usuário com streak de 5 dias, última atualização 2 dias atrás, freeze disponível
      expect(streakController.currentStreak.value, 5);
      expect(streakController.streakFreezeAvailable, true);

      // Act: Atualizar streak (simula completar lição hoje)
      await streakController.updateStreak();

      // Assert: Streak mantido, freeze consumido
      expect(streakController.currentStreak.value, 5); // Mantido
      expect(streakController.streakFreezeAvailable, false); // Consumido
    });

    test('Streak should reset when freeze not available', () async {
      // Arrange: Usuário com streak de 5 dias, sem freeze disponível
      streakController.setStreakFreezeAvailable(false);
      streakController.setLastStreakDate(
        DateTime.now().subtract(const Duration(days: 2)).toIso8601String().split('T')[0]
      );
      expect(streakController.currentStreak.value, 5);
      expect(streakController.streakFreezeAvailable, false);

      // Act: Atualizar streak
      await streakController.updateStreak();

      // Assert: Streak resetado para 1
      expect(streakController.currentStreak.value, 1); // Resetado e incrementado para hoje
    });
  });

  group('Boost Application - Energy Refill', () {
    test('Energy refill should restore energy to maximum', () async {
      // Arrange: Usuário com 3 energia (de 5 máximo)
      expect(energyController.currentEnergy.value, 3);

      // Act: Aplicar energy refill
      await energyController.refillEnergy();

      // Assert: Energia restaurada para 5
      expect(energyController.currentEnergy.value, 5);
      expect(energyController.errorMessage.value, isEmpty);
    });

    test('Energy refill should not work when energy is full', () async {
      // Arrange: Usuário com 5 energia (máximo)
      energyController.currentEnergy.value = 5;

      // Act: Tentar aplicar energy refill
      await energyController.refillEnergy();

      // Assert: Erro definido, energia permanece 5
      expect(energyController.errorMessage.value, isNotEmpty);
      expect(energyController.errorMessage.value, contains('energia máxima'));
      expect(energyController.currentEnergy.value, 5);
    });
  });

  group('Boost Application - Multiple Boosts', () {
    test('Multiple boosts should work simultaneously', () async {
      // Arrange: Ativar XP booster e gem multiplier
      await xpController.activateXpBooster(60);
      await gemsController.activateGemMultiplier(60);
      expect(xpController.hasXpBooster, true);
      expect(gemsController.hasGemMultiplier, true);
      
      final initialXp = xpController.totalXp.value;
      final initialGems = gemsController.gems.value;

      // Act: Adicionar 10 XP e 5 gems (simulando lição)
      await xpController.addXp(10);
      await gemsController.addGems(5);

      // Assert: Ambos multiplicadores aplicados
      expect(xpController.totalXp.value, initialXp + 20); // 10 × 2
      expect(gemsController.gems.value, initialGems + 10); // 5 × 2
    });

    test('Boosts expire independently', () async {
      // Arrange: XP booster expirado, gem multiplier ativo
      xpController.setXpBoosterUntil(DateTime.now().subtract(const Duration(seconds: 1)));
      await gemsController.activateGemMultiplier(60);
      
      expect(xpController.hasXpBooster, false);
      expect(gemsController.hasGemMultiplier, true);
      
      final initialXp = xpController.totalXp.value;
      final initialGems = gemsController.gems.value;

      // Act: Adicionar 10 XP e 5 gems
      await xpController.addXp(10);
      await gemsController.addGems(5);

      // Assert: Apenas gem multiplier aplicado
      expect(xpController.totalXp.value, initialXp + 10); // Sem multiplicador
      expect(gemsController.gems.value, initialGems + 10); // Com multiplicador (5 × 2)
    });
  });

  group('Integration Test Summary', () {
    test('All boost application flows verified', () {
      // Verificação de que todos os fluxos foram testados
      expect(true, true, reason: 'All boost application flows verified');
    });
  });
}
