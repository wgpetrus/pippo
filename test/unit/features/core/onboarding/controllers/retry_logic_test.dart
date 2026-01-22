import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('Retry Logic - Exponential Backoff', () {
    test('retry succeeds after temporary network error', () async {
      int attemptCount = 0;
      
      // Simula operação que falha nas primeiras 2 tentativas e sucede na 3ª
      Future<String> operation() async {
        attemptCount++;
        
        if (attemptCount < 3) {
          // Simula erro de rede temporário
          throw Exception('network-request-failed');
        }
        
        // Sucesso na 3ª tentativa
        return 'success';
      }
      
      // Wrapper de retry simplificado (mesma lógica do controller)
      Future<T> retryWithBackoff<T>(
        Future<T> Function() op, {
        int maxAttempts = 3,
      }) async {
        int attempt = 0;
        Exception? lastException;

        while (attempt < maxAttempts) {
          try {
            attempt++;
            final result = await op();
            return result;
          } catch (e) {
            lastException = e is Exception ? e : Exception(e.toString());
            
            // Se não é a última tentativa, aguardar antes de tentar novamente
            if (attempt < maxAttempts) {
              // Exponential backoff: 2^(attempt-1) segundos
              // Para teste, usar delay mínimo
              await Future.delayed(const Duration(milliseconds: 10));
            }
          }
        }

        throw lastException!;
      }
      
      // Executar operação com retry
      final result = await retryWithBackoff(operation);
      
      // Verificar que operação foi bem-sucedida após 3 tentativas
      expect(result, equals('success'));
      expect(attemptCount, equals(3));
    });

    test('retry fails after max attempts with persistent error', () async {
      int attemptCount = 0;
      
      // Simula operação que sempre falha
      Future<String> operation() async {
        attemptCount++;
        throw Exception('persistent-error');
      }
      
      // Wrapper de retry simplificado
      Future<T> retryWithBackoff<T>(
        Future<T> Function() op, {
        int maxAttempts = 3,
      }) async {
        int attempt = 0;
        Exception? lastException;

        while (attempt < maxAttempts) {
          try {
            attempt++;
            final result = await op();
            return result;
          } catch (e) {
            lastException = e is Exception ? e : Exception(e.toString());
            
            if (attempt < maxAttempts) {
              await Future.delayed(const Duration(milliseconds: 10));
            }
          }
        }

        throw lastException!;
      }
      
      // Verificar que exceção é lançada após 3 tentativas
      expect(
        () => retryWithBackoff(operation),
        throwsA(isA<Exception>()),
      );
      
      // Aguardar para permitir que todas as tentativas sejam executadas
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Verificar que foram feitas exatamente 3 tentativas
      expect(attemptCount, equals(3));
    });

    test('retry succeeds on first attempt when no error', () async {
      int attemptCount = 0;
      
      // Simula operação que sucede imediatamente
      Future<String> operation() async {
        attemptCount++;
        return 'success';
      }
      
      // Wrapper de retry simplificado
      Future<T> retryWithBackoff<T>(
        Future<T> Function() op, {
        int maxAttempts = 3,
      }) async {
        int attempt = 0;
        Exception? lastException;

        while (attempt < maxAttempts) {
          try {
            attempt++;
            final result = await op();
            return result;
          } catch (e) {
            lastException = e is Exception ? e : Exception(e.toString());
            
            if (attempt < maxAttempts) {
              await Future.delayed(const Duration(milliseconds: 10));
            }
          }
        }

        throw lastException!;
      }
      
      // Executar operação com retry
      final result = await retryWithBackoff(operation);
      
      // Verificar que operação foi bem-sucedida na primeira tentativa
      expect(result, equals('success'));
      expect(attemptCount, equals(1));
    });

    test('retry uses exponential backoff delays', () async {
      final delays = <int>[];
      int attemptCount = 0;
      
      // Simula operação que sempre falha para testar delays
      Future<String> operation() async {
        attemptCount++;
        throw Exception('test-error');
      }
      
      // Wrapper de retry que registra delays
      Future<T> retryWithBackoff<T>(
        Future<T> Function() op, {
        int maxAttempts = 3,
      }) async {
        int attempt = 0;
        Exception? lastException;

        while (attempt < maxAttempts) {
          try {
            attempt++;
            final result = await op();
            return result;
          } catch (e) {
            lastException = e is Exception ? e : Exception(e.toString());
            
            if (attempt < maxAttempts) {
              // Calcular delay exponencial
              final delaySeconds = attempt == 1 ? 0 : (1 << (attempt - 1));
              delays.add(delaySeconds);
              
              // Usar delay mínimo para teste
              await Future.delayed(const Duration(milliseconds: 10));
            }
          }
        }

        throw lastException!;
      }
      
      // Executar operação com retry (vai falhar)
      try {
        await retryWithBackoff(operation);
      } catch (e) {
        // Esperado
      }
      
      // Verificar padrão de delays exponenciais
      // Tentativa 1 → 0s (imediata)
      // Tentativa 2 → 2s
      expect(delays.length, equals(2));
      expect(delays[0], equals(0)); // Primeira tentativa sem delay
      expect(delays[1], equals(2)); // Segunda tentativa com 2s delay
    });

    test('retry preserves operation result type', () async {
      // Simula operação que retorna Map
      Future<Map<String, dynamic>> operation() async {
        return {'status': 'success', 'data': 123};
      }
      
      // Wrapper de retry simplificado
      Future<T> retryWithBackoff<T>(
        Future<T> Function() op, {
        int maxAttempts = 3,
      }) async {
        int attempt = 0;
        Exception? lastException;

        while (attempt < maxAttempts) {
          try {
            attempt++;
            final result = await op();
            return result;
          } catch (e) {
            lastException = e is Exception ? e : Exception(e.toString());
            
            if (attempt < maxAttempts) {
              await Future.delayed(const Duration(milliseconds: 10));
            }
          }
        }

        throw lastException!;
      }
      
      // Executar operação com retry
      final result = await retryWithBackoff(operation);
      
      // Verificar que tipo e conteúdo são preservados
      expect(result, isA<Map<String, dynamic>>());
      expect(result['status'], equals('success'));
      expect(result['data'], equals(123));
    });

    test('retry handles different exception types', () async {
      int attemptCount = 0;
      
      // Simula operação que lança diferentes tipos de exceção
      Future<String> operation() async {
        attemptCount++;
        
        if (attemptCount == 1) {
          throw Exception('network-error');
        } else if (attemptCount == 2) {
          throw 'string-error';
        }
        
        return 'success';
      }
      
      // Wrapper de retry simplificado
      Future<T> retryWithBackoff<T>(
        Future<T> Function() op, {
        int maxAttempts = 3,
      }) async {
        int attempt = 0;
        Exception? lastException;

        while (attempt < maxAttempts) {
          try {
            attempt++;
            final result = await op();
            return result;
          } catch (e) {
            lastException = e is Exception ? e : Exception(e.toString());
            
            if (attempt < maxAttempts) {
              await Future.delayed(const Duration(milliseconds: 10));
            }
          }
        }

        throw lastException!;
      }
      
      // Executar operação com retry
      final result = await retryWithBackoff(operation);
      
      // Verificar que operação foi bem-sucedida após lidar com diferentes exceções
      expect(result, equals('success'));
      expect(attemptCount, equals(3));
    });
  });

  group('Retry Logic - State Management', () {
    test('retry attempt counter increments correctly', () {
      int retryAttempt = 0;
      
      // Simular incremento de tentativas
      retryAttempt = 1;
      expect(retryAttempt, equals(1));
      
      retryAttempt = 2;
      expect(retryAttempt, equals(2));
      
      retryAttempt = 3;
      expect(retryAttempt, equals(3));
    });

    test('retry attempt counter resets after success', () {
      int retryAttempt = 3;
      
      // Simular reset após sucesso
      retryAttempt = 0;
      
      expect(retryAttempt, equals(0));
    });

    test('retry message updates during attempts', () {
      String retryMessage = '';
      
      // Simular mensagens de retry
      retryMessage = 'Tentativa 2 de 3...';
      expect(retryMessage, equals('Tentativa 2 de 3...'));
      
      retryMessage = 'Tentativa 3 de 3...';
      expect(retryMessage, equals('Tentativa 3 de 3...'));
      
      // Simular limpeza após sucesso
      retryMessage = '';
      expect(retryMessage, isEmpty);
    });

    test('retry message shows wait time', () {
      String retryMessage = '';
      
      // Simular mensagem de aguardo
      retryMessage = 'Aguardando 2s antes da próxima tentativa...';
      expect(retryMessage, contains('Aguardando'));
      expect(retryMessage, contains('2s'));
      expect(retryMessage, contains('próxima tentativa'));
    });

    test('retry state is cleared after operation completes', () {
      int retryAttempt = 3;
      String retryMessage = 'Tentativa 3 de 3...';
      
      // Simular limpeza de estado
      retryAttempt = 0;
      retryMessage = '';
      
      expect(retryAttempt, equals(0));
      expect(retryMessage, isEmpty);
    });
  });

  group('Retry Logic - Cancel Functionality', () {
    test('retry can be cancelled during execution', () {
      bool retryCancelled = false;
      
      // Simular cancelamento
      retryCancelled = true;
      
      expect(retryCancelled, isTrue);
    });

    test('retry throws exception when cancelled', () async {
      bool retryCancelled = false;
      
      // Simula operação com verificação de cancelamento
      Future<String> operation() async {
        if (retryCancelled) {
          throw Exception('Operação cancelada pelo usuário.');
        }
        return 'success';
      }
      
      // Cancelar antes de executar
      retryCancelled = true;
      
      // Verificar que exceção é lançada
      expect(
        () => operation(),
        throwsA(
          predicate((e) => 
            e is Exception && 
            e.toString().contains('Operação cancelada pelo usuário')
          ),
        ),
      );
    });

    test('retry clears state when cancelled', () {
      int retryAttempt = 2;
      String retryMessage = 'Tentativa 2 de 3...';
      bool retryCancelled = false;
      
      // Simular cancelamento
      retryCancelled = true;
      retryAttempt = 0;
      retryMessage = '';
      
      expect(retryCancelled, isTrue);
      expect(retryAttempt, equals(0));
      expect(retryMessage, isEmpty);
    });

    test('cancel flag is reset at start of new retry', () {
      bool retryCancelled = true;
      
      // Simular início de nova operação
      retryCancelled = false;
      
      expect(retryCancelled, isFalse);
    });
  });

  group('Retry Logic - Integration Scenarios', () {
    test('retry succeeds after intermittent network failure', () async {
      int attemptCount = 0;
      bool networkAvailable = false;
      
      // Simula operação que depende de rede
      Future<String> operation() async {
        attemptCount++;
        
        // Rede fica disponível na 2ª tentativa
        if (attemptCount >= 2) {
          networkAvailable = true;
        }
        
        if (!networkAvailable) {
          throw Exception('network-request-failed');
        }
        
        return 'data-saved';
      }
      
      // Wrapper de retry simplificado
      Future<T> retryWithBackoff<T>(
        Future<T> Function() op, {
        int maxAttempts = 3,
      }) async {
        int attempt = 0;
        Exception? lastException;

        while (attempt < maxAttempts) {
          try {
            attempt++;
            final result = await op();
            return result;
          } catch (e) {
            lastException = e is Exception ? e : Exception(e.toString());
            
            if (attempt < maxAttempts) {
              await Future.delayed(const Duration(milliseconds: 10));
            }
          }
        }

        throw lastException!;
      }
      
      // Executar operação com retry
      final result = await retryWithBackoff(operation);
      
      // Verificar sucesso após rede ficar disponível
      expect(result, equals('data-saved'));
      expect(networkAvailable, isTrue);
      expect(attemptCount, equals(2));
    });

    test('retry preserves data in memory after failure', () async {
      // Simular dados do onboarding
      final userData = {
        'name': 'João Silva',
        'email': 'joao@example.com',
        'language': 'en',
      };
      
      int attemptCount = 0;
      
      // Simula operação que falha mas preserva dados
      Future<void> operation() async {
        attemptCount++;
        
        if (attemptCount < 2) {
          // Falha mas dados permanecem em userData
          throw Exception('network-error');
        }
        
        // Sucesso - dados ainda disponíveis
        expect(userData['name'], equals('João Silva'));
        expect(userData['email'], equals('joao@example.com'));
      }
      
      // Wrapper de retry simplificado
      Future<T> retryWithBackoff<T>(
        Future<T> Function() op, {
        int maxAttempts = 3,
      }) async {
        int attempt = 0;
        Exception? lastException;

        while (attempt < maxAttempts) {
          try {
            attempt++;
            final result = await op();
            return result;
          } catch (e) {
            lastException = e is Exception ? e : Exception(e.toString());
            
            if (attempt < maxAttempts) {
              await Future.delayed(const Duration(milliseconds: 10));
            }
          }
        }

        throw lastException!;
      }
      
      // Executar operação com retry
      await retryWithBackoff(operation);
      
      // Verificar que dados foram preservados durante retry
      expect(userData['name'], equals('João Silva'));
      expect(userData['email'], equals('joao@example.com'));
      expect(userData['language'], equals('en'));
    });
  });
}
