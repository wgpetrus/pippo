# Implementation Plan: Treasure Challenges System

## Overview

This implementation plan covers the treasure challenges system for Pippo, including daily, weekly, and special challenges with automatic progress tracking and reward distribution. The system integrates with existing features (Lessons, Gamification) and is implemented as Tab 3 (Treasure) in the home navigation.

**IMPORTANT**: This treasure challenges system is designed to integrate with existing modules:
1. **Gamification Module** (existing) - Provides gems and XP that challenges reward
2. **Lessons Module** (existing) - Triggers challenge progress updates on lesson completion
3. **Profile Module** (existing) - May display challenge statistics in the future

The implementation works directly with `Map<String, dynamic>` from Firestore (no models, repositories, or services) and includes conditional checks to ensure the system works independently while being ready for integrations.

## Tasks

- [x] 1. Create TreasureController structure and Firestore integration
  - Create `features/inners/treasure/controllers/treasure_controller.dart`
  - Implement observable states (isLoading, errorMessage, challenges list, isClaimingReward)
  - Implement Firestore load/save methods with error handling
  - Implement retry logic for Firestore operations
  - Work directly with `Map<String, dynamic>` (no models)
  - _Requirements: 9.1, 9.2, 9.4, 9.5_

- [x] 2. Implement helper methods for challenge data
  - [x] 2.1 Implement challenge validation helpers
    - Write `_isCompleted(Map<String, dynamic> challenge)` method
    - Write `_isExpired(Map<String, dynamic> challenge)` method
    - Write `_canClaim(Map<String, dynamic> challenge)` method
    - Write `_getProgressPercentage(Map<String, dynamic> challenge)` method
    - _Requirements: 4.1, 4.2, 4.5, 6.1, 6.2, 7.1, 7.2_
  
  - [x] 2.2 Implement expiration calculation
    - Write `calculateExpiration(String type, {DateTime? customDate})` method
    - Implement Daily expiration: midnight (23:59:59) of current day
    - Implement Weekly expiration: Sunday 23:59:59 of current week
    - Implement Special expiration: custom date parameter
    - Use DateTime.now() for user timezone
    - _Requirements: 1.2, 1.3, 1.4, 6.4, 6.5, 6.6_
  
  - [x] 2.3 Write property test for expiration consistency
    - **Property 1: Challenge Type Expiration Consistency**
    - **Property 2: Weekly Challenge Expiration Consistency**
    - **Property 3: Special Challenge Custom Expiration**
    - **Validates: Requirements 1.2, 1.3, 1.4**

- [x] 3. Implement challenge loading system
  - [x] 3.1 Implement challenge fetching from Firestore
    - Write `loadChallenges()` method
    - Query `users/{userId}/challenges` collection
    - Load data as `List<Map<String, dynamic>>`
    - Filter expired challenges using `_isExpired()`
    - Sort by type (daily, weekly, special) and expiration date
    - Update challenges observable list
    - _Requirements: 9.4, 6.1, 6.7_
  
  - [x] 3.2 Write property test for active challenges retrieval
    - **Property 29: Active Challenges Retrieval**
    - **Validates: Requirements 9.4**
  
  - [x] 3.3 Implement expired challenge removal
    - Write `removeExpiredChallenges()` method
    - Filter challenges using `_isExpired()`
    - Delete expired challenges from Firestore
    - Update local challenges list
    - Call on controller init and page entry
    - _Requirements: 6.2, 6.3, 6.7_
  
  - [x] 3.4 Write property test for expired challenge removal
    - **Property 22: Expired Challenge Removal**
    - **Validates: Requirements 6.2**

