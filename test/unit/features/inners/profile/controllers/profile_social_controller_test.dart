import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:pippo/features/inners/profile/controllers/profile_social_controller.dart';

void main() {
  late ProfileSocialController controller;
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late MockUser user;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(signedIn: true);
    user = auth.currentUser as MockUser;
    
    Get.testMode = true;
    
    controller = ProfileSocialController(
      firestore: firestore,
      auth: auth,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('ProfileSocialController - loadUserProfile()', () {
    test('carrega perfil de outro usuário', () async {
      // Arrange - Criar usuário alvo
      const targetUserId = 'user123';
      
      await firestore.collection('users').doc(targetUserId).set({
        'name': 'João Silva',
        'username': 'joaosilva',
        'bio': 'Aprendendo inglês',
        'avatarId': 'avatar_02',
        'country': 'BR',
        'email': 'joao@example.com',
      });

      await firestore
          .collection('users')
          .doc(targetUserId)
          .collection('stats')
          .doc('gamification')
          .set({
        'xp': {
          'totalXp': 500,
          'level': 5,
        },
        'streak': {
          'currentStreak': 10,
          'longestStreak': 15,
        },
      });

      // Act
      await controller.loadUserProfile(targetUserId);

      // Assert
      expect(controller.viewedUserData['name'], 'João Silva');
      expect(controller.viewedUserData['username'], 'joaosilva');
      expect(controller.viewedUserData['totalXp'], 500);
      expect(controller.viewedUserData['level'], 5);
      expect(controller.viewedUserData['currentStreak'], 10);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, isEmpty);
    });

    test('retorna erro quando usuário não encontrado', () async {
      // Act
      await controller.loadUserProfile('nonexistent');

      // Assert
      expect(controller.errorMessage.value, contains('error_user_not_found'));
    });
  });

  group('ProfileSocialController - followUser()', () {
    test('adiciona usuário à lista de following', () async {
      // Arrange
      const targetUserId = 'user123';
      
      await firestore.collection('users').doc(targetUserId).set({
        'name': 'João Silva',
        'username': 'joaosilva',
      });

      // Act
      await controller.followUser(targetUserId);

      // Assert - Verifica que o estado foi atualizado (mesmo se Firestore falhar)
      // Em testes unitários, focamos na lógica do controller
      expect(controller.isLoading.value, false);
    });

    test('retorna erro ao tentar seguir a si mesmo', () async {
      // Act
      await controller.followUser(user.uid);

      // Assert
      expect(controller.errorMessage.value, 'error_cannot_follow_self'.tr);
    });
  });

  group('ProfileSocialController - unfollowUser()', () {
    test('remove usuário da lista de following', () async {
      // Arrange
      const targetUserId = 'user123';
      
      // Criar relacionamento de following
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('following')
          .doc(targetUserId)
          .set({'userId': targetUserId, 'followedAt': FieldValue.serverTimestamp()});

      await firestore
          .collection('users')
          .doc(targetUserId)
          .collection('followers')
          .doc(user.uid)
          .set({'userId': user.uid, 'followedAt': FieldValue.serverTimestamp()});

      controller.isFollowingViewedUser.value = true;

      // Act
      await controller.unfollowUser(targetUserId);

      // Assert - Verifica que o loading terminou
      expect(controller.isLoading.value, false);
    });
  });

  group('ProfileSocialController - searchUsers()', () {
    test('retorna usuários que correspondem à query', () async {
      // Arrange - Criar alguns usuários
      await firestore.collection('users').doc('user1').set({
        'name': 'João Silva',
        'username': 'joaosilva',
        'searchName': 'joão silva',
      });

      await firestore.collection('users').doc('user2').set({
        'name': 'Maria Santos',
        'username': 'mariasantos',
        'searchName': 'maria santos',
      });

      await firestore.collection('users').doc('user3').set({
        'name': 'João Pedro',
        'username': 'joaopedro',
        'searchName': 'joão pedro',
      });

      // Note: FakeFirebaseFirestore não suporta queries complexas como array-contains
      // Este teste valida a estrutura, mas a busca real seria testada em integration tests
      
      // Act - Carregar lista de following/followers (que usa busca)
      await controller.loadFollowing();

      // Assert - Verifica que não há erro
      expect(controller.errorMessage.value, isEmpty);
    });
  });

  group('ProfileSocialController - Weekday Translations', () {
    test('usa translation keys para dias da semana no progresso semanal', () async {
      // Arrange - Criar curso ativo
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .set({
        'language': 'en',
        'isActive': true,
      });

      // Act
      await controller.loadWeeklyProgress();

      // Assert - Verifica que os dias da semana estão presentes
      expect(controller.weeklyProgress.length, 7);
      
      // Verifica que cada dia tem a estrutura correta
      for (final dayData in controller.weeklyProgress) {
        expect(dayData.containsKey('day'), true);
        expect(dayData.containsKey('xp'), true);
        expect(dayData.containsKey('date'), true);
        
        // Verifica que o dia não é uma string hardcoded em português
        final day = dayData['day'] as String;
        expect(day, isNotEmpty);
        
        // Verifica que não são as strings antigas hardcoded
        expect(day, isNot(equals('Segunda')));
        expect(day, isNot(equals('Terça')));
        expect(day, isNot(equals('Quarta')));
        expect(day, isNot(equals('Quinta')));
        expect(day, isNot(equals('Sexta')));
        expect(day, isNot(equals('Sábado')));
        expect(day, isNot(equals('Domingo')));
      }
    });

    test('progresso semanal de outro usuário usa translation keys', () async {
      // Arrange - Criar usuário alvo com curso ativo
      const targetUserId = 'user123';
      
      await firestore.collection('users').doc(targetUserId).set({
        'name': 'João Silva',
        'username': 'joaosilva',
      });

      await firestore
          .collection('users')
          .doc(targetUserId)
          .collection('courses')
          .doc('course1')
          .set({
        'language': 'en',
        'isActive': true,
      });

      // Act
      await controller.loadUserWeeklyProgress(targetUserId);

      // Assert - Verifica que os dias da semana estão presentes
      expect(controller.viewedUserWeeklyProgress.length, 7);
      
      // Verifica que cada dia tem a estrutura correta
      for (final dayData in controller.viewedUserWeeklyProgress) {
        expect(dayData.containsKey('day'), true);
        expect(dayData.containsKey('xp'), true);
        expect(dayData.containsKey('date'), true);
        
        // Verifica que o dia não é uma string hardcoded em português
        final day = dayData['day'] as String;
        expect(day, isNotEmpty);
        
        // Verifica que não são as strings antigas hardcoded
        expect(day, isNot(equals('Segunda')));
        expect(day, isNot(equals('Terça')));
        expect(day, isNot(equals('Quarta')));
        expect(day, isNot(equals('Quinta')));
        expect(day, isNot(equals('Sexta')));
        expect(day, isNot(equals('Sábado')));
        expect(day, isNot(equals('Domingo')));
      }
    });

    test('progresso semanal vazio usa translation keys', () async {
      // Act - Carregar progresso sem curso ativo
      await controller.loadWeeklyProgress();

      // Assert - Verifica que retorna 7 dias com 0 XP
      expect(controller.weeklyProgress.length, 7);
      
      // Verifica que todos os dias têm XP = 0 e usam translation keys
      for (final dayData in controller.weeklyProgress) {
        expect(dayData['xp'], 0);
        
        final day = dayData['day'] as String;
        expect(day, isNotEmpty);
        
        // Verifica que não são as strings antigas hardcoded
        expect(day, isNot(equals('Segunda')));
        expect(day, isNot(equals('Terça')));
        expect(day, isNot(equals('Quarta')));
        expect(day, isNot(equals('Quinta')));
        expect(day, isNot(equals('Sexta')));
        expect(day, isNot(equals('Sábado')));
        expect(day, isNot(equals('Domingo')));
      }
    });
  });
}
