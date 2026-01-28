# Implementation Plan: Shop System

## Overview

This implementation plan covers the shop system for Pippo, including gem-based purchases of boosts (Energy Refill, XP Booster, Gem Multiplier, Streak Freeze) with validation, error handling, and UI feedback. The system is fully integrated into the existing `GamificationController` and `ShopPage` - **core functionality is already implemented**. This plan focuses on comprehensive testing and optional UI enhancements.

**IMPORTANT**: The shop system is designed to work with existing modules:
1. **GamificationController** (existing) - Contains all purchase methods and state management
2. **ShopPage** (existing) - UI is complete and matches Figma design
3. **Lesson Module** (existing) - Boosts are automatically applied during lesson completion
4. **Streak Module** (existing) - Streak freeze is automatically consumed when needed

The implementation follows strict steering rules: **NO models, repositories, or services** - all logic resides directly in `GamificationController`. The system uses atomic Firestore operations with automatic rollback on failure.

## Tasks

- [x] 1. Unit Tests - Energy Refill Purchase
  - [x] 1.1 Test successful energy refill purchase
    - Setup: User has 200 gems, 0 energy
    - Execute: Call `purchaseEnergyRefill()`
    - Verify: Gems reduced by 100, energy increased to 5, no error message
    - _Requirements: 2.1, 2.3, 2.5_
  
  - [x] 1.2 Test energy refill with insufficient gems
    - Setup: User has 50 gems
    - Execute: Call `purchaseEnergyRefill()`
    - Verify: Gems unchanged, energy unchanged, error message contains "gemas a mais"
    - _Requirements: 2.2, 6.1_
  
  - [x] 1.3 Test energy refill with energy cap
    - Setup: User has 200 gems, 3 energy
    - Execute: Call `purchaseEnergyRefill()`
    - Verify: Gems reduced by 100, energy capped at 5 (not 8)
    - _Requirements: 2.3_
  
  - [x] 1.4 Test energy refill with full energy
    - Setup: User has 200 gems, 5 energy
    - Execute: Call `purchaseEnergyRefill()`
    - Verify: Gems reduced by 100, energy stays at 5
    - _Requirements: 2.3_
  
  - [x] 1.5 Test energy refill authentication failure
    - Setup: Mock unauthenticated user
    - Execute: Call `purchaseEnergyRefill()`
    - Verify: Error message contains "não autenticado", state unchanged
    - _Requirements: 6.4_


- [x] 2. Unit Tests - XP Booster Purchase
  - [x] 2.1 Test successful XP booster purchase
    - Setup: User has 200 gems, no active booster
    - Execute: Call `purchaseXpBooster()`
    - Verify: Gems reduced by 150, `hasXpBooster` is true, expiration time set to now + 1 hour
    - _Requirements: 3.1, 3.3, 3.4, 3.5_
  
  - [x] 2.2 Test XP booster with insufficient gems
    - Setup: User has 100 gems
    - Execute: Call `purchaseXpBooster()`
    - Verify: Gems unchanged, `hasXpBooster` is false, error message contains "gemas a mais"
    - _Requirements: 3.1, 6.1_
  
  - [x] 2.3 Test XP booster idempotency
    - Setup: User has 300 gems, XP booster already active
    - Execute: Call `purchaseXpBooster()`
    - Verify: Gems unchanged, error message contains "já tem"
    - _Requirements: 3.2, 3.6_
  
  - [x] 2.4 Test XP booster expiration time
    - Setup: User has 200 gems
    - Execute: Call `purchaseXpBooster()`
    - Verify: Expiration time is exactly 1 hour from now (±1 second tolerance)
    - _Requirements: 3.4_
  
  - [x] 2.5 Test XP booster authentication failure
    - Setup: Mock unauthenticated user
    - Execute: Call `purchaseXpBooster()`
    - Verify: Error message contains "não autenticado", state unchanged
    - _Requirements: 6.4_

