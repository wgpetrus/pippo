# Design Document - Onboarding

## Overview

The onboarding module manages the complete first-time user experience in the Pippo application, collecting user preferences, creating accounts, and initializing the learning environment. It implements a 14-screen flow (9 data collection screens + 4 transition screens + 1 welcome screen) that guides users through language selection, profile creation, account setup, and email verification.

The module supports two modes:
1. **Full Onboarding**: Complete flow for new users (14 screens)
2. **Add Course Mode**: Simplified flow for existing users adding a new language (4 screens)

The architecture follows GetX patterns with a single OnboardingController managing all state and a dedicated OnboardingNavigation class handling screen transitions. All Firebase operations follow standardized error handling patterns defined in the company's firebase.md guidelines.

## Architecture

### Module Structure

```
features/core/onboarding/
├── bindings/
│   └── onboarding_binding.dart
├── controllers/
│   └── onboarding_controller.dart
├── navigation/
│   └── onboarding_navigation.dart
├── views/
│   ├── welcome_view.dart
│   ├── language_view/
│   │   ├── select_language_page.dart
│   │   ├── language_level_page.dart
│   │   └── learning_reason_page.dart
│   ├── time_view/
│   │   └── study_time_page.dart
│   ├── profile_view/
│   │   ├── user_name_page.dart
│   │   ├── user_age_page.dart
│   │   ├── user_email_page.dart
│   │   ├── user_password_page.dart
│   │   └── verify_code_page.dart
│   └── transitions_view/
│       ├── intro_page.dart
│       ├── pause_one_page.dart
│       ├── pause_two_page.dart
│       └── conclusion_page.dart
└── widgets/
    ├── bouncing_mascot.dart
    ├── onboarding_header.dart
    ├── onboarding_text_field.dart
    ├── option_card.dart
    └── progress_bar.dart
```

### Flow Diagram

```
Welcome → SelectLanguage → LanguageLevel → LearningReason → Intro (transition)
  ↓
StudyTime → PauseOne (transition)
  ↓
UserName → UserAge → PauseTwo (transition)
  ↓
UserEmail → UserPassword → VerifyCode → Account Finalization → Conclusion (transition)
  ↓
/home (Get.offAllNamed)
```

### Add Course Mode Flow

```
SelectLanguage → LanguageLevel → LearningReason → StudyTime → Conclusion → /home
```


## Components and Interfaces

### OnboardingController

**Responsibilities:**
- Manage onboarding flow state and data collection
- Handle Firebase Auth account creation
- Generate and verify OTP codes
- Create Firestore user documents and courses
- Initialize gamification stats
- Coordinate with OnboardingNavigation for screen transitions

**Key Methods:**
```dart
// Validation
String? validateName(String? value)
String? validateEmail(String? value)
String? validatePassword(String? value)

// Account Creation
Future<void> createAccount()
Future<void> sendVerificationCode()
Future<void> resendVerificationCode()
Future<void> verifyCode(String code)

// Account Finalization
Future<String> generateUniqueUsername(String name)
Future<void> finalizeAccount()
Future<void> createUserDocument(String userId, String username)
Future<void> createFirstCourse(String userId)
Future<void> initializeGamificationStats(String userId)

// Add Course Mode
Future<void> addNewCourse()

// Completion
Future<void> completeOnboarding()

// Private helpers
String _generateOTP()
void _startResendTimer()
```

**Observable States:**
```dart
// Required states
final isLoading = false.obs;
final errorMessage = ''.obs;

// Mode flags
final isAddingCourse = false.obs;
final skipWelcome = false.obs;

// Language data
final selectedLanguage = ''.obs;  // e.g., "en", "es", "fr"
final languageLevel = ''.obs;     // "beginner", "intermediate", "advanced"
final learningReason = ''.obs;    // "travel", "work", "culture", "brain", "other"

// Time data
final studyTime = ''.obs;         // "5", "10", "15", "20"

// Profile data
final userName = ''.obs;
final userAge = ''.obs;           // "under_13", "13-17", "18-24", "25-34", "35+"
final userEmail = ''.obs;
final userPassword = ''.obs;

// OTP data (follows AuthController pattern)
final resendTimer = 0.obs;        // Countdown timer for resend (60 seconds)

// Private state
String? _tempEmail;               // Temporary email storage for OTP operations
Timer? _resendCountdownTimer;     // Timer instance for countdown
```

### OnboardingNavigation

