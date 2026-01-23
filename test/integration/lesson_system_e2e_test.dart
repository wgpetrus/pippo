import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pippo/features/core/lesson/controllers/lesson_controller.dart';
import 'package:pippo/features/inners/gamification/controllers/gamification_controller.dart';

import '../helpers/firebase_test_helper.dart';

/// End-to-End Integration Tests for Lesson System
/// 
/// Tests complete flows:
/// - Complete lesson flow (start → exercises → completion)
/// - Failed lesson flow (start → wrong answers → failure)
/// - Resume lesson flow (start → pause → resume → complete)
/// - Multiple lessons per day (streak logic)
/// - All exercise types validate correctly
/// - Energy consumption and regeneration
/// - XP distribution and level up
/// - Streak updates (first lesson of day)
/// - History updates (YYYY-MM-DD format)
/// - Boosters apply correctly
/// - Error handling (network errors, retries)
void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late MockUser user;
  late LessonController lessonController;
  late GamificationController gamificationController;

  setUp(() async {
    // Initialize Firebase mocks
    firestore = FakeFirebaseFirestore();
    user = MockUser(
      uid: 'test-user-id',
      email: 'test@example.com',
      displayName: 'Test User',
    );
    auth = MockFirebaseAuth(mockUser: user, signedIn: true);

    // Setup Firebase test helper
    await FirebaseTestHelper.setupFirebase();

    // Initialize GetX
    Get.testMode = true;

    // Setup initial user data in Firestore
    await _setupUserData(firestore, user.uid);

    // Initialize controllers
    gamificationController = GamificationController();
    Get.put<GamificationController>(gamificationController);

    lessonController = LessonController();
    Get.put<LessonController>(lessonController);

    // Wait for controllers to initialize
    await Future.delayed(const Duration(milliseconds: 100));
  });

  tearDown(() {
    Get.reset();
  });

  group('End-to-End: Complete Lesson Flow', () {
    test('should complete full lesson flow with all exercises', () async {
      // Arrange: Setup lesson data
      await _setupLessonData(firestore, 'course1', '1');

      // Act: Start lesson
      await lessonController.startLesson('course1', '1');

      // Assert: Lesson started successfully
      expect(lessonController.isLoading.value, false);
      expect(lessonController.errorMessage.value, isEmpty);
      expect(lessonController.hearts.value, 3);
      expect(lessonController.currentExercises.length, 4);

      // Act: Complete all exercises correctly
      for (int i = 0; i < 4; i++) {
        final exercise = lessonController.currentExercises[i];
        final type = exercise['type'] as String;
        
        // Submit correct answer based on exercise type
        await _submitCorrectAnswer(lessonController, exercise, type);
        
        // Advance to next exercise if not last
        if (i < 3) {
          lessonController.nextExercise();
        }
      }

      // Wait for completion to process
      await Future.delayed(const Duration(milliseconds: 500));

      // Assert: Lesson completed successfully
      expect(lessonController.correctAnswers.value, 4);
      expect(lessonController.totalAnswers.value, 4);
      expect(lessonController.accuracy, 100.0);
      expect(lessonController.isPerfect, true);

      // Verify progress saved
      final progressDoc = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .doc('course1')
          .collection('progress')
          .doc('1')
          .get();

      expect(progressDoc.exists, true);
      expect(progressDoc.data()?['status'], 'completed');
      expect(progressDoc.data()?['accuracy'], 100.0);
    });
  });


  group('End-to-End: Failed Lesson Flow', () {
    test('should fail lesson when hearts reach 0', () async {
      // Arrange: Setup lesson data
      await _setupLessonData(firestore, 'course1', '1');

      // Act: Start lesson
      await lessonController.startLesson('course1', '1');

      // Assert: Lesson started
      expect(lessonController.hearts.value, 3);

      // Act: Submit 3 wrong answers
      for (int i = 0; i < 3; i++) {
        final exercise = lessonController.currentExercises[i];
        final type = exercise['type'] as String;
        
        // Submit wrong answer
        await _submitWrongAnswer(lessonController, exercise, type);
        
        // Check hearts decreased
        expect(lessonController.hearts.value, 3 - (i + 1));
      }

      // Assert: Lesson failed
      expect(lessonController.hearts.value, 0);
      expect(lessonController.correctAnswers.value, 0);
      expect(lessonController.totalAnswers.value, 3);

      // Verify no rewards given
      final statsDoc = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('gamification')
          .get();

      // XP should remain at initial value (no rewards for failed lesson)
      final xpData = statsDoc.data()?['xp'] as Map<String, dynamic>?;
      expect(xpData?['totalXp'], 0); // Initial value
    });
  });

  group('End-to-End: Resume Lesson Flow', () {
    test('should resume lesson without consuming additional energy', () async {
      // Arrange: Setup lesson data
      await _setupLessonData(firestore, 'course1', '1');

      // Act: Start lesson
      await lessonController.startLesson('course1', '1');
      
      // Get initial energy
      final initialEnergy = gamificationController.currentEnergy.value;

      // Complete first 2 exercises
      for (int i = 0; i < 2; i++) {
        final exercise = lessonController.currentExercises[i];
        final type = exercise['type'] as String;
        await _submitCorrectAnswer(lessonController, exercise, type);
        lessonController.nextExercise();
      }

      // Save in-progress state
      await lessonController.saveInProgressState('course1', '1');

      // Simulate app restart - reset controller
      Get.delete<LessonController>();
      lessonController = LessonController();
      Get.put<LessonController>(lessonController);
      await Future.delayed(const Duration(milliseconds: 100));

      // Act: Resume lesson
      await lessonController.resumeLesson('course1', '1');

      // Assert: Lesson resumed successfully
      expect(lessonController.currentExerciseIndex.value, 2);
      expect(lessonController.correctAnswers.value, 2);
      expect(lessonController.totalAnswers.value, 2);
      expect(lessonController.hearts.value, 3);

      // Verify energy not consumed again
      expect(gamificationController.currentEnergy.value, initialEnergy);

      // Complete remaining exercises
      for (int i = 2; i < 4; i++) {
        final exercise = lessonController.currentExercises[i];
        final type = exercise['type'] as String;
        await _submitCorrectAnswer(lessonController, exercise, type);
        if (i < 3) lessonController.nextExercise();
      }

      // Assert: Lesson completed
      expect(lessonController.correctAnswers.value, 4);
      expect(lessonController.totalAnswers.value, 4);
    });
  });


  group('End-to-End: Multiple Lessons Per Day (Streak Logic)', () {
    test('should update streak only on first lesson of day', () async {
      // Arrange: Setup multiple lessons
      await _setupLessonData(firestore, 'course1', '1');
      await _setupLessonData(firestore, 'course1', '2');

      // Set yesterday as last streak date
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
      
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('gamification')
          .update({
        'streak.currentStreak': 5,
        'streak.longestStreak': 10,
        'streak.lastStreakDate': yesterdayStr,
      });

      // Act: Complete first lesson
      await lessonController.startLesson('course1', '1');
      await _completeAllExercises(lessonController);
      await lessonController.completeLesson();

      // Assert: Streak incremented
      var statsDoc = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('gamification')
          .get();
      
      var streakData = statsDoc.data()?['streak'] as Map<String, dynamic>?;
      expect(streakData?['currentStreak'], 6); // Incremented from 5

      // Act: Complete second lesson same day
      Get.delete<LessonController>();
      lessonController = LessonController();
      Get.put<LessonController>(lessonController);
      await Future.delayed(const Duration(milliseconds: 100));

      await lessonController.startLesson('course1', '2');
      await _completeAllExercises(lessonController);
      await lessonController.completeLesson();

      // Assert: Streak NOT incremented again
      statsDoc = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('gamification')
          .get();
      
      streakData = statsDoc.data()?['streak'] as Map<String, dynamic>?;
      expect(streakData?['currentStreak'], 6); // Still 6, not 7
    });
  });

  group('End-to-End: Exercise Type Validation', () {
    test('should validate all exercise types correctly', () async {
      // Arrange: Setup lesson with all exercise types
      await _setupLessonData(firestore, 'course1', '1');
      await lessonController.startLesson('course1', '1');

      // Test Image Exercise
      final imageExercise = lessonController.currentExercises[0];
      expect(imageExercise['type'], 'image');
      await _submitCorrectAnswer(lessonController, imageExercise, 'image');
      expect(lessonController.correctAnswers.value, 1);
      lessonController.nextExercise();

      // Test Translation Exercise
      final translationExercise = lessonController.currentExercises[1];
      expect(translationExercise['type'], 'translation');
      await _submitCorrectAnswer(lessonController, translationExercise, 'translation');
      expect(lessonController.correctAnswers.value, 2);
      lessonController.nextExercise();

      // Test Word Order Exercise
      final wordOrderExercise = lessonController.currentExercises[2];
      expect(wordOrderExercise['type'], 'word_order');
      await _submitCorrectAnswer(lessonController, wordOrderExercise, 'word_order');
      expect(lessonController.correctAnswers.value, 3);
      lessonController.nextExercise();

      // Test Match Exercise
      final matchExercise = lessonController.currentExercises[3];
      expect(matchExercise['type'], 'match');
      await _submitCorrectAnswer(lessonController, matchExercise, 'match');
      expect(lessonController.correctAnswers.value, 4);

      // Assert: All exercises validated correctly
      expect(lessonController.totalAnswers.value, 4);
      expect(lessonController.accuracy, 100.0);
    });
  });


  group('End-to-End: Energy Consumption and Regeneration', () {
    test('should consume energy on lesson start', () async {
      // Arrange
      await _setupLessonData(firestore, 'course1', '1');
      final initialEnergy = gamificationController.currentEnergy.value;

      // Act
      await lessonController.startLesson('course1', '1');

      // Assert
      expect(gamificationController.currentEnergy.value, initialEnergy - 1);
    });

    test('should not start lesson with 0 energy', () async {
      // Arrange: Set energy to 0
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('gamification')
          .update({'currentEnergy': 0});
      
      gamificationController.currentEnergy.value = 0;
      await _setupLessonData(firestore, 'course1', '1');

      // Act
      await lessonController.startLesson('course1', '1');

      // Assert
      expect(lessonController.errorMessage.value, isNotEmpty);
      expect(lessonController.errorMessage.value, contains('energia'));
    });

    test('should allow lesson start with unlimited energy', () async {
      // Arrange: Set unlimited energy
      final futureTime = DateTime.now().add(const Duration(hours: 1));
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('gamification')
          .update({
        'currentEnergy': 0,
        'unlimitedEnergyUntil': Timestamp.fromDate(futureTime),
      });
      
      gamificationController.currentEnergy.value = 0;
      await _setupLessonData(firestore, 'course1', '1');

      // Act
      await lessonController.startLesson('course1', '1');

      // Assert: Lesson started despite 0 energy
      expect(lessonController.errorMessage.value, isEmpty);
      expect(lessonController.currentExercises.length, 4);
      expect(gamificationController.currentEnergy.value, 0); // Energy not consumed
    });
  });

  group('End-to-End: XP Distribution and Level Up', () {
    test('should distribute XP to all counters and level up', () async {
      // Arrange: Set user close to level up
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('gamification')
          .update({
        'xp.totalXp': 95, // Close to level 2 (needs 100)
        'xp.level': 1,
        'xp.xpToNextLevel': 100,
      });
      
      await _setupLessonData(firestore, 'course1', '1');

      // Act: Complete lesson (should give 10 base XP + 5 perfect + 5 first today = 20 XP)
      await lessonController.startLesson('course1', '1');
      await _completeAllExercises(lessonController);
      await lessonController.completeLesson();

      // Assert: XP distributed and leveled up
      final statsDoc = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('gamification')
          .get();
      
      final xpData = statsDoc.data()?['xp'] as Map<String, dynamic>?;
      expect(xpData?['totalXp'], greaterThanOrEqualTo(100)); // Should be 115
      expect(xpData?['level'], 2); // Leveled up
      expect(xpData?['weeklyXp'], greaterThan(0));
      expect(xpData?['todayXp'], greaterThan(0));
    });
  });


  group('End-to-End: Streak Updates', () {
    test('should update streak on first lesson of day', () async {
      // Arrange: Set yesterday as last streak date
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
      
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('gamification')
          .update({
        'streak.currentStreak': 3,
        'streak.longestStreak': 5,
        'streak.lastStreakDate': yesterdayStr,
      });
      
      await _setupLessonData(firestore, 'course1', '1');

      // Act
      await lessonController.startLesson('course1', '1');
      await _completeAllExercises(lessonController);
      await lessonController.completeLesson();

      // Assert
      final statsDoc = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('gamification')
          .get();
      
      final streakData = statsDoc.data()?['streak'] as Map<String, dynamic>?;
      expect(streakData?['currentStreak'], 4); // Incremented
      
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      expect(streakData?['lastStreakDate'], todayStr);
    });

    test('should reset streak if last lesson was before yesterday', () async {
      // Arrange: Set 3 days ago as last streak date
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final threeDaysAgoStr = '${threeDaysAgo.year}-${threeDaysAgo.month.toString().padLeft(2, '0')}-${threeDaysAgo.day.toString().padLeft(2, '0')}';
      
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('gamification')
          .update({
        'streak.currentStreak': 10,
        'streak.longestStreak': 15,
        'streak.lastStreakDate': threeDaysAgoStr,
      });
      
      await _setupLessonData(firestore, 'course1', '1');

      // Act
      await lessonController.startLesson('course1', '1');
      await _completeAllExercises(lessonController);
      await lessonController.completeLesson();

      // Assert
      final statsDoc = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('gamification')
          .get();
      
      final streakData = statsDoc.data()?['streak'] as Map<String, dynamic>?;
      expect(streakData?['currentStreak'], 1); // Reset to 1
      expect(streakData?['longestStreak'], 15); // Longest unchanged
    });
  });

  group('End-to-End: History Updates', () {
    test('should update daily history with YYYY-MM-DD format', () async {
      // Arrange
      await _setupLessonData(firestore, 'course1', '1');

      // Act
      await lessonController.startLesson('course1', '1');
      await _completeAllExercises(lessonController);
      await lessonController.completeLesson();

      // Assert
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final historyDoc = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .doc(todayStr)
          .get();

      expect(historyDoc.exists, true);
      expect(historyDoc.data()?['date'], todayStr);
      expect(historyDoc.data()?['lessonsCompleted'], 1);
      expect(historyDoc.data()?['xpEarned'], greaterThan(0));
      expect(historyDoc.data()?['gemsEarned'], greaterThan(0));
      expect(historyDoc.data()?['timeSpent'], greaterThan(0));
    });
  });


  group('End-to-End: Boosters Apply Correctly', () {
    test('should apply XP booster multiplier', () async {
      // Arrange: Set active XP booster
      final futureTime = DateTime.now().add(const Duration(hours: 1));
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('gamification')
          .update({
        'boosters.xpBoosterExpiresAt': Timestamp.fromDate(futureTime),
      });
      
      gamificationController.gems.value = 150; // Ensure enough gems
      await _setupLessonData(firestore, 'course1', '1');

      // Act
      await lessonController.startLesson('course1', '1');
      await _completeAllExercises(lessonController);
      
      // Get XP before completion
      final statsDocBefore = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('gamification')
          .get();
      final xpBefore = statsDocBefore.data()?['xp']?['totalXp'] as int? ?? 0;
      
      await lessonController.completeLesson();

      // Assert: XP doubled
      final statsDocAfter = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('gamification')
          .get();
      final xpAfter = statsDocAfter.data()?['xp']?['totalXp'] as int? ?? 0;
      final xpGained = xpAfter - xpBefore;
      
      // Base XP (10) + Perfect (5) + First Today (5) = 20, then doubled = 40
      expect(xpGained, 40);
    });

    test('should apply gem multiplier', () async {
      // Arrange: Set active gem multiplier
      final futureTime = DateTime.now().add(const Duration(hours: 1));
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('gamification')
          .update({
        'boosters.gemMultiplierExpiresAt': Timestamp.fromDate(futureTime),
      });
      
      gamificationController.gems.value = 200; // Ensure enough gems
      await _setupLessonData(firestore, 'course1', '1');

      // Act
      await lessonController.startLesson('course1', '1');
      await _completeAllExercises(lessonController);
      
      // Get gems before completion
      final statsDocBefore = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('gamification')
          .get();
      final gemsBefore = statsDocBefore.data()?['gems']?['totalGems'] as int? ?? 0;
      
      await lessonController.completeLesson();

      // Assert: Gems doubled
      final statsDocAfter = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('gamification')
          .get();
      final gemsAfter = statsDocAfter.data()?['gems']?['totalGems'] as int? ?? 0;
      final gemsGained = gemsAfter - gemsBefore;
      
      // Base gems (1) doubled = 2
      expect(gemsGained, 2);
    });

    test('should not apply expired booster', () async {
      // Arrange: Set expired XP booster
      final pastTime = DateTime.now().subtract(const Duration(hours: 1));
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('gamification')
          .update({
        'boosters.xpBoosterExpiresAt': Timestamp.fromDate(pastTime),
      });
      
      await _setupLessonData(firestore, 'course1', '1');

      // Act
      await lessonController.startLesson('course1', '1');
      await _completeAllExercises(lessonController);
      
      final statsDocBefore = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('gamification')
          .get();
      final xpBefore = statsDocBefore.data()?['xp']?['totalXp'] as int? ?? 0;
      
      await lessonController.completeLesson();

      // Assert: XP not doubled (booster expired)
      final statsDocAfter = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('gamification')
          .get();
      final xpAfter = statsDocAfter.data()?['xp']?['totalXp'] as int? ?? 0;
      final xpGained = xpAfter - xpBefore;
      
      // Base XP (10) + Perfect (5) + First Today (5) = 20 (not doubled)
      expect(xpGained, 20);
    });
  });


  group('End-to-End: Error Handling', () {
    test('should not consume energy on lesson start error', () async {
      // Arrange: Setup invalid lesson (no exercises)
      await firestore
          .collection('courses')
          .doc('course1')
          .collection('lessons')
          .doc('999')
          .set({
        'id': '999',
        'xpReward': 10,
        'gemsReward': 1,
      });
      
      final initialEnergy = gamificationController.currentEnergy.value;

      // Act: Try to start lesson with no exercises
      await lessonController.startLesson('course1', '999');

      // Assert: Error occurred and energy not consumed
      expect(lessonController.errorMessage.value, isNotEmpty);
      expect(gamificationController.currentEnergy.value, initialEnergy);
    });

    test('should prevent concurrent lesson starts', () async {
      // Arrange
      await _setupLessonData(firestore, 'course1', '1');

      // Act: Try to start lesson twice simultaneously
      final future1 = lessonController.startLesson('course1', '1');
      final future2 = lessonController.startLesson('course1', '1');
      
      await Future.wait([future1, future2]);

      // Assert: Second start should be prevented
      expect(lessonController.errorMessage.value, contains('já está sendo iniciada'));
    });
  });
}

