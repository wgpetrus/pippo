# Implementation Plan: Gamification System

## Overview

This implementation plan covers the gamification system for Pippo, including streak tracking, energy management, XP/levels progression, and gems economy. The system is implemented as a single controller that integrates with existing features (Home, Lesson, Shop, Profile).

**IMPORTANT**: This gamification system is designed to integrate with future modules in this order:
1. **Lessons Module** (next) - Will call gamification methods for energy and rewards
2. **Challenges Module** - Will be called by gamification to update progress
3. **Ranking Module** - Will read weeklyXp from gamification stats
4. **Shop Module** - Will use gamification purchase methods
5. **Profile Module** - Already integrated, displays stats

The implementation includes conditional checks for future modules (e.g., `Get.isRegistered<ChallengesController>()`) to ensure the system works independently while being ready for future integrations.

## Tasks

- [x] 1. Create GamificationController structure and Firestore integration
  - Create `features/inners/gamification/controllers/gamification_controller.dart`
  - Implement observable states (isLoading, errorMessage, all gamification stats)
  - Implement Firestore load/save methods with error handling
  - Implement retry logic for Firestore operations
  - _Requirements: 13.1, 13.2, 13.5, 13.6, 13.7, 15.6_

- [x] 2. Implement energy system
  - [x] 2.1 Implement energy regeneration algorithm
    - Write `_calculateEnergyRegeneration()` method
    - Implement formula: energiesToAdd = minutesPassed ~/ 30
    - Cap energy at maxEnergy (5)
    - Update lastEnergyRegenAt timestamp
    - _Requirements: 3.1, 3.4, 3.5, 3.6_
  
  - [x] 2.2 Write property test for energy regeneration
    - **Property 11: Energy Regeneration Formula**
    - **Validates: Requirements 3.4, 3.5**
  
  - [x] 2.3 Implement energy consumption
    - Write `_consumeEnergy()` method
    - Decrement energy by 1
    - Update lastEnergyRegenAt
    - Implement `canStartLesson()` validation
    - _Requirements: 3.2, 3.3, 3.7_
  
  - [x] 2.4 Write property test for energy consumption
    - **Property 12: Energy Consumption and Timestamp Update**
    - **Validates: Requirements 3.2, 3.3**
  
  - [x] 2.5 Implement energy refill purchase
    - Write `purchaseEnergyRefill()` method
    - Validate gems >= 100
    - Deduct 100 gems, add 5 energy (capped at max)
    - Update Firestore
    - _Requirements: 4.1, 4.2, 9.1_
  
  - [x] 2.6 Write property test for energy refill
    - **Property 15: Energy Refill Transaction**
    - **Validates: Requirements 4.1, 4.2, 9.1**
  
  - [x] 2.7 Implement unlimited energy
    - Add unlimitedEnergyUntil field handling
    - Implement hasUnlimitedEnergy getter
    - Skip energy consumption when unlimited active
    - _Requirements: 4.3, 4.4, 4.5_

- [x] 3. Implement streak system
  - [x] 3.1 Implement streak update algorithm
    - Write `_updateStreak()` method
    - Handle first lesson ever case
    - Handle consecutive day case
    - Handle missed day with freeze case
    - Handle streak broken case
    - Use user timezone for date calculations
    - _Requirements: 1.1, 1.2, 1.4, 1.5, 1.6, 1.7_
  
  - [x] 3.2 Write property test for first lesson increments streak
    - **Property 5: First Lesson Increments Streak**
    - **Validates: Requirements 1.1, 1.4**
  
  - [x] 3.3 Write property test for missed day resets streak
    - **Property 6: Missed Day Resets Streak**
    - **Validates: Requirements 1.2**
  
  - [x] 3.4 Write property test for multiple lessons same day
    - **Property 7: Multiple Lessons Same Day**
    - **Validates: Requirements 1.6**
  
  - [x] 3.5 Implement streak freeze system
    - Write `purchaseStreakFreeze()` method
    - Implement freeze consumption logic
    - Implement daily freeze reset
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [x] 3.6 Write property test for streak freeze
    - **Property 8: Streak Freeze Consumption**
    - **Validates: Requirements 1.7, 2.2**
  
  - [x] 3.7 Implement streak milestones
    - Write `_checkStreakMilestones()` method
    - Award gems at milestones (7, 14, 30, 100 days)
    - Track milestonesReached array
    - _Requirements: 1.8_

