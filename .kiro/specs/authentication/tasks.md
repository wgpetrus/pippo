# Implementation Plan: Authentication

## Overview

This implementation plan breaks down the authentication module into discrete, manageable tasks. Each task builds on previous work and includes references to specific requirements. The plan follows the company's development workflow, separating UI implementation (Step 7) from logic implementation (Step 8).

## Tasks

### Phase 1: Core Setup and Splash Logic

- [x] 1. Setup authentication module structure
  - Create folder structure: `features/core/auth/` with bindings, controllers, views, widgets
  - Create folder structure: `features/inners/splash/` with bindings, controllers, views
  - Setup routes in `shared/routes/app_routes.dart` for /splash, /auth, /onboarding, /home
  - _Requirements: 1.1, 1.4, 1.5, 1.8_

- [ ] 2. Implement SplashController with critical verification order
  - [ ] 2.1 Create SplashController with isLoading and errorMessage states
    - Initialize controller extending GetxController
    - Add observable states: isLoading, errorMessage
    - _Requirements: 1.2, 5.1_
  
  - [ ] 2.2 Implement authentication check method
    - Check Firebase Auth currentUser
    - Return boolean indicating if user is authenticated
    - _Requirements: 1.2_
  
  - [ ] 2.3 Implement first access check method
    - Check SharedPreferences for isFirstAccess key
    - Default to true if key doesn't exist
    - _Requirements: 1.3, 6.3_
  
  - [ ] 2.4 Implement onboarding completion check method
    - Fetch user document from Firestore
    - Extract onboardingCompleted field (default false)
    - Apply 5-second timeout
    - Handle Firestore errors with standardized handler
    - _Requirements: 1.6, 1.7, 1.11, 8.2_
  
  - [ ] 2.5 Implement navigation decision logic
    - Follow exact order: auth check → first access → onboarding check → navigate
    - Navigate to /onboarding if first access or onboarding incomplete
    - Navigate to /auth if not authenticated and not first access
    - Navigate to /home if authenticated and onboarding complete
    - Navigate to /auth on Firestore error or timeout
    - _Requirements: 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 1.12_
  
  - [ ]* 2.6 Write property test for navigation order invariant
    - **Property 1: Navigation Order Invariant**
    - **Validates: Requirements 1.2, 1.3, 1.6**
    - Test that verification order is never inverted
    - Generate various authentication states
    - Verify correct navigation for each state
  
  - [ ]* 2.7 Write property test for timeout application
    - **Property 9: Timeout Application**
    - **Validates: Requirements 1.11, 1.12**
    - Test that Firestore operations timeout after 5 seconds
    - Verify navigation to /auth on timeout

- [ ] 3. Implement network error handling in splash
  - Detect network errors during Firestore fetch
  - Display error message "Verifique sua conexão com a internet"
  - Show "Tentar novamente" button
  - Retry logic on button press
  - _Requirements: 1.10, 8.4_

- [ ] 4. Create SplashView UI
  - Display logo centered
  - Show CircularProgressIndicator at bottom (48px from bottom)
  - Display for minimum 2 seconds
  - Show error message and retry button when needed
  - _Requirements: 1.1, 1.10, 5.5_

### Phase 2: Login Implementation

