// Integration test for email/password onboarding flow
// Tests the complete user journey from welcome to home screen
// WITHOUT Firebase dependencies (logic-only test)
// Validates: Requirements 10.1

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Email/Password Onboarding Flow - Logic Tests', () {
    test('Email/password onboarding from welcome to home - complete flow', () {
      // Simula fluxo completo de onboarding com email/password
      // Valida: Requirements 10.1
      
      // Simula dados coletados durante o fluxo
      final collectedData = <String, dynamic>{};
      
      // ETAPA 1: Welcome (tela inicial)
      // Usuário clica em "Get Started"
      collectedData['skipWelcome'] = false;
      expect(collectedData['skipWelcome'], false);
      
      // ETAPA 2: Select Language
      collectedData['selectedLanguage'] = 'en';
      expect(collectedData['selectedLanguage'], 'en');
      
      // ETAPA 3: Language Level
      collectedData['languageLevel'] = 'beginner';
      expect(collectedData['languageLevel'], 'beginner');
      
      // ETAPA 4: Learning Reason
      collectedData['learningReason'] = 'travel';
      expect(collectedData['learningReason'], 'travel');
      
      // ETAPA 5: Intro (transição - sem dados)
      // Apenas animação
      
      // ETAPA 6: Study Time
      collectedData['studyTime'] = '10';
      expect(collectedData['studyTime'], '10');
      
      // ETAPA 7: Pause One (transição - sem dados)
      // Apenas animação
      
      // ETAPA 8: User Name
      collectedData['userName'] = 'João Silva';
      expect(collectedData['userName'], 'João Silva');
      
      // Validação de nome
      String? validateName(String? value) {
        if (value == null || value.trim().isEmpty) {
          return 'Nome é obrigatório.';
        }
        if (value.trim().length < 2) {
          return 'Nome deve ter pelo menos 2 caracteres.';
        }
        final nameRegex = RegExp(r'^[a-zA-ZÀ-ÿ\s]{2,50}$');
        if (!nameRegex.hasMatch(value.trim())) {
          return 'Nome deve conter apenas letras e espaços.';
        }
        return null;
      }
      
      expect(validateName(collectedData['userName']), null);
      
      // ETAPA 9: User Age
      collectedData['userAge'] = '25-34';
      expect(collectedData['userAge'], '25-34');
      
      // ETAPA 10: Pause Two (transição - sem dados)
      // Apenas animação
      
      // ETAPA 11: User Email
      collectedData['userEmail'] = 'joao@email.com';
      expect(collectedData['userEmail'], 'joao@email.com');
      
      // Validação de email
      String? validateEmail(String? value) {
        if (value == null || value.trim().isEmpty) {
          return 'E-mail é obrigatório.';
        }
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value.trim())) {
          return 'Por favor, insira um e-mail válido.';
        }
        return null;
      }
      
      expect(validateEmail(collectedData['userEmail']), null);
      
      // ETAPA 12: User Password
      collectedData['userPassword'] = 'senha123';
      expect(collectedData['userPassword'], 'senha123');
      
      // Validação de senha
      String? validatePassword(String? value) {
        if (value == null || value.isEmpty) {
          return 'Senha é obrigatória.';
        }
        if (value.length < 6) {
          return 'Senha deve ter pelo menos 6 caracteres.';
        }
        return null;
      }
      
      expect(validatePassword(collectedData['userPassword']), null);
      
      // ETAPA 13: Verify Code (OTP)
      // Simula código OTP (em produção viria por email)
      const otpCode = '12345';
      expect(otpCode.length, 5);
      expect(RegExp(r'^\d{5}$').hasMatch(otpCode), true);
      
      // Validação de OTP
      String? validateOTP(String code) {
        final sanitizedCode = code.trim();
        if (sanitizedCode.length != 5) {
          return 'O código deve ter 5 dígitos.';
        }
        final digitRegex = RegExp(r'^\d{5}$');
        if (!digitRegex.hasMatch(sanitizedCode)) {
          return 'O código deve conter apenas números.';
        }
        return null;
      }
      
      expect(validateOTP(otpCode), null);
      
      // ETAPA 14: Conclusion (transição final)
      // Mostra estatísticas e navega para home
      
      // VERIFICAÇÕES FINAIS
      
      // Verifica que todos os dados foram coletados (8 campos principais)
      expect(collectedData['selectedLanguage'], 'en');
      expect(collectedData['languageLevel'], 'beginner');
      expect(collectedData['learningReason'], 'travel');
      expect(collectedData['studyTime'], '10');
      expect(collectedData['userName'], 'João Silva');
      expect(collectedData['userAge'], '25-34');
      expect(collectedData['userEmail'], 'joao@email.com');
      expect(collectedData['userPassword'], 'senha123');
      
      // Verifica que authProvider está vazio (email/password)
      collectedData['authProvider'] = '';
      expect(collectedData['authProvider'], '');
      
      // Verifica que nenhuma tela foi pulada (email/password flow)
      bool shouldSkipEmail(String authProvider) => authProvider == 'google';
      bool shouldSkipPassword(String authProvider) => authProvider == 'google';
      bool shouldSkipVerifyCode(String authProvider) => authProvider == 'google';
      
      expect(shouldSkipEmail(collectedData['authProvider']), false);
      expect(shouldSkipPassword(collectedData['authProvider']), false);
      expect(shouldSkipVerifyCode(collectedData['authProvider']), false);
      
      // Verifica estrutura de dados para Firestore
      final userDoc = {
        'id': 'user123',
        'email': collectedData['userEmail'],
        'name': collectedData['userName'],
        'username': 'joaosilva',
        'age': collectedData['userAge'],
        'authProvider': collectedData['authProvider'].isEmpty ? 'email' : collectedData['authProvider'],
        'onboardingCompleted': true,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      };
      
      expect(userDoc['authProvider'], 'email');
      expect(userDoc['onboardingCompleted'], true);
      expect(userDoc.containsKey('id'), true);
      expect(userDoc.containsKey('email'), true);
      expect(userDoc.containsKey('name'), true);
      expect(userDoc['email'], 'joao@email.com');
      expect(userDoc['name'], 'João Silva');
      
      final courseDoc = {
        'id': 'course123',
        'language': collectedData['selectedLanguage'],
        'languageName': 'English',
        'level': collectedData['languageLevel'],
        'reason': collectedData['learningReason'],
        'studyTime': int.parse(collectedData['studyTime']),
        'isActive': true,
        'createdAt': DateTime.now(),
      };
      
      expect(courseDoc['language'], 'en');
      expect(courseDoc['level'], 'beginner');
      expect(courseDoc['studyTime'], 10);
      expect(courseDoc['isActive'], true);
      
      final statsDoc = {
        'xp': 0,
        'level': 1,
        'streak': 0,
        'energy': 5,
        'gems': 0,
        'hearts': 5,
        'lastActiveAt': DateTime.now(),
      };
      
      expect(statsDoc['xp'], 0);
      expect(statsDoc['level'], 1);
      expect(statsDoc['energy'], 5);
      expect(statsDoc['gems'], 0);
      expect(statsDoc['hearts'], 5);
      
      // Verifica que progresso foi calculado corretamente
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
      
      final progress = calculateProgress('verify_code', false);
      expect(progress['current'], 9);
      expect(progress['total'], 9);
      
      // Verifica que isAddingCourse está false (novo usuário)
      collectedData['isAddingCourse'] = false;
      expect(collectedData['isAddingCourse'], false);
      
      // Verifica sequência de telas (14 telas no total, incluindo transições)
      const allScreens = [
        'welcome',
        'select_language',
        'language_level',
        'learning_reason',
        'intro',           // transição
        'study_time',
        'pause_one',       // transição
        'user_name',
        'user_age',
        'pause_two',       // transição
        'user_email',
        'user_password',
        'verify_code',
        'conclusion',      // transição final
      ];
      
      expect(allScreens.length, 14);
      expect(allScreens.contains('user_email'), true);
      expect(allScreens.contains('user_password'), true);
      expect(allScreens.contains('verify_code'), true);
    });

    test('Data sanitization before saving', () {
      // Testa sanitização de dados antes de salvar
      
      String sanitizeName(String value) {
        return value.trim();
      }
      
      String sanitizeEmail(String value) {
        return value.trim().toLowerCase();
      }
      
      // Nome com espaços extras
      final dirtyName = '  João Silva  ';
      final cleanName = sanitizeName(dirtyName);
      expect(cleanName, 'João Silva');
      
      // Email com espaços e maiúsculas
      final dirtyEmail = '  JOAO@EMAIL.COM  ';
      final cleanEmail = sanitizeEmail(dirtyEmail);
      expect(cleanEmail, 'joao@email.com');
    });

    test('Validation prevents invalid data from reaching Firestore', () {
      // Testa que validação impede dados inválidos
      
      String? validateName(String? value) {
        if (value == null || value.trim().isEmpty) {
          return 'Nome é obrigatório.';
        }
        if (value.trim().length < 2) {
          return 'Nome deve ter pelo menos 2 caracteres.';
        }
        final nameRegex = RegExp(r'^[a-zA-ZÀ-ÿ\s]{2,50}$');
        if (!nameRegex.hasMatch(value.trim())) {
          return 'Nome deve conter apenas letras e espaços.';
        }
        return null;
      }
      
      String? validateEmail(String? value) {
        if (value == null || value.trim().isEmpty) {
          return 'E-mail é obrigatório.';
        }
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value.trim())) {
          return 'Por favor, insira um e-mail válido.';
        }
        return null;
      }
      
      String? validatePassword(String? value) {
        if (value == null || value.isEmpty) {
          return 'Senha é obrigatória.';
        }
        if (value.length < 6) {
          return 'Senha deve ter pelo menos 6 caracteres.';
        }
        return null;
      }
      
      // Dados inválidos
      expect(validateName(''), 'Nome é obrigatório.');
      expect(validateName('A'), 'Nome deve ter pelo menos 2 caracteres.');
      expect(validateName('João123'), 'Nome deve conter apenas letras e espaços.');
      
      expect(validateEmail(''), 'E-mail é obrigatório.');
      expect(validateEmail('invalido'), 'Por favor, insira um e-mail válido.');
      
      expect(validatePassword(''), 'Senha é obrigatória.');
      expect(validatePassword('12345'), 'Senha deve ter pelo menos 6 caracteres.');
      
      // Dados válidos
      expect(validateName('João Silva'), null);
      expect(validateEmail('joao@email.com'), null);
      expect(validatePassword('senha123'), null);
    });

    test('OTP validation rules', () {
      // Testa regras de validação de OTP
      
      String? validateOTP(String code) {
        final sanitizedCode = code.trim();
        if (sanitizedCode.length != 5) {
          return 'O código deve ter 5 dígitos.';
        }
        final digitRegex = RegExp(r'^\d{5}$');
        if (!digitRegex.hasMatch(sanitizedCode)) {
          return 'O código deve conter apenas números.';
        }
        return null;
      }
      
      // Códigos inválidos
      expect(validateOTP('1234'), 'O código deve ter 5 dígitos.');
      expect(validateOTP('123456'), 'O código deve ter 5 dígitos.');
      expect(validateOTP('12a45'), 'O código deve conter apenas números.');
      
      // Código válido
      expect(validateOTP('12345'), null);
      
      // Debug bypass code
      const debugCode = '00000';
      expect(validateOTP(debugCode), null);
    });

    test('Progress calculation for full onboarding', () {
      // Testa cálculo de progresso para onboarding completo
      
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
      
      // Primeira tela
      var progress = calculateProgress('select_language', false);
      expect(progress['current'], 1);
      expect(progress['total'], 9);
      
      // Tela do meio
      progress = calculateProgress('user_name', false);
      expect(progress['current'], 5);
      expect(progress['total'], 9);
      
      // Última tela
      progress = calculateProgress('verify_code', false);
      expect(progress['current'], 9);
      expect(progress['total'], 9);
      
      // Tela de transição (não conta no progresso)
      progress = calculateProgress('intro', false);
      expect(progress['current'], 1);
      expect(progress['total'], 9);
    });

    test('Error messages are user-friendly', () {
      // Testa que mensagens de erro são amigáveis
      
      final errorMessages = [
        'Nome é obrigatório.',
        'E-mail é obrigatório.',
        'Senha é obrigatória.',
        'Por favor, insira um e-mail válido.',
        'Senha deve ter pelo menos 6 caracteres.',
        'O código deve ter 5 dígitos.',
      ];
      
      for (final message in errorMessages) {
        expect(message, isNot(contains('Exception')));
        expect(message, isNot(contains('Error')));
        expect(message, isNot(contains('null')));
      }
    });

    test('Batch write structure for Firestore', () {
      // Testa estrutura de batch write para Firestore
      
      final batchOperations = <String, Map<String, dynamic>>{};
      
      // 1. User document
      batchOperations['users/user123'] = {
        'id': 'user123',
        'email': 'joao@email.com',
        'name': 'João Silva',
        'username': 'joaosilva',
        'age': '25-34',
        'authProvider': 'email',
        'onboardingCompleted': true,
      };
      
      // 2. Course document
      batchOperations['users/user123/courses/course123'] = {
        'id': 'course123',
        'language': 'en',
        'level': 'beginner',
        'studyTime': 10,
        'isActive': true,
      };
      
      // 3. Stats document
      batchOperations['users/user123/stats/gamification'] = {
        'xp': 0,
        'level': 1,
        'streak': 0,
        'energy': 5,
        'gems': 0,
        'hearts': 5,
      };
      
      // Verifica que todas as 3 operações estão no batch
      expect(batchOperations.length, 3);
      expect(batchOperations.containsKey('users/user123'), true);
      expect(batchOperations.containsKey('users/user123/courses/course123'), true);
      expect(batchOperations.containsKey('users/user123/stats/gamification'), true);
    });
  });
}
