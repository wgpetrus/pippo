import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'firebase_test_helper.dart';
import 'profile_test_helper.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  const testUserId = 'test-user-123';

  setUp(() async {
    await FirebaseTestHelper.setupFirebase();
    firestore = FirebaseTestHelper.createMockFirestore();
  });

  group('ProfileTestHelper', () {
    test('populateProfileData cria documento de perfil', () async {
      // Act
      final profileData = await ProfileTestHelper.populateProfileData(
        firestore,
        testUserId,
        userName: 'John Doe',
        username: 'johndoe',
        bio: 'Learning languages!',
        avatarId: 5,
        country: 'US',
      );

      // Assert - Verificar retorno
      expect(profileData['userName'], 'John Doe');
      expect(profileData['username'], 'johndoe');
      expect(profileData['bio'], 'Learning languages!');
      expect(profileData['avatarId'], 5);
      expect(profileData['country'], 'US');

      // Assert - Verificar documento no Firestore
      final userDoc = await firestore.collection('users').doc(testUserId).get();

      expect(userDoc.exists, isTrue);
      expect(userDoc.data()?['userName'], 'John Doe');
      expect(userDoc.data()?['username'], 'johndoe');
      expect(userDoc.data()?['bio'], 'Learning languages!');
      expect(userDoc.data()?['avatarId'], 5);
      expect(userDoc.data()?['country'], 'US');
      expect(userDoc.data()?['email'], 'test@example.com');
      expect(userDoc.data()?['createdAt'], isNotNull);
    });

    test('populateProfileData usa valores padrão', () async {
      // Act
      final profileData = await ProfileTestHelper.populateProfileData(
        firestore,
        testUserId,
      );

      // Assert
      expect(profileData['userName'], 'Test User');
      expect(profileData['username'], 'testuser');
      expect(profileData['bio'], 'Test bio');
      expect(profileData['avatarId'], 1);
      expect(profileData['country'], 'BR');
    });

    test('populateSocialData cria documentos de seguindo e seguidores',
        () async {
      // Act
      final counts = await ProfileTestHelper.populateSocialData(
        firestore,
        testUserId,
        ['user2', 'user3', 'user4'],
        followerIds: ['user5', 'user6'],
      );

      // Assert - Verificar contadores
      expect(counts['followingCount'], 3);
      expect(counts['followersCount'], 2);

      // Assert - Verificar documentos de seguindo
      final following = await firestore
          .collection('users')
          .doc(testUserId)
          .collection('following')
          .get();

      expect(following.docs.length, 3);
      expect(following.docs.any((doc) => doc.id == 'user2'), isTrue);
      expect(following.docs.any((doc) => doc.id == 'user3'), isTrue);
      expect(following.docs.any((doc) => doc.id == 'user4'), isTrue);

      // Assert - Verificar documentos de seguidores
      final followers = await firestore
          .collection('users')
          .doc(testUserId)
          .collection('followers')
          .get();

      expect(followers.docs.length, 2);
      expect(followers.docs.any((doc) => doc.id == 'user5'), isTrue);
      expect(followers.docs.any((doc) => doc.id == 'user6'), isTrue);
    });

    test('populateSocialData sem seguidores', () async {
      // Act
      final counts = await ProfileTestHelper.populateSocialData(
        firestore,
        testUserId,
        ['user2', 'user3'],
      );

      // Assert
      expect(counts['followingCount'], 2);
      expect(counts['followersCount'], 0);

      // Assert - Verificar que não há seguidores
      final followers = await firestore
          .collection('users')
          .doc(testUserId)
          .collection('followers')
          .get();

      expect(followers.docs.length, 0);
    });

    test('populateSettings cria documento de configurações', () async {
      // Act
      final settings = await ProfileTestHelper.populateSettings(
        firestore,
        testUserId,
        soundEffects: false,
        listeningExercises: true,
        speakingExercises: false,
        practiceReminders: true,
        reminderTime: '18:00',
        dailyGoal: 50,
      );

      // Assert - Verificar retorno
      expect(settings['soundEffects'], false);
      expect(settings['listeningExercises'], true);
      expect(settings['speakingExercises'], false);
      expect(settings['practiceReminders'], true);
      expect(settings['reminderTime'], '18:00');
      expect(settings['dailyGoal'], 50);

      // Assert - Verificar documento no Firestore
      final settingsDoc = await firestore
          .collection('users')
          .doc(testUserId)
          .collection('settings')
          .doc('preferences')
          .get();

      expect(settingsDoc.exists, isTrue);
      expect(settingsDoc.data()?['soundEffects'], false);
      expect(settingsDoc.data()?['listeningExercises'], true);
      expect(settingsDoc.data()?['speakingExercises'], false);
      expect(settingsDoc.data()?['practiceReminders'], true);
      expect(settingsDoc.data()?['reminderTime'], '18:00');
      expect(settingsDoc.data()?['dailyGoal'], 50);
    });

    test('populateSettings usa valores padrão', () async {
      // Act
      final settings = await ProfileTestHelper.populateSettings(
        firestore,
        testUserId,
      );

      // Assert
      expect(settings['soundEffects'], true);
      expect(settings['listeningExercises'], true);
      expect(settings['speakingExercises'], true);
      expect(settings['practiceReminders'], true);
      expect(settings['reminderTime'], '09:00');
      expect(settings['dailyGoal'], 20);
    });
  });
}
