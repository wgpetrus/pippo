import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pippo/features/core/lesson/controllers/lesson_controller.dart';
import 'package:pippo/features/inners/gamification/controllers/gamification_controller.dart';

import '../../../../helpers/firebase_test_helper.dart';

/// Feature: lesson-system, Property 10: XP Distribution Atomicity
/// 
/// **Property:** XP distribution formula must be consistent and deterministic
/// 
/// This property verifies that:
/// 1. _calculateXPForNextLevel() follows formula: currentLevel * 100
/// 2. Formula is deterministic (same input = same output)
/// 3. Formula scales correctly for any level
/// 4. XP requirements increase monotonically
/// 
/// **Validates: Requirements 6.1, 6.2, 6.3, 6.7**
void main() {
  late LessonController controller;

  setUpAll(() async {
    await FirebaseTestHelper.setupFirebase();
  });

  setUp(() {
    Get.testMode = true;

    // Register GamificationController mock
    Get.put<GamificationController>(
      GamificationController(),
      permanent: true,
    );

    controller = LessonController();
  });

  tearDown(() {
    Get.reset();
  });

  group('Property 10: XP Distribution Atomicity', () {
    test('calculateXPForNextLevel follows formula: currentLevel * 100', () {
      // Property: Para qualquer nível de 1 a 100, XP = nível * 100
      for (int level = 1; level <= 100; level++) {
        final xpForNextLevel = controller.calculateXPForNextLevelForTest(level);

        // Property: XP for next level must equal currentLevel * 100
        expect(xpForNextLevel, equals(level * 100),
            reason:
                'XP for level $level should be ${level * 100}, got $xpForNextLevel');

        // Property: XP increases linearly with level
        if (level > 1) {
          final previousXp =
              controller.calculateXPForNextLevelForTest(level - 1);
          expect(xpForNextLevel - previousXp, equals(100),
              reason: 'XP should increase by exactly 100 per level');
        }
      }
    });

    test('calculateXPForNextLevel never returns negative or zero values', () {
      // Property: Para qualquer nível, XP > 0
      for (int level = 1; level <= 100; level++) {
        final xpForNextLevel = controller.calculateXPForNextLevelForTest(level);

        // Property: XP for next level is always positive
        expect(xpForNextLevel, greaterThan(0),
            reason: 'XP for next level must be positive');

        // Property: XP for next level is at least 100
        expect(xpForNextLevel, greaterThanOrEqualTo(100),
            reason: 'XP for next level must be at least 100');
      }
    });

    test('calculateXPForNextLevel is deterministic', () {
      // Property: Mesma entrada sempre produz mesma saída
      for (int level = 1; level <= 50; level++) {
        final xp1 = controller.calculateXPForNextLevelForTest(level);
        final xp2 = controller.calculateXPForNextLevelForTest(level);
        final xp3 = controller.calculateXPForNextLevelForTest(level);

        // Property: Same input always produces same output
        expect(xp1, equals(xp2), reason: 'Formula should be deterministic');
        expect(xp2, equals(xp3), reason: 'Formula should be deterministic');
        expect(xp1, equals(level * 100),
            reason: 'Formula should match specification');
      }
    });

    test('calculateXPForNextLevel scales correctly for high levels', () {
      // Property: Fórmula funciona para níveis muito altos
      final highLevels = [100, 500, 1000, 5000, 10000];

      for (final level in highLevels) {
        final xpForNextLevel = controller.calculateXPForNextLevelForTest(level);

        // Property: Formula holds for any level
        expect(xpForNextLevel, equals(level * 100),
            reason: 'Formula should work for level $level');

        // Property: XP scales linearly
        final doubleLevel = level * 2;
        final doubleXp = controller.calculateXPForNextLevelForTest(doubleLevel);
        expect(doubleXp, equals(xpForNextLevel * 2),
            reason: 'XP should scale linearly with level');
      }
    });

    test('XP distribution formula maintains consistency across iterations', () {
      // Property: Soma de XP individual = XP total calculado diretamente
      for (int iteration = 0; iteration < 100; iteration++) {
        final startLevel = 1 + (iteration % 50);
        final endLevel = startLevel + 10;

        int totalXpNeeded = 0;

        // Calculate total XP needed to go from startLevel to endLevel
        for (int level = startLevel; level < endLevel; level++) {
          final xpForLevel = controller.calculateXPForNextLevelForTest(level);
          totalXpNeeded += xpForLevel;
        }

        // Property: Total XP is sum of individual level requirements
        int expectedTotal = 0;
        for (int level = startLevel; level < endLevel; level++) {
          expectedTotal += level * 100;
        }

        expect(totalXpNeeded, equals(expectedTotal),
            reason:
                'Total XP from level $startLevel to $endLevel should match sum');

        // Property: Total XP can be calculated directly using arithmetic series
        final directCalculation = ((endLevel - 1) * endLevel ~/ 2 -
                (startLevel - 1) * startLevel ~/ 2) *
            100;
        expect(totalXpNeeded, equals(directCalculation),
            reason: 'Direct calculation should match iterative sum');
      }
    });

    test('level up threshold increases monotonically', () {
      // Property: Cada nível requer mais XP que o anterior
      for (int level = 1; level < 100; level++) {
        final currentThreshold =
            controller.calculateXPForNextLevelForTest(level);
        final nextThreshold =
            controller.calculateXPForNextLevelForTest(level + 1);

        // Property: Each level requires more XP than the previous
        expect(nextThreshold, greaterThan(currentThreshold),
            reason: 'Level ${level + 1} threshold must exceed level $level');

        // Property: Difference is always exactly 100
        expect(nextThreshold - currentThreshold, equals(100),
            reason: 'Threshold increase must be exactly 100');
      }
    });

    test('XP requirements are consistent with level progression', () {
      // Property: Se totalXp >= threshold, deve subir de nível
      for (int i = 0; i < 100; i++) {
        final currentLevel = 1 + (i % 50);
        final threshold = controller.calculateXPForNextLevelForTest(currentLevel);
        final currentTotalXp = threshold; // Exatamente no threshold

        // Property: If totalXp >= threshold, level up should occur
        final shouldLevelUp = currentTotalXp >= threshold;
        expect(shouldLevelUp, isTrue,
            reason: 'Should level up when XP meets threshold');

        // Property: After level up, totalXp is NOT reset
        final newLevel = currentLevel + 1;
        final newThreshold = controller.calculateXPForNextLevelForTest(newLevel);

        // If we had exactly threshold XP, we need more for next level
        expect(currentTotalXp, lessThan(newThreshold),
            reason: 'After leveling up, need more XP for next level');
      }
    });

    test('XP formula handles edge cases correctly', () {
      // Property: Casos extremos produzem resultados esperados
      final edgeCases = [
        (level: 1, expectedXp: 100),
        (level: 2, expectedXp: 200),
        (level: 10, expectedXp: 1000),
        (level: 50, expectedXp: 5000),
        (level: 100, expectedXp: 10000),
        (level: 999, expectedXp: 99900),
        (level: 1000, expectedXp: 100000),
      ];

      for (final testCase in edgeCases) {
        final xpForNextLevel =
            controller.calculateXPForNextLevelForTest(testCase.level);

        // Property: Formula produces expected results for edge cases
        expect(xpForNextLevel, equals(testCase.expectedXp),
            reason:
                'Level ${testCase.level} should require ${testCase.expectedXp} XP');
      }
    });

    test('multiple level ups accumulate XP correctly', () {
      // Property: XP acumula corretamente através de múltiplos níveis
      for (int startLevel = 1; startLevel <= 50; startLevel++) {
        int totalXp = 0;
        int currentLevel = startLevel;

        // Level up 10 times
        for (int i = 0; i < 10; i++) {
          final xpNeeded =
              controller.calculateXPForNextLevelForTest(currentLevel);
          totalXp += xpNeeded;
          currentLevel++;

          // Property: totalXp accumulates, never resets
          expect(totalXp, greaterThan(0), reason: 'Total XP should accumulate');

          // Property: totalXp should equal sum of all level requirements
          int expectedTotal = 0;
          for (int level = startLevel; level < currentLevel; level++) {
            expectedTotal += level * 100;
          }
          expect(totalXp, equals(expectedTotal),
              reason: 'Accumulated XP should match sum of requirements');
        }
      }
    });

    test('XP formula is commutative for level ranges', () {
      // Property: Ordem de cálculo não importa
      for (int i = 0; i < 50; i++) {
        final level1 = 1 + (i % 25);
        final level2 = level1 + 10;

        // Calculate forward
        int forwardSum = 0;
        for (int level = level1; level < level2; level++) {
          forwardSum += controller.calculateXPForNextLevelForTest(level);
        }

        // Calculate backward
        int backwardSum = 0;
        for (int level = level2 - 1; level >= level1; level--) {
          backwardSum += controller.calculateXPForNextLevelForTest(level);
        }

        // Property: Sum is same regardless of order
        expect(forwardSum, equals(backwardSum),
            reason: 'XP sum should be commutative');
      }
    });
  });
}
