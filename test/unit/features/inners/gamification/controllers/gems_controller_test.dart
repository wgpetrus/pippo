import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:pippo/features/inners/gamification/controllers/gems_controller.dart';

void main() {
  late GemsController controller;
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late MockUser user;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(signedIn: true);
    user = auth.currentUser as MockUser;
    
    Get.testMode = true;
    
    controller = GemsController(
      firestore: firestore,
      auth: auth,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('GemsController - loadGems()', () {
    test('carrega gems do Firestore quando documento existe', () async {
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
        'gems': {
          'gems': 150,
          'totalGemsEarned': 200,
          'totalGemsSpent': 50,
          'gemMultiplierUntil': null,
        },
      });

      // Act
      await controller.loadGems();

      // Assert
      expect(controller.gems.value, 150);
      expect(controller.totalGemsEarned.value, 200);
      expect(controller.totalGemsSpent.value, 50);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, isEmpty);
    });

    test('cria gems iniciais quando documento não existe', () async {
      // Arrange - Criar curso sem stats
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .set({'isActive': true, 'language': 'en'});

      // Act
      await controller.loadGems();

      // Assert
      expect(controller.gems.value, 0);
      expect(controller.totalGemsEarned.value, 0);
      expect(controller.totalGemsSpent.value, 0);
      expect(controller.isLoading.value, false);
    });
  });

  group('GemsController - addGems()', () {
    test('adiciona gems ao saldo', () async {
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
        'gems': {
          'gems': 100,
          'totalGemsEarned': 100,
          'totalGemsSpent': 0,
          'gemMultiplierUntil': null,
        },
      });

      controller.gems.value = 100;
      controller.totalGemsEarned.value = 100;

      // Act
      await controller.addGems(50);

      // Assert
      expect(controller.gems.value, 150);
      expect(controller.totalGemsEarned.value, 150);
    });

    test('aplica multiplicador 2x quando ativo', () async {
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
        'gems': {
          'gems': 100,
          'totalGemsEarned': 100,
          'totalGemsSpent': 0,
          'gemMultiplierUntil': null,
        },
      });

      controller.gems.value = 100;
      controller.totalGemsEarned.value = 100;
      controller.setGemMultiplierUntil(
        DateTime.now().add(const Duration(hours: 1)),
      );

      // Act - Adicionar 10 gems com multiplicador (deve adicionar 20)
      await controller.addGems(10);

      // Assert
      expect(controller.gems.value, 120); // 100 + (10 * 2)
      expect(controller.totalGemsEarned.value, 120);
    });

    test('não aceita gems negativas', () async {
      // Arrange
      controller.gems.value = 100;

      // Act & Assert
      expect(() => controller.addGems(-10), throwsException);
    });
  });

  group('GemsController - spendGems()', () {
    test('deduz gems quando saldo suficiente', () async {
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
        'gems': {
          'gems': 100,
          'totalGemsEarned': 100,
          'totalGemsSpent': 0,
          'gemMultiplierUntil': null,
        },
      });

      controller.gems.value = 100;
      controller.totalGemsSpent.value = 0;

      // Act
      await controller.spendGems(30);

      // Assert
      expect(controller.gems.value, 70);
      expect(controller.totalGemsSpent.value, 30);
      expect(controller.errorMessage.value, isEmpty);
    });

    test('retorna false quando saldo insuficiente', () async {
      // Arrange
      controller.gems.value = 20;

      // Act
      await controller.spendGems(50);

      // Assert
      expect(controller.gems.value, 20); // Não muda
      expect(controller.errorMessage.value, contains('gemas a mais'));
    });
  });

  group('GemsController - activateGemMultiplier()', () {
    test('define hasGemMultiplier como true por 1 hora', () async {
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
        'gems': {
          'gems': 100,
          'totalGemsEarned': 100,
          'totalGemsSpent': 0,
          'gemMultiplierUntil': null,
        },
      });

      // Act
      await controller.activateGemMultiplier(60); // 60 minutos

      // Assert
      expect(controller.hasGemMultiplier, true);
      expect(controller.getGemMultiplierUntil(), isNotNull);
    });
  });
}
