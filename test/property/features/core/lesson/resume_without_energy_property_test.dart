import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../../../../lib/features/core/lesson/controllers/lesson_flow_flowController.dart';
import '../../../../../lib/features/core/lesson/controllers/lesson_progress_flowController.dart';
import '../../../../../lib/features/inners/gamification/controllers/gamification_flowController.dart';
import '../../../../helpers/firebase_test_helper.dart';

/// Feature: lesson-system, Property 20: Resume Without Energy Cost
/// 
/// For any lesson in in_progress state, resuming SHALL restore from
/// currentExerciseIndex and SHALL NOT consume additional energy.
/// 
/// Validates: Requirements 14.5, 14.6
void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late LessonFlowController flowController;
  late LessonProgressController progressController;
  late GamificationController gamificationController;

  setUp(() async {
    // Initialize fake Firebase
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth(signedIn: true);
    
    // Setup Firebase
    await FirebaseTestHelper.setupFirebase();
    
    // Initialize GetX
    Get.testMode = true;
    
    // Create gamification controller
    gamificationController = GamificationController();
    Get.put<GamificationController>(gamificationController);
    
    // Initialize gamification data
    await FirebaseTestHelper.populateGamificationData(
      fakeFirestore,
      mockAuth.currentUser!.uid,
      currentEnergy: 5,
    );
    
    // Create lesson controllers
    progressController = LessonProgressController();
    Get.put<LessonProgressController>(progressController);
    
    flowController = LessonFlowController();
    Get.put<LessonFlowController>(flowController);
  });

  tearDown(() {
    Get.reset();
  });

  group('Property 20: Resume Without Energy Cost', () {
    test('resuming in_progress lesson does not consume energy', () async {
      // Property: Resume SHALL NOT consume additional energy
      
      for (int i = 0; i < 100; i++) {
        final courseId = 'course_$i';
        final lessonId = (i % 10 + 1).toString(); // Lessons 1-10
        final userId = mockAuth.currentUser!.uid;
        
        // Setup: Create lesson data
        await fakeFirestore
            .collection('courses')
            .doc(courseId)
            .collection('lessons')
            .doc(lessonId)
            .set({
          'id': lessonId,
          'xpReward': 10,
          'gemsReward': 1,
        });
        
        // Setup: Create exercises
        for (int j = 0; j < 5; j++) {
          await fakeFirestore
              .collection('courses')
              .doc(courseId)
              .collection('lessons')
              .doc(lessonId)
              .collection('exercises')
              .doc('ex_$j')
              .set({
            'id': 'ex_$j',
            'type': 'image',
            'order': j,
            'prompt': 'Test prompt',
            'word': 'test',
            'wordAudio': 'test.mp3',
            'options': [
              {'id': 'opt1', 'image': 'img1.png', 'isCorrect': true},
              {'id': 'opt2', 'image': 'img2.png', 'isCorrect': false},
              {'id': 'opt3', 'image': 'img3.png', 'isCorrect': false},
              {'id': 'opt4', 'image': 'img4.png', 'isCorrect': false},
            ],
          });
        }
        
        // Setup: Create in_progress state with various progress points
        final savedExerciseIndex = i % 5; // 0-4
        final savedHearts = (i % 3) + 1; // 1-3
        final savedCorrectAnswers = i % 4; // 0-3
        final savedTotalAnswers = savedCorrectAnswers + (i % 2); // At least correct answers
        final savedAccumulatedTime = i * 1000; // Various times
        
        await fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('courses')
            .doc(courseId)
            .collection('progress')
            .doc(lessonId)
            .set({
          'lessonId': lessonId,
          'status': 'in_progress',
          'currentExerciseIndex': savedExerciseIndex,
          'hearts': savedHearts,
          'correctAnswers': savedCorrectAnswers,
          'totalAnswers': savedTotalAnswers,
          'accumulatedTime': savedAccumulatedTime,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        
        // Get initial energy
        final initialEnergyDoc = await fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('stats')
            .doc('gamification')
            .get();
        final initialEnergy = initialEnergyDoc.data()?['currentEnergy'] as int? ?? 5;
        
        // Action: Resume lesson
        await flowController.resumeLessonFromProgressForTest(courseId, lessonId);
        
        // Verify: Energy was NOT consumed
        final finalEnergyDoc = await fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('stats')
            .doc('gamification')
            .get();
        final finalEnergy = finalEnergyDoc.data()?['currentEnergy'] as int? ?? 5;
        
        expect(
          finalEnergy,
          equals(initialEnergy),
          reason: 'Resume should NOT consume energy. '
              'Initial: $initialEnergy, Final: $finalEnergy, '
              'Iteration: $i',
        );
        
        // Verify: State was restored correctly
        expect(
          flowController.currentExerciseIndex.value,
          equals(savedExerciseIndex),
          reason: 'Should restore currentExerciseIndex. '
              'Expected: $savedExerciseIndex, Actual: ${flowController.currentExerciseIndex.value}',
        );
        
        expect(
          flowController.hearts.value,
          equals(savedHearts),
          reason: 'Should restore hearts. '
              'Expected: $savedHearts, Actual: ${flowController.hearts.value}',
        );
        
        expect(
          flowController.correctAnswers.value,
          equals(savedCorrectAnswers),
          reason: 'Should restore correctAnswers. '
              'Expected: $savedCorrectAnswers, Actual: ${flowController.correctAnswers.value}',
        );
        
        expect(
          flowController.totalAnswers.value,
          equals(savedTotalAnswers),
          reason: 'Should restore totalAnswers. '
              'Expected: $savedTotalAnswers, Actual: ${flowController.totalAnswers.value}',
        );
        
        expect(
          flowController.accumulatedTime.value,
          equals(savedAccumulatedTime),
          reason: 'Should restore accumulatedTime. '
              'Expected: $savedAccumulatedTime, Actual: ${flowController.accumulatedTime.value}',
        );
        
        // Verify: Lesson data was loaded
        expect(
          flowController.currentLesson.value,
          isNotNull,
          reason: 'Should load lesson data',
        );
        
        expect(
          flowController.currentExercises.length,
          equals(5),
          reason: 'Should load all exercises',
        );
        
        // Verify: Time tracking was restarted
        expect(
          flowController.startTime.value,
          isNotNull,
          reason: 'Should restart time tracking',
        );
        
        expect(
          flowController.pauseTime.value,
          isNull,
          reason: 'Should not be paused after resume',
        );
        
        // Reset for next iteration
        flowController.currentLesson.value = null;
        flowController.currentExercises.clear();
        flowController.currentExerciseIndex.value = 0;
      }
    });

    test('resume fails gracefully for non-existent progress', () async {
      // Property: Resume with no saved progress should fail without consuming energy
      
      for (int i = 0; i < 50; i++) {
        final courseId = 'course_$i';
        final lessonId = (i % 10 + 1).toString();
        final userId = mockAuth.currentUser!.uid;
        
        // Setup: Create lesson data but NO progress
        await fakeFirestore
            .collection('courses')
            .doc(courseId)
            .collection('lessons')
            .doc(lessonId)
            .set({
          'id': lessonId,
          'xpReward': 10,
          'gemsReward': 1,
        });
        
        // Get initial energy
        final initialEnergyDoc = await fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('stats')
            .doc('gamification')
            .get();
        final initialEnergy = initialEnergyDoc.data()?['currentEnergy'] as int? ?? 5;
        
        // Action: Try to resume (should fail)
        await flowController.resumeLessonFromProgressForTest(courseId, lessonId);
        
        // Verify: Energy was NOT consumed even on failure
        final finalEnergyDoc = await fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('stats')
            .doc('gamification')
            .get();
        final finalEnergy = finalEnergyDoc.data()?['currentEnergy'] as int? ?? 5;
        
        expect(
          finalEnergy,
          equals(initialEnergy),
          reason: 'Failed resume should NOT consume energy. '
              'Initial: $initialEnergy, Final: $finalEnergy',
        );
        
        // Verify: Error message was set
        expect(
          flowController.errorMessage.value,
          isNotEmpty,
          reason: 'Should set error message on failure',
        );
        
        // Verify: Lesson was not loaded
        expect(
          flowController.currentLesson.value,
          isNull,
          reason: 'Should not load lesson on failure',
        );
      }
    });

    test('resume fails for completed lessons without consuming energy', () async {
      // Property: Cannot resume completed lessons, no energy consumed
      
      for (int i = 0; i < 50; i++) {
        final courseId = 'course_$i';
        final lessonId = (i % 10 + 1).toString();
        final userId = mockAuth.currentUser!.uid;
        
        // Setup: Create lesson data
        await fakeFirestore
            .collection('courses')
            .doc(courseId)
            .collection('lessons')
            .doc(lessonId)
            .set({
          'id': lessonId,
          'xpReward': 10,
          'gemsReward': 1,
        });
        
        // Setup: Create completed progress
        await fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('courses')
            .doc(courseId)
            .collection('progress')
            .doc(lessonId)
            .set({
          'lessonId': lessonId,
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
          'accuracy': 100.0,
          'xpEarned': 10,
          'gemsEarned': 1,
        });
        
        // Get initial energy
        final initialEnergyDoc = await fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('stats')
            .doc('gamification')
            .get();
        final initialEnergy = initialEnergyDoc.data()?['currentEnergy'] as int? ?? 5;
        
        // Action: Try to resume completed lesson (should fail)
        await flowController.resumeLessonFromProgressForTest(courseId, lessonId);
        
        // Verify: Energy was NOT consumed
        final finalEnergyDoc = await fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('stats')
            .doc('gamification')
            .get();
        final finalEnergy = finalEnergyDoc.data()?['currentEnergy'] as int? ?? 5;
        
        expect(
          finalEnergy,
          equals(initialEnergy),
          reason: 'Resume of completed lesson should NOT consume energy. '
              'Initial: $initialEnergy, Final: $finalEnergy',
        );
        
        // Verify: Error message was set
        expect(
          flowController.errorMessage.value,
          isNotEmpty,
          reason: 'Should set error message when trying to resume completed lesson',
        );
      }
    });

    test('resume restores state at any exercise index', () async {
      // Property: Resume works correctly regardless of which exercise was saved
      
      for (int exerciseIndex = 0; exerciseIndex < 10; exerciseIndex++) {
        final courseId = 'course_test';
        final lessonId = '1';
        final userId = mockAuth.currentUser!.uid;
        
        // Setup: Create lesson with 10 exercises
        await fakeFirestore
            .collection('courses')
            .doc(courseId)
            .collection('lessons')
            .doc(lessonId)
            .set({
          'id': lessonId,
          'xpReward': 10,
          'gemsReward': 1,
        });
        
        for (int j = 0; j < 10; j++) {
          await fakeFirestore
              .collection('courses')
              .doc(courseId)
              .collection('lessons')
              .doc(lessonId)
              .collection('exercises')
              .doc('ex_$j')
              .set({
            'id': 'ex_$j',
            'type': 'image',
            'order': j,
            'prompt': 'Test prompt',
            'word': 'test',
            'wordAudio': 'test.mp3',
            'options': [
              {'id': 'opt1', 'image': 'img1.png', 'isCorrect': true},
              {'id': 'opt2', 'image': 'img2.png', 'isCorrect': false},
              {'id': 'opt3', 'image': 'img3.png', 'isCorrect': false},
              {'id': 'opt4', 'image': 'img4.png', 'isCorrect': false},
            ],
          });
        }
        
        // Setup: Save progress at specific exercise index
        await fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('courses')
            .doc(courseId)
            .collection('progress')
            .doc(lessonId)
            .set({
          'lessonId': lessonId,
          'status': 'in_progress',
          'currentExerciseIndex': exerciseIndex,
          'hearts': 3,
          'correctAnswers': exerciseIndex,
          'totalAnswers': exerciseIndex,
          'accumulatedTime': exerciseIndex * 1000,
        });
        
        // Get initial energy
        final initialEnergyDoc = await fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('stats')
            .doc('gamification')
            .get();
        final initialEnergy = initialEnergyDoc.data()?['currentEnergy'] as int? ?? 5;
        
        // Action: Resume
        await flowController.resumeLessonFromProgressForTest(courseId, lessonId);
        
        // Verify: No energy consumed
        final finalEnergyDoc = await fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('stats')
            .doc('gamification')
            .get();
        final finalEnergy = finalEnergyDoc.data()?['currentEnergy'] as int? ?? 5;
        
        expect(
          finalEnergy,
          equals(initialEnergy),
          reason: 'Resume at exercise $exerciseIndex should NOT consume energy',
        );
        
        // Verify: Correct exercise index restored
        expect(
          flowController.currentExerciseIndex.value,
          equals(exerciseIndex),
          reason: 'Should restore to exercise index $exerciseIndex',
        );
        
        // Verify: Can continue from restored point
        expect(
          flowController.currentExerciseIndex.value,
          lessThan(flowController.currentExercises.length),
          reason: 'Restored index should be valid for continuing lesson',
        );
        
        // Reset for next iteration
        flowController.currentLesson.value = null;
        flowController.currentExercises.clear();
        flowController.currentExerciseIndex.value = 0;
      }
    });

    test('multiple resume attempts do not consume energy', () async {
      // Property: Resuming same lesson multiple times never consumes energy
      
      final courseId = 'course_test';
      final lessonId = '1';
      final userId = mockAuth.currentUser!.uid;
      
      // Setup: Create lesson
      await fakeFirestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .doc(lessonId)
          .set({
        'id': lessonId,
        'xpReward': 10,
        'gemsReward': 1,
      });
      
      // Setup: Create exercises
      for (int j = 0; j < 5; j++) {
        await fakeFirestore
            .collection('courses')
            .doc(courseId)
            .collection('lessons')
            .doc(lessonId)
            .collection('exercises')
            .doc('ex_$j')
            .set({
          'id': 'ex_$j',
          'type': 'image',
          'order': j,
          'prompt': 'Test prompt',
          'word': 'test',
          'wordAudio': 'test.mp3',
          'options': [
            {'id': 'opt1', 'image': 'img1.png', 'isCorrect': true},
            {'id': 'opt2', 'image': 'img2.png', 'isCorrect': false},
            {'id': 'opt3', 'image': 'img3.png', 'isCorrect': false},
            {'id': 'opt4', 'image': 'img4.png', 'isCorrect': false},
          ],
        });
      }
      
      // Setup: Create in_progress state
      await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('courses')
          .doc(courseId)
          .collection('progress')
          .doc(lessonId)
          .set({
        'lessonId': lessonId,
        'status': 'in_progress',
        'currentExerciseIndex': 2,
        'hearts': 3,
        'correctAnswers': 2,
        'totalAnswers': 2,
        'accumulatedTime': 5000,
      });
      
      // Get initial energy
      final initialEnergyDoc = await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('stats')
          .doc('gamification')
          .get();
      final initialEnergy = initialEnergyDoc.data()?['currentEnergy'] as int? ?? 5;
      
      // Action: Resume multiple times
      for (int i = 0; i < 10; i++) {
        await flowController.resumeLessonFromProgressForTest(courseId, lessonId);
        
        // Verify: Energy never changes
        final currentEnergyDoc = await fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('stats')
            .doc('gamification')
            .get();
        final currentEnergy = currentEnergyDoc.data()?['currentEnergy'] as int? ?? 5;
        
        expect(
          currentEnergy,
          equals(initialEnergy),
          reason: 'Resume attempt $i should NOT consume energy. '
              'Initial: $initialEnergy, Current: $currentEnergy',
        );
        
        // Reset controller state for next resume
        flowController.currentLesson.value = null;
        flowController.currentExercises.clear();
        flowController.currentExerciseIndex.value = 0;
      }
    });

    test('resume with zero energy still works', () async {
      // Property: Resume works even when user has 0 energy
      
      for (int i = 0; i < 50; i++) {
        final courseId = 'course_$i';
        final lessonId = '1';
        final userId = mockAuth.currentUser!.uid;
        
        // Setup: Set energy to 0
        await fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('stats')
            .doc('gamification')
            .update({'currentEnergy': 0});
        
        // Setup: Create lesson
        await fakeFirestore
            .collection('courses')
            .doc(courseId)
            .collection('lessons')
            .doc(lessonId)
            .set({
          'id': lessonId,
          'xpReward': 10,
          'gemsReward': 1,
        });
        
        // Setup: Create exercises
        for (int j = 0; j < 5; j++) {
          await fakeFirestore
              .collection('courses')
              .doc(courseId)
              .collection('lessons')
              .doc(lessonId)
              .collection('exercises')
              .doc('ex_$j')
              .set({
            'id': 'ex_$j',
            'type': 'image',
            'order': j,
            'prompt': 'Test prompt',
            'word': 'test',
            'wordAudio': 'test.mp3',
            'options': [
              {'id': 'opt1', 'image': 'img1.png', 'isCorrect': true},
              {'id': 'opt2', 'image': 'img2.png', 'isCorrect': false},
              {'id': 'opt3', 'image': 'img3.png', 'isCorrect': false},
              {'id': 'opt4', 'image': 'img4.png', 'isCorrect': false},
            ],
          });
        }
        
        // Setup: Create in_progress state
        await fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('courses')
            .doc(courseId)
            .collection('progress')
            .doc(lessonId)
            .set({
          'lessonId': lessonId,
          'status': 'in_progress',
          'currentExerciseIndex': 1,
          'hearts': 2,
          'correctAnswers': 1,
          'totalAnswers': 1,
          'accumulatedTime': 2000,
        });
        
        // Action: Resume with 0 energy
        await flowController.resumeLessonFromProgressForTest(courseId, lessonId);
        
        // Verify: Resume succeeded
        expect(
          flowController.errorMessage.value,
          isEmpty,
          reason: 'Resume should succeed even with 0 energy',
        );
        
        expect(
          flowController.currentLesson.value,
          isNotNull,
          reason: 'Should load lesson even with 0 energy',
        );
        
        // Verify: Energy is still 0 (not consumed)
        final finalEnergyDoc = await fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('stats')
            .doc('gamification')
            .get();
        final finalEnergy = finalEnergyDoc.data()?['currentEnergy'] as int? ?? 0;
        
        expect(
          finalEnergy,
          equals(0),
          reason: 'Energy should remain 0 after resume',
        );
        
        // Reset for next iteration
        flowController.currentLesson.value = null;
        flowController.currentExercises.clear();
        flowController.currentExerciseIndex.value = 0;
        
        // Reset energy for next test
        await fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('stats')
            .doc('gamification')
            .update({'currentEnergy': 5});
      }
    });
  });
}
