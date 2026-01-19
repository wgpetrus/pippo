# Requirements Document - Onboarding

## Introduction

This document defines the requirements for the Pippo onboarding system, a gamified language learning application. The system manages the complete first-time user experience, collecting user preferences, creating accounts, and initializing the learning environment. It supports both full onboarding for new users and a simplified "add course" mode for existing users.

## Glossary

- **System**: The onboarding module of the Pippo application
- **User**: Person using the application
- **Firebase_Auth**: Firebase authentication service
- **Firestore**: Firebase NoSQL database
- **OTP**: One-Time Password (single-use verification code)
- **SharedPreferences**: Local storage for simple device data
- **Course**: A language learning path with units and lessons
- **Gamification_Stats**: User progress metrics (XP, streak, energy, gems)
- **Username**: Unique identifier generated from user's name
- **Add_Course_Mode**: Simplified onboarding flow for existing users adding a new language

## Requirements

### Requirement 1: Welcome and Entry Point

**User Story:** As a new user, I want to see a welcoming introduction screen, so that I understand what the app offers and can choose to start or sign in.

#### Acceptance Criteria

1. WHEN the app navigates to onboarding, THE System SHALL display the welcome screen with mascot animation
2. WHEN the welcome screen is displayed, THE System SHALL show "Get Started" button
3. WHEN the welcome screen is displayed, THE System SHALL show "I already have an account" link
4. WHEN the user clicks "Get Started", THE System SHALL navigate to language selection
5. WHEN the user clicks "I already have an account", THE System SHALL navigate to /auth using Get.toNamed
6. WHEN coming from social login, THE System SHALL skip the welcome screen and go directly to language selection
7. THE System SHALL use Get.toNamed for auth navigation to allow returning to onboarding

### Requirement 2: Language Selection

**User Story:** As a user, I want to select which language I want to learn and my proficiency level, so that the app can provide appropriate content.

#### Acceptance Criteria

1. WHEN the user reaches language selection, THE System SHALL display a grid of available languages with flags
2. WHEN a language is selected, THE System SHALL store the language code and name
3. WHEN a language is selected, THE System SHALL navigate to language level selection
4. WHEN the user reaches language level, THE System SHALL display options: Beginner, Intermediate, Advanced
5. WHEN a level is selected, THE System SHALL store the selected level
6. WHEN a level is selected, THE System SHALL navigate to learning reason selection
7. WHEN the user reaches learning reason, THE System SHALL display options: Travel, Work, Culture, Brain Training, Other
8. WHEN a reason is selected, THE System SHALL store the selected reason
9. WHEN a reason is selected, THE System SHALL navigate to intro transition screen
10. THE System SHALL validate that a selection is made before allowing navigation
11. THE System SHALL update progress bar to reflect completion of language selection phase

### Requirement 3: Study Time Selection

**User Story:** As a user, I want to set my daily study goal, so that the app can provide appropriate lesson lengths and reminders.

#### Acceptance Criteria

1. WHEN the user reaches study time selection, THE System SHALL display options: 5, 10, 15, 20 minutes
2. WHEN a study time is selected, THE System SHALL store the selected time in minutes
3. WHEN a study time is selected, THE System SHALL navigate to pause one transition screen
4. THE System SHALL validate that a selection is made before allowing navigation
5. THE System SHALL update progress bar to reflect completion of study time phase

### Requirement 4: User Profile Creation

**User Story:** As a user, I want to provide my name and age range, so that the app can personalize my experience.

#### Acceptance Criteria

1. WHEN the user reaches name input, THE System SHALL display a text field for name entry
2. WHEN the user submits name, THE System SHALL validate that the name is not empty
3. WHEN the name is empty, THE System SHALL display error "Nome é obrigatório."
4. WHEN the name contains only whitespace, THE System SHALL display error "Nome é obrigatório."
5. WHEN the name is valid, THE System SHALL store the name
6. WHEN the name is valid, THE System SHALL navigate to age selection
7. WHEN the user reaches age selection, THE System SHALL display options: Under 13, 13-17, 18-24, 25-34, 35+
8. WHEN an age range is selected, THE System SHALL store the selected age range
9. WHEN an age range is selected, THE System SHALL navigate to pause two transition screen
10. THE System SHALL update progress bar to reflect completion of profile phase

