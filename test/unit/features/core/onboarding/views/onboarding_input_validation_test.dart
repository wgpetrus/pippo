import 'package:flutter_test/flutter_test.dart';
import 'package:pippo/shared/utils/validation_helper.dart';

void main() {
  group('Real-time Validation Logic - Name', () {
    test('should return error for invalid name with numbers', () {
      final error = ValidationHelper.validateName('João123');
      expect(error, 'error_name_invalid');
    });

    test('should return error for short name', () {
      final error = ValidationHelper.validateName('A');
      expect(error, 'error_name_min_length');
    });

    test('should return null for valid name', () {
      final error = ValidationHelper.validateName('João Silva');
      expect(error, null);
    });

    test('should return error for empty name', () {
      final error = ValidationHelper.validateName('');
      expect(error, 'error_name_required');
    });

    test('should return error for name with special characters', () {
      final error = ValidationHelper.validateName('João@Silva');
      expect(error, 'error_name_invalid');
    });
  });

  group('Real-time Validation Logic - Email', () {
    test('should return error for invalid email format', () {
      final error = ValidationHelper.validateEmail('invalid');
      expect(error, 'error_email_invalid');
    });

    test('should return error for email without domain', () {
      final error = ValidationHelper.validateEmail('user@');
      expect(error, 'error_email_invalid');
    });

    test('should return null for valid email', () {
      final error = ValidationHelper.validateEmail('user@example.com');
      expect(error, null);
    });

    test('should return error for empty email', () {
      final error = ValidationHelper.validateEmail('');
      expect(error, 'error_email_required');
    });

    test('should return error for email without @', () {
      final error = ValidationHelper.validateEmail('userexample.com');
      expect(error, 'error_email_invalid');
    });
  });

  group('Real-time Validation Logic - Password', () {
    test('should return error for short password', () {
      final error = ValidationHelper.validatePassword('12345');
      expect(error, 'error_password_min_length');
    });

    test('should return null for valid password', () {
      final error = ValidationHelper.validatePassword('123456');
      expect(error, null);
    });

    test('should return error for empty password', () {
      final error = ValidationHelper.validatePassword('');
      expect(error, 'error_password_required');
    });

    test('should return null for password with exactly 6 characters', () {
      final error = ValidationHelper.validatePassword('abcdef');
      expect(error, null);
    });

    test('should return null for long password', () {
      final error = ValidationHelper.validatePassword('verylongpassword123');
      expect(error, null);
    });
  });

  group('Validation Feedback Pattern - Immediate Response', () {
    test('validation should be called on every text change', () {
      // Simula o padrão de validação em tempo real
      final inputs = ['A', 'Ab', 'Ab1', 'Abc'];
      final errors = <String?>[];

      for (final input in inputs) {
        errors.add(ValidationHelper.validateName(input));
      }

      // Verifica que validação retorna erro imediatamente
      expect(errors[0], 'error_name_min_length'); // 'A'
      expect(errors[1], null); // 'Ab' - válido
      expect(errors[2], 'error_name_invalid'); // 'Ab1'
      expect(errors[3], null); // 'Abc' - válido
    });

    test('email validation should respond to each keystroke', () {
      final inputs = ['u', 'us', 'user', 'user@', 'user@e', 'user@example.com'];
      final errors = <String?>[];

      for (final input in inputs) {
        errors.add(ValidationHelper.validateEmail(input));
      }

      // Todos os inputs incompletos devem retornar erro
      expect(errors[0], 'error_email_invalid'); // 'u'
      expect(errors[1], 'error_email_invalid'); // 'us'
      expect(errors[2], 'error_email_invalid'); // 'user'
      expect(errors[3], 'error_email_invalid'); // 'user@'
      expect(errors[4], 'error_email_invalid'); // 'user@e'
      expect(errors[5], null); // 'user@example.com' - válido
    });

    test('password validation should respond immediately', () {
      final inputs = ['1', '12', '123', '1234', '12345', '123456'];
      final errors = <String?>[];

      for (final input in inputs) {
        errors.add(ValidationHelper.validatePassword(input));
      }

      // Senhas com menos de 6 caracteres devem retornar erro
      expect(errors[0], 'error_password_min_length');
      expect(errors[1], 'error_password_min_length');
      expect(errors[2], 'error_password_min_length');
      expect(errors[3], 'error_password_min_length');
      expect(errors[4], 'error_password_min_length');
      expect(errors[5], null); // '123456' - válido
    });
  });

  group('Validation State Management Pattern', () {
    test('button should be disabled when validation fails', () {
      // Simula o padrão de desabilitar botão com input inválido
      final nameError = ValidationHelper.validateName('A');
      final hasText = 'A'.isNotEmpty;
      final isValid = hasText && nameError == null;

      expect(isValid, false);
    });

    test('button should be enabled when validation passes', () {
      final nameError = ValidationHelper.validateName('João Silva');
      final hasText = 'João Silva'.isNotEmpty;
      final isValid = hasText && nameError == null;

      expect(isValid, true);
    });

    test('button should be disabled with empty input', () {
      final nameError = ValidationHelper.validateName('');
      final hasText = ''.isNotEmpty;
      final isValid = hasText && nameError == null;

      expect(isValid, false);
    });
  });

  group('Error Message Display Pattern', () {
    test('error message should be shown when validation fails', () {
      final error = ValidationHelper.validateName('João123');
      final shouldShowError = error != null;

      expect(shouldShowError, true);
      expect(error, 'error_name_invalid');
    });

    test('error message should be hidden when validation passes', () {
      final error = ValidationHelper.validateName('João Silva');
      final shouldShowError = error != null;

      expect(shouldShowError, false);
    });

    test('error message should update on each validation', () {
      // Simula mudança de erro conforme input muda
      var error = ValidationHelper.validateName('A');
      expect(error, 'error_name_min_length');

      error = ValidationHelper.validateName('João123');
      expect(error, 'error_name_invalid');

      error = ValidationHelper.validateName('João Silva');
      expect(error, null);
    });
  });

  group('Password Confirmation Pattern', () {
    test('should show error when passwords do not match', () {
      final password = '123456';
      final confirm = '654321';
      final error = password != confirm ? 'error_passwords_dont_match' : null;

      expect(error, 'error_passwords_dont_match');
    });

    test('should clear error when passwords match', () {
      final password = '123456';
      final confirm = '123456';
      final error = password != confirm ? 'error_passwords_dont_match' : null;

      expect(error, null);
    });

    test('should validate confirm field on password change', () {
      // Simula re-validação do campo de confirmação quando senha muda
      var password = '123456';
      var confirm = '123456';
      var error = password != confirm ? 'error_passwords_dont_match' : null;
      expect(error, null);

      // Usuário muda a senha
      password = '654321';
      error = password != confirm ? 'error_passwords_dont_match' : null;
      expect(error, 'error_passwords_dont_match');
    });
  });

  group('Visual Feedback Pattern', () {
    test('should show error border when validation fails', () {
      final error = ValidationHelper.validateName('João123');
      final hasError = error != null;

      expect(hasError, true);
    });

    test('should show normal border when validation passes', () {
      final error = ValidationHelper.validateName('João Silva');
      final hasError = error != null;

      expect(hasError, false);
    });

    test('border color should change based on validation state', () {
      // Simula mudança de cor da borda
      var error = ValidationHelper.validateName('A');
      var hasError = error != null;
      expect(hasError, true); // Borda vermelha

      error = ValidationHelper.validateName('João Silva');
      hasError = error != null;
      expect(hasError, false); // Borda normal
    });
  });

  group('Integration - Complete Validation Flow', () {
    test('complete name validation flow', () {
      // Simula fluxo completo de validação de nome
      final testCases = [
        {'input': '', 'expectError': true},
        {'input': 'A', 'expectError': true},
        {'input': 'Ab', 'expectError': false},
        {'input': 'João', 'expectError': false},
        {'input': 'João123', 'expectError': true},
        {'input': 'João Silva', 'expectError': false},
      ];

      for (final testCase in testCases) {
        final input = testCase['input'] as String;
        final expectError = testCase['expectError'] as bool;
        final error = ValidationHelper.validateName(input);
        final hasError = error != null;

        expect(hasError, expectError,
            reason: 'Input "$input" should ${expectError ? "have" : "not have"} error');
      }
    });

    test('complete email validation flow', () {
      final testCases = [
        {'input': '', 'expectError': true},
        {'input': 'invalid', 'expectError': true},
        {'input': 'user@', 'expectError': true},
        {'input': 'user@example', 'expectError': true},
        {'input': 'user@example.com', 'expectError': false},
      ];

      for (final testCase in testCases) {
        final input = testCase['input'] as String;
        final expectError = testCase['expectError'] as bool;
        final error = ValidationHelper.validateEmail(input);
        final hasError = error != null;

        expect(hasError, expectError,
            reason: 'Input "$input" should ${expectError ? "have" : "not have"} error');
      }
    });

    test('complete password validation flow', () {
      final testCases = [
        {'input': '', 'expectError': true},
        {'input': '123', 'expectError': true},
        {'input': '12345', 'expectError': true},
        {'input': '123456', 'expectError': false},
        {'input': 'verylongpassword', 'expectError': false},
      ];

      for (final testCase in testCases) {
        final input = testCase['input'] as String;
        final expectError = testCase['expectError'] as bool;
        final error = ValidationHelper.validatePassword(input);
        final hasError = error != null;

        expect(hasError, expectError,
            reason: 'Input "$input" should ${expectError ? "have" : "not have"} error');
      }
    });
  });
}