- [x] 3. Unit Tests - Gem Multiplier Purchase
  - [x] 3.1 Test successful gem multiplier purchase
    - Setup: User has 300 gems, no active multiplier
    - Execute: Call `purchaseGemMultiplier()`
    - Verify: Gems reduced by 200, `hasGemMultiplier` is true, expiration time set to now + 1 hour
    - _Requirements: 4.1, 4.3, 4.4, 4.5_
  
  - [x] 3.2 Test gem multiplier with insufficient gems
    - Setup: User has 150 gems
    - Execute: Call `purchaseGemMultiplier()`
    - Verify: Gems unchanged, `hasGemMultiplier` is false, error message contains "gemas a mais"
    - _Requirements: 4.1, 6.1_
  
  - [x] 3.3 Test gem multiplier idempotency
    - Setup: User has 400 gems, gem multiplier already active
    - Execute: Call `purchaseGemMultiplier()`
    - Verify: Gems unchanged, error message contains "já tem"
    - _Requirements: 4.2, 4.6_
  
  - [x] 3.4 Test gem multiplier expiration time
    - Setup: User has 300 gems
    - Execute: Call `purchaseGemMultiplier()`
    - Verify: Expiration time is exactly 1 hour from now (±1 second tolerance)
    - _Requirements: 4.4_
  
  - [x] 3.5 Test gem multiplier authentication failure
    - Setup: Mock unauthenticated user
    - Execute: Call `purchaseGemMultiplier()`
    - Verify: Error message contains "não autenticado", state unchanged
    - _Requirements: 6.4_

- [x] 4. Unit Tests - Streak Freeze Purchase
  - [x] 4.1 Test successful streak freeze purchase
    - Setup: User has 300 gems, no freeze available
    - Execute: Call `purchaseStreakFreeze()`
    - Verify: Gems reduced by 200, `streakFreezeAvailable` is true
    - _Requirements: 5.1, 5.3, 5.4, 5.5_
  
  - [x] 4.2 Test streak freeze with insufficient gems
    - Setup: User has 150 gems
    - Execute: Call `purchaseStreakFreeze()`
    - Verify: Gems unchanged, `streakFreezeAvailable` is false, error message contains "gemas a mais"
    - _Requirements: 5.1, 6.1_
  
  - [x] 4.3 Test streak freeze idempotency
    - Setup: User has 400 gems, freeze already available
    - Execute: Call `purchaseStreakFreeze()`
    - Verify: Gems unchanged, error message contains "já tem"
    - _Requirements: 5.2, 5.6_
  
  - [x] 4.4 Test streak freeze authentication failure
    - Setup: Mock unauthenticated user
    - Execute: Call `purchaseStreakFreeze()`
    - Verify: Error message contains "não autenticado", state unchanged
    - _Requirements: 6.4_


- [x] 5. Checkpoint - Unit Tests Complete
  - Ensure all unit tests pass, ask the user if questions arise.

- [x] 6. Property-Based Tests - Atomic Gem Transactions
  - [x] 6.1 Property 1: Atomic Gem Deduction
    - **Statement:** All gem transactions are atomic - either fully complete or fully revert
    - **Validates: Requirements 2.5, 3.5, 4.5, 5.5, 6.6**
    - Generate: Random initial gems (0-2000), random purchase type (0-3)
    - Execute: Attempt purchase
    - Assert: If success, gems and totalGemsSpent both updated; if failure, both unchanged
  
  - [x] 6.2 Property 2: Non-Negative Gem Balance
    - **Statement:** Gem balance can never become negative after any operation
    - **Validates: Requirements 6.1**
    - Generate: Random initial gems (0-1000), random purchase type (0-3)
    - Execute: Attempt purchase
    - Assert: `gems.value >= 0` always true
  
  - [x] 6.3 Property 3: Gem Spending Consistency
    - **Statement:** totalGemsSpent always equals sum of all successful purchases
    - **Validates: Requirements 2.5, 3.5, 4.5, 5.5**
    - Generate: Sequence of random purchases with sufficient gems
    - Execute: Perform all purchases
    - Assert: totalGemsSpent equals sum of all purchase costs

