import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:pippo/features/inners/gamification/controllers/xp_level_controller.dart';

void main() {
  late XpLevelController controller;
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late MockUser user;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(signedIn: true);
    user = auth.currentUser as MockUser;
    
    Get.testMode = true;
    
    controller = XpLevelController(
      firestore: firestore,
      auth: auth,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('XpLevelController - loadXpAndLevel()', () {
    test('carrega XP e nível do Firestore quando documento existe', () async {
      // Arrange - Popular dados no Firestore
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .set({'isActive': true, 'language': 'en'});

      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .collection('stats')
          .doc('gamification')
          .set({
        'xp': {
          'totalXp': 250,
          'weeklyXP': 50,
          'todayXp': 20,
          'level': 3,
          'xpToNextLevel': 300,
          'xpBoosterUntil': null,
          'lastWeeklyResetDate': '',
          'lastDailyResetDate': '',
        },
      });

      // Act
      await controller.loadXpAndLevel();

      // Assert
      expect(controller.totalXp.value, 250);
      expect(controller.weeklyXP.value, 50);
      expect(controller.todayXp.value, 20);
      expect(controller.level.value, 3);
      expect(controller.xpToNextLevel.value, 300);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, isEmpty);
    });

    test('cria XP inicial quando documento não existe', () async {
      // Arrange - Criar curso sem stats
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .set({'isActive': true, 'language': 'en'});

      // Act
      await controller.loadXpAndLevel();

      // Assert
      expect(controller.totalXp.value, 0);
      expect(controller.level.value, 1);
      expect(controller.xpToNextLevel.value, 100);
      expect(controller.isLoading.value, false);
    });
  });

  group('XpLevelController - addXp()', () {
    test('adiciona XP e atualiza nível quando necessário', () async {
      // Arrange
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .set({'isActive': true, 'language': 'en'});

      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .collection('stats')
          .doc('gamification')
          .set({
        'xp': {
          'totalXp': 90,
          'weeklyXP': 90,
          'todayXp': 90,
          'level': 1,
          'xpToNextLevel': 100,
          'xpBoosterUntil': null,
          'lastWeeklyResetDate': '',
          'lastDailyResetDate': '',
        },
      });

      // Criar dailyHistory para evitar erro
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .collection('stats')
          .doc('dailyHistory')
          .set({'lastUpdated': FieldValue.serverTimestamp()});

      controller.totalXp.value = 90;
      controller.level.value = 1;
      controller.xpToNextLevel.value = 100;

      // Act - Adicionar 20 XP (total = 110, deve subir para level 2)
      await controller.addXp(20);

      // Assert
      expect(controller.totalXp.value, 110);
      expect(controller.level.value, 2);
      expect(controller.xpToNextLevel.value, 200); // Level 2 * 100
    });

    test('aplica multiplicador 2x quando booster ativo', () async {
      // Arrange
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .set({'isActive': true, 'language': 'en'});

      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
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
      });

      // Criar dailyHistory
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .collection('stats')
          .doc('dailyHistory')
          .set({'lastUpdated': FieldValue.serverTimestamp()});

      controller.totalXp.value = 0;
      controller.setXpBoosterUntil(
        DateTime.now().add(const Duration(hours: 1)),
      );

      // Act - Adicionar 10 XP com booster (deve adicionar 20)
      await controller.addXp(10);

      // Assert
      expect(controller.totalXp.value, 20); // 10 * 2
      expect(controller.weeklyXP.value, 20);
      expect(controller.todayXp.value, 20);
    });

    test('não aceita XP negativo', () async {
      // Arrange
      controller.totalXp.value = 100;

      // Act
      await controller.addXp(-10);

      // Assert - XP não deve mudar quando valor é negativo
      expect(controller.totalXp.value, 100);
    });
  });

  group('XpLevelController - activateXpBooster()', () {
    test('define hasXpBooster como true por 1 hora', () async {
      // Arrange
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .set({'isActive': true, 'language': 'en'});

      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
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
      });

      // Act
      await controller.activateXpBooster(60); // 60 minutos

      // Assert
      expect(controller.hasXpBooster, true);
      expect(controller.getXpBoosterUntil(), isNotNull);
    });
  });

  group('XpLevelController - resetWeeklyXp()', () {
    test('zera weeklyXp no domingo', () async {
      // Arrange
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .set({'isActive': true, 'language': 'en'});

      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .collection('stats')
          .doc('gamification')
          .set({
        'xp': {
          'totalXp': 500,
          'weeklyXP': 100,
          'todayXp': 20,
          'level': 5,
          'xpToNextLevel': 500,
          'xpBoosterUntil': null,
          'lastWeeklyResetDate': '',
          'lastDailyResetDate': '',
        },
      });

      controller.weeklyXP.value = 100;

      // Act
      await controller.resetWeeklyXp();

      // Assert
      expect(controller.weeklyXP.value, 0);
      expect(controller.getLastWeeklyResetDate(), isNotEmpty);
    });
  });

  group('XpLevelController - resetDailyXp()', () {
    test('zera dailyXp à meia-noite', () async {
      // Arrange
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .set({'isActive': true, 'language': 'en'});

      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .collection('stats')
          .doc('gamification')
          .set({
        'xp': {
          'totalXp': 500,
          'weeklyXP': 100,
          'todayXp': 50,
          'level': 5,
          'xpToNextLevel': 500,
          'xpBoosterUntil': null,
          'lastWeeklyResetDate': '',
          'lastDailyResetDate': '',
        },
      });

      controller.todayXp.value = 50;

      // Act
      await controller.resetDailyXp();

      // Assert
      expect(controller.todayXp.value, 0);
      expect(controller.getLastDailyResetDate(), isNotEmpty);
    });
  });
}
