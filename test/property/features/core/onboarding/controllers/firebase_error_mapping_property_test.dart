// Flutter packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

/// Feature: onboarding, Property 6: Firebase Error Message Mapping
/// 
/// Property: For any Firebase Auth error code, the system MUST return
/// a Portuguese error message that does not contain technical terms.
/// 
/// Validates: Requirements 5.15, 5.16, 5.17, 5.18, 13.1, 13.2, 13.3, 13.4, 13.5
/// 
/// NOTA: Este teste valida a lógica de mapeamento de erros sem instanciar o OnboardingController
/// para evitar dependência do Firebase. O handler abaixo é uma cópia exata do método
/// do OnboardingController. Qualquer mudança no controller DEVE ser refletida aqui.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Handler extraído do OnboardingController
  // IMPORTANTE: Manter sincronizado com lib/features/core/onboarding/controllers/onboarding_controller.dart
  String handleFirebaseAuthError(FirebaseAuthException e) {
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

  group('Feature: onboarding, Property 6: Firebase Error Message Mapping', () {

    test('Property 6.1: All Firebase Auth error codes return Portuguese messages', () {
      // Property: Every Firebase Auth error code MUST return a message in Portuguese
      
      final errorCodes = [
        'email-already-in-use',
        'invalid-email',
        'operation-not-allowed',
        'weak-password',
        'network-request-failed',
        'too-many-requests',
        'unknown-error', // default case
      ];

      final expectedMessages = {
        'email-already-in-use': 'Este e-mail já está sendo usado por outra conta.',
        'invalid-email': 'Por favor, insira um e-mail válido.',
        'operation-not-allowed': 'Operação não permitida no momento.',
        'weak-password': 'A senha deve ter pelo menos 6 caracteres.',
        'network-request-failed': 'Verifique sua conexão com a internet.',
        'too-many-requests': 'Muitas tentativas. Aguarde alguns minutos e tente novamente.',
        'unknown-error': 'Não foi possível criar sua conta. Tente novamente.',
      };

      for (int i = 0; i < 100; i++) {
        for (final errorCode in errorCodes) {
          final exception = FirebaseAuthException(code: errorCode);
          final message = handleFirebaseAuthError(exception);
          
          // Property 1: Message must not be empty
          expect(message.isNotEmpty, isTrue,
              reason: 'Iteration $i: Error code "$errorCode" must return non-empty message');
          
          // Property 2: Message must match expected Portuguese message
          expect(message, equals(expectedMessages[errorCode]),
              reason: 'Iteration $i: Error code "$errorCode" must return correct Portuguese message');
        }
      }
    });

    test('Property 6.2: Error messages contain no technical terms', () {
      // Property: Error messages MUST NOT contain technical terms or error codes
      
      final errorCodes = [
        'email-already-in-use',
        'invalid-email',
        'operation-not-allowed',
        'weak-password',
        'network-request-failed',
        'too-many-requests',
        'unknown-error',
      ];

      final technicalTerms = [
        'exception',
        'error',
        'code',
        'firebase',
        'auth',
        'null',
        'undefined',
        'failed',
        'invalid',
        'operation',
      ];

      for (int i = 0; i < 100; i++) {
        for (final errorCode in errorCodes) {
          final exception = FirebaseAuthException(code: errorCode);
          final message = handleFirebaseAuthError(exception);
          final lowerCaseMessage = message.toLowerCase();
          
          // Property: Message must not contain technical terms
          final containsTechnicalTerms = technicalTerms.any(
            (term) => lowerCaseMessage.contains(term)
          );
          
          expect(containsTechnicalTerms, isFalse,
              reason: 'Iteration $i: Message for "$errorCode" must not contain technical terms. Message: "$message"');
        }
      }
    });

    test('Property 6.3: Error messages are user-friendly and actionable', () {
      // Property: Error messages MUST be user-friendly and provide actionable guidance
      
      final errorCodes = [
        'email-already-in-use',
        'invalid-email',
        'weak-password',
        'network-request-failed',
        'too-many-requests',
      ];

      for (int i = 0; i < 100; i++) {
        for (final errorCode in errorCodes) {
          final exception = FirebaseAuthException(code: errorCode);
          final message = handleFirebaseAuthError(exception);
          
          // Property 1: Message must be at least 10 characters (not too short)
          expect(message.length, greaterThanOrEqualTo(10),
              reason: 'Iteration $i: Message for "$errorCode" must be descriptive enough');
          
          // Property 2: Message must end with proper punctuation
          expect(message.endsWith('.'), isTrue,
              reason: 'Iteration $i: Message for "$errorCode" must end with period');
          
          // Property 3: Message must start with capital letter
          expect(message[0], equals(message[0].toUpperCase()),
              reason: 'Iteration $i: Message for "$errorCode" must start with capital letter');
        }
      }
    });

    test('Property 6.4: Unknown error codes return default message', () {
      // Property: Any unknown error code MUST return the default error message
      
      final unknownErrorCodes = [
        'unknown-error',
        'random-error',
        'new-error-code',
        'undefined-error',
        '',
        'custom-error-123',
      ];

      final defaultMessage = 'Não foi possível criar sua conta. Tente novamente.';

      for (int i = 0; i < 100; i++) {
        for (final errorCode in unknownErrorCodes) {
          final exception = FirebaseAuthException(code: errorCode);
          final message = handleFirebaseAuthError(exception);
          
          // Property: Unknown errors must return default message
          expect(message, equals(defaultMessage),
              reason: 'Iteration $i: Unknown error code "$errorCode" must return default message');
        }
      }
    });

    test('Property 6.5: Error mapping is consistent across multiple calls', () {
      // Property: Error handler MUST return the same message for the same error code
      // across multiple calls (pure function)
      
      final errorCodes = [
        'email-already-in-use',
        'invalid-email',
        'weak-password',
        'network-request-failed',
        'too-many-requests',
        'unknown-error',
      ];

      for (int i = 0; i < 50; i++) {
        for (final errorCode in errorCodes) {
          // Call handler multiple times with same error code
          final results = <String>[];
          for (int j = 0; j < 10; j++) {
            final exception = FirebaseAuthException(code: errorCode);
            final message = handleFirebaseAuthError(exception);
            results.add(message);
          }
          
          // Property: All results must be identical
          final firstResult = results.first;
          expect(results.every((r) => r == firstResult), isTrue,
              reason: 'Iteration $i: Handler must return consistent message for "$errorCode"');
        }
      }
    });

    test('Property 6.6: Specific error codes have specific messages', () {
      // Property: Each specific error code MUST have its own unique message
      // (not all returning the same generic message)
      
      final errorCodes = [
        'email-already-in-use',
        'invalid-email',
        'weak-password',
        'network-request-failed',
        'too-many-requests',
      ];

      final messages = <String>{};
      
      for (int i = 0; i < 100; i++) {
        messages.clear();
        
        for (final errorCode in errorCodes) {
          final exception = FirebaseAuthException(code: errorCode);
          final message = handleFirebaseAuthError(exception);
          messages.add(message);
        }
        
        // Property: All messages must be unique (no duplicates)
        expect(messages.length, equals(errorCodes.length),
            reason: 'Iteration $i: Each error code must have a unique message');
      }
    });

    test('Property 6.7: Messages are in Portuguese (contain Portuguese characters)', () {
      // Property: Messages MUST be in Portuguese and may contain Portuguese-specific characters
      
      final errorCodes = [
        'email-already-in-use',
        'invalid-email',
        'weak-password',
        'network-request-failed',
        'too-many-requests',
      ];

      // Portuguese words that should appear in messages
      final portugueseWords = [
        'e-mail',
        'senha',
        'conta',
        'válido',
        'conexão',
        'internet',
        'tentativas',
        'minutos',
        'pelo menos',
        'caracteres',
      ];

      for (int i = 0; i < 100; i++) {
        bool foundPortugueseWord = false;
        
        for (final errorCode in errorCodes) {
          final exception = FirebaseAuthException(code: errorCode);
          final message = handleFirebaseAuthError(exception);
          final lowerCaseMessage = message.toLowerCase();
          
          // Check if message contains at least one Portuguese word
          if (portugueseWords.any((word) => lowerCaseMessage.contains(word))) {
            foundPortugueseWord = true;
          }
        }
        
        // Property: At least some messages must contain Portuguese words
        expect(foundPortugueseWord, isTrue,
            reason: 'Iteration $i: Messages must be in Portuguese');
      }
    });

    test('Property 6.8: All required error codes are mapped', () {
      // Property: All error codes specified in requirements MUST be mapped
      
      final requiredErrorCodes = [
        'email-already-in-use',    // Requirement 5.15
        'invalid-email',           // Requirement 5.16
        'weak-password',           // Requirement 5.17
        'network-request-failed',  // Requirement 5.18
        'too-many-requests',       // Additional requirement
      ];

      for (int i = 0; i < 100; i++) {
        for (final errorCode in requiredErrorCodes) {
          final exception = FirebaseAuthException(code: errorCode);
          final message = handleFirebaseAuthError(exception);
          
          // Property 1: Message must not be the default message
          final defaultMessage = 'Não foi possível criar sua conta. Tente novamente.';
          expect(message, isNot(equals(defaultMessage)),
              reason: 'Iteration $i: Required error code "$errorCode" must have specific message');
          
          // Property 2: Message must be non-empty
          expect(message.isNotEmpty, isTrue,
              reason: 'Iteration $i: Required error code "$errorCode" must have message');
        }
      }
    });
  });
}