- [ ] 5. Implement AuthController for login
  - [ ] 5.1 Create AuthController with required states
    - Add isLoading, errorMessage observables
    - Initialize Firebase Auth instance
    - _Requirements: 2.1, 5.1_
  
  - [ ] 5.2 Implement email validation method
    - Check if email is empty
    - Validate email format using GetUtils.isEmail
    - Return appropriate Portuguese error message
    - _Requirements: 2.2, 2.4, 4.3_
  
  - [ ] 5.3 Implement password validation method
    - Check if password is empty
    - Validate minimum 6 characters
    - Return appropriate Portuguese error message
    - _Requirements: 2.3, 4.4_
  
  - [ ]* 5.4 Write property test for form validation completeness
    - **Property 4: Form Validation Completeness**
    - **Validates: Requirements 4.1, 4.2**
    - Generate random valid/invalid emails and passwords
    - Verify all validations run before Firebase operations
  
  - [ ] 5.5 Implement Firebase Auth error handler
    - Map all Firebase Auth error codes to Portuguese messages
    - Handle: user-not-found, wrong-password, invalid-email, user-disabled, too-many-requests, network-request-failed, invalid-credential
    - Return user-friendly messages without technical terms
    - _Requirements: 2.10, 2.11, 2.12, 2.13, 2.14, 2.15, 2.16, 8.1, 8.3, 8.7_
  
  - [ ]* 5.6 Write property test for error message mapping
    - **Property 3: Error Message Mapping**
    - **Validates: Requirements 8.1, 8.3**
    - Test all Firebase error codes
    - Verify messages are in Portuguese
    - Verify no technical terms in messages
  
  - [ ] 5.7 Implement login method
    - Set isLoading to true
    - Clear previous error messages
    - Authenticate via Firebase Auth signInWithEmailAndPassword
    - On success: fetch user document from Firestore
    - Check onboardingCompleted field
    - If false: navigate to /onboarding
    - If true: update lastActiveAt with serverTimestamp
    - Navigate to /home using Get.offAllNamed
    - On error: use error handler and display message
    - Set isLoading to false in finally block
    - _Requirements: 2.5, 2.6, 2.7, 2.8, 2.9, 2.17, 5.2, 5.3, 7.1_
  
  - [ ]* 5.8 Write property test for authentication state consistency
    - **Property 2: Authentication State Consistency**
    - **Validates: Requirements 2.8, 2.9**
    - Test that lastActiveAt is updated before navigation
    - Verify Get.offAllNamed is called with /home
  
  - [ ]* 5.9 Write property test for loading state consistency
    - **Property 7: Loading State Consistency**
    - **Validates: Requirements 5.1, 5.3, 5.4**
    - Test loading indicator appears during operation
    - Test loading indicator removed on completion/error
  
  - [ ]* 5.10 Write unit tests for login edge cases
    - Test empty email and password
    - Test invalid email format
    - Test short password
    - Test network errors
    - Test Firestore fetch failures

- [ ] 6. Create SigninView UI
  - Create StatefulWidget with form key
  - Add TextEditingController for email and password
  - Add AppTextField for email with email validator
  - Add AppTextField for password with password validator and toggle visibility
  - Add "Esqueci minha senha?" link
  - Add AppButton "Entrar" connected to controller.login()
  - Show loading indicator when isLoading is true
  - Display error message when errorMessage is not empty
  - Add social login buttons (Google, Facebook) - placeholder for future
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.17, 4.2, 4.5, 4.7, 4.8_

### Phase 3: Password Recovery

- [ ] 7. Implement password recovery in AuthController
  - [ ] 7.1 Implement OTP generation and storage
    - Generate 5-digit random numeric code
    - Store code in FlutterSecureStorage with expiration timestamp (10 minutes)
    - Store associated email
    - _Requirements: 3.4, 3.6, 9.4_
  
  - [ ] 7.2 Implement send password reset code method
    - Validate email is not empty and valid
    - Generate OTP code
    - Send email via Firebase Auth sendPasswordResetEmail
    - Store OTP code with expiration
    - Navigate to verify code screen
    - Handle errors with standardized handler
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7_
  
  - [ ] 7.3 Implement resend timer logic
    - Track last send timestamp
    - Calculate seconds remaining until 60 seconds elapsed
    - Update observable resendTimer every second
    - Enable resend button when timer reaches 0
    - _Requirements: 3.14, 3.15, 3.16_
  
  - [ ] 7.4 Implement OTP verification method
    - Validate code is exactly 5 digits
    - Retrieve stored OTP from FlutterSecureStorage
    - Check if code matches
    - Check if code has expired (> 10 minutes)
    - Display appropriate error messages
    - Navigate to new password screen on success
    - _Requirements: 3.8, 3.9, 3.10, 3.11, 3.12, 3.13_
  
  - [ ]* 7.5 Write property test for OTP expiration
    - **Property 5: OTP Expiration**
    - **Validates: Requirements 3.6, 3.13**
    - Generate OTPs with various creation times
    - Verify codes older than 10 minutes are rejected
  
  - [ ] 7.6 Implement password reset method
    - Validate new password has minimum 6 characters
    - Update password via Firebase Auth
    - Clear OTP from secure storage
    - Navigate to login screen with success message
    - _Requirements: 3.17, 3.18, 3.19, 3.20_
  
  - [ ]* 7.7 Write unit tests for password recovery flow
    - Test OTP generation format (5 digits)
    - Test OTP expiration logic
    - Test resend timer countdown
    - Test password validation