**Responsibilities:**
- Provide navigation methods for all onboarding screens
- Maintain consistent navigation patterns (Get.to for internal, Get.offAllNamed for completion)
- Handle back navigation

**Key Methods:**
```dart
// Language flow
void goToSelectLanguage()
void goToLanguageLevel()
void goToLearningReason()

// Transitions
void goToIntro()
void goToPauseOne()
void goToPauseTwo()
void goToConclusion()

// Time
void goToStudyTime()

// Profile
void goToUserName()
void goToUserAge()
void goToUserEmail()
void goToUserPassword()
void goToVerifyCode()

// Completion
void finishOnboarding()  // Get.offAllNamed('/home')
void goToAuth()          // Get.toNamed('/auth')
```

### Views

All views use existing global widgets where possible:

**WelcomeView (StatelessWidget):**
- BouncingMascot widget
- AppButton for "Get Started"
- TextButton for "I already have an account"

**SelectLanguagePage (StatefulWidget):**
- OnboardingHeader with progress bar
- Grid of OptionCard widgets (language flags)
- AppButton for "Continue"

**LanguageLevelPage (StatefulWidget):**
- OnboardingHeader with progress bar
- List of OptionCard widgets (levels)
- AppButton for "Continue"

**LearningReasonPage (StatefulWidget):**
- OnboardingHeader with progress bar
- List of OptionCard widgets (reasons)
- AppButton for "Continue"

**IntroPage, PauseOnePage, PauseTwoPage (StatelessWidget):**
- Mascot with animation
- Motivational text
- AppButton for "Continue"

**StudyTimePage (StatefulWidget):**
- OnboardingHeader with progress bar
- List of OptionCard widgets (time options)
- AppButton for "Continue"

**UserNamePage (StatefulWidget):**
- OnboardingHeader with progress bar
- OnboardingTextField for name input
- AppButton for "Continue"

**UserAgePage (StatefulWidget):**
- OnboardingHeader with progress bar
- List of OptionCard widgets (age ranges)
- AppButton for "Continue"

**UserEmailPage (StatefulWidget):**
- OnboardingHeader with progress bar
- OnboardingTextField for email input
- AppButton for "Continue"

**UserPasswordPage (StatefulWidget):**
- OnboardingHeader with progress bar
- OnboardingTextField for password input with toggle visibility
- Password requirements text
- AppButton for "Continue"

**VerifyCodePage (StatefulWidget):**
- OnboardingHeader with progress bar
- Text with masked email
- AppPinput for 5-digit code
- AppResendCode with 60-second timer
- AppButton for "Verify"

**ConclusionPage (StatelessWidget):**
- Mascot celebrating
- Success message
- Stats preview
- AppButton for "Start Learning"

### Widgets

**Existing Global Widgets (shared/widgets/):**
- AppButton - Primary action buttons
- AppPinput - OTP code input
- AppResendCode - Resend timer component

**Feature Widgets (onboarding/widgets/):**
- BouncingMascot - Animated mascot character
- OnboardingHeader - Header with back button and progress bar
- OnboardingTextField - Customized text input for onboarding
- OptionCard - Selectable card with icon/image and text
- ProgressBar - Visual progress indicator


## Data Models

### User Document (Firestore)

```dart
// Firestore path: users/{userId}
{
  "id": String,                    // Firebase Auth UID
  "email": String,                 // User email
  "name": String,                  // Display name
  "username": String,              // Unique username (lowercase, no spaces)
  "age": String,                   // Age range: "under_13", "13-17", "18-24", "25-34", "35+"
  "onboardingCompleted": bool,     // true after onboarding
  "createdAt": Timestamp,          // FieldValue.serverTimestamp()
  "updatedAt": Timestamp,          // FieldValue.serverTimestamp()
  "lastActiveAt": Timestamp?       // Updated on login
}
```

### Course Document (Firestore)

```dart
// Firestore path: users/{userId}/courses/{courseId}
{
  "id": String,                    // Firestore auto-generated ID
  "language": String,              // Language code: "en", "es", "fr", etc.
  "languageName": String,          // Display name: "English", "Spanish", etc.
  "level": String,                 // "beginner", "intermediate", "advanced"
  "reason": String,                // "travel", "work", "culture", "brain", "other"
  "studyTime": int,                // Daily goal in minutes: 5, 10, 15, 20
  "isActive": bool,                // true for current course
  "createdAt": Timestamp           // FieldValue.serverTimestamp()
}
```

### Gamification Stats Document (Firestore)

