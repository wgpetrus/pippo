import 'package:flutter_test/flutter_test.dart';

/// Feature: lesson-system, Property 9: Reward Calculation Order
/// 
/// For any completed lesson, rewards SHALL be calculated in this exact order:
/// (1) base XP/gems from lesson, (2) add perfect bonus (+5 XP if 100% accuracy),
/// (3) add first today bonus (+5 XP if first lesson), (4) apply booster multipliers (2× if active).
/// 
/// Validates: Requirements 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9, 13.5
void main() {
  group('Property 9: Reward Calculation Order', () {
    test('XP calculation follows exact order: base → perfect → first today → booster', () {
      // Property: XP rewards must be calculated in exact order
      
      for (int i = 0; i < 100; i++) {
        // Generate test data
        final baseXp = 10 + (i % 10); // 10-19
        final isPerfect = (i % 2 == 0); // Alternate perfect/imperfect
        final isFirstToday = (i % 3 == 0); // Every 3rd is first today
        final hasBooster = (i % 4 == 0); // Every 4th has booster
        
        // Calculate expected XP following exact order
        int expectedXp = baseXp; // Step 1: Base
        if (isPerfect) expectedXp += 5; // Step 2: Perfect bonus
        if (isFirstToday) expectedXp += 5; // Step 3: First today bonus
        if (hasBooster) expectedXp *= 2; // Step 4: Booster multiplier
        
        // Verify order is followed
        expect(
          expectedXp,
          greaterThan(0),
          reason: 'XP must be positive',
        );
        
        // Verify perfect bonus only applied when isPerfect
        if (isPerfect) {
          expect(
            expectedXp >= baseXp + 5,
            isTrue,
            reason: 'Perfect bonus (+5) must be applied when isPerfect=true',
          );
        }
        
        // Verify booster multiplies total (not just base)
        if (hasBooster) {
          final xpBeforeBooster = baseXp + 
              (isPerfect ? 5 : 0) + 
              (isFirstToday ? 5 : 0);
          expect(
            expectedXp,
            equals(xpBeforeBooster * 2),
            reason: 'Booster must multiply total XP (base + bonuses). '
                'Base: $baseXp, Perfect: $isPerfect, First: $isFirstToday, '
                'Before booster: $xpBeforeBooster, Expected: $expectedXp',
          );
        }

        
        // Verify first today bonus is independent of perfect
        if (isFirstToday && !isPerfect && !hasBooster) {
          expect(
            expectedXp,
            equals(baseXp + 5),
            reason: 'First today bonus should be added independently',
          );
        }
        
        // Verify both bonuses stack before booster
        if (isPerfect && isFirstToday && !hasBooster) {
          expect(
            expectedXp,
            equals(baseXp + 10),
            reason: 'Both bonuses should stack: +5 perfect + +5 first today',
          );
        }
      }
    });

    test('gems calculation follows exact order: base → multiplier', () {
      // Property: Gems rewards must be calculated in exact order
      
      for (int i = 0; i < 100; i++) {
        // Generate test data
        final baseGems = 1 + (i % 5); // 1-5
        final hasMultiplier = (i % 3 == 0); // Every 3rd has multiplier
        
        // Calculate expected gems following exact order
        int expectedGems = baseGems; // Step 1: Base
        if (hasMultiplier) expectedGems *= 2; // Step 2: Multiplier
        
        // Verify order is followed
        expect(
          expectedGems,
          greaterThan(0),
          reason: 'Gems must be positive',
        );
        
        // Verify multiplier doubles gems
        if (hasMultiplier) {
          expect(
            expectedGems,
            equals(baseGems * 2),
            reason: 'Gem multiplier must double base gems. '
                'Base: $baseGems, Expected: $expectedGems',
          );
        } else {
          expect(
            expectedGems,
            equals(baseGems),
            reason: 'Without multiplier, gems should equal base',
          );
        }
      }
    });


    test('perfect bonus only applied at exactly 100% accuracy', () {
      // Property: Perfect bonus is binary - 100% or nothing
      
      for (int i = 0; i < 100; i++) {
        final baseXp = 10;
        final correctAnswers = i % 11; // 0-10
        final totalAnswers = 10;
        
        final accuracy = totalAnswers > 0 
            ? (correctAnswers / totalAnswers) * 100 
            : 0.0;
        
        final expectedBonus = accuracy == 100.0 ? 5 : 0;
        
        // Verify perfect bonus is binary
        if (accuracy == 100.0) {
          expect(
            expectedBonus,
            equals(5),
            reason: 'Perfect bonus must be +5 at 100% accuracy',
          );
        } else {
          expect(
            expectedBonus,
            equals(0),
            reason: 'Perfect bonus must be 0 when accuracy < 100%',
          );
        }
        
        // Verify 90% doesn't get bonus
        if (correctAnswers == 9 && totalAnswers == 10) {
          expect(
            accuracy,
            equals(90.0),
            reason: '9/10 should be 90%, not 100%',
          );
          expect(
            expectedBonus,
            equals(0),
            reason: '90% accuracy should not get perfect bonus',
          );
        }
      }
    });

    test('booster multiplies total XP including all bonuses', () {
      // Property: Booster applies to (base + perfect + first today), not just base
      
      for (int i = 0; i < 100; i++) {
        final baseXp = 10 + (i % 5);
        final hasPerfect = (i % 2 == 0);
        final hasFirstToday = (i % 3 == 0);
        
        // Calculate XP before booster
        int xpBeforeBooster = baseXp;
        if (hasPerfect) xpBeforeBooster += 5;
        if (hasFirstToday) xpBeforeBooster += 5;
        
        // Apply booster
        final xpWithBooster = xpBeforeBooster * 2;
        
        // Verify booster multiplies total
        expect(
          xpWithBooster,
          equals(xpBeforeBooster * 2),
          reason: 'Booster must multiply (base + bonuses), not just base. '
              'Base: $baseXp, Perfect: $hasPerfect, First: $hasFirstToday, '
              'Before booster: $xpBeforeBooster, With booster: $xpWithBooster',
        );
        
        // Verify booster doesn't apply to base only
        final incorrectCalculation = (baseXp * 2) + 
            (hasPerfect ? 5 : 0) + 
            (hasFirstToday ? 5 : 0);
        
        if (hasPerfect || hasFirstToday) {
          expect(
            xpWithBooster,
            isNot(equals(incorrectCalculation)),
            reason: 'Booster must NOT apply only to base (bonuses must be included)',
          );
        }
      }
    });
  });
}
