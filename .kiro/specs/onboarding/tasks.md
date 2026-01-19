# Implementation Plan: Onboarding

## Overview

This implementation plan breaks down the onboarding module into discrete, manageable tasks. The UI is already complete (Step 7 done), so this plan focuses on implementing the controller logic, Firebase integration, and testing. Each task builds on previous work and includes references to specific requirements.

## Tasks

### Phase 1: Core Controller Setup and Validation

- [x] 1. Setup OnboardingController with required states and methods
  - [x] 1.1 Verify controller has all required observable states
    - Verify isLoading, errorMessage exist
    - Verify isAddingCourse, skipWelcome flags exist
    - Verify all data collection observables exist (language, level, reason, time, name, age, email, password)
    - Verify OTP observables exist (otpCode, otpExpiration, resendTimer)
    - _Requirements: 2.2, 2.5, 2.8, 3.2, 4.5, 4.8, 5.5, 5.11, 6.4, 6.9, 6.10, 12.1_
  
  - [x] 1.2 Implement input validation methods
    - Implement validateName: check empty and whitespace-only
    - Implement validateEmail: check empty and valid format using GetUtils.isEmail
    - Implement validatePassword: check empty and minimum 6 characters
    - Return Portuguese error messages
    - _Requirements: 4.2, 4.3, 4.4, 5.2, 5.3, 5.4, 5.9, 5.10, 11.2, 11.3, 11.4, 11.5_
  
  - [x] 1.3 Write property test for input validation completeness
    - **Property 3: Input Validation Completeness**
    - **Validates: Requirements 4.2, 4.3, 4.4, 5.2, 5.3, 5.4, 5.9, 5.10, 11.1, 11.2, 11.3, 11.4, 11.5**
    - Generate random valid/invalid names, emails, passwords
    - Verify validation rules apply consistently
    - Verify Portuguese error messages
  
  - [x] 1.4 Write unit tests for validation edge cases
    - Test empty string, whitespace-only string, null values
    - Test invalid email formats
    - Test password lengths (0, 1, 5, 6, 10 characters)
    - Verify error messages match requirements

### Phase 2: Firebase Auth Integration

- [x] 2. Implement account creation with Firebase Auth
  - [x] 2.1 Implement createAccount method
    - Set isLoading to true
    - Clear previous error messages
    - Validate email and password using validators
    - Call Firebase Auth createUserWithEmailAndPassword
    - On success: generate and send OTP code
    - On error: use standardized error handler
    - Set isLoading to false in finally block
    - _Requirements: 5.5, 5.11, 5.12, 5.13, 5.19, 12.1, 12.2, 12.3_
  
  - [x] 2.2 Implement Firebase Auth error handler
    - Map error codes: email-already-in-use, invalid-email, weak-password, network-request-failed, too-many-requests
    - Return Portuguese messages without technical terms
    - Use standardized handler from firebase.md
    - _Requirements: 5.15, 5.16, 5.17, 5.18, 13.1, 13.2, 13.3, 13.4, 13.5_
  
  - [x] 2.3 Write property test for Firebase error message mapping
    - **Property 6: Firebase Error Message Mapping**
    - **Validates: Requirements 5.15, 5.16, 5.17, 5.18, 13.1, 13.2, 13.3, 13.4, 13.5**
    - Test all Firebase Auth error codes
    - Verify messages are in Portuguese
    - Verify no technical terms in messages
  
  - [x] 2.4 Write unit tests for account creation flow
    - Test successful account creation
    - Test each Firebase error code
    - Test loading state transitions
    - Test error message display

### Phase 3: OTP Generation and Verification

