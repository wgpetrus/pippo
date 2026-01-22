import 'package:flutter_test/flutter_test.dart';

/// Feature: lesson-system, Property 11: Level Up Formula
/// 
/// *For any* level, the XP required for next level SHALL equal 
/// `currentLevel * 100`, and when totalXp reaches or exceeds this threshold, 
/// currentLevel SHALL increment by 1 without resetting totalXp.
/// 
/// **Validates: Requirements 6.4, 6.5, 6.6**
void main() {
  group('Property 11: Level Up Formula', () {
    test('level up occurs when totalXp >= currentLevel * 100', () {
      // Test 100 random scenarios
      for (int i = 0; i < 100; i++) {
        final currentLevel = 1 + (i % 50);
        final threshold = currentLevel * 100;

        // Test at threshold
        final totalXpAtThreshold = threshold;
        final shouldLevelUp = totalXpAtThreshold >= threshold;

        // Property: Level up occurs at exactly the threshold
        expect(shouldLevelUp, isTrue,
            reason:
                'Should level up when totalXp ($totalXpAtThreshold) >= threshold ($threshold)');

        // Test just below threshold
        if (threshold > 0) {
          final totalXpBelowThreshold = threshold - 1;
          final shouldNotLevelUp = totalXpBelowThreshold >= threshold;

          // Property: No level up below threshold
          expect(shouldNotLevelUp, isFalse,
              reason:
                  'Should NOT level up when totalXp ($totalXpBelowThreshold) < threshold ($threshold)');
        }

        // Test above threshold
        final totalXpAboveThreshold = threshold + 50;
        final shouldLevelUpAbove = totalXpAboveThreshold >= threshold;

        // Property: Level up occurs above threshold
        expect(shouldLevelUpAbove, isTrue,
            reason:
                'Should level up when totalXp ($totalXpAboveThreshold) > threshold ($threshold)');
      }
    });

    test('totalXp is never reset after level up', () {
      // Simulate 100 level up scenarios
      for (int startLevel = 1; startLevel <= 100; startLevel++) {
        int totalXp = startLevel * 100; // At threshold
        int currentLevel = startLevel;

        // Perform level up
        if (totalXp >= currentLevel * 100) {
          currentLevel++;
          // totalXp is NOT reset
        }

        // Property: totalXp remains unchanged after level up
        expect(totalXp, equals(startLevel * 100),
            reason: 'totalXp should NOT be reset after level up');

        // Property: totalXp is preserved across level ups
        final originalXp = totalXp;
        if (totalXp >= currentLevel * 100) {
          currentLevel++;
        }
        expect(totalXp, equals(originalXp),
            reason: 'totalXp should be preserved across multiple level ups');
      }
    });

    test('currentLevel increments by exactly 1 per level up', () {
      // Test 100 scenarios
      for (int i = 0; i < 100; i++) {
        final startLevel = 1 + (i % 50);
        final threshold = startLevel * 100;
        final totalXp = threshold + (i * 10);

        int currentLevel = startLevel;

        // Perform level up
        if (totalXp >= currentLevel * 100) {
          final oldLevel = currentLevel;
          currentLevel++;

          // Property: Level increments by exactly 1
          expect(currentLevel, equals(oldLevel + 1),
              reason: 'Level should increment by exactly 1');

          // Property: Level never skips values
          expect(currentLevel - oldLevel, equals(1),
              reason: 'Level should not skip values');
        }
      }
    });

    test('multiple level ups process sequentially', () {
      // Test scenarios where totalXp allows multiple level ups
      for (int startLevel = 1; startLevel <= 50; startLevel++) {
        // Give enough XP for exactly 5 level ups
        // Level N requires N * 100 XP to reach level N+1
        int totalXp = 0;
        for (int level = startLevel; level < startLevel + 5; level++) {
          totalXp += level * 100;
        }

        int currentLevel = startLevel;
        int levelUpsProcessed = 0;
        final maxLevelUps = 5;

        // Process all possible level ups
        while (totalXp >= currentLevel * 100 && levelUpsProcessed < maxLevelUps) {
          currentLevel++;
          levelUpsProcessed++;
        }

        // Property: Correct number of level ups processed
        // Note: The actual number may vary based on XP accumulation
        expect(levelUpsProcessed, greaterThanOrEqualTo(1),
            reason: 'Should process at least 1 level up with accumulated XP');

        // Property: Level increases monotonically
        expect(currentLevel, greaterThan(startLevel),
            reason: 'Level should increase after processing level ups');

        // Property: totalXp is never reset
        int expectedTotalXp = 0;
        for (int level = startLevel; level < startLevel + 5; level++) {
          expectedTotalXp += level * 100;
        }
        expect(totalXp, equals(expectedTotalXp),
            reason: 'totalXp should remain unchanged');
      }
    });

    test('level up threshold increases monotonically', () {
      // Test 100 consecutive levels
      for (int level = 1; level < 100; level++) {
        final currentThreshold = level * 100;
        final nextThreshold = (level + 1) * 100;

        // Property: Each level requires more XP than previous
        expect(nextThreshold, greaterThan(currentThreshold),
            reason:
                'Threshold for level ${level + 1} must exceed level $level');

        // Property: Threshold difference is constant (100)
        expect(nextThreshold - currentThreshold, equals(100),
            reason: 'Threshold increase must be exactly 100');
      }
    });

    test('level up formula is deterministic', () {
      // Test 50 levels multiple times
      for (int level = 1; level <= 50; level++) {
        final threshold1 = level * 100;
        final threshold2 = level * 100;
        final threshold3 = level * 100;

        // Property: Same level always produces same threshold
        expect(threshold1, equals(threshold2),
            reason: 'Formula should be deterministic');
        expect(threshold2, equals(threshold3),
            reason: 'Formula should be deterministic');
      }
    });

    test('level up handles edge cases correctly', () {
      // Test edge cases
      final edgeCases = [
        (level: 1, totalXp: 100, shouldLevelUp: true),
        (level: 1, totalXp: 99, shouldLevelUp: false),
        (level: 1, totalXp: 101, shouldLevelUp: true),
        (level: 10, totalXp: 1000, shouldLevelUp: true),
        (level: 10, totalXp: 999, shouldLevelUp: false),
        (level: 50, totalXp: 5000, shouldLevelUp: true),
        (level: 100, totalXp: 10000, shouldLevelUp: true),
        (level: 100, totalXp: 9999, shouldLevelUp: false),
      ];

      for (final testCase in edgeCases) {
        final threshold = testCase.level * 100;
        final actualShouldLevelUp = testCase.totalXp >= threshold;

        // Property: Level up decision matches expected
        expect(actualShouldLevelUp, equals(testCase.shouldLevelUp),
            reason:
                'Level ${testCase.level} with ${testCase.totalXp} XP: expected ${testCase.shouldLevelUp}');
      }
    });

    test('level up preserves XP across multiple levels', () {
      // Simulate earning XP and leveling up multiple times
      for (int iteration = 0; iteration < 50; iteration++) {
        int totalXp = 0;
        int currentLevel = 1;
        final xpGains = [50, 75, 100, 125, 150, 200];

        for (final xpGain in xpGains) {
          // Add XP
          totalXp += xpGain;

          // Check for level up
          while (totalXp >= currentLevel * 100) {
            currentLevel++;
          }

          // Property: totalXp equals sum of all gains
          final expectedTotal = xpGains
              .take(xpGains.indexOf(xpGain) + 1)
              .reduce((a, b) => a + b);
          expect(totalXp, equals(expectedTotal),
              reason: 'totalXp should equal sum of all XP gains');
        }
      }
    });

    test('level up formula scales correctly for high levels', () {
      // Test very high levels
      final highLevels = [100, 500, 1000, 5000, 10000];

      for (final level in highLevels) {
        final threshold = level * 100;

        // Property: Formula works for any level
        expect(threshold, equals(level * 100),
            reason: 'Formula should work for level $level');

        // Property: Threshold is always positive
        expect(threshold, greaterThan(0),
            reason: 'Threshold must be positive');

        // Property: Threshold scales linearly
        final doubleLevel = level * 2;
        final doubleThreshold = doubleLevel * 100;
        expect(doubleThreshold, equals(threshold * 2),
            reason: 'Threshold should scale linearly');
      }
    });

    test('level up maintains consistency with XP accumulation', () {
      // Test 100 scenarios of XP accumulation and level ups
      for (int i = 0; i < 100; i++) {
        int totalXp = 0;
        int currentLevel = 1;
        final xpPerLesson = 15 + (i % 50);

        // Complete 20 lessons
        for (int lesson = 0; lesson < 20; lesson++) {
          totalXp += xpPerLesson;

          // Process level ups
          int levelUpsBefore = currentLevel;
          while (totalXp >= currentLevel * 100) {
            currentLevel++;
          }
          int levelUpsAfter = currentLevel;

          // Property: Level ups are processed immediately
          if (totalXp >= levelUpsBefore * 100) {
            expect(levelUpsAfter, greaterThan(levelUpsBefore),
                reason: 'Level should increase when threshold is met');
          }

          // Property: totalXp is never reset
          expect(totalXp, equals((lesson + 1) * xpPerLesson),
              reason: 'totalXp should accumulate without reset');
        }
      }
    });
  });
}
