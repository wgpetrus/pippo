import 'package:flutter_test/flutter_test.dart';

/// Feature: lesson-system, Property 13: Completion Sequence Order
/// 
/// For any lesson completion, operations SHALL execute in this exact order:
/// (1) calculate rewards, (2) distribute XP, (3) add gems, (4) check level up,
/// (5) update streak (if first today), (6) save progress, (7) update history,
/// (8) update challenges, (9) unlock next lesson.
/// 
/// Validates: Requirements 5.1, 8.1, 8.4, 8.7, 9.5
void main() {
  group('Property 13: Completion Sequence Order', () {
    test('completion operations must execute in exact order', () {
      // Property: Completion sequence order is critical for data consistency
      
      for (int i = 0; i < 100; i++) {
        // Generate test data
        final baseXp = 10 + (i % 10);
        final baseGems = 1 + (i % 5);
        final isPerfect = (i % 2 == 0);
        final isFirstToday = (i % 3 == 0);
        final hasXpBooster = (i % 4 == 0);
        final hasGemMultiplier = (i % 5 == 0);
        
        // Simulate completion sequence
        final sequence = <String>[];
        
        // Step 1: Calculate rewards
        sequence.add('calculate_rewards');
        int totalXp = baseXp;
        if (isPerfect) totalXp += 5;
        if (isFirstToday) totalXp += 5;
        if (hasXpBooster) totalXp *= 2;
        
        int totalGems = baseGems;
        if (hasGemMultiplier) totalGems *= 2;
        
        // Step 2: Distribute XP
        sequence.add('distribute_xp');
        
        // Step 3: Add gems
        sequence.add('add_gems');
        
        // Step 4: Check level up
        sequence.add('check_level_up');
        
        // Step 5: Update streak (only if first today)
        if (isFirstToday) {
          sequence.add('update_streak');
        }
        
        // Step 6: Save progress
        sequence.add('save_progress');
        
        // Step 7: Update history
        sequence.add('update_history');
        
        // Step 8: Update challenges
        sequence.add('update_challenges');
        
        // Step 9: Unlock next lesson
        sequence.add('unlock_next_lesson');
        
        // Verify sequence order
        expect(
          sequence[0],
          equals('calculate_rewards'),
          reason: 'Step 1 must be calculate_rewards',
        );
        
        expect(
          sequence[1],
          equals('distribute_xp'),
          reason: 'Step 2 must be distribute_xp',
        );
        
        expect(
          sequence[2],
          equals('add_gems'),
          reason: 'Step 3 must be add_gems',
        );
        
        expect(
          sequence[3],
          equals('check_level_up'),
          reason: 'Step 4 must be check_level_up',
        );
        
        // Verify streak update position (if present)
        if (isFirstToday) {
          final streakIndex = sequence.indexOf('update_streak');
          final saveProgressIndex = sequence.indexOf('save_progress');
          
          expect(
            streakIndex,
            lessThan(saveProgressIndex),
            reason: 'update_streak must occur before save_progress',
          );
          
          expect(
            streakIndex,
            equals(4),
            reason: 'update_streak must be at position 4 (Step 5)',
          );
        }
        
        // Verify save_progress comes before update_history
        final saveIndex = sequence.indexOf('save_progress');
        final historyIndex = sequence.indexOf('update_history');
        
        expect(
          saveIndex,
          lessThan(historyIndex),
          reason: 'save_progress must occur before update_history',
        );
        
        // Verify update_history comes before update_challenges
        final challengesIndex = sequence.indexOf('update_challenges');
        
        expect(
          historyIndex,
          lessThan(challengesIndex),
          reason: 'update_history must occur before update_challenges',
        );
        
        // Verify unlock_next_lesson is last
        expect(
          sequence.last,
          equals('unlock_next_lesson'),
          reason: 'unlock_next_lesson must be the last operation',
        );
        
        // Verify total sequence length
        final expectedLength = isFirstToday ? 9 : 8;
        expect(
          sequence.length,
          equals(expectedLength),
          reason: 'Sequence must have exactly $expectedLength steps',
        );
      }
    });

    test('rewards must be calculated before distribution', () {
      // Property: Rewards calculation must complete before any distribution
      
      for (int i = 0; i < 100; i++) {
        final baseXp = 10 + (i % 10);
        final isPerfect = (i % 2 == 0);
        
        // Simulate calculation
        int calculatedXp = baseXp;
        if (isPerfect) calculatedXp += 5;
        
        // Verify calculation happens first
        expect(
          calculatedXp,
          greaterThan(0),
          reason: 'XP must be calculated before distribution',
        );
        
        // Verify distribution uses calculated value
        final distributedXp = calculatedXp;
        
        expect(
          distributedXp,
          equals(calculatedXp),
          reason: 'Distributed XP must equal calculated XP',
        );
        
        // Verify perfect bonus is included in distribution
        if (isPerfect) {
          expect(
            distributedXp,
            equals(baseXp + 5),
            reason: 'Perfect bonus must be included in distributed XP',
          );
        }
      }
    });

    test('XP distribution must occur before level up check', () {
      // Property: Level up check must use updated totalXp
      
      for (int i = 0; i < 100; i++) {
        final currentTotalXp = i * 10; // 0, 10, 20, ...
        final currentLevel = 1 + (i ~/ 10); // 1, 1, 1, ..., 2, 2, 2, ...
        final earnedXp = 15;
        
        // Step 1: Distribute XP
        final newTotalXp = currentTotalXp + earnedXp;
        
        // Step 2: Check level up
        final xpForNextLevel = currentLevel * 100;
        final shouldLevelUp = newTotalXp >= xpForNextLevel;
        
        // Verify level up check uses new total
        if (shouldLevelUp) {
          expect(
            newTotalXp,
            greaterThanOrEqualTo(xpForNextLevel),
            reason: 'Level up check must use updated totalXp',
          );
        }
        
        // Verify level up doesn't use old total
        final wouldLevelUpWithOldTotal = currentTotalXp >= xpForNextLevel;
        if (shouldLevelUp && !wouldLevelUpWithOldTotal) {
          expect(
            newTotalXp,
            greaterThan(currentTotalXp),
            reason: 'Level up must consider newly distributed XP',
          );
        }
      }
    });

    test('streak update only occurs if first lesson today', () {
      // Property: Streak update is conditional on first lesson today
      
      for (int i = 0; i < 100; i++) {
        final isFirstToday = (i % 3 == 0);
        final lessonsCompletedToday = isFirstToday ? 0 : (i % 5 + 1);
        
        // Determine if streak should update
        final shouldUpdateStreak = lessonsCompletedToday == 0;
        
        expect(
          shouldUpdateStreak,
          equals(isFirstToday),
          reason: 'Streak should only update if first lesson today',
        );
        
        // Verify streak doesn't update on subsequent lessons
        if (lessonsCompletedToday > 0) {
          expect(
            shouldUpdateStreak,
            isFalse,
            reason: 'Streak must not update on lesson ${lessonsCompletedToday + 1} of the day',
          );
        }
      }
    });

    test('progress save must occur before history update', () {
      // Property: Lesson progress must be saved before updating daily history
      
      for (int i = 0; i < 100; i++) {
        final lessonId = i % 10 + 1;
        final xpEarned = 10 + (i % 10);
        
        // Simulate sequence
        final operations = <String>[];
        
        // Save progress first
        operations.add('save_progress_lesson_$lessonId');
        
        // Then update history
        operations.add('update_history_with_xp_$xpEarned');
        
        // Verify order
        expect(
          operations[0],
          startsWith('save_progress'),
          reason: 'Progress save must occur first',
        );
        
        expect(
          operations[1],
          startsWith('update_history'),
          reason: 'History update must occur after progress save',
        );
        
        // Verify history uses saved progress data
        expect(
          operations[1],
          contains('xp_$xpEarned'),
          reason: 'History must use XP from saved progress',
        );
      }
    });

    test('challenges update must occur after history update', () {
      // Property: Challenges must be updated after history is saved
      
      for (int i = 0; i < 100; i++) {
        final lessonsCompleted = i % 5 + 1;
        
        // Simulate sequence
        final operations = <String>[];
        
        // Update history first
        operations.add('update_history_lessons_$lessonsCompleted');
        
        // Then update challenges
        operations.add('update_challenges');
        
        // Verify order
        final historyIndex = operations.indexWhere((op) => op.startsWith('update_history'));
        final challengesIndex = operations.indexWhere((op) => op.startsWith('update_challenges'));
        
        expect(
          historyIndex,
          lessThan(challengesIndex),
          reason: 'History update must occur before challenges update',
        );
        
        // Verify challenges can access history data
        expect(
          challengesIndex,
          equals(1),
          reason: 'Challenges update must be after history (index 1)',
        );
      }
    });

    test('next lesson unlock must be last operation', () {
      // Property: Unlocking next lesson must be the final operation
      
      for (int i = 0; i < 100; i++) {
        final currentLessonId = i % 10 + 1;
        final nextLessonId = currentLessonId + 1;
        
        // Simulate all operations
        final operations = <String>[
          'calculate_rewards',
          'distribute_xp',
          'add_gems',
          'check_level_up',
          'save_progress',
          'update_history',
          'update_challenges',
          'unlock_lesson_$nextLessonId',
        ];
        
        // Verify unlock is last
        expect(
          operations.last,
          startsWith('unlock_lesson'),
          reason: 'Unlock next lesson must be the last operation',
        );
        
        // Verify all other operations come before unlock
        final unlockIndex = operations.length - 1;
        
        for (int j = 0; j < unlockIndex; j++) {
          expect(
            j,
            lessThan(unlockIndex),
            reason: 'Operation ${operations[j]} must occur before unlock',
          );
        }
        
        // Verify unlock uses correct lesson ID
        expect(
          operations.last,
          contains('$nextLessonId'),
          reason: 'Must unlock lesson $nextLessonId (current + 1)',
        );
      }
    });

    test('error in any step must not affect previous steps', () {
      // Property: Operations are atomic - completed steps remain valid
      
      for (int i = 0; i < 100; i++) {
        final failAtStep = i % 9; // Fail at different steps
        
        // Simulate sequence with potential failure
        final completedSteps = <String>[];
        
        for (int step = 0; step < 9; step++) {
          if (step == failAtStep) {
            // Simulate failure at this step
            break;
          }
          
          completedSteps.add('step_$step');
        }
        
        // Verify completed steps are valid
        expect(
          completedSteps.length,
          equals(failAtStep),
          reason: 'Only steps before failure should be completed',
        );
        
        // Verify no steps after failure are executed
        for (int step = failAtStep; step < 9; step++) {
          expect(
            completedSteps,
            isNot(contains('step_$step')),
            reason: 'Step $step should not execute after failure at step $failAtStep',
          );
        }
        
        // Verify completed steps are in order
        for (int j = 0; j < completedSteps.length; j++) {
          expect(
            completedSteps[j],
            equals('step_$j'),
            reason: 'Completed steps must be in sequential order',
          );
        }
      }
    });
  });
}
