import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

/// Helper para popular dados de teste relacionados ao Profile
/// 
/// Uso:
/// ```dart
/// await ProfileTestHelper.populateProfileData(firestore, userId);
/// await ProfileTestHelper.populateSocialData(firestore, userId, ['user2', 'user3']);
/// await ProfileTestHelper.populateSettings(firestore, userId);
/// ```
class ProfileTestHelper {
  /// Popula Firestore com dados de perfil do usuário
  /// 
  /// Cria documento em users/{userId} com campos:
  /// - userName: nome completo
  /// - username: nome de usuário único
  /// - bio: biografia
  /// - avatarId: ID do avatar
  /// - country: código do país
  /// 
  /// Retorna Map com os valores populados
  static Future<Map<String, dynamic>> populateProfileData(
    FakeFirebaseFirestore firestore,
    String userId, {
    String userName = 'Test User',
    String username = 'testuser',
    String bio = 'Test bio',
    int avatarId = 1,
    String country = 'BR',
  }) async {
    final profileData = {
      'userName': userName,
      'username': username,
      'bio': bio,
      'avatarId': avatarId,
      'country': country,
      'email': 'test@example.com',
      'createdAt': FieldValue.serverTimestamp(),
    };

    await firestore.collection('users').doc(userId).set(profileData);

    return profileData;
  }

  /// Popula Firestore com dados sociais (seguindo/seguidores)
  /// 
  /// Cria:
  /// - Documentos em users/{userId}/following para cada usuário seguido
  /// - Documentos em users/{userId}/followers para cada seguidor
  /// 
  /// Retorna Map com contadores:
  /// - followingCount: número de usuários seguidos
  /// - followersCount: número de seguidores
  static Future<Map<String, int>> populateSocialData(
    FakeFirebaseFirestore firestore,
    String userId,
    List<String> followingIds, {
    List<String>? followerIds,
  }) async {
    // Popular lista de seguindo
    for (final targetId in followingIds) {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('following')
          .doc(targetId)
          .set({
        'followedAt': FieldValue.serverTimestamp(),
      });
    }

    // Popular lista de seguidores
    final followers = followerIds ?? [];
    for (final followerId in followers) {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('followers')
          .doc(followerId)
          .set({
        'followedAt': FieldValue.serverTimestamp(),
      });
    }

    return {
      'followingCount': followingIds.length,
      'followersCount': followers.length,
    };
  }

  /// Popula Firestore com configurações do usuário
  /// 
  /// Cria documento em users/{userId}/settings/preferences com:
  /// - soundEffects: efeitos sonoros habilitados
  /// - listeningExercises: exercícios de escuta habilitados
  /// - speakingExercises: exercícios de fala habilitados
  /// - practiceReminders: lembretes de prática habilitados
  /// - reminderTime: horário do lembrete
  /// - dailyGoal: meta diária de XP
  /// 
  /// Retorna Map com as configurações
  static Future<Map<String, dynamic>> populateSettings(
    FakeFirebaseFirestore firestore,
    String userId, {
    bool soundEffects = true,
    bool listeningExercises = true,
    bool speakingExercises = true,
    bool practiceReminders = true,
    String reminderTime = '09:00',
    int dailyGoal = 20,
  }) async {
    final settings = {
      'soundEffects': soundEffects,
      'listeningExercises': listeningExercises,
      'speakingExercises': speakingExercises,
      'practiceReminders': practiceReminders,
      'reminderTime': reminderTime,
      'dailyGoal': dailyGoal,
    };

    await firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('preferences')
        .set(settings);

    return settings;
  }
}