- [x] 3. Implement OTP lifecycle management
  - [x] 3.1 Implement OTP generation and storage in Firestore
    - Generate 5-digit random numeric code using `(10000 + Random().nextInt(90000)).toString()`
    - Create document in Firestore collection 'emailVerifications' with email as document key
    - Store document with fields: `{code: String, expiresAt: Timestamp, attempts: int, createdAt: Timestamp}`
    - Set expiresAt to `Timestamp.fromDate(DateTime.now().add(Duration(minutes: 10)))`
    - Set attempts to 0
    - Use `FieldValue.serverTimestamp()` for createdAt
    - _Requirements: 5.13, 6.4, 6.12, 6.14, 6.15, 6.16, 6.17_
  
  - [x] 3.2 Implement sendVerificationCode method
    - Generate OTP code using `_generateOTP()`
    - Store OTP in Firestore collection 'emailVerifications' with email as key
    - Store `_tempEmail` private variable for session management
    - Start 60-second resend timer using `_startResendTimer()`
    - Navigate to verification screen
    - **⚠️ CRITICAL**: Add comment about email sending being incomplete (temporary for testing)
    - **⚠️ CRITICAL**: Code is saved to Firestore but NOT sent via email
    - **⚠️ CRITICAL**: Must implement Cloud Function or email service for production
    - _Requirements: 5.13, 5.14, 6.3, 6.9, 6.13_
  
  - [x] 3.3 Implement resend timer logic
    - Use `Timer.periodic` with 1-second interval
    - Update `resendTimer.obs` from 60 down to 0
    - Cancel timer in `onClose()` lifecycle method
    - Enable resend button when timer reaches 0
    - _Requirements: 6.9, 6.10, 6.11_
  
  - [x] 3.4 Implement verifyCode method
    - Retrieve OTP document from Firestore using `_tempEmail` as key
    - Parse document to get code, expiresAt, attempts
    - Validate entered code matches stored code
    - Check if current time is before expiresAt (10 minutes)
    - Display appropriate error messages in Portuguese
    - On success: mark email as verified and proceed to finalization
    - Delete OTP document from Firestore after successful verification
    - _Requirements: 6.5, 6.6, 6.7, 6.8, 6.18, 6.19_
  
  - [x] 3.5 Write property test for OTP lifecycle management
    - **Property 7: OTP Lifecycle Management**
    - **Validates: Requirements 6.4, 6.5, 6.6, 6.7, 6.8, 6.12, 6.13, 6.14, 6.15, 6.16, 6.17, 6.18, 6.19**
    - Generate 100 OTP codes and verify format (5 digits)
    - Test expiration logic with various timestamps
    - Verify codes older than 10 minutes are rejected
    - Verify Firestore document structure matches specification
    - Verify document key is email address
  
  - [x] 3.6 Write unit tests for OTP flow
    - Test OTP generation format (5 digits)
    - Test correct code acceptance
    - Test incorrect code rejection
    - Test expired code rejection (> 10 minutes)
    - Test resend timer countdown
    - Test Firestore document creation
    - Test Firestore document deletion after verification

### Phase 4: Username Generation and Uniqueness

- [x] 4. Implement unique username generation
  - [x] 4.1 Implement generateUniqueUsername method
    - Convert name to lowercase
    - Remove all spaces
    - Query Firestore for existing username (where username == value, limit 1)
    - If exists: append random number (1-9999) and check again
    - Repeat until unique (max 100 attempts)
    - Return unique username
    - Handle Firestore errors with standardized handler
    - _Requirements: 7.1, 7.2, 7.3, 7.4_
  
  - [x] 4.2 Write property test for username uniqueness guarantee
    - **Property 8: Username Uniqueness Guarantee**
    - **Validates: Requirements 7.1, 7.2, 7.3, 7.4**
    - Generate multiple usernames from same name
    - Verify all generated usernames are unique
    - Verify lowercase and no spaces
    - Test with existing usernames in Firestore
  
  - [x] 4.3 Write unit tests for username generation
    - Test basic conversion (lowercase, no spaces)
    - Test conflict resolution with random numbers
    - Test max attempts handling
    - Test Firestore error handling

### Phase 5: Firestore Document Creation

- [x] 5. Implement account finalization with Firestore
  - [x] 5.1 Implement createUserDocument method
    - Get current Firebase Auth user ID
    - Generate unique username from userName
    - Create document at users/{userId}
    - Include fields: id, email, name, username, age, onboardingCompleted: true
    - Include timestamps: createdAt, updatedAt with FieldValue.serverTimestamp()
    - Handle Firestore errors with standardized handler
    - _Requirements: 7.5, 7.6, 7.7_
  
  - [x] 5.2 Implement createFirstCourse method
    - Generate course ID using Firestore auto-generated ID (via .doc() without parameters)
    - Create document at users/{userId}/courses/{courseId}
    - Include fields: id, language, languageName, level, reason, studyTime, isActive: true
    - Include timestamp: createdAt with FieldValue.serverTimestamp()
    - Handle Firestore errors with standardized handler
    - _Requirements: 7.8, 7.9, 7.10, 7.11_
  
  - [x] 5.3 Implement initializeGamificationStats method
    - Create document at users/{userId}/stats/gamification
    - Set initial values: xp: 0, level: 1, streak: 0, energy: 5, gems: 0, hearts: 5
    - Include timestamp: lastActiveAt with FieldValue.serverTimestamp()
    - Handle Firestore errors with standardized handler
    - _Requirements: 7.12, 7.13, 7.14_
  
  - [x] 5.4 Implement finalizeAccount method
    - Call createUserDocument
    - Call createFirstCourse
    - Call initializeGamificationStats
    - Save isFirstAccess = false to SharedPreferences
    - Navigate to conclusion screen
    - Set isLoading appropriately
    - _Requirements: 7.15, 7.16, 7.20_
  
  - [x] 5.5 Write property test for Firestore document structure completeness
    - **Property 9: Firestore Document Structure Completeness**
    - **Validates: Requirements 7.5, 7.6, 7.7, 7.8, 7.9, 7.10, 7.11, 7.12, 7.13, 7.14, 7.15**
    - Verify user document has all required fields
    - Verify course document has all required fields
    - Verify stats document has all required fields
    - Verify all timestamps use FieldValue.serverTimestamp()
    - Verify course ID uses Firestore auto-generated ID
  
  - [x] 5.6 Write unit tests for Firestore operations
    - Test user document creation
    - Test course document creation
    - Test stats document initialization
    - Test Firestore error handling
    - Test SharedPreferences update


