# Tasks - Critical App Fixes

## Priority P0 (Critical - Blocks Usage)

### 1. Input Validation System

#### 1.1 Create ValidationHelper
**Validates: Requirements 1.1, 1.2, 9.1, 9.2**

Create centralized validation helper with reusable validators and sanitizers.

- [x] Create `lib/shared/utils/validation_helper.dart`
- [x] Implement `validateName()` with regex pattern for letters and spaces (min 2 chars)
- [x] Implement `validateEmail()` with email regex validation
- [x] Implement `validatePassword()` with minimum 6 characters check
- [x] Implement `sanitizeName()` to trim whitespace
- [x] Implement `sanitizeEmail()` to trim and lowercase
- [x] Add comprehensive unit tests for all validators

#### 1.2 Add Real-time Validation to Onboarding Views
**Validates: Requirements 1.1**

Implement real-time validation with visual feedback in onboarding input screens.

- [x] Update `user_name_page.dart`: Add listener to validate on text change, show error message, disable button if invalid
- [x] Update `user_email_page.dart`: Add listener to validate on text change, show error message, disable button if invalid
- [x] Update `user_password_page.dart`: Add listener to validate on text change, show error message, disable button if invalid
- [x] Update `OnboardingTextField` widget to support error state with red border
- [x] Test validation feedback appears immediately on invalid input

#### 1.3 Update OnboardingController Validators
**Validates: Requirements 1.2**

Replace inline validators with ValidationHelper methods.

- [x] Update `validateName()` to use `ValidationHelper.validateName()`
- [x] Update `validateEmail()` to use `ValidationHelper.validateEmail()`
- [x] Update `validatePassword()` to use `ValidationHelper.validatePassword()`
- [x] Update `createAccount()` to sanitize email and name before saving
- [x] Update `finalizeAccount()` to use sanitizers before Firestore write
- [x] Add validation tests for controller methods

### 2. OTP Debug Bypass

#### 2.1 Implement Debug Mode Bypass
**Validates: Requirements 2.1, 2.2**

Add kDebugMode bypass for OTP verification during development.

- [ ] Import `package:flutter/foundation.dart` in `onboarding_controller.dart`
- [ ] Update `verifyCode()` to check `kDebugMode` and accept "00000" as valid code
- [ ] Add debug log when bypass is used
- [ ] Ensure bypass ONLY works in debug mode (test in release build)
- [ ] Update `verify_code_page.dart` to show debug banner when `kDebugMode` is true
- [ ] Add "Use test code 00000" hint text in debug banner
- [ ] Test bypass works in debug, fails in release

### 3. Global Controllers Registration

#### 3.1 Register Global Controllers in main.dart
**Validates: Requirements 3.2, 6.1, 6.2**

Register AuthController and GamificationController globally to prevent "Controller not found" errors.

- [ ] Update `main.dart` to import AuthController and GamificationController
- [ ] Add `Get.put(AuthController(), permanent: true)` before runApp
- [ ] Add `Get.put(GamificationController(), permanent: true)` before runApp
- [ ] Remove AuthController registration from `AuthBinding`
- [ ] Remove GamificationController registration from `HomeBinding`
- [ ] Test settings page logout works from any screen
- [ ] Test gamification stats accessible from home, profile, and lesson screens

### 4. Atomic Onboarding Data Saving

#### 4.1 Implement Batch Write for Onboarding
**Validates: Requirements 8.1, 8.2**

Replace sequential writes with atomic batch transaction in finalizeAccount().

- [ ] Update `finalizeAccount()` in `onboarding_controller.dart` to use Firestore batch
- [ ] Validate all data before starting batch (name, email, password, language, level, studyTime)
- [ ] Create batch write for: user document, course document, gamification stats
- [ ] Implement rollback on error (batch.commit() handles this automatically)
- [ ] Keep data in memory after error for retry
- [ ] Add "Try again" button in UI when save fails
- [ ] Test partial failure scenarios (simulate Firestore errors)
- [ ] Verify no partial data in Firestore after failed save

## Priority P1 (High - Affects UX)

### 5. Navigation Fixes

#### 5.1 Fix Gems Modal → Shop Navigation
**Validates: Requirements 3.1**

Implement correct navigation from gems modal to shop tab.

- [ ] Add `goToShop()` method to `HomeController` that sets `currentNavIndex.value = 2`
- [ ] Update `GemsModal.show()` to pass `onGoToShop` callback
- [ ] Update callback to close modal then call `homeController.goToShop()`
- [ ] Test modal closes before navigation
- [ ] Test shop tab (index 2) is selected after clicking "Go to shop"
- [ ] Verify smooth transition animation

### 6. Google Login Differentiated Flow

#### 6.1 Add authProvider Field to OnboardingController
**Validates: Requirements 4.1, 4.2**

Track authentication provider to skip appropriate screens.

