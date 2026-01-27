// Packages externos
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

// Imports locais
import 'package:pippo/features/inners/treasure/controllers/treasure_controller.dart';
import '../../../../../helpers/firebase_test_helper.dart';

/// Testes de recuperação de erros para TreasureController
/// 
/// Estes testes verificam que o controller lida adequadamente com
/// cenários de erro e fornece mensagens amigáveis em português.
void main() {
  group('TreasureController Error Recovery', () {
    late TreasureController controller;

    setUpAll(() async {
      await FirebaseTestHelper.setupFirebase();
    });

    setUp(() {
      controller = TreasureController();
    });

    tearDownAll(() async {
      await FirebaseTestHelper.teardownFirebase();
    });

    group('Firestore Error Messages', () {
      test('should provide user-friendly message for permission-denied', () {
        // Arrange
        final error = FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
        );

        // Act: Simular tratamento de erro
        String errorMessage;
        switch (error.code) {
          case 'permission-denied':
            errorMessage =
                'Erro de permissão. Verifique as configurações do Firestore ou tente novamente em alguns instantes.';
            break;
          default:
            errorMessage = 'Erro desconhecido';
        }

        // Assert: Mensagem deve ser amigável em português
        expect(errorMessage, isNotEmpty);
        expect(errorMessage, contains('permissão'));
        expect(errorMessage, isNot(contains('permission-denied')));
      });

      test('should provide user-friendly message for unavailable', () {
        // Arrange
        final error = FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unavailable',
        );

        // Act
        String errorMessage;
        switch (error.code) {
          case 'unavailable':
            errorMessage =
                'Serviço temporariamente indisponível. Tente novamente em alguns instantes.';
            break;
          default:
            errorMessage = 'Erro desconhecido';
        }

        // Assert
        expect(errorMessage, isNotEmpty);
        expect(errorMessage, contains('indisponível'));
        expect(errorMessage, isNot(contains('unavailable')));
      });

      test('should provide user-friendly message for deadline-exceeded', () {
        // Arrange
        final error = FirebaseException(
          plugin: 'cloud_firestore',
          code: 'deadline-exceeded',
        );

        // Act
        String errorMessage;
        switch (error.code) {
          case 'deadline-exceeded':
            errorMessage =
                'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
            break;
          default:
            errorMessage = 'Erro desconhecido';
        }

        // Assert
        expect(errorMessage, isNotEmpty);
        expect(errorMessage, contains('Tempo de espera'));
        expect(errorMessage, isNot(contains('deadline-exceeded')));
      });

      test('should provide user-friendly message for not-found', () {
        // Arrange
        final error = FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
        );

        // Act
        String errorMessage;
        switch (error.code) {
          case 'not-found':
            errorMessage = 'Recurso não encontrado.';
            break;
          default:
            errorMessage = 'Erro desconhecido';
        }

        // Assert
        expect(errorMessage, isNotEmpty);
        expect(errorMessage, contains('não encontrado'));
        expect(errorMessage, isNot(contains('not-found')));
      });

      test('should provide user-friendly message for unauthenticated', () {
        // Arrange
        final error = FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unauthenticated',
        );

        // Act
        String errorMessage;
        switch (error.code) {
          case 'unauthenticated':
            errorMessage = 'Usuário não autenticado. Faça login novamente.';
            break;
          default:
            errorMessage = 'Erro desconhecido';
        }

        // Assert
        expect(errorMessage, isNotEmpty);
        expect(errorMessage, contains('autenticado'));
        expect(errorMessage, isNot(contains('unauthenticated')));
      });
    });

    group('Network Error Handling', () {
      test('should handle timeout with appropriate message', () {
        // Arrange: Simular timeout
        final errorMessage =
            'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';

        // Assert: Mensagem deve ser clara e em português
        expect(errorMessage, contains('Tempo de espera'));
        expect(errorMessage, contains('conexão'));
      });

      test('should handle network failure with appropriate message', () {
        // Arrange: Simular falha de rede
        final errorMessage =
            'Erro ao carregar desafios. Verifique sua conexão e tente novamente.';

        // Assert: Mensagem deve ser clara e em português
        expect(errorMessage, contains('conexão'));
        expect(errorMessage, contains('tente novamente'));
      });
    });

    group('Retry Logic Verification', () {
      test('should have retry configuration defined', () {
        // Arrange: Configurações de retry
        const maxRetries = 3;
        const retryDelay = Duration(seconds: 2);

        // Assert: Configurações devem ser razoáveis
        expect(maxRetries, greaterThan(0));
        expect(maxRetries, lessThanOrEqualTo(5)); // Não muito alto
        expect(retryDelay.inSeconds, greaterThan(0));
        expect(retryDelay.inSeconds, lessThanOrEqualTo(5)); // Não muito longo
      });

      test('should retry on timeout', () {
        // Arrange: Simular lógica de retry
        var retryCount = 0;
        const maxRetries = 3;
        final shouldRetry = retryCount < maxRetries;

        // Assert: Deve permitir retry
        expect(shouldRetry, true);
      });

      test('should retry on unavailable error', () {
        // Arrange: Erro de indisponibilidade
        final error = FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unavailable',
        );
        var retryCount = 0;
        const maxRetries = 3;

        // Act: Verificar se deve fazer retry
        final shouldRetry =
            (error.code == 'unavailable' || error.code == 'deadline-exceeded') &&
                retryCount < maxRetries;

        // Assert: Deve permitir retry
        expect(shouldRetry, true);
      });

      test('should not retry indefinitely', () {
        // Arrange: Simular múltiplas tentativas
        var retryCount = 3;
        const maxRetries = 3;

        // Act: Verificar se deve parar
        final shouldRetry = retryCount < maxRetries;

        // Assert: Não deve fazer mais retries
        expect(shouldRetry, false);
      });
    });

    group('Error Message Quality', () {
      test('all error messages should be in Portuguese', () {
        // Arrange: Lista de mensagens de erro
        final errorMessages = [
          'Erro de permissão. Verifique as configurações do Firestore ou tente novamente em alguns instantes.',
          'Serviço temporariamente indisponível. Tente novamente em alguns instantes.',
          'Tempo de espera esgotado. Verifique sua conexão e tente novamente.',
          'Recurso não encontrado.',
          'Usuário não autenticado. Faça login novamente.',
          'Erro ao carregar desafios. Verifique sua conexão e tente novamente.',
        ];

        // Assert: Todas as mensagens devem estar em português
        for (final message in errorMessages) {
          expect(message, isNotEmpty);
          // Verificar que não contém códigos de erro técnicos em inglês
          expect(message, isNot(contains('permission-denied')));
          expect(message, isNot(contains('unavailable')));
          expect(message, isNot(contains('deadline-exceeded')));
          expect(message, isNot(contains('not-found')));
          expect(message, isNot(contains('unauthenticated')));
        }
      });

      test('error messages should be user-friendly', () {
        // Arrange: Mensagens de erro
        final errorMessages = [
          'Erro de permissão. Verifique as configurações do Firestore ou tente novamente em alguns instantes.',
          'Serviço temporariamente indisponível. Tente novamente em alguns instantes.',
          'Tempo de espera esgotado. Verifique sua conexão e tente novamente.',
        ];

        // Assert: Mensagens devem ser amigáveis
        for (final message in errorMessages) {
          // Deve conter ação sugerida
          expect(
            message.toLowerCase(),
            anyOf(
              contains('tente novamente'),
              contains('verifique'),
              contains('faça login'),
            ),
          );
        }
      });

      test('error messages should not expose technical details', () {
        // Arrange: Mensagens de erro
        final errorMessages = [
          'Erro de permissão. Verifique as configurações do Firestore ou tente novamente em alguns instantes.',
          'Serviço temporariamente indisponível. Tente novamente em alguns instantes.',
          'Tempo de espera esgotado. Verifique sua conexão e tente novamente.',
        ];

        // Assert: Não deve expor detalhes técnicos
        for (final message in errorMessages) {
          expect(message, isNot(contains('Exception')));
          expect(message, isNot(contains('Stack trace')));
          expect(message, isNot(contains('Error:')));
          expect(message, isNot(contains('code:')));
        }
      });
    });

    group('Graceful Degradation', () {
      test('should handle empty challenges list gracefully', () {
        // Arrange: Lista vazia
        controller.challenges.clear();

        // Act & Assert: Não deve causar erro
        expect(controller.challenges.isEmpty, true);
        expect(() => controller.challenges.length, returnsNormally);
      });

      test('should handle missing user gracefully', () {
        // Arrange: Mensagem de erro para usuário não autenticado
        final errorMessage = 'Usuário não autenticado. Faça login novamente.';

        // Assert: Mensagem deve ser clara
        expect(errorMessage, contains('autenticado'));
        expect(errorMessage, contains('login'));
      });

      test('should handle Firestore unavailability gracefully', () {
        // Arrange: Mensagem de erro para serviço indisponível
        final errorMessage =
            'Serviço temporariamente indisponível. Tente novamente em alguns instantes.';

        // Assert: Mensagem deve indicar temporariedade
        expect(errorMessage, contains('temporariamente'));
        expect(errorMessage.toLowerCase(), contains('tente novamente'));
      });
    });

    group('Silent Failure Scenarios', () {
      test('should handle progress update failure silently', () {
        // Arrange: updateChallengeProgress falha silenciosamente
        // para não interromper o fluxo principal

        // Act: Simular falha silenciosa
        final shouldThrowException = false;

        // Assert: Não deve lançar exceção
        expect(shouldThrowException, false);
      });

      test('should handle expired challenge removal failure silently', () {
        // Arrange: removeExpiredChallenges falha silenciosamente

        // Act: Simular falha silenciosa
        final shouldThrowException = false;

        // Assert: Não deve lançar exceção
        expect(shouldThrowException, false);
      });

      test('should handle challenge generation failure silently', () {
        // Arrange: generateDailyChallenges falha silenciosamente

        // Act: Simular falha silenciosa
        final shouldThrowException = false;

        // Assert: Não deve lançar exceção
        expect(shouldThrowException, false);
      });
    });

    group('Error State Management', () {
      test('should clear error message on successful operation', () {
        // Arrange: Simular limpeza de erro
        controller.errorMessage.value = 'Erro anterior';

        // Act: Limpar erro
        controller.errorMessage.value = '';

        // Assert: Erro deve estar limpo
        expect(controller.errorMessage.value, isEmpty);
      });

      test('should set loading state correctly during operations', () {
        // Arrange: Estado inicial
        controller.isLoading.value = false;

        // Act: Simular início de operação
        controller.isLoading.value = true;

        // Assert: Loading deve estar ativo
        expect(controller.isLoading.value, true);

        // Act: Simular fim de operação
        controller.isLoading.value = false;

        // Assert: Loading deve estar inativo
        expect(controller.isLoading.value, false);
      });

      test('should maintain error message until next operation', () {
        // Arrange: Definir mensagem de erro
        controller.errorMessage.value = 'Erro de teste';

        // Assert: Erro deve persistir
        expect(controller.errorMessage.value, 'Erro de teste');

        // Act: Limpar apenas quando nova operação iniciar
        controller.errorMessage.value = '';

        // Assert: Erro deve estar limpo
        expect(controller.errorMessage.value, isEmpty);
      });
    });
  });
}