### Requirement 5: Account Creation

**User Story:** As a user, I want to create an account with email and password, so that I can save my progress and access it from any device.

#### Acceptance Criteria

1. WHEN the user reaches email input, THE System SHALL display a text field for email entry
2. WHEN the user submits email, THE System SHALL validate that the email is not empty
3. WHEN the email is empty, THE System SHALL display error "E-mail é obrigatório."
4. WHEN the email is not valid, THE System SHALL display error "Por favor, insira um e-mail válido."
5. WHEN the email is valid, THE System SHALL store the email
6. WHEN the email is valid, THE System SHALL navigate to password input
7. WHEN the user reaches password input, THE System SHALL display a text field for password entry with toggle visibility
8. WHEN the user submits password, THE System SHALL validate that the password is not empty
9. WHEN the password is empty, THE System SHALL display error "Senha é obrigatória."
10. WHEN the password has less than 6 characters, THE System SHALL display error "A senha deve ter pelo menos 6 caracteres."
11. WHEN the password is valid, THE System SHALL store the password
12. WHEN the password is valid, THE System SHALL create Firebase Auth user with createUserWithEmailAndPassword
13. WHEN account creation is successful, THE System SHALL generate and send 5-digit OTP code to email
14. WHEN OTP is sent, THE System SHALL navigate to verification screen
15. IF account creation fails with email-already-in-use, THEN THE System SHALL display "Este e-mail já está sendo usado por outra conta."
16. IF account creation fails with invalid-email, THEN THE System SHALL display "Por favor, insira um e-mail válido."
17. IF account creation fails with weak-password, THEN THE System SHALL display "A senha deve ter pelo menos 6 caracteres."
18. IF account creation fails with network-request-failed, THEN THE System SHALL display "Verifique sua conexão com a internet."
19. WHEN account creation is in progress, THE System SHALL display loading indicator and disable buttons

### Requirement 6: Email Verification

**User Story:** As a user, I want to verify my email address with a code, so that the system can confirm my identity.

#### Acceptance Criteria

1. WHEN the user reaches verification screen, THE System SHALL display 5-digit OTP input field
2. WHEN the user reaches verification screen, THE System SHALL display masked email address
3. WHEN the user reaches verification screen, THE System SHALL start 60-second resend timer
4. WHEN the user enters 5 digits, THE System SHALL automatically verify the code
5. WHEN the code is correct and not expired, THE System SHALL mark email as verified
6. WHEN the code is correct, THE System SHALL navigate to account finalization
7. WHEN the code is incorrect, THE System SHALL display error "Código inválido. Verifique e tente novamente."
8. WHEN the code has expired (> 10 minutes), THE System SHALL display error "Código expirado. Solicite um novo código."
9. WHEN the user requests resend, THE System SHALL wait 60 seconds since last send
10. WHEN the 60-second timer has not finished, THE System SHALL display countdown timer
11. WHEN the timer finishes, THE System SHALL enable the resend button
12. WHEN resend is clicked, THE System SHALL generate new 5-digit OTP code
13. WHEN new code is generated, THE System SHALL send email and restart 60-second timer
14. THE System SHALL store OTP code in Firestore collection 'emailVerifications' with document key as user's email
15. THE System SHALL store OTP document with fields: code (String), expiresAt (Timestamp), attempts (int), createdAt (Timestamp)
16. WHEN storing OTP, THE System SHALL use FieldValue.serverTimestamp() for createdAt
17. WHEN storing OTP, THE System SHALL set expiresAt to current time + 10 minutes using Timestamp.fromDate()
18. WHEN verifying code, THE System SHALL retrieve document from Firestore using email as key
19. WHEN code is verified successfully, THE System SHALL delete the OTP document from Firestore

### Requirement 7: Account Finalization

**User Story:** As a user, I want my account to be fully configured with my learning preferences, so that I can start learning immediately.

#### Acceptance Criteria