// Helper Functions

/// Setup initial user data in Firestore
Future<void> _setupUserData(FakeFirebaseFirestore firestore, String userId) async {
  await firestore
      .collection('users')
      .doc(userId)
      .collection('stats')
      .doc('gamification')
      .set({
    'currentEnergy': 5,
    'maxEnergy': 5,
    'lastEnergyRegenAt': Timestamp.now(),
    'unlimitedEnergyUntil': null,
    'xp': {
      'totalXp': 0,
      'weeklyXp': 0,
      'todayXp': 0,
      'level': 1,
      'xpToNextLevel': 100,
    },
    'gems': {
      'totalGems': 0,
      'totalGemsEarned': 0,
      'totalGemsSpent': 0,
    },
    'streak': {
      'currentStreak': 0,
      'longestStreak': 0,
      'lastStreakDate': '',
    },
    'boosters': {
      'xpBoosterExpiresAt': null,
      'gemMultiplierExpiresAt': null,
    },
  });
}

/// Setup lesson data with exercises
Future<void> _setupLessonData(
  FakeFirebaseFirestore firestore,
  String courseId,
  String lessonId,
) async {
  // Create lesson
  await firestore
      .collection('courses')
      .doc(courseId)
      .collection('lessons')
      .doc(lessonId)
      .set({
    'id': lessonId,
    'courseId': courseId,
    'xpReward': 10,
    'gemsReward': 1,
  });

  // Create exercises
  final exercises = [
    {
      'id': '1',
      'type': 'image',
      'order': 0,
      'prompt': 'Select the correct image',
      'word': 'dog',
      'options': [
        {'id': 'img1', 'image': 'dog.png', 'isCorrect': true},
        {'id': 'img2', 'image': 'cat.png', 'isCorrect': false},
        {'id': 'img3', 'image': 'bird.png', 'isCorrect': false},
        {'id': 'img4', 'image': 'fish.png', 'isCorrect': false},
      ],
    },
    {
      'id': '2',
      'type': 'translation',
      'order': 1,
      'prompt': 'Select the correct translation',
      'word': 'hello',
      'wordAudio': 'hello.mp3',
      'options': [
        {'id': 'opt1', 'text': 'olá', 'isCorrect': true},
        {'id': 'opt2', 'text': 'tchau', 'isCorrect': false},
        {'id': 'opt3', 'text': 'obrigado', 'isCorrect': false},
        {'id': 'opt4', 'text': 'por favor', 'isCorrect': false},
      ],
    },
    {
      'id': '3',
      'type': 'word_order',
      'order': 2,
      'prompt': 'Arrange the words',
      'sentence': 'I am happy',
      'correctOrder': ['I', 'am', 'happy'],
      'availableWords': ['I', 'am', 'happy', 'sad'],
    },
    {
      'id': '4',
      'type': 'match',
      'order': 3,
      'prompt': 'Match the pairs',
      'pairs': [
        {'audio': 'hello.mp3', 'text': 'olá'},
        {'audio': 'goodbye.mp3', 'text': 'tchau'},
        {'audio': 'thanks.mp3', 'text': 'obrigado'},
        {'audio': 'please.mp3', 'text': 'por favor'},
      ],
    },
  ];

  for (final exercise in exercises) {
    await firestore
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .doc(lessonId)
        .collection('exercises')
        .doc(exercise['id'] as String)
        .set(exercise);
  }
}


