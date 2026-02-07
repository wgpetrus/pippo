import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:pippo/features/inners/gamification/controllers/streak_controller.dart';

void main() {
  late StreakController controller;
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late MockUser user;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(signedIn: true);
    user = auth.currentUser as MockUser;
    
    Get.testMode = true;
    
    controller = StreakController(
      firestore: firestore,
      auth: auth,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('StreakController - loadStreak()', () {
    test('carrega streak do Firestore quando documento existe', () async {
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
        'streak': {
          'currentStreak': 5,
          'longestStreak': 10,
          'lastStreakDate': '2024-01-15',
          'streakFreezeAvailable': true,
          'streakFreezeUsedToday': false,
          'milestonesReached': [7],
        },
      });

      // Act
      await controller.loadStreak();

      // Assert
      expect(controller.currentStreak.value, 5);
      expect(controller.longestStreak.value, 10);
      expect(controller.getLastStreakDate(), '2024-01-15');
      expect(controller.getStreakFreezeAvailable(), true);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, isEmpty);
    });

    test('cria streak inicial quando documento não existe', () async {
      // Arrange - Criar curso sem stats
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .set({'isActive': true, 'language': 'en'});

      // Act
      await controller.loadStreak();

      // Assert
      expect(controller.currentStreak.value, 0);
      expect(controller.longestStreak.value, 0);
      expect(controller.isLoading.value, false);
    });
  });

  group('StreakController - updateStreak()', () {
    test('incrementa streak quando dia consecutivo', () async {
      // Arrange
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayStr = controller.formatDateForStreakPublic(yesterday);
      
      controller.currentStreak.value = 3;
      controller.longestStreak.value = 5;
      controller.setLastStreakDate(yesterdayStr);

      // Act
      controller.updateStreakPublic();

      // Assert
      expect(controller.currentStreak.value, 4);
      expect(controller.longestStreak.value, 5);
    });

    test('atualiza longestStreak quando currentStreak ultrapassa', () async {
      // Arrange
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayStr = controller.formatDateForStreakPublic(yesterday);
      
      controller.currentStreak.value = 5;
      controller.longestStreak.value = 5;
      controller.setLastStreakDate(yesterdayStr);

      // Act
      controller.updateStreakPublic();

      // Assert
      expect(controller.currentStreak.value, 6);
      expect(controller.longestStreak.value, 6);
    });

    test('reseta streak quando dia perdido (sem freeze)', () async {
      // Arrange
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final twoDaysAgoStr = controller.formatDateForStreakPublic(twoDaysAgo);
      
      controller.currentStreak.value = 5;
      controller.longestStreak.value = 10;
      controller.setLastStreakDate(twoDaysAgoStr);
      controller.setStreakFreezeAvailable(false);

      // Act
      controller.updateStreakPublic();

      // Assert
      expect(controller.currentStreak.value, 1);
      expect(controller.longestStreak.value, 10); // Não muda
    });

    test('mantém streak quando dia perdido mas tem freeze disponível', () async {
      // Arrange
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final twoDaysAgoStr = controller.formatDateForStreakPublic(twoDaysAgo);
      
      controller.currentStreak.value = 5;
      controller.longestStreak.value = 10;
      controller.setLastStreakDate(twoDaysAgoStr);
      controller.setStreakFreezeAvailable(true);

      // Act
      controller.updateStreakPublic();

      // Assert
      expect(controller.currentStreak.value, 5); // Mantém
      expect(controller.getStreakFreezeAvailable(), false); // Consome freeze
      expect(controller.getStreakFreezeUsedToday(), true);
    });

    test('não altera streak quando já praticou hoje', () async {
      // Arrange
      final today = DateTime.now();
      final todayStr = controller.formatDateForStreakPublic(today);
      
      controller.currentStreak.value = 5;
      controller.longestStreak.value = 10;
      controller.setLastStreakDate(todayStr);

      // Act
      controller.updateStreakPublic();

      // Assert
      expect(controller.currentStreak.value, 5); // Não muda
      expect(controller.longestStreak.value, 10); // Não muda
    });
  });

  group('StreakController - useStreakFreeze()', () {
    test('consome freeze quando disponível', () async {
      // Arrange - Criar curso e documento de stats
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
        'streak': {
          'currentStreak': 5,
          'longestStreak': 5,
          'lastStreakDate': '2024-01-15',
          'streakFreezeAvailable': true,
          'streakFreezeUsedToday': false,
          'milestonesReached': [],
        },
      });

      controller.setStreakFreezeAvailable(true);
      controller.setStreakFreezeUsedToday(false);

      // Act
      await controller.useStreakFreeze();

      // Assert
      expect(controller.getStreakFreezeAvailable(), false);
      expect(controller.getStreakFreezeUsedToday(), true);
      expect(controller.errorMessage.value, isEmpty);
    });

    test('retorna erro quando freeze não disponível', () async {
      // Arrange
      controller.setStreakFreezeAvailable(false);

      // Act
      await controller.useStreakFreeze();

      // Assert
      expect(controller.errorMessage.value, contains('não tem streak freeze'));
    });

    test('retorna erro quando freeze já usado hoje', () async {
      // Arrange
      controller.setStreakFreezeAvailable(true);
      controller.setStreakFreezeUsedToday(true);

      // Act
      await controller.useStreakFreeze();

      // Assert
      expect(controller.errorMessage.value, contains('já usou o streak freeze'));
    });
  });

  group('StreakController - checkStreakMilestone()', () {
    test('retorna true para múltiplos de 7', () async {
      // Arrange
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .set({'isActive': true, 'language': 'en'});

      controller.currentStreak.value = 7;
      controller.setMilestonesReached([]);

      // Act
      await controller.checkStreakMilestone();

      // Assert
      expect(controller.getMilestonesReached(), contains(7));
    });

    test('não adiciona milestone duplicado', () async {
      // Arrange
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .set({'isActive': true, 'language': 'en'});

      controller.currentStreak.value = 7;
      controller.setMilestonesReached([7]);

      // Act
      await controller.checkStreakMilestone();

      // Assert
      expect(controller.getMilestonesReached().where((m) => m == 7).length, 1);
    });

    test('adiciona múltiplos milestones conforme streak aumenta', () async {
      // Arrange
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .set({'isActive': true, 'language': 'en'});

      controller.setMilestonesReached([]);

      // Act - Testar milestone 7
      controller.currentStreak.value = 7;
      await controller.checkStreakMilestone();
      
      // Act - Testar milestone 14
      controller.currentStreak.value = 14;
      await controller.checkStreakMilestone();

      // Assert
      expect(controller.getMilestonesReached(), containsAll([7, 14]));
    });
  });
}
