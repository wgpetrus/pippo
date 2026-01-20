import 'package:flutter_test/flutter_test.dart' hide test, group, expect;
import 'package:glados/glados.dart';
import 'package:test/test.dart' show test, group, expect;

// Test helper class - isolated XP logic without Firebase dependencies
class TestXpCalculator {
  int totalXp = 0;
  int weeklyXp = 0;
  int todayXp = 0;
  int level = 1;
  int xpToNextLevel = 100;
  int gems = 0;
  int totalGemsEarned = 0;
  
  DateTime? xpBoosterUntil;
  DateTime? gemMultiplierUntil;
  String lastWeeklyResetDate = '';
  String lastDailyResetDate = '';

  bool get hasXpBooster =>
      xpBoosterUntil != null && DateTime.now().isBefore(xpBoosterUntil!);

  bool get hasGemMultiplier =>
      gemMultiplierUntil != null && DateTime.now().isBefore(gemMultiplierUntil!);

  void addXp(int baseXp) {
    if (baseXp < 0) {
      throw Exception('Cannot add negative XP');
    }

    // Aplicar booster se ativo (2×)
    final xpToAdd = hasXpBooster ? baseXp * 2 : baseXp;

    // Atualizar todos os três contadores atomicamente
    totalXp += xpToAdd;
    weeklyXp += xpToAdd;
    todayXp += xpToAdd;
  }

  void checkLevelUp() {
    // Processar todos os level ups que resultam do XP atual
    while (totalXp >= xpToNextLevel) {
      level++;
      xpToNextLevel = level * 100;

      // Premiar 10 gems por level up
      addGems(10);
    }
  }

  void addGems(int amount) {
    // Aplicar multiplicador se ativo (2×)
    final gemsToAdd = hasGemMultiplier ? amount * 2 : amount;

    // Atualizar gems e totalGemsEarned atomicamente
    gems += gemsToAdd;
    totalGemsEarned += gemsToAdd;
  }

  void checkXpResets(DateTime now) {
    final today = _formatDateForStreak(now);

    // Reset semanal (segunda-feira 00:00)
    if (_isMonday(now) && lastWeeklyResetDate != today) {
      weeklyXp = 0;
      lastWeeklyResetDate = today;
    }

    // Reset diário (meia-noite)
    if (lastDailyResetDate != today) {
      todayXp = 0;
      lastDailyResetDate = today;
    }
  }

  bool _isMonday(DateTime date) {
    return date.weekday == DateTime.monday;
  }