- [x] 4. Checkpoint - Ensure energy and streak tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Implement XP and level system
  - [x] 5.1 Implement XP addition algorithm
    - Write `_addXp()` method
    - Apply XP booster if active (2×)
    - Check and apply XP resets (weekly, daily)
    - Update totalXp, weeklyXp, todayXp atomically
    - _Requirements: 5.1, 5.2, 5.5, 5.6_
  
  - [x] 5.2 Write property test for XP triple update atomicity
    - **Property 20: XP Triple Update Atomicity**
    - **Validates: Requirements 5.6, 7.5**
  
  - [x] 5.3 Write property test for XP booster
    - **Property 21: XP Booster Doubles Gains**
    - **Validates: Requirements 5.5**
  
  - [x] 5.4 Implement level up algorithm
    - Write `_checkLevelUp()` method
    - Implement formula: xpToNextLevel = level × 100
    - Process multiple level ups sequentially
    - Award 10 gems per level up
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.6_
  
  - [x] 5.5 Write property test for level formula
    - **Property 17: Level Formula Correctness**
    - **Validates: Requirements 6.1**
  
  - [x] 5.6 Write property test for level up trigger
    - **Property 18: Level Up Trigger and Reward**
    - **Validates: Requirements 6.2, 6.3, 6.4**
  
  - [x] 5.7 Implement XP resets
    - Write `_checkXpResets()` method
    - Reset weeklyXp on Monday 00:00
    - Reset todayXp at midnight
    - Use user timezone for calculations
    - _Requirements: 7.1, 7.2, 7.4_
  
  - [x] 5.8 Write property test for XP resets
    - **Property 24: Weekly XP Reset**
    - **Property 25: Daily XP Reset**
    - **Validates: Requirements 7.1, 7.2**
  
  - [x] 5.9 Implement lesson bonuses
    - Add perfect lesson bonus (+5 XP)
    - Add first lesson of day bonus (+5 XP)
    - Implement `_isFirstLessonOfDay()` helper
    - _Requirements: 5.3, 5.4_

- [x] 6. Implement gems economy
  - [x] 6.1 Implement gem addition
    - Write `_addGems()` method
    - Apply gem multiplier if active (2×)
    - Update gems and totalGemsEarned atomically
    - _Requirements: 8.1, 8.7, 8.8_
  
  - [x] 6.2 Write property test for gems dual update
    - **Property 27: Gems Dual Update Atomicity**
    - **Validates: Requirements 8.8**
  
  - [x] 6.3 Write property test for gem multiplier
    - **Property 26: Gem Multiplier Doubles Gains**
    - **Validates: Requirements 8.7**
  
  - [x] 6.4 Implement gem spending
    - Update gems and totalGemsSpent atomically
    - Validate sufficient gems before purchase
    - _Requirements: 9.6, 9.7_
  
  - [x] 6.5 Write property test for insufficient gems
    - **Property 29: Insufficient Gems Prevention**
    - **Validates: Requirements 9.7**

- [x] 7. Implement power-ups
  - [x] 7.1 Implement XP booster purchase
    - Write `purchaseXpBooster()` method
    - Deduct 150 gems
    - Set xpBoosterUntil to current time + 1 hour
    - Prevent duplicate purchase if already active
    - _Requirements: 9.3, 10.1, 10.5_
  
  - [x] 7.2 Implement gem multiplier purchase
    - Write `purchaseGemMultiplier()` method
    - Deduct 200 gems
    - Set gemMultiplierUntil to current time + 1 hour
    - Prevent duplicate purchase if already active
    - _Requirements: 9.4, 10.2, 10.6_
  
  - [x] 7.3 Write property test for power-up activation
    - **Property 31: Power-Up Activation Timestamp**
    - **Validates: Requirements 10.1, 10.2**
  
  - [x] 7.4 Write property test for power-up idempotence
    - **Property 33: Power-Up Purchase Idempotence**
    - **Validates: Requirements 10.5, 10.6**
  
  - [x] 7.5 Implement power-up expiration
    - Implement hasXpBooster getter
    - Implement hasGemMultiplier getter
    - Check current time < expiration timestamp
    - _Requirements: 10.3, 10.4_

- [x] 8. Checkpoint - Ensure XP, gems, and power-up tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 9. Implement lesson completion flow
  - [x] 9.1 Implement onLessonStart method
    - Check canStartLesson()
    - Call _calculateEnergyRegeneration()
    - Call _consumeEnergy()
    - Save to Firestore
    - _Requirements: 3.2, 3.7_
  
  - [x] 9.2 Implement onLessonComplete method
    - Calculate total rewards (base + bonuses)
    - Add XP with booster
    - Add gems with multiplier
    - Update streak if first lesson of day
    - Check streak milestones
    - Check level up
    - **Add conditional call to ChallengesController (if registered)**
    - Save to Firestore in transaction
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 11.6_
  
  - [x] 9.3 Write property test for reward calculation order
    - **Property 34: Reward Calculation Order**
    - **Validates: Requirements 11.1, 11.2, 11.3, 11.4, 11.5**
  
  - [x] 9.4 Write property test for transaction atomicity
    - **Property 35: Transaction Atomicity**
    - **Validates: Requirements 11.6**
  
  - [x] 9.5 Add future module integration hooks
    - Add conditional check for ChallengesController registration
    - Implement call to challenges.updateProgress() if available
    - Add TODO comments for future Lessons module integration
    - Document integration points in code comments
    - _Note: Ensures backward compatibility while preparing for future modules_