- [x] 7. Property-Based Tests - Idempotent Boost Activation
  - [x] 7.1 Property 4: XP Booster Idempotence
    - **Statement:** Purchasing an already-active XP booster fails without changing state
    - **Validates: Requirements 3.2, 3.6**
    - Generate: Random initial gems (sufficient)
    - Execute: Purchase XP booster twice
    - Assert: Second purchase fails, gems only deducted once
  
  - [x] 7.2 Property 5: Gem Multiplier Idempotence
    - **Statement:** Purchasing an already-active gem multiplier fails without changing state
    - **Validates: Requirements 4.2, 4.6**
    - Generate: Random initial gems (sufficient)
    - Execute: Purchase gem multiplier twice
    - Assert: Second purchase fails, gems only deducted once
  
  - [x] 7.3 Property 6: Streak Freeze Idempotence
    - **Statement:** Purchasing an already-available streak freeze fails without changing state
    - **Validates: Requirements 5.2, 5.6**
    - Generate: Random initial gems (sufficient)
    - Execute: Purchase streak freeze twice
    - Assert: Second purchase fails, gems only deducted once

- [x] 8. Property-Based Tests - Energy Cap Enforcement
  - [x] 8.1 Property 7: Energy Never Exceeds Maximum
    - **Statement:** Energy refill never exceeds maximum energy (5)
    - **Validates: Requirements 2.3**
    - Generate: Random initial energy (0-5)
    - Execute: Purchase energy refill
    - Assert: `currentEnergy.value <= 5` always true
  
  - [x] 8.2 Property 8: Energy Addition Correctness
    - **Statement:** Energy refill adds exactly 5 energy or caps at 5
    - **Validates: Requirements 2.3**
    - Generate: Random initial energy (0-5)
    - Execute: Purchase energy refill
    - Assert: If initial < 5, new energy = min(initial + 5, 5)


- [x] 9. Property-Based Tests - Boost Expiration Consistency
  - [x] 9.1 Property 9: XP Booster Expiration Time
    - **Statement:** XP booster expiration time is always in the future when activated
    - **Validates: Requirements 3.4**
    - Generate: Random initial state
    - Execute: Purchase XP booster
    - Assert: Expiration time > now and <= now + 1 hour
  
  - [x] 9.2 Property 10: Gem Multiplier Expiration Time
    - **Statement:** Gem multiplier expiration time is always in the future when activated
    - **Validates: Requirements 4.4**
    - Generate: Random initial state
    - Execute: Purchase gem multiplier
    - Assert: Expiration time > now and <= now + 1 hour
  
  - [x] 9.3 Property 11: Boost Expiration Check
    - **Statement:** hasXpBooster and hasGemMultiplier correctly check expiration
    - **Validates: Requirements 3.6, 4.6**
    - Generate: Random expiration time (past, present, future)
    - Execute: Check hasXpBooster/hasGemMultiplier
    - Assert: Returns true only if expiration time > now

- [x] 10. Property-Based Tests - Rollback Completeness
  - [x] 10.1 Property 12: Complete State Rollback on Error
    - **Statement:** On any error, all state changes are fully reverted
    - **Validates: Requirements 6.6**
    - Generate: Random initial state
    - Execute: Mock Firestore error, attempt purchase
    - Assert: All state values match initial state after rollback
  
  - [x] 10.2 Property 13: Rollback Preserves Consistency
    - **Statement:** Rollback maintains consistency between gems and totalGemsSpent
    - **Validates: Requirements 6.6**
    - Generate: Random initial state
    - Execute: Mock Firestore error, attempt purchase
    - Assert: gems and totalGemsSpent relationship unchanged