```dart
// Firestore path: users/{userId}/stats/gamification
{
  "xp": int,                       // Experience points (starts at 0)
  "level": int,                    // User level (starts at 1)
  "streak": int,                   // Consecutive days (starts at 0)
  "energy": int,                   // Available energy/hearts (starts at 5)
  "gems": int,                     // Virtual currency (starts at 0)
  "hearts": int,                   // Lives (starts at 5)
  "lastActiveAt": Timestamp        // FieldValue.serverTimestamp()
}
```

### OTP Storage (Firestore)

```dart
// Firestore path: emailVerifications/{email}
{
  "code": String,                  // 5-digit numeric code
  "expiresAt": Timestamp,          // Current time + 10 minutes
  "attempts": int,                 // Number of verification attempts (starts at 0)
  "createdAt": Timestamp           // FieldValue.serverTimestamp()
}

// Note: Document key is the user's email address
// This follows the same pattern as passwordResets collection in AuthController
```

### SharedPreferences Keys

```dart
static const String keyIsFirstAccess = 'isFirstAccess';
// true = first time opening app (default)
// false = user has completed onboarding or logged in
```

### Language Options

```dart
final availableLanguages = [
  {'code': 'en', 'name': 'English', 'flag': 'assets/flags/en.png'},
  {'code': 'es', 'name': 'Spanish', 'flag': 'assets/flags/es.png'},
  {'code': 'fr', 'name': 'French', 'flag': 'assets/flags/fr.png'},
  {'code': 'de', 'name': 'German', 'flag': 'assets/flags/de.png'},
  {'code': 'it', 'name': 'Italian', 'flag': 'assets/flags/it.png'},
  {'code': 'pt', 'name': 'Portuguese', 'flag': 'assets/flags/pt.png'},
];
```

### Progress Calculation

```dart
// Full onboarding: 9 screens (excludes 4 transitions + 1 welcome)
// Screens: SelectLanguage(1), LanguageLevel(2), LearningReason(3),
//          StudyTime(4), UserName(5), UserAge(6),
//          UserEmail(7), UserPassword(8), VerifyCode(9)

// Add course mode: 4 screens
// Screens: SelectLanguage(1), LanguageLevel(2), LearningReason(3), StudyTime(4)

int calculateProgress(String currentScreen, bool isAddingCourse) {
  if (isAddingCourse) {
    final screens = ['select_language', 'language_level', 'learning_reason', 'study_time'];
    return screens.indexOf(currentScreen) + 1;
  } else {
    final screens = [
      'select_language', 'language_level', 'learning_reason',
      'study_time', 'user_name', 'user_age',
      'user_email', 'user_password', 'verify_code'
    ];
    return screens.indexOf(currentScreen) + 1;
  }
}
```


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Selection Flow Navigation

*For any* selection screen (language, level, reason, study time, age), when a valid selection is made and continue is clicked, the system should navigate to the next screen in the flow and store the selected value.

**Validates: Requirements 2.2, 2.3, 2.5, 2.6, 2.8, 2.9, 3.2, 3.3, 4.5, 4.6, 4.8, 4.9**

### Property 2: Data Persistence Consistency

*For any* data collected during onboarding (language, level, reason, study time, name, age, email, password), the stored value in the controller should exactly match the value selected or entered by the user.

**Validates: Requirements 2.2, 2.5, 2.8, 3.2, 4.5, 4.8, 5.5, 5.11**

### Property 3: Input Validation Completeness

*For any* form field (name, email, password), validation rules should be applied before allowing submission, and appropriate Portuguese error messages should be displayed for invalid inputs.

**Validates: Requirements 4.2, 4.3, 4.4, 5.2, 5.3, 5.4, 5.9, 5.10, 11.1, 11.2, 11.3, 11.4, 11.5**

### Property 4: Progress Calculation Accuracy

*For any* screen in the onboarding flow, the progress bar should display the correct fraction (current/total) based on whether the user is in full onboarding or add course mode, excluding transition screens from the count.

**Validates: Requirements 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 9.8**

### Property 5: Loading State Consistency

*For any* asynchronous operation (account creation, Firestore writes, OTP sending), the loading indicator should be visible during execution and removed upon completion or error.

**Validates: Requirements 5.19, 7.20, 12.1, 12.2, 12.3, 12.4, 12.5**

### Property 6: Firebase Error Message Mapping

*For any* Firebase Auth or Firestore error code, the system should return a Portuguese error message that does not contain technical terms or error codes.

**Validates: Requirements 5.15, 5.16, 5.17, 5.18, 13.1, 13.2, 13.3, 13.4, 13.5**

