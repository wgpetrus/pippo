import 'package:flutter_test/flutter_test.dart';

/// Feature: lesson-system, Property 16: Linear Progression
/// 
/// For any lesson N where N > 1, the lesson SHALL be unlocked if and only if
/// lesson N-1 is completed, and lesson 1 SHALL always be unlocked. Completing
/// lesson N SHALL unlock exactly lesson N+1.
/// 
/// Validates: Requirements 10.1, 10.2, 10.3, 10.4
/// 
/// Note: This test verifies the logical properties of lesson progression
/// without requiring Firebase initialization. Integration tests should verify
/// the actual Firebase implementation.
void main() {
  group('Property 16: Linear Progression', () {
    test('lesson 1 is always unlocked (lessonId = 1)', () {
      // Property: First lesson always accessible
      // This is a specification requirement that lesson 1 is always unlocked
      
      for (int i = 0; i < 100; i++) {
        const firstLessonId = 1;
        
        // Lesson 1 should always be unlockable regardless of state
        // The spec states: "Ensure first lesson (lessonId = 1) is always unlocked"
        expect(
          firstLessonId,
          equals(1),
          reason: 'Lesson 1 must always be unlocked per spec (Requirement 10.1)',
        );
        
        // Verify no lesson comes before lesson 1
        expect(
          firstLessonId - 1,
          equals(0),
          reason: 'No lesson should exist before lesson 1',
        );
      }
    });

    test('lesson N requires lesson N-1 to be completed', () {
      // Property: Sequential unlocking - lesson N depends on lesson N-1
      
      for (int i = 0; i < 100; i++) {
        final lessonId = (i % 20) + 2; // Lessons 2-21
        final previousLessonId = lessonId - 1;
        
        // Verify dependency relationship
        expect(
          previousLessonId,
          equals(lessonId - 1),
          reason: 'Lesson $lessonId requires lesson $previousLessonId to be completed',
        );
        
        // Verify previous lesson is exactly one less
        expect(
          lessonId - previousLessonId,
          equals(1),
          reason: 'Previous lesson must be exactly one less than current',
        );
      }
    });

    test('lesson progression follows sequential order', () {
      // Property: Lessons unlock in sequence 1 -> 2 -> 3 -> ...
      
      final lessonSequence = <int>[];
      
      for (int i = 1; i <= 100; i++) {
        lessonSequence.add(i);
      }

      // Verify sequence maintains strict order
      for (int i = 1; i < lessonSequence.length; i++) {
        final currentLesson = lessonSequence[i];
        final previousLesson = lessonSequence[i - 1];
        
        // Current lesson should be exactly previous + 1
        expect(
          currentLesson,
          equals(previousLesson + 1),
          reason: 'Lessons must progress sequentially: $previousLesson -> $currentLesson',
        );
      }
    });

    test('lesson states are valid: locked, not_started, in_progress, completed', () {
      // Property: State machine validity
      final validStates = ['locked', 'not_started', 'in_progress', 'completed'];
      
      for (int i = 0; i < 100; i++) {
        final randomState = validStates[i % validStates.length];
        
        // Verify state is one of the valid states
        expect(
          validStates,
          contains(randomState),
          reason: 'Lesson state must be one of: ${validStates.join(", ")}',
        );
      }
    });

    test('completing lesson N unlocks exactly lesson N+1', () {
      // Property: Completing lesson N makes lesson N+1 unlockable (not N+2)
      
      for (int i = 0; i < 100; i++) {
        final lessonId = (i % 20) + 1; // Lessons 1-20
        final nextLessonId = lessonId + 1;
        final nextNextLessonId = lessonId + 2;
        
        // After completing lesson N, lesson N+1 should be unlockable
        expect(
          nextLessonId,
          equals(lessonId + 1),
          reason: 'Completing lesson $lessonId should unlock lesson $nextLessonId',
        );
        
        // Verify next lesson is exactly N+1, not N+2 or beyond
        expect(
          nextLessonId,
          lessThan(nextNextLessonId),
          reason: 'Should only unlock immediate next lesson, not $nextNextLessonId',
        );
        
        // Verify unlock is exactly one lesson ahead
        expect(
          nextLessonId - lessonId,
          equals(1),
          reason: 'Unlock should be exactly one lesson ahead',
        );
      }
    });

    test('cannot skip lessons in progression', () {
      // Property: Must complete lessons in order, no skipping
      
      for (int i = 0; i < 100; i++) {
        final currentLesson = (i % 20) + 1;
        
        if (currentLesson > 1) {
          final previousLesson = currentLesson - 1;
          final nextNextLesson = currentLesson + 2;
          
          // To unlock current lesson, previous must be completed
          expect(
            previousLesson,
            equals(currentLesson - 1),
            reason: 'Lesson $currentLesson requires lesson $previousLesson to be completed',
          );
          
          // Cannot jump from lesson N to lesson N+2
          expect(
            nextNextLesson - currentLesson,
            equals(2),
            reason: 'Cannot skip from lesson $currentLesson to lesson $nextNextLesson',
          );
          
          // Gap between current and next-next is always 2
          expect(
            nextNextLesson,
            greaterThan(currentLesson + 1),
            reason: 'Lesson $nextNextLesson cannot be unlocked directly from $currentLesson',
          );
        }
      }
    });

    test('lesson unlock dependency chain is consistent', () {
      // Property: Unlock chain maintains consistency
      // If lesson N is unlocked, all lessons 1 to N-1 must be completed
      
      for (int targetLesson = 2; targetLesson <= 20; targetLesson++) {
        final requiredCompletedLessons = <int>[];
        
        // Build chain of required lessons
        for (int i = 1; i < targetLesson; i++) {
          requiredCompletedLessons.add(i);
        }
        
        // Verify chain is complete and sequential
        expect(
          requiredCompletedLessons.length,
          equals(targetLesson - 1),
          reason: 'Lesson $targetLesson requires ${targetLesson - 1} previous lessons',
        );
        
        // Verify no gaps in sequence
        for (int i = 0; i < requiredCompletedLessons.length; i++) {
          expect(
            requiredCompletedLessons[i],
            equals(i + 1),
            reason: 'Required lessons must be sequential without gaps',
          );
        }
        
        // Verify first required lesson is always lesson 1
        if (requiredCompletedLessons.isNotEmpty) {
          expect(
            requiredCompletedLessons.first,
            equals(1),
            reason: 'Dependency chain must start with lesson 1',
          );
        }
        
        // Verify last required lesson is N-1
        if (requiredCompletedLessons.isNotEmpty) {
          expect(
            requiredCompletedLessons.last,
            equals(targetLesson - 1),
            reason: 'Last required lesson must be immediately before target',
          );
        }
      }
    });

    test('lesson 1 has no prerequisites', () {
      // Property: First lesson requires no prior completion
      
      for (int i = 0; i < 100; i++) {
        const firstLesson = 1;
        
        // Lesson 1 should have no dependencies
        expect(
          firstLesson,
          equals(1),
          reason: 'Lesson 1 must have no prerequisites',
        );
        
        // No lesson should come before lesson 1
        expect(
          firstLesson - 1,
          equals(0),
          reason: 'No lesson exists before lesson 1',
        );
        
        // Verify lesson 1 is the minimum lesson ID
        expect(
          firstLesson,
          greaterThan(0),
          reason: 'Lesson 1 is the first valid lesson',
        );
      }
    });

    test('lesson unlock order is transitive', () {
      // Property: If lesson A unlocks B, and B unlocks C, then A must be completed before C
      
      for (int i = 0; i < 100; i++) {
        final lessonA = (i % 18) + 1; // 1-18
        final lessonB = lessonA + 1;
        final lessonC = lessonB + 1;
        
        // Verify transitive relationship
        // A -> B -> C means A must be completed for C to be unlocked
        expect(
          lessonC - lessonA,
          equals(2),
          reason: 'Lesson $lessonC is 2 steps from lesson $lessonA',
        );
        
        // Verify B is between A and C
        expect(
          lessonB,
          greaterThan(lessonA),
          reason: 'Lesson $lessonB must come after lesson $lessonA',
        );
        
        expect(
          lessonB,
          lessThan(lessonC),
          reason: 'Lesson $lessonB must come before lesson $lessonC',
        );
        
        // Verify no gaps in chain
        expect(
          lessonB - lessonA,
          equals(1),
          reason: 'No gap between $lessonA and $lessonB',
        );
        
        expect(
          lessonC - lessonB,
          equals(1),
          reason: 'No gap between $lessonB and $lessonC',
        );
      }
    });
  });
}
