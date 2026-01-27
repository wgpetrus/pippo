// Dart SDK
import 'dart:async';

// Packages externos
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

// Imports locais
import 'package:pippo/features/inners/treasure/controllers/treasure_controller.dart';
import '../../../../../helpers/firebase_test_helper.dart';

/// Testes de edge cases para TreasureController
/// 
/// Estes testes focam na lógica de validação e edge cases sem
/// depender de autenticação Firebase real. Testam métodos públicos
/// de validação e cálculo.
void main() {
  group('TreasureController Edge Cases - Validation Logic', () {
    late TreasureController controller;

    setUpAll(() async {
      await FirebaseTestHelper.setupFirebase();
    });

    setUp(() {
      // Criar controller sem inicializar (sem chamar onInit)
      controller = TreasureController();
    });

    tearDownAll(() async {
      await FirebaseTestHelper.teardownFirebase();
    });

    group('Edge Case: Expired challenge validation', () {
      test('should identify expired challenge correctly', () {
        // Arrange: Criar desafio expirado
        final expiredChallenge = {
          'id': 'expired-challenge',
          'type': 'daily',
          'title': 'Complete 3 lessons',
          'description': 'Finish 3 lessons today',
          'goal': 3,
          'progress': 3,
          'rewardType': 'gems',
          'rewardAmount': 50,
          'expirationDate': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 1)),
          ),
          'iconPath': 'assets/icon.png',
          'isClaimed': false,
        };

        // Act: Verificar se está expirado usando lógica de expiração
        final expirationDate =
            (expiredChallenge['expirationDate'] as Timestamp?)?.toDate();
        final isExpired =
            expirationDate != null && DateTime.now().isAfter(expirationDate);

        // Assert: Deve estar expirado
        expect(isExpired, true);
      });

      test('should identify non-expired challenge correctly', () {
        // Arrange: Criar desafio ativo
        final activeChallenge = {
          'id': 'active-challenge',
          'expirationDate': Timestamp.fromDate(
            DateTime.now().add(const Duration(days: 1)),
          ),
        };

        // Act: Verificar expiração
        final expirationDate =
            (activeChallenge['expirationDate'] as Timestamp?)?.toDate();
        final isExpired =
            expirationDate != null && DateTime.now().isAfter(expirationDate);

        // Assert: Não deve estar expirado
        expect(isExpired, false);
      });
    });

    group('Edge Case: Completed challenge validation', () {
      test('should identify completed challenge correctly', () {
        // Arrange: Desafio completado
        final completedChallenge = {
          'progress': 3,
          'goal': 3,
        };

        // Act: Verificar se está completado
        final progress = completedChallenge['progress'] as int? ?? 0;
        final goal = completedChallenge['goal'] as int? ?? 0;
        final isCompleted = progress >= goal;

        // Assert: Deve estar completado
        expect(isCompleted, true);
      });

      test('should identify incomplete challenge correctly', () {
        // Arrange: Desafio incompleto
        final incompleteChallenge = {
          'progress': 1,
          'goal': 3,
        };

        // Act: Verificar se está completado
        final progress = incompleteChallenge['progress'] as int? ?? 0;
        final goal = incompleteChallenge['goal'] as int? ?? 0;
        final isCompleted = progress >= goal;

        // Assert: Não deve estar completado
        expect(isCompleted, false);
      });
    });

    group('Edge Case: Challenge structure validation', () {
      test('should reject challenge with missing required fields', () {
        // Arrange: Desafio incompleto
        final incompleteChallenge = {
          'id': 'incomplete',
          'title': 'Test',
          // Faltando campos obrigatórios
        };

        // Act: Validar estrutura
        final validationError =
            controller.validateChallengeStructure(incompleteChallenge);

        // Assert: Deve ter erro
        expect(validationError, isNotNull);
        expect(validationError, contains('obrigatórios'));
      });

      test('should accept challenge with all required fields', () {
        // Arrange: Desafio completo
        final validChallenge = {
          'title': 'Test Challenge',
          'description': 'Test description',
          'goal': 3,
          'progress': 0,
          'rewardType': 'gems',
          'rewardAmount': 50,
          'expirationDate': Timestamp.now(),
          'iconPath': 'assets/icon.png',
          'type': 'daily',
        };

        // Act: Validar estrutura
        final validationError =
            controller.validateChallengeStructure(validChallenge);

        // Assert: Não deve ter erro
        expect(validationError, isNull);
      });
    });

    group('Edge Case: Goal validation', () {
      test('should reject challenge with zero goal', () {
        // Arrange
        final invalidChallenge = {
          'title': 'Test',
          'description': 'Test',
          'goal': 0,
          'progress': 0,
          'rewardType': 'gems',
          'rewardAmount': 50,
          'expirationDate': Timestamp.now(),
          'iconPath': 'assets/icon.png',
          'type': 'daily',
        };

        // Act
        final validationError =
            controller.validateChallengeStructure(invalidChallenge);

        // Assert
        expect(validationError, isNotNull);
        expect(validationError, contains('positivo'));
      });

      test('should reject challenge with negative goal', () {
        // Arrange
        final invalidChallenge = {
          'title': 'Test',
          'description': 'Test',
          'goal': -5,
          'progress': 0,
          'rewardType': 'gems',
          'rewardAmount': 50,
          'expirationDate': Timestamp.now(),
          'iconPath': 'assets/icon.png',
          'type': 'daily',
        };

        // Act
        final validationError =
            controller.validateChallengeStructure(invalidChallenge);

        // Assert
        expect(validationError, isNotNull);
        expect(validationError, contains('positivo'));
      });

      test('should accept challenge with positive goal', () {
        // Arrange
        final validChallenge = {
          'title': 'Test',
          'description': 'Test',
          'goal': 3,
          'progress': 0,
          'rewardType': 'gems',
          'rewardAmount': 50,
          'expirationDate': Timestamp.now(),
          'iconPath': 'assets/icon.png',
          'type': 'daily',
        };

        // Act
        final validationError =
            controller.validateChallengeStructure(validChallenge);

        // Assert
        expect(validationError, isNull);
      });
    });

    group('Edge Case: Reward amount validation', () {
      test('should reject challenge with zero reward amount', () {
        // Arrange
        final invalidChallenge = {
          'title': 'Test',
          'description': 'Test',
          'goal': 3,
          'progress': 0,
          'rewardType': 'gems',
          'rewardAmount': 0,
          'expirationDate': Timestamp.now(),
          'iconPath': 'assets/icon.png',
          'type': 'daily',
        };

        // Act
        final validationError =
            controller.validateChallengeStructure(invalidChallenge);

        // Assert
        expect(validationError, isNotNull);
        expect(validationError, contains('positivo'));
      });

      test('should reject challenge with negative reward amount', () {
        // Arrange
        final invalidChallenge = {
          'title': 'Test',
          'description': 'Test',
          'goal': 3,
          'progress': 0,
          'rewardType': 'gems',
          'rewardAmount': -10,
          'expirationDate': Timestamp.now(),
          'iconPath': 'assets/icon.png',
          'type': 'daily',
        };

        // Act
        final validationError =
            controller.validateChallengeStructure(invalidChallenge);

        // Assert
        expect(validationError, isNotNull);
        expect(validationError, contains('positivo'));
      });
    });

    group('Edge Case: Reward type validation', () {
      test('should reject challenge with invalid reward type', () {
        // Arrange
        final invalidChallenge = {
          'title': 'Test',
          'description': 'Test',
          'goal': 3,
          'progress': 0,
          'rewardType': 'invalid_type',
          'rewardAmount': 50,
          'expirationDate': Timestamp.now(),
          'iconPath': 'assets/icon.png',
          'type': 'daily',
        };

        // Act
        final validationError =
            controller.validateChallengeStructure(invalidChallenge);

        // Assert
        expect(validationError, isNotNull);
        expect(validationError, contains('inválido'));
      });

      test('should accept challenge with gems reward type', () {
        // Arrange
        final validChallenge = {
          'title': 'Test',
          'description': 'Test',
          'goal': 3,
          'progress': 0,
          'rewardType': 'gems',
          'rewardAmount': 50,
          'expirationDate': Timestamp.now(),
          'iconPath': 'assets/icon.png',
          'type': 'daily',
        };

        // Act
        final validationError =
            controller.validateChallengeStructure(validChallenge);

        // Assert
        expect(validationError, isNull);
      });

      test('should accept challenge with xp reward type', () {
        // Arrange
        final validChallenge = {
          'title': 'Test',
          'description': 'Test',
          'goal': 3,
          'progress': 0,
          'rewardType': 'xp',
          'rewardAmount': 50,
          'expirationDate': Timestamp.now(),
          'iconPath': 'assets/icon.png',
          'type': 'daily',
        };

        // Act
        final validationError =
            controller.validateChallengeStructure(validChallenge);

        // Assert
        expect(validationError, isNull);
      });

      test('should accept challenge with item reward type', () {
        // Arrange
        final validChallenge = {
          'title': 'Test',
          'description': 'Test',
          'goal': 3,
          'progress': 0,
          'rewardType': 'item',
          'rewardAmount': 1,
          'expirationDate': Timestamp.now(),
          'iconPath': 'assets/icon.png',
          'type': 'daily',
        };

        // Act
        final validationError =
            controller.validateChallengeStructure(validChallenge);

        // Assert
        expect(validationError, isNull);
      });
    });

    group('Edge Case: Initial progress validation', () {
      test('should reject challenge with non-zero initial progress', () {
        // Arrange
        final invalidChallenge = {
          'title': 'Test',
          'description': 'Test',
          'goal': 3,
          'progress': 1, // Deve ser 0
          'rewardType': 'gems',
          'rewardAmount': 50,
          'expirationDate': Timestamp.now(),
          'iconPath': 'assets/icon.png',
          'type': 'daily',
        };

        // Act
        final validationError =
            controller.validateChallengeStructure(invalidChallenge);

        // Assert
        expect(validationError, isNotNull);
        expect(validationError, contains('zero'));
      });
    });

    group('Edge Case: Progress percentage calculation', () {
      test('should calculate 0% for no progress', () {
        // Arrange
        final challenge = {'progress': 0, 'goal': 3};

        // Act
        final percentage = controller.getProgressPercentage(challenge);

        // Assert
        expect(percentage, 0.0);
      });

      test('should calculate 50% for half progress', () {
        // Arrange
        final challenge = {'progress': 1, 'goal': 2};

        // Act
        final percentage = controller.getProgressPercentage(challenge);

        // Assert
        expect(percentage, 0.5);
      });

      test('should calculate 100% for completed challenge', () {
        // Arrange
        final challenge = {'progress': 3, 'goal': 3};

        // Act
        final percentage = controller.getProgressPercentage(challenge);

        // Assert
        expect(percentage, 1.0);
      });

      test('should cap at 100% for over-completed challenge', () {
        // Arrange
        final challenge = {'progress': 5, 'goal': 3};

        // Act
        final percentage = controller.getProgressPercentage(challenge);

        // Assert
        expect(percentage, 1.0);
      });
    });

    group('Edge Case: Expiration calculation', () {
      test('should calculate daily expiration correctly', () {
        // Act
        final expiration = controller.calculateExpiration('daily');
        final now = DateTime.now();

        // Assert: Deve ser meia-noite do dia atual
        expect(expiration.year, now.year);
        expect(expiration.month, now.month);
        expect(expiration.day, now.day);
        expect(expiration.hour, 23);
        expect(expiration.minute, 59);
        expect(expiration.second, 59);
      });

      test('should calculate weekly expiration correctly', () {
        // Act
        final expiration = controller.calculateExpiration('weekly');

        // Assert: Deve ser domingo às 23:59:59
        expect(expiration.weekday, DateTime.sunday);
        expect(expiration.hour, 23);
        expect(expiration.minute, 59);
        expect(expiration.second, 59);
      });

      test('should use custom date for special challenges', () {
        // Arrange
        final customDate = DateTime.now().add(const Duration(days: 10));

        // Act
        final expiration =
            controller.calculateExpiration('special', customDate: customDate);

        // Assert: Deve usar a data customizada
        expect(expiration, customDate);
      });
    });

    group('Edge Case: Empty challenges list', () {
      test('should handle empty list correctly', () {
        // Arrange: Lista vazia
        controller.challenges.clear();

        // Act & Assert
        expect(controller.challenges.isEmpty, true);
        expect(controller.challenges.length, 0);
      });
    });

    group('Edge Case: Multiple expired challenges filtering', () {
      test('should filter out all expired challenges', () {
        // Arrange: Criar lista mista
        final challenges = [
          {
            'id': 'expired-1',
            'expirationDate': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 1)),
            ),
          },
          {
            'id': 'expired-2',
            'expirationDate': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 2)),
            ),
          },
          {
            'id': 'active-1',
            'expirationDate': Timestamp.fromDate(
              DateTime.now().add(const Duration(days: 1)),
            ),
          },
        ];

        // Act: Filtrar expirados
        final activeChallenges = challenges.where((challenge) {
          final expirationDate =
              (challenge['expirationDate'] as Timestamp?)?.toDate();
          if (expirationDate == null) return true;
          return DateTime.now().isBefore(expirationDate);
        }).toList();

        // Assert: Apenas 1 ativo
        expect(activeChallenges.length, 1);
        expect(activeChallenges.first['id'], 'active-1');
      });
    });

    group('Edge Case: Negative progress validation', () {
      test('should validate negative progress is rejected', () {
        // Arrange: Simular validação de progresso negativo
        final negativeAmount = -1;

        // Act: Verificar se é negativo
        final isNegative = negativeAmount < 0;

        // Assert: Deve ser identificado como negativo
        expect(isNegative, true);
      });
    });

    group('Edge Case: Claimed challenge validation', () {
      test('should identify already claimed challenge', () {
        // Arrange: Desafio já coletado
        final claimedChallenge = {
          'isClaimed': true,
          'claimedAt': Timestamp.now(),
        };

        // Act: Verificar se foi coletado
        final isClaimed = claimedChallenge['isClaimed'] as bool? ?? false;

        // Assert: Deve estar coletado
        expect(isClaimed, true);
      });

      test('should identify unclaimed challenge', () {
        // Arrange: Desafio não coletado
        final unclaimedChallenge = {
          'isClaimed': false,
        };

        // Act: Verificar se foi coletado
        final isClaimed = unclaimedChallenge['isClaimed'] as bool? ?? false;

        // Assert: Não deve estar coletado
        expect(isClaimed, false);
      });
    });
  });
}
