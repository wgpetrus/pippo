# Implementation Plan: Lesson System

## Overview

This plan implements the core lesson system for Pippo, following a strict order-of-operations architecture to ensure data consistency across energy management, XP distribution, streak tracking, and progress persistence. The implementation follows GetX patterns with all logic contained in the LessonController.

## Tasks

- [ ] 1. Set up Firestore structure and data handling
  - Define Firestore collection paths as constants
  - Define document structure maps (no model classes)
  - Implement Timestamp ↔ DateTime conversion helpers
  - Create Map validation helpers for exercise types
  - _Requirements: 1.1, 8.1, 8.2, 8.3, 8.4_

- [ ] 1.1 Write property test for timestamp conversion
  - **Property 1: Timestamp Round Trip**
  - **Validates: Requirements 8.3, 12.5**

- [ ] 2. Implement LessonController with state management
  - [ ] 2.1 Create LessonController with mandatory states (isLoading, errorMessage)
    - Add observable states: currentLesson, currentExercises, currentExerciseIndex
    - Add execution states: hearts, correctAnswers, totalAnswers, startTime
    - Add feedback states: showFeedback, isCorrectAnswer, correctAnswerText
    - _Requirements: 3.1, 4.4, 4.5, 14.1_

  - [ ] 2.2 Write property test for state initialization
    - **Property 19: Exercise Index Progression**
    - **Validates: Requirements 14.1, 14.2, 14.3**

  - [ ] 2.3 Implement lesson validation methods
    - Add _isLessonUnlocked() to check previous lesson completed
    - Add _hasEnergy() to verify energy availability
    - Add _hasUnlimitedEnergy() to check unlimited status
    - Ensure first lesson (lessonId = 1) is always unlocked
    - _Requirements: 1.1, 1.2, 1.5, 10.1, 10.2_

  - [ ] 2.4 Write property test for lesson validation
    - **Property 16: Linear Progression**
    - **Validates: Requirements 10.1, 10.2, 10.3, 10.4**

  - [ ] 2.5 Implement energy management methods
    - Add _consumeEnergy() with atomic Firestore transaction
    - Add _calculateAvailableEnergy() using formula: min(5, currentEnergy + (minutesPassed ~/ 30))
    - Add _calculateMinutesUntilNextEnergy() using formula: 30 - (minutesPassed % 30)
    - _Requirements: 1.4, 1.6, 1.7_

  - [ ] 2.6 Write property test for energy formulas
    - **Property 3: Energy Regeneration Formula Consistency**
    - **Validates: Requirements 1.6, 1.7**

- [ ] 3. Implement lesson start sequence (CRITICAL ORDER)
  - [ ] 3.1 Create startLesson() method with exact order
    - Step 1: Validate lesson is unlocked
    - Step 2: Validate user has energy (or unlimited active)
    - Step 3: Consume energy (atomic operation)
    - Step 4: Initialize lesson state (hearts=3, counters=0, startTime)
    - Step 5: Load exercises from Firestore
    - Step 6: Navigate to first exercise
    - Handle errors: display message, do NOT consume energy on failure
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 3.1, 12.1, 14.1_

  - [ ] 3.2 Write property test for start sequence order
    - **Property 1: Lesson Start Order of Operations**
    - **Validates: Requirements 1.1, 1.2, 1.4**

  - [ ] 3.3 Write property test for energy consumption
    - **Property 2: Energy Consumption Atomicity**
    - **Validates: Requirements 1.4, 1.5, 12.1**

  - [ ] 3.4 Write unit test for 0 energy case
    - Test Low Energy Modal is shown
    - Test lesson does not start
    - _Requirements: 1.3_

- [ ] 4. Checkpoint - Ensure lesson start works correctly
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 5. Implement exercise validation for all types
  - [ ] 5.1 Create exercise validation methods
    - Add _validateImageExercise() to compare imageIds
    - Add _validateTranslationExercise() to compare text (case-sensitive, trimmed)
    - Add _validateWordOrderExercise() to compare ordered arrays
    - Add _validateMatchExercise() to verify all 4 pairs match
    - _Requirements: 2.2, 2.4, 2.6, 2.9, 11.1, 11.2, 11.3, 11.4, 11.5, 11.6_

  - [ ] 5.2 Write property test for exercise validation
    - **Property 4: Exercise Validation Type Safety**
    - **Validates: Requirements 2.2, 2.4, 2.6, 2.9, 11.1, 11.2, 11.3, 11.4**

  - [ ] 5.3 Write property test for input sanitization
    - **Property 17: Input Sanitization**
    - **Validates: Requirements 11.5, 11.6**

