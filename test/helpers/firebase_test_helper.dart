import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper para setup de Firebase em testes
/// 
/// Uso:
/// ```dart
/// setUp(() async {
///   await FirebaseTestHelper.setupFirebase();
/// });
/// 
/// tearDown(() async {
///   await FirebaseTestHelper.teardownFirebase();
/// });
/// ```
class FirebaseTestHelper {
  static bool _initialized = false;

  /// Inicializa Firebase para testes
  static Future<void> setupFirebase() async {
    if (_initialized) return;

    TestWidgetsFlutterBinding.ensureInitialized();

    // Setup Firebase Core Mock
    setupFirebaseCoreMocks();

    // Inicializar Firebase
    await Firebase.initializeApp();

    _initialized = true;
  }

  /// Limpa Firebase após testes
  static Future<void> teardownFirebase() async {
    // Não precisa fazer nada, o Firebase é resetado entre testes
  }

  /// Cria um MockFirebaseAuth com usuário logado
  static MockFirebaseAuth createMockAuth({
    bool signedIn = true,
    String uid = 'test-user-id',
    String email = 'test@example.com',
  }) {
    return MockFirebaseAuth(
      signedIn: signedIn,
      mockUser: MockUser(
        uid: uid,
        email: email,
        displayName: 'Test User',
      ),
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
    bool hasXpBooster = false,
    bool hasGemMultiplier = false,
    bool hasUnlimitedEnergy = false,
  }) async {
    await firestore.collection('users').doc(userId).collection('stats').doc('gamification').set({
      'currentEnergy': currentEnergy,
      'lastEnergyUpdate': FieldValue.serverTimestamp(),
      'totalGems': totalGems,
      'xp': {
        'totalXp': totalXp,
        'weeklyXp': 0,
        'todayXp': 0,
        'level': currentLevel,
        'xpToNextLevel': currentLevel * 100,
      },
      'boosters': {
        'xpBooster': hasXpBooster
            ? {
                'active': true,
                'expiresAt': Timestamp.fromDate(
                  DateTime.now().add(const Duration(hours: 1)),
                ),
              }
            : {'active': false},
        'gemMultiplier': hasGemMultiplier
            ? {
                'active': true,
                'expiresAt': Timestamp.fromDate(
                  DateTime.now().add(const Duration(hours: 1)),
                ),
              }
            : {'active': false},
        'unlimitedEnergy': hasUnlimitedEnergy
            ? {
                'active': true,
                'expiresAt': Timestamp.fromDate(
                  DateTime.now().add(const Duration(hours: 1)),
                ),
              }
            : {'active': false},
      },
    });
  }

  /// Popula Firestore com dados de teste para lições
  static Future<void> populateLessonData(
    FakeFirebaseFirestore firestore,
    String courseId,
    String lessonId, {
    int xpReward = 10,
    int gemsReward = 1,
  }) async {
    await firestore
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .doc(lessonId)
        .set({
      'id': lessonId,
      'name': 'Test Lesson',
      'xpReward': xpReward,
      'gemsReward': gemsReward,
    });
  }

  /// Popula Firestore com exercícios de teste
  static Future<void> populateExercises(
    FakeFirebaseFirestore firestore,
    String courseId,
    String lessonId,
    List<Map<String, dynamic>> exercises,
  ) async {
    for (int i = 0; i < exercises.length; i++) {
      await firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .doc(lessonId)
          .collection('exercises')
          .doc('exercise_$i')
          .set({
        'id': 'exercise_$i',
        'order': i,
        ...exercises[i],
      });
    }
  }

  /// Popula progresso de lições
  static Future<void> populateLessonProgress(
    FakeFirebaseFirestore firestore,
    String userId,
    String courseId,
    String lessonId, {
    String status = 'completed',
  }) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('courses')
        .doc(courseId)
        .collection('progress')
        .doc(lessonId)
        .set({
      'status': status,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }
}

/// Setup Firebase Core Mocks
void setupFirebaseCoreMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Register the mock Firebase platform
  FirebasePlatform.instance = FakeFirebasePlatform();
}

/// Fake Firebase Platform for testing
class FakeFirebasePlatform extends FirebasePlatform {
  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return FakeFirebaseAppPlatform(name);
  }

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return FakeFirebaseAppPlatform(name ?? defaultFirebaseAppName);
  }

  @override
  List<FirebaseAppPlatform> get apps => [FakeFirebaseAppPlatform(defaultFirebaseAppName)];
}

/// Fake Firebase App Platform for testing
class FakeFirebaseAppPlatform extends FirebaseAppPlatform {
  FakeFirebaseAppPlatform(String name)
      : super(name, const FirebaseOptions(
          apiKey: 'test-api-key',
          appId: 'test-app-id',
          messagingSenderId: 'test-sender-id',
          projectId: 'test-project-id',
        ));

  @override
  Future<void> delete() async {}

  @override
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setAutomaticResourceManagementEnabled(bool enabled) async {}
}
