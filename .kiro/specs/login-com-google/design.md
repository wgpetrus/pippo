# Design Document - Google Social Login

## Overview

This module adds Google Sign-In to the existing authentication system. It uses `google_sign_in` plugin with Firebase Auth. Facebook login will be a placeholder showing a "coming soon" message.

## Architecture

### Integration with Existing Module

```
features/core/auth/
├── controllers/
│   └── auth_controller.dart  ← Add social login methods
├── views/
│   └── signin_view.dart      ← Connect existing SocialButton
└── widgets/
    └── social_button.dart    ← Already exists
```

### Google Authentication Flow

```
1. User taps Google button → isLoading = true
2. GoogleSignIn.signIn() → Account picker
3. Get credentials → Firebase signInWithCredential()
4. Check Firestore for user document
5a. New user → Create document → /onboarding
5b. Existing (onboarding incomplete) → /onboarding  
5c. Existing (onboarding complete) → Update lastActiveAt → /home
```

## Components and Interfaces

### AuthController (Extension)

**New Methods:**
```dart
Future<void> signInWithGoogle()
void onFacebookTap()
String _handleGoogleSignInError(dynamic error)
```

**Existing States (reuse):**
```dart
final isLoading = false.obs;
final errorMessage = ''.obs;
```

### SigninView Update

Connect existing SocialButton widgets to controller:

```dart
SocialButton(
  icon: AppAssets.logoGoogle,
  label: 'Continue with Google',
  onPressed: controller.isLoading.value ? null : controller.signInWithGoogle,
)

SocialButton(
  icon: AppAssets.logoFacebook,
  label: 'Continue with Facebook',
  onPressed: controller.isLoading.value ? null : controller.onFacebookTap,
)
```

## Data Models

### New User Document (Google)

```dart
{
  'id': firebaseUser.uid,
  'email': firebaseUser.email,
  'displayName': firebaseUser.displayName,
  'photoURL': firebaseUser.photoURL,
  'authProvider': 'google',
  'onboardingCompleted': false,
  'createdAt': FieldValue.serverTimestamp(),
  'updatedAt': FieldValue.serverTimestamp(),
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system.*

### Property 1: New User Document Creation

*For any* successful Google authentication where user document does not exist, the system MUST create a document with onboardingCompleted = false.

**Validates: Requirements 1.5, 1.6, 1.7**

### Property 2: Navigation Consistency

*For any* successful Google login, navigation MUST follow same logic as email login: onboardingCompleted false → /onboarding, true → /home with Get.offAllNamed.

**Validates: Requirements 1.9, 1.10, 1.11, 5.1, 5.4**

### Property 3: Loading State Consistency

*For any* Google Sign-In operation, isLoading MUST be true during operation and false after completion or error.

**Validates: Requirements 1.12, 4.1, 4.4, 4.5**

### Property 4: Error Message Security

*For any* error during Google Sign-In, the message MUST be in Portuguese and MUST NOT contain technical terms.

**Validates: Requirements 2.9, 5.6**

## Error Handling

### Google Sign-In Error Handler

```dart
String _handleGoogleSignInError(dynamic error) {
  if (error is PlatformException && error.code == 'sign_in_canceled') {
    return '';
  }
  if (error is PlatformException && error.code == 'network_error') {
    return 'Verifique sua conexão com a internet.';
  }
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'account-exists-with-different-credential':
        return 'Este e-mail já está vinculado a outra conta.';
      case 'user-disabled':
        return 'Esta conta foi desativada. Entre em contato com o suporte.';
      default:
        return 'Não foi possível fazer login com Google. Tente novamente.';
    }
  }
  return 'Ocorreu um erro inesperado. Tente novamente.';
}
```

### Facebook Placeholder

```dart
void onFacebookTap() {
  Get.snackbar(
    'Em breve!',
    'Login com Facebook estará disponível em breve!',
    snackPosition: SnackPosition.BOTTOM,
  );
}
```

## Testing Strategy

### Unit Tests
- Error message mapping for each error code
- Cancel returns empty string (no error shown)
- Document creation with correct fields

### Property Tests
- Property 1: Document creation for new users
- Property 2: Navigation based on onboarding state
- Property 3: Loading state during operation
- Property 4: Error messages without technical terms

## Implementation Notes

### Dependencies

```yaml
dependencies:
  google_sign_in: ^6.2.1
```

### Firebase Setup
1. Enable Google Sign-In in Firebase Console
2. Add SHA-1/SHA-256 fingerprints (Android)
3. Download updated google-services.json

### Rules
- NEVER log Google tokens
- ALWAYS use Get.offAllNamed for post-login navigation
- ALWAYS show loading during entire operation
- Follow same patterns as email login

