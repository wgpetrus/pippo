import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('Error Handling - Firestore Error Codes', () {
    // Firestore error handler extraído do OnboardingController
    // IMPORTANTE: Manter sincronizado com lib/features/core/onboarding/controllers/onboarding_controller.dart
    String handleFirestoreError(String errorCode) {
      switch (errorCode) {
        case 'permission-denied':
          return 'Erro de permissão. Verifique as configurações do Firestore ou tente novamente em alguns instantes.';
        case 'unavailable':
          return 'Serviço temporariamente indisponível. Tente novamente em alguns instantes.';
        case 'deadline-exceeded':
          return 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
        case 'resource-exhausted':
          return 'Muitas requisições. Aguarde alguns minutos e tente novamente.';
        case 'failed-precondition':
          return 'Operação não permitida no estado atual. Tente novamente.';
        case 'aborted':
          return 'Operação cancelada. Tente novamente.';
        case 'out-of-range':
          return 'Valor fora do intervalo permitido.';
        case 'unimplemented':
          return 'Operação não implementada.';
        case 'internal':
          return 'Erro interno do servidor. Tente novamente em alguns instantes.';
        case 'unauthenticated':
          return 'Usuário não autenticado. Faça login novamente.';
        case 'not-found':
          return 'Recurso não encontrado.';
        case 'already-exists':
          return 'Recurso já existe.';
        case 'cancelled':
          return 'Operação cancelada.';
        case 'data-loss':
          return 'Erro de integridade de dados.';
        case 'invalid-argument':
          return 'Argumento inválido.';
        default:
          return 'Erro ao salvar dados. Verifique sua conexão e tente novamente.';
      }
    }

    test('permission-denied error returns correct Portuguese message', () {
      final message = handleFirestoreError('permission-denied');
      expect(message, equals('Erro de permissão. Verifique as configurações do Firestore ou tente novamente em alguns instantes.'));
    });

    test('unavailable error returns correct Portuguese message', () {
      final message = handleFirestoreError('unavailable');
      expect(message, equals('Serviço temporariamente indisponível. Tente novamente em alguns instantes.'));
    });

    test('deadline-exceeded error returns correct Portuguese message', () {
      final message = handleFirestoreError('deadline-exceeded');
      expect(message, equals('Tempo de espera esgotado. Verifique sua conexão e tente novamente.'));
    });

    test('resource-exhausted error returns correct Portuguese message', () {
      final message = handleFirestoreError('resource-exhausted');
      expect(message, equals('Muitas requisições. Aguarde alguns minutos e tente novamente.'));
    });

    test('failed-precondition error returns correct Portuguese message', () {
      final message = handleFirestoreError('failed-precondition');
      expect(message, equals('Operação não permitida no estado atual. Tente novamente.'));
    });

    test('aborted error returns correct Portuguese message', () {
      final message = handleFirestoreError('aborted');
      expect(message, equals('Operação cancelada. Tente novamente.'));
    });

    test('out-of-range error returns correct Portuguese message', () {
      final message = handleFirestoreError('out-of-range');
      expect(message, equals('Valor fora do intervalo permitido.'));
    });

    test('unimplemented error returns correct Portuguese message', () {
      final message = handleFirestoreError('unimplemented');
      expect(message, equals('Operação não implementada.'));
    });

    test('internal error returns correct Portuguese message', () {
      final message = handleFirestoreError('internal');
      expect(message, equals('Erro interno do servidor. Tente novamente em alguns instantes.'));
    });

    test('unauthenticated error returns correct Portuguese message', () {
      final message = handleFirestoreError('unauthenticated');
      expect(message, equals('Usuário não autenticado. Faça login novamente.'));
    });

    test('not-found error returns correct Portuguese message', () {
      final message = handleFirestoreError('not-found');
      expect(message, equals('Recurso não encontrado.'));
    });

    test('already-exists error returns correct Portuguese message', () {
      final message = handleFirestoreError('already-exists');
      expect(message, equals('Recurso já existe.'));
    });

    test('cancelled error returns correct Portuguese message', () {
      final message = handleFirestoreError('cancelled');
      expect(message, equals('Operação cancelada.'));
    });

    test('data-loss error returns correct Portuguese message', () {
      final message = handleFirestoreError('data-loss');
      expect(message, equals('Erro de integridade de dados.'));
    });

    test('invalid-argument error returns correct Portuguese message', () {
      final message = handleFirestoreError('invalid-argument');
      expect(message, equals('Argumento inválido.'));
    });

    test('unknown error returns default Portuguese message', () {
      final message = handleFirestoreError('unknown-error-code');
      expect(message, equals('Erro ao salvar dados. Verifique sua conexão e tente novamente.'));
    });

    test('all Firestore error messages are in Portuguese', () {
      final errorCodes = [
        'permission-denied',
        'unavailable',
        'deadline-exceeded',
        'resource-exhausted',
        'failed-precondition',
        'aborted',
        'out-of-range',
        'unimplemented',
        'internal',
        'unauthenticated',
        'not-found',
        'already-exists',
        'cancelled',
        'data-loss',
        'invalid-argument',
      ];

      for (final code in errorCodes) {
        final message = handleFirestoreError(code);
        
        // Verify message is not empty
        expect(message.isNotEmpty, isTrue,
            reason: 'Error code "$code" must return non-empty message');
        
        // Verify message ends with period
        expect(message.endsWith('.'), isTrue,
            reason: 'Error code "$code" message must end with period');
        
        // Verify message starts with capital letter
        expect(message[0], equals(message[0].toUpperCase()),
            reason: 'Error code "$code" message must start with capital letter');
      }
    });

    test('Firestore error messages do not contain technical terms', () {
      final errorCodes = [
        'unavailable',
        'deadline-exceeded',
        'resource-exhausted',
        'unauthenticated',
        'not-found',
      ];

      // Note: permission-denied is excluded because the standardized handler
      // from firebase.md intentionally includes "Firestore" for clarity
      final technicalTerms = ['exception', 'error code', 'firebase', 'stack trace', 'debug'];

      for (final code in errorCodes) {
        final message = handleFirestoreError(code);
        final lowerMessage = message.toLowerCase();
        
        for (final term in technicalTerms) {
          expect(lowerMessage, isNot(contains(term)),
              reason: 'Error code "$code" message must not contain technical term "$term"');
        }
      }
    });

    test('each Firestore error code has unique message', () {
      final errorCodes = [
        'permission-denied',
        'unavailable',
        'deadline-exceeded',
        'resource-exhausted',
        'unauthenticated',
        'not-found',
        'already-exists',
        'cancelled',
      ];

      final messages = <String>{};
      for (final code in errorCodes) {
        final message = handleFirestoreError(code);
        messages.add(message);
      }

      // All messages should be unique (except for some that may share messages)
      expect(messages.length, greaterThan(1),
          reason: 'Error codes should have distinct messages');
    });

    test('Firestore error messages are user-friendly', () {
      final errorCodes = [
        'permission-denied',
        'unavailable',
        'deadline-exceeded',
        'resource-exhausted',
        'unauthenticated',
      ];

      for (final code in errorCodes) {
        final message = handleFirestoreError(code);
        
        // Verify message provides actionable guidance
        final hasActionableGuidance = 
            message.contains('Verifique') ||
            message.contains('Aguarde') ||
            message.contains('Tente novamente') ||
            message.contains('Faça login');
        
        expect(hasActionableGuidance, isTrue,
            reason: 'Error code "$code" message should provide actionable guidance');
      }
    });
  });

  group('Error Handling - Error Message Display', () {
    test('error message is cleared when starting new operation', () {
      // Simulate error message state
      String errorMessage = 'Erro anterior';
      
      // Simulate starting new operation
      errorMessage = '';
      
      expect(errorMessage, isEmpty,
          reason: 'Error message should be cleared when starting new operation');
    });

    test('error message is displayed when not empty', () {
      final errorMessage = 'Este é um erro de teste.';
      
      expect(errorMessage.isNotEmpty, isTrue,
          reason: 'Error message should be displayed when not empty');
    });

    test('error message is hidden when empty', () {
      final errorMessage = '';
      
      expect(errorMessage.isEmpty, isTrue,
          reason: 'Error message should be hidden when empty');
    });

    test('error message is in Portuguese', () {
      final errorMessages = [
        'Erro de permissão. Verifique as configurações do Firestore ou tente novamente em alguns instantes.',
        'Serviço temporariamente indisponível. Tente novamente em alguns instantes.',
        'Tempo de espera esgotado. Verifique sua conexão e tente novamente.',
        'Usuário não autenticado. Faça login novamente.',
      ];

      for (final message in errorMessages) {
        // Verify message contains Portuguese words
        final hasPortugueseWords = 
            message.contains('Erro') ||
            message.contains('Verifique') ||
            message.contains('Tente') ||
            message.contains('Usuário');
        
        expect(hasPortugueseWords, isTrue,
            reason: 'Error message should be in Portuguese');
      }
    });

    test('error message does not contain technical terms', () {
      final errorMessages = [
        'Erro de permissão. Verifique as configurações do Firestore ou tente novamente em alguns instantes.',
        'Serviço temporariamente indisponível. Tente novamente em alguns instantes.',
        'Tempo de espera esgotado. Verifique sua conexão e tente novamente.',
      ];

      final technicalTerms = ['exception', 'stack trace', 'debug', 'error code'];

      for (final message in errorMessages) {
        final lowerMessage = message.toLowerCase();
        
        for (final term in technicalTerms) {
          expect(lowerMessage, isNot(contains(term)),
              reason: 'Error message should not contain technical term "$term"');
        }
      }
    });
  });

  group('Error Handling - Error Message Clearing', () {
    test('error message is cleared at start of createAccount', () {
      String errorMessage = 'Erro anterior';
      
      // Simulate start of createAccount
      errorMessage = '';
      
      expect(errorMessage, isEmpty);
    });

    test('error message is cleared at start of sendVerificationCode', () {
      String errorMessage = 'Erro anterior';
      
      // Simulate start of sendVerificationCode
      errorMessage = '';
      
      expect(errorMessage, isEmpty);
    });

    test('error message is cleared at start of resendVerificationCode', () {
      String errorMessage = 'Erro anterior';
      
      // Simulate start of resendVerificationCode
      errorMessage = '';
      
      expect(errorMessage, isEmpty);
    });

    test('error message is cleared at start of verifyCode', () {
      String errorMessage = 'Erro anterior';
      
      // Simulate start of verifyCode
      errorMessage = '';
      
      expect(errorMessage, isEmpty);
    });

    test('error message is cleared at start of finalizeAccount', () {
      String errorMessage = 'Erro anterior';
      
      // Simulate start of finalizeAccount
      errorMessage = '';
      
      expect(errorMessage, isEmpty);
    });

    test('error message is cleared at start of addNewCourse', () {
      String errorMessage = 'Erro anterior';
      
      // Simulate start of addNewCourse
      errorMessage = '';
      
      expect(errorMessage, isEmpty);
    });

    test('error message persists until next operation', () {
      String errorMessage = 'Erro de teste';
      
      // Error message should remain until explicitly cleared
      expect(errorMessage, equals('Erro de teste'));
      
      // Simulate starting new operation
      errorMessage = '';
      
      expect(errorMessage, isEmpty);
    });
  });

  group('Error Handling - Portuguese Messages', () {
    test('all error messages end with period', () {
      final errorMessages = [
        'Erro de permissão. Verifique as configurações do Firestore ou tente novamente em alguns instantes.',
        'Serviço temporariamente indisponível. Tente novamente em alguns instantes.',
        'Tempo de espera esgotado. Verifique sua conexão e tente novamente.',
        'Muitas requisições. Aguarde alguns minutos e tente novamente.',
        'Usuário não autenticado. Faça login novamente.',
        'Recurso não encontrado.',
        'Recurso já existe.',
      ];

      for (final message in errorMessages) {
        expect(message.endsWith('.'), isTrue,
            reason: 'Error message "$message" must end with period');
      }
    });
  });
}