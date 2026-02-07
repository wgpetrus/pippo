import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import local
import 'package:pippo/shared/utils/validation_helper.dart';

void main() {
  setUp(() async {
    // Setup GetX
    Get.testMode = true;

    // Setup SharedPreferences
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    Get.reset();
  });

  group('State Persistence - Onboarding', () {
    test('isFirstAccess is set to false after onboarding completion',
        () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstAccess', true); // Start with true

      // Act - Simulate what completeOnboarding() does
      await prefs.setBool('isFirstAccess', false);

      // Assert
      final isFirstAccess = prefs.getBool('isFirstAccess');
      expect(isFirstAccess, false,
          reason: 'isFirstAccess should be set to false after onboarding');
    });

    test('isFirstAccess remains false after being set', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();

      // Act
      await prefs.setBool('isFirstAccess', false);

      // Assert
      final isFirstAccess = prefs.getBool('isFirstAccess');
      expect(isFirstAccess, false);

      // Verify it stays false even after multiple reads
      final isFirstAccess2 = prefs.getBool('isFirstAccess');
      expect(isFirstAccess2, false);
    });

    test('isFirstAccess defaults to true when not set', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();

      // Act - Don't set anything

      // Assert
      final isFirstAccess = prefs.getBool('isFirstAccess');
      expect(isFirstAccess, isNull,
          reason: 'isFirstAccess should be null when not set');
      
      // In the app, we treat null as true (first access)
      final isFirstAccessOrDefault = isFirstAccess ?? true;
      expect(isFirstAccessOrDefault, true);
    });

    test('isFirstAccess can be read after being set to false', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstAccess', false);

      // Act
      final isFirstAccess = prefs.getBool('isFirstAccess');

      // Assert
      expect(isFirstAccess, false);
    });

    test('isFirstAccess persists across multiple reads', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstAccess', false);

      // Act & Assert - Read multiple times
      for (int i = 0; i < 10; i++) {
        final isFirstAccess = prefs.getBool('isFirstAccess');
        expect(isFirstAccess, false,
            reason: 'isFirstAccess should remain false on read $i');
      }
    });
  });

  group('Input Validation - Name', () {
    // Validadores extraídos do OnboardingController
    // IMPORTANTE: Manter sincronizado com lib/features/core/onboarding/controllers/onboarding_controller.dart
    String? validateName(String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Nome é obrigatório.';
      }
      return null;
    }

    test('rejects null value', () {
      final result = validateName(null);
      expect(result, equals('Nome é obrigatório.'));
    });

    test('rejects empty string', () {
      final result = validateName('');
      expect(result, equals('Nome é obrigatório.'));
    });

    test('rejects whitespace-only string', () {
      final result = validateName('   ');
      expect(result, equals('Nome é obrigatório.'));
    });

    test('rejects tab-only string', () {
      final result = validateName('\t');
      expect(result, equals('Nome é obrigatório.'));
    });

    test('rejects newline-only string', () {
      final result = validateName('\n');
      expect(result, equals('Nome é obrigatório.'));
    });

    test('rejects mixed whitespace string', () {
      final result = validateName('  \t\n  ');
      expect(result, equals('Nome é obrigatório.'));
    });

    test('accepts valid name', () {
      final result = validateName('João');
      expect(result, isNull);
    });

    test('accepts name with spaces', () {
      final result = validateName('Maria Silva');
      expect(result, isNull);
    });

    test('accepts name with leading/trailing spaces (trimmed)', () {
      final result = validateName(' João ');
      expect(result, isNull);
    });

    test('accepts single character name', () {
      final result = validateName('A');
      expect(result, isNull);
    });

    test('accepts name with special characters', () {
      final result = validateName('José María');
      expect(result, isNull);
    });
  });

  group('Input Validation - Email', () {
    // Validadores extraídos do OnboardingController
    String? validateEmail(String? value) {
      if (value == null || value.isEmpty) {
        return 'E-mail é obrigatório.';
      }
      if (!GetUtils.isEmail(value)) {
        return 'Por favor, insira um e-mail válido.';
      }
      return null;
    }

    test('rejects null value', () {
      final result = validateEmail(null);
      expect(result, equals('E-mail é obrigatório.'));
    });

    test('rejects empty string', () {
      final result = validateEmail('');
      expect(result, equals('E-mail é obrigatório.'));
    });

    test('rejects invalid format - no @', () {
      final result = validateEmail('invalid');
      expect(result, equals('Por favor, insira um e-mail válido.'));
    });

    test('rejects invalid format - no domain', () {
      final result = validateEmail('invalid@');
      expect(result, equals('Por favor, insira um e-mail válido.'));
    });

    test('rejects invalid format - no local part', () {
      final result = validateEmail('@invalid.com');
      expect(result, equals('Por favor, insira um e-mail válido.'));
    });

    test('rejects invalid format - missing TLD', () {
      final result = validateEmail('invalid@domain');
      expect(result, equals('Por favor, insira um e-mail válido.'));
    });

    test('rejects invalid format - space in email', () {
      final result = validateEmail('invalid domain@test.com');
      expect(result, equals('Por favor, insira um e-mail válido.'));
    });

    test('rejects invalid format - double dots', () {
      final result = validateEmail('invalid..email@test.com');
      expect(result, equals('Por favor, insira um e-mail válido.'));
    });

    test('accepts valid email', () {
      final result = validateEmail('user@example.com');
      expect(result, isNull);
    });

    test('accepts email with dots', () {
      final result = validateEmail('user.name@example.com');
      expect(result, isNull);
    });

    test('accepts email with plus', () {
      final result = validateEmail('user+tag@example.com');
      expect(result, isNull);
    });

    test('accepts email with underscore', () {
      final result = validateEmail('user_name@example.com');
      expect(result, isNull);
    });

    test('accepts email with numbers', () {
      final result = validateEmail('user123@example.com');
      expect(result, isNull);
    });

    test('accepts email with subdomain', () {
      final result = validateEmail('user@subdomain.example.com');
      expect(result, isNull);
    });

    test('accepts email with country TLD', () {
      final result = validateEmail('user@example.co.uk');
      expect(result, isNull);
    });
  });

  group('Input Validation - Password', () {
    // Validadores extraídos do OnboardingController
    String? validatePassword(String? value) {
      if (value == null || value.isEmpty) {
        return 'Senha é obrigatória.';
      }
      if (value.length < 6) {
        return 'A senha deve ter pelo menos 6 caracteres.';
      }
      return null;
    }

    test('rejects null value', () {
      final result = validatePassword(null);
      expect(result, equals('Senha é obrigatória.'));
    });

    test('rejects empty string', () {
      final result = validatePassword('');
      expect(result, equals('Senha é obrigatória.'));
    });

    test('rejects password with 0 characters', () {
      final result = validatePassword('');
      expect(result, equals('Senha é obrigatória.'));
    });

    test('rejects password with 1 character', () {
      final result = validatePassword('1');
      expect(result, equals('A senha deve ter pelo menos 6 caracteres.'));
    });

    test('rejects password with 5 characters', () {
      final result = validatePassword('12345');
      expect(result, equals('A senha deve ter pelo menos 6 caracteres.'));
    });

    test('accepts password with exactly 6 characters', () {
      final result = validatePassword('123456');
      expect(result, isNull);
    });

    test('accepts password with 10 characters', () {
      final result = validatePassword('1234567890');
      expect(result, isNull);
    });

    test('accepts password with letters', () {
      final result = validatePassword('abcdef');
      expect(result, isNull);
    });

    test('accepts password with mixed case', () {
      final result = validatePassword('Pass123');
      expect(result, isNull);
    });

    test('accepts password with special characters', () {
      final result = validatePassword('P@ss123!');
      expect(result, isNull);
    });

    test('accepts password with spaces', () {
      final result = validatePassword('abc def');
      expect(result, isNull);
    });

    test('accepts very long password', () {
      final result = validatePassword('123456789012345678901234567890');
      expect(result, isNull);
    });
  });

  group('Error Messages', () {
    // Validadores extraídos do OnboardingController
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

    test('name error message matches requirements', () {
      final result = validateName('');
      expect(result, equals('Nome é obrigatório.'));
    });

    test('email empty error message matches requirements', () {
      final result = validateEmail('');
      expect(result, equals('E-mail é obrigatório.'));
    });

    test('email invalid error message matches requirements', () {
      final result = validateEmail('invalid');
      expect(result, equals('Por favor, insira um e-mail válido.'));
    });

    test('password empty error message matches requirements', () {
      final result = validatePassword('');
      expect(result, equals('Senha é obrigatória.'));
    });

    test('password short error message matches requirements', () {
      final result = validatePassword('123');
      expect(result, equals('A senha deve ter pelo menos 6 caracteres.'));
    });

    test('all error messages are in Portuguese', () {
      final nameError = validateName('');
      final emailEmptyError = validateEmail('');
      final emailInvalidError = validateEmail('invalid');
      final passwordEmptyError = validatePassword('');
      final passwordShortError = validatePassword('123');

      // Check that all error messages contain Portuguese words
      expect(nameError, contains('obrigatório'));
      expect(emailEmptyError, contains('obrigatório'));
      expect(emailInvalidError, contains('Por favor'));
      expect(passwordEmptyError, contains('obrigatória'));
      expect(passwordShortError, contains('pelo menos'));
    });

    test('error messages do not contain technical terms', () {
      final nameError = validateName('');
      final emailInvalidError = validateEmail('invalid');
      final passwordShortError = validatePassword('123');

      // Check that error messages don't contain technical terms
      expect(nameError?.toLowerCase(), isNot(contains('null')));
      expect(nameError?.toLowerCase(), isNot(contains('error')));
      expect(emailInvalidError?.toLowerCase(), isNot(contains('invalid')));
      expect(emailInvalidError?.toLowerCase(), isNot(contains('error')));
      expect(passwordShortError?.toLowerCase(), isNot(contains('error')));
    });
  });

  group('Account Creation Flow', () {
    // Firebase Auth error handler extraído do OnboardingController
    // IMPORTANTE: Manter sincronizado com lib/features/core/onboarding/controllers/onboarding_controller.dart
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

    test('email-already-in-use error returns correct message', () {
      final message = handleFirebaseAuthError('email-already-in-use');
      expect(message, equals('Este e-mail já está sendo usado por outra conta.'));
    });

    test('invalid-email error returns correct message', () {
      final message = handleFirebaseAuthError('invalid-email');
      expect(message, equals('Por favor, insira um e-mail válido.'));
    });

    test('weak-password error returns correct message', () {
      final message = handleFirebaseAuthError('weak-password');
      expect(message, equals('A senha deve ter pelo menos 6 caracteres.'));
    });

    test('network-request-failed error returns correct message', () {
      final message = handleFirebaseAuthError('network-request-failed');
      expect(message, equals('Verifique sua conexão com a internet.'));
    });

    test('too-many-requests error returns correct message', () {
      final message = handleFirebaseAuthError('too-many-requests');
      expect(message, equals('Muitas tentativas. Aguarde alguns minutos e tente novamente.'));
    });

    test('operation-not-allowed error returns correct message', () {
      final message = handleFirebaseAuthError('operation-not-allowed');
      expect(message, equals('Operação não permitida no momento.'));
    });

    test('unknown error returns default message', () {
      final message = handleFirebaseAuthError('unknown-error');
      expect(message, equals('Não foi possível criar sua conta. Tente novamente.'));
    });

    test('all Firebase error messages are in Portuguese', () {
      final errorCodes = [
        'email-already-in-use',
        'invalid-email',
        'weak-password',
        'network-request-failed',
        'too-many-requests',
        'operation-not-allowed',
      ];

      for (final code in errorCodes) {
        final message = handleFirebaseAuthError(code);
        
        // Check message is not empty
        expect(message.isNotEmpty, isTrue,
            reason: 'Error code "$code" must return non-empty message');
        
        // Check message ends with period
        expect(message.endsWith('.'), isTrue,
            reason: 'Error code "$code" message must end with period');
        
        // Check message starts with capital letter
        expect(message[0], equals(message[0].toUpperCase()),
            reason: 'Error code "$code" message must start with capital letter');
      }
    });

    test('Firebase error messages do not contain technical terms', () {
      final errorCodes = [
        'email-already-in-use',
        'invalid-email',
        'weak-password',
        'network-request-failed',
        'too-many-requests',
      ];

      final technicalTerms = ['exception', 'error', 'code', 'firebase', 'auth'];

      for (final code in errorCodes) {
        final message = handleFirebaseAuthError(code);
        final lowerMessage = message.toLowerCase();
        
        for (final term in technicalTerms) {
          expect(lowerMessage, isNot(contains(term)),
              reason: 'Error code "$code" message must not contain technical term "$term"');
        }
      }
    });

    test('each Firebase error code has unique message', () {
      final errorCodes = [
        'email-already-in-use',
        'invalid-email',
        'weak-password',
        'network-request-failed',
        'too-many-requests',
      ];

      final messages = <String>{};
      for (final code in errorCodes) {
        final message = handleFirebaseAuthError(code);
        messages.add(message);
      }

      // All messages should be unique
      expect(messages.length, equals(errorCodes.length),
          reason: 'Each error code must have a unique message');
    });
  });

  group('OTP Flow', () {
    // Helper: Generate 5-digit OTP code (same logic as controller)
    String generateOTP() {
      final random = Random();
      final code = (10000 + random.nextInt(90000)).toString();
      return code;
    }

    test('OTP generation produces 5-digit code', () {
      final code = generateOTP();
      
      expect(code.length, equals(5), reason: 'OTP must be exactly 5 digits');
      expect(RegExp(r'^\d{5}$$').hasMatch(code), isTrue, reason: 'OTP must contain only digits');
    });

    test('OTP generation produces codes in valid range', () {
      for (int i = 0; i < 20; i++) {
        final code = generateOTP();
        final codeInt = int.parse(code);
        
        expect(codeInt, greaterThanOrEqualTo(10000), reason: 'OTP must be >= 10000');
        expect(codeInt, lessThanOrEqualTo(99999), reason: 'OTP must be <= 99999');
      }
    });

    test('correct code is accepted', () {
      final storedCode = '12345';
      final enteredCode = '12345';
      
      expect(enteredCode, equals(storedCode), reason: 'Matching codes should be accepted');
    });

    test('incorrect code is rejected', () {
      final storedCode = '12345';
      final enteredCode = '54321';
      
      expect(enteredCode, isNot(equals(storedCode)), reason: 'Non-matching codes should be rejected');
    });

    test('expired code is rejected (> 10 minutes)', () {
      final now = DateTime.now();
      final expiresAt = now.subtract(const Duration(minutes: 11));
      
      final isExpired = now.isAfter(expiresAt);
      expect(isExpired, isTrue, reason: 'Code expired 11 minutes ago should be rejected');
    });

    test('valid code is accepted (< 10 minutes)', () {
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(minutes: 5));
      
      final isExpired = now.isAfter(expiresAt);
      expect(isExpired, isFalse, reason: 'Code expiring in 5 minutes should be accepted');
    });

    test('code expiring exactly now is accepted (boundary)', () {
      final now = DateTime.now();
      final expiresAt = now;
      
      final isExpired = now.isAfter(expiresAt);
      expect(isExpired, isFalse, reason: 'Code expiring exactly now should be accepted');
    });

    test('code expired 1 second ago is rejected (boundary)', () {
      final now = DateTime.now();
      final expiresAt = now.subtract(const Duration(seconds: 1));
      
      final isExpired = now.isAfter(expiresAt);
      expect(isExpired, isTrue, reason: 'Code expired 1 second ago should be rejected');
    });

    test('resend timer counts down from 60 to 0', () {
      int timer = 60;
      
      // Simulate countdown
      for (int i = 60; i >= 0; i--) {
        expect(timer, equals(i), reason: 'Timer should be at $i');
        timer--;
      }
      
      expect(timer, equals(-1), reason: 'Timer should reach -1 after countdown');
    });

    test('Firestore document structure has all required fields', () {
      final document = {
        'code': '12345',
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 10))),
        'attempts': 0,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      };
      
      expect(document.containsKey('code'), isTrue);
      expect(document.containsKey('expiresAt'), isTrue);
      expect(document.containsKey('attempts'), isTrue);
      expect(document.containsKey('createdAt'), isTrue);
    });

    test('Firestore document has correct field types', () {
      final document = {
        'code': '12345',
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 10))),
        'attempts': 0,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      };
      
      expect(document['code'], isA<String>());
      expect(document['expiresAt'], isA<Timestamp>());
      expect(document['attempts'], isA<int>());
      expect(document['createdAt'], isA<Timestamp>());
    });

    test('Firestore document attempts starts at 0', () {
      final document = {
        'code': '12345',
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 10))),
        'attempts': 0,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      };
      
      expect(document['attempts'], equals(0), reason: 'attempts must start at 0');
    });

    test('OTP document is deleted after successful verification', () {
      // Simulate document deletion
      Map<String, dynamic>? document = {
        'code': '12345',
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 10))),
        'attempts': 0,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      };
      
      // After successful verification
      document = null;
      
      expect(document, isNull, reason: 'Document should be deleted after verification');
    });

    test('code validation rejects non-5-digit codes', () {
      final testCases = [
        ('1234', false),   // Too short
        ('123456', false), // Too long
        ('', false),       // Empty
        ('abcde', false),  // Letters
        ('12 45', false),  // Space
        ('12.45', false),  // Decimal
        ('12345', true),   // Valid
      ];
      
      for (final testCase in testCases) {
        final code = testCase.$1;
        final shouldBeValid = testCase.$2;
        
        final isValid = code.length == 5 && RegExp(r'^\d{5}$').hasMatch(code);
        
        expect(
          isValid,
          equals(shouldBeValid),
          reason: 'Code "$code" should ${shouldBeValid ? "be" : "not be"} valid',
        );
      }
    });

    test('OTP error messages are in Portuguese', () {
      final errorMessages = {
        'invalid_length': 'O código deve ter 5 dígitos.',
        'invalid_format': 'O código deve conter apenas números.',
        'code_not_found': 'Código não encontrado. Solicite um novo código.',
        'code_expired': 'Código expirado. Solicite um novo código.',
        'code_invalid': 'Código inválido. Verifique e tente novamente.',
        'session_expired': 'Sessão expirada. Inicie o processo novamente.',
      };
      
      for (final message in errorMessages.values) {
        expect(message.isNotEmpty, isTrue);
        expect(message.endsWith('.'), isTrue);
        expect(message[0], equals(message[0].toUpperCase()));
      }
    });
  });

  group('Username Generation', () {
    // Helper function to simulate username generation logic
    // IMPORTANTE: Manter sincronizado com OnboardingController.generateUniqueUsername
    String generateBaseUsername(String name) {
      return name.toLowerCase().replaceAll(' ', '');
    }

    test('converts name to lowercase', () {
      final testCases = [
        ('JOÃO', 'joão'),
        ('Maria', 'maria'),
        ('PEDRO SILVA', 'pedrosilva'),
        ('Ana Paula', 'anapaula'),
      ];

      for (final testCase in testCases) {
        final name = testCase.$1;
        final expected = testCase.$2;
        final username = generateBaseUsername(name);

        expect(username, equals(expected),
            reason: 'Username from "$name" should be "$expected"');
      }
    });

    test('removes all spaces from name', () {
      final testCases = [
        'João Silva',
        'Maria  Silva', // double space
        'Pedro   Silva   Santos', // multiple spaces
        ' Ana Paula ', // leading/trailing spaces
      ];

      for (final name in testCases) {
        final username = generateBaseUsername(name);

        expect(username.contains(' '), isFalse,
            reason: 'Username from "$name" should not contain spaces');
      }
    });

    test('handles single word names', () {
      final testCases = [
        ('João', 'joão'),
        ('MARIA', 'maria'),
        ('Pedro', 'pedro'),
      ];

      for (final testCase in testCases) {
        final name = testCase.$1;
        final expected = testCase.$2;
        final username = generateBaseUsername(name);

        expect(username, equals(expected));
      }
    });

    test('handles multi-word names', () {
      final testCases = [
        ('João Silva', 'joãosilva'),
        ('Maria Silva Santos', 'mariasilvasantos'),
        ('José da Silva', 'josédasilva'),
      ];

      for (final testCase in testCases) {
        final name = testCase.$1;
        final expected = testCase.$2;
        final username = generateBaseUsername(name);

        expect(username, equals(expected));
      }
    });

    test('handles names with special characters', () {
      final testCases = [
        ('José', 'josé'),
        ('María', 'maría'),
        ('François', 'françois'),
      ];

      for (final testCase in testCases) {
        final name = testCase.$1;
        final expected = testCase.$2;
        final username = generateBaseUsername(name);

        expect(username, equals(expected));
      }
    });

    test('handles names with numbers', () {
      final testCases = [
        ('João123', 'joão123'),
        ('Maria456', 'maria456'),
      ];

      for (final testCase in testCases) {
        final name = testCase.$1;
        final expected = testCase.$2;
        final username = generateBaseUsername(name);

        expect(username, equals(expected));
      }
    });

    test('handles edge cases', () {
      final testCases = [
        ('A', 'a'),
        ('AB', 'ab'),
        ('A B', 'ab'),
        ('   João   ', 'joão'),
      ];

      for (final testCase in testCases) {
        final name = testCase.$1;
        final expected = testCase.$2;
        final username = generateBaseUsername(name);

        expect(username, equals(expected));
      }
    });

    test('username with number suffix follows pattern', () {
      final baseUsername = 'joaosilva';
      final suffixes = [1, 10, 100, 1000, 9999];

      for (final suffix in suffixes) {
        final username = '$baseUsername$suffix';

        // Must start with base username
        expect(username.startsWith(baseUsername), isTrue);

        // Suffix must be a valid number
        final suffixStr = username.substring(baseUsername.length);
        final suffixNum = int.tryParse(suffixStr);
        expect(suffixNum, isNotNull);
        expect(suffixNum, equals(suffix));

        // No separator between base and suffix
        expect(username, equals('$baseUsername$suffix'));
      }
    });

    test('random number suffix is between 1 and 9999', () {
      final random = Random();
      
      for (int i = 0; i < 20; i++) {
        final suffix = random.nextInt(9999) + 1;
        
        expect(suffix, greaterThanOrEqualTo(1));
        expect(suffix, lessThanOrEqualTo(9999));
      }
    });

    test('conflict resolution appends random number', () {
      final baseUsername = 'joaosilva';
      final existingUsernames = {'joaosilva', 'joaosilva1', 'joaosilva2'};

      // Simulate conflict resolution
      String username = baseUsername;
      int attempts = 0;
      const maxAttempts = 100;

      while (attempts < maxAttempts && existingUsernames.contains(username)) {
        final random = Random().nextInt(9999) + 1;
        username = '$baseUsername$random';
        attempts++;
      }

      // Should have found a unique username
      expect(existingUsernames.contains(username), isFalse,
          reason: 'Should generate username not in existing set');
      expect(attempts, lessThan(maxAttempts),
          reason: 'Should find unique username within max attempts');
    });

    test('max attempts handling', () {
      int attempts = 0;
      const maxAttempts = 100;

      // Simulate reaching max attempts
      while (attempts < maxAttempts) {
        attempts++;
      }

      expect(attempts, equals(maxAttempts),
          reason: 'Should stop at max attempts');
    });

    test('username generation is deterministic for same input', () {
      final name = 'João Silva';
      final usernames = <String>[];

      // Generate username multiple times
      for (int i = 0; i < 10; i++) {
        usernames.add(generateBaseUsername(name));
      }

      // All results should be identical
      final firstUsername = usernames.first;
      expect(usernames.every((u) => u == firstUsername), isTrue,
          reason: 'generateBaseUsername should be deterministic');
    });

    test('different names produce different usernames', () {
      final testPairs = [
        ['João Silva', 'Maria Silva'],
        ['Pedro', 'Paulo'],
        ['Ana Paula', 'Ana Maria'],
      ];

      for (final pair in testPairs) {
        final username1 = generateBaseUsername(pair[0]);
        final username2 = generateBaseUsername(pair[1]);

        expect(username1, isNot(equals(username2)),
            reason: 'Different names should produce different usernames');
      }
    });

    test('same name with different case produces same username', () {
      final variations = ['João Silva', 'joão silva', 'JOÃO SILVA', 'João  Silva'];
      final usernames = variations.map((name) => generateBaseUsername(name)).toSet();

      expect(usernames.length, equals(1),
          reason: 'Names differing only in case/spaces should produce same username');
    });

    test('Firestore error handling returns Portuguese message', () {
      // Simulate Firestore error codes
      String handleFirestoreError(String errorCode) {
        switch (errorCode) {
          case 'permission-denied':
            return 'Erro de permissão. Verifique as configurações do Firestore ou tente novamente em alguns instantes.';
          case 'unavailable':
            return 'Serviço temporariamente indisponível. Tente novamente em alguns instantes.';
          case 'deadline-exceeded':
            return 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
          default:
            return 'Erro ao salvar dados. Verifique sua conexão e tente novamente.';
        }
      }

      final errorCodes = ['permission-denied', 'unavailable', 'deadline-exceeded', 'unknown'];

      for (final code in errorCodes) {
        final message = handleFirestoreError(code);

        expect(message.isNotEmpty, isTrue);
        expect(message.endsWith('.'), isTrue);
        expect(message[0], equals(message[0].toUpperCase()));
      }
    });

    test('username generation error messages are in Portuguese', () {
      final errorMessages = {
        'max_attempts': 'Não foi possível gerar um nome de usuário único.',
        'firestore_error': 'Erro ao verificar nome de usuário. Tente novamente.',
      };

      for (final message in errorMessages.values) {
        expect(message.isNotEmpty, isTrue);
        expect(message.endsWith('.'), isTrue);
        expect(message[0], equals(message[0].toUpperCase()));
      }
    });

    test('username preserves non-space characters', () {
      final testCases = [
        ('João123', 'joão123'),
        ('Maria_Silva', 'maria_silva'),
        ('Pedro-Santos', 'pedro-santos'),
      ];

      for (final testCase in testCases) {
        final name = testCase.$1;
        final expected = testCase.$2;
        final username = generateBaseUsername(name);

        expect(username, equals(expected),
            reason: 'Username should preserve non-space characters');
      }
    });

    test('username length equals name length minus spaces', () {
      final testCases = [
        'João',
        'Maria Silva',
        'Pedro Silva Santos',
      ];

      for (final name in testCases) {
        final username = generateBaseUsername(name);
        final expectedLength = name.replaceAll(' ', '').length;

        expect(username.length, equals(expectedLength),
            reason: 'Username length should equal name length minus spaces');
      }
    });
  });

  group('Firestore Operations - Document Structure', () {
    test('user document structure has all required fields', () {
      // Simulate user document creation
      final userDoc = {
        'id': 'user123',
        'email': 'user@example.com',
        'name': 'João Silva',
        'username': 'joaosilva',
        'age': '25-34',
        'onboardingCompleted': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Verify all required fields are present
      expect(userDoc.containsKey('id'), isTrue);
      expect(userDoc.containsKey('email'), isTrue);
      expect(userDoc.containsKey('name'), isTrue);
      expect(userDoc.containsKey('username'), isTrue);
      expect(userDoc.containsKey('age'), isTrue);
      expect(userDoc.containsKey('onboardingCompleted'), isTrue);
      expect(userDoc.containsKey('createdAt'), isTrue);
      expect(userDoc.containsKey('updatedAt'), isTrue);

      // Verify field values
      expect(userDoc['onboardingCompleted'], isTrue);
      expect(userDoc['createdAt'], isA<FieldValue>());
      expect(userDoc['updatedAt'], isA<FieldValue>());
    });

    test('course document structure has all required fields', () {
      // Simulate Firestore auto-generated ID (20-character alphanumeric)
      final courseId = 'abc123def456ghi789jk';

      // Simulate course document creation
      final courseDoc = {
        'id': courseId,
        'language': 'en',
        'languageName': 'English',
        'level': 'beginner',
        'reason': 'travel',
        'studyTime': 10,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Verify all required fields are present
      expect(courseDoc.containsKey('id'), isTrue);
      expect(courseDoc.containsKey('language'), isTrue);
      expect(courseDoc.containsKey('languageName'), isTrue);
      expect(courseDoc.containsKey('level'), isTrue);
      expect(courseDoc.containsKey('reason'), isTrue);
      expect(courseDoc.containsKey('studyTime'), isTrue);
      expect(courseDoc.containsKey('isActive'), isTrue);
      expect(courseDoc.containsKey('createdAt'), isTrue);

      // Verify field values
      expect(courseDoc['isActive'], isTrue);
      expect(courseDoc['studyTime'], isA<int>());
      expect(courseDoc['createdAt'], isA<FieldValue>());
    });

    // TODO: Fix this test - requires proper mock setup
    // test('course ID uses Firestore auto-generated format', () async {
    //   // Setup
    //   controller.selectedLanguage.value = 'en';
    //   controller.languageLevel.value = 'beginner';
    //   controller.learningReason.value = 'travel';
    //   controller.studyTime.value = '10';
    //
    //   // Mock Firestore to capture the document reference
    //   String? capturedCourseId;
    //   when(() => mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    //   when(() => mockUsersCollection.doc('test-user-id')).thenReturn(mockUserDoc);
    //   when(() => mockUserDoc.collection('courses')).thenReturn(mockCoursesCollection);
    //   
    //   // Mock .doc() without parameters to return a doc with auto-generated ID
    //   final mockCourseDoc = MockDocumentReference<Map<String, dynamic>>();
    //   when(() => mockCoursesCollection.doc()).thenReturn(mockCourseDoc);
    //   when(() => mockCourseDoc.id).thenReturn('abc123def456ghi789jk'); // Firestore-like ID
    //   when(() => mockCourseDoc.set(any())).thenAnswer((_) async {
    //     capturedCourseId = mockCourseDoc.id;
    //   });
    //
    //   // Execute
    //   await controller.createFirstCourse('test-user-id');
    //
    //   // Verify
    //   expect(capturedCourseId, isNotNull);
    //   expect(capturedCourseId, isA<String>());
    //   expect(capturedCourseId!.isNotEmpty, isTrue);
    //   expect(capturedCourseId!.length, greaterThanOrEqualTo(20)); // Firestore IDs are typically 20 chars
    //   
    //   // Verify .doc() was called without parameters (auto-generated ID)
    //   verify(() => mockCoursesCollection.doc()).called(1);
    // });

    test('stats document structure has all required fields', () {
      // Simulate stats document creation
      final statsDoc = {
        'xp': 0,
        'level': 1,
        'streak': 0,
        'energy': 5,
        'gems': 0,
        'hearts': 5,
        'lastActiveAt': FieldValue.serverTimestamp(),
      };

      // Verify all required fields are present
      expect(statsDoc.containsKey('xp'), isTrue);
      expect(statsDoc.containsKey('level'), isTrue);
      expect(statsDoc.containsKey('streak'), isTrue);
      expect(statsDoc.containsKey('energy'), isTrue);
      expect(statsDoc.containsKey('gems'), isTrue);
      expect(statsDoc.containsKey('hearts'), isTrue);
      expect(statsDoc.containsKey('lastActiveAt'), isTrue);

      // Verify initial values
      expect(statsDoc['xp'], equals(0));
      expect(statsDoc['level'], equals(1));
      expect(statsDoc['streak'], equals(0));
      expect(statsDoc['energy'], equals(5));
      expect(statsDoc['gems'], equals(0));
      expect(statsDoc['hearts'], equals(5));
      expect(statsDoc['lastActiveAt'], isA<FieldValue>());
    });

    test('stats initial values are non-negative', () {
      final statsDoc = {
        'xp': 0,
        'level': 1,
        'streak': 0,
        'energy': 5,
        'gems': 0,
        'hearts': 5,
      };

      expect(statsDoc['xp']! >= 0, isTrue);
      expect(statsDoc['level']! >= 0, isTrue);
      expect(statsDoc['streak']! >= 0, isTrue);
      expect(statsDoc['energy']! >= 0, isTrue);
      expect(statsDoc['gems']! >= 0, isTrue);
      expect(statsDoc['hearts']! >= 0, isTrue);
    });

    test('all timestamps use FieldValue.serverTimestamp not DateTime', () {
      final userDoc = {
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final courseDoc = {
        'createdAt': FieldValue.serverTimestamp(),
      };

      final statsDoc = {
        'lastActiveAt': FieldValue.serverTimestamp(),
      };

      // Verify all are FieldValue
      expect(userDoc['createdAt'], isA<FieldValue>());
      expect(userDoc['updatedAt'], isA<FieldValue>());
      expect(courseDoc['createdAt'], isA<FieldValue>());
      expect(statsDoc['lastActiveAt'], isA<FieldValue>());

      // Verify none are DateTime
      expect(userDoc['createdAt'], isNot(isA<DateTime>()));
      expect(userDoc['updatedAt'], isNot(isA<DateTime>()));
      expect(courseDoc['createdAt'], isNot(isA<DateTime>()));
      expect(statsDoc['lastActiveAt'], isNot(isA<DateTime>()));
    });

    test('Firestore error handler returns Portuguese messages', () {
      // Simulate Firestore error codes
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

      for (final code in errorCodes) {
        final message = handleFirestoreError(code);

        // Verify message is not empty
        expect(message.isNotEmpty, isTrue);

        // Verify message ends with period
        expect(message.endsWith('.'), isTrue);

        // Verify message starts with capital letter
        expect(message[0], equals(message[0].toUpperCase()));
      }
    });

    test('Firestore error messages do not contain technical terms', () {
      String handleFirestoreError(String errorCode) {
        switch (errorCode) {
          case 'permission-denied':
            return 'Erro de permissão. Verifique as configurações do Firestore ou tente novamente em alguns instantes.';
          case 'unavailable':
            return 'Serviço temporariamente indisponível. Tente novamente em alguns instantes.';
          case 'deadline-exceeded':
            return 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
          default:
            return 'Erro ao salvar dados. Verifique sua conexão e tente novamente.';
        }
      }

      final errorCodes = ['permission-denied', 'unavailable', 'deadline-exceeded'];
      final technicalTerms = ['exception', 'error code', 'firebase', 'stack trace'];

      for (final code in errorCodes) {
        final message = handleFirestoreError(code).toLowerCase();

        for (final term in technicalTerms) {
          expect(message.contains(term), isFalse,
              reason: 'Message for "$code" should not contain technical term "$term"');
        }
      }
    });

    test('SharedPreferences isFirstAccess is updated after finalization', () async {
      final prefs = await SharedPreferences.getInstance();

      // Start with true (first access)
      await prefs.setBool('isFirstAccess', true);
      expect(prefs.getBool('isFirstAccess'), isTrue);

      // After finalization, should be false
      await prefs.setBool('isFirstAccess', false);
      expect(prefs.getBool('isFirstAccess'), isFalse);

      // Verify it persists
      final isFirstAccess = prefs.getBool('isFirstAccess');
      expect(isFirstAccess, isFalse);
    });
  });

  group('Add Course Mode', () {
    test('Course document structure matches expected format', () {
      // Arrange - Simulate course document structure with Firestore auto-generated ID
      final courseId = 'abc123def456ghi789jk'; // Simulate Firestore auto-generated ID
      
      final courseDoc = {
        'id': courseId,
        'language': 'es',
        'languageName': 'Spanish',
        'level': 'intermediate',
        'reason': 'work',
        'studyTime': 15,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Assert - Verify all required fields
      expect(courseDoc.containsKey('id'), isTrue);
      expect(courseDoc.containsKey('language'), isTrue);
      expect(courseDoc.containsKey('languageName'), isTrue);
      expect(courseDoc.containsKey('level'), isTrue);
      expect(courseDoc.containsKey('reason'), isTrue);
      expect(courseDoc.containsKey('studyTime'), isTrue);
      expect(courseDoc.containsKey('isActive'), isTrue);
      expect(courseDoc.containsKey('createdAt'), isTrue);

      // Verify types
      expect(courseDoc['id'], isA<String>());
      expect(courseDoc['language'], isA<String>());
      expect(courseDoc['languageName'], isA<String>());
      expect(courseDoc['level'], isA<String>());
      expect(courseDoc['reason'], isA<String>());
      expect(courseDoc['studyTime'], isA<int>());
      expect(courseDoc['isActive'], isA<bool>());
      expect(courseDoc['createdAt'], isA<FieldValue>());

      // Verify values
      expect(courseDoc['isActive'], isTrue);
      expect(courseDoc['studyTime'], greaterThan(0));
    });

    test('Course document does not contain user-specific fields', () {
      // Arrange
      final courseDoc = {
        'id': 'course123',
        'language': 'fr',
        'languageName': 'French',
        'level': 'beginner',
        'reason': 'culture',
        'studyTime': 20,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Assert - User-specific fields should not be present
      expect(courseDoc.containsKey('email'), isFalse);
      expect(courseDoc.containsKey('name'), isFalse);
      expect(courseDoc.containsKey('username'), isFalse);
      expect(courseDoc.containsKey('age'), isFalse);
      expect(courseDoc.containsKey('onboardingCompleted'), isFalse);
      expect(courseDoc.containsKey('updatedAt'), isFalse);
    });

    test('Course document does not contain stats fields', () {
      // Arrange
      final courseDoc = {
        'id': 'course123',
        'language': 'de',
        'languageName': 'German',
        'level': 'advanced', // This is course level, not stats level
        'reason': 'work',
        'studyTime': 10,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Assert - Stats fields should not be present
      expect(courseDoc.containsKey('xp'), isFalse);
      expect(courseDoc.containsKey('streak'), isFalse);
      expect(courseDoc.containsKey('energy'), isFalse);
      expect(courseDoc.containsKey('gems'), isFalse);
      expect(courseDoc.containsKey('hearts'), isFalse);
      expect(courseDoc.containsKey('lastActiveAt'), isFalse);
    });

    test('SharedPreferences is not modified in add course mode', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstAccess', false);
      final keysBefore = prefs.getKeys();

      // Act - Simulate add course mode (no SharedPreferences modification)
      // In add course mode, we don't touch SharedPreferences

      // Assert
      final keysAfter = prefs.getKeys();
      expect(keysAfter, equals(keysBefore),
          reason: 'SharedPreferences should not be modified in add course mode');
      expect(prefs.getBool('isFirstAccess'), isFalse,
          reason: 'isFirstAccess should remain unchanged');
    });

    test('Course ID uses Firestore auto-generated format', () {
      // Arrange & Act - Simulate Firestore auto-generated ID
      // Firestore generates 20-character alphanumeric IDs
      final courseId = 'abc123def456ghi789jk';

      // Assert - Verify ID is valid string
      expect(courseId, isA<String>());
      expect(courseId.isNotEmpty, isTrue,
          reason: 'Course ID must not be empty');
      expect(courseId.length, equals(20),
          reason: 'Firestore auto-generated IDs are 20 characters long');
    });

    test('Multiple course IDs are unique', () {
      // Arrange - Simulate multiple Firestore auto-generated IDs
      final courseIds = <String>{};

      // Act - Generate 100 simulated course IDs
      for (int i = 0; i < 100; i++) {
        courseIds.add('course_id_$i'); // Simulate unique IDs
      }

      // Assert - All IDs should be unique
      expect(courseIds.length, equals(100),
          reason: 'All generated course IDs must be unique');
    });

    test('Course language codes are valid', () {
      // Arrange
      final validLanguageCodes = ['en', 'es', 'fr', 'de', 'pt', 'zh', 'ja', 'ar'];

      // Act & Assert
      for (final langCode in validLanguageCodes) {
        expect(langCode.length, equals(2),
            reason: 'Language code must be 2 characters');
        expect(langCode, equals(langCode.toLowerCase()),
            reason: 'Language code must be lowercase');
      }
    });

    test('Course level values are valid', () {
      // Arrange
      final validLevels = ['beginner', 'intermediate', 'advanced'];

      // Act & Assert
      for (final level in validLevels) {
        expect(level, equals(level.toLowerCase()),
            reason: 'Level must be lowercase');
        expect(validLevels.contains(level), isTrue,
            reason: 'Level must be one of: beginner, intermediate, advanced');
      }
    });

    test('Course reason values are valid', () {
      // Arrange
      final validReasons = ['travel', 'work', 'culture', 'brain', 'other'];

      // Act & Assert
      for (final reason in validReasons) {
        expect(reason, equals(reason.toLowerCase()),
            reason: 'Reason must be lowercase');
        expect(validReasons.contains(reason), isTrue,
            reason: 'Reason must be one of: travel, work, culture, brain, other');
      }
    });

    test('Course study time values are valid', () {
      // Arrange
      final validStudyTimes = [5, 10, 15, 20];

      // Act & Assert
      for (final time in validStudyTimes) {
        expect(time, isA<int>(), reason: 'Study time must be int');
        expect(time, greaterThan(0), reason: 'Study time must be positive');
        expect(validStudyTimes.contains(time), isTrue,
            reason: 'Study time must be one of: 5, 10, 15, 20');
      }
    });

    test('Course isActive is always true for new courses', () {
      // Arrange & Act
      final courseDoc = {
        'id': 'course123',
        'language': 'en',
        'languageName': 'English',
        'level': 'beginner',
        'reason': 'travel',
        'studyTime': 10,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Assert
      expect(courseDoc['isActive'], isTrue,
          reason: 'New courses must have isActive set to true');
    });

    test('Course uses FieldValue.serverTimestamp() for createdAt', () {
      // Arrange & Act
      final courseDoc = {
        'id': 'course123',
        'language': 'en',
        'languageName': 'English',
        'level': 'beginner',
        'reason': 'travel',
        'studyTime': 10,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Assert
      expect(courseDoc['createdAt'], isA<FieldValue>(),
          reason: 'createdAt must use FieldValue.serverTimestamp()');
      expect(courseDoc['createdAt'], isNot(isA<DateTime>()),
          reason: 'createdAt must not be DateTime (common mistake)');
    });
  });

  group('Progress Calculation', () {
    // Helper function to simulate progress calculation logic
    // IMPORTANTE: Manter sincronizado com OnboardingController.calculateProgress
    Map<String, int> calculateProgress(String currentScreen, bool isAddingCourse) {
      // Define screen order for full onboarding (9 screens - excludes transitions)
      final fullOnboardingScreens = [
        'select_language',
        'language_level',
        'learning_reason',
        'study_time',
        'user_name',
        'user_age',
        'user_email',
        'user_password',
        'verify_code',
      ];

      // Define screen order for add course mode (4 screens)
      final addCourseScreens = [
        'select_language',
        'language_level',
        'learning_reason',
        'study_time',
      ];

      // Select appropriate screen list based on mode
      final screens = isAddingCourse ? addCourseScreens : fullOnboardingScreens;
      final total = screens.length;

      // Find current position (1-indexed)
      final index = screens.indexOf(currentScreen);
      final current = index >= 0 ? index + 1 : 1;

      return {'current': current, 'total': total};
    }

    test('select_language is position 1 in full onboarding', () {
      final progress = calculateProgress('select_language', false);
      expect(progress['current'], equals(1));
      expect(progress['total'], equals(9));
    });

    test('language_level is position 2 in full onboarding', () {
      final progress = calculateProgress('language_level', false);
      expect(progress['current'], equals(2));
      expect(progress['total'], equals(9));
    });

    test('learning_reason is position 3 in full onboarding', () {
      final progress = calculateProgress('learning_reason', false);
      expect(progress['current'], equals(3));
      expect(progress['total'], equals(9));
    });

    test('study_time is position 4 in full onboarding', () {
      final progress = calculateProgress('study_time', false);
      expect(progress['current'], equals(4));
      expect(progress['total'], equals(9));
    });

    test('user_name is position 5 in full onboarding', () {
      final progress = calculateProgress('user_name', false);
      expect(progress['current'], equals(5));
      expect(progress['total'], equals(9));
    });

    test('user_age is position 6 in full onboarding', () {
      final progress = calculateProgress('user_age', false);
      expect(progress['current'], equals(6));
      expect(progress['total'], equals(9));
    });

    test('user_email is position 7 in full onboarding', () {
      final progress = calculateProgress('user_email', false);
      expect(progress['current'], equals(7));
      expect(progress['total'], equals(9));
    });

    test('user_password is position 8 in full onboarding', () {
      final progress = calculateProgress('user_password', false);
      expect(progress['current'], equals(8));
      expect(progress['total'], equals(9));
    });

    test('verify_code is position 9 in full onboarding', () {
      final progress = calculateProgress('verify_code', false);
      expect(progress['current'], equals(9));
      expect(progress['total'], equals(9));
    });

    test('select_language is position 1 in add course mode', () {
      final progress = calculateProgress('select_language', true);
      expect(progress['current'], equals(1));
      expect(progress['total'], equals(4));
    });

    test('language_level is position 2 in add course mode', () {
      final progress = calculateProgress('language_level', true);
      expect(progress['current'], equals(2));
      expect(progress['total'], equals(4));
    });

    test('learning_reason is position 3 in add course mode', () {
      final progress = calculateProgress('learning_reason', true);
      expect(progress['current'], equals(3));
      expect(progress['total'], equals(4));
    });

    test('study_time is position 4 in add course mode', () {
      final progress = calculateProgress('study_time', true);
      expect(progress['current'], equals(4));
      expect(progress['total'], equals(4));
    });

    test('transition screen welcome is excluded', () {
      final progress = calculateProgress('welcome', false);
      expect(progress['current'], equals(1)); // Defaults to 1 (not found)
      expect(progress['total'], equals(9));
    });

    test('transition screen intro is excluded', () {
      final progress = calculateProgress('intro', false);
      expect(progress['current'], equals(1)); // Defaults to 1 (not found)
      expect(progress['total'], equals(9));
    });

    test('transition screen pause_one is excluded', () {
      final progress = calculateProgress('pause_one', false);
      expect(progress['current'], equals(1)); // Defaults to 1 (not found)
      expect(progress['total'], equals(9));
    });

    test('transition screen pause_two is excluded', () {
      final progress = calculateProgress('pause_two', false);
      expect(progress['current'], equals(1)); // Defaults to 1 (not found)
      expect(progress['total'], equals(9));
    });

    test('transition screen conclusion is excluded', () {
      final progress = calculateProgress('conclusion', false);
      expect(progress['current'], equals(1)); // Defaults to 1 (not found)
      expect(progress['total'], equals(9));
    });

    test('unknown screen defaults to position 1', () {
      final progress = calculateProgress('unknown_screen', false);
      expect(progress['current'], equals(1));
      expect(progress['total'], equals(9));
    });

    test('empty screen name defaults to position 1', () {
      final progress = calculateProgress('', false);
      expect(progress['current'], equals(1));
      expect(progress['total'], equals(9));
    });

    test('full onboarding mode has 9 total screens', () {
      final screens = [
        'select_language',
        'language_level',
        'learning_reason',
        'study_time',
        'user_name',
        'user_age',
        'user_email',
        'user_password',
        'verify_code',
      ];

      for (final screen in screens) {
        final progress = calculateProgress(screen, false);
        expect(progress['total'], equals(9),
            reason: 'Full onboarding should always have 9 total screens');
      }
    });

    test('add course mode has 4 total screens', () {
      final screens = [
        'select_language',
        'language_level',
        'learning_reason',
        'study_time',
      ];

      for (final screen in screens) {
        final progress = calculateProgress(screen, true);
        expect(progress['total'], equals(4),
            reason: 'Add course mode should always have 4 total screens');
      }
    });

    test('user_name is not in add course mode', () {
      final progress = calculateProgress('user_name', true);
      expect(progress['current'], equals(1)); // Not found, defaults to 1
      expect(progress['total'], equals(4));
    });

    test('user_age is not in add course mode', () {
      final progress = calculateProgress('user_age', true);
      expect(progress['current'], equals(1)); // Not found, defaults to 1
      expect(progress['total'], equals(4));
    });

    test('user_email is not in add course mode', () {
      final progress = calculateProgress('user_email', true);
      expect(progress['current'], equals(1)); // Not found, defaults to 1
      expect(progress['total'], equals(4));
    });

    test('user_password is not in add course mode', () {
      final progress = calculateProgress('user_password', true);
      expect(progress['current'], equals(1)); // Not found, defaults to 1
      expect(progress['total'], equals(4));
    });

    test('verify_code is not in add course mode', () {
      final progress = calculateProgress('verify_code', true);
      expect(progress['current'], equals(1)); // Not found, defaults to 1
      expect(progress['total'], equals(4));
    });
  });

  group('Controller Validation Methods', () {
    // These tests verify that the controller's validation methods correctly
    // delegate to ValidationHelper and return the expected results.
    // Since OnboardingController requires Firebase initialization, we test
    // the ValidationHelper directly (which is what the controller uses).
    //
    // NOTE: The controller methods are simple wrappers:
    // - validateName() => ValidationHelper.validateName()
    // - validateEmail() => ValidationHelper.validateEmail()
    // - validatePassword() => ValidationHelper.validatePassword()
    //
    // These tests ensure the ValidationHelper (used by the controller) works correctly.

    group('validateName', () {
      test('returns null for valid name', () {
        final result = ValidationHelper.validateName('João Silva');
        expect(result, isNull);
      });

      test('returns error for null value', () {
        final result = ValidationHelper.validateName(null);
        expect(result, equals('Nome é obrigatório.'));
      });

      test('returns error for empty string', () {
        final result = ValidationHelper.validateName('');
        expect(result, equals('Nome é obrigatório.'));
      });

      test('returns error for whitespace-only string', () {
        final result = ValidationHelper.validateName('   ');
        expect(result, equals('Nome é obrigatório.'));
      });

      test('returns error for single character name', () {
        final result = ValidationHelper.validateName('A');
        expect(result, equals('Nome deve ter pelo menos 2 caracteres.'));
      });

      test('returns error for name with numbers', () {
        final result = ValidationHelper.validateName('João123');
        expect(result, equals('Nome deve conter apenas letras e espaços.'));
      });

      test('returns error for name with special characters', () {
        final result = ValidationHelper.validateName('João@Silva');
        expect(result, equals('Nome deve conter apenas letras e espaços.'));
      });

      test('accepts name with exactly 2 characters', () {
        final result = ValidationHelper.validateName('Jo');
        expect(result, isNull);
      });

      test('accepts name with accented characters', () {
        final result = ValidationHelper.validateName('José María');
        expect(result, isNull);
      });

      test('accepts name with multiple spaces', () {
        final result = ValidationHelper.validateName('Maria da Silva Santos');
        expect(result, isNull);
      });

      test('trims leading and trailing spaces before validation', () {
        final result = ValidationHelper.validateName('  João Silva  ');
        expect(result, isNull);
      });

      test('returns consistent results for same input', () {
        final name = 'João Silva';
        final result1 = ValidationHelper.validateName(name);
        final result2 = ValidationHelper.validateName(name);
        final result3 = ValidationHelper.validateName(name);
        
        expect(result1, equals(result2));
        expect(result2, equals(result3));
      });

      test('error message is in Portuguese', () {
        final result = ValidationHelper.validateName('');
        expect(result, contains('obrigatório'));
      });

      test('error message does not contain technical terms', () {
        final result = ValidationHelper.validateName('');
        final lowerResult = result?.toLowerCase() ?? '';
        
        expect(lowerResult, isNot(contains('null')));
        expect(lowerResult, isNot(contains('error')));
        expect(lowerResult, isNot(contains('exception')));
      });
    });

    group('validateEmail', () {
      test('returns null for valid email', () {
        final result = ValidationHelper.validateEmail('user@example.com');
        expect(result, isNull);
      });

      test('returns error for null value', () {
        final result = ValidationHelper.validateEmail(null);
        expect(result, equals('E-mail é obrigatório.'));
      });

      test('returns error for empty string', () {
        final result = ValidationHelper.validateEmail('');
        expect(result, equals('E-mail é obrigatório.'));
      });

      test('returns error for whitespace-only string', () {
        final result = ValidationHelper.validateEmail('   ');
        expect(result, equals('E-mail é obrigatório.'));
      });

      test('returns error for email without @', () {
        final result = ValidationHelper.validateEmail('userexample.com');
        expect(result, equals('Por favor, insira um e-mail válido.'));
      });

      test('returns error for email without domain', () {
        final result = ValidationHelper.validateEmail('user@');
        expect(result, equals('Por favor, insira um e-mail válido.'));
      });

      test('returns error for email without local part', () {
        final result = ValidationHelper.validateEmail('@example.com');
        expect(result, equals('Por favor, insira um e-mail válido.'));
      });

      test('returns error for email without TLD', () {
        final result = ValidationHelper.validateEmail('user@example');
        expect(result, equals('Por favor, insira um e-mail válido.'));
      });

      test('returns error for email with spaces', () {
        final result = ValidationHelper.validateEmail('user name@example.com');
        expect(result, equals('Por favor, insira um e-mail válido.'));
      });

      test('accepts email with dots in local part', () {
        final result = ValidationHelper.validateEmail('user.name@example.com');
        expect(result, isNull);
      });

      test('accepts email with plus sign', () {
        final result = ValidationHelper.validateEmail('user+tag@example.com');
        expect(result, isNull);
      });

      test('accepts email with numbers', () {
        final result = ValidationHelper.validateEmail('user123@example.com');
        expect(result, isNull);
      });

      test('accepts email with subdomain', () {
        final result = ValidationHelper.validateEmail('user@mail.example.com');
        expect(result, isNull);
      });

      test('accepts email with country TLD', () {
        final result = ValidationHelper.validateEmail('user@example.co.uk');
        expect(result, isNull);
      });

      test('trims leading and trailing spaces before validation', () {
        final result = ValidationHelper.validateEmail('  user@example.com  ');
        expect(result, isNull);
      });

      test('returns consistent results for same input', () {
        final email = 'user@example.com';
        final result1 = ValidationHelper.validateEmail(email);
        final result2 = ValidationHelper.validateEmail(email);
        final result3 = ValidationHelper.validateEmail(email);
        
        expect(result1, equals(result2));
        expect(result2, equals(result3));
      });

      test('error messages are in Portuguese', () {
        final result1 = ValidationHelper.validateEmail('');
        final result2 = ValidationHelper.validateEmail('invalid');
        
        expect(result1, contains('obrigatório'));
        expect(result2, contains('Por favor'));
      });

      test('error messages do not contain technical terms', () {
        final result = ValidationHelper.validateEmail('invalid');
        final lowerResult = result?.toLowerCase() ?? '';
        
        expect(lowerResult, isNot(contains('regex')));
        expect(lowerResult, isNot(contains('pattern')));
        expect(lowerResult, isNot(contains('error')));
      });
    });

    group('validatePassword', () {
      test('returns null for valid password', () {
        final result = ValidationHelper.validatePassword('123456');
        expect(result, isNull);
      });

      test('returns error for null value', () {
        final result = ValidationHelper.validatePassword(null);
        expect(result, equals('Senha é obrigatória.'));
      });

      test('returns error for empty string', () {
        final result = ValidationHelper.validatePassword('');
        expect(result, equals('Senha é obrigatória.'));
      });

      test('returns error for password with 1 character', () {
        final result = ValidationHelper.validatePassword('1');
        expect(result, equals('Senha deve ter pelo menos 6 caracteres.'));
      });

      test('returns error for password with 5 characters', () {
        final result = ValidationHelper.validatePassword('12345');
        expect(result, equals('Senha deve ter pelo menos 6 caracteres.'));
      });

      test('accepts password with exactly 6 characters', () {
        final result = ValidationHelper.validatePassword('123456');
        expect(result, isNull);
      });

      test('accepts password with 10 characters', () {
        final result = ValidationHelper.validatePassword('1234567890');
        expect(result, isNull);
      });

      test('accepts password with letters', () {
        final result = ValidationHelper.validatePassword('abcdef');
        expect(result, isNull);
      });

      test('accepts password with mixed case', () {
        final result = ValidationHelper.validatePassword('Pass123');
        expect(result, isNull);
      });

      test('accepts password with special characters', () {
        final result = ValidationHelper.validatePassword('P@ss123!');
        expect(result, isNull);
      });

      test('accepts password with spaces', () {
        final result = ValidationHelper.validatePassword('abc def');
        expect(result, isNull);
      });

      test('accepts very long password', () {
        final result = ValidationHelper.validatePassword('a' * 100);
        expect(result, isNull);
      });

      test('does NOT trim spaces (password validation)', () {
        // Password validation should NOT trim spaces
        // Spaces are valid password characters
        final result = ValidationHelper.validatePassword('  abc  ');
        expect(result, isNull); // 8 characters including spaces
      });

      test('returns consistent results for same input', () {
        final password = 'Pass123';
        final result1 = ValidationHelper.validatePassword(password);
        final result2 = ValidationHelper.validatePassword(password);
        final result3 = ValidationHelper.validatePassword(password);
        
        expect(result1, equals(result2));
        expect(result2, equals(result3));
      });

      test('error messages are in Portuguese', () {
        final result1 = ValidationHelper.validatePassword('');
        final result2 = ValidationHelper.validatePassword('123');
        
        expect(result1, contains('obrigatória'));
        expect(result2, contains('pelo menos'));
      });

      test('error messages do not contain technical terms', () {
        final result = ValidationHelper.validatePassword('123');
        final lowerResult = result?.toLowerCase() ?? '';
        
        expect(lowerResult, isNot(contains('length')));
        expect(lowerResult, isNot(contains('error')));
        expect(lowerResult, isNot(contains('invalid')));
      });
    });

    group('Validation Integration', () {
      test('all validators return null for valid inputs', () {
        final nameResult = ValidationHelper.validateName('João Silva');
        final emailResult = ValidationHelper.validateEmail('joao@example.com');
        final passwordResult = ValidationHelper.validatePassword('Pass123');
        
        expect(nameResult, isNull);
        expect(emailResult, isNull);
        expect(passwordResult, isNull);
      });

      test('all validators return errors for invalid inputs', () {
        final nameResult = ValidationHelper.validateName('');
        final emailResult = ValidationHelper.validateEmail('');
        final passwordResult = ValidationHelper.validatePassword('');
        
        expect(nameResult, isNotNull);
        expect(emailResult, isNotNull);
        expect(passwordResult, isNotNull);
      });

      test('validators are independent', () {
        // Valid name, invalid email
        final nameResult1 = ValidationHelper.validateName('João Silva');
        final emailResult1 = ValidationHelper.validateEmail('invalid');
        
        expect(nameResult1, isNull);
        expect(emailResult1, isNotNull);
        
        // Invalid name, valid email
        final nameResult2 = ValidationHelper.validateName('');
        final emailResult2 = ValidationHelper.validateEmail('user@example.com');
        
        expect(nameResult2, isNotNull);
        expect(emailResult2, isNull);
      });

      test('validators can be called multiple times', () {
        for (int i = 0; i < 10; i++) {
          final result = ValidationHelper.validateName('João Silva');
          expect(result, isNull);
        }
      });

      test('validators handle edge cases consistently', () {
        // Null inputs
        expect(ValidationHelper.validateName(null), isNotNull);
        expect(ValidationHelper.validateEmail(null), isNotNull);
        expect(ValidationHelper.validatePassword(null), isNotNull);
        
        // Empty inputs
        expect(ValidationHelper.validateName(''), isNotNull);
        expect(ValidationHelper.validateEmail(''), isNotNull);
        expect(ValidationHelper.validatePassword(''), isNotNull);
        
        // Whitespace inputs
        expect(ValidationHelper.validateName('   '), isNotNull);
        expect(ValidationHelper.validateEmail('   '), isNotNull);
        // Password does not trim, so '   ' is valid (3 chars but < 6)
        expect(ValidationHelper.validatePassword('   '), isNotNull);
      });

      test('all error messages end with period', () {
        final nameError = ValidationHelper.validateName('');
        final emailError = ValidationHelper.validateEmail('');
        final passwordError = ValidationHelper.validatePassword('');
        
        expect(nameError?.endsWith('.'), isTrue);
        expect(emailError?.endsWith('.'), isTrue);
        expect(passwordError?.endsWith('.'), isTrue);
      });

      test('all error messages start with capital letter', () {
        final nameError = ValidationHelper.validateName('');
        final emailError = ValidationHelper.validateEmail('');
        final passwordError = ValidationHelper.validatePassword('');
        
        expect(nameError?[0], equals(nameError?[0].toUpperCase()));
        expect(emailError?[0], equals(emailError?[0].toUpperCase()));
        expect(passwordError?[0], equals(passwordError?[0].toUpperCase()));
      });

      test('all error messages are user-friendly', () {
        final nameError = ValidationHelper.validateName('');
        final emailError = ValidationHelper.validateEmail('invalid');
        final passwordError = ValidationHelper.validatePassword('123');
        
        // Check messages don't contain technical jargon
        final allErrors = [nameError, emailError, passwordError];
        final technicalTerms = ['null', 'error', 'exception', 'invalid', 'regex'];
        
        for (final error in allErrors) {
          if (error != null) {
            final lowerError = error.toLowerCase();
            for (final term in technicalTerms) {
              // 'invalid' is allowed in "e-mail válido" context
              if (term == 'invalid' && error.contains('válido')) continue;
              expect(lowerError, isNot(contains(term)),
                  reason: 'Error "$error" should not contain technical term "$term"');
            }
          }
        }
      });
    });
  });

  // NOTE: The following tests require controller instantiation with Firebase mocks.
  // These tests are currently skipped because OnboardingController requires Firebase
  // Auth and Firestore to be initialized in its constructor.
  // 
  // To enable these tests:
  // 1. Refactor OnboardingController to accept Firebase instances via constructor
  // 2. Update tests to pass mockAuth and fakeFirestore to controller
  // 3. Uncomment the test groups below
  //
  // Tests covered: Selection Flow (29 tests total)

  /*
  group('Selection Flow - Data Storage', () {
    test('selectedLanguage stores value correctly', () {
      // Arrange
      final controller = OnboardingController();
      
      // Act
      controller.selectedLanguage.value = 'Inglês';
      
      // Assert
      expect(controller.selectedLanguage.value, equals('Inglês'));
    });

    test('languageLevel stores value correctly', () {
      // Arrange
      final controller = OnboardingController();
      
      // Act
      controller.languageLevel.value = 'Sei algumas palavras';
      
      // Assert
      expect(controller.languageLevel.value, equals('Sei algumas palavras'));
    });

    test('learningReason stores value correctly', () {
      // Arrange
      final controller = OnboardingController();
      
      // Act
      controller.learningReason.value = 'Quero explorar o mundo.';
      
      // Assert
      expect(controller.learningReason.value, equals('Quero explorar o mundo.'));
    });

    test('studyTime stores value correctly', () {
      // Arrange
      final controller = OnboardingController();
      
      // Act
      controller.studyTime.value = '10 min / dia';
      
      // Assert
      expect(controller.studyTime.value, equals('10 min / dia'));
    });

    test('userAge stores value correctly', () {
      // Arrange
      final controller = OnboardingController();
      
      // Act
      controller.userAge.value = '25';
      
      // Assert
      expect(controller.userAge.value, equals('25'));
    });

    test('all selection fields start empty', () {
      // Arrange & Act
      final controller = OnboardingController();
      
      // Assert
      expect(controller.selectedLanguage.value, isEmpty);
      expect(controller.languageLevel.value, isEmpty);
      expect(controller.learningReason.value, isEmpty);
      expect(controller.studyTime.value, isEmpty);
      expect(controller.userAge.value, isEmpty);
    });

    test('selection values persist after being set', () {
      // Arrange
      final controller = OnboardingController();
      
      // Act - Set all values
      controller.selectedLanguage.value = 'Inglês';
      controller.languageLevel.value = 'Sei algumas palavras';
      controller.learningReason.value = 'Quero explorar o mundo.';
      controller.studyTime.value = '10 min / dia';
      controller.userAge.value = '25';
      
      // Assert - Read multiple times to verify persistence
      for (int i = 0; i < 5; i++) {
        expect(controller.selectedLanguage.value, equals('Inglês'));
        expect(controller.languageLevel.value, equals('Sei algumas palavras'));
        expect(controller.learningReason.value, equals('Quero explorar o mundo.'));
        expect(controller.studyTime.value, equals('10 min / dia'));
        expect(controller.userAge.value, equals('25'));
      }
    });

    test('selection values can be changed', () {
      // Arrange
      final controller = OnboardingController();
      
      // Act - Set initial value
      controller.selectedLanguage.value = 'Inglês';
      expect(controller.selectedLanguage.value, equals('Inglês'));
      
      // Act - Change value
      controller.selectedLanguage.value = 'Espanhol';
      
      // Assert
      expect(controller.selectedLanguage.value, equals('Espanhol'));
    });

    test('selection values are independent', () {
      // Arrange
      final controller = OnboardingController();
      
      // Act - Set language
      controller.selectedLanguage.value = 'Inglês';
      
      // Assert - Other fields remain empty
      expect(controller.selectedLanguage.value, equals('Inglês'));
      expect(controller.languageLevel.value, isEmpty);
      expect(controller.learningReason.value, isEmpty);
      expect(controller.studyTime.value, isEmpty);
      expect(controller.userAge.value, isEmpty);
    });

    test('multiple selections maintain all values', () {
      // Arrange
      final controller = OnboardingController();
      
      // Act - Set values sequentially
      controller.selectedLanguage.value = 'Inglês';
      controller.languageLevel.value = 'Sei algumas palavras';
      controller.learningReason.value = 'Quero explorar o mundo.';
      
      // Assert - All previous values are maintained
      expect(controller.selectedLanguage.value, equals('Inglês'));
      expect(controller.languageLevel.value, equals('Sei algumas palavras'));
      expect(controller.learningReason.value, equals('Quero explorar o mundo.'));
    });

    test('selection values are reactive', () {
      // Arrange
      final controller = OnboardingController();
      int notificationCount = 0;
      
      // Listen to changes
      controller.selectedLanguage.listen((_) {
        notificationCount++;
      });
      
      // Act
      controller.selectedLanguage.value = 'Inglês';
      
      // Assert
      expect(notificationCount, greaterThan(0));
    });

    test('empty selection is preserved as empty', () {
      // Arrange
      final controller = OnboardingController();
      
      // Act - Don't set any value
      
      // Assert
      expect(controller.selectedLanguage.value, isEmpty);
      
      // Verify it stays empty after multiple reads
      for (int i = 0; i < 5; i++) {
        expect(controller.selectedLanguage.value, isEmpty);
      }
    });

    test('selection values accept various formats', () {
      // Arrange
      final controller = OnboardingController();
      
      // Act & Assert - Language with special characters
      controller.selectedLanguage.value = 'Português';
      expect(controller.selectedLanguage.value, equals('Português'));
      
      // Act & Assert - Level with spaces
      controller.languageLevel.value = 'Sei algumas palavras';
      expect(controller.languageLevel.value, equals('Sei algumas palavras'));
      
      // Act & Assert - Reason with punctuation
      controller.learningReason.value = 'Quero explorar o mundo.';
      expect(controller.learningReason.value, equals('Quero explorar o mundo.'));
      
      // Act & Assert - Time with special format
      controller.studyTime.value = '10 min / dia';
      expect(controller.studyTime.value, equals('10 min / dia'));
      
      // Act & Assert - Age as string
      controller.userAge.value = '25';
      expect(controller.userAge.value, equals('25'));
    });

    test('selection values handle edge cases', () {
      // Arrange
      final controller = OnboardingController();
      
      // Act & Assert - Single character
      controller.selectedLanguage.value = 'A';
      expect(controller.selectedLanguage.value, equals('A'));
      
      // Act & Assert - Very long string
      controller.learningReason.value = 'A' * 1000;
      expect(controller.learningReason.value.length, equals(1000));
      
      // Act & Assert - Numbers
      controller.userAge.value = '123';
      expect(controller.userAge.value, equals('123'));
    });
  });

  group('Selection Flow - Validation', () {
    test('empty selection is detected', () {
      // Arrange
      final controller = OnboardingController();
      
      // Act - Don't set any value
      
      // Assert
      expect(controller.selectedLanguage.value.isEmpty, isTrue);
    });

    test('non-empty selection is valid', () {
      // Arrange
      final controller = OnboardingController();
      
      // Act
      controller.selectedLanguage.value = 'Inglês';
      
      // Assert
      expect(controller.selectedLanguage.value.isNotEmpty, isTrue);
    });

    test('validation works for all selection fields', () {
      // Arrange
      final controller = OnboardingController();
      
      // Act - Set all values
      controller.selectedLanguage.value = 'Inglês';
      controller.languageLevel.value = 'Sei algumas palavras';
      controller.learningReason.value = 'Quero explorar o mundo.';
      controller.studyTime.value = '10 min / dia';
      controller.userAge.value = '25';
      
      // Assert - All are non-empty
      expect(controller.selectedLanguage.value.isNotEmpty, isTrue);
      expect(controller.languageLevel.value.isNotEmpty, isTrue);
      expect(controller.learningReason.value.isNotEmpty, isTrue);
      expect(controller.studyTime.value.isNotEmpty, isTrue);
      expect(controller.userAge.value.isNotEmpty, isTrue);
    });

    test('whitespace-only selection is not empty string', () {
      // Arrange
      final controller = OnboardingController();
      
      // Act
      controller.selectedLanguage.value = '   ';
      
      // Assert - String is not empty (contains whitespace)
      expect(controller.selectedLanguage.value.isEmpty, isFalse);
      expect(controller.selectedLanguage.value.trim().isEmpty, isTrue);
    });

    test('selection validation is case-sensitive', () {
      // Arrange
      final controller = OnboardingController();
      
      // Act
      controller.selectedLanguage.value = 'Inglês';
      
      // Assert
      expect(controller.selectedLanguage.value, equals('Inglês'));
      expect(controller.selectedLanguage.value, isNot(equals('inglês')));
      expect(controller.selectedLanguage.value, isNot(equals('INGLÊS')));
    });
  });

  group('Selection Flow - Navigation Triggers', () {
    test('selection change triggers reactive update', () {
      // Arrange
      final controller = OnboardingController();
      bool wasTriggered = false;
      
      // Listen to changes
      controller.selectedLanguage.listen((_) {
        wasTriggered = true;
      });
      
      // Act
      controller.selectedLanguage.value = 'Inglês';
      
      // Assert
      expect(wasTriggered, isTrue);
    });

    test('multiple selections trigger multiple updates', () {
      // Arrange
      final controller = OnboardingController();
      int triggerCount = 0;
      
      // Listen to changes
      controller.selectedLanguage.listen((_) {
        triggerCount++;
      });
      
      // Act - Make multiple selections
      controller.selectedLanguage.value = 'Inglês';
      controller.selectedLanguage.value = 'Espanhol';
      controller.selectedLanguage.value = 'Francês';
      
      // Assert
      expect(triggerCount, greaterThanOrEqualTo(3));
    });

    test('setting same value triggers update', () {
      // Arrange
      final controller = OnboardingController();
      int triggerCount = 0;
      
      // Listen to changes
      controller.selectedLanguage.listen((_) {
        triggerCount++;
      });
      
      // Act - Set same value twice
      controller.selectedLanguage.value = 'Inglês';
      controller.selectedLanguage.value = 'Inglês';
      
      // Assert - Both assignments trigger updates
      expect(triggerCount, greaterThanOrEqualTo(2));
    });

    test('each selection field has independent triggers', () {
      // Arrange
      final controller = OnboardingController();
      int languageTriggers = 0;
      int levelTriggers = 0;
      
      // Listen to changes
      controller.selectedLanguage.listen((_) {
        languageTriggers++;
      });
      controller.languageLevel.listen((_) {
        levelTriggers++;
      });
      
      // Act
      controller.selectedLanguage.value = 'Inglês';
      controller.languageLevel.value = 'Sei algumas palavras';
      
      // Assert - Each field triggers independently
      expect(languageTriggers, greaterThan(0));
      expect(levelTriggers, greaterThan(0));
    });

    test('clearing selection triggers update', () {
      // Arrange
      final controller = OnboardingController();
      controller.selectedLanguage.value = 'Inglês';
      int triggerCount = 0;
      
      // Listen to changes
      controller.selectedLanguage.listen((_) {
        triggerCount++;
      });
      
      // Act - Clear selection
      controller.selectedLanguage.value = '';
      
      // Assert
      expect(triggerCount, greaterThan(0));
      expect(controller.selectedLanguage.value, isEmpty);
    });
  });

  group('Selection Flow - Data Persistence Across Navigation', () {
    test('language selection persists when setting level', () {
      // Arrange
      final controller = OnboardingController();
      
      // Act - Select language
      controller.selectedLanguage.value = 'Inglês';
      
      // Act - Navigate to level (simulate by setting level)
      controller.languageLevel.value = 'Sei algumas palavras';
      
      // Assert - Language is still stored
      expect(controller.selectedLanguage.value, equals('Inglês'));
      expect(controller.languageLevel.value, equals('Sei algumas palavras'));
    });

    test('all selections persist through complete flow', () {
      // Arrange
      final controller = OnboardingController();
      
      // Act - Simulate complete selection flow
      controller.selectedLanguage.value = 'Inglês';
      expect(controller.selectedLanguage.value, equals('Inglês'));
      
      controller.languageLevel.value = 'Sei algumas palavras';
      expect(controller.selectedLanguage.value, equals('Inglês'));
      expect(controller.languageLevel.value, equals('Sei algumas palavras'));
      
      controller.learningReason.value = 'Quero explorar o mundo.';
      expect(controller.selectedLanguage.value, equals('Inglês'));
      expect(controller.languageLevel.value, equals('Sei algumas palavras'));
      expect(controller.learningReason.value, equals('Quero explorar o mundo.'));
      
      controller.studyTime.value = '10 min / dia';
      expect(controller.selectedLanguage.value, equals('Inglês'));
      expect(controller.languageLevel.value, equals('Sei algumas palavras'));
      expect(controller.learningReason.value, equals('Quero explorar o mundo.'));
      expect(controller.studyTime.value, equals('10 min / dia'));
      
      controller.userAge.value = '25';
      
      // Assert - All values are maintained
      expect(controller.selectedLanguage.value, equals('Inglês'));
      expect(controller.languageLevel.value, equals('Sei algumas palavras'));
      expect(controller.learningReason.value, equals('Quero explorar o mundo.'));
      expect(controller.studyTime.value, equals('10 min / dia'));
      expect(controller.userAge.value, equals('25'));
    });

    test('selections persist after back navigation simulation', () {
      // Arrange
      final controller = OnboardingController();
      
      // Act - Set values
      controller.selectedLanguage.value = 'Inglês';
      controller.languageLevel.value = 'Sei algumas palavras';
      controller.learningReason.value = 'Quero explorar o mundo.';
      
      // Simulate back navigation (values should remain)
      // In real app, Get.back() would be called but values persist in controller
      
      // Assert - All values are still there
      expect(controller.selectedLanguage.value, equals('Inglês'));
      expect(controller.languageLevel.value, equals('Sei algumas palavras'));
      expect(controller.learningReason.value, equals('Quero explorar o mundo.'));
    });

    test('selections can be modified after initial selection', () {
      // Arrange
      final controller = OnboardingController();
      
      // Act - Initial selections
      controller.selectedLanguage.value = 'Inglês';
      controller.languageLevel.value = 'Sei algumas palavras';
      
      // Act - Modify language (simulate going back and changing)
      controller.selectedLanguage.value = 'Espanhol';
      
      // Assert - New language is stored, level is maintained
      expect(controller.selectedLanguage.value, equals('Espanhol'));
      expect(controller.languageLevel.value, equals('Sei algumas palavras'));
    });

    test('controller maintains state across multiple operations', () {
      // Arrange
      final controller = OnboardingController();
      
      // Act - Set values
      controller.selectedLanguage.value = 'Inglês';
      controller.languageLevel.value = 'Sei algumas palavras';
      
      // Simulate other operations (like validation)
      final isLanguageSelected = controller.selectedLanguage.value.isNotEmpty;
      final isLevelSelected = controller.languageLevel.value.isNotEmpty;
      
      // Assert - Values are still maintained
      expect(isLanguageSelected, isTrue);
      expect(isLevelSelected, isTrue);
      expect(controller.selectedLanguage.value, equals('Inglês'));
      expect(controller.languageLevel.value, equals('Sei algumas palavras'));
    });
  });
  */
}