- [ ] Add `authProvider = ''.obs` to `OnboardingController`
- [ ] Add `shouldSkipEmail()` method that returns `authProvider.value == 'google'`
- [ ] Add `shouldSkipPassword()` method that returns `authProvider.value == 'google'`
- [ ] Add `shouldSkipVerifyCode()` method that returns `authProvider.value == 'google'`
- [ ] Update `AuthController.signInWithGoogle()` to set `authProvider = 'google'` before navigation
- [ ] Pre-fill `userName` with Google displayName
- [ ] Pre-fill `userEmail` with Google email (readonly)

#### 6.2 Update OnboardingNavigation to Skip Screens
**Validates: Requirements 4.1**

Modify navigation logic to skip email/password/OTP for Google users.

- [ ] Update `goToUserEmail()` to check `shouldSkipEmail()` and skip to conclusion if true
- [ ] Update `goToUserPassword()` to check `shouldSkipPassword()` and skip to conclusion if true
- [ ] Update `goToVerifyCode()` to check `shouldSkipVerifyCode()` and skip to conclusion if true
- [ ] Test complete Google onboarding flow skips email, password, and OTP screens
- [ ] Verify Google users go directly from age selection to conclusion

### 7. Individual User Data Loading

#### 7.1 Load User-Specific Data in Controllers
**Validates: Requirements 5.1, 5.2**

Ensure all controllers load data for the current authenticated user only.

- [ ] Verify `GamificationController.loadStats()` uses `FirebaseAuth.instance.currentUser?.uid`
- [ ] Add clear "Test data" placeholders in leaderboard if using mock data
- [ ] Add clear "Test data" placeholders in friends list if using mock data
- [ ] Add code comments indicating which data is mocked
- [ ] Test profile shows logged user's stats, not other users' data
- [ ] Test leaderboard loads real Firestore data or shows clear placeholder

## Priority P2 (Medium - Improvement)

### 8. Error Handling Improvements

#### 8.1 Add Loading Feedback
**Validates: Requirements 7.1**

Implement visual loading indicators during async operations.

- [ ] Verify all async methods in controllers set `isLoading.value = true/false`
- [ ] Add 30-second timeout to Firestore operations
- [ ] Show clear error message if timeout occurs
- [ ] Test loading spinner visible during login, onboarding save, data load
- [ ] Test timeout message appears after 30 seconds

#### 8.2 Implement Retry Logic
**Validates: Requirements 7.2**

Add automatic retry with exponential backoff for failed operations.

- [ ] Implement retry wrapper in `onboarding_controller.dart` (3 attempts, exponential backoff)
- [ ] Apply retry to `createAccount()`, `finalizeAccount()`, `sendVerificationCode()`
- [ ] Show visual feedback during retry attempts
- [ ] Add "Cancel" button to stop retry
- [ ] Test retry succeeds after temporary network error
- [ ] Test retry stops after 3 failed attempts

### 9. Clear Placeholders for Mock Data

#### 9.1 Add Placeholder Indicators
**Validates: Requirements 5.2**

Make it obvious which data is mocked vs real.

- [ ] Add "🧪 Test data" text to leaderboard if using mock data
- [ ] Add different placeholder icon for mock friends
- [ ] Add code comment `// TODO: Replace with real Firestore data` where mocked
- [ ] Test placeholders are clearly visible in UI
- [ ] Verify placeholders removed when real data is implemented

## Priority P3 (Low - Future)

### 10. Integration Tests

#### 10.1 Complete Onboarding Flow Test
**Validates: Requirements 10.1**

Create integration test for full onboarding flow.

- [ ] Create `test/integration/onboarding_complete_flow_test.dart`
- [ ] Test email/password onboarding from welcome to home
- [ ] Test Google onboarding with skipped screens
- [ ] Test input validation prevents invalid data
- [ ] Test Firestore save creates all required documents
- [ ] Verify test runs successfully in CI/CD

#### 10.2 Navigation Tests
**Validates: Requirements 10.2**

Create integration tests for critical navigation paths.

- [ ] Create `test/integration/navigation_test.dart`
- [ ] Test home → shop navigation via gems modal
- [ ] Test profile → settings → logout navigation
- [ ] Test logout clears stack and returns to auth
- [ ] Verify all navigation tests pass

---

## Notes

- **Testing Strategy**: Each task should have corresponding unit/integration tests
- **Error Handling**: All Firestore operations must use standardized error handlers
- **Code Review**: Each completed task should be reviewed for code quality and adherence to steering rules
- **Documentation**: Update relevant documentation after completing each major section

---

## Success Criteria

- ✅ 0 validation errors reaching Firestore
- ✅ 0 crashes from "Controller not found"
- ✅ 100% of users complete onboarding without errors
- ✅ Navigation works in 100% of tested cases
- ✅ Google login works without asking for email again
- ✅ Debug bypass works in development, fails in production
- ✅ Atomic saves prevent partial data in Firestore