1. WHEN email is verified, THE System SHALL generate unique username from user's name
2. WHEN generating username, THE System SHALL convert name to lowercase and remove spaces
3. WHEN generating username, THE System SHALL check if username exists in Firestore
4. WHEN username exists, THE System SHALL append random number (1-9999) and check again
5. WHEN username is unique, THE System SHALL create Firestore user document
6. WHEN creating user document, THE System SHALL include: id, email, name, username, age, onboardingCompleted: true
7. WHEN creating user document, THE System SHALL include: createdAt and updatedAt with FieldValue.serverTimestamp()
8. WHEN user document is created, THE System SHALL create first course in users/{userId}/courses subcollection
9. WHEN creating course, THE System SHALL use Firestore auto-generated ID (via .doc() without parameters)
10. WHEN creating course, THE System SHALL include: id, language, level, reason, studyTime, isActive: true
11. WHEN creating course, THE System SHALL include: createdAt with FieldValue.serverTimestamp()
12. WHEN course is created, THE System SHALL initialize gamification stats in users/{userId}/stats/gamification
13. WHEN initializing stats, THE System SHALL set: xp: 0, level: 1, streak: 0, energy: 5, gems: 0, hearts: 5
14. WHEN initializing stats, THE System SHALL set: lastActiveAt with FieldValue.serverTimestamp()
15. WHEN all data is saved, THE System SHALL save isFirstAccess = false to SharedPreferences
16. WHEN isFirstAccess is saved, THE System SHALL navigate to conclusion screen
17. WHEN conclusion screen is displayed, THE System SHALL show success message and stats preview
18. WHEN user clicks "Start Learning", THE System SHALL navigate to /home using Get.offAllNamed
19. IF Firestore operations fail, THEN THE System SHALL display appropriate error message
20. WHEN finalization is in progress, THE System SHALL display loading indicator

### Requirement 8: Add Course Mode

**User Story:** As an existing user, I want to add a new language course without going through full onboarding, so that I can learn multiple languages efficiently.

#### Acceptance Criteria

1. WHEN isAddingCourse flag is true, THE System SHALL skip welcome, name, age, email, password, and verification screens
2. WHEN in add course mode, THE System SHALL only show: language selection, level, reason, study time, conclusion
3. WHEN in add course mode, THE System SHALL use existing authenticated user
4. WHEN in add course mode, THE System SHALL create new course in users/{userId}/courses subcollection
5. WHEN in add course mode, THE System SHALL NOT modify user document or gamification stats
6. WHEN in add course mode, THE System SHALL NOT update isFirstAccess in SharedPreferences
7. WHEN in add course mode, THE System SHALL navigate to /home using Get.offAllNamed after completion
8. THE System SHALL validate user is authenticated before allowing add course mode

### Requirement 9: Progress Tracking

**User Story:** As a user, I want to see my progress through the onboarding flow, so that I know how much is left to complete.

#### Acceptance Criteria

1. WHEN the user is on any onboarding screen, THE System SHALL display progress bar at top
2. WHEN calculating progress, THE System SHALL exclude transition screens (intro, pause one, pause two, conclusion)
3. WHEN calculating progress, THE System SHALL count: language (3 screens), study time (1 screen), profile (5 screens)
4. WHEN on language selection screens, THE System SHALL show progress 1/9, 2/9, 3/9
5. WHEN on study time screen, THE System SHALL show progress 4/9
6. WHEN on profile screens, THE System SHALL show progress 5/9, 6/9, 7/9, 8/9, 9/9
7. WHEN in add course mode, THE System SHALL show progress 1/4, 2/4, 3/4, 4/4
8. THE System SHALL update progress bar smoothly as user advances

### Requirement 10: Navigation and Back Button

**User Story:** As a user, I want to be able to go back to previous screens if I want to change my selections, so that I have control over my choices.

#### Acceptance Criteria

1. WHEN the user is on any onboarding screen except welcome, THE System SHALL display back button
2. WHEN the back button is clicked, THE System SHALL navigate to previous screen using Get.back()
3. WHEN on welcome screen, THE System SHALL not display back button
4. WHEN on transition screens, THE System SHALL not allow going back
5. WHEN the user goes back, THE System SHALL preserve previously entered data
6. WHEN the user goes back, THE System SHALL update progress bar to reflect current position

