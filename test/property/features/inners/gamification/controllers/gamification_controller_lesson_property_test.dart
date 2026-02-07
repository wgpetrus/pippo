import 'package:glados/glados.dart';

// Test helper class - isolated lesson completion logic without Firebase dependencies
class TestLessonCompletionCalculator {
  int totalXp = 0;
  int weeklyXp = 0;
  int todayXp = 0;
  int level = 1;
  int xpToNextLevel = 100;
  int gems = 0;
  int totalGemsEarned = 0;
  int currentStreak = 0;
  int longestStreak = 0;
  
  DateTime? xpBoosterUntil;
  DateTime? gemMultiplierUntil;
  String lastStreakDate = '';
  List<int> milestonesReached = [];

  bool get hasXpBooster =>
      xpBoosterUntil != null && DateTime.now().isBefore(xpBoosterUntil!);

  bool get hasGemMultiplier =>
      gemMultiplierUntil != null && DateTime.now().isBefore(gemMultiplierUntil!);

  // Track operation order for testing
  List<String> operationOrder = [];

  void addXp(int baseXp) {
    operationOrder.add('addXp');
    
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

  void addGems(int amount) {
    operationOrder.add('addGems');
    
    if (amount < 0) {
      throw Exception('Cannot add negative gems');
    }

    // Aplicar multiplicador se ativo (2×)
    final gemsToAdd = hasGemMultiplier ? amount * 2 : amount;

    // Atualizar gems e totalGemsEarned atomicamente
    gems += gemsToAdd;
    totalGemsEarned += gemsToAdd;
  }

  void updateStreak() {
    operationOrder.add('updateStreak');
    
    final now = DateTime.now();
    final today = _formatDateForStreak(now);

    // Primeiro caso: primeira lição ever
    if (lastStreakDate.isEmpty) {
      currentStreak = 1;
      longestStreak = 1;
      lastStreakDate = today;
      return;
    }

    // Segundo caso: já completou hoje
    if (lastStreakDate == today) {
      return;
    }

    // Calcular diferença de dias
    final lastDateTime = DateTime.parse(lastStreakDate);
    final daysDifference = now.difference(lastDateTime).inDays;

    // Terceiro caso: dia consecutivo
    if (daysDifference == 1) {
      currentStreak++;
      longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
      lastStreakDate = today;
      return;
    }

    // Streak quebrado - reset
    currentStreak = 1;
    lastStreakDate = today;
  }

  void checkStreakMilestones() {
    operationOrder.add('checkStreakMilestones');
    
    // Milestones: 7, 14, 30, 100 dias
    // Recompensas: 5, 10, 25, 50 gems
    final milestones = {
      7: 5,
      14: 10,
      30: 25,
      100: 50,
    };

    for (final entry in milestones.entries) {
      final milestone = entry.key;
      final reward = entry.value;

      // Se atingiu o milestone e ainda não foi premiado
      if (currentStreak == milestone && !milestonesReached.contains(milestone)) {
        // Adicionar gems
        gems += reward;
        totalGemsEarned += reward;

        // Marcar milestone como alcançado
        milestonesReached.add(milestone);
      }
    }
  }

  void checkLevelUp() {
    operationOrder.add('checkLevelUp');
    
    // Processar todos os level ups que resultam do XP atual
    while (totalXp >= xpToNextLevel) {
      level++;
      xpToNextLevel = level * 100;

      // Premiar 10 gems por level up
      addGems(10);
    }
  }

  bool isFirstLessonOfDay() {
    final now = DateTime.now();
    final today = _formatDateForStreak(now);

    // Se não há lastStreakDate ou é diferente de hoje, é primeira lição
    return lastStreakDate.isEmpty || lastStreakDate != today;
  }

  String _formatDateForStreak(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Simulate complete lesson flow
  void completeLessonFlow(int baseXp, int baseGems, bool isPerfect) {
    operationOrder.clear();
    
    // 1. Calculate total rewards (base + bonuses)
    var totalXpReward = baseXp;
    var totalGemsReward = baseGems;

    // Perfect lesson bonus (+5 XP)
    if (isPerfect) {
      totalXpReward += 5;
    }

    // First lesson of day bonus (+5 XP)
    final isFirstLesson = isFirstLessonOfDay();
    if (isFirstLesson) {
      totalXpReward += 5;
    }

    // 2. Add XP (with booster if active)
    addXp(totalXpReward);

    // 3. Add gems (with multiplier if active)
    addGems(totalGemsReward);

    // 4. Update streak if first lesson of day
    if (isFirstLesson) {
      updateStreak();
      checkStreakMilestones();
    }

    // 5. Check level up
    checkLevelUp();
  }
}

void main() {
  group('Feature: gamification-system, Lesson Completion Flow Property Tests', () {
    // Property 34: Reward Calculation Order
    // For any lesson completion, operations should execute in this exact order:
    // calculate rewards → apply multipliers → add XP → add gems → update streak (if first of day) → check level up
    Glados3(any.int, any.int, any.bool).test(
      'Property 34: operations execute in correct order',
      (baseXp, baseGems, isPerfect) {
        // Constrain values to valid ranges
        final xp = baseXp.abs() % 100; // 0-99
        final gems = baseGems.abs() % 10; // 0-9
        
        // Create calculator
        final calculator = TestLessonCompletionCalculator();
        
        // Complete lesson
        calculator.completeLessonFlow(xp, gems, isPerfect);
        
        // Verify operation order
        final operations = calculator.operationOrder;
        
        // Must have at least addXp and addGems
        expect(
          operations.contains('addXp'),
          isTrue,
          reason: 'addXp must be called',
        );
        
        expect(
          operations.contains('addGems'),
          isTrue,
          reason: 'addGems must be called',
        );
        
        // addXp must come before addGems
        final xpIndex = operations.indexOf('addXp');
        final gemsIndex = operations.indexOf('addGems');
        
        expect(
          xpIndex < gemsIndex,
          isTrue,
          reason: 'addXp must be called before addGems. Order: $operations',
        );
        
        // If streak was updated, it must come after addGems
        if (operations.contains('updateStreak')) {
          final streakIndex = operations.indexOf('updateStreak');
          expect(
            streakIndex > gemsIndex,
            isTrue,
            reason: 'updateStreak must be called after addGems. Order: $operations',
          );
          
          // checkStreakMilestones must come after updateStreak
          if (operations.contains('checkStreakMilestones')) {
            final milestonesIndex = operations.indexOf('checkStreakMilestones');
            expect(
              milestonesIndex > streakIndex,
              isTrue,
              reason: 'checkStreakMilestones must be called after updateStreak. Order: $operations',
            );
          }
        }
        
        // checkLevelUp must be last
        if (operations.contains('checkLevelUp')) {
          final levelUpIndex = operations.indexOf('checkLevelUp');
          expect(
            levelUpIndex,
            equals(operations.length - 1),
            reason: 'checkLevelUp must be called last. Order: $operations',
          );
        }
      },
    );

    // Property 34 (continued): Verify bonuses are calculated before multipliers
    Glados2(any.int, any.int).test(
      'Property 34: bonuses calculated before multipliers applied',
      (baseXp, baseGems) {
        // Constrain values to valid ranges
        final xp = (baseXp.abs() % 50) + 10; // 10-59
        final gems = (baseGems.abs() % 5) + 1; // 1-5
        
        // Create calculator with active booster and existing streak (not first lesson)
        final calculator = TestLessonCompletionCalculator();
        calculator.xpBoosterUntil = DateTime.now().add(Duration(hours: 1));
        
        // Set lastStreakDate to today so it's NOT first lesson of day
        final today = calculator._formatDateForStreak(DateTime.now());
        calculator.lastStreakDate = today;
        calculator.currentStreak = 5;
        
        // Complete perfect lesson (should get +5 perfect bonus only, before doubling)
        final initialXp = calculator.totalXp;
        calculator.completeLessonFlow(xp, gems, true);
        
        // Calculate expected XP: (base + perfect bonus) × 2 (booster)
        // No first lesson bonus since lastStreakDate is today
        final expectedXp = (xp + 5) * 2;
        final actualXp = calculator.totalXp - initialXp;
        
        expect(
          actualXp,
          equals(expectedXp),
          reason: 'Perfect bonus should be added before booster multiplier. '
              'Base: $xp, Expected: $expectedXp, Got: $actualXp',
        );
      },
    );

    // Property 34 (continued): Verify first lesson bonus is calculated correctly
    Glados(any.int).test(
      'Property 34: first lesson bonus calculated before multipliers',
      (baseXp) {
        // Constrain to valid range
        final xp = (baseXp.abs() % 50) + 10; // 10-59
        
        // Create calculator with active booster (first lesson)
        final calculator = TestLessonCompletionCalculator();
        calculator.xpBoosterUntil = DateTime.now().add(Duration(hours: 1));
        
        // Complete first lesson (should get +5 bonus before doubling)
        final initialXp = calculator.totalXp;
        calculator.completeLessonFlow(xp, 1, false);
        
        // Calculate expected XP: (base + first lesson bonus) × 2 (booster)
        final expectedXp = (xp + 5) * 2;
        final actualXp = calculator.totalXp - initialXp;
        
        expect(
          actualXp,
          equals(expectedXp),
          reason: 'First lesson bonus should be added before booster multiplier. '
              'Base: $xp, Expected: $expectedXp, Got: $actualXp',
        );
      },
    );

    // Property 34 (continued): Verify streak only updates on first lesson
    Glados2(any.int, any.int).test(
      'Property 34: streak only updates if first lesson of day',
      (baseXp, baseGems) {
        // Constrain values to valid ranges
        final xp = baseXp.abs() % 100; // 0-99
        final gems = baseGems.abs() % 10; // 0-9
        
        // Create calculator with existing streak from today
        final calculator = TestLessonCompletionCalculator();
        final today = calculator._formatDateForStreak(DateTime.now());
        calculator.lastStreakDate = today;
        calculator.currentStreak = 5;
        
        // Complete lesson (not first of day)
        calculator.completeLessonFlow(xp, gems, false);
        
        // Verify streak was NOT updated
        expect(
          calculator.currentStreak,
          equals(5),
          reason: 'Streak should not update if not first lesson of day',
        );
        
        // Verify updateStreak was not called
        expect(
          calculator.operationOrder.contains('updateStreak'),
          isFalse,
          reason: 'updateStreak should not be called if not first lesson of day',
        );
      },
    );

    // Property 34 (continued): Verify level up processes all levels
    test(
      'Property 34: level up processes all levels sequentially',
      () {
        // Create calculator near level up
        final calculator = TestLessonCompletionCalculator();
        calculator.level = 1;
        calculator.xpToNextLevel = 100;
        calculator.totalXp = 50;
        
        // Complete lesson with enough XP to level up multiple times
        // Starting: Level 1, 50 XP (need 100 for level 2)
        // Add 250 XP → Total 300 XP
        // Level 2 at 100 XP (threshold becomes 200)
        // Level 3 at 200 XP (threshold becomes 300)
        // Level 4 at 300 XP (threshold becomes 400)
        calculator.completeLessonFlow(250, 1, false);
        
        // Verify reached level 4 (not 3, because 300 XP = exactly level 4 threshold)
        expect(
          calculator.level,
          equals(4),
          reason: 'Should process multiple level ups sequentially. '
              'Started at level 1 with 50 XP, added 250 XP = 300 total XP = level 4',
        );
        
        // Verify xpToNextLevel recalculated for level 4
        expect(
          calculator.xpToNextLevel,
          equals(400),
          reason: 'xpToNextLevel should be recalculated for new level (4 × 100 = 400)',
        );
        
        // Verify gems awarded for each level up (10 per level × 3 levels)
        // Level 1→2, 2→3, 3→4 = 3 level ups = 30 gems + 1 from lesson
        expect(
          calculator.gems,
          greaterThanOrEqualTo(30 + 1),
          reason: 'Should award 10 gems for each of the 3 level ups (30) plus lesson gems (1)',
        );
      },
    );

    // Property 35: Transaction Atomicity
    // For any lesson completion, all stat updates (XP, gems, streak, level)
    // should succeed together or fail together with no partial updates
    Glados3(any.int, any.int, any.bool).test(
      'Property 35: all stats update atomically or not at all',
      (baseXp, baseGems, isPerfect) {
        // Constrain values to valid ranges
        final xp = baseXp.abs() % 100; // 0-99
        final gems = baseGems.abs() % 10; // 0-9
        
        // Create calculator
        final calculator = TestLessonCompletionCalculator();
        
        // Store initial state
        final initialTotalXp = calculator.totalXp;
        final initialWeeklyXp = calculator.weeklyXp;
        final initialTodayXp = calculator.todayXp;
        final initialGems = calculator.gems;
        final initialTotalGemsEarned = calculator.totalGemsEarned;
        final initialStreak = calculator.currentStreak;
        final initialLevel = calculator.level;
        
        // Complete lesson
        calculator.completeLessonFlow(xp, gems, isPerfect);
        
        // Verify atomicity: if any stat changed, all related stats should have changed
        final xpChanged = calculator.totalXp != initialTotalXp;
        final gemsChanged = calculator.gems != initialGems;
        
        if (xpChanged) {
          // If totalXp changed, weeklyXp and todayXp must also have changed
          expect(
            calculator.weeklyXp != initialWeeklyXp,
            isTrue,
            reason: 'If totalXp changes, weeklyXp must also change atomically',
          );
          
          expect(
            calculator.todayXp != initialTodayXp,
            isTrue,
            reason: 'If totalXp changes, todayXp must also change atomically',
          );
        }
        
        if (gemsChanged) {
          // If gems changed, totalGemsEarned must also have changed
          expect(
            calculator.totalGemsEarned != initialTotalGemsEarned,
            isTrue,
            reason: 'If gems change, totalGemsEarned must also change atomically',
          );
        }
        
        // Verify consistency: all three XP counters increased by same amount
        final totalXpIncrease = calculator.totalXp - initialTotalXp;
        final weeklyXpIncrease = calculator.weeklyXp - initialWeeklyXp;
        final todayXpIncrease = calculator.todayXp - initialTodayXp;
        
        expect(
          totalXpIncrease == weeklyXpIncrease && weeklyXpIncrease == todayXpIncrease,
          isTrue,
          reason: 'All three XP counters must increase by same amount atomically. '
              'Total: $totalXpIncrease, Weekly: $weeklyXpIncrease, Today: $todayXpIncrease',
        );
        
        // Verify gems consistency
        final gemsIncrease = calculator.gems - initialGems;
        final totalGemsEarnedIncrease = calculator.totalGemsEarned - initialTotalGemsEarned;
        
        expect(
          gemsIncrease == totalGemsEarnedIncrease,
          isTrue,
          reason: 'gems and totalGemsEarned must increase by same amount atomically. '
              'Gems: $gemsIncrease, TotalEarned: $totalGemsEarnedIncrease',
        );
      },
    );

    // Property 35 (continued): Verify no partial updates on error
    test(
      'Property 35: no partial updates if operation fails',
      () {
        // Create calculator
        final calculator = TestLessonCompletionCalculator();
        
        // Store initial state
        final initialTotalXp = calculator.totalXp;
        final initialGems = calculator.gems;
        final initialStreak = calculator.currentStreak;
        final initialLevel = calculator.level;
        
        // Try to add negative XP (should fail)
        try {
          calculator.addXp(-10);
          fail('Should throw exception for negative XP');
        } catch (e) {
          // Expected exception
        }
        
        // Verify no state changed
        expect(
          calculator.totalXp,
          equals(initialTotalXp),
          reason: 'totalXp should not change if operation fails',
        );
        
        expect(
          calculator.gems,
          equals(initialGems),
          reason: 'gems should not change if operation fails',
        );
        
        expect(
          calculator.currentStreak,
          equals(initialStreak),
          reason: 'streak should not change if operation fails',
        );
        
        expect(
          calculator.level,
          equals(initialLevel),
          reason: 'level should not change if operation fails',
        );
      },
    );
  });
}
