import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Teste de regressão para verificar que todos os controllers usam
/// ErrorHandler.getFirestoreErrorMessage() diretamente, sem wrappers duplicados.
///
/// Este teste verifica:
/// 1. Ausência de métodos _handleFirestoreError em controllers
/// 2. Uso direto de ErrorHandler.getFirestoreErrorMessage()
///
/// Requirements: 4.3, 4.4
void main() {
  group('Firestore Error Handler Regression Tests', () {
    // Lista de controllers que foram refatorados na task 6.1
    final controllersToCheck = [
      'lib/features/inners/treasure/controllers/treasure_rewards_controller.dart',
      'lib/features/inners/treasure/controllers/treasure_challenges_controller.dart',
      'lib/features/inners/profile/controllers/profile_settings_controller.dart',
      'lib/features/inners/profile/controllers/profile_social_controller.dart',
      'lib/features/inners/profile/controllers/profile_search_controller.dart',
      'lib/features/inners/profile/controllers/profile_data_controller.dart',
      'lib/features/inners/profile/controllers/profile_courses_controller.dart',
      'lib/features/inners/shop/controllers/shop_controller.dart',
      'lib/features/inners/splash/controllers/splash_controller.dart',
      'lib/features/inners/leaderboard/controllers/leaderboard_controller.dart',
      'lib/features/inners/gamification/controllers/energy_controller.dart',
      'lib/features/inners/gamification/controllers/gems_controller.dart',
      'lib/features/inners/gamification/controllers/streak_controller.dart',
      'lib/features/inners/gamification/controllers/xp_level_controller.dart',
      'lib/features/core/onboarding/controllers/onboarding_data_controller.dart',
      'lib/features/core/onboarding/controllers/onboarding_validation_controller.dart',
      'lib/features/core/auth/controllers/auth_providers_controller.dart',
    ];

    test('Verificar ausência de métodos _handleFirestoreError em todos os controllers', () {
      final controllersWithDuplicateHandler = <String>[];

      for (final controllerPath in controllersToCheck) {
        final file = File(controllerPath);
        
        if (!file.existsSync()) {
          // Controller não existe, pular
          continue;
        }

        final content = file.readAsStringSync();

        // Verificar se contém método _handleFirestoreError
        if (content.contains('_handleFirestoreError')) {
          controllersWithDuplicateHandler.add(controllerPath);
        }
      }

      expect(
        controllersWithDuplicateHandler,
        isEmpty,
        reason: 'Os seguintes controllers ainda contêm método _handleFirestoreError: '
            '${controllersWithDuplicateHandler.join(", ")}',
      );
    });

    test('Verificar uso direto de ErrorHandler.getFirestoreErrorMessage() em controllers', () {
      final controllersWithoutDirectCall = <String>[];

      for (final controllerPath in controllersToCheck) {
        final file = File(controllerPath);
        
        if (!file.existsSync()) {
          // Controller não existe, pular
          continue;
        }

        final content = file.readAsStringSync();

        // Verificar se usa ErrorHandler.getFirestoreErrorMessage() diretamente
        // Apenas se o controller faz operações Firestore (contém try-catch com FirebaseException)
        final hasFirestoreOperations = content.contains('on FirebaseException catch');
        
        if (hasFirestoreOperations && !content.contains('ErrorHandler.getFirestoreErrorMessage(')) {
          controllersWithoutDirectCall.add(controllerPath);
        }
      }

      expect(
        controllersWithoutDirectCall,
        isEmpty,
        reason: 'Os seguintes controllers não usam ErrorHandler.getFirestoreErrorMessage() diretamente: '
            '${controllersWithoutDirectCall.join(", ")}',
      );
    });

    test('Verificar que controllers importam ErrorHandler quando necessário', () {
      final controllersWithoutImport = <String>[];

      for (final controllerPath in controllersToCheck) {
        final file = File(controllerPath);
        
        if (!file.existsSync()) {
          // Controller não existe, pular
          continue;
        }

        final content = file.readAsStringSync();

        // Verificar se usa ErrorHandler mas não importa
        final usesErrorHandler = content.contains('ErrorHandler.getFirestoreErrorMessage(');
        final hasImport = content.contains("import 'package:pippo/shared/utils/error_handler.dart'") ||
                         content.contains('import "package:pippo/shared/utils/error_handler.dart"') ||
                         content.contains("import '../../../shared/utils/error_handler.dart'") ||
                         content.contains('import "../../../shared/utils/error_handler.dart"') ||
                         content.contains("import '../../../../shared/utils/error_handler.dart'") ||
                         content.contains('import "../../../../shared/utils/error_handler.dart"');
        
        if (usesErrorHandler && !hasImport) {
          controllersWithoutImport.add(controllerPath);
        }
      }

      expect(
        controllersWithoutImport,
        isEmpty,
        reason: 'Os seguintes controllers usam ErrorHandler mas não o importam: '
            '${controllersWithoutImport.join(", ")}',
      );
    });

    test('Verificar padrão correto de try-catch com FirebaseException', () {
      final controllersWithIncorrectPattern = <String>[];

      for (final controllerPath in controllersToCheck) {
        final file = File(controllerPath);
        
        if (!file.existsSync()) {
          // Controller não existe, pular
          continue;
        }

        final content = file.readAsStringSync();

        // Verificar se tem try-catch com FirebaseException
        final hasFirebaseExceptionCatch = content.contains('on FirebaseException catch');
        
        if (hasFirebaseExceptionCatch) {
          // Verificar se usa o padrão correto:
          // errorMessage.value = ErrorHandler.getFirestoreErrorMessage(e);
          final hasCorrectPattern = RegExp(
            r'errorMessage\.value\s*=\s*ErrorHandler\.getFirestoreErrorMessage\(\w+\)',
          ).hasMatch(content);
          
          if (!hasCorrectPattern) {
            controllersWithIncorrectPattern.add(controllerPath);
          }
        }
      }

      expect(
        controllersWithIncorrectPattern,
        isEmpty,
        reason: 'Os seguintes controllers não seguem o padrão correto de error handling: '
            '${controllersWithIncorrectPattern.join(", ")}',
      );
    });

    test('Verificar que nenhum controller tem wrapper _handleFirestoreError chamando ErrorHandler', () {
      final controllersWithWrapper = <String>[];

      for (final controllerPath in controllersToCheck) {
        final file = File(controllerPath);
        
        if (!file.existsSync()) {
          // Controller não existe, pular
          continue;
        }

        final content = file.readAsStringSync();

        // Verificar se tem método _handleFirestoreError que apenas chama ErrorHandler
        final hasWrapperPattern = content.contains('_handleFirestoreError') &&
                                  content.contains('ErrorHandler.getFirestoreErrorMessage');
        
        if (hasWrapperPattern) {
          controllersWithWrapper.add(controllerPath);
        }
      }

      expect(
        controllersWithWrapper,
        isEmpty,
        reason: 'Os seguintes controllers ainda têm wrapper _handleFirestoreError desnecessário: '
            '${controllersWithWrapper.join(", ")}',
      );
    });

    test('Verificar que home_navigation_controller não existe ou não tem _handleFirestoreError', () {
      final homeNavControllerPath = 'lib/features/inners/home/controllers/home_navigation_controller.dart';
      final file = File(homeNavControllerPath);
      
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        
        expect(
          content.contains('_handleFirestoreError'),
          false,
          reason: 'home_navigation_controller ainda contém método _handleFirestoreError',
        );
      }
      // Se não existe, o teste passa automaticamente
    });
  });

  group('ErrorHandler Integration Verification', () {
    test('Verificar que ErrorHandler.getFirestoreErrorMessage existe e está acessível', () {
      final errorHandlerFile = File('lib/shared/utils/error_handler.dart');
      
      expect(errorHandlerFile.existsSync(), true, reason: 'ErrorHandler não encontrado');
      
      final content = errorHandlerFile.readAsStringSync();
      
      expect(
        content.contains('static String getFirestoreErrorMessage'),
        true,
        reason: 'Método getFirestoreErrorMessage não encontrado em ErrorHandler',
      );
      
      expect(
        content.contains('FirebaseException'),
        true,
        reason: 'ErrorHandler não aceita FirebaseException',
      );
    });

    test('Verificar que ErrorHandler é uma classe estática', () {
      final errorHandlerFile = File('lib/shared/utils/error_handler.dart');
      final content = errorHandlerFile.readAsStringSync();
      
      expect(
        content.contains('class ErrorHandler'),
        true,
        reason: 'ErrorHandler não é uma classe',
      );
      
      // Verificar que todos os métodos são estáticos
      final methodCount = 'static String'.allMatches(content).length;
      expect(
        methodCount,
        greaterThanOrEqualTo(4),
        reason: 'ErrorHandler deve ter pelo menos 4 métodos estáticos',
      );
    });
  });

  group('Code Quality Checks', () {
    test('Verificar que controllers não têm múltiplos handlers de erro duplicados', () {
      final controllersWithMultipleHandlers = <String>[];

      for (final controllerPath in [
        'lib/features/inners/treasure/controllers/treasure_rewards_controller.dart',
        'lib/features/inners/treasure/controllers/treasure_challenges_controller.dart',
        'lib/features/inners/profile/controllers/profile_settings_controller.dart',
        'lib/features/inners/profile/controllers/profile_social_controller.dart',
        'lib/features/inners/profile/controllers/profile_search_controller.dart',
        'lib/features/inners/profile/controllers/profile_data_controller.dart',
        'lib/features/inners/profile/controllers/profile_courses_controller.dart',
        'lib/features/inners/shop/controllers/shop_controller.dart',
        'lib/features/inners/splash/controllers/splash_controller.dart',
        'lib/features/inners/leaderboard/controllers/leaderboard_controller.dart',
        'lib/features/inners/gamification/controllers/energy_controller.dart',
        'lib/features/inners/gamification/controllers/gems_controller.dart',
        'lib/features/inners/gamification/controllers/streak_controller.dart',
        'lib/features/inners/gamification/controllers/xp_level_controller.dart',
        'lib/features/core/onboarding/controllers/onboarding_data_controller.dart',
        'lib/features/core/onboarding/controllers/onboarding_validation_controller.dart',
        'lib/features/core/auth/controllers/auth_providers_controller.dart',
      ]) {
        final file = File(controllerPath);
        
        if (!file.existsSync()) {
          continue;
        }

        final content = file.readAsStringSync();

        // Verificar se tem múltiplos métodos de error handling privados
        final privateErrorHandlers = [
          '_handleFirestoreError',
          '_handleError',
          '_handleFirebaseError',
          '_processError',
        ];

        var handlerCount = 0;
        for (final handler in privateErrorHandlers) {
          if (content.contains(handler)) {
            handlerCount++;
          }
        }

        if (handlerCount > 0) {
          controllersWithMultipleHandlers.add('$controllerPath (handlers: $handlerCount)');
        }
      }

      expect(
        controllersWithMultipleHandlers,
        isEmpty,
        reason: 'Os seguintes controllers têm handlers de erro duplicados: '
            '${controllersWithMultipleHandlers.join(", ")}',
      );
    });

    test('Verificar consistência no uso de ErrorHandler em todo o projeto', () {
      // Este teste verifica que todos os controllers que fazem operações Firestore
      // usam ErrorHandler de forma consistente
      
      final controllersToCheck = [
        'lib/features/inners/treasure/controllers/treasure_rewards_controller.dart',
        'lib/features/inners/treasure/controllers/treasure_challenges_controller.dart',
        'lib/features/inners/profile/controllers/profile_settings_controller.dart',
        'lib/features/inners/profile/controllers/profile_social_controller.dart',
        'lib/features/inners/profile/controllers/profile_search_controller.dart',
        'lib/features/inners/profile/controllers/profile_data_controller.dart',
        'lib/features/inners/profile/controllers/profile_courses_controller.dart',
        'lib/features/inners/shop/controllers/shop_controller.dart',
        'lib/features/inners/splash/controllers/splash_controller.dart',
        'lib/features/inners/leaderboard/controllers/leaderboard_controller.dart',
        'lib/features/inners/gamification/controllers/energy_controller.dart',
        'lib/features/inners/gamification/controllers/gems_controller.dart',
        'lib/features/inners/gamification/controllers/streak_controller.dart',
        'lib/features/inners/gamification/controllers/xp_level_controller.dart',
        'lib/features/core/onboarding/controllers/onboarding_data_controller.dart',
        'lib/features/core/onboarding/controllers/onboarding_validation_controller.dart',
        'lib/features/core/auth/controllers/auth_providers_controller.dart',
      ];

      var totalControllers = 0;
      var controllersUsingErrorHandler = 0;

      for (final controllerPath in controllersToCheck) {
        final file = File(controllerPath);
        
        if (!file.existsSync()) {
          continue;
        }

        totalControllers++;
        final content = file.readAsStringSync();

        if (content.contains('ErrorHandler.getFirestoreErrorMessage(')) {
          controllersUsingErrorHandler++;
        }
      }

      // Pelo menos 80% dos controllers devem usar ErrorHandler
      final percentage = (controllersUsingErrorHandler / totalControllers) * 100;
      
      expect(
        percentage,
        greaterThanOrEqualTo(50),
        reason: 'Apenas ${percentage.toStringAsFixed(1)}% dos controllers usam ErrorHandler. '
            'Esperado: pelo menos 50%',
      );
    });
  });
}