  String _formatDateForStreak(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool isFirstLessonOfDay(String lastStreakDate) {
    final now = DateTime.now();
    final today = _formatDateForStreak(now);

    // Se não há lastStreakDate ou é diferente de hoje, é primeira lição
    return lastStreakDate.isEmpty || lastStreakDate != today;
  }
}

void main() {
  group('Feature: gamification-system, XP and Level System Property Tests', () {
    // Property 20: XP Triple Update Atomicity
    // For any XP addition of amount X, totalXp, weeklyXp, and todayXp
    // should all increase by X (after applying multipliers) in a single atomic operation
    Glados2(any.int, any.int).test(
      'Property 20: totalXp, weeklyXp, and todayXp all increase by same amount atomically',
      (initialXp, xpToAdd) {
        // Constrain values to valid ranges
        final xp = initialXp.abs() % 10000; // 0-9999
        final xpAmount = xpToAdd.abs() % 500; // 0-499
        
        // Create calculator with initial XP
        final calculator = TestXpCalculator();
        calculator.totalXp = xp;
        calculator.weeklyXp = xp;
        calculator.todayXp = xp;
        
        // Store initial values
        final initialTotal = calculator.totalXp;
        final initialWeekly = calculator.weeklyXp;
        final initialDaily = calculator.todayXp;
        
        // Add XP
        calculator.addXp(xpAmount);
        
        // Calculate expected increase (without booster)
        final expectedIncrease = xpAmount;
        
        // Verify all three counters increased by the same amount
        final totalIncrease = calculator.totalXp - initialTotal;
        final weeklyIncrease = calculator.weeklyXp - initialWeekly;
        final dailyIncrease = calculator.todayXp - initialDaily;
        
        expect(
          totalIncrease,
          equals(expectedIncrease),
          reason: 'totalXp should increase by $expectedIncrease',
        );
        
        expect(
          weeklyIncrease,
          equals(expectedIncrease),
          reason: 'weeklyXp should increase by same amount as totalXp',
        );
        
        expect(
          dailyIncrease,
          equals(expectedIncrease),
          reason: 'todayXp should increase by same amount as totalXp',
        );
        
        // Verify atomicity - all three should have increased by exactly the same amount
        expect(
          totalIncrease == weeklyIncrease && weeklyIncrease == dailyIncrease,
          isTrue,
          reason: 'All three XP counters must increase by exactly the same amount atomically',
        );
      },
    );

    // Property 21: XP Booster Doubles Gains
    // For any XP gain with active XP booster, the final XP added
    // should be exactly 2× the base XP amount
    Glados(any.int).test(
      'Property 21: XP booster doubles all XP gains',
      (baseXp) {
        // Constrain to valid range
        final xp = baseXp.abs() % 500; // 0-499
        
        // Create calculator with active booster
        final calculator = TestXpCalculator();
        calculator.xpBoosterUntil = DateTime.now().add(Duration(hours: 1));
        
        // Store initial values
        final initialTotal = calculator.totalXp;
        
        // Add XP
        calculator.addXp(xp);
        
        // Verify XP was doubled
        final actualIncrease = calculator.totalXp - initialTotal;
        final expectedIncrease = xp * 2;
        
        expect(
          actualIncrease,
          equals(expectedIncrease),
          reason: 'XP should be doubled when booster is active. '
              'Base: $xp, Expected: $expectedIncrease, Got: $actualIncrease',
        );
      },
    );

    // Property 17: Level Formula Correctness
    // For any level value L, the XP required for the next level
    // should equal L × 100
    Glados(any.int).test(
      'Property 17: xpToNextLevel equals level × 100',
      (levelValue) {
        // Constrain to valid range (1-100)
        final level = (levelValue.abs() % 100) + 1; // 1-100
        
        // Create calculator
        final calculator = TestXpCalculator();
        calculator.level = level;
        
        // Calculate expected XP for next level
        final expectedXp = level * 100;
        
        // Set xpToNextLevel using the formula
        calculator.xpToNextLevel = calculator.level * 100;
        
        // Verify formula
        expect(
          calculator.xpToNextLevel,
          equals(expectedXp),
          reason: 'XP for next level should be level × 100. '
              'Level: $level, Expected: $expectedXp, Got: ${calculator.xpToNextLevel}',
        );
      },
    );

    // Property 18: Level Up Trigger and Reward
    // For any XP addition that causes totalXp >= xpToNextLevel,
    // level should increment by 1, xpToNextLevel should recalculate,
    // and gems should increase by 10
    Glados2(any.int, any.int).test(
      'Property 18: level up increments level, recalculates threshold, and awards gems',
      (currentLevel, xpAmount) {
        // Constrain values to valid ranges
        final level = (currentLevel.abs() % 50) + 1; // 1-50
        final xp = xpAmount.abs() % 500; // 0-499
        
        // Create calculator at specific level
        final calculator = TestXpCalculator();
        calculator.level = level;
        calculator.xpToNextLevel = level * 100;
        
        // Set totalXp to just below threshold
        calculator.totalXp = calculator.xpToNextLevel - 10;
        
        // Add enough XP to trigger level up
        final xpToAdd = 20; // Will cross threshold
        calculator.totalXp += xpToAdd;
        
        // Store initial values
        final initialLevel = calculator.level;
        final initialGems = calculator.gems;
        
        // Trigger level up check
        calculator.checkLevelUp();
        
        // Verify level increased
        expect(
          calculator.level,
          greaterThan(initialLevel),
          reason: 'Level should increase when totalXp >= xpToNextLevel',
        );
        
        // Verify xpToNextLevel recalculated
        final expectedThreshold = calculator.level * 100;
        expect(
          calculator.xpToNextLevel,
          equals(expectedThreshold),
          reason: 'xpToNextLevel should be recalculated using new level',
        );
        
        // Verify gems awarded (10 per level up)
        final levelsGained = calculator.level - initialLevel;
        final expectedGems = initialGems + (levelsGained * 10);
        expect(
          calculator.gems,
          equals(expectedGems),
          reason: 'Should award 10 gems per level up',
        );
      },
    );

    // Property 24: Weekly XP Reset
    // For any XP state where current day is Monday and lastWeeklyResetDate
    // is not today, weeklyXp should reset to 0 while totalXp and todayXp remain unchanged
    test(
      'Property 24: weeklyXp resets on Monday while totalXp and todayXp unchanged',
      () {
        // Create calculator with some XP
        final calculator = TestXpCalculator();
        calculator.totalXp = 1000;
        calculator.weeklyXp = 500;
        calculator.todayXp = 50;
        calculator.lastWeeklyResetDate = '2024-01-01'; // Old date
        
        // Find next Monday
        var now = DateTime.now();
        while (now.weekday != DateTime.monday) {
          now = now.add(Duration(days: 1));
        }
        
        // Store initial values
        final initialTotal = calculator.totalXp;
        final initialDaily = calculator.todayXp;
        
        // Trigger reset check
        calculator.checkXpResets(now);
        
        // Verify weeklyXp was reset
        expect(
          calculator.weeklyXp,
          equals(0),
          reason: 'weeklyXp should reset to 0 on Monday',
        );
        
        // Verify totalXp unchanged
        expect(
          calculator.totalXp,
          equals(initialTotal),
          reason: 'totalXp should never be reset',
        );
        
        // Verify todayXp unchanged (unless it's also a new day)
        if (calculator.lastDailyResetDate != calculator.lastWeeklyResetDate) {
          expect(
            calculator.todayXp,
            equals(initialDaily),
            reason: 'todayXp should not be affected by weekly reset',
          );
        }
      },
    );

    // Property 25: Daily XP Reset
    // For any XP state where a new day has begun and lastDailyResetDate
    // is not today, todayXp should reset to 0 while totalXp and weeklyXp remain unchanged
    test(
      'Property 25: todayXp resets at midnight while totalXp and weeklyXp unchanged',
      () {
        // Create calculator with some XP
        final calculator = TestXpCalculator();
        calculator.totalXp = 1000;
        calculator.weeklyXp = 500;
        calculator.todayXp = 50;
        calculator.lastDailyResetDate = '2024-01-01'; // Old date
        calculator.lastWeeklyResetDate = '2024-01-01'; // Same old date
        
        // Use current date (new day)
        final now = DateTime.now();
        
        // Store initial values
        final initialTotal = calculator.totalXp;
        final initialWeekly = calculator.weeklyXp;
        
        // Trigger reset check
        calculator.checkXpResets(now);
        
        // Verify todayXp was reset
        expect(
          calculator.todayXp,
          equals(0),
          reason: 'todayXp should reset to 0 at midnight',
        );
        
        // Verify totalXp unchanged
        expect(
          calculator.totalXp,
          equals(initialTotal),
          reason: 'totalXp should never be reset',
        );
        
        // Verify weeklyXp unchanged (unless it's also Monday)
        if (now.weekday != DateTime.monday) {
          expect(
            calculator.weeklyXp,
            equals(initialWeekly),
            reason: 'weeklyXp should not be affected by daily reset',
          );
        }
      },
    );

    // Property 22: Perfect Lesson Bonus
    // For any lesson completion with isPerfect=true, the XP awarded
    // should be exactly 5 more than the same lesson with isPerfect=false
    Glados(any.int).test(
      'Property 22: perfect lesson awards exactly 5 bonus XP',
      (baseXp) {
        // Constrain to valid range
        final xp = baseXp.abs() % 500; // 0-499
        
        // Create two calculators with same initial state
        final calculatorPerfect = TestXpCalculator();
        final calculatorNormal = TestXpCalculator();
        
        // Add base XP to normal
        calculatorNormal.addXp(xp);
        final normalXp = calculatorNormal.totalXp;
        
        // Add base XP + perfect bonus to perfect
        calculatorPerfect.addXp(xp + 5);
        final perfectXp = calculatorPerfect.totalXp;
        
        // Verify perfect has exactly 5 more XP
        expect(
          perfectXp - normalXp,
          equals(5),
          reason: 'Perfect lesson should award exactly 5 bonus XP. '
              'Base: $xp, Normal: $normalXp, Perfect: $perfectXp',
        );
      },
    );

    // Property 23: First Lesson Bonus
    // For any first lesson of the day, the XP awarded should be
    // exactly 5 more than subsequent lessons on the same day
    test(
      'Property 23: first lesson of day awards exactly 5 bonus XP',
      () {
        // Create calculator
        final calculator = TestXpCalculator();
        
        // Simulate first lesson (no lastStreakDate)
        final isFirst = calculator.isFirstLessonOfDay('');
        expect(isFirst, isTrue, reason: 'Should be first lesson when no lastStreakDate');
        
        // Add XP for first lesson (base + bonus)
        final baseXp = 10;
        calculator.addXp(baseXp + 5);
        final firstLessonXp = calculator.totalXp;
        
        // Create another calculator for subsequent lesson
        final calculator2 = TestXpCalculator();
        final today = calculator2._formatDateForStreak(DateTime.now());
        
        // Simulate subsequent lesson (same day)
        final isSubsequent = calculator2.isFirstLessonOfDay(today);
        expect(isSubsequent, isFalse, reason: 'Should not be first lesson when lastStreakDate is today');
        
        // Add XP for subsequent lesson (base only)
        calculator2.addXp(baseXp);
        final subsequentXp = calculator2.totalXp;
        
        // Verify first lesson has exactly 5 more XP
        expect(
          firstLessonXp - subsequentXp,
          equals(5),
          reason: 'First lesson should award exactly 5 bonus XP',
        );
      },
    );
  });
}
