# Requirements Document - Authentication

## Introduction

This document defines the requirements for the Pippo authentication system, a gamified language learning application. The system manages login, registration, password recovery, and initial navigation decisions, ensuring users are correctly directed based on their authentication state and onboarding progress.

## Glossary

- **System**: The authentication module of the Pippo application
- **User**: Person using the application
- **Firebase_Auth**: Firebase authentication service
- **Firestore**: Firebase NoSQL database
- **Onboarding**: Initial user profile configuration process
- **Splash**: Initial screen displayed when opening the application
- **OTP**: One-Time Password (single-use verification code)
- **SharedPreferences**: Local storage for simple device data

## Requirements

### Requirement 1: Splash and Navigation Decision

**User Story:** As a user, I want the app to automatically direct me to the correct screen when opening, so that I have a smooth experience without needing to navigate manually.

#### Acceptance Criteria

1. WHEN the app is opened, THE System SHALL display the splash screen for a minimum of 2 seconds
2. WHEN checking user state, THE System SHALL first verify if there is an authenticated user in Firebase_Auth
3. IF the user is not authenticated, THEN THE System SHALL check if it is the first access via SharedPreferences
4. WHEN it is the first access (isFirstAccess == true), THE System SHALL navigate to /onboarding
5. WHEN it is not the first access (isFirstAccess == false), THE System SHALL navigate to /auth
6. IF the user is authenticated, THEN THE System SHALL fetch the user document from Firestore
7. WHEN the onboardingCompleted field is false, THE System SHALL navigate to /onboarding
8. WHEN the onboardingCompleted field is true, THE System SHALL navigate to /home
9. IF the Firestore fetch fails, THEN THE System SHALL navigate to /auth
10. WHEN there is no internet connection, THE System SHALL display message "Verifique sua conexão com a internet" with "Tentar novamente" button
11. THE System SHALL apply a 5-second timeout to the Firestore verification
12. WHEN the timeout is reached, THE System SHALL navigate to /auth

### Requirement 2: User Login

**User Story:** As an existing user, I want to log in with my email and password, so that I can access my account and continue my learning.

#### Acceptance Criteria

1. WHEN the user submits email and password, THE System SHALL validate that both fields are not empty
2. WHEN the email is empty, THE System SHALL display error "E-mail é obrigatório."
3. WHEN the password is empty, THE System SHALL display error "Senha é obrigatória."
4. WHEN the email is not valid, THE System SHALL display error "Por favor, insira um e-mail válido."
5. WHEN the credentials are valid, THE System SHALL authenticate via Firebase_Auth.signInWithEmailAndPassword
6. WHEN authentication is successful, THE System SHALL fetch the user document from Firestore
7. WHEN onboardingCompleted is false, THE System SHALL navigate to /onboarding
8. WHEN onboardingCompleted is true, THE System SHALL update the lastActiveAt field with FieldValue.serverTimestamp()
9. WHEN lastActiveAt is updated, THE System SHALL navigate to /home using Get.offAllNamed
10. IF authentication fails with user-not-found, THEN THE System SHALL display "Não encontramos uma conta com este e-mail."
11. IF authentication fails with wrong-password, THEN THE System SHALL display "Senha incorreta. Verifique e tente novamente."
12. IF authentication fails with invalid-email, THEN THE System SHALL display "Por favor, insira um e-mail válido."
13. IF authentication fails with user-disabled, THEN THE System SHALL display "Esta conta foi desativada. Entre em contato com o suporte."
14. IF authentication fails with too-many-requests, THEN THE System SHALL display "Muitas tentativas. Aguarde alguns minutos e tente novamente."
15. IF authentication fails with network-request-failed, THEN THE System SHALL display "Verifique sua conexão com a internet."
16. IF authentication fails with invalid-credential, THEN THE System SHALL display "E-mail ou senha incorretos."
17. WHEN authentication is in progress, THE System SHALL display loading indicator and disable the login button


### Requirement 3: Password Recovery

**User Story:** As a user who forgot my password, I want to be able to reset it through a code sent by email, so that I can recover access to my account.

#### Acceptance Criteria

1. WHEN the user requests password recovery, THE System SHALL validate that the email is not empty
2. WHEN the email is empty, THE System SHALL display error "E-mail é obrigatório."
3. WHEN the email is not valid, THE System SHALL display error "Por favor, insira um e-mail válido."
4. WHEN the email is valid, THE System SHALL generate a 5-digit numeric OTP code
5. WHEN the code is generated, THE System SHALL send email with the code via Firebase_Auth.sendPasswordResetEmail
6. WHEN the email is sent, THE System SHALL store the code temporarily with a 10-minute expiration timestamp
7. WHEN the code is stored, THE System SHALL navigate to the code verification screen
8. WHEN the user enters the code, THE System SHALL validate that it is exactly 5 digits
9. WHEN the code is incomplete, THE System SHALL keep the verification button disabled
10. WHEN the code is complete, THE System SHALL validate if it matches the stored code
11. WHEN the code is correct and not expired, THE System SHALL navigate to new password screen
12. WHEN the code is incorrect, THE System SHALL display error "Código inválido. Verifique e tente novamente."
13. WHEN the code has expired, THE System SHALL display error "Código expirado. Solicite um novo código."
14. WHEN the user requests resend, THE System SHALL wait 60 seconds since the last send
15. WHEN the 60-second timer has not finished, THE System SHALL display countdown timer
16. WHEN the timer finishes, THE System SHALL enable the resend button
17. WHEN the user defines a new password, THE System SHALL validate that it has at least 6 characters
18. WHEN the password is too short, THE System SHALL display error "A senha deve ter pelo menos 6 caracteres."
19. WHEN the new password is valid, THE System SHALL update the password via Firebase_Auth
20. WHEN the password is updated, THE System SHALL navigate to login screen with success message

