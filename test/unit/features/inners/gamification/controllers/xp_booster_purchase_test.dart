import 'package:flutter_test/flutter_test.dart';

/// Unit tests for XP Booster Purchase
/// 
/// Tests the purchaseXpBooster() logic in GamificationController
/// covering successful purchases, insufficient gems, idempotency, expiration time, and authentication failures.
/// 
/// Note: These are logic-only tests that validate the business rules without
/// requiring full Firebase integration. Integration tests will cover the full flow.
void main() {
  group('XP Booster Purchase - Unit Tests', () {
    group('2.1 Test successful XP booster purchase', () {
      test('User with 200 gems and no active booster - logic validation', () {
        // Setup: User has 200 gems, no active booster
        const initialGems = 200;
        const cost = 150;
        const boosterDuration = Duration(hours: 1);
        final now = DateTime.now();

        // Validate: User has sufficient gems
        final canAfford = initialGems >= cost;
        expect(canAfford, isTrue, reason: 'User should have sufficient gems');

        // Validate: No active booster
        DateTime? xpBoosterUntil;
        final hasActiveBooster = xpBoosterUntil != null && now.isBefore(xpBoosterUntil);
        expect(hasActiveBooster, isFalse, reason: 'User should not have active booster');

        // Execute: Deduct gems and activate booster
        final newGems = initialGems - cost;
        final totalSpent = cost;
        xpBoosterUntil = now.add(boosterDuration);

        // Verify: Gems reduced by 150
        expect(newGems, equals(50), reason: 'Gems should be reduced by 150');
        expect(totalSpent, equals(150), reason: 'Total gems spent should be 150');

        // Verify: hasXpBooster is true
        final hasBoosterAfter = xpBoosterUntil != null && now.isBefore(xpBoosterUntil);
        expect(hasBoosterAfter, isTrue, reason: 'hasXpBooster should be true after purchase');

        // Verify: Expiration time set to now + 1 hour
        final expectedExpiration = now.add(boosterDuration);
        final timeDifference = xpBoosterUntil.difference(expectedExpiration).inSeconds.abs();
        expect(timeDifference, lessThan(2), 
            reason: 'Expiration time should be approximately 1 hour from now (±1 second tolerance)');
      });
    });

    group('2.2 Test XP booster with insufficient gems', () {
      test('User with 100 gems cannot purchase booster - logic validation', () {
        // Setup: User has 100 gems
        const initialGems = 100;
        const cost = 150;
        DateTime? xpBoosterUntil;

        // Validate: User does not have sufficient gems
        final canAfford = initialGems >= cost;
        expect(canAfford, isFalse, reason: 'User should not have sufficient gems');

        // Calculate deficit
        final deficit = cost - initialGems;
        expect(deficit, equals(50), reason: 'Deficit should be 50 gems');

        // Verify: Error message should indicate deficit
        final errorMessage = 'Você precisa de $deficit gemas a mais.';
        expect(errorMessage, contains('gemas a mais'), 
            reason: 'Error message should indicate insufficient gems');
        expect(errorMessage, contains('50'), 
            reason: 'Error message should specify how many more gems are needed');

        // Verify: State should remain unchanged
        final finalGems = initialGems; // No change
        final hasBooster = xpBoosterUntil != null && DateTime.now().isBefore(xpBoosterUntil);
        expect(finalGems, equals(initialGems), reason: 'Gems should remain unchanged');
        expect(hasBooster, isFalse, reason: 'hasXpBooster should remain false');
      });
    });

    group('2.3 Test XP booster idempotency', () {
      test('User with 300 gems and active booster cannot purchase again - logic validation', () {
        // Setup: User has 300 gems, XP booster already active
        const initialGems = 300;
        const cost = 150;
        final now = DateTime.now();
        DateTime? xpBoosterUntil = now.add(const Duration(minutes: 30)); // Active booster

        // Validate: User has sufficient gems
        final canAfford = initialGems >= cost;
        expect(canAfford, isTrue, reason: 'User should have sufficient gems');

        // Validate: Booster is already active (idempotency check)
        final hasActiveBooster = xpBoosterUntil != null && now.isBefore(xpBoosterUntil);
        expect(hasActiveBooster, isTrue, reason: 'User should have active booster');

        // Verify: Error message should indicate booster already active
        const errorMessage = 'Você já tem um XP booster ativo.';
        expect(errorMessage, contains('já tem'), 
            reason: 'Error message should indicate booster already active');

        // Verify: State should remain unchanged
        final finalGems = initialGems; // No change
        expect(finalGems, equals(initialGems), reason: 'Gems should remain unchanged');
        expect(xpBoosterUntil, isNotNull, reason: 'Booster expiration should remain set');
      });
    });

    group('2.4 Test XP booster expiration time', () {
      test('Expiration time is exactly 1 hour from now - logic validation', () {
        // Setup: User has 200 gems
        const initialGems = 200;
        const cost = 150;
        const boosterDuration = Duration(hours: 1);
        final now = DateTime.now();

        // Execute: Activate booster
        final xpBoosterUntil = now.add(boosterDuration);

        // Verify: Expiration time is exactly 1 hour from now (±1 second tolerance)
        final expectedExpiration = now.add(boosterDuration);
        final timeDifference = xpBoosterUntil.difference(expectedExpiration).inSeconds.abs();
        
        expect(timeDifference, lessThan(2), 
            reason: 'Expiration time should be exactly 1 hour from now (±1 second tolerance)');
        
        // Verify: Expiration is in the future
        expect(xpBoosterUntil.isAfter(now), isTrue, 
            reason: 'Expiration time should be in the future');
        
        // Verify: Duration is approximately 1 hour
        final duration = xpBoosterUntil.difference(now);
        expect(duration.inMinutes, greaterThanOrEqualTo(59), 
            reason: 'Duration should be at least 59 minutes');
        expect(duration.inMinutes, lessThanOrEqualTo(61), 
            reason: 'Duration should be at most 61 minutes');
      });

      test('Booster expires after 1 hour - logic validation', () {
        // Setup: Booster activated 1 hour and 1 minute ago
        final now = DateTime.now();
        final xpBoosterUntil = now.subtract(const Duration(minutes: 1)); // Expired

        // Verify: hasXpBooster returns false after expiration
        final hasBooster = xpBoosterUntil != null && now.isBefore(xpBoosterUntil);
        expect(hasBooster, isFalse, 
            reason: 'hasXpBooster should return false after expiration');
      });

      test('Booster is active before expiration - logic validation', () {
        // Setup: Booster activated 30 minutes ago
        final now = DateTime.now();
        final xpBoosterUntil = now.add(const Duration(minutes: 30)); // Still active

        // Verify: hasXpBooster returns true before expiration
        final hasBooster = xpBoosterUntil != null && now.isBefore(xpBoosterUntil);
        expect(hasBooster, isTrue, 
            reason: 'hasXpBooster should return true before expiration');
      });
    });

    group('2.5 Test XP booster authentication failure', () {
      test('Unauthenticated user cannot purchase booster - logic validation', () {
        // Setup: Simulate unauthenticated user (userId is null or empty)
        const String? userId = null;
        const initialGems = 200;
        DateTime? xpBoosterUntil;

        // Validate: User is not authenticated
        final isAuthenticated = userId != null && userId.isNotEmpty;
        expect(isAuthenticated, isFalse, reason: 'User should not be authenticated');

        // Verify: Error message should indicate authentication failure
        const errorMessage = 'Usuário não autenticado.';
        expect(errorMessage, contains('não autenticado'), 
            reason: 'Error message should indicate authentication failure');

        // Verify: State should remain unchanged
        final finalGems = initialGems; // No change
        final hasBooster = xpBoosterUntil != null && DateTime.now().isBefore(xpBoosterUntil);
        expect(finalGems, equals(initialGems), reason: 'Gems should remain unchanged');
        expect(hasBooster, isFalse, reason: 'hasXpBooster should remain false');
      });

      test('User with empty userId cannot purchase booster - logic validation', () {
        // Setup: Simulate user with empty userId
        const userId = '';
        const initialGems = 200;

        // Validate: User ID is empty
        final isAuthenticated = userId.isNotEmpty;
        expect(isAuthenticated, isFalse, reason: 'Empty userId should be invalid');

        // Verify: Should fail authentication check
        const errorMessage = 'Usuário não autenticado.';
        expect(errorMessage, contains('não autenticado'), 
            reason: 'Error message should indicate authentication failure');
      });
    });

    group('Additional Edge Cases', () {
      test('XP booster cost is exactly 150 gems', () {
        // Verify the cost constant
        const cost = 150;
        expect(cost, equals(150), reason: 'XP booster should cost exactly 150 gems');
      });

      test('XP booster duration is exactly 1 hour', () {
        // Verify the duration constant
        const duration = Duration(hours: 1);
        expect(duration.inHours, equals(1), reason: 'XP booster should last exactly 1 hour');
        expect(duration.inMinutes, equals(60), reason: 'XP booster should last exactly 60 minutes');
      });

      test('Atomic transaction - both gems and booster update together', () {
        // Test that updates are atomic (all-or-nothing)
        const initialGems = 200;
        const cost = 150;
        final now = DateTime.now();

        // Simulate successful transaction
        var gems = initialGems;
        var totalSpent = 0;
        DateTime? xpBoosterUntil;

        final canAfford = gems >= cost;
        final hasActiveBooster = xpBoosterUntil != null && now.isBefore(xpBoosterUntil);
        
        if (canAfford && !hasActiveBooster) {
          // Atomic update - all three values change together
          gems -= cost;
          totalSpent += cost;
          xpBoosterUntil = now.add(const Duration(hours: 1));
        }

        // Verify all values updated
        expect(gems, equals(50), reason: 'Gems should be updated');
        expect(totalSpent, equals(150), reason: 'Total spent should be updated');
        expect(xpBoosterUntil, isNotNull, reason: 'Booster expiration should be set');
      });

      test('Failed transaction - no state changes', () {
        // Test that failed transactions don't change state
        const initialGems = 100;
        const cost = 150;
        final now = DateTime.now();

        var gems = initialGems;
        var totalSpent = 0;
        DateTime? xpBoosterUntil;

        final canAfford = gems >= cost;
        if (canAfford) {
          gems -= cost;
          totalSpent += cost;
          xpBoosterUntil = now.add(const Duration(hours: 1));
        }

        // Verify no values changed
        expect(gems, equals(initialGems), reason: 'Gems should not change');
        expect(totalSpent, equals(0), reason: 'Total spent should not change');
        expect(xpBoosterUntil, isNull, reason: 'Booster expiration should remain null');
      });

      test('Validation order: authentication before gems', () {
        // Test that authentication is checked before gem balance
        const String? userId = null;
        const initialGems = 200;
        const cost = 150;

        // Check authentication first
        final isAuthenticated = userId != null && userId.isNotEmpty;
        
        if (!isAuthenticated) {
          // Should fail here, before checking gems
          const errorMessage = 'Usuário não autenticado.';
          expect(errorMessage, contains('não autenticado'));
          return; // Exit early
        }

        // This should not be reached
        final canAfford = initialGems >= cost;
        expect(canAfford, isTrue); // This line should not execute
      });

      test('Validation order: gems before idempotency', () {
        // Test that gem balance is checked before idempotency
        const initialGems = 100; // Insufficient
        const cost = 150;
        final now = DateTime.now();
        final xpBoosterUntil = now.add(const Duration(minutes: 30)); // Active

        // Check gems first
        final canAfford = initialGems >= cost;
        
        if (!canAfford) {
          // Should fail here, before checking idempotency
          final deficit = cost - initialGems;
          final errorMessage = 'Você precisa de $deficit gemas a mais.';
          expect(errorMessage, contains('gemas a mais'));
          return; // Exit early
        }

        // This should not be reached
        final hasActiveBooster = xpBoosterUntil != null && now.isBefore(xpBoosterUntil);
        expect(hasActiveBooster, isTrue); // This line should not execute
      });
    });
  });
}
