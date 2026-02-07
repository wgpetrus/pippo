import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper class para setup de Firebase em testes
class FirebaseTestHelper {
  /// Inicializa Firebase para testes
  static Future<void> setupFirebase() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Setup Firebase Core mock
    setupFirebaseCoreMocks();
    
    // Inicializar Firebase (se ainda não foi inicializado)
    try {
      await Firebase.initializeApp();
    } catch (e) {
      // Já inicializado, ignorar
    }
  }

  /// Limpa Firebase após testes
  static Future<void> teardownFirebase() async {
    // Cleanup se necessário
  }

  /// Cria um MockFirebaseAuth com usuário logado
  static MockFirebaseAuth createMockAuth({
    bool signedIn = true,
    String uid = 'test-user-id',
    String email = 'test@example.com',
    String displayName = 'Test User',
  }) {
    final user = MockUser(
      isAnonymous: false,
      uid: uid,
      email: email,
      displayName: displayName,
    );

    return MockFirebaseAuth(
      signedIn: signedIn,
      mockUser: user,
    );
  }

  /// Cria um FakeFirebaseFirestore
  static FakeFirebaseFirestore createMockFirestore() {
    return FakeFirebaseFirestore();
  }

  /// Popula Firestore com dados de teste para gamification
  static Future<void> populateGamificationData(
    FakeFirebaseFirestore firestore,
    String userId, {
    int currentEnergy = 5,
    int totalGems = 100,
    int totalXp = 0,
    int currentLevel = 1,
    int currentStreak = 0,
    bool hasXpBooster = false,
    bool hasGemMultiplier = false,
    bool hasUnlimitedEnergy = false,
  }) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc('gamification')
        .set({
      'currentEnergy': currentEnergy,
      'maxEnergy': 5,
      'totalGems': totalGems,
      'totalXp': totalXp,
      'currentLevel': currentLevel,
      'currentStreak': currentStreak,
      'hasXpBooster': hasXpBooster,
      'hasGemMultiplier': hasGemMultiplier,
      'hasUnlimitedEnergy': hasUnlimitedEnergy,
      'lastEnergyUpdate': FieldValue.serverTimestamp(),
      'lastStreakUpdate': FieldValue.serverTimestamp(),
    });
  }

  /// Popula Firestore com dados de perfil
  static Future<void> populateProfileData(
    FakeFirebaseFirestore firestore,
    String userId, {
    String userName = 'Test User',
    String username = 'testuser',
    String bio = 'Test bio',
    int avatarId = 1,
    String country = 'BR',
    String email = 'test@example.com',
  }) async {
    await firestore.collection('users').doc(userId).set({
      'userName': userName,
      'username': username,
      'bio': bio,
      'avatarId': avatarId,
      'country': country,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Popula dados sociais (seguindo/seguidores)
  static Future<void> populateSocialData(
    FakeFirebaseFirestore firestore,
    String userId,
    List<String> following,
    List<String> followers,
  ) async {
    // Adiciona seguindo
    for (final targetId in following) {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('following')
          .doc(targetId)
          .set({'followedAt': FieldValue.serverTimestamp()});
    }

    // Adiciona seguidores
    for (final followerId in followers) {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('followers')
          .doc(followerId)
          .set({'followedAt': FieldValue.serverTimestamp()});
    }
  }

  /// Popula configurações de perfil
  static Future<void> populateSettings(
    FakeFirebaseFirestore firestore,
    String userId, {
    bool soundEffects = true,
    bool listeningExercises = true,
    bool speakingExercises = true,
    bool practiceReminders = true,
    String reminderTime = '09:00',
    int dailyGoal = 20,
  }) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('preferences')
        .set({
      'soundEffects': soundEffects,
      'listeningExercises': listeningExercises,
      'speakingExercises': speakingExercises,
      'practiceReminders': practiceReminders,
      'reminderTime': reminderTime,
      'dailyGoal': dailyGoal,
    });
  }

  /// Popula Firestore com itens da loja
  static Future<void> populateShopItems(
    FakeFirebaseFirestore firestore,
  ) async {
    await firestore.collection('shopItems').doc('energy_refill').set({
      'name': 'Energy Refill',
      'cost': 50,
      'type': 'boost',
    });

    await firestore.collection('shopItems').doc('xp_booster').set({
      'name': 'XP Booster',
      'cost': 150,
      'type': 'boost',
    });

    await firestore.collection('shopItems').doc('gem_multiplier').set({
      'name': 'Gem Multiplier',
      'cost': 200,
      'type': 'boost',
    });

    await firestore.collection('shopItems').doc('streak_freeze').set({
      'name': 'Streak Freeze',
      'cost': 100,
      'type': 'boost',
    });
  }
}

/// Setup Firebase Core mocks
void setupFirebaseCoreMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_core',
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    if (methodCall.method == 'Firebase#initializeCore') {
      return [
        {
          'name': '[DEFAULT]',
          'options': {
            'apiKey': 'test-api-key',
            'appId': 'test-app-id',
            'messagingSenderId': 'test-sender-id',
            'projectId': 'test-project-id',
          },
          'pluginConstants': {},
        }
      ];
    }
    if (methodCall.method == 'Firebase#initializeApp') {
      return {
        'name': methodCall.arguments['appName'],
        'options': methodCall.arguments['options'],
        'pluginConstants': {},
      };
    }
    return null;
  });
}
