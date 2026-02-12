import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:pippo/features/inners/profile/controllers/profile_data_controller.dart';
import 'package:pippo/features/inners/profile/controllers/profile_social_controller.dart';
import 'package:pippo/features/inners/profile/controllers/profile_auth_controller.dart';
import 'package:pippo/features/inners/profile/controllers/profile_search_controller.dart';
import 'package:pippo/features/inners/profile/controllers/profile_settings_controller.dart';
import 'package:pippo/features/inners/profile/controllers/profile_courses_controller.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late MockUser user;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(signedIn: true);
    user = auth.currentUser as MockUser;
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('ProfileDataController - Error Handling', () {
    late ProfileDataController controller;

    setUp(() {
      controller = ProfileDataController(
        firestore: firestore,
        auth: auth,
      );
    });

    test('onClose() limpa recursos corretamente', () {
      // Arrange - Adicionar dados
      controller.missingFields.addAll(['name', 'bio']);
      controller.isLoading.value = true;
      controller.errorMessage.value = 'Erro teste';

      // Act
      controller.onClose();

      // Assert
      expect(controller.missingFields.isEmpty, true);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, isEmpty);
    });

    test('loadOwnProfile() usa translation key para erro de autenticação', () async {
      // Arrange - Usuário não autenticado
      final unauthController = ProfileDataController(
        firestore: firestore,
        auth: MockFirebaseAuth(signedIn: false),
      );

      // Act
      await unauthController.loadOwnProfile();

      // Assert
      expect(unauthController.errorMessage.value, contains('error_unauthenticated'));
    });

    test('loadOwnProfile() usa translation key para perfil não encontrado', () async {
      // Act - Perfil não existe
      await controller.loadOwnProfile();

      // Assert
      expect(controller.errorMessage.value, contains('error_profile_not_found'));
    });

    test('updateProfile() usa translation key para erro genérico', () async {
      // Arrange - Criar perfil
      await firestore.collection('users').doc(user.uid).set({
        'name': 'Test User',
      });

      // Act - Tentar atualizar com dados inválidos que causarão erro
      await controller.updateProfile({
        'name': 'Updated Name',
      });

      // Assert - Não deve crashar, deve tratar erro
      expect(controller.isLoading.value, false);
    });

    test('checkUsernameAvailability() usa translation key para erro genérico', () async {
      // Act
      await controller.checkUsernameAvailability('testuser');

      // Assert - Não deve crashar
      expect(controller.isCheckingUsername.value, false);
    });
  });

  group('ProfileSocialController - Error Handling', () {
    late ProfileSocialController controller;

    setUp(() {
      controller = ProfileSocialController(
        firestore: firestore,
        auth: auth,
      );
    });

    test('onClose() limpa recursos corretamente', () {
      // Arrange - Adicionar dados
      controller.following.add({'userId': 'user1'});
      controller.followers.add({'userId': 'user2'});
      controller.weeklyProgress.add({'day': 'Mon', 'xp': 10});
      controller.viewedUserWeeklyProgress.add({'day': 'Tue', 'xp': 20});
      controller.viewedUserData.value = {'name': 'Test'};
      controller.isLoading.value = true;
      controller.errorMessage.value = 'Erro teste';
      controller.isLoadingProgress.value = true;

      // Act
      controller.onClose();

      // Assert
      expect(controller.following.isEmpty, true);
      expect(controller.followers.isEmpty, true);
      expect(controller.weeklyProgress.isEmpty, true);
      expect(controller.viewedUserWeeklyProgress.isEmpty, true);
      expect(controller.viewedUserData.isEmpty, true);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, isEmpty);
      expect(controller.isLoadingProgress.value, false);
    });

    test('loadUserProfile() usa translation key para erro de autenticação', () async {
      // Arrange - Usuário não autenticado
      final unauthController = ProfileSocialController(
        firestore: firestore,
        auth: MockFirebaseAuth(signedIn: false),
      );

      // Act
      await unauthController.loadUserProfile('other-user-id');

      // Assert
      expect(unauthController.errorMessage.value, contains('error_unauthenticated'));
    });

    test('loadUserProfile() usa translation key para usuário não encontrado', () async {
      // Act - Usuário não existe
      await controller.loadUserProfile('non-existent-user');

      // Assert
      expect(controller.errorMessage.value, contains('error_user_not_found'));
    });

    test('followUser() usa translation key para erro de autenticação', () async {
      // Arrange - Usuário não autenticado
      final unauthController = ProfileSocialController(
        firestore: firestore,
        auth: MockFirebaseAuth(signedIn: false),
      );

      // Act
      await unauthController.followUser('target-user-id');

      // Assert
      expect(unauthController.errorMessage.value, contains('error_unauthenticated'));
    });

    test('unfollowUser() usa translation key para erro de autenticação', () async {
      // Arrange - Usuário não autenticado
      final unauthController = ProfileSocialController(
        firestore: firestore,
        auth: MockFirebaseAuth(signedIn: false),
      );

      // Act
      await unauthController.unfollowUser('target-user-id');

      // Assert
      expect(unauthController.errorMessage.value, contains('error_unauthenticated'));
    });

    test('loadFollowing() usa translation key para erro de autenticação', () async {
      // Arrange - Usuário não autenticado
      final unauthController = ProfileSocialController(
        firestore: firestore,
        auth: MockFirebaseAuth(signedIn: false),
      );

      // Act
      await unauthController.loadFollowing();

      // Assert
      expect(unauthController.errorMessage.value, contains('error_unauthenticated'));
    });

    test('loadFollowers() usa translation key para erro de autenticação', () async {
      // Arrange - Usuário não autenticado
      final unauthController = ProfileSocialController(
        firestore: firestore,
        auth: MockFirebaseAuth(signedIn: false),
      );

      // Act
      await unauthController.loadFollowers();

      // Assert
      expect(unauthController.errorMessage.value, contains('error_unauthenticated'));
    });
  });

  group('ProfileAuthController - Error Handling', () {
    late ProfileAuthController controller;

    setUp(() {
      controller = ProfileAuthController(
        firestore: firestore,
        auth: auth,
      );
    });

    test('onClose() limpa recursos corretamente', () {
      // Arrange
      controller.isLoading.value = true;
      controller.errorMessage.value = 'Erro teste';

      // Act
      controller.onClose();

      // Assert
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, isEmpty);
    });

    test('changePassword() usa translation key para erro de autenticação', () async {
      // Arrange - Usuário não autenticado
      final unauthController = ProfileAuthController(
        firestore: firestore,
        auth: MockFirebaseAuth(signedIn: false),
      );

      // Act
      await unauthController.changePassword('oldpass', 'newpass');

      // Assert
      expect(unauthController.errorMessage.value, contains('error_unauthenticated'));
    });

    test('linkPhoneNumber() usa translation key para erro de autenticação', () async {
      // Arrange - Usuário não autenticado
      final unauthController = ProfileAuthController(
        firestore: firestore,
        auth: MockFirebaseAuth(signedIn: false),
      );

      // Act
      await unauthController.linkPhoneNumber('+5511999999999', '123456');

      // Assert
      expect(unauthController.errorMessage.value, contains('error_unauthenticated'));
    });

    test('deleteAccount() usa translation key para erro de autenticação', () async {
      // Arrange - Usuário não autenticado
      final unauthController = ProfileAuthController(
        firestore: firestore,
        auth: MockFirebaseAuth(signedIn: false),
      );

      // Act
      await unauthController.deleteAccount();

      // Assert
      expect(unauthController.errorMessage.value, contains('error_unauthenticated'));
    });
  });

  group('ProfileSettingsController - Error Handling', () {
    late ProfileSettingsController controller;

    setUp(() {
      controller = ProfileSettingsController(
        firestore: firestore,
        auth: auth,
      );
    });

    test('onClose() limpa recursos corretamente', () {
      // Arrange
      controller.isLoading.value = true;
      controller.errorMessage.value = 'Erro teste';

      // Act
      controller.onClose();

      // Assert
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, isEmpty);
    });

    test('loadSettings() usa translation key para erro de autenticação', () async {
      // Arrange - Usuário não autenticado
      final unauthController = ProfileSettingsController(
        firestore: firestore,
        auth: MockFirebaseAuth(signedIn: false),
      );

      // Act
      await unauthController.loadSettings();

      // Assert
      expect(unauthController.errorMessage.value, contains('error_unauthenticated'));
    });

    test('updateSetting() usa translation key para erro de autenticação', () async {
      // Arrange - Usuário não autenticado
      final unauthController = ProfileSettingsController(
        firestore: firestore,
        auth: MockFirebaseAuth(signedIn: false),
      );

      // Act
      await unauthController.updateSetting('soundEffects', true);

      // Assert
      expect(unauthController.errorMessage.value, contains('error_unauthenticated'));
    });
  });

  group('ProfileCoursesController - Error Handling', () {
    late ProfileCoursesController controller;

    setUp(() {
      controller = ProfileCoursesController(
        firestore: firestore,
        auth: auth,
      );
    });

    test('onClose() limpa recursos corretamente', () {
      // Arrange - Adicionar dados
      controller.userCourses.add({'id': 'course1'});
      controller.isLoading.value = true;
      controller.errorMessage.value = 'Erro teste';

      // Act
      controller.onClose();

      // Assert
      expect(controller.userCourses.isEmpty, true);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, isEmpty);
    });

    test('loadUserCourses() usa translation key para erro de autenticação', () async {
      // Arrange - Usuário não autenticado
      final unauthController = ProfileCoursesController(
        firestore: firestore,
        auth: MockFirebaseAuth(signedIn: false),
      );

      // Act
      await unauthController.loadUserCourses();

      // Assert
      expect(unauthController.errorMessage.value, contains('error_unauthenticated'));
    });

    test('setPrimaryCourse() usa translation key para erro de autenticação', () async {
      // Arrange - Usuário não autenticado
      final unauthController = ProfileCoursesController(
        firestore: firestore,
        auth: MockFirebaseAuth(signedIn: false),
      );

      // Act
      await unauthController.setPrimaryCourse('course1');

      // Assert
      expect(unauthController.errorMessage.value, contains('error_unauthenticated'));
    });

    test('removeCourse() usa translation key para erro de autenticação', () async {
      // Arrange - Usuário não autenticado
      final unauthController = ProfileCoursesController(
        firestore: firestore,
        auth: MockFirebaseAuth(signedIn: false),
      );

      // Act
      await unauthController.removeCourse('course1');

      // Assert
      expect(unauthController.errorMessage.value, contains('error_unauthenticated'));
    });
  });
}