- [ ] 6. Implement answer submission and hearts management
  - [ ] 6.1 Create submitAnswer() method
    - Validate answer using appropriate validation method
    - Increment totalAnswers counter
    - If correct: increment correctAnswers
    - If incorrect: decrement hearts BEFORE showing feedback
    - Check if hearts = 0 (trigger failLesson())
    - Show feedback (correct/incorrect)
    - If last exercise and hearts > 0: trigger completeLesson()
    - _Requirements: 3.2, 3.3, 4.3, 4.4, 4.5_

  - [ ] 6.2 Write property test for hearts invariant
    - **Property 5: Hearts Invariant**
    - **Validates: Requirements 3.1, 3.2, 3.3, 3.6**

  - [ ] 6.3 Write property test for answer counters
    - **Property 7: Answer Counter Consistency**
    - **Validates: Requirements 4.4, 4.5, 4.7**

  - [ ] 6.4 Write property test for hearts decrement order
    - **Property 8: Hearts Decrement Before Feedback**
    - **Validates: Requirements 4.3**

- [ ] 7. Implement lesson failure handling
  - [ ] 7.1 Create failLesson() method
    - Set lesson state to failed
    - Display fail screen
    - Award zero rewards (XP = 0, gems = 0)
    - Do NOT refund consumed energy
    - Navigate to fail screen
    - _Requirements: 3.3, 3.4, 3.5_

  - [ ] 7.2 Write property test for failed lesson consequences
    - **Property 6: Failed Lesson Consequences**
    - **Validates: Requirements 3.4, 3.5**

- [ ] 8. Checkpoint - Ensure exercise execution works correctly
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 9. Implement reward calculation (CRITICAL ORDER)
  - [ ] 9.1 Create reward calculation methods
    - Add _calculateTotalXP() with exact order:
      - Start with base: lesson.xpReward
      - Add perfect bonus: +5 if accuracy == 100%
      - Add first today bonus: +5 if _isFirstLessonToday()
      - Apply XP Booster: multiply by 2 if active and not expired
    - Add _calculateTotalGems() with exact order:
      - Start with base: lesson.gemsReward
      - Apply Gem Multiplier: multiply by 2 if active and not expired
    - Add _checkBoosterExpiration() to compare current time with expiry
    - _Requirements: 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9, 13.1, 13.2, 13.3, 13.4, 13.5, 13.6_

  - [ ] 9.2 Write property test for reward calculation order
    - **Property 9: Reward Calculation Order**
    - **Validates: Requirements 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9, 13.5**

  - [ ] 9.3 Write property test for booster expiration
    - **Property 18: Booster Expiration**
    - **Validates: Requirements 13.1, 13.2, 13.3, 13.4, 13.6**

- [ ] 10. Implement XP distribution and level up
  - [ ] 10.1 Create XP distribution methods
    - Add _distributeXP() to add XP to all three counters atomically:
      - Add to totalXp (never resets)
      - Add to weeklyXp (resets Monday 00:00)
      - Add to todayXp (resets daily at midnight)
    - Add _checkAndLevelUp() to check if totalXp >= currentLevel * 100
    - If level up: increment currentLevel, do NOT reset totalXp
    - Add _calculateXPForNextLevel() using formula: currentLevel * 100
    - Use Firestore transaction for atomic updates
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7_

  - [ ] 10.2 Write property test for XP distribution
    - **Property 10: XP Distribution Atomicity**
    - **Validates: Requirements 6.1, 6.2, 6.3, 6.7**

  - [ ] 10.3 Write property test for level up formula
    - **Property 11: Level Up Formula**
    - **Validates: Requirements 6.4, 6.5, 6.6**

- [ ] 11. Implement streak management (user timezone)
  - [ ] 11.1 Create streak management methods
    - Add _isFirstLessonToday() to check if first lesson completed today
    - Add _getTodayDateString() to get date in YYYY-MM-DD format (user timezone)
    - Add _isYesterday() to compare dates
    - Add _updateStreak() with logic:
      - If last streak date is yesterday: increment currentStreak by 1
      - If last streak date is today: no change
      - If last streak date is before yesterday: reset currentStreak to 1
      - Update longestStreak if currentStreak exceeds it
      - Save current date as lastStreakDate
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8_

  - [ ] 11.2 Write property test for streak update logic
    - **Property 12: Streak Update Logic**
    - **Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8**

- [ ] 12. Checkpoint - Ensure rewards and streak work correctly
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 13. Implement lesson completion sequence (CRITICAL ORDER)
  - [ ] 13.1 Create completeLesson() method with exact order
    - Step 1: Calculate rewards (_calculateTotalXP, _calculateTotalGems)
    - Step 2: Distribute XP (_distributeXP)
    - Step 3: Add gems to totalGems
    - Step 4: Check and execute level up (_checkAndLevelUp)
    - Step 5: Update streak (only if first lesson today, _updateStreak)
    - Step 6: Save lesson progress (_saveLessonProgress)
    - Step 7: Update daily history (_updateDailyHistory)
    - Step 8: Update challenges (_updateChallenges)
    - Step 9: Unlock next lesson (_unlockNextLesson)
    - Step 10: Navigate to completion screen
    - Handle errors: retry up to 3 times, cache locally if all fail
    - _Requirements: 5.1, 8.1, 8.7, 9.5, 12.2, 12.3_

  - [ ] 13.2 Write property test for completion sequence order
    - **Property 13: Completion Sequence Order**
    - **Validates: Requirements 5.1, 8.1, 8.4, 8.7, 9.5**

