# Requirements - Critical App Fixes

## Overview

Fix critical issues identified in the app affecting data validation, navigation, authentication, and user experience.

---

## 1. Input Validation in Onboarding

### 1.1 Real-time Validation
**As a** user  
**I want** immediate feedback when I type invalid data  
**So that** I can correct it before proceeding

**Acceptance Criteria:**
- Name: only letters and spaces, minimum 2 characters
- Email: valid format (regex)
- Password: minimum 6 characters
- Immediate visual feedback (red border + message)
- "Continue" button disabled if invalid

### 1.2 Submit Validation
**As a** system  
**I want** to validate data before saving to Firestore  
**So that** there is no invalid data in the database

**Acceptance Criteria:**
- Double validation: UI + Controller
- Data sanitization (trim, lowercase for email)
- Clear and friendly error messages

---

## 2. OTP Verification Flow (Without Email)

### 2.1 Development Mode with Bypass
**As a** developer  
**I want** to skip OTP verification in development  
**So that** I can test the complete flow

**Acceptance Criteria:**
- `kDebugMode` flag for automatic bypass
- Fixed code "00000" accepted in debug
- Production: real code from Firestore (until email is implemented)
- Clear message in console about debug mode

### 2.2 Adequate Visual Feedback
**As a** user  
**I want** to know I'm in test mode  
**So that** I understand why I didn't receive an email

**Acceptance Criteria:**
- Debug banner on OTP screen
- Explanatory text about test code
- "Use test code" button visible only in debug

---

## 3. Correct Navigation

### 3.1 Gems Modal → Shop
**As a** user  
**I want** to go to the shop when clicking "Go to shop"  
**So that** I can buy more gems

**Acceptance Criteria:**
- Button navigates to tab 2 (Shop)
- Modal closes before navigating
- Smooth transition animation

### 3.2 Settings → AuthController
**As a** user  
**I want** to access settings without error  
**So that** I can logout

**Acceptance Criteria:**
- AuthController registered globally
- Permanent binding (not just in /auth)
- Logout works from any screen

---

## 4. Social Login (Google)

### 4.1 Differentiated Flow
**As a** user who logs in with Google  
**I want** to skip fields already filled by Google  
**So that** I don't have to type email again

**Acceptance Criteria:**
- Detect authProvider = 'google'
- Skip screens: email, password, OTP verification
- Go directly to: name, age, language, time
- Email and displayName already saved from Google

### 4.2 Pre-filled Data
**As a** system  
**I want** to use Google data when available  
**So that** the user has less work

**Acceptance Criteria:**
- Name pre-filled with Google displayName
- Email readonly (not editable)
- Google avatar saved as photoURL

---

## 5. Individual User Data

### 5.1 Unique Profiles
**As a** user  
**I want** to see my own data  
**So that** I don't see other users' data

**Acceptance Criteria:**
- Load data from current userId
- Leaderboard with real Firestore data
- Friends with real data (or clear placeholder)
- Profile with logged user stats

### 5.2 Clear Placeholders
**As a** developer  
**I want** obvious placeholders for mocked data  
**So that** I know what still needs to be implemented

**Acceptance Criteria:**
- "Test data" text visible
- Different placeholder icon
- Code comment indicating mock

---

## 6. Global Controllers

### 6.1 Permanent Registration
**As a** system  
**I want** essential controllers always available  
**So that** there is no "Controller not found" error

**Acceptance Criteria:**
- AuthController: global registration in main.dart
- GamificationController: global registration in main.dart
- Other controllers: only in specific bindings

### 6.2 Safe Lazy Loading
**As a** system  
**I want** to load controllers on demand  
**So that** I save memory but don't have crashes

**Acceptance Criteria:**
- Get.put() for global controllers
- Get.lazyPut() for feature controllers
- Get.isRegistered() check before Get.find()

---

## 7. Error Handling