### Phase 6: Add Course Mode Implementation

- [x] 6. Implement add course mode functionality
  - [x] 6.1 Implement addNewCourse method
    - Verify user is authenticated (Firebase Auth currentUser)
    - Get user ID from authenticated user
    - Generate course ID using Firestore auto-generated ID (via .doc() without parameters)
    - Create course document at users/{userId}/courses/{courseId}
    - Include fields: id, language, languageName, level, reason, studyTime, isActive: true
    - Include timestamp: createdAt with FieldValue.serverTimestamp()
    - Do NOT modify user document
    - Do NOT modify gamification stats
    - Do NOT update SharedPreferences
    - Navigate to conclusion screen
    - _Requirements: 8.3, 8.4, 8.5, 8.6_
  
  - [x] 6.2 Update completeOnboarding method to handle both modes
    - Check isAddingCourse flag
    - If true: call addNewCourse
    - If false: call finalizeAccount
    - Navigate to /home using Get.offAllNamed in both cases
    - _Requirements: 8.7_
  
  - [x] 6.3 Write property test for add course mode behavior
    - **Property 10: Add Course Mode Behavior**
    - **Validates: Requirements 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8**
    - Verify screens are skipped when isAddingCourse is true
    - Verify only course document is created
    - Verify user document and stats are not modified
    - Verify SharedPreferences is not updated
  
  - [x] 6.4 Write unit tests for add course mode
    - Test course creation in add mode
    - Test user document not modified
    - Test stats not modified
    - Test SharedPreferences not updated
    - Test authentication check

### Phase 7: Progress Tracking and Navigation

- [x] 7. Implement progress tracking logic
  - [x] 7.1 Implement calculateProgress method
    - Define screen order for full onboarding (9 screens)
    - Define screen order for add course mode (4 screens)
    - Exclude transition screens from count
    - Return current position / total screens
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 9.8_
  
  - [x] 7.2 Update OnboardingHeader widget to use calculateProgress
    - Pass current screen name to calculateProgress
    - Pass isAddingCourse flag
    - Display progress bar with calculated value
    - _Requirements: 9.1, 9.8_
  
  - [x] 7.3 Write property test for progress calculation accuracy
    - **Property 4: Progress Calculation Accuracy**
    - **Validates: Requirements 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 9.8**
    - Test progress for each screen in full onboarding
    - Test progress for each screen in add course mode
    - Verify transition screens are excluded
    - Verify correct fractions (1/9, 2/9, etc.)
  
  - [x] 7.4 Write unit tests for progress calculation
    - Test each screen position
    - Test full onboarding mode
    - Test add course mode
    - Test transition screen exclusion