- [x] 4. Checkpoint - Ensure loading and expiration tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Implement challenge progress tracking
  - [x] 5.1 Implement progress update algorithm
    - Write `updateChallengeProgress(String challengeType, int amount)` method
    - Query active challenges matching challengeType
    - Increment progress using FieldValue.increment (atomic)
    - Check if progress >= goal using `_isCompleted()`
    - Mark as completed when goal reached
    - Save to Firestore
    - Update local state
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.1, 4.2_
  
  - [x] 5.2 Write property test for progress update
    - **Property 9: Progress Update on Events**
    - **Validates: Requirements 3.1, 3.2, 3.3, 3.4**
  
  - [x] 5.3 Write property test for completion detection
    - **Property 10: Completion Detection**
    - **Validates: Requirements 3.5, 4.1, 4.2**
  
  - [x] 5.4 Write property test for progress persistence
    - **Property 11: Progress Persistence**
    - **Validates: Requirements 3.6**
  
  - [x] 5.5 Implement progress validation
    - Validate progress value is non-negative
    - Validate challenge exists and is active
    - Validate challenge is not expired
    - Reject invalid updates with descriptive errors
    - _Requirements: 10.2, 4.5_
  
  - [x] 5.6 Write property test for non-negative progress
    - **Property 31: Non-Negative Progress Validation**
    - **Validates: Requirements 10.2**

- [x] 6. Implement reward claiming system
  - [x] 6.1 Implement reward claim validation
    - Write `claimReward(String challengeId)` method
    - Validate challenge is completed using `_isCompleted()`
    - Validate reward not already claimed
    - Validate challenge not expired using `_isExpired()`
    - Validate user is authenticated
    - Validate challenge belongs to authenticated user
    - _Requirements: 5.1, 5.2, 5.3, 10.3, 10.4_
  
  - [x] 6.2 Write property tests for claim validation
    - **Property 14: Claim Requires Completion**
    - **Property 15: Claim Requires Not Already Claimed**
    - **Property 16: Claim Requires Not Expired**
    - **Property 32: User Ownership Validation**
    - **Validates: Requirements 5.1, 5.2, 5.3, 6.3, 10.3, 10.4**
  
  - [x] 6.3 Implement reward distribution
    - Add gems reward to user's gems in Firestore
    - Add XP reward to user's XP in Firestore
    - Use Firestore transaction for atomicity
    - Update GamificationController state if registered
    - _Requirements: 5.4, 5.5, 8.5, 8.6_
  
  - [x] 6.4 Write property tests for reward application
    - **Property 17: Gems Reward Application**
    - **Property 18: XP Reward Application**
    - **Validates: Requirements 5.4, 5.5, 8.5, 8.6**
  
  - [x] 6.5 Implement claim finalization
    - Mark challenge as claimed with timestamp
    - Save claimedAt to Firestore
    - Remove from active challenges list
    - Show reward animation
    - _Requirements: 5.6, 5.7, 5.8, 9.3_
  
  - [x] 6.6 Write property test for claimed status
    - **Property 19: Claimed Status Persistence**
    - **Property 20: Claimed Challenge Removal**
    - **Validates: Requirements 5.6, 5.8, 7.5, 9.3**

- [x] 7. Checkpoint - Ensure progress and reward tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 8. Implement challenge state display logic
  - [x] 8.1 Implement state determination methods
    - Implement logic for "In Progress" state (progress < goal)
    - Implement logic for "Completed" state (progress >= goal, not claimed)
    - Implement logic for button enable/disable
    - Implement logic for glow animation trigger
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.6_
  
  - [x] 8.2 Write property tests for state display
    - **Property 26: In Progress State Display**
    - **Property 27: Completed State Display**
    - **Property 12: Completed Challenge Button State**
    - **Validates: Requirements 7.1, 7.2, 7.3, 7.6, 11.5, 11.6**