### 7.1 Loading Visual Feedback
**As a** user  
**I want** to see when the app is loading  
**So that** I know it hasn't frozen

**Acceptance Criteria:**
- Spinner visible during operations
- 30-second timeout
- Clear error message if it fails

### 7.2 Automatic Retry
**As a** system  
**I want** to retry failed operations  
**So that** temporary errors don't break the flow

**Acceptance Criteria:**
- 3 attempts with exponential backoff
- Visual retry feedback
- Option to cancel retry

---

## 8. Onboarding Data Saving

### 8.1 Atomic Transaction
**As a** system  
**I want** to save all onboarding data at once  
**So that** there is no partial data in Firestore

**Acceptance Criteria:**
- Batch write for user + course + stats
- Rollback if any operation fails
- Validation of all fields before saving

### 8.2 Error Recovery
**As a** user  
**I want** to be able to try again if saving fails  
**So that** I don't lose my data

**Acceptance Criteria:**
- Data kept in memory after error
- "Try again" button visible
- Option to go back and edit data

---

## 9. Centralized Validators

### 9.1 Validation Helpers
**As a** developer  
**I want** reusable validators  
**So that** I maintain consistency

**Acceptance Criteria:**
- ValidationHelper class in shared/utils/
- Methods: validateName, validateEmail, validatePassword
- Centralized regex patterns
- Standardized error messages

### 9.2 Data Sanitization
**As a** system  
**I want** to clean data before saving  
**So that** there are no extra spaces or invalid characters

**Acceptance Criteria:**
- trim() on all text inputs
- toLowerCase() on emails
- removeSpecialChars() on usernames

---

## 10. Integration Tests

### 10.1 Complete Onboarding Flow
**As a** QA  
**I want** to test the complete flow automatically  
**So that** I detect regressions

**Acceptance Criteria:**
- Complete onboarding test (email/password)
- Onboarding test with Google
- Input validation test
- Firestore save test

### 10.2 Navigation Tests
**As a** QA  
**I want** to test navigation between screens  
**So that** I ensure there are no broken routes

**Acceptance Criteria:**
- Navigation test home → shop
- Navigation test profile → settings
- Logout and return to auth test

---

## Priorities

### P0 (Critical - Blocks usage)
1. Input validation in onboarding
2. OTP flow with debug bypass
3. Global AuthController (error in settings)
4. Correct onboarding data saving

### P1 (High - Affects UX)
5. Gems modal → shop navigation
6. Google login with differentiated flow
7. Individual user data

### P2 (Medium - Improvement)
8. Centralized validators
9. Improved error handling
10. Clear placeholders for mocks

### P3 (Low - Future)
11. Integration tests
12. Automatic retry with feedback

---

## Technical Notes

### OTP without Email
- **Decision:** Use bypass in debug until email sending is implemented
- **Fixed code:** "00000" accepted only in `kDebugMode`
- **Production:** Real code from Firestore (user copies manually)
- **Future:** Implement Cloud Function for email sending

### Global Controllers
- **AuthController:** Needed throughout the app (logout, auth verification)
- **GamificationController:** Needed in home, profile, lesson
- **OnboardingController:** Only during onboarding (not global)

### Validation
- **UI:** Immediate feedback (red border, message)
- **Controller:** Validation before saving
- **Firestore:** Rules for server-side validation (future)

---

## Dependencies

- `flutter/foundation.dart` (kDebugMode)
- No new external dependencies needed

---

## Risks

1. **OTP bypass in production:** Ensure `kDebugMode` works correctly
2. **Global controllers:** Increases memory usage (acceptable for 2 controllers)
3. **Regex validation:** May block valid names from other cultures (review patterns)

---

## Success Metrics

- ✅ 0 validation errors reaching Firestore
- ✅ 0 crashes from "Controller not found"
- ✅ 100% of users complete onboarding without errors
- ✅ Navigation works in 100% of tested cases
- ✅ Google login works without asking for email again
