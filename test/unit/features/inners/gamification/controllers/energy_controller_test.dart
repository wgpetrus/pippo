import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:pippo/features/inners/gamification/controllers/energy_controller.dart';

void main() {
  late EnergyController controller;
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late MockUser user;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(signedIn: true);
    user = auth.currentUser as MockUser;
    
    Get.testMode = true;
    
    controller = EnergyController(
      firestore: firestore,
      auth: auth,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('EnergyController - loadEnergy()', () {
    test('carrega energia do Firestore quando documento existe', () async {
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
        'energy': {
          'currentEnergy': 3,
          'maxEnergy': 5,
          'lastEnergyRegenAt': Timestamp.now(),
          'unlimitedEnergyUntil': null,
        },
      });

      // Act
      await controller.loadEnergy();

      // Assert
      expect(controller.currentEnergy.value, 3);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, isEmpty);
    });

    test('cria energia inicial quando documento não existe', () async {
      // Arrange - Criar curso sem stats
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .set({'isActive': true, 'language': 'en'});

      // Act
      await controller.loadEnergy();

      // Assert
      expect(controller.currentEnergy.value, 5); // Energia máxima inicial
      expect(controller.isLoading.value, false);
    });
  });

  group('EnergyController - consumeEnergy()', () {
    test('deduz 1 energia quando disponível', () async {
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
        'energy': {
          'currentEnergy': 5,
          'maxEnergy': 5,
          'lastEnergyRegenAt': Timestamp.now(),
          'unlimitedEnergyUntil': null,
        },
      });

      controller.currentEnergy.value = 5;

      // Act
      await controller.consumeEnergy(1);

      // Assert
      expect(controller.currentEnergy.value, 4);
    });

    test('retorna false quando energia zero', () async {
      // Arrange
      controller.currentEnergy.value = 0;

      // Act
      await controller.consumeEnergy(1);

      // Assert
      expect(controller.currentEnergy.value, 0); // Não muda
    });

    test('não consome energia quando tem unlimited energy', () async {
      // Arrange
      controller.currentEnergy.value = 3;
      controller.setUnlimitedEnergyUntil(
        DateTime.now().add(const Duration(hours: 1)),
      );

      // Act
      await controller.consumeEnergy(1);

      // Assert
      expect(controller.currentEnergy.value, 3); // Não muda
    });
  });

  group('EnergyController - regenerateEnergy()', () {
    test('adiciona 1 energia a cada 30 minutos', () async {
      // Arrange
      controller.currentEnergy.value = 2;
      controller.setLastEnergyRegenAt(
        DateTime.now().subtract(const Duration(minutes: 30)),
      );

      // Act
      controller.calculateEnergyRegenerationPublic();

      // Assert
      expect(controller.currentEnergy.value, 3);
    });

    test('adiciona múltiplas energias quando passou muito tempo', () async {
      // Arrange
      controller.currentEnergy.value = 1;
      controller.setLastEnergyRegenAt(
        DateTime.now().subtract(const Duration(minutes: 90)),
      );

      // Act
      controller.calculateEnergyRegenerationPublic();

      // Assert
      expect(controller.currentEnergy.value, 4); // 1 + 3 (90min / 30min)
    });

    test('não ultrapassa energia máxima (5)', () async {
      // Arrange
      controller.currentEnergy.value = 3;
      controller.setLastEnergyRegenAt(
        DateTime.now().subtract(const Duration(minutes: 120)),
      );

      // Act
      controller.calculateEnergyRegenerationPublic();

      // Assert
      expect(controller.currentEnergy.value, 5); // Máximo
    });

    test('não regenera quando já está no máximo', () async {
      // Arrange
      controller.currentEnergy.value = 5;
      controller.setLastEnergyRegenAt(
        DateTime.now().subtract(const Duration(minutes: 30)),
      );

      // Act
      controller.calculateEnergyRegenerationPublic();

      // Assert
      expect(controller.currentEnergy.value, 5); // Não muda
    });

    test('não regenera quando tem unlimited energy', () async {
      // Arrange
      controller.currentEnergy.value = 2;
      controller.setUnlimitedEnergyUntil(
        DateTime.now().add(const Duration(hours: 1)),
      );
      controller.setLastEnergyRegenAt(
        DateTime.now().subtract(const Duration(minutes: 30)),
      );

      // Act
      controller.calculateEnergyRegenerationPublic();

      // Assert
      expect(controller.currentEnergy.value, 2); // Não muda
    });
  });

  group('EnergyController - activateUnlimitedEnergy()', () {
    test('define hasUnlimited como true por tempo especificado', () async {
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
        'energy': {
          'currentEnergy': 3,
          'maxEnergy': 5,
          'lastEnergyRegenAt': Timestamp.now(),
          'unlimitedEnergyUntil': null,
        },
      });

      // Act
      await controller.activateUnlimitedEnergy(60); // 60 minutos

      // Assert
      expect(controller.hasUnlimitedEnergy, true);
    });
  });

  group('EnergyController - refillEnergy()', () {
    test('restaura energia para máximo (5)', () async {
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
        'energy': {
          'currentEnergy': 2,
          'maxEnergy': 5,
          'lastEnergyRegenAt': Timestamp.now(),
          'unlimitedEnergyUntil': null,
        },
      });

      controller.currentEnergy.value = 2;

      // Act
      await controller.refillEnergy();

      // Assert
      expect(controller.currentEnergy.value, 5);
      expect(controller.errorMessage.value, isEmpty);
    });

    test('retorna erro quando energia já está no máximo', () async {
      // Arrange
      controller.currentEnergy.value = 5;

      // Act
      await controller.refillEnergy();

      // Assert
      expect(controller.currentEnergy.value, 5);
      expect(controller.errorMessage.value, contains('energia máxima'));
    });
  });
}