- [x] 9. Implement challenge creation and validation
  - [x] 9.1 Implement challenge structure validation
    - Validate all required fields present (title, description, goal, etc.)
    - Validate goal is positive integer
    - Validate reward amount is positive
    - Validate reward type is one of: gems, xp, item
    - Initialize progress to zero
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 10.1_
  
  - [x] 9.2 Write property tests for challenge validation
    - **Property 4: Challenge Structure Completeness**
    - **Property 5: Goal Validation**
    - **Property 6: Reward Amount Validation**
    - **Property 7: Reward Type Validation**
    - **Property 8: Initial Progress Zero**
    - **Property 30: Required Fields Validation**
    - **Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5, 10.1**
  
  - [x] 9.3 Implement challenge generation (optional)
    - Create challenge templates as `Map<String, dynamic>`
    - Write `generateDailyChallenges()` method
    - Write `generateWeeklyChallenges()` method
    - Calculate expiration using `calculateExpiration()`
    - Save to Firestore under `users/{userId}/challenges`
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [x] 10. Integrate with existing modules
  - [x] 10.1 Integrate with LessonController
    - Add conditional check for TreasureController registration
    - Call `updateChallengeProgress('lessons', 1)` after lesson completion
    - Call `updateChallengeProgress('correct_exercises', count)` after exercises
    - Handle errors gracefully
    - _Requirements: 3.1, 3.3, 8.1, 8.3_
  
  - [x] 10.2 Integrate with GamificationController
    - Add conditional check for TreasureController registration
    - Call `updateChallengeProgress('xp', amount)` after XP gain
    - Call `updateChallengeProgress('streak', 1)` after streak update
    - Handle errors gracefully
    - _Requirements: 3.2, 3.4, 8.2, 8.4_
  
  - [x] 10.3 Add future module integration hooks
    - Add conditional checks for module registration
    - Add TODO comments for future integrations
    - Document integration points in code comments
    - _Note: Ensures backward compatibility while preparing for future modules_

- [x] 11. Update TreasurePage UI
  - [x] 11.1 Connect TreasurePage to TreasureController
    - Get TreasureController with Get.find()
    - Display challenges list with Obx
    - Show loading state while fetching
    - Show empty state when no challenges
    - Show error state on failures
    - Use ResponsiveUtils for all dimensions
    - _Requirements: 11.1, 11.2, 11.3, 11.12, 11.13, 14.1, 14.2, 14.5_
  
  - [x] 11.2 Implement pull-to-refresh
    - Add RefreshIndicator widget
    - Call loadChallenges() on refresh
    - Show loading indicator during refresh
    - _Requirements: 12.5_
  
  - [x] 11.3 Implement scroll position maintenance
    - Save scroll position on navigation away
    - Restore scroll position on return
    - _Requirements: 12.6_

- [x] 12. Update ChallengeCard widget
  - [x] 12.1 Connect ChallengeCard to controller
    - Accept `Map<String, dynamic> challengeData` parameter
    - Display title, description from map
    - Display progress bar with `_getProgressPercentage()`
    - Display goal text (e.g., "1/3 lessons")
    - Display reward icon and amount
    - Use ResponsiveUtils for dimensions
    - _Requirements: 11.4, 14.1, 14.2, 14.3_
  
  - [x] 12.2 Implement claim button states
    - Disable button when in progress (gray color)
    - Enable button when completed (primary color)
    - Show loading spinner during claim
    - Add glow animation when completed
    - Call controller.claimReward() on tap
    - _Requirements: 11.5, 11.6, 11.7, 13.1_
  
  - [x] 12.3 Implement error handling in UI
    - Display error messages from controller
    - Use Firebase error handlers for user-friendly messages
    - Show error snackbar or modal
    - _Requirements: 10.5, 13.7_

- [x] 13. Create new UI widgets
  - [x] 13.1 Create RewardAnimationModal widget
    - Show full-screen modal on reward claim
    - Display reward type icon (gem or XP)
    - Display reward amount with animation
    - Add celebratory effects (confetti, particles)
    - Auto-dismiss after 2 seconds
    - _Requirements: 5.7, 11.7, 13.2, 13.3, 13.4_
  
  - [x] 13.2 Create EmptyState widget
    - Display treasure mascot
    - Display friendly message ("No challenges available")
    - Use ResponsiveUtils for layout
    - _Requirements: 11.13, 14.1_
  
  - [x] 13.3 Create ProgressIndicatorWidget
    - Custom progress bar for challenges
    - Animate progress changes smoothly
    - Show percentage or fraction (1/3)
    - Use AppTheme colors
    - _Requirements: 13.5, 14.1_

