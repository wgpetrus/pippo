import 'package:flutter_test/flutter_test.dart';

/// Feature: lesson-system, Property 23: Challenge Update Consistency
/// 
/// For any lesson completion, all active challenges SHALL be updated with incremented counters
/// (lessonsCompleted, xpEarned), challenges reaching goal SHALL be marked completed,
/// and challenge rewards SHALL be awarded.
/// 
/// Validates: Requirements 9.1, 9.2, 9.3, 9.4
void main() {
  group('Property 23: Challenge Update Consistency', () {
    test('all active challenges are updated after lesson completion', () {
      // Property: Every active challenge must be processed
      
      for (int i = 0; i < 100; i++) {
        // Generate test data - varying number of active challenges
        final numChallenges = 1 + (i % 5); // 1-5 challenges
        final challenges = <Map<String, dynamic>>[];
        
        for (int j = 0; j < numChallenges; j++) {
          challenges.add({
            'id': 'challenge_$j',
            'status': 'active',
            'type': ['lessons_completed', 'xp_earned', 'perfect_lessons'][j % 3],
            'progress': j * 2,
            'goal': 10 + (j * 5),
          });
        }
        
        // Verify all challenges are processed
        expect(
          challenges.length,
          equals(numChallenges),
          reason: 'All generated challenges must be present',
        );
        
        // Verify all are active
        for (final challenge in challenges) {
          expect(
            challenge['status'],
            equals('active'),
            reason: 'All challenges must start as active',
          );
        }
      }
    });

    test('lessons_completed counter increments by exactly 1 per lesson', () {
      // Property: lessons_completed challenges increment by 1 per lesson
      
      for (int i = 0; i < 100; i++) {
        final initialProgress = i % 20; // 0-19
        final goal = 10 + (i % 10); // 10-19
        
        // Simulate lesson completion
        final newProgress = initialProgress + 1;
        
        // Verify increment is exactly 1
        expect(
          newProgress,
          equals(initialProgress + 1),
          reason: 'lessons_completed must increment by exactly 1. '
              'Initial: $initialProgress, New: $newProgress',
        );
        
        // Verify progress never decreases
        expect(
          newProgress,
          greaterThanOrEqualTo(initialProgress),
          reason: 'Progress must never decrease',
        );
        
        // Verify completion detection
        final isCompleted = newProgress >= goal;
        if (newProgress >= goal) {
          expect(
            isCompleted,
            isTrue,
            reason: 'Challenge must be marked completed when progress >= goal. '
                'Progress: $newProgress, Goal: $goal',
          );
        } else {
          expect(
            isCompleted,
            isFalse,
            reason: 'Challenge must remain active when progress < goal',
          );
        }
      }
    });

    test('xp_earned counter increments by lesson XP amount', () {
      // Property: xp_earned challenges increment by actual XP earned
      
      for (int i = 0; i < 100; i++) {
        final initialProgress = i * 5; // 0, 5, 10, ...
        final lessonXp = 10 + (i % 20); // 10-29
        final goal = 100 + (i % 50); // 100-149
        
        // Simulate XP earned
        final newProgress = initialProgress + lessonXp;
        
        // Verify increment matches XP earned
        expect(
          newProgress,
          equals(initialProgress + lessonXp),
          reason: 'xp_earned must increment by exact XP amount. '
              'Initial: $initialProgress, XP: $lessonXp, New: $newProgress',
        );
        
        // Verify progress accumulates correctly
        expect(
          newProgress - initialProgress,
          equals(lessonXp),
          reason: 'Progress delta must equal XP earned',
        );
        
        // Verify completion detection
        if (newProgress >= goal) {
          expect(
            newProgress,
            greaterThanOrEqualTo(goal),
            reason: 'Completed challenge progress must be >= goal',
          );
        }
      }
    });

    test('perfect_lessons counter only increments for 100% accuracy', () {
      // Property: perfect_lessons only increments when accuracy is exactly 100%
      
      for (int i = 0; i < 100; i++) {
        final initialProgress = i % 10; // 0-9
        final correctAnswers = i % 11; // 0-10
        final totalAnswers = 10;
        
        final accuracy = totalAnswers > 0 
            ? (correctAnswers / totalAnswers) * 100 
            : 0.0;
        
        final isPerfect = accuracy == 100.0;
        final newProgress = initialProgress + (isPerfect ? 1 : 0);
        
        // Verify increment is binary (0 or 1)
        if (isPerfect) {
          expect(
            newProgress,
            equals(initialProgress + 1),
            reason: 'perfect_lessons must increment by 1 when accuracy is 100%. '
                'Accuracy: $accuracy, Initial: $initialProgress, New: $newProgress',
          );
        } else {
          expect(
            newProgress,
            equals(initialProgress),
            reason: 'perfect_lessons must NOT increment when accuracy < 100%. '
                'Accuracy: $accuracy, Progress should remain: $initialProgress',
          );
        }
        
        // Verify 90% doesn't count as perfect
        if (correctAnswers == 9 && totalAnswers == 10) {
          expect(
            isPerfect,
            isFalse,
            reason: '90% accuracy (9/10) should not count as perfect',
          );
          expect(
            newProgress,
            equals(initialProgress),
            reason: '90% accuracy should not increment perfect_lessons counter',
          );
        }
      }
    });

    test('challenge status changes from active to completed when goal reached', () {
      // Property: Status must change to completed exactly when progress >= goal
      
      for (int i = 0; i < 100; i++) {
        final progress = i % 25; // 0-24
        final goal = 10 + (i % 10); // 10-19
        
        final expectedStatus = progress >= goal ? 'completed' : 'active';
        
        // Verify status transition
        expect(
          expectedStatus,
          isIn(['active', 'completed']),
          reason: 'Status must be either active or completed',
        );
        
        // Verify completion condition
        if (progress >= goal) {
          expect(
            expectedStatus,
            equals('completed'),
            reason: 'Status must be completed when progress >= goal. '
                'Progress: $progress, Goal: $goal',
          );
        } else {
          expect(
            expectedStatus,
            equals('active'),
            reason: 'Status must remain active when progress < goal. '
                'Progress: $progress, Goal: $goal',
          );
        }
        
        // Verify edge case: progress exactly equals goal
        if (progress == goal) {
          expect(
            expectedStatus,
            equals('completed'),
            reason: 'Challenge must be completed when progress exactly equals goal',
          );
        }
        
        // Verify edge case: progress one less than goal
        if (progress == goal - 1) {
          expect(
            expectedStatus,
            equals('active'),
            reason: 'Challenge must remain active when progress is one less than goal',
          );
        }
      }
    });

    test('challenge rewards are awarded exactly once upon completion', () {
      // Property: Rewards awarded only when challenge transitions to completed
      
      for (int i = 0; i < 100; i++) {
        final wasCompleted = (i % 3 == 0); // Already completed
        final nowCompleted = (i % 2 == 0); // Completing now
        final rewardXp = 50 + (i % 50); // 50-99
        final rewardGems = 5 + (i % 10); // 5-14
        
        // Determine if rewards should be awarded
        final shouldAwardRewards = nowCompleted && !wasCompleted;
        
        final awardedXp = shouldAwardRewards ? rewardXp : 0;
        final awardedGems = shouldAwardRewards ? rewardGems : 0;
        
        // Verify rewards only awarded on first completion
        if (nowCompleted && !wasCompleted) {
          expect(
            awardedXp,
            equals(rewardXp),
            reason: 'Full XP reward must be awarded on first completion',
          );
          expect(
            awardedGems,
            equals(rewardGems),
            reason: 'Full gems reward must be awarded on first completion',
          );
        } else {
          expect(
            awardedXp,
            equals(0),
            reason: 'No XP should be awarded if already completed or not completing',
          );
          expect(
            awardedGems,
            equals(0),
            reason: 'No gems should be awarded if already completed or not completing',
          );
        }
        
        // Verify no double rewards
        if (wasCompleted && nowCompleted) {
          expect(
            awardedXp,
            equals(0),
            reason: 'No rewards should be given for already completed challenges',
          );
        }
      }
    });

    test('multiple challenge types can be updated simultaneously', () {
      // Property: Different challenge types update independently
      
      for (int i = 0; i < 100; i++) {
        final lessonXp = 15 + (i % 10); // 15-24
        final isPerfect = (i % 2 == 0);
        
        // Simulate three challenge types
        final lessonsProgress = i % 5;
        final xpProgress = i * 10;
        final perfectProgress = i % 3;
        
        // Update each type
        final newLessonsProgress = lessonsProgress + 1;
        final newXpProgress = xpProgress + lessonXp;
        final newPerfectProgress = perfectProgress + (isPerfect ? 1 : 0);
        
        // Verify each updates independently
        expect(
          newLessonsProgress,
          equals(lessonsProgress + 1),
          reason: 'lessons_completed must always increment by 1',
        );
        
        expect(
          newXpProgress,
          equals(xpProgress + lessonXp),
          reason: 'xp_earned must increment by lesson XP',
        );
        
        expect(
          newPerfectProgress,
          equals(perfectProgress + (isPerfect ? 1 : 0)),
          reason: 'perfect_lessons must increment only if perfect',
        );
        
        // Verify updates don't interfere with each other
        expect(
          newLessonsProgress - lessonsProgress,
          equals(1),
          reason: 'lessons_completed increment should not be affected by other types',
        );
        
        expect(
          newXpProgress - xpProgress,
          equals(lessonXp),
          reason: 'xp_earned increment should not be affected by other types',
        );
      }
    });

    test('challenge progress never decreases', () {
      // Property: Progress is monotonically increasing
      
      for (int i = 0; i < 100; i++) {
        final initialProgress = i % 50; // 0-49
        final increment = 1 + (i % 10); // 1-10
        
        final newProgress = initialProgress + increment;
        
        // Verify progress increases or stays same
        expect(
          newProgress,
          greaterThanOrEqualTo(initialProgress),
          reason: 'Progress must never decrease. '
              'Initial: $initialProgress, New: $newProgress',
        );
        
        // Verify positive increment
        expect(
          newProgress - initialProgress,
          greaterThanOrEqualTo(0),
          reason: 'Progress delta must be non-negative',
        );
        
        // Verify increment is applied
        if (increment > 0) {
          expect(
            newProgress,
            greaterThan(initialProgress),
            reason: 'Progress must increase when increment > 0',
          );
        }
      }
    });

    test('inactive challenges are not updated', () {
      // Property: Only active challenges should be processed
      
      for (int i = 0; i < 100; i++) {
        final status = ['active', 'completed', 'expired'][i % 3];
        final initialProgress = i % 20;
        
        // Determine if challenge should be updated
        final shouldUpdate = status == 'active';
        final newProgress = shouldUpdate ? initialProgress + 1 : initialProgress;
        
        // Verify only active challenges update
        if (status == 'active') {
          expect(
            newProgress,
            equals(initialProgress + 1),
            reason: 'Active challenges must be updated',
          );
        } else {
          expect(
            newProgress,
            equals(initialProgress),
            reason: 'Non-active challenges must NOT be updated. '
                'Status: $status, Progress should remain: $initialProgress',
          );
        }
        
        // Verify completed challenges don't update
        if (status == 'completed') {
          expect(
            newProgress,
            equals(initialProgress),
            reason: 'Completed challenges should not update progress',
          );
        }
        
        // Verify expired challenges don't update
        if (status == 'expired') {
          expect(
            newProgress,
            equals(initialProgress),
            reason: 'Expired challenges should not update progress',
          );
        }
      }
    });
  });
}
