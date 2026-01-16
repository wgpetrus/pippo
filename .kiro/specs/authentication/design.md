# Design Document - Authentication

## Overview

The authentication module is responsible for managing user authentication, session state, and navigation decisions in the Pippo application. It implements a critical verification order that ensures users are correctly directed based on their authentication state and onboarding progress.

The module follows a simple, lean architecture using GetX for state management, Firebase Auth for authentication, and Firestore for user data persistence. All error handling follows standardized patterns defined in the company's firebase.md guidelines.

## Architecture

### Module Structure

```
features/core/auth/
├── bindings/
│   └── auth_binding.dart
├── controllers/
│   ├── auth_controller.dart
│   └── splash_controller.dart
├── views/
│   ├── signin_view.dart
│   ├── forgot_password_view.dart
│   ├── verify_code_view.dart
│   └── new_password_view.dart
└── widgets/
    └── social_button.dart

features/inners/splash/
├── bindings/
│   └── splash_binding.dart
├── controllers/
│   └── splash_controller.dart
└── views/
    └── splash_view.dart
```

### Critical Verification Order

The splash screen MUST follow this exact order (NEVER invert):

```
1. Check if user is authenticated (Firebase Auth)
   ↓
2. If NOT authenticated: check first access (SharedPreferences)
   ↓
3. If authenticated: check onboarding completed (Firestore)
   ↓
4. Navigate to correct screen
```

This order is critical and defined in regras-criticas.md.

## Components and Interfaces

### SplashController

**Responsibilities:**
- Execute critical verification order
- Handle navigation decisions
- Manage timeout and error states

**Key Methods:**
```dart
Future<void> _navigate()
Future<bool> _isFirstAccess()
Future<bool> _isOnboardingCompleted(String userId)
void _navigateToOnboarding()
void _navigateToAuth()
void _navigateToHome()
```

**Observable States:**
```dart
final isLoading = true.obs;
final errorMessage = ''.obs;
```

### AuthController

**Responsibilities:**
- Handle login authentication
- Manage password recovery flow
- Validate form inputs
- Handle Firebase errors

**Key Methods:**
```dart
Future<void> login(String email, String password)
Future<void> sendPasswordResetCode(String email)
Future<void> verifyCode(String code)
Future<void> resetPassword(String newPassword)
String? validateEmail(String? value)
String? validatePassword(String? value)
```

**Observable States:**
```dart
final isLoading = false.obs;
final errorMessage = ''.obs;
final otpCode = ''.obs;
final otpExpiration = Rx<DateTime?>(null);
final resendTimer = 0.obs;
```

### Views

**SigninView (StatefulWidget):**
- Email and password input fields
- Login button with loading state
- Navigation to forgot password
- Social login buttons (future)

**ForgotPasswordView (StatefulWidget):**
- Email input field
- Send code button
- Navigation to verify code

**VerifyCodeView (StatefulWidget):**
- 5-digit OTP input (AppPinput)
- Resend code with 60-second timer (AppResendCode)
- Verify button

**NewPasswordView (StatefulWidget):**
- New password input
- Confirm password input
- Reset button

## Data Models

### User Document (Firestore)

```dart
class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? username;
  final bool onboardingCompleted;
  final DateTime? lastActiveAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Firestore path: users/{userId}
}
```

### OTP Storage (Local - FlutterSecureStorage)

```dart
class OTPData {
  final String code;
  final DateTime expiresAt;
  final String email;
  
  // Stored temporarily for password recovery
  // Expires after 10 minutes
}
```

### SharedPreferences Keys

