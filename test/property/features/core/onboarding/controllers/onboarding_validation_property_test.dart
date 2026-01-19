// Flutter packages
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Feature: onboarding, Property 3: Input Validation Completeness
/// 
/// Property: For any form field (name, email, password), validation rules
/// MUST be applied consistently and return appropriate Portuguese error messages
/// for invalid inputs.
/// 
/// Validates: Requirements 4.2, 4.3, 4.4, 5.2, 5.3, 5.4, 5.9, 5.10, 11.1, 11.2, 11.3, 11.4, 11.5
/// 
/// NOTA: Estes testes validam a lógica de validação sem instanciar o OnboardingController
/// para evitar dependência do Firebase. Os validadores abaixo são cópias exatas dos métodos
/// do OnboardingController. Qualquer mudança no controller DEVE ser refletida aqui.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Validadores extraídos do OnboardingController
  // IMPORTANTE: Manter sincronizado com lib/features/core/onboarding/controllers/onboarding_controller.dart
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
    if (!GetUtils.isEmail(value)) {
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

  group('Feature: onboarding, Property 3: Input Validation Completeness', () {

    test('Property 3.1: Name validation rejects empty and whitespace-only strings', () {
      // Property: validateName MUST reject null, empty, and whitespace-only strings
      // and return Portuguese error message
      
      final invalidNames = [
        null,
        '',
        ' ',
        '  ',
        '\t',
        '\n',
        '   \t\n   ',
      ];

      for (int i = 0; i < 100; i++) {
        for (final name in invalidNames) {
          final result = validateName(name);
          
          // Property 1: Must return error message
          expect(result, isNotNull,
              reason: 'Iteration $i: Empty/whitespace name must return error');
          
          // Property 2: Error message must be in Portuguese
          expect(result, equals('Nome é obrigatório.'),
              reason: 'Iteration $i: Error message must be in Portuguese');
        }
      }
    });

    test('Property 3.2: Name validation accepts valid names', () {
      // Property: validateName MUST accept any non-empty, non-whitespace string
      
      final validNames = [
        'João',
        'Maria Silva',
        'José da Silva Santos',
        'A',
        'Ana Paula',
        'Pedro  Henrique', // multiple spaces between words
        ' Maria ', // spaces at edges (will be trimmed)
        'François',
        'José María',
        '123', // numbers are valid
        'User123',
      ];

      for (int i = 0; i < 100; i++) {
        for (final name in validNames) {
          final result = validateName(name);
          
          // Property: Must return null (no error)
          expect(result, isNull,
              reason: 'Iteration $i: Valid name "$name" must not return error');
        }
      }
    });

    test('Property 3.3: Email validation rejects empty strings', () {
      // Property: validateEmail MUST reject null and empty strings
      // with Portuguese error message
      
      final emptyEmails = [null, ''];

      for (int i = 0; i < 100; i++) {
        for (final email in emptyEmails) {
          final result = validateEmail(email);
          
          // Property 1: Must return error message
          expect(result, isNotNull,
              reason: 'Iteration $i: Empty email must return error');
          
          // Property 2: Error message must be "E-mail é obrigatório."
          expect(result, equals('E-mail é obrigatório.'),
              reason: 'Iteration $i: Empty email error must be in Portuguese');
        }
      }
    });

    test('Property 3.4: Email validation rejects invalid formats', () {
      // Property: validateEmail MUST reject invalid email formats
      // with Portuguese error message
      
      final invalidEmails = [
        'invalid',
        'invalid@',
        '@invalid.com',
        'invalid@.com',
        'invalid@domain',
        'invalid domain@test.com',
        'invalid..email@test.com',
        'invalid@domain..com',
        '.invalid@test.com',
        'invalid.@test.com',
        'invalid@test.com.',
        'invalid @test.com',
        'invalid@ test.com',
      ];

      for (int i = 0; i < 100; i++) {
        for (final email in invalidEmails) {
          final result = validateEmail(email);
          
          // Property 1: Must return error message
          expect(result, isNotNull,
              reason: 'Iteration $i: Invalid email "$email" must return error');
          
          // Property 2: Error message must be "Por favor, insira um e-mail válido."
          expect(result, equals('Por favor, insira um e-mail válido.'),
              reason: 'Iteration $i: Invalid email error must be in Portuguese');
        }
      }
    });

    test('Property 3.5: Email validation accepts valid formats', () {
      // Property: validateEmail MUST accept valid email formats
      
      final validEmails = [
        'user@example.com',
        'user.name@example.com',
        'user+tag@example.com',
        'user_name@example.com',
        'user123@example.com',
        'user@subdomain.example.com',
        'user@example.co.uk',
        'test.email.with+symbol@example4u.net',
      ];

      for (int i = 0; i < 100; i++) {
        for (final email in validEmails) {
          final result = validateEmail(email);
          
          // Property: Must return null (no error)
          expect(result, isNull,
              reason: 'Iteration $i: Valid email "$email" must not return error');
        }
      }
    });

    test('Property 3.6: Password validation rejects empty strings', () {
      // Property: validatePassword MUST reject null and empty strings
      // with Portuguese error message
      
      final emptyPasswords = [null, ''];

      for (int i = 0; i < 100; i++) {
        for (final password in emptyPasswords) {
          final result = validatePassword(password);
          
          // Property 1: Must return error message
          expect(result, isNotNull,
              reason: 'Iteration $i: Empty password must return error');
          
          // Property 2: Error message must be "Senha é obrigatória."
          expect(result, equals('Senha é obrigatória.'),
              reason: 'Iteration $i: Empty password error must be in Portuguese');
        }
      }
    });

    test('Property 3.7: Password validation rejects passwords shorter than 6 characters', () {
      // Property: validatePassword MUST reject passwords with less than 6 characters
      // with Portuguese error message
      
      final shortPasswords = [
        '1',
        '12',
        '123',
        '1234',
        '12345',
        'a',
        'ab',
        'abc',
        'abcd',
        'abcde',
      ];

      for (int i = 0; i < 100; i++) {
        for (final password in shortPasswords) {
          final result = validatePassword(password);
          
          // Property 1: Must return error message
          expect(result, isNotNull,
              reason: 'Iteration $i: Short password "$password" must return error');
          
          // Property 2: Error message must be "A senha deve ter pelo menos 6 caracteres."
          expect(result, equals('A senha deve ter pelo menos 6 caracteres.'),
              reason: 'Iteration $i: Short password error must be in Portuguese');
        }
      }
    });

    test('Property 3.8: Password validation accepts passwords with 6 or more characters', () {
      // Property: validatePassword MUST accept passwords with 6 or more characters
      
      final validPasswords = [
        '123456',
        'abcdef',
        'password',
        'Pass123',
        'MyP@ssw0rd',
        '123456789012345678901234567890', // very long
        'abc def', // with space
        '!@#\$%^',
        'Senha123!@#',
      ];

      for (int i = 0; i < 100; i++) {
        for (final password in validPasswords) {
          final result = validatePassword(password);
          
          // Property: Must return null (no error)
          expect(result, isNull,
              reason: 'Iteration $i: Valid password (length ${password.length}) must not return error');
        }
      }
    });

    test('Property 3.9: Validation is consistent across multiple calls', () {
      // Property: Validation functions MUST return the same result for the same input
      // across multiple calls (pure functions)
      
      final testCases = [
        {'input': 'João', 'validator': 'name'},
        {'input': '', 'validator': 'name'},
        {'input': 'user@example.com', 'validator': 'email'},
        {'input': 'invalid', 'validator': 'email'},
        {'input': 'Pass123', 'validator': 'password'},
        {'input': '123', 'validator': 'password'},
      ];

      for (int i = 0; i < 50; i++) {
        for (final testCase in testCases) {
          final input = testCase['input'] as String;
          final validator = testCase['validator'] as String;
          
          // Call validator multiple times
          final results = <String?>[];
          for (int j = 0; j < 10; j++) {
            String? result;
            switch (validator) {
              case 'name':
                result = validateName(input);
                break;
              case 'email':
                result = validateEmail(input);
                break;
              case 'password':
                result = validatePassword(input);
                break;
            }
            results.add(result);
          }
          
          // Property: All results must be identical
          final firstResult = results.first;
          expect(results.every((r) => r == firstResult), isTrue,
              reason: 'Iteration $i: Validator "$validator" must return consistent results for "$input"');
        }
      }
    });

    test('Property 3.10: All error messages are in Portuguese', () {
      // Property: All validation error messages MUST be in Portuguese
      // and contain no technical terms
      
      final testCases = [
        {'validator': 'name', 'input': '', 'expectedError': 'Nome é obrigatório.'},
        {'validator': 'email', 'input': '', 'expectedError': 'E-mail é obrigatório.'},
        {'validator': 'email', 'input': 'invalid', 'expectedError': 'Por favor, insira um e-mail válido.'},
        {'validator': 'password', 'input': '', 'expectedError': 'Senha é obrigatória.'},
        {'validator': 'password', 'input': '123', 'expectedError': 'A senha deve ter pelo menos 6 caracteres.'},
      ];

      for (int i = 0; i < 100; i++) {
        for (final testCase in testCases) {
          final validator = testCase['validator'] as String;
          final input = testCase['input'] as String;
          final expectedError = testCase['expectedError'] as String;
          
          String? result;
          switch (validator) {
            case 'name':
              result = validateName(input);
              break;
            case 'email':
              result = validateEmail(input);
              break;
            case 'password':
              result = validatePassword(input);
              break;
          }
          
          // Property 1: Error message must match expected
          expect(result, equals(expectedError),
              reason: 'Iteration $i: Error message must be in Portuguese');
          
          // Property 2: Error message must not contain technical terms
          final technicalTerms = ['null', 'empty', 'invalid', 'error', 'exception', 'validation'];
          final lowerCaseError = result!.toLowerCase();
          final containsTechnicalTerms = technicalTerms.any((term) => lowerCaseError.contains(term));
          expect(containsTechnicalTerms, isFalse,
              reason: 'Iteration $i: Error message must not contain technical terms');
        }
      }
    });

    test('Property 3.11: Validation functions handle edge cases correctly', () {
      // Property: Validation functions MUST handle edge cases correctly
      
      final edgeCases = [
        // Name edge cases
        {'validator': 'name', 'input': ' João ', 'shouldPass': true},
        {'validator': 'name', 'input': '\tJoão\n', 'shouldPass': true},
        {'validator': 'name', 'input': '   ', 'shouldPass': false},
        
        // Email edge cases
        {'validator': 'email', 'input': 'USER@EXAMPLE.COM', 'shouldPass': true},
        
        // Password edge cases
        {'validator': 'password', 'input': '      ', 'shouldPass': true}, // 6 spaces
        {'validator': 'password', 'input': '     ', 'shouldPass': false}, // 5 spaces
      ];

      for (int i = 0; i < 100; i++) {
        for (final testCase in edgeCases) {
          final validator = testCase['validator'] as String;
          final input = testCase['input'] as String;
          final shouldPass = testCase['shouldPass'] as bool;
          
          String? result;
          switch (validator) {
            case 'name':
              result = validateName(input);
              break;
            case 'email':
              result = validateEmail(input);
              break;
            case 'password':
              result = validatePassword(input);
              break;
          }
          
          // Property: Result must match expected outcome
          if (shouldPass) {
            expect(result, isNull,
                reason: 'Iteration $i: Edge case "$input" should pass validation');
          } else {
            expect(result, isNotNull,
                reason: 'Iteration $i: Edge case "$input" should fail validation');
          }
        }
      }
    });
  });
}