- [x] 11. Property-Based Tests - Validation Order Consistency
  - [x] 11.1 Property 14: Authentication Checked First
    - **Statement:** Authentication validation happens before gem validation
    - **Validates: Requirements 6.4**
    - Generate: Unauthenticated user with sufficient gems
    - Execute: Attempt purchase
    - Assert: Error message contains "não autenticado" (not "gemas")
  
  - [x] 11.2 Property 15: Gem Balance Checked Before Idempotency
    - **Statement:** Gem balance validation happens before idempotency check
    - **Validates: Requirements 6.1, 3.2, 4.2, 5.2**
    - Generate: Authenticated user with insufficient gems and active boost
    - Execute: Attempt purchase
    - Assert: Error message contains "gemas a mais" (not "já tem")
  
  - [x] 11.3 Property 16: Validation Order Never Inverts
    - **Statement:** Validation order is always auth → gems → idempotency
    - **Validates: Design correctness**
    - Generate: Various invalid states
    - Execute: Attempt purchases
    - Assert: Error messages follow correct priority order

- [x] 12. Checkpoint - Property Tests Complete
  - Ensure all property tests pass (minimum 100 iterations each), ask the user if questions arise.


- [x] 13. Integration Tests - Purchase Flow from UI
  - [x] 13.1 Test complete energy refill purchase flow
    - Setup: Launch ShopPage with 200 gems
    - Execute: Tap energy refill boost item
    - Verify: Gem balance updated in AppBar, success snackbar shown with green background
    - _Requirements: 1.1, 1.5, 2.1, 2.4_
  
  - [x] 13.2 Test complete XP booster purchase flow
    - Setup: Launch ShopPage with 200 gems
    - Execute: Tap XP booster item
    - Verify: Gem balance updated, success snackbar shown, boost becomes active
    - _Requirements: 1.1, 1.5, 3.1, 3.5_
  
  - [x] 13.3 Test complete gem multiplier purchase flow
    - Setup: Launch ShopPage with 300 gems
    - Execute: Tap gem multiplier item
    - Verify: Gem balance updated, success snackbar shown, multiplier becomes active
    - _Requirements: 1.1, 1.5, 4.1, 4.5_
  
  - [x] 13.4 Test complete streak freeze purchase flow
    - Setup: Launch ShopPage with 300 gems
    - Execute: Tap streak freeze item
    - Verify: Gem balance updated, success snackbar shown, freeze becomes available
    - _Requirements: 1.1, 1.5, 5.1, 5.5_
  
  - [x] 13.5 Test purchase flow with insufficient gems
    - Setup: Launch ShopPage with 50 gems
    - Execute: Tap 100-gem item
    - Verify: Error snackbar shown with red background, gem balance unchanged
    - _Requirements: 1.5, 6.1, 6.5_
  
  - [x] 13.6 Test purchase flow with already active boost
    - Setup: Launch ShopPage with XP booster already active
    - Execute: Tap XP booster item
    - Verify: Error snackbar shown, gems unchanged
    - _Requirements: 1.5, 3.2, 6.2, 6.5_

- [x] 14. Integration Tests - Boost Application
  - [x] 14.1 Test XP booster application during lesson
    - Setup: Purchase XP booster, start lesson
    - Execute: Complete lesson earning 10 base XP
    - Verify: User receives 20 XP (2× multiplier applied)
    - _Requirements: 3.3, 3.5, 7.1_
  
  - [x] 14.2 Test gem multiplier application during lesson
    - Setup: Purchase gem multiplier, start lesson
    - Execute: Complete lesson earning 5 base gems
    - Verify: User receives 10 gems (2× multiplier applied)
    - _Requirements: 4.3, 4.5, 7.2_
  
  - [x] 14.3 Test streak freeze consumption
    - Setup: Purchase streak freeze, skip a day
    - Execute: Complete lesson next day
    - Verify: Streak maintained, freeze consumed, `streakFreezeAvailable` becomes false
    - _Requirements: 5.3, 5.5, 7.3_
  
  - [x] 14.4 Test boost expiration
    - Setup: Purchase XP booster
    - Execute: Wait 1 hour + 1 minute, complete lesson
    - Verify: `hasXpBooster` returns false, multiplier not applied
    - _Requirements: 3.6, 7.4_
  
  - [x] 14.5 Test multiple boosts active simultaneously
    - Setup: Purchase XP booster and gem multiplier
    - Execute: Complete lesson
    - Verify: Both multipliers applied (2× XP and 2× gems)
    - _Requirements: 3.5, 4.5, 7.5_