```dart
static const String keyIsFirstAccess = 'isFirstAccess';
// true = first time opening app
// false = user has seen onboarding or logged in before
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Navigation Order Invariant

*For any* app startup sequence, the verification order MUST be: (1) check authentication, (2) if not authenticated check first access, (3) if authenticated check onboarding completion, (4) navigate.

**Validates: Requirements 1.2, 1.3, 1.6**

### Property 2: Authentication State Consistency

*For any* successful login, if the user document exists in Firestore and onboardingCompleted is true, then lastActiveAt MUST be updated before navigation to /home.

**Validates: Requirements 2.8, 2.9**

### Property 3: Error Message Mapping

*For any* Firebase Auth error code, the system MUST return a Portuguese error message that does not contain technical terms.

**Validates: Requirements 8.1, 8.3**

### Property 4: Form Validation Completeness

*For any* form submission, all required fields MUST be validated before any Firebase operation is attempted.

**Validates: Requirements 4.1, 4.2**

### Property 5: OTP Expiration

*For any* OTP code generated, if more than 10 minutes have passed since generation, the code MUST be rejected as expired.

**Validates: Requirements 3.6, 3.13**

### Property 6: Navigation Stack Clearing

*For any* successful login or onboarding completion, the navigation stack MUST be completely cleared using Get.offAllNamed.

**Validates: Requirements 7.1, 7.2, 7.4**

### Property 7: Loading State Consistency

*For any* asynchronous operation, the loading indicator MUST be visible during execution and removed upon completion or error.

**Validates: Requirements 5.1, 5.3, 5.4**

### Property 8: Sensitive Data Protection

*For any* password or authentication token, the value MUST never appear in console logs or error messages.

**Validates: Requirements 9.1, 9.2**

### Property 9: Timeout Application

*For any* Firestore operation during splash, if the operation exceeds 5 seconds, the system MUST timeout and navigate to /auth.

**Validates: Requirements 1.11, 1.12**

### Property 10: Onboarding State Persistence

*For any* user who completes onboarding, the onboardingCompleted field MUST be set to true in Firestore before navigation to /home.

**Validates: Requirements 10.3, 10.4**

## Error Handling

### Firebase Auth Error Handler

```dart
String _handleFirebaseLoginError(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return 'Não encontramos uma conta com este e-mail.';
    case 'wrong-password':
      return 'Senha incorreta. Verifique e tente novamente.';
    case 'invalid-email':
      return 'Por favor, insira um e-mail válido.';
    case 'user-disabled':
      return 'Esta conta foi desativada. Entre em contato com o suporte.';
    case 'too-many-requests':
      return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
    case 'network-request-failed':
      return 'Verifique sua conexão com a internet.';
    case 'invalid-credential':
      return 'E-mail ou senha incorretos.';
    default:
      return 'Não foi possível fazer login. Tente novamente.';
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
    case 'unauthenticated':
      return 'Usuário não autenticado. Faça login novamente.';
    case 'not-found':
      return 'Recurso não encontrado.';
    default:
      return 'Erro ao buscar dados. Verifique sua conexão e tente novamente.';
  }
}
```

### Timeout Handling

```dart
Future<T> _withTimeout<T>(Future<T> operation, {Duration timeout = const Duration(seconds: 5)}) async {
  try {
    return await operation.timeout(timeout);
  } on TimeoutException {
    throw Exception('Operação excedeu o tempo limite');
  }
}
```

## Testing Strategy

### Unit Tests

Unit tests will verify specific examples and edge cases:

**AuthController Tests:**
- Email validation with valid/invalid formats
- Password validation with various lengths
- Error message mapping for each Firebase error code
- OTP generation and expiration logic
- Resend timer countdown

**SplashController Tests:**
- Navigation decision for each authentication state
- Timeout handling for Firestore operations
- First access detection logic
- Error recovery flows

**Form Validation Tests:**
- Empty field detection
- Email format validation
- Password length validation
- Error message display

### Property-Based Tests

Property tests will verify universal properties across all inputs using a property-based testing library (e.g., `faker` for data generation):

**Configuration:**
- Minimum 100 iterations per property test
- Each test tagged with: `Feature: authentication, Property {number}: {property_text}`

**Property Test Examples:**

```dart
// Property 3: Error Message Mapping
test('Feature: authentication, Property 3: Error Message Mapping', () {
  final authController = AuthController();
  final errorCodes = [
    'user-not-found',
    'wrong-password',
    'invalid-email',
    'user-disabled',
    'too-many-requests',
    'network-request-failed',
    'invalid-credential',
  ];
  
  for (final code in errorCodes) {
    final error = FirebaseAuthException(code: code);
    final message = authController.handleLoginError(error);
    
    // Property: message must be in Portuguese and not contain technical terms
    expect(message, isNot(contains(code)));
    expect(message, isNot(contains('Exception')));
    expect(message, isNot(contains('Error')));
  }
});

// Property 5: OTP Expiration
test('Feature: authentication, Property 5: OTP Expiration', () {
  for (int i = 0; i < 100; i++) {
    final now = DateTime.now();
    final minutesAgo = Random().nextInt(20); // 0-20 minutes ago
    final otpCreatedAt = now.subtract(Duration(minutes: minutesAgo));
    
    final isExpired = now.difference(otpCreatedAt).inMinutes > 10;
    final shouldBeRejected = minutesAgo > 10;
    
    expect(isExpired, equals(shouldBeRejected));
  }
});

// Property 7: Loading State Consistency
test('Feature: authentication, Property 7: Loading State Consistency', () async {
  final controller = AuthController();
  
  // Before operation
  expect(controller.isLoading.value, false);
  
  // Start operation
  final operation = controller.login('test@test.com', 'password');
  await Future.delayed(Duration(milliseconds: 10));
  
  // During operation
  expect(controller.isLoading.value, true);
  
  // After operation
  await operation;
  expect(controller.isLoading.value, false);
});
```

### Integration Tests

Integration tests will verify complete flows:

- Complete login flow (signin → Firestore fetch → navigation)
- Complete password recovery flow (forgot → verify → reset → signin)
- Splash navigation for each user state
- Error recovery and retry mechanisms

### Test Coverage Goals

- Unit tests: 80%+ code coverage
- Property tests: All 10 correctness properties
- Integration tests: All critical user flows
- Error handling: All Firebase error codes

## Implementation Notes

### Critical Rules

1. **NEVER invert the verification order** in splash screen
2. **ALWAYS use Get.offAllNamed** for post-login navigation
3. **ALWAYS use FieldValue.serverTimestamp()** for lastActiveAt
4. **NEVER log passwords or tokens** to console
5. **ALWAYS validate inputs** before Firebase operations
6. **ALWAYS use standardized error handlers** from firebase.md

### State Management

- Use GetX `.obs` for reactive state
- Keep controllers lean (no TextEditingController, no Streams)
- Views handle TextEditingController (StatefulWidget for forms)
- Validators in controller return `String?` (no side effects)

### Security

- Use FlutterSecureStorage for OTP codes
- Use SharedPreferences for isFirstAccess flag
- Clear sensitive data after use
- Validate all inputs before sending to server

### Performance

- Apply 5-second timeout to Firestore operations
- Show loading indicators for all async operations
- Cache first access check result
- Minimize Firestore reads during splash

### Localization

- All user-facing messages in Portuguese
- Error messages follow standardized patterns
- No technical terms in user messages
- Consistent terminology across the app