- [x] 14. Checkpoint - Ensure UI integration tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 15. Implement invariant properties
  - [x] 15.1 Write property test for challenge display completeness
    - **Property 33: Challenge Display Completeness**
    - **Property 34: Active Challenges List Display**
    - **Validates: Requirements 11.3, 11.4**
  
  - [x] 15.2 Write property test for no completion on claimed/expired
    - **Property 13: No Completion for Claimed or Expired**
    - **Validates: Requirements 4.5**
  
  - [x] 15.3 Write property test for expiration check on load
    - **Property 21: Expiration Check on Load**
    - **Property 23: Daily Challenge Expiration Logic**
    - **Property 24: Weekly Challenge Expiration Logic**
    - **Property 25: Special Challenge Expiration Logic**
    - **Validates: Requirements 6.1, 6.4, 6.5, 6.6**

- [x] 16. Implement responsive design
  - [x] 16.1 Apply ResponsiveUtils throughout
    - Use ResponsiveUtils for all widget dimensions
    - Use spacing constants (spacing8, spacing16, etc.)
    - Use font size constants (fontSize14, fontSize16, etc.)
    - Wrap content in SafeArea
    - Use SingleChildScrollView to prevent overflow
    - _Requirements: 11.9, 14.1, 14.2, 14.3, 14.4, 14.5_
  
  - [x] 16.2 Test on multiple screen sizes
    - Test on mobile (375x667)
    - Test on tablet (820x1180)
    - Test on desktop (1920x1080)
    - Verify touch targets are at least 48x48
    - Verify aspect ratios are maintained
    - _Requirements: 14.6, 14.7, 14.8_

- [x] 17. Integrate with HomeBinding
  - [x] 17.1 Update HomeBinding to instantiate TreasureController
    - Add `Get.lazyPut<TreasureController>(() => TreasureController())`
    - Ensure AuthController is instantiated first
    - Ensure GamificationController is instantiated first
    - _Requirements: 12.1_

- [x] 18. Update home navigation
  - [x] 18.1 Verify Tab 3 navigation
    - Verify Treasure tab is Tab 3 in bottom navigation
    - Verify tapping tab navigates to TreasurePage
    - Verify tab highlights when active
    - Verify navigation doesn't clear stack
    - _Requirements: 11.1, 12.1, 12.2, 12.3_
  
  - [x] 18.2 Implement real-time updates
    - Update treasure page when challenge completed in other tab
    - Refresh data when returning to treasure page
    - Use Obx for reactive updates
    - _Requirements: 12.4, 12.5_

- [x] 19. Final checkpoint - Integration testing
  - Ensure all tests pass, ask the user if questions arise.

- [x] 20. Error handling and edge cases
  - [x] 20.1 Write unit tests for edge cases
    - Test claiming reward from expired challenge
    - Test claiming reward from already claimed challenge
    - Test claiming reward from incomplete challenge
    - Test progress update on non-existent challenge
    - Test loading challenges with Firestore error
    - Test empty challenges list display
  
  - [x] 20.2 Implement error recovery
    - Test Firestore failure scenarios
    - Verify retry logic works
    - Verify user-friendly error messages in Portuguese
    - Test network timeout handling
    - Test permission denied scenarios
    - _Requirements: 9.5, 10.5, 13.7_

## Notes

- All tasks include comprehensive testing (property-based and unit tests)
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties (minimum 100 iterations each)
- Unit tests validate specific examples and edge cases
- Integration tasks connect treasure challenges with existing features (Lessons, Gamification, Home)
- **CRITICAL**: Never create models, repositories, or services - work directly with `Map<String, dynamic>`
- After completion, the system will be ready for future enhancements (Cloud Functions for challenge generation, analytics, etc.)