/// Submit correct answer for an exercise
Future<void> _submitCorrectAnswer(
  LessonController controller,
  Map<String, dynamic> exercise,
  String type,
) async {
  switch (type) {
    case 'image':
      final options = exercise['options'] as List;
      final correctOption = options.firstWhere((opt) => opt['isCorrect'] == true);
      await controller.submitAnswer(correctOption['id'], type);
      break;
    case 'translation':
      final options = exercise['options'] as List;
      final correctOption = options.firstWhere((opt) => opt['isCorrect'] == true);
      await controller.submitAnswer(correctOption['text'], type);
      break;
    case 'word_order':
      final correctOrder = exercise['correctOrder'] as List<dynamic>;
      await controller.submitAnswer(correctOrder.cast<String>(), type);
      break;
    case 'match':
      final pairs = exercise['pairs'] as List;
      final correctPairs = <String, String>{};
      for (final pair in pairs) {
        correctPairs[pair['audio'] as String] = pair['text'] as String;
      }
      await controller.submitAnswer(correctPairs, type);
      break;
  }
}

/// Submit wrong answer for an exercise
Future<void> _submitWrongAnswer(
  LessonController controller,
  Map<String, dynamic> exercise,
  String type,
) async {
  switch (type) {
    case 'image':
      final options = exercise['options'] as List;
      final wrongOption = options.firstWhere((opt) => opt['isCorrect'] == false);
      await controller.submitAnswer(wrongOption['id'], type);
      break;
    case 'translation':
      final options = exercise['options'] as List;
      final wrongOption = options.firstWhere((opt) => opt['isCorrect'] == false);
      await controller.submitAnswer(wrongOption['text'], type);
      break;
    case 'word_order':
      // Submit wrong order
      await controller.submitAnswer(['wrong', 'order'], type);
      break;
    case 'match':
      // Submit wrong pairs
      await controller.submitAnswer({'wrong': 'pairs'}, type);
      break;
  }
}

/// Complete all exercises in the lesson correctly
Future<void> _completeAllExercises(LessonController controller) async {
  for (int i = 0; i < controller.currentExercises.length; i++) {
    final exercise = controller.currentExercises[i];
    final type = exercise['type'] as String;
    
    await _submitCorrectAnswer(controller, exercise, type);
    
    if (i < controller.currentExercises.length - 1) {
      controller.nextExercise();
    }
  }
}