### Property 7: OTP Lifecycle Management

*For any* OTP code generated, the code should be exactly 5 digits, stored with a 10-minute expiration, and rejected if verified after expiration or if the code doesn't match.

**Validates: Requirements 6.4, 6.5, 6.6, 6.7, 6.8, 6.12, 6.13, 6.14**

### Property 8: Username Uniqueness Guarantee

*For any* user name provided, the system should generate a unique username by converting to lowercase, removing spaces, and appending a random number (1-9999) if the username already exists in Firestore, repeating until a unique username is found.

**Validates: Requirements 7.1, 7.2, 7.3, 7.4**

### Property 9: Firestore Document Structure Completeness

*For any* user completing onboarding, the system should create three documents: (1) user document with all required fields, (2) course document in subcollection with Firestore auto-generated ID, (3) gamification stats document with initial values, all using FieldValue.serverTimestamp() for timestamps.

**Validates: Requirements 7.5, 7.6, 7.7, 7.8, 7.9, 7.10, 7.11, 7.12, 7.13, 7.14, 7.15**

### Property 10: Add Course Mode Behavior

*For any* user in add course mode (isAddingCourse = true), the system should skip welcome, name, age, email, password, and verification screens, only show language selection and study time screens, create only a new course document without modifying user document or stats, and not update SharedPreferences.

**Validates: Requirements 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8**

### Property 11: Navigation Stack Management

*For any* onboarding screen except welcome and transition screens, the back button should be visible and functional, allowing navigation to the previous screen while preserving entered data.

**Validates: Requirements 10.1, 10.2, 10.3, 10.4, 10.5, 10.6**

### Property 12: Sensitive Data Protection

*For any* log output or error message, the system should never include passwords, authentication tokens, or email addresses in plain text.

**Validates: Requirements 14.1, 14.2, 14.3**

### Property 13: Transition Screen Behavior

*For any* transition screen (intro, pause one, pause two, conclusion), the screen should display mascot animation and motivational text, not count toward progress calculation, not allow back navigation, and automatically proceed to the next screen when continue is clicked.

**Validates: Requirements 15.1, 15.2, 15.3, 15.4, 15.5, 15.6, 15.7, 15.8, 15.9, 15.10**

### Property 14: Navigation Method Correctness

*For any* navigation from welcome to auth, the system should use Get.toNamed (not Get.offAllNamed) to preserve the navigation stack and allow returning to onboarding.

**Validates: Requirements 1.5, 1.7**

### Property 15: Final Navigation Stack Clearing

*For any* successful onboarding completion, the system should use Get.offAllNamed('/home') to clear the entire navigation stack and prevent returning to onboarding screens.

**Validates: Requirements 7.18**


## Error Handling

### Firebase Auth Error Handler

```dart
String _handleFirebaseAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'email-already-in-use':
      return 'Este e-mail já está sendo usado por outra conta.';
    case 'invalid-email':
      return 'Por favor, insira um e-mail válido.';
    case 'operation-not-allowed':
      return 'Operação não permitida no momento.';
    case 'weak-password':
      return 'A senha deve ter pelo menos 6 caracteres.';
    case 'network-request-failed':
      return 'Verifique sua conexão com a internet.';
    case 'too-many-requests':
      return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
    default:
      return 'Não foi possível criar sua conta. Tente novamente.';
  }
}
```

### Firestore Error Handler

```dart
String _handleFirestoreError(FirebaseException e) {
  switch (e.code) {
    case 'permission-denied':
      return 'Erro de permissão. Verifique as configurações do Firestore ou tente novamente em alguns instantes.';
    case 'unavailable':
      return 'Serviço temporariamente indisponível. Tente novamente em alguns instantes.';
    case 'deadline-exceeded':
      return 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    case 'resource-exhausted':
      return 'Muitas requisições. Aguarde alguns minutos e tente novamente.';
    case 'unauthenticated':
      return 'Usuário não autenticado. Faça login novamente.';
    case 'not-found':
      return 'Recurso não encontrado.';
    case 'already-exists':
      return 'Recurso já existe.';
    default:
      return 'Erro ao salvar dados. Verifique sua conexão e tente novamente.';
  }
}
```

### Validation Error Messages

```dart
// Name validation
String? validateName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Nome é obrigatório.';
  }
  return null;
}

// Email validation
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'E-mail é obrigatório.';
  }
  if (!GetUtils.isEmail(value)) {
    return 'Por favor, insira um e-mail válido.';
  }
  return null;
}

// Password validation
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Senha é obrigatória.';
  }
  if (value.length < 6) {
    return 'A senha deve ter pelo menos 6 caracteres.';
  }
  return null;
}
```

