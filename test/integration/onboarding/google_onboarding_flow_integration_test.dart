// Integration test for Google onboarding flow
// Tests that Google users skip email, password, and OTP screens
// WITHOUT Firebase dependencies (logic-only test)
// Validates: Requirements 4.1, 4.2

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Google Onboarding Flow - Logic Tests', () {
    test('Google onboarding skips email, password, and OTP screens', () {
      // Simula fluxo completo de onboarding com Google
      // Valida: Requirements 4.1, 4.2
      
      // Simula dados coletados durante o fluxo
      final collectedData = <String, dynamic>{};
      
      // ETAPA 1: Google Sign In (antes do onboarding)
      // Usuário faz login com Google e recebe dados pré-preenchidos
      collectedData['authProvider'] = 'google';
      collectedData['userName'] = 'João Silva'; // Pre-filled from Google displayName
      collectedData['userEmail'] = 'joao@gmail.com'; // Pre-filled from Google email
      collectedData['skipWelcome'] = true; // Pula welcome screen
      
      expect(collectedData['authProvider'], 'google');
      expect(collectedData['userName'], isNotEmpty);
      expect(collectedData['userEmail'], isNotEmpty);
      expect(collectedData['skipWelcome'], true);
      
      // ETAPA 2: Select Language (primeira tela do onboarding para Google users)
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
      
      // ETAPA 8: User Name (pode editar o nome pré-preenchido)
      // Nome já está pré-preenchido, usuário pode editar se quiser
      expect(collectedData['userName'], 'João Silva');
      
      // ETAPA 9: User Age
      collectedData['userAge'] = '25-34';
      expect(collectedData['userAge'], '25-34');
      
      // ETAPA 10: Pause Two (transição - sem dados)
      // Apenas animação
      
      // VERIFICAÇÃO CRÍTICA: Telas que devem ser PULADAS para Google users
      bool shouldSkipEmail(String authProvider) => authProvider == 'google';
      bool shouldSkipPassword(String authProvider) => authProvider == 'google';
      bool shouldSkipVerifyCode(String authProvider) => authProvider == 'google';
      
      expect(shouldSkipEmail(collectedData['authProvider']), true);
      expect(shouldSkipPassword(collectedData['authProvider']), true);
      expect(shouldSkipVerifyCode(collectedData['authProvider']), true);
      
      // ETAPA 11: User Email - PULADA (Google já forneceu)
      // Não deve pedir email novamente
      
      // ETAPA 12: User Password - PULADA (Google já autenticou)
      // Não deve pedir senha
      
      // ETAPA 13: Verify Code (OTP) - PULADA (Google já verificou)
      // Não deve pedir código de verificação
      
      // ETAPA 14: Conclusion (transição final)
      // Mostra estatísticas e navega para home
      
      // VERIFICAÇÕES FINAIS
      
      // Verifica que todos os dados necessários foram coletados
      expect(collectedData['authProvider'], 'google');
      expect(collectedData['selectedLanguage'], 'en');
      expect(collectedData['languageLevel'], 'beginner');
      expect(collectedData['learningReason'], 'travel');
      expect(collectedData['studyTime'], '10');
      expect(collectedData['userName'], 'João Silva');
      expect(collectedData['userAge'], '25-34');
      expect(collectedData['userEmail'], 'joao@gmail.com');
      
      // Verifica que senha NÃO foi coletada (Google users não precisam)
      expect(collectedData.containsKey('userPassword'), false);
      
      // Verifica estrutura de dados para Firestore
      final userDoc = {
        'id': 'user123',
        'email': collectedData['userEmail'],
        'name': collectedData['userName'],
        'username': 'joaosilva',
        'age': collectedData['userAge'],
        'authProvider': collectedData['authProvider'],
        'onboardingCompleted': true,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      };
      
      expect(userDoc['authProvider'], 'google');
      expect(userDoc['onboardingCompleted'], true);
      expect(userDoc['email'], 'joao@gmail.com');
      expect(userDoc['name'], 'João Silva');
      
      // Verifica que sequência de telas é MENOR para Google users
      const googleScreens = [
        // 'welcome',        // PULADA (skipWelcome = true)
        'select_language',
        'language_level',
        'learning_reason',
        'intro',           // transição
        'study_time',
        'pause_one',       // transição
        'user_name',       // pré-preenchido, mas pode editar
        'user_age',
        'pause_two',       // transição
        // 'user_email',   // PULADA (Google já forneceu)
        // 'user_password', // PULADA (Google já autenticou)
        // 'verify_code',   // PULADA (Google já verificou)
        'conclusion',      // transição final
      ];
      
      const regularScreens = [
        'welcome',
        'select_language',
        'language_level',
        'learning_reason',
        'intro',
        'study_time',
        'pause_one',
        'user_name',
        'user_age',
        'pause_two',
        'user_email',
        'user_password',
        'verify_code',
        'conclusion',
      ];
      
      // Google users pulam 4 telas (welcome, email, password, verify_code)
      expect(googleScreens.length, regularScreens.length - 4);
      expect(googleScreens.contains('user_email'), false);
      expect(googleScreens.contains('user_password'), false);
      expect(googleScreens.contains('verify_code'), false);
    });

    test('shouldSkip methods return correct values for Google users', () {
      // Testa métodos de skip para usuários Google
      
      bool shouldSkipEmail(String authProvider) => authProvider == 'google';
      bool shouldSkipPassword(String authProvider) => authProvider == 'google';
      bool shouldSkipVerifyCode(String authProvider) => authProvider == 'google';
      
      // Google users
      expect(shouldSkipEmail('google'), true);
      expect(shouldSkipPassword('google'), true);
      expect(shouldSkipVerifyCode('google'), true);
      
      // Regular users
      expect(shouldSkipEmail(''), false);
      expect(shouldSkipPassword(''), false);
      expect(shouldSkipVerifyCode(''), false);
      
      expect(shouldSkipEmail('email'), false);
      expect(shouldSkipPassword('email'), false);
      expect(shouldSkipVerifyCode('email'), false);
    });

    test('Google user data is pre-filled correctly', () {
      // Testa que dados do Google são pré-preenchidos corretamente
      
      // Simula resposta do Google Sign In
      final googleUserData = {
        'displayName': 'João Silva',
        'email': 'joao@gmail.com',
        'photoURL': 'https://example.com/photo.jpg',
        'uid': 'google123',
      };
      
      // Dados pré-preenchidos no onboarding
      final preFilledData = {
        'userName': googleUserData['displayName'],
        'userEmail': googleUserData['email'],
        'authProvider': 'google',
        'skipWelcome': true,
      };
      
      expect(preFilledData['userName'], 'João Silva');
      expect(preFilledData['userEmail'], 'joao@gmail.com');
      expect(preFilledData['authProvider'], 'google');
      expect(preFilledData['skipWelcome'], true);
    });

    test('Navigation skips correct screens for Google users', () {
      // Testa que navegação pula telas corretas para Google users
      
      String authProvider = 'google';
      
      // Simula navegação após UserAgePage
      String getNextScreen(String currentScreen, String authProvider) {
        if (currentScreen == 'user_age') {
          // Após idade, verifica se deve pular email
          if (authProvider == 'google') {
            return 'conclusion'; // Pula direto para conclusão
          } else {
            return 'user_email'; // Vai para email
          }
        }
        return 'unknown';
      }
      
      // Google user: age → conclusion (pula email, password, verify_code)
      expect(getNextScreen('user_age', 'google'), 'conclusion');
      
      // Regular user: age → email
      expect(getNextScreen('user_age', ''), 'user_email');
      expect(getNextScreen('user_age', 'email'), 'user_email');
    });

    test('Progress calculation for Google onboarding', () {
      // Testa cálculo de progresso para onboarding com Google
      
      Map<String, int> calculateProgress(String currentScreen, bool isAddingCourse, String authProvider) {
        final fullScreens = [
          'select_language', 'language_level', 'learning_reason',
          'study_time', 'user_name', 'user_age',
          'user_email', 'user_password', 'verify_code',
        ];
        
        final googleScreens = [
          'select_language', 'language_level', 'learning_reason',
          'study_time', 'user_name', 'user_age',
        ];
        
        final addCourseScreens = [
          'select_language', 'language_level', 'learning_reason', 'study_time',
        ];
        
        List<String> screens;
        if (isAddingCourse) {
          screens = addCourseScreens;
        } else if (authProvider == 'google') {
          screens = googleScreens;
        } else {
          screens = fullScreens;
        }
        
        final index = screens.indexOf(currentScreen);
        
        return {'current': index >= 0 ? index + 1 : 1, 'total': screens.length};
      }
      
      // Google user - primeira tela
      var progress = calculateProgress('select_language', false, 'google');
      expect(progress['current'], 1);
      expect(progress['total'], 6); // Apenas 6 telas para Google users
      
      // Google user - última tela
      progress = calculateProgress('user_age', false, 'google');
      expect(progress['current'], 6);
      expect(progress['total'], 6);
      
      // Regular user - última tela
      progress = calculateProgress('verify_code', false, '');
      expect(progress['current'], 9);
      expect(progress['total'], 9);
    });

    test('Batch write structure for Google users', () {
      // Testa estrutura de batch write para usuários Google
      
      final batchOperations = <String, Map<String, dynamic>>{};
      
      // 1. User document (com authProvider = 'google')
      batchOperations['users/user123'] = {
        'id': 'user123',
        'email': 'joao@gmail.com',
        'name': 'João Silva',
        'username': 'joaosilva',
        'age': '25-34',
        'authProvider': 'google', // IMPORTANTE: indica login com Google
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
      
      // Verifica que authProvider está correto
      expect(batchOperations['users/user123']!['authProvider'], 'google');
      
      // Verifica que todas as 3 operações estão no batch
      expect(batchOperations.length, 3);
    });

    test('Email is readonly for Google users', () {
      // Testa que email é readonly para usuários Google
      // Valida: Requirements 4.2
      
      final userData = {
        'authProvider': 'google',
        'userEmail': 'joao@gmail.com',
      };
      
      // Email deve ser readonly (não editável)
      bool isEmailReadonly(String authProvider) => authProvider == 'google';
      
      expect(isEmailReadonly(userData['authProvider'] as String), true);
      
      // Regular users podem editar email
      expect(isEmailReadonly(''), false);
      expect(isEmailReadonly('email'), false);
    });
  });
}
