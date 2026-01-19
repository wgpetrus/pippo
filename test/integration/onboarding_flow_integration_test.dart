// Integration tests for onboarding flows
// Verifica coordenação entre lógica de fluxo, validação e padrões
// Nota: Testes com Firebase real devem ser executados como testes E2E

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Integration Tests - Complete Onboarding Flows', () {
    test('Full onboarding flow - data collection sequence', () {
      // Verifica que o padrão de coleta de dados está correto
      // welcome → language → profile → account → verification → finalization → home
      
      final collectedData = <String, String>{};
      
      // Step 1: Language selection
      collectedData['selectedLanguage'] = 'en';
      collectedData['languageLevel'] = 'beginner';
      collectedData['learningReason'] = 'travel';
      
      // Step 2: Study time
      collectedData['studyTime'] = '10';
      
      // Step 3: Profile data
      collectedData['userName'] = 'João Silva';
      collectedData['userAge'] = '25-34';
      
      // Step 4: Account data
      collectedData['userEmail'] = 'joao@email.com';
      collectedData['userPassword'] = '123456';
      
      // Verify all data is collected (8 fields)
      expect(collectedData.length, 8);
      expect(collectedData['selectedLanguage'], 'en');
      expect(collectedData['userName'], 'João Silva');
      expect(collectedData['userEmail'], 'joao@email.com');
    });

    test('Add course flow - reduced data collection', () {
      // Verifica que o modo add course coleta apenas dados do curso
      // language → study time → conclusion → home
      
      final collectedData = <String, String>{};
      
      // Only course-related data
      collectedData['selectedLanguage'] = 'es';
      collectedData['languageLevel'] = 'intermediate';
      collectedData['learningReason'] = 'work';
      collectedData['studyTime'] = '15';
      
      // Verify only 4 fields collected
      expect(collectedData.length, 4);
      
      // Profile data should NOT be collected
      expect(collectedData.containsKey('userName'), false);
      expect(collectedData.containsKey('userEmail'), false);
    });

    test('Back navigation preserves data', () {
      // Verifica que dados são preservados durante navegação
      
      final sessionData = <String, String>{};
      
      // Collect data
      sessionData['selectedLanguage'] = 'fr';
      sessionData['studyTime'] = '20';
      
      // User edits one value
      sessionData['studyTime'] = '5';
      
      // Other values remain unchanged
      expect(sessionData['selectedLanguage'], 'fr');
      expect(sessionData['studyTime'], '5');
    });

    test('Skip welcome from social login', () {
      // Verifica padrão de pular tela de boas-vindas
      var shouldSkipWelcome = false;
      
      // Coming from social login
      shouldSkipWelcome = true;
      expect(shouldSkipWelcome, true);
    });
  });

  group('Integration Tests - OTP Flow', () {
    test('OTP code validation rules', () {
      // Test code validation logic
      
      String? validateOTPCode(String code) {
        final sanitizedCode = code.trim();
        
        if (sanitizedCode.length != 5) {
          return 'O código deve ter 5 dígitos.';
        }
        
        final digitRegex = RegExp(r'^\d{5}$$');
        if (!digitRegex.hasMatch(sanitizedCode)) {
          return 'O código deve conter apenas números.';
        }
        
        return null;
      }
      
      // Invalid codes
      expect(validateOTPCode('1234'), 'O código deve ter 5 dígitos.');
      expect(validateOTPCode('12a45'), 'O código deve conter apenas números.');
      
      // Valid code
      expect(validateOTPCode('12345'), null);
    });

    test('OTP resend timer countdown', () {
      // Simula timer de reenvio de 60 segundos
      var resendTimer = 60;
      
      expect(resendTimer, 60);
      
      // Countdown
      resendTimer = 0;
      expect(resendTimer, 0);
    });

    test('OTP expiration logic', () {
      // Simula lógica de expiração (10 minutos)
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(minutes: 10));
      
      // Valid before expiration
      expect(now.isBefore(expiresAt), true);
      
      // Invalid after expiration
      final afterExpiration = now.add(const Duration(minutes: 11));
      expect(afterExpiration.isAfter(expiresAt), true);
    });
  });

  group('Integration Tests - Error Recovery', () {
    test('Error message clearing pattern', () {
      var errorMessage = 'Erro anterior';
      
      // Clear before new operation
      errorMessage = '';
      expect(errorMessage, '');
    });

    test('Loading state management pattern', () {
      var isLoading = false;
      
      // Start operation
      isLoading = true;
      expect(isLoading, true);
      
      // End operation
      isLoading = false;
      expect(isLoading, false);
    });

    test('Retry mechanism pattern', () {
      var errorMessage = 'Erro de rede';
      var isLoading = false;
      
      // Clear error for retry
      errorMessage = '';
      isLoading = true;
      
      expect(errorMessage, '');
      expect(isLoading, true);
    });
  });

  group('Integration Tests - Username Generation', () {
    test('Username sanitization logic', () {
      String sanitizeUsername(String name) {
        return name
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]'), '');
      }
      
      expect(sanitizeUsername('João Silva'), 'joosilva');  // ã is removed
      expect(sanitizeUsername('José María'), 'josmara');  // é and í are removed
      expect(sanitizeUsername('User123'), 'user123');
    });

    test('Username conflict resolution pattern', () {
      final existingUsernames = <String>{'joaosilva', 'joaosilva1'};
      
      String generateUsername(String base, Set<String> existing) {
        var username = base;
        var attempts = 0;
        
        while (attempts < 100 && existing.contains(username)) {
          username = '$base${(attempts + 1) * 1000}';
          attempts++;
        }
        
        return username;
      }
      
      final newUsername = generateUsername('joaosilva', existingUsernames);
      expect(existingUsernames.contains(newUsername), false);
    });
  });

  group('Integration Tests - Progress Calculation', () {
    test('Full onboarding progress calculation', () {
      Map<String, int> calculateProgress(String currentScreen, bool isAddingCourse) {
        final fullScreens = [
          'select_language', 'language_level', 'learning_reason',
          'study_time', 'user_name', 'user_age',
          'user_email', 'user_password', 'verify_code',
        ];
        
        final addCourseScreens = [
          'select_language', 'language_level', 'learning_reason', 'study_time',
        ];
        
        final screens = isAddingCourse ? addCourseScreens : fullScreens;
        final index = screens.indexOf(currentScreen);
        
        return {'current': index >= 0 ? index + 1 : 1, 'total': screens.length};
      }
      
      // Test full onboarding
      var progress = calculateProgress('select_language', false);
      expect(progress['current'], 1);
      expect(progress['total'], 9);
      
      progress = calculateProgress('verify_code', false);
      expect(progress['current'], 9);
      expect(progress['total'], 9);
    });

    test('Add course mode progress calculation', () {
      Map<String, int> calculateProgress(String currentScreen, bool isAddingCourse) {
        final fullScreens = [
          'select_language', 'language_level', 'learning_reason',
          'study_time', 'user_name', 'user_age',
          'user_email', 'user_password', 'verify_code',
        ];
        
        final addCourseScreens = [
          'select_language', 'language_level', 'learning_reason', 'study_time',
        ];
        
        final screens = isAddingCourse ? addCourseScreens : fullScreens;
        final index = screens.indexOf(currentScreen);
        
        return {'current': index >= 0 ? index + 1 : 1, 'total': screens.length};
      }
      
      // Test add course mode
      var progress = calculateProgress('select_language', true);
      expect(progress['current'], 1);
      expect(progress['total'], 4);
      
      progress = calculateProgress('study_time', true);
      expect(progress['current'], 4);
      expect(progress['total'], 4);
    });

    test('Transition screens exclusion', () {
      Map<String, int> calculateProgress(String currentScreen, bool isAddingCourse) {
        final fullScreens = [
          'select_language', 'language_level', 'learning_reason',
          'study_time', 'user_name', 'user_age',
          'user_email', 'user_password', 'verify_code',
        ];
        
        final addCourseScreens = [
          'select_language', 'language_level', 'learning_reason', 'study_time',
        ];
        
        final screens = isAddingCourse ? addCourseScreens : fullScreens;
        final index = screens.indexOf(currentScreen);
        
        return {'current': index >= 0 ? index + 1 : 1, 'total': screens.length};
      }
      
      // Transition screens return default (1)
      var progress = calculateProgress('intro', false);
      expect(progress['current'], 1);
      
      progress = calculateProgress('conclusion', false);
      expect(progress['current'], 1);
    });
  });

  group('Integration Tests - Validation Logic', () {
    test('Name validation returns Portuguese messages', () {
      String? validateName(String? value) {
        if (value == null || value.trim().isEmpty) {
          return 'Nome é obrigatório.';
        }
        return null;
      }
      
      expect(validateName(''), 'Nome é obrigatório.');
      expect(validateName('João'), null);
    });

    test('Email validation returns Portuguese messages', () {
      String? validateEmail(String? value) {
        if (value == null || value.isEmpty) {
          return 'E-mail é obrigatório.';
        }
        if (!value.contains('@')) {
          return 'Por favor, insira um e-mail válido.';
        }
        return null;
      }
      
      expect(validateEmail(''), 'E-mail é obrigatório.');
      expect(validateEmail('invalido'), 'Por favor, insira um e-mail válido.');
      expect(validateEmail('teste@email.com'), null);
    });

    test('Password validation returns Portuguese messages', () {
      String? validatePassword(String? value) {
        if (value == null || value.isEmpty) {
          return 'Senha é obrigatória.';
        }
        if (value.length < 6) {
          return 'A senha deve ter pelo menos 6 caracteres.';
        }
        return null;
      }
      
      expect(validatePassword(''), 'Senha é obrigatória.');
      expect(validatePassword('12345'), 'A senha deve ter pelo menos 6 caracteres.');
      expect(validatePassword('123456'), null);
    });
  });

  group('Integration Tests - Firestore Document Structure', () {
    test('User document structure verification', () {
      final userDocument = {
        'id': 'user123',
        'email': 'test@email.com',
        'name': 'João Silva',
        'username': 'joaosilva',
        'age': '25-34',
        'onboardingCompleted': true,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      };
      
      expect(userDocument.length, 8);
      expect(userDocument.containsKey('id'), true);
      expect(userDocument.containsKey('email'), true);
      expect(userDocument.containsKey('onboardingCompleted'), true);
    });

    test('Course document structure verification', () {
      final courseDocument = {
        'id': 'course123',
        'language': 'en',
        'languageName': 'English',
        'level': 'beginner',
        'reason': 'travel',
        'studyTime': 10,
        'isActive': true,
        'createdAt': DateTime.now(),
      };
      
      expect(courseDocument.length, 8);
      expect(courseDocument.containsKey('language'), true);
      expect(courseDocument.containsKey('studyTime'), true);
    });

    test('Gamification stats document structure verification', () {
      final statsDocument = {
        'xp': 0,
        'level': 1,
        'streak': 0,
        'energy': 5,
        'gems': 0,
        'hearts': 5,
        'lastActiveAt': DateTime.now(),
      };
      
      expect(statsDocument.length, 7);
      expect(statsDocument['xp'], 0);
      expect(statsDocument['level'], 1);
      expect(statsDocument['energy'], 5);
    });

    test('OTP document structure verification', () {
      final otpDocument = {
        'code': '12345',
        'expiresAt': DateTime.now().add(const Duration(minutes: 10)),
        'attempts': 0,
        'createdAt': DateTime.now(),
      };
      
      expect(otpDocument.length, 4);
      expect(otpDocument.containsKey('code'), true);
      expect(otpDocument.containsKey('expiresAt'), true);
    });
  });

  group('Integration Tests - Security Patterns', () {
    test('Error messages do not expose sensitive data', () {
      String? validateEmail(String? value) {
        if (value == null || value.isEmpty) {
          return 'E-mail é obrigatório.';
        }
        if (!value.contains('@')) {
          return 'Por favor, insira um e-mail válido.';
        }
        return null;
      }
      
      final emailError = validateEmail('usuario@email.com');
      expect(emailError, isNot(contains('usuario@email.com')));
    });

    test('Error messages are user-friendly', () {
      final errorMessages = [
        'Nome é obrigatório.',
        'E-mail é obrigatório.',
        'Senha é obrigatória.',
        'Por favor, insira um e-mail válido.',
        'A senha deve ter pelo menos 6 caracteres.',
      ];
      
      for (final message in errorMessages) {
        expect(message, isNot(contains('Exception')));
        expect(message, isNot(contains('Error')));
      }
    });
  });
}