- [x] 15. Integration Tests - Error Handling
  - [x] 15.1 Test Firestore permission-denied error
    - Setup: Mock permission-denied error
    - Execute: Attempt purchase
    - Verify: Error message contains "permissão", state reverted via `loadStats()`
    - _Requirements: 6.3, 6.6_
  
  - [x] 15.2 Test Firestore unavailable error
    - Setup: Mock unavailable error
    - Execute: Attempt purchase
    - Verify: Error message contains "indisponível", state reverted
    - _Requirements: 6.3, 6.6_
  
  - [x] 15.3 Test Firestore deadline-exceeded error
    - Setup: Mock deadline-exceeded error
    - Execute: Attempt purchase
    - Verify: Error message contains "tempo de espera", state reverted
    - _Requirements: 6.3, 6.6_
  
  - [x] 15.4 Test timeout handling
    - Setup: Mock Firestore timeout (>30 seconds)
    - Execute: Attempt purchase
    - Verify: Timeout error shown, state reverted
    - _Requirements: 6.3, 6.6_
  
  - [x] 15.5 Test retry logic with transient errors
    - Setup: Mock transient error that succeeds on retry
    - Execute: Attempt purchase
    - Verify: Purchase succeeds after retry, correct backoff timing (1s, 2s, 4s)
    - _Requirements: 6.3_
  
  - [x] 15.6 Test rollback completeness
    - Setup: Capture initial state, mock Firestore error
    - Execute: Attempt purchase
    - Verify: All state values (gems, totalGemsSpent, boosts) match initial state
    - _Requirements: 6.6_

- [x] 16. Checkpoint - Integration Tests Complete
  - Ensure all integration tests pass, ask the user if questions arise.

- [x] 17.* UI Enhancement - Active Boost Indicators (Optional)
  - [x] 17.1 Add public getters for boost expiration times
    - Add `DateTime? get xpBoosterUntil => _xpBoosterUntil;` to GamificationController
    - Add `DateTime? get gemMultiplierUntil => _gemMultiplierUntil;` to GamificationController
    - Write unit tests for getters
    - _Requirements: 7.1, 7.2_
  
  - [x] 17.2 Update BoostItem to show active badge
    - Check `gamification.hasXpBooster` in ShopPage
    - Pass `badge: 'ATIVO'` and `badgeColor: AppTheme.green` when active
    - Verify badge displays correctly on UI
    - _Requirements: 7.1, 7.2, 7.3_
  
  - [x] 17.3 Add expiration timer display
    - Create helper method `getBoostTimeRemaining(DateTime? expiresAt)`
    - Display remaining time in BoostItem description (e.g., "45min restantes")
    - Update timer every minute using Timer.periodic
    - _Requirements: 7.4_
  
  - [x] 17.4 Disable purchase button when boost is active
    - Set `onTap: null` when boost is active
    - Add visual indication (grayed out or different styling)
    - Show tooltip explaining boost is already active
    - _Requirements: 7.3, 7.6_


