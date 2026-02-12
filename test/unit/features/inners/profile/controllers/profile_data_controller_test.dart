import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:pippo/features/inners/profile/controllers/profile_data_controller.dart';

void main() {
  late ProfileDataController controller;
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late MockUser user;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(signedIn: true);
    user = auth.currentUser as MockUser;
    
    Get.testMode = true;
    
    controller = ProfileDataController(
      firestore: firestore,
      auth: auth,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('ProfileDataController - loadOwnProfile()', () {
    test('carrega perfil do usuário autenticado', () async {
      // Arrange - Criar perfil do usuário
      await firestore.collection('users').doc(user.uid).set({
        'name': 'João Silva',
        'username': 'joaosilva',
        'bio': 'Aprendendo inglês',
        'avatarId': 'avatar_02',
        'country': 'BR',
        'email': 'joao@example.com',
      });

      // Criar curso ativo
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .set({'isActive': true, 'language': 'en'});

      // Criar stats
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
          'level': 5,
        },
        'streak': {
          'currentStreak': 10,
        },
      });

      // Act
      await controller.loadOwnProfile();

      // Assert
      expect(controller.userName.value, 'João Silva');
      expect(controller.username.value, 'joaosilva');
      expect(controller.bio.value, 'Aprendendo inglês');
      expect(controller.avatarId.value, 'avatar_02');
      expect(controller.country.value, 'BR');
      expect(controller.totalXp.value, 500);
      expect(controller.level.value, 5);
      expect(controller.currentStreak.value, 10);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, isEmpty);
    });

    test('retorna erro quando perfil não encontrado', () async {
      // Act
      await controller.loadOwnProfile();

      // Assert
      expect(controller.errorMessage.value, contains('error_profile_not_found'));
    });
  });

  group('ProfileDataController - updateProfile()', () {
    test('atualiza campos do perfil no Firestore', () async {
      // Arrange - Criar perfil inicial
      await firestore.collection('users').doc(user.uid).set({
        'name': 'João Silva',
        'username': 'joaosilva',
        'bio': 'Bio antiga',
        'avatarId': 'avatar_01',
        'country': 'BR',
      });

      controller.userName.value = 'João Silva';
      controller.bio.value = 'Bio antiga';

      // Act
      await controller.updateProfile({
        'name': 'João Pedro Silva',
        'bio': 'Nova bio atualizada',
      });

      // Assert
      expect(controller.userName.value, 'João Pedro Silva');
      expect(controller.bio.value, 'Nova bio atualizada');
      expect(controller.isLoading.value, false);
      
      // Verificar no Firestore
      final doc = await firestore.collection('users').doc(user.uid).get();
      expect(doc.data()?['name'], 'João Pedro Silva');
      expect(doc.data()?['bio'], 'Nova bio atualizada');
    });
  });

  group('ProfileDataController - checkUsernameAvailability()', () {
    test('retorna true quando disponível', () async {
      // Act
      await controller.checkUsernameAvailability('novousuario');

      // Assert
      expect(controller.isUsernameAvailable.value, true);
      expect(controller.isCheckingUsername.value, false);
    });

    test('retorna false quando já existe', () async {
      // Arrange - Criar usuário com username existente
      await firestore.collection('users').doc('other-user').set({
        'username': 'usuarioexistente',
        'name': 'Outro Usuário',
      });

      // Act
      await controller.checkUsernameAvailability('usuarioexistente');

      // Assert
      expect(controller.isUsernameAvailable.value, false);
      expect(controller.isCheckingUsername.value, false);
    });

    test('retorna true quando é o mesmo username atual', () async {
      // Arrange
      controller.username.value = 'meuusername';

      // Act
      await controller.checkUsernameAvailability('meuusername');

      // Assert
      expect(controller.isUsernameAvailable.value, true);
    });
  });
}