### Requirement 11: Form Validation

**User Story:** As a user, I want to receive immediate feedback about form errors, so that I can quickly correct them and proceed.

#### Acceptance Criteria

1. WHEN the user submits a form, THE System SHALL validate all fields before processing
2. WHEN a required field is empty, THE System SHALL display error message below the field
3. WHEN the email does not follow valid format, THE System SHALL display error "Por favor, insira um e-mail válido."
4. WHEN the password has less than 6 characters, THE System SHALL display error "A senha deve ter pelo menos 6 caracteres."
5. WHEN the name contains only whitespace, THE System SHALL display error "Nome é obrigatório."
6. WHEN there are validation errors, THE System SHALL keep the continue button enabled but show errors
7. WHEN all fields are valid, THE System SHALL allow form submission
8. THE System SHALL display error messages in Portuguese
9. THE System SHALL clear error messages when the user corrects the field

### Requirement 12: Loading States

**User Story:** As a user, I want to see visual indicators when the app is processing my actions, so that I know the system is responding.

#### Acceptance Criteria

1. WHEN an asynchronous operation starts, THE System SHALL display loading indicator
2. WHEN in loading state, THE System SHALL disable action buttons to prevent multiple clicks
3. WHEN the operation is completed, THE System SHALL remove the loading indicator
4. WHEN the operation fails, THE System SHALL remove loading and display error message
5. THE System SHALL use CircularProgressIndicator for operations of indeterminate duration

### Requirement 13: Firebase Error Handling

**User Story:** As a user, I want to receive clear error messages in Portuguese when something goes wrong, so that I understand the problem and know how to solve it.

#### Acceptance Criteria

1. WHEN a Firebase_Auth error occurs, THE System SHALL map the error code to a Portuguese message
2. WHEN a Firestore error occurs, THE System SHALL map the error code to a Portuguese message
3. THE System SHALL display friendly messages without technical terms
4. WHEN a network error occurs, THE System SHALL display "Verifique sua conexão com a internet."
5. WHEN an unknown error occurs, THE System SHALL display an appropriate generic message
6. THE System SHALL log technical errors only to the console, not to the user
7. THE System SHALL use the standardized error handlers defined in firebase.md

### Requirement 14: Data Security

**User Story:** As a user, I want my personal data to be handled securely, to protect my privacy and account.

#### Acceptance Criteria

1. THE System SHALL never log passwords to the console or logs
2. THE System SHALL never log authentication tokens
3. THE System SHALL never log email addresses to console
4. THE System SHALL use HTTPS for all communications with Firebase
5. WHEN storing non-sensitive data, THE System SHALL use SharedPreferences
6. THE System SHALL validate all inputs before sending to the server
7. THE System SHALL clear sensitive data from memory after use
8. THE System SHALL use Firestore auto-generated IDs for course IDs (via .doc() without parameters)
9. WHEN storing OTP codes, THE System SHALL use Firestore with appropriate security rules
10. THE System SHALL delete OTP documents from Firestore after successful verification

### Requirement 15: Transition Screens

**User Story:** As a user, I want to see motivational messages during onboarding, so that I stay engaged and excited about learning.

#### Acceptance Criteria

1. WHEN the user completes language selection, THE System SHALL display intro transition screen
2. WHEN the user completes study time selection, THE System SHALL display pause one transition screen
3. WHEN the user completes age selection, THE System SHALL display pause two transition screen
4. WHEN the user completes verification, THE System SHALL display conclusion transition screen
5. WHEN on transition screens, THE System SHALL display mascot with animation
6. WHEN on transition screens, THE System SHALL display motivational text
7. WHEN on transition screens, THE System SHALL display "Continue" button
8. WHEN "Continue" is clicked on transition screen, THE System SHALL navigate to next onboarding step
9. THE System SHALL not count transition screens in progress calculation
10. THE System SHALL not allow going back from transition screens