- [x] 8. Implement navigation logic and back button handling
  - [x] 8.1 Verify OnboardingNavigation methods
    - Verify all navigation methods use Get.to() for internal navigation
    - Verify goToAuth uses Get.toNamed('/auth')
    - Verify finishOnboarding uses Get.offAllNamed('/home')
    - _Requirements: 1.5, 7.18, 10.2_
  
  - [x] 8.2 Implement back button visibility logic
    - Hide back button on welcome screen
    - Hide back button on transition screens
    - Show back button on all other screens
    - _Requirements: 10.1, 10.3, 10.4_
  
  - [x] 8.3 Implement data preservation on back navigation
    - Verify controller observables persist when navigating back
    - Test data remains after Get.back()
    - _Requirements: 10.5, 10.6_
  
  - [x] 8.4 Write property test for navigation stack management
    - **Property 11: Navigation Stack Management**
    - **Validates: Requirements 10.1, 10.2, 10.3, 10.4, 10.5, 10.6**
    - Verify back button availability on each screen
    - Verify data persists after back navigation
    - Verify Get.back() works correctly
  
  - [x] 8.5 Write property test for navigation method correctness
    - **Property 14: Navigation Method Correctness**
    - **Validates: Requirements 1.5, 1.7**
    - Verify Get.toNamed is used for auth navigation
    - Verify navigation stack is preserved
  
  - [x] 8.6 Write property test for final navigation stack clearing
    - **Property 15: Final Navigation Stack Clearing**
    - **Validates: Requirements 7.18**
    - Verify Get.offAllNamed is used for completion
    - Verify navigation stack is cleared
  
  - [x] 8.7 Write unit tests for navigation
    - Test each navigation method
    - Test back button visibility
    - Test data preservation
    - Test navigation stack behavior

### Phase 8: Data Persistence and Selection Flow

- [x] 9. Implement selection flow and data storage
  - [x] 9.1 Connect selection screens to controller
    - Update SelectLanguagePage to store selection in controller.selectedLanguage
    - Update LanguageLevelPage to store selection in controller.languageLevel
    - Update LearningReasonPage to store selection in controller.learningReason
    - Update StudyTimePage to store selection in controller.studyTime
    - Update UserAgePage to store selection in controller.userAge
    - Verify navigation is triggered after selection
    - _Requirements: 2.2, 2.3, 2.5, 2.6, 2.8, 2.9, 3.2, 3.3, 4.8, 4.9_
  
  - [x] 9.2 Implement selection validation
    - Verify selection is made before allowing navigation
    - Keep continue button enabled but show validation on click
    - _Requirements: 2.10, 3.4_
  
  - [x] 9.3 Write property test for selection flow navigation
    - **Property 1: Selection Flow Navigation**
    - **Validates: Requirements 2.2, 2.3, 2.5, 2.6, 2.8, 2.9, 3.2, 3.3, 4.5, 4.6, 4.8, 4.9**
    - Test navigation after each selection
    - Verify correct screen transitions
    - Verify data is stored
  
  - [x] 9.4 Write property test for data persistence consistency
    - **Property 2: Data Persistence Consistency**
    - **Validates: Requirements 2.2, 2.5, 2.8, 3.2, 4.5, 4.8, 5.5, 5.11**
    - Test all data fields
    - Verify stored value matches selected value
    - Test persistence across navigation
  
  - [x] 9.5 Write unit tests for selection flow
    - Test each selection screen
    - Test data storage
    - Test navigation triggers
    - Test validation

### Phase 9: Loading States and Error Handling

- [x] 10. Implement loading state management
  - [x] 10.1 Verify loading states in all async methods
    - Verify isLoading is set to true at start
    - Verify isLoading is set to false in finally block
    - Verify buttons are disabled when isLoading is true
    - Verify CircularProgressIndicator is shown when isLoading is true
    - _Requirements: 5.19, 7.20, 12.1, 12.2, 12.3, 12.4, 12.5_
  
  - [x] 10.2 Write property test for loading state consistency
    - **Property 5: Loading State Consistency**
    - **Validates: Requirements 5.19, 7.20, 12.1, 12.2, 12.3, 12.4, 12.5**
    - Test loading indicator appears during async operations
    - Test loading indicator removed on completion
    - Test loading indicator removed on error
  
  - [x] 10.3 Write unit tests for loading states
    - Test loading during account creation
    - Test loading during Firestore operations
    - Test loading during OTP sending
    - Test button disabled state

- [x] 11. Implement comprehensive error handling
  - [x] 11.1 Verify Firestore error handler
    - Map all Firestore error codes to Portuguese messages
    - Use standardized handler from firebase.md
    - _Requirements: 7.19, 13.2, 13.3, 13.4, 13.5_
  
  - [x] 11.2 Implement error message display in views
    - Show errorMessage when not empty
    - Clear errorMessage when starting new operation
    - Display in Portuguese without technical terms
    - _Requirements: 13.3, 13.6_
  
  - [x] 11.3 Write unit tests for error handling
    - Test each Firestore error code
    - Test error message display
    - Test error message clearing
    - Test Portuguese messages

### Phase 10: Security and Data Protection

