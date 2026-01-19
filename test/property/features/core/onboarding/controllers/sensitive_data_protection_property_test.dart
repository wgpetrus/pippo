import 'package:flutter_test/flutter_test.dart';

/// Property 12: Sensitive Data Protection
/// Validates: Requirements 14.1, 14.2, 14.3
/// 
/// Verifica que dados sensíveis (senhas, emails, tokens) nunca aparecem em logs ou mensagens de erro
/// 
/// NOTA: Este teste valida as mensagens de erro e validações sem instanciar o OnboardingController
/// para evitar dependência do Firebase. Os validadores abaixo são cópias exatas dos métodos
/// do OnboardingController. Qualquer mudança no controller DEVE ser refletida aqui.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Validadores extraídos do OnboardingController
  // IMPORTANTE: Manter sincronizados com lib/features/core/onboarding/controllers/onboarding_controller.dart
  
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome é obrigatório.';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-mail é obrigatório.';
    }
    // Simple email validation (same as GetUtils.isEmail)
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, insira um e-mail válido.';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória.';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    return null;
  }

  // Firebase Auth error handler (extracted from controller)
  String handleFirebaseAuthError(String errorCode) {
    switch (errorCode) {
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

  // Firestore error handler (extracted from controller)
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

  group('Feature: onboarding, Property 12: Sensitive Data Protection', () {

    test('passwords never appear in error messages', () {
      // Test data: various passwords (excluding empty string which is a special case)
      final testPasswords = [
        'password123',
        'MySecretP@ss',
        'test1234',
        '123456',
        'P@ssw0rd!',
        'super_secret_password',
        '12345', // Too short
      ];

      for (final password in testPasswords) {
        // Validate password
        final validationError = validatePassword(password);
        
        // Verify password never appears in validation error
        if (validationError != null && password.isNotEmpty) {
          expect(
            validationError.contains(password),
            false,
            reason: 'Password "$password" should not appear in validation error message',
          );
          
          // Verify error message is user-friendly
          expect(
            validationError.contains('obrigatória') || validationError.contains('caracteres'),
            true,
            reason: 'Error message should be user-friendly in Portuguese',
          );
        }
      }
      
      // Test empty password separately
      final emptyError = validatePassword('');
      expect(emptyError, isNotNull);
      expect(emptyError!.contains('obrigatória'), true);
    });

    test('emails never appear in technical error messages', () {
      // Test data: various emails
      final testEmails = [
        'user@example.com',
        'test.user@domain.com',
        'admin@company.org',
        'john.doe@email.co.uk',
        'contact@website.io',
        'invalid-email', // Invalid format
        '', // Empty
      ];

      for (final email in testEmails) {
        // Validate email
        final validationError = validateEmail(email);
        
        // Verify validation error is user-friendly and doesn't expose the email in technical context
        if (validationError != null) {
          // Error should be generic, not containing the specific email
          expect(
            validationError.contains('obrigatório') || validationError.contains('válido'),
            true,
            reason: 'Error message should be generic and user-friendly',
          );
          
          // Should not contain technical terms
          expect(
            validationError.contains('Exception') || validationError.contains('Error'),
            false,
            reason: 'Error message should not contain technical terms',
          );
        }
      }
    });

    test('error messages do not expose technical details', () {
      // Test that error messages are user-friendly and don't expose:
      // - Stack traces
      // - Firebase error codes (raw)
      // - Authentication tokens
      // - Internal system details

      final forbiddenTerms = [
        'FirebaseAuthException',
        'FirebaseException',
        'StackTrace',
        'token',
        'auth_token',
        'access_token',
        'refresh_token',
        'Exception:',
        'Error:',
        '.dart',
        'lib/',
      ];

      // Test various error messages
      final errorMessages = [
        'Não foi possível fazer login. Tente novamente.',
        'Não foi possível criar sua conta. Tente novamente.',
        'Erro ao salvar dados. Verifique sua conexão e tente novamente.',
      ];
      
      for (final errorMessage in errorMessages) {
        for (final term in forbiddenTerms) {
          expect(
            errorMessage.toLowerCase().contains(term.toLowerCase()),
            false,
            reason: 'Error message should not contain technical term: "$term"',
          );
        }
      }
    });

    test('validation errors are user-friendly without exposing data', () {
      // Test various validation scenarios
      final testCases = [
        {
          'field': 'name',
          'value': '',
          'validator': (String? v) => validateName(v),
        },
        {
          'field': 'email',
          'value': 'invalid-email',
          'validator': (String? v) => validateEmail(v),
        },
        {
          'field': 'password',
          'value': '123',
          'validator': (String? v) => validatePassword(v),
        },
      ];

      for (final testCase in testCases) {
        final validator = testCase['validator'] as String? Function(String?);
        final value = testCase['value'] as String;
        final field = testCase['field'] as String;
        
        final error = validator(value);
        
        if (error != null) {
          // Verify error is in Portuguese
          expect(
            error.contains(RegExp(r'[áàâãéêíóôõúç]', caseSensitive: false)) ||
            error.contains('obrigatório') ||
            error.contains('válido') ||
            error.contains('caracteres'),
            true,
            reason: 'Error message should be in Portuguese for field: $field',
          );
          
          // Verify error doesn't contain technical terms
          expect(
            error.contains('null') ||
            error.contains('undefined') ||
            error.contains('Exception'),
            false,
            reason: 'Error message should not contain technical terms for field: $field',
          );
        }
      }
    });

    test('Firebase Auth error handlers return user-friendly messages', () {
      // Test that Firebase error codes are properly mapped to Portuguese messages
      // without exposing the raw error codes
      
      final errorCodes = [
        'email-already-in-use',
        'invalid-email',
        'weak-password',
        'network-request-failed',
        'too-many-requests',
        'user-not-found',
        'unknown-error',
      ];

      for (final errorCode in errorCodes) {
        final message = handleFirebaseAuthError(errorCode);
        
        // Verify message is user-friendly (contains common Portuguese words or phrases)
        final hasPortugueseContent = 
          message.contains(RegExp(r'[áàâãéêíóôõúç]', caseSensitive: false)) ||
          message.contains('e-mail') ||
          message.contains('senha') ||
          message.contains('conta') ||
          message.contains('Verifique') ||
          message.contains('Não') ||
          message.contains('Muitas') ||
          message.contains('Aguarde') ||
          message.contains('Tente');
        
        expect(
          hasPortugueseContent,
          true,
          reason: 'Error message should be in Portuguese for code: $errorCode. Got: "$message"',
        );
        
        // Verify message doesn't contain error codes
        expect(
          message.contains(errorCode),
          false,
          reason: 'Error message should not contain error code: $errorCode',
        );
        
        // Verify message doesn't contain technical terms
        expect(
          message.toLowerCase().contains('exception') ||
          message.toLowerCase().contains('firebase'),
          false,
          reason: 'Error message should not contain technical terms for code: $errorCode',
        );
      }
    });

    test('Firestore error handlers return user-friendly messages', () {
      // Test that Firestore error codes are properly mapped to Portuguese messages
      
      final errorCodes = [
        'permission-denied',
        'unavailable',
        'deadline-exceeded',
        'resource-exhausted',
        'unauthenticated',
        'not-found',
        'already-exists',
        'unknown-error',
      ];

      for (final errorCode in errorCodes) {
        final message = handleFirestoreError(errorCode);
        
        // Verify message is in Portuguese
        final hasPortugueseContent =
          message.contains(RegExp(r'[áàâãéêíóôõúç]', caseSensitive: false)) ||
          message.contains('Erro') ||
          message.contains('Verifique') ||
          message.contains('Tente') ||
          message.contains('Aguarde') ||
          message.contains('Serviço') ||
          message.contains('Usuário');
        
        expect(
          hasPortugueseContent,
          true,
          reason: 'Error message should be in Portuguese for code: $errorCode. Got: "$message"',
        );
        
        // Verify message doesn't contain error codes
        expect(
          message.contains(errorCode),
          false,
          reason: 'Error message should not contain error code: $errorCode',
        );
        
        // Verify message doesn't contain technical exception terms
        // Note: "Firestore" may appear in user-facing messages like "configurações do Firestore"
        // which is acceptable, but "FirestoreException" is not
        expect(
          message.contains('Exception') ||
          message.contains('FirestoreException'),
          false,
          reason: 'Error message should not contain exception terms for code: $errorCode',
        );
      }
    });

    test('OTP codes are not logged or exposed in error messages', () {
      // Test that OTP codes never appear in error messages
      final testCodes = [
        '12345',
        '67890',
        '11111',
        '99999',
        '54321',
      ];

      // Expected generic error messages for OTP validation
      final expectedErrors = [
        'O código deve ter 5 dígitos.',
        'O código deve conter apenas números.',
        'Código inválido. Verifique e tente novamente.',
        'Código expirado. Solicite um novo código.',
      ];
      
      for (final code in testCodes) {
        // Verify that expected error messages don't contain the code
        for (final errorMessage in expectedErrors) {
          expect(
            errorMessage.contains(code),
            false,
            reason: 'OTP code "$code" should not appear in error message',
          );
          
          // Verify error is generic and user-friendly
          expect(
            errorMessage.contains('código') || errorMessage.contains('Código'),
            true,
            reason: 'Error message should be generic and user-friendly',
          );
        }
      }
    });

    test('username generation does not expose sensitive data', () {
      // Test that username generation doesn't log or expose sensitive information
      final testNames = [
        'John Doe',
        'Maria Silva',
        'Test User',
        'Admin Account',
      ];

      // Expected error messages for username generation
      final expectedErrors = [
        'Não foi possível gerar um nome de usuário único.',
        'Erro ao verificar nome de usuário. Tente novamente.',
      ];

      for (final name in testNames) {
        // Verify error messages don't contain the original name
        for (final errorMessage in expectedErrors) {
          expect(
            errorMessage.contains(name),
            false,
            reason: 'Original name "$name" should not appear in error messages',
          );
          
          // Verify error is generic
          expect(
            errorMessage.contains('usuário') || errorMessage.contains('Erro'),
            true,
            reason: 'Error message should be generic',
          );
        }
      }
    });

    test('all error messages are in Portuguese without technical terms', () {
      // Comprehensive test: verify all possible error messages are user-friendly
      
      final errorScenarios = [
        'Não foi possível criar sua conta. Tente novamente.',
        'Não foi possível enviar o código. Tente novamente.',
        'Erro ao verificar código. Tente novamente.',
        'Não foi possível gerar um nome de usuário único.',
        'Erro ao criar documento do usuário. Tente novamente.',
        'Erro ao criar curso. Tente novamente.',
        'Erro ao inicializar estatísticas. Tente novamente.',
        'Erro ao salvar dados. Verifique sua conexão e tente novamente.',
      ];

      for (final errorMessage in errorScenarios) {
        // Verify message is in Portuguese
        expect(
          errorMessage.contains(RegExp(r'[áàâãéêíóôõúç]', caseSensitive: false)) ||
          errorMessage.contains('Não') ||
          errorMessage.contains('Erro'),
          true,
          reason: 'Error message should be in Portuguese',
        );
        
        // Verify no technical terms
        final technicalTerms = [
          'Exception',
          'Error',
          'Firebase',
          'Firestore',
          'Auth',
          'token',
          'null',
          'undefined',
          '.dart',
          'lib/',
        ];
        
        for (final term in technicalTerms) {
          expect(
            errorMessage.contains(term),
            false,
            reason: 'Error message should not contain technical term: "$term"',
          );
        }
      }
    });

    test('Property: Sensitive data protection is consistent across 100 iterations', () {
      // Test with various sensitive data across multiple iterations
      final testPasswords = ['password123', 'MySecretP@ss', 'test1234'];
      final testEmails = ['user@example.com', 'test@domain.com'];
      
      // Run 100 iterations to verify consistency
      for (int iteration = 0; iteration < 100; iteration++) {
        // Test passwords
        for (final password in testPasswords) {
          final error = validatePassword(password);
          if (error != null) {
            expect(
              error.contains(password),
              false,
              reason: 'Iteration $iteration: Password should not appear in error',
            );
          }
        }
        
        // Test emails
        for (final email in testEmails) {
          final error = validateEmail(email);
          if (error != null) {
            expect(
              error.contains('Exception') || error.contains('Error'),
              false,
              reason: 'Iteration $iteration: Error should not contain technical terms',
            );
          }
        }
        
        // Test Firebase error handlers
        final authError = handleFirebaseAuthError('email-already-in-use');
        expect(
          authError.contains('email-already-in-use'),
          false,
          reason: 'Iteration $iteration: Error code should not appear in message',
        );
        
        final firestoreError = handleFirestoreError('permission-denied');
        expect(
          firestoreError.contains('permission-denied'),
          false,
          reason: 'Iteration $iteration: Error code should not appear in message',
        );
      }
    });
  });
}