### OTP Generation and Storage

```dart
/// Generates 5-digit OTP code (follows AuthController pattern)
String _generateOTP() {
  final random = Random();
  final code = (10000 + random.nextInt(90000)).toString();
  return code;
}

/// Starts 60-second resend timer (follows AuthController pattern)
void _startResendTimer() {
  resendTimer.value = 60;
  _resendCountdownTimer?.cancel();

  _resendCountdownTimer = Timer.periodic(
    const Duration(seconds: 1),
    (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        timer.cancel();
      }
    },
  );
}

/// Sends verification code (follows AuthController pattern)
Future<void> sendVerificationCode() async {
  isLoading.value = true;
  errorMessage.value = '';

  try {
    // Generate OTP code
    final code = _generateOTP();

    // Store code in Firestore with expiration
    await _firestore.collection('emailVerifications').doc(userEmail.value).set({
      'code': code,
      'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 10))),
      'attempts': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // ⚠️ CRITICAL - INCOMPLETE IMPLEMENTATION ⚠️
    // TODO: [PRODUCTION REQUIRED] Implement email sending
    // 
    // CURRENT PROBLEM:
    // - Code is generated and saved to Firestore ✅
    // - BUT user does NOT receive email with code ❌
    // - For testing now: access Firestore Console and copy code manually
    // 
    // PRODUCTION SOLUTION:
    // Option 1 (Recommended): Cloud Function
    //   1. Create Cloud Function that listens to new documents in 'emailVerifications'
    //   2. Function sends email via SendGrid/Mailgun/AWS SES
    //   3. Code never exposed in client (more secure)
    // 
    // Option 2 (Alternative): Direct Email Service
    //   1. Integrate email package (emailjs, sendgrid_mailer)
    //   2. Send email directly from app
    //   3. Less secure (API key in client)
    // 
    // REFERENCES:
    // - Firebase Cloud Functions: https://firebase.google.com/docs/functions
    // - SendGrid: https://sendgrid.com/
    // - Mailgun: https://www.mailgun.com/
    // 
    // ⚠️ DO NOT DEPLOY TO PRODUCTION WITHOUT IMPLEMENTING EMAIL SENDING ⚠️

    // Store email temporarily for resend
    _tempEmail = userEmail.value;

    // Start 60-second resend timer
    _startResendTimer();

    // Navigate to verification screen
    nav.goToVerifyCode();
  } on FirebaseException catch (e) {
    errorMessage.value = _handleFirestoreError(e);
  } catch (e) {
    errorMessage.value = 'Não foi possível enviar o código. Tente novamente.';
  } finally {
    isLoading.value = false;
  }
}

/// Resends verification code (follows AuthController pattern)
Future<void> resendVerificationCode() async {
  if (_tempEmail == null) {
    errorMessage.value = 'Sessão expirada. Inicie o processo novamente.';
    return;
  }

  isLoading.value = true;
  errorMessage.value = '';

  try {
    // Generate new OTP code
    final code = _generateOTP();

    // Store code in Firestore with expiration
    await _firestore.collection('emailVerifications').doc(_tempEmail!).set({
      'code': code,
      'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 10))),
      'attempts': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // ⚠️ CRITICAL - SAME PROBLEM AS sendVerificationCode ⚠️
    // TODO: [PRODUCTION REQUIRED] Implement email sending
    // Code is generated but user does NOT receive email
    // See detailed comments in sendVerificationCode()

    // Restart 60-second resend timer
    _startResendTimer();

    // Success feedback
    Get.snackbar(
      'Código reenviado',
      'Um novo código foi enviado para seu e-mail.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  } on FirebaseException catch (e) {
    errorMessage.value = _handleFirestoreError(e);
  } catch (e) {
    errorMessage.value = 'Não foi possível reenviar o código. Tente novamente.';
  } finally {
    isLoading.value = false;
  }
}

/// Verifies OTP code (follows AuthController pattern)
Future<void> verifyCode(String code) async {
  // Sanitize code (remove spaces)
  final sanitizedCode = code.trim();

  // Validate code is exactly 5 digits
  if (sanitizedCode.length != 5) {
    errorMessage.value = 'O código deve ter 5 dígitos.';
    return;
  }

  // Validate code contains only numbers
  final digitRegex = RegExp(r'^\d{5}$');
  if (!digitRegex.hasMatch(sanitizedCode)) {
    errorMessage.value = 'O código deve conter apenas números.';
    return;
  }

  isLoading.value = true;
  errorMessage.value = '';

  try {
    if (_tempEmail == null) {
      errorMessage.value = 'Sessão expirada. Inicie o processo novamente.';
      return;
    }

    // Retrieve code from Firestore
    final doc = await _firestore.collection('emailVerifications').doc(_tempEmail!).get();

    if (!doc.exists) {
      errorMessage.value = 'Código não encontrado. Solicite um novo código.';
      return;
    }

    final data = doc.data()!;
    final storedCode = data['code'] as String;
    final expiresAt = (data['expiresAt'] as Timestamp).toDate();

    // Check if code has expired (> 10 minutes)
    if (DateTime.now().isAfter(expiresAt)) {
      errorMessage.value = 'Código expirado. Solicite um novo código.';
      return;
    }

    // Check if code matches
    if (sanitizedCode != storedCode) {
      errorMessage.value = 'Código inválido. Verifique e tente novamente.';
      return;
    }

    // Code is valid - proceed to account finalization
    await finalizeAccount();
  } on FirebaseException catch (e) {
    errorMessage.value = _handleFirestoreError(e);
  } catch (e) {
    errorMessage.value = 'Erro ao verificar código. Tente novamente.';
  } finally {
    isLoading.value = false;
  }
}
```

### Username Generation Error Handling

```dart
Future<String> generateUniqueUsername(String name) async {
  try {
    String baseUsername = name.toLowerCase().replaceAll(' ', '');
    String username = baseUsername;
    int attempts = 0;
    const maxAttempts = 100;
    
    while (attempts < maxAttempts) {
      final doc = await _firestore.collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      
      if (doc.docs.isEmpty) {
        return username;
      }
      
      // Username exists, append random number
      final random = Random().nextInt(9999) + 1;
      username = '$baseUsername$random';
      attempts++;
    }
    
    throw Exception('Não foi possível gerar um nome de usuário único.');
  } catch (e) {
    throw Exception('Erro ao verificar nome de usuário. Tente novamente.');
  }
}
```


## Testing Strategy

### Unit Tests

Unit tests will verify specific examples and edge cases:

**OnboardingController Tests:**
- Name validation with empty, whitespace-only, and valid names
- Email validation with valid/invalid formats
- Password validation with various lengths
- Error message mapping for each Firebase error code
- OTP generation format (5 digits)
- OTP expiration logic (10 minutes)
- Resend timer countdown (60 seconds)
- Username generation with conflicts
- Progress calculation for each screen
- Add course mode flag behavior

**Navigation Tests:**
- Correct navigation method usage (Get.to vs Get.toNamed vs Get.offAllNamed)
- Back button availability on each screen
- Navigation stack preservation
- Skip welcome screen when flag is set

**Data Storage Tests:**
- Each selection stores correct value
- Data persists across navigation
- SharedPreferences isFirstAccess flag
- Firestore document structure

**Form Validation Tests:**
- Empty field detection
- Email format validation
- Password length validation
- Whitespace-only input rejection
- Error message display

### Property-Based Tests

Property tests will verify universal properties across all inputs using a property-based testing library (e.g., `faker` for data generation):

**Configuration:**
- Minimum 100 iterations per property test
- Each test tagged with: `Feature: onboarding, Property {number}: {property_text}`

**Property Test Examples:**