- [x] 12. Implement security measures
  - [x] 12.1 Audit code for sensitive data logging
    - Remove any debugPrint or print with passwords
    - Remove any logging of email addresses
    - Remove any logging of authentication tokens
    - Verify error messages don't expose sensitive data
    - _Requirements: 14.1, 14.2, 14.3_
  
  - [x] 12.2 Implement secure OTP storage in Firestore
    - Use Firestore collection 'emailVerifications' for OTP codes
    - Set appropriate Firestore security rules to protect OTP documents
    - Delete OTP document after successful verification
    - _Requirements: 14.9, 14.10_
  
  - [x] 12.3 Implement input validation before server calls
    - Validate all inputs before Firebase operations
    - Sanitize inputs if needed
    - _Requirements: 14.6_
  
  - [x] 12.4 Write property test for sensitive data protection
    - **Property 12: Sensitive Data Protection**
    - **Validates: Requirements 14.1, 14.2, 14.3**
    - Verify passwords never appear in logs
    - Verify emails never appear in logs
    - Verify tokens never appear in error messages
  
  - [x] 12.5 Write unit tests for security
    - Test Firestore OTP storage
    - Test OTP document deletion
    - Test input validation
    - Test data clearing

### Phase 11: Transition Screens and Skip Logic

- [x] 13. Implement transition screen behavior
  - [x] 13.1 Verify transition screens don't count in progress
    - Verify IntroPage, PauseOnePage, PauseTwoPage, ConclusionPage excluded
    - Verify progress calculation skips these screens
    - _Requirements: 15.9_
  
  - [x] 13.2 Implement no-back-navigation on transitions
    - Verify back button is hidden on transition screens
    - Verify WillPopScope or similar prevents back gesture
    - _Requirements: 15.10_
  
  - [x] 13.3 Implement skip welcome logic
    - Check OnboardingController.shouldSkipWelcome static flag
    - If true, navigate directly to SelectLanguagePage
    - If false, show WelcomeView
    - _Requirements: 1.6_
  
  - [x] 13.4 Write property test for transition screen behavior
    - **Property 13: Transition Screen Behavior**
    - **Validates: Requirements 15.1, 15.2, 15.3, 15.4, 15.5, 15.6, 15.7, 15.8, 15.9, 15.10**
    - Verify transition screens display correctly
    - Verify they don't count in progress
    - Verify no back navigation
    - Verify continue button works
  
  - [x] 13.5 Write unit tests for transition screens
    - Test skip welcome logic
    - Test transition screen exclusion from progress
    - Test back button hiding
    - Test continue navigation

### Phase 12: Integration and Final Testing

- [x] 14. Write integration tests for complete flows
  - Test complete full onboarding flow: welcome → language → profile → account → verification → finalization → home
  - Test complete add course flow: language → study time → conclusion → home
  - Test back navigation preserving data
  - Test error recovery and retry mechanisms
  - Test OTP resend flow
  - Test username conflict resolution
  - Test Firestore document creation verification
  - Test skip welcome from social login

- [x] 15. Final checkpoint - Ensure all tests pass
  - Run all unit tests
  - Run all property tests (minimum 100 iterations each)
  - Run all integration tests
  - Verify 80%+ code coverage
  - Fix any failing tests
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Each task references specific requirements for traceability
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- UI is already complete (Step 7 done), focus is on controller logic
- Follow critical rules from design document
- Use standardized error handlers from firebase.md
- All user-facing messages must be in Portuguese
- Never log passwords, tokens, or emails
- Always use Get.offAllNamed for final navigation to /home
- Always use Get.toNamed for navigation to /auth
- Always use FieldValue.serverTimestamp() for Firestore timestamps
- Always use Firestore auto-generated IDs for course ID generation (via .doc() without parameters)
- **OTP Implementation Pattern (from AuthController):**
  - Store OTP in Firestore collection 'emailVerifications' (NOT FlutterSecureStorage)
  - Document key: user's email address
  - Document structure: `{code: String, expiresAt: Timestamp, attempts: int, createdAt: Timestamp}`
  - Use `_tempEmail` private variable for session management
  - Use `_generateOTP()`: `(10000 + Random().nextInt(90000)).toString()`
  - Use `_startResendTimer()` with `Timer.periodic` for 60-second countdown
  - Include ⚠️ CRITICAL comments about email sending being incomplete (temporary for testing)
  - Code is saved to Firestore but NOT sent via email (must implement Cloud Function or email service for production)
  - Delete OTP document from Firestore after successful verification