- [ ] 14. Implement progress persistence
  - [ ] 14.1 Create progress persistence methods
    - Add _saveLessonProgress() to save to Firestore:
      - Path: users/{userId}/courses/{courseId}/progress/{lessonId}
      - Include: accuracy, xpEarned, gemsEarned, timeSpent (seconds), mistakes
      - Use FieldValue.serverTimestamp() for completedAt
    - Add _updateDailyHistory() to save/update history:
      - Path: users/{userId}/history/{YYYY-MM-DD}
      - Use user timezone for date calculation
      - Increment: lessonsCompleted, totalXp, totalGems, totalTime
    - Add _unlockNextLesson() to mark lesson N+1 as unlocked
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7_

  - [ ] 14.2 Write property test for progress data completeness
    - **Property 14: Progress Data Completeness**
    - **Validates: Requirements 8.2, 8.3**

  - [ ] 14.3 Write property test for history date format
    - **Property 15: History Date Format**
    - **Validates: Requirements 8.4, 8.5, 8.6**

- [ ] 15. Implement challenge updates
  - [ ] 15.1 Create challenge update methods
    - Add _updateChallenges() to update all active challenges
    - Increment relevant counters (lessonsCompleted, xpEarned, etc.)
    - Mark challenges as completed when goal is reached
    - Award challenge rewards
    - _Requirements: 9.1, 9.2, 9.3, 9.4_

  - [ ] 15.2 Write property test for challenge updates
    - **Property 23: Challenge Update Consistency**
    - **Validates: Requirements 9.1, 9.2, 9.3, 9.4**

- [ ] 16. Implement time tracking
  - [ ] 16.1 Create time tracking methods
    - Record startTime when lesson starts
    - Calculate elapsed time: completionTime - startTime (milliseconds)
    - Convert to seconds for storage
    - Track only active time (exclude pause time)
    - Accumulate time across resume sessions
    - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5, 15.6_

  - [ ] 16.2 Write property test for time tracking
    - **Property 21: Time Tracking Accuracy**
    - **Validates: Requirements 15.1, 15.2, 15.3, 15.4, 15.5, 15.6**

- [ ] 17. Checkpoint - Ensure completion and persistence work correctly
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 18. Implement lesson resume functionality
  - [ ] 18.1 Create resumeLesson() method
    - Load lesson progress from Firestore
    - Restore currentExerciseIndex
    - Restore hearts, correctAnswers, totalAnswers
    - Do NOT consume additional energy
    - Continue from saved exercise
    - _Requirements: 14.4, 14.5, 14.6_

  - [ ] 18.2 Write property test for resume without energy cost
    - **Property 20: Resume Without Energy Cost**
    - **Validates: Requirements 14.5, 14.6**

- [ ] 19. Implement error handling and retry logic
  - [ ] 19.1 Add error handling to all critical methods
    - Lesson start: display error, do NOT consume energy
    - Lesson completion: retry up to 3 times with exponential backoff
    - Save failure: cache progress locally, sync on next app open
    - Data loading: display error with retry button
    - Timestamp conversion: use fallback date (current date in user timezone)
    - Validate all exercise data exists before lesson start
    - Prevent concurrent lesson starts
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 12.7_

  - [ ] 19.2 Write property test for error handling
    - **Property 22: Error Handling Without Side Effects**
    - **Validates: Requirements 12.1, 12.2, 12.3**

  - [ ] 19.3 Write property test for concurrency prevention
    - **Property 25: Concurrency Prevention**
    - **Validates: Requirements 12.7**

- [ ] 20. Create LessonBinding for dependency injection
  - Register LessonController with Get.lazyPut()
  - Ensure controller is disposed properly
  - _Requirements: All_