- [ ] 8. Create ForgotPasswordView UI
  - Create StatefulWidget with form key
  - Add AppAppbar with "Esqueci minha senha" title
  - Add explanatory text
  - Add AppTextField for email with validator
  - Add AppButton "Enviar código" connected to controller.sendPasswordResetCode()
  - Show loading indicator when isLoading is true
  - Display error message when errorMessage is not empty
  - _Requirements: 3.1, 3.2, 3.3, 4.2, 5.1_

- [ ] 9. Create VerifyCodeView UI
  - Create StatefulWidget
  - Add AppAppbar with "Verificar código" title
  - Display text with masked email
  - Add AppPinput for 5-digit code input
  - Add AppResendCode component with 60-second timer
  - Add AppButton "Verificar" (disabled until 5 digits entered)
  - Connect verify button to controller.verifyCode()
  - Connect resend to controller.sendPasswordResetCode()
  - Show loading indicator when isLoading is true
  - Display error message when errorMessage is not empty
  - _Requirements: 3.7, 3.8, 3.9, 3.12, 3.13, 3.14, 3.15, 3.16_

- [ ] 10. Create NewPasswordView UI
  - Create StatefulWidget with form key
  - Add AppAppbar with "Nova senha" title
  - Add AppTextField for new password with validator and toggle visibility
  - Add AppTextField for confirm password with match validation
  - Add AppButton "Redefinir senha" connected to controller.resetPassword()
  - Show loading indicator when isLoading is true
  - Display error message when errorMessage is not empty
  - _Requirements: 3.17, 3.18, 4.4_

### Phase 4: State Persistence and Security

- [ ] 11. Implement state persistence
  - Save isFirstAccess = false to SharedPreferences after first onboarding
  - Save onboardingCompleted = true to Firestore after onboarding completion
  - Maintain isFirstAccess = false on logout
  - _Requirements: 6.1, 6.2, 6.4_

- [ ] 12. Implement secure navigation
  - [ ] 12.1 Verify Get.offAllNamed usage in all navigation points
    - Login success → Get.offAllNamed('/home')
    - Onboarding completion → Get.offAllNamed('/home')
    - Logout → Get.offAllNamed('/auth')
    - _Requirements: 7.1, 7.2, 7.3_
  
  - [ ]* 12.2 Write property test for navigation stack clearing
    - **Property 6: Navigation Stack Clearing**
    - **Validates: Requirements 7.1, 7.2, 7.4**
    - Verify navigation stack is cleared after login
    - Verify cannot navigate back to splash or auth

- [ ] 13. Implement data security measures
  - [ ] 13.1 Audit code for password/token logging
    - Remove any console.log or debugPrint with sensitive data
    - Verify error messages don't expose tokens
    - _Requirements: 9.1, 9.2_
  
  - [ ]* 13.2 Write property test for sensitive data protection
    - **Property 8: Sensitive Data Protection**
    - **Validates: Requirements 9.1, 9.2**
    - Verify passwords never appear in logs
    - Verify tokens never appear in error messages
  
  - [ ] 13.3 Implement input validation before server calls
    - Validate all inputs before Firebase operations
    - Sanitize inputs if needed
    - _Requirements: 9.6_
  
  - [ ] 13.4 Implement secure storage usage
    - Use FlutterSecureStorage for OTP codes
    - Use SharedPreferences for isFirstAccess
    - Clear OTP from secure storage after use
    - _Requirements: 9.4, 9.5, 9.7_

### Phase 5: Integration and Testing

- [ ] 14. Implement onboarding integration
  - Verify onboardingCompleted field check in login flow
  - Verify navigation to /onboarding when field is false
  - Verify navigation to /home when field is true
  - Preserve authentication state during onboarding
  - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

- [ ]* 15. Write property test for onboarding state persistence
  - **Property 10: Onboarding State Persistence**
  - **Validates: Requirements 10.3, 10.4**
  - Verify onboardingCompleted is set before navigation
  - Test persistence across sessions

- [ ]* 16. Write integration tests for complete flows
  - Test complete login flow: signin → Firestore → navigation
  - Test complete password recovery: forgot → verify → reset → signin
  - Test splash navigation for all user states
  - Test error recovery and retry mechanisms

- [ ] 17. Final checkpoint - Ensure all tests pass
  - Run all unit tests
  - Run all property tests (minimum 100 iterations each)
  - Run all integration tests
  - Verify 80%+ code coverage
  - Fix any failing tests
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- Follow the critical verification order defined in regras-criticas.md
- Use standardized error handlers from firebase.md
- All user-facing messages must be in Portuguese
- Never log passwords or tokens
- Always use Get.offAllNamed for post-authentication navigation
