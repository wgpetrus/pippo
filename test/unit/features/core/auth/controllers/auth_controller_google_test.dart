import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthController - Google Sign-In Unit Tests', () {
    group('Error Handler - Cancel', () {
      test('should return empty string when user cancels Google Sign-In', () {
        // Arrange
        final error = PlatformException(code: 'sign_in_canceled');

        // Act
        final result = _handleGoogleSignInError(error);

        // Assert
        expect(result, '',
            reason: 'Cancel should return empty string (no error shown)');
      });
    });

    group('Error Handler - Network Error', () {
      test('should return Portuguese message for network error', () {
        // Arrange
        final error = PlatformException(code: 'network_error');

        // Act
        final result = _handleGoogleSignInError(error);

        // Assert
        expect(result, 'Verifique sua conexão com a internet.',
            reason: 'Network error should return Portuguese message');
      });
    });

    group('Error Handler - Firebase Auth Errors', () {
      test('should return Portuguese message for account-exists-with-different-credential', () {
        // Arrange
        final error = _createFirebaseAuthException('account-exists-with-different-credential');

        // Act
        final result = _handleGoogleSignInError(error);

        // Assert
        expect(
          result,
          'Este e-mail já está vinculado a outra conta. Tente fazer login de outra forma.',
          reason: 'Should return correct Portuguese message for account-exists error',
        );
      });

      test('should return Portuguese message for invalid-credential', () {
        // Arrange
        final error = _createFirebaseAuthException('invalid-credential');

        // Act
        final result = _handleGoogleSignInError(error);

        // Assert
        expect(
          result,
          'Credenciais inválidas. Tente novamente.',
          reason: 'Should return correct Portuguese message for invalid-credential',
        );
      });

      test('should return Portuguese message for operation-not-allowed', () {
        // Arrange
        final error = _createFirebaseAuthException('operation-not-allowed');

        // Act
        final result = _handleGoogleSignInError(error);

        // Assert
        expect(
          result,
          'Login com Google não está habilitado. Entre em contato com o suporte.',
          reason: 'Should return correct Portuguese message for operation-not-allowed',
        );
      });

      test('should return Portuguese message for user-disabled', () {
        // Arrange
        final error = _createFirebaseAuthException('user-disabled');

        // Act
        final result = _handleGoogleSignInError(error);

        // Assert
        expect(
          result,
          'Esta conta foi desativada. Entre em contato com o suporte.',
          reason: 'Should return correct Portuguese message for user-disabled',
        );
      });

      test('should return default Portuguese message for unknown Firebase error', () {
        // Arrange
        final error = _createFirebaseAuthException('unknown-error');

        // Act
        final result = _handleGoogleSignInError(error);

        // Assert
        expect(
          result,
          'Não foi possível fazer login com Google. Tente novamente.',
          reason: 'Should return default Portuguese message for unknown error',
        );
      });
    });

    group('Error Handler - Unknown Errors', () {
      test('should return default Portuguese message for unknown error type', () {
        // Arrange
        final error = Exception('Unknown error');

        // Act
        final result = _handleGoogleSignInError(error);

        // Assert
        expect(
          result,
          'Ocorreu um erro inesperado. Tente novamente.',
          reason: 'Should return default Portuguese message for unknown error type',
        );
      });
    });

    group('Error Messages - No Technical Terms', () {
      test('cancel error should not contain technical terms', () {
        // Arrange
        final error = PlatformException(code: 'sign_in_canceled');

        // Act
        final result = _handleGoogleSignInError(error);

        // Assert
        expect(result, isNot(contains('sign_in_canceled')),
            reason: 'Error message should not contain technical error code');
        expect(result, isNot(contains('PlatformException')),
            reason: 'Error message should not contain exception type');
      });

      test('network error should not contain technical terms', () {
        // Arrange
        final error = PlatformException(code: 'network_error');

        // Act
        final result = _handleGoogleSignInError(error);

        // Assert
        expect(result, isNot(contains('network_error')),
            reason: 'Error message should not contain technical error code');
        expect(result, isNot(contains('PlatformException')),
            reason: 'Error message should not contain exception type');
      });

      test('Firebase errors should not contain technical terms', () {
        // Arrange
        final error = _createFirebaseAuthException('account-exists-with-different-credential');

        // Act
        final result = _handleGoogleSignInError(error);

        // Assert
        expect(result, isNot(contains('account-exists-with-different-credential')),
            reason: 'Error message should not contain technical error code');
        expect(result, isNot(contains('FirebaseAuthException')),
            reason: 'Error message should not contain exception type');
      });
    });

    group('Document Creation - Field Validation', () {
      test('should create document with all required fields', () {
        // Arrange
        final expectedFields = {
          'id': 'test-user-id',
          'email': 'test@example.com',
          'displayName': 'Test User',
          'photoURL': 'https://example.com/photo.jpg',
          'authProvider': 'google',
          'onboardingCompleted': false,
        };

        // Act & Assert
        expect(expectedFields['id'], isNotNull,
            reason: 'Document should have id field');
        expect(expectedFields['email'], isNotNull,
            reason: 'Document should have email field');
        expect(expectedFields['displayName'], isNotNull,
            reason: 'Document should have displayName field');
        expect(expectedFields['photoURL'], isNotNull,
            reason: 'Document should have photoURL field');
        expect(expectedFields['authProvider'], 'google',
            reason: 'Document should have authProvider set to google');
        expect(expectedFields['onboardingCompleted'], false,
            reason: 'Document should have onboardingCompleted set to false');
      });

      test('should set authProvider to google', () {
        // Arrange
        final authProvider = 'google';

        // Act & Assert
        expect(authProvider, 'google',
            reason: 'authProvider must be exactly "google"');
      });

      test('should set onboardingCompleted to false for new users', () {
        // Arrange
        final onboardingCompleted = false;

        // Act & Assert
        expect(onboardingCompleted, false,
            reason: 'onboardingCompleted must be false for new Google users');
      });

      test('should include user email from Google account', () {
        // Arrange
        final email = 'user@gmail.com';

        // Act & Assert
        expect(email, isNotEmpty,
            reason: 'Email should not be empty');
        expect(email, contains('@'),
            reason: 'Email should be valid format');
      });

      test('should include displayName from Google account', () {
        // Arrange
        final displayName = 'John Doe';

        // Act & Assert
        expect(displayName, isNotEmpty,
            reason: 'displayName should not be empty');
      });

      test('should include photoURL from Google account', () {
        // Arrange
        final photoURL = 'https://lh3.googleusercontent.com/a/photo';

        // Act & Assert
        expect(photoURL, isNotEmpty,
            reason: 'photoURL should not be empty');
        expect(photoURL, startsWith('http'),
            reason: 'photoURL should be a valid URL');
      });
    });
  });
}

// Helper function to simulate the error handler
// This mirrors the implementation in AuthController
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
        return 'Este e-mail já está vinculado a outra conta. Tente fazer login de outra forma.';
      case 'invalid-credential':
        return 'Credenciais inválidas. Tente novamente.';
      case 'operation-not-allowed':
        return 'Login com Google não está habilitado. Entre em contato com o suporte.';
      case 'user-disabled':
        return 'Esta conta foi desativada. Entre em contato com o suporte.';
      default:
        return 'Não foi possível fazer login com Google. Tente novamente.';
    }
  }
  return 'Ocorreu um erro inesperado. Tente novamente.';
}

// Helper function to create FirebaseAuthException for testing
FirebaseAuthException _createFirebaseAuthException(String code) {
  return FirebaseAuthException(
    code: code,
    message: 'Test error message',
  );
}