- [ ] 21. Implement lesson views (UI only, no logic)
  - [ ] 21.1 Create ImageExercisePage
    - Use ExerciseHeader (progress, close, hearts)
    - Use MascotBubble for question
    - Display 4 ImageWithLabel options
    - Use FeedbackBottomSheet for feedback
    - Mark TODO comments for controller integration
    - _Requirements: 2.1, 2.2_

  - [ ] 21.2 Create TranslationExercisePage
    - Use ExerciseHeader
    - Use AudioCard for word with audio
    - Display 4 LessonOptionCard for translations
    - Use FeedbackBottomSheet
    - Mark TODO comments for controller integration
    - _Requirements: 2.3, 2.4_

  - [ ] 21.3 Create WordExercisePage
    - Use ExerciseHeader
    - Use MascotBubble for instruction
    - Use WordZone for answer area
    - Display WordChip list (draggable)
    - Use FeedbackBottomSheet
    - Mark TODO comments for controller integration
    - _Requirements: 2.5, 2.6_

  - [ ] 21.4 Create MatchExercisePage
    - Use ExerciseHeader
    - Display two columns of AudioWordButton
    - Show connection lines for pairs
    - Use FeedbackBottomSheet
    - Mark TODO comments for controller integration
    - _Requirements: 2.7, 2.8, 2.9_

  - [ ] 21.5 Create CompletePage
    - Display mascot celebrating
    - Show title "Lesson Complete!"
    - Display statistics (XP, accuracy, time)
    - Use AppButton "Continue"
    - Mark TODO comments for controller integration
    - _Requirements: 5.1_

  - [ ] 21.6 Create FailPage
    - Display sad mascot
    - Show title "Lesson Failed"
    - Display message about hearts
    - Use AppButton "Try Again"
    - Mark TODO comments for controller integration
    - _Requirements: 3.4_

- [ ] 22. Checkpoint - Ensure UI is complete
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 23. Connect views to controller (Etapa 8)
  - [ ] 23.1 Connect ImageExercisePage to controller
    - Add Get.find<LessonController>() in initState
    - Wrap reactive widgets with Obx()
    - Connect image selection to controller.submitAnswer()
    - Display hearts from controller.hearts.value
    - Show feedback from controller feedback states
    - Remove TODO comments
    - _Requirements: 2.2, 3.2, 4.1, 4.2_

  - [ ] 23.2 Connect TranslationExercisePage to controller
    - Add Get.find<LessonController>()
    - Wrap reactive widgets with Obx()
    - Connect translation selection to controller.submitAnswer()
    - Display hearts and feedback
    - Remove TODO comments
    - _Requirements: 2.4, 3.2, 4.1, 4.2_

  - [ ] 23.3 Connect WordExercisePage to controller
    - Add Get.find<LessonController>()
    - Wrap reactive widgets with Obx()
    - Connect word arrangement to controller.submitAnswer()
    - Display hearts and feedback
    - Remove TODO comments
    - _Requirements: 2.6, 3.2, 4.1, 4.2_

  - [ ] 23.4 Connect MatchExercisePage to controller
    - Add Get.find<LessonController>()
    - Wrap reactive widgets with Obx()
    - Connect pair matching to controller.submitAnswer()
    - Display hearts and feedback
    - Remove TODO comments
    - _Requirements: 2.9, 3.2, 4.1, 4.2_

  - [ ] 23.5 Connect CompletePage to controller
    - Display rewards from controller
    - Show level up if occurred
    - Connect continue button to navigation
    - Remove TODO comments
    - _Requirements: 5.1, 6.4_

  - [ ] 23.6 Connect FailPage to controller
    - Display fail message
    - Connect try again button to restart
    - Remove TODO comments
    - _Requirements: 3.4_

- [ ] 24. Add lesson routes to app_routes.dart
  - Add route for sections page (lesson selection)
  - Add routes for all exercise types
  - Add routes for complete/fail pages
  - Register LessonBinding
  - _Requirements: All_

- [ ] 25. Integrate with existing home flow
  - Connect lesson button in home to lesson start
  - Pass courseId and lessonId parameters
  - Handle navigation back to home after completion
  - Update home stats after lesson completion
  - _Requirements: All_

- [ ] 26. Final checkpoint - End-to-end testing
  - Test complete lesson flow (start → exercises → completion)
  - Test failed lesson flow (start → wrong answers → failure)
  - Test resume lesson flow (start → pause → resume → complete)
  - Test multiple lessons per day (streak logic)
  - Test all exercise types validate correctly
  - Test energy consumption and regeneration
  - Test XP distribution and level up
  - Test streak updates (first lesson of day)
  - Test history updates (YYYY-MM-DD format)
  - Test boosters apply correctly
  - Test error handling (network errors, retries)
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- All logic is contained in LessonController (no separate service classes)
- Follow EXACT order of operations for lesson start and completion
- Use Firestore transactions for atomic operations (energy, XP distribution)
- Use user timezone for streak and history dates (NOT UTC)
- All error messages in Portuguese and user-friendly
- Property tests run minimum 100 iterations each
- Each property test tagged with: Feature: lesson-system, Property N: [description]
- Views use StatefulWidget (complex state management)
- Obx() only where reactive updates needed
- Mark TODO comments in views during UI phase (Etapa 7)
- Remove TODO comments when connecting to controller (Etapa 8)