- [x] 10. Implement invariant properties
  - [x] 10.1 Write property test for streak invariant
    - **Property 1: Streak Invariant**
    - **Validates: Requirements 1.3**
  
  - [x] 10.2 Write property test for total XP never decreases
    - **Property 2: Total XP Never Decreases**
    - **Validates: Requirements 6.5, 7.3**
  
  - [x] 10.3 Write property test for energy bounds
    - **Property 3: Energy Bounds**
    - **Validates: Requirements 3.1, 15.1, 15.2**
  
  - [x] 10.4 Write property test for non-negative resources
    - **Property 4: Non-Negative Resources**
    - **Validates: Requirements 15.3, 15.4**

- [x] 11. Implement timezone utilities
  - [x] 11.1 Implement date formatting helpers
    - Write `_formatDateForStreak()` method (YYYY-MM-DD)
    - Write `_isSameDay()` method
    - Write `_isMonday()` method
    - Use DateTime.now() for user timezone
    - _Requirements: 1.4, 1.5, 7.4_
  
  - [x] 11.2 Write property test for user timezone
    - **Property 44: User Timezone for Date Operations**
    - **Validates: Requirements 1.5, 7.4**

- [x] 12. Integrate with HomeBinding
  - [x] 12.1 Update HomeBinding to instantiate GamificationController
    - Add `Get.lazyPut<GamificationController>(() => GamificationController())`
    - Ensure AuthController is instantiated first
    - _Requirements: 12.1, 12.2, 12.3_

- [x] 13. Update HomeAppbar to display gamification stats
  - [x] 13.1 Add Obx widgets for streak, energy, gems
    - Display currentStreak with fire icon
    - Display currentEnergy with bolt icon
    - Display gems with diamond icon
    - Make each stat clickable to open modal
    - _Requirements: 1.1, 3.1, 8.1_

- [x] 14. Update existing modals to use GamificationController
  - [x] 14.1 Update StreakModal
    - Get GamificationController with Get.find()
    - Display currentStreak and longestStreak
    - Show streak freeze purchase option
    - _Requirements: 1.1, 1.3, 2.1_
  
  - [x] 14.2 Update EnergyModal
    - Get GamificationController with Get.find()
    - Display currentEnergy and maxEnergy
    - Show next energy regeneration time
    - Show energy refill purchase option
    - _Requirements: 3.1, 3.8, 4.1_
  
  - [x] 14.3 Update GemsModal
    - Get GamificationController with Get.find()
    - Display gems and totalGemsEarned
    - Show gem purchase options (IAP placeholder)
    - _Requirements: 8.1, 8.8_

- [x] 15. Integrate with LessonController
  - [x] 15.1 Update LessonController to check energy before starting
    - Call gamification.canStartLesson()
    - Show LowEnergyModal if insufficient energy
    - Call gamification.onLessonStart() when starting
    - _Requirements: 3.2, 3.7_
  
  - [x] 15.2 Update LessonController to award rewards on completion
    - Calculate baseXp and baseGems based on performance
    - Determine isPerfect flag
    - Call gamification.onLessonComplete()
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 8.1_

- [x] 16. Integrate with Shop
  - [x] 16.1 Update BoostItem widgets to call purchase methods
    - Energy refill → gamification.purchaseEnergyRefill()
    - XP booster → gamification.purchaseXpBooster()
    - Gem multiplier → gamification.purchaseGemMultiplier()
    - Streak freeze → gamification.purchaseStreakFreeze()
    - Show success/error snackbar
    - _Requirements: 9.1, 9.2, 9.3, 9.4_

- [x] 17. Integrate with Profile
  - [x] 17.1 Update ProfilePage to display gamification stats
    - Show totalXp in OverviewCard
    - Show level in OverviewCard
    - Show currentStreak in OverviewCard
    - Show longestStreak in OverviewCard
    - Use Obx for reactive updates
    - _Requirements: 1.1, 1.3, 6.1, 6.2_

- [x] 18. Implement history tracking (optional)
  - [x] 18.1 Create history subcollection structure
    - Store lesson completions with date, XP, gems
    - Store streak milestones with date, milestone value
    - Store level ups with date, new level
    - Use "YYYY-MM-DD" format for dates
    - _Requirements: 14.1, 14.2, 14.3, 14.4_
  
  - [x] 18.2 Implement history retention
    - Query history with date range filter
    - Limit to most recent 365 days
    - _Requirements: 14.5, 14.6_

- [x] 19. Final checkpoint - Integration testing
  - Ensure all tests pass, ask the user if questions arise.

- [x] 20. Error handling and edge cases
  - [x] 20.1 Write unit tests for edge cases
    - Test energy at 0 (lower bound)
    - Test energy at 5 (upper bound)
    - Test negative XP rejection
    - Test negative gems rejection
    - Test invalid level calculation
  
  - [x] 20.2 Implement error recovery
    - Test Firestore failure scenarios
    - Verify retry logic works
    - Verify user-friendly error messages
    - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5, 15.6, 15.7_

## Notes

- All tasks include comprehensive testing (property-based and unit tests)
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties (minimum 100 iterations each)
- Unit tests validate specific examples and edge cases
- Integration tasks connect gamification with existing features (Home, Lesson, Shop, Profile)
- After completion, refer to design.md section "Future Module Integration Points" for details on how future modules will integrate
