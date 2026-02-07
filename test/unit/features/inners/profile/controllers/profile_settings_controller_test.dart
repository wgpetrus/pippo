import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:pippo/features/inners/profile/controllers/profile_settings_controller.dart';

void main() {
  late ProfileSettingsController controller;
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late MockUser user;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(signedIn: true);
    user = auth.currentUser as MockUser;
    
    Get.testMode = true;
    
    controller = ProfileSettingsController(
      firestore: firestore,
      auth: auth,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('ProfileSettingsController - loadSettings()', () {
    test('carrega configurações do Firestore', () async {
      // Arrange - Criar configurações
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('preferences')
          .set({
        'soundEffects': false,
        'listeningExercises': true,
        'speakingExercises': false,
        'practiceReminders': true,
        'reminderTime': '09:00',
        'leaderboardUpdates': false,
        'friendActivity': true,
        'dailyGoal': 20,
      });

      // Act
      await controller.loadSettings();

      // Assert
      expect(controller.soundEffects.value, false);
      expect(controller.listeningExercises.value, true);
      expect(controller.speakingExercises.value, false);
      expect(controller.practiceReminders.value, true);
      expect(controller.reminderTime.value, '09:00');
      expect(controller.leaderboardUpdates.value, false);
      expect(controller.friendActivity.value, true);
      expect(controller.dailyGoal.value, 20);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, isEmpty);
    });

    test('usa valores padrão quando documento não existe', () async {
      // Act
      await controller.loadSettings();

      // Assert - Valores padrão
      expect(controller.soundEffects.value, true);
      expect(controller.listeningExercises.value, true);
      expect(controller.speakingExercises.value, true);
      expect(controller.practiceReminders.value, false);
      expect(controller.reminderTime.value, '18:00');
      expect(controller.dailyGoal.value, 10);
    });
  });

  group('ProfileSettingsController - updateSetting()', () {
    test('atualiza configuração específica', () async {
      // Arrange - Criar documento inicial
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('preferences')
          .set({
        'soundEffects': true,
        'dailyGoal': 10,
      });

      controller.soundEffects.value = true;

      // Act
      await controller.updateSetting('soundEffects', false);

      // Assert
      expect(controller.soundEffects.value, false);
      
      // Verificar no Firestore
      final doc = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('preferences')
          .get();
      expect(doc.data()?['soundEffects'], false);
    });

    test('valida valores antes de salvar', () async {
      // Arrange
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('preferences')
          .set({'dailyGoal': 10});

      // Act - Atualizar dailyGoal
      await controller.updateSetting('dailyGoal', 30);

      // Assert
      expect(controller.dailyGoal.value, 30);
    });
  });
}