```dart
// Property 2: Data Persistence Consistency
test('Feature: onboarding, Property 2: Data Persistence Consistency', () {
  final controller = OnboardingController();
  final testData = [
    {'field': 'selectedLanguage', 'value': 'en'},
    {'field': 'languageLevel', 'value': 'beginner'},
    {'field': 'learningReason', 'value': 'travel'},
    {'field': 'studyTime', 'value': '10'},
    {'field': 'userName', 'value': 'John Doe'},
    {'field': 'userAge', 'value': '25-34'},
  ];
  
  for (final data in testData) {
    // Set value
    switch (data['field']) {
      case 'selectedLanguage':
        controller.selectedLanguage.value = data['value'] as String;
        break;
      case 'languageLevel':
        controller.languageLevel.value = data['value'] as String;
        break;
      // ... other cases
    }
    
    // Verify stored value matches
    final stored = controller.getFieldValue(data['field'] as String);
    expect(stored, equals(data['value']));
  }
});

// Property 4: Progress Calculation Accuracy
test('Feature: onboarding, Property 4: Progress Calculation Accuracy', () {
  final screens = [
    'select_language', 'language_level', 'learning_reason',
    'study_time', 'user_name', 'user_age',
    'user_email', 'user_password', 'verify_code'
  ];
  
  for (int i = 0; i < screens.length; i++) {
    final progress = calculateProgress(screens[i], false);
    expect(progress, equals(i + 1));
  }
  
  // Test add course mode
  final addCourseScreens = ['select_language', 'language_level', 'learning_reason', 'study_time'];
  for (int i = 0; i < addCourseScreens.length; i++) {
    final progress = calculateProgress(addCourseScreens[i], true);
    expect(progress, equals(i + 1));
  }
});

// Property 6: Firebase Error Message Mapping
test('Feature: onboarding, Property 6: Firebase Error Message Mapping', () {
  final controller = OnboardingController();
  final errorCodes = [
    'email-already-in-use',
    'invalid-email',
    'weak-password',
    'network-request-failed',
  ];
  
  for (final code in errorCodes) {
    final error = FirebaseAuthException(code: code);
    final message = controller.handleAuthError(error);
    
    // Property: message must be in Portuguese and not contain technical terms
    expect(message, isNot(contains(code)));
    expect(message, isNot(contains('Exception')));
    expect(message, isNot(contains('Error')));
    expect(message, isNot(contains('error')));
  }
});

// Property 7: OTP Lifecycle Management
test('Feature: onboarding, Property 7: OTP Lifecycle Management', () {
  for (int i = 0; i < 100; i++) {
    // Generate OTP
    final otp = generateOTP();
    
    // Verify format (5 digits)
    expect(otp.length, equals(5));
    expect(int.tryParse(otp), isNotNull);
    
    // Test expiration
    final now = DateTime.now();
    final minutesAgo = Random().nextInt(20); // 0-20 minutes ago
    final createdAt = now.subtract(Duration(minutes: minutesAgo));
    final expiration = createdAt.add(Duration(minutes: 10));
    
    final isExpired = now.isAfter(expiration);
    final shouldBeRejected = minutesAgo > 10;
    
    expect(isExpired, equals(shouldBeRejected));
  }
});

// Property 8: Username Uniqueness Guarantee
test('Feature: onboarding, Property 8: Username Uniqueness Guarantee', () async {
  final controller = OnboardingController();
  final names = ['John Doe', 'Jane Smith', 'Bob Wilson'];
  final generatedUsernames = <String>{};
  
  for (final name in names) {
    for (int i = 0; i < 10; i++) {
      final username = await controller.generateUniqueUsername(name);
      
      // Property: username must be unique
      expect(generatedUsernames.contains(username), false);
      generatedUsernames.add(username);
      
      // Property: username must be lowercase with no spaces
      expect(username, equals(username.toLowerCase()));
      expect(username.contains(' '), false);
    }
  }
});

// Property 12: Sensitive Data Protection
test('Feature: onboarding, Property 12: Sensitive Data Protection', () {
  final controller = OnboardingController();
  final sensitiveData = [
    'password123',
    'test@example.com',
    'authToken12345',
  ];
  
  // Simulate various operations and check logs
  for (final data in sensitiveData) {
    controller.userPassword.value = data;
    controller.userEmail.value = data;
    
    // Verify sensitive data is not in error messages
    final error = controller.errorMessage.value;
    expect(error.contains(data), false);
  }
});
```

### Integration Tests

Integration tests will verify complete flows:

- Complete full onboarding flow: welcome → language → profile → account → verification → finalization → home
- Complete add course flow: language → study time → conclusion → home
- Back navigation preserving data
- Error recovery and retry mechanisms
- OTP resend flow
- Username conflict resolution
- Firestore document creation verification

### Test Coverage Goals

- Unit tests: 80%+ code coverage
- Property tests: All 15 correctness properties
- Integration tests: All critical user flows
- Error handling: All Firebase error codes


## Implementation Notes

### Critical Rules

1. **ALWAYS use Get.toNamed** for navigation to /auth (preserves stack)
2. **ALWAYS use Get.offAllNamed** for navigation to /home after completion (clears stack)
3. **ALWAYS use FieldValue.serverTimestamp()** for all Firestore timestamps
4. **ALWAYS use Firestore auto-generated IDs** for course ID generation (via .doc() without parameters)
5. **NEVER log passwords, tokens, or emails** to console
6. **ALWAYS validate inputs** before Firebase operations
7. **ALWAYS use standardized error handlers** from firebase.md
8. **ALWAYS check isAddingCourse flag** before showing/skipping screens
9. **ALWAYS exclude transition screens** from progress calculation
10. **ALWAYS generate unique username** by checking Firestore and appending numbers if needed

