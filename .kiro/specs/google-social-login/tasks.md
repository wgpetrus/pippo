# Implementation Plan: Google Social Login

## Overview

This plan adds Google Sign-In to the existing authentication module. Facebook button will be a placeholder. All tasks extend the existing AuthController and SigninView.

## Tasks

- [ ] 1. Add google_sign_in dependency
  - Add `google_sign_in: ^6.2.1` to pubspec.yaml
  - Run `flutter pub get`
  - _Requirements: 1.1_

- [ ] 2. Implement signInWithGoogle method in AuthController
  - [ ] 2.1 Add Google Sign-In instance and method signature
    - Initialize GoogleSignIn with scopes ['email', 'profile']
    - Create signInWithGoogle() async method
    - Set isLoading = true at start
    - _Requirements: 1.1, 1.12, 4.1_
  
  - [ ] 2.2 Implement Google authentication flow
    - Call GoogleSignIn.signIn()
    - Handle cancel (return silently)
    - Get GoogleSignInAuthentication
    - Create GoogleAuthProvider.credential
    - Call Firebase signInWithCredential
    - _Requirements: 1.2, 1.3, 1.4_
  
  - [ ] 2.3 Implement user document handling
    - Check if user document exists in Firestore
    - If not exists: create document with onboardingCompleted = false
    - Store email, displayName, photoURL, authProvider = 'google'
    - _Requirements: 1.5, 1.6, 1.7_
  
  - [ ] 2.4 Implement navigation logic
    - If onboardingCompleted false → Get.offAllNamed('/onboarding')
    - If onboardingCompleted true → update lastActiveAt → Get.offAllNamed('/home')
    - Set isLoading = false in finally block
    - _Requirements: 1.9, 1.10, 1.11, 5.1, 5.4_
  
  - [ ] 2.5 Write property test for navigation consistency
    - **Property 2: Navigation Consistency**
    - **Validates: Requirements 1.9, 1.10, 1.11, 5.1, 5.4**

- [ ] 3. Implement error handling
  - [ ] 3.1 Add _handleGoogleSignInError method
    - Handle sign_in_canceled (return empty string)
    - Handle network_error
    - Handle FirebaseAuthException codes
    - Return Portuguese messages without technical terms
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.7, 2.8, 2.9_
  
  - [ ] 3.2 Write property test for error message security
    - **Property 4: Error Message Security**
    - **Validates: Requirements 2.9, 5.6**

- [ ] 4. Implement Facebook placeholder
  - Add onFacebookTap() method
  - Show SnackBar with "Login com Facebook estará disponível em breve!"
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [ ] 5. Connect SigninView to controller
  - [ ] 5.1 Connect Google button to signInWithGoogle
    - Disable when isLoading is true
    - _Requirements: 1.1, 4.2_
  
  - [ ] 5.2 Connect Facebook button to onFacebookTap
    - Disable when isLoading is true
    - _Requirements: 3.1, 4.2_
  
  - [ ] 5.3 Ensure all buttons disabled during loading
    - Email login button
    - Google button
    - Facebook button
    - "Esqueci minha senha" link
    - _Requirements: 4.2, 4.3_

- [ ] 6. Write property test for loading state consistency
  - **Property 3: Loading State Consistency**
  - **Validates: Requirements 1.12, 4.1, 4.4, 4.5**

- [ ] 7. Write unit tests
  - Test cancel returns empty error message
  - Test each error code maps to correct Portuguese message
  - Test document creation with correct fields
  - _Requirements: 2.1-2.9_

- [ ] 8. Checkpoint - Ensure all tests pass
  - Run all unit tests
  - Run all property tests
  - Verify Google Sign-In flow works
  - Verify Facebook placeholder shows SnackBar
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- All tasks are required
- Extends existing AuthController (no new controller needed)
- Uses existing SocialButton widget
- Follow same navigation patterns as email login
- Never log Google tokens
- All error messages in Portuguese