### Requirement 4: Form Validation

**User Story:** As a user, I want to receive immediate feedback about form errors, so that I can quickly correct them and proceed.

#### Acceptance Criteria

1. WHEN the user submits a form, THE System SHALL validate all fields before processing
2. WHEN a required field is empty, THE System SHALL display error message below the field
3. WHEN the email does not follow valid format, THE System SHALL display error "Por favor, insira um e-mail válido."
4. WHEN the password has less than 6 characters, THE System SHALL display error "A senha deve ter pelo menos 6 caracteres."
5. WHEN there are validation errors, THE System SHALL focus on the first field with error
6. WHEN all fields are valid, THE System SHALL allow form submission
7. THE System SHALL display error messages in Portuguese
8. THE System SHALL clear error messages when the user corrects the field

### Requirement 5: Loading States

**User Story:** As a user, I want to see visual indicators when the app is processing my actions, so that I know the system is responding.

#### Acceptance Criteria

1. WHEN an asynchronous operation starts, THE System SHALL display loading indicator
2. WHEN in loading state, THE System SHALL disable action buttons to prevent multiple clicks
3. WHEN the operation is completed, THE System SHALL remove the loading indicator
4. WHEN the operation fails, THE System SHALL remove loading and display error message
5. THE System SHALL use CircularProgressIndicator for operations of indeterminate duration
6. WHEN loading exceeds 5 seconds, THE System SHALL apply timeout and display error

### Requirement 6: State Persistence

**User Story:** As a user, I want the app to remember if I have accessed it before, so that I don't need to go through onboarding again.

#### Acceptance Criteria

1. WHEN the user completes onboarding for the first time, THE System SHALL save isFirstAccess = false in SharedPreferences
2. WHEN the user completes onboarding, THE System SHALL save onboardingCompleted = true in Firestore
3. WHEN the app is opened, THE System SHALL check isFirstAccess in SharedPreferences
4. WHEN the user logs out, THE System SHALL maintain isFirstAccess = false
5. THE System SHALL use SharedPreferences for non-sensitive local data
6. THE System SHALL use Firestore for data synchronized across devices


### Requirement 7: Secure Navigation

**User Story:** As a user, I want navigation between screens to be smooth and without the possibility of going back to previous screens after login, for a consistent experience.

#### Acceptance Criteria

1. WHEN the user logs in successfully, THE System SHALL use Get.offAllNamed('/home')
2. WHEN the user completes onboarding, THE System SHALL use Get.offAllNamed('/home')
3. WHEN the user logs out, THE System SHALL use Get.offAllNamed('/auth')
4. WHEN navigating with offAllNamed, THE System SHALL clear the entire previous navigation stack
5. THE System SHALL prevent the user from going back to splash after navigation decision
6. THE System SHALL prevent the user from going back to auth after successful login

### Requirement 8: Firebase Error Handling

**User Story:** As a user, I want to receive clear error messages in Portuguese when something goes wrong, so that I understand the problem and know how to solve it.

#### Acceptance Criteria

1. WHEN a Firebase_Auth error occurs, THE System SHALL map the error code to a Portuguese message
2. WHEN a Firestore error occurs, THE System SHALL map the error code to a Portuguese message
3. THE System SHALL display friendly messages without technical terms
4. WHEN a network error occurs, THE System SHALL display "Verifique sua conexão com a internet."
5. WHEN an unknown error occurs, THE System SHALL display an appropriate generic message
6. THE System SHALL log technical errors only to the console, not to the user
7. THE System SHALL use the standardized error handlers defined in firebase.md

### Requirement 9: Data Security

**User Story:** As a user, I want my authentication data to be handled securely, to protect my privacy and account.

#### Acceptance Criteria

1. THE System SHALL never log passwords to the console or logs
2. THE System SHALL never log authentication tokens
3. THE System SHALL use HTTPS for all communications with Firebase
4. WHEN storing sensitive data locally, THE System SHALL use FlutterSecureStorage
5. WHEN storing non-sensitive data, THE System SHALL use SharedPreferences
6. THE System SHALL validate all inputs before sending to the server
7. THE System SHALL clear sensitive data from memory after use

### Requirement 10: Onboarding Integration

**User Story:** As a new user, I want to be directed to complete my profile after first login, so that I can personalize my learning experience.

#### Acceptance Criteria

1. WHEN the user logs in for the first time, THE System SHALL check the onboardingCompleted field
2. WHEN onboardingCompleted is false or does not exist, THE System SHALL navigate to /onboarding
3. WHEN the user completes onboarding, THE System SHALL update onboardingCompleted = true
4. WHEN onboardingCompleted is true, THE System SHALL navigate directly to /home
5. THE System SHALL preserve the authentication state during onboarding
6. THE System SHALL allow the user to complete onboarding across multiple sessions