### State Management

- Use GetX `.obs` for reactive state
- Keep controller lean (no TextEditingController, no Streams)
- Views handle TextEditingController (StatefulWidget for forms)
- Validators in controller return `String?` (no side effects)
- Use OnboardingNavigation class for all screen transitions

### Security

- Use FlutterSecureStorage for OTP codes
- Use SharedPreferences for isFirstAccess flag
- Clear sensitive data after use
- Validate all inputs before sending to server
- Never expose passwords or tokens in logs or error messages

### Performance

- Show loading indicators for all async operations
- Minimize Firestore reads (batch operations where possible)
- Cache language options locally
- Use efficient username uniqueness check (limit(1) query)

### Localization

- All user-facing messages in Portuguese
- Error messages follow standardized patterns
- No technical terms in user messages
- Consistent terminology across the app

### Firebase Operations

**Account Creation Flow:**
1. Validate email and password
2. Create Firebase Auth user with createUserWithEmailAndPassword
3. Generate and send 5-digit OTP code
4. Store OTP with 10-minute expiration in FlutterSecureStorage
5. Navigate to verification screen

**Email Verification Flow:**
1. User enters 5-digit code
2. Retrieve stored OTP from FlutterSecureStorage
3. Validate code matches and not expired
4. Mark email as verified
5. Proceed to account finalization

**Account Finalization Flow:**
1. Generate unique username from name
2. Create user document in Firestore users/{userId}
3. Create first course in users/{userId}/courses/{courseId}
4. Initialize gamification stats in users/{userId}/stats/gamification
5. Save isFirstAccess = false to SharedPreferences
6. Navigate to conclusion screen
7. Navigate to /home with Get.offAllNamed

**Add Course Flow:**
1. Skip to language selection (no welcome, profile, account screens)
2. Collect language, level, reason, study time
3. Create new course document in users/{userId}/courses/{courseId}
4. Do NOT modify user document or stats
5. Do NOT update SharedPreferences
6. Navigate to /home with Get.offAllNamed

### Username Generation Algorithm

```dart
1. Convert name to lowercase
2. Remove all spaces
3. Check if username exists in Firestore (where username == value, limit 1)
4. If exists:
   a. Generate random number 1-9999
   b. Append to base username
   c. Check again
   d. Repeat until unique (max 100 attempts)
5. Return unique username
```

### Progress Calculation Logic

```dart
Full Onboarding (9 screens):
1. SelectLanguage
2. LanguageLevel
3. LearningReason
4. StudyTime
5. UserName
6. UserAge
7. UserEmail
8. UserPassword
9. VerifyCode

Excluded from count:
- WelcomeView
- IntroPage (transition)
- PauseOnePage (transition)
- PauseTwoPage (transition)
- ConclusionPage (transition)

Add Course Mode (4 screens):
1. SelectLanguage
2. LanguageLevel
3. LearningReason
4. StudyTime
```

### OTP Management

- Generate 5-digit numeric code using Random
- Store in FlutterSecureStorage with key 'onboarding_otp'
- Include expiration timestamp (current time + 10 minutes)
- Include associated email
- Clear from storage after successful verification
- Implement 60-second resend timer
- Generate new code on resend

### Navigation Patterns

**Internal Navigation (Get.to):**
- Between onboarding screens
- Preserves navigation stack
- Allows back button

**External Navigation (Get.toNamed):**
- From welcome to /auth
- Preserves navigation stack
- Allows returning to onboarding

**Final Navigation (Get.offAllNamed):**
- After onboarding completion to /home
- Clears entire navigation stack
- Prevents returning to onboarding

### Component Usage

**Use Existing Global Widgets:**
- AppButton for all action buttons
- AppPinput for OTP input
- AppResendCode for resend timer
- AppTextField where OnboardingTextField doesn't fit

**Use Feature Widgets:**
- OnboardingHeader for all screens with progress
- OnboardingTextField for name, email, password inputs
- OptionCard for all selection screens
- BouncingMascot for welcome and transitions
- ProgressBar (embedded in OnboardingHeader)

**Never Create:**
- Custom button widgets (use AppButton)
- Custom input widgets (use AppTextField or OnboardingTextField)
- Custom loading indicators (use CircularProgressIndicator)