- [x] 18.* UI Enhancement - Loading States (Optional)
  - [x] 18.1 Disable all boost items during purchase
    - Check `gamification.isLoading.value` in ShopPage
    - Set `onTap: null` for all items when loading
    - Add loading indicator to tapped item
    - _Requirements: 1.5_
  
  - [x] 18.2 Show loading spinner in AppBar gem counter
    - Replace gem count with spinner when `isLoading.value == true`
    - Restore gem count when loading completes
    - Use ResponsiveUtils for spinner sizing
    - _Requirements: 1.5_
  
  - [x] 18.3 Prevent rapid-fire purchases
    - Debounce tap events (minimum 500ms between taps)
    - Show feedback if user taps too quickly
    - _Requirements: 1.5_

- [x] 19.* UI Enhancement - Confirmation Dialogs (Optional)
  - [x] 19.1 Create confirmation dialog widget
    - Show item name, cost, and description
    - "Confirmar" and "Cancelar" buttons
    - Follow AppTheme styling
    - Use ResponsiveUtils for dimensions
  
  - [x] 19.2 Show dialog for 200+ gem purchases
    - Gem Multiplier (200 gems)
    - Streak Freeze (200 gems)
    - Skip dialog for cheaper items (Energy Refill, XP Booster)
  
  - [x] 19.3 Test dialog flow
    - Verify dialog shows before purchase
    - Verify "Cancelar" prevents purchase
    - Verify "Confirmar" proceeds with purchase

- [x] 20. Update Firestore Security Rules
  - [x] 20.1 Add rule to prevent negative gem balance
    - Rule: `request.resource.data.gems.gems >= 0`
    - Test with Firebase emulator
    - _Requirements: 6.1_
  
  - [x] 20.2 Add rule to cap energy at 0-5
    - Rule: `request.resource.data.energy.currentEnergy >= 0 && request.resource.data.energy.currentEnergy <= 5`
    - Test with Firebase emulator
    - _Requirements: 2.3_
  
  - [x] 20.3 Add rule to verify user authentication
    - Rule: `request.auth != null && request.auth.uid == userId`
    - Test with Firebase emulator
    - _Requirements: 6.4_
  
  - [x] 20.4 Test security rules with various scenarios
    - Test authenticated user can write
    - Test unauthenticated user cannot write
    - Test user cannot write to other user's data
    - Test negative gems are rejected
    - Test energy > 5 is rejected


- [x] 21. Documentation
  - [ ] 21.1 Document purchase flow for team
    - Create flowchart of purchase process
    - Document validation order (auth → gems → idempotency)
    - Document rollback strategy (loadStats on error)
    - Add to project documentation
  
  - [x] 21.2 Create user-facing help documentation
    - Explain what each boost does
    - Explain how to earn gems
    - Explain boost durations and effects
    - Add to in-app help section (if exists)
  
  - [x] 21.3 Add analytics events (optional)
    - Track purchase attempts (item type, gem cost)
    - Track successful purchases (item type, user gems before/after)
    - Track failed purchases with reason (insufficient gems, already active, etc.)
    - Track boost usage during lessons (XP/gem multipliers applied)

- [x] 22. Final Checkpoint - Complete System
  - Ensure all tests passing
  - Verify core functionality works correctly
  - Verify UI feedback is clear and user-friendly
  - Verify error messages are in Portuguese
  - Verify rollback works on all error scenarios
  - System ready for production use

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- **Core functionality is already implemented** - focus is on testing and optional enhancements
- All user-facing text must be in Portuguese
- All code comments must be in Portuguese
- Use ResponsiveUtils for all dimensions and spacing
- Use Firebase error handlers from company steering (firebase.md)
- Follow GetX patterns from company steering (getx-patterns.md)
- **CRITICAL**: NO models, repositories, or services - all logic in GamificationController
- Each property test must run minimum 100 iterations
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- Integration tests validate end-to-end flows
- UI enhancements (tasks 17-19) are optional but improve UX
- Security rules (task 20) are critical for production deployment
- After completion, the system will be production-ready with comprehensive test coverage

