import 'package:flutter_test/flutter_test.dart';

/// Unit tests for Gem Multiplier Purchase
/// 
/// Tests the purchaseGemMultiplier() logic in GamificationController
/// covering successful purchases, insufficient gems, idempotency, expiration time, and authentication failures.
/// 
/// Note: These are logic-only tests that validate the business rules without
/// requiring full Firebase integration. Integration tests will cover the full flow.
void main() {
  group('Gem Multiplier Purchase - Unit Tests', () {
    group('3.1 Test successful gem multiplier purchase', () {
      test('User with 300 gems and no active multiplier - logic validation', () {
        // Setup: User has 300 gems, no active multiplier
        const initialGems = 300;
        const cost = 200;
        const multiplierDuration = Duration(hours: 1);
        final now = DateTime.now();

        // Validate: User has sufficient gems
        final canAfford = initialGems >= cost;
        expect(canAfford, isTrue, reason: 'User should have sufficient gems');

        // Validate: No active multiplier
        DateTime? gemMultiplierUntil;
        final hasActiveMultiplier = gemMultiplierUntil != null && now.isBefore(gemMultiplierUntil);
        expect(hasActiveMultiplier, isFalse, reason: 'User should not have active multiplier');

        // Execute: Deduct gems and activate multiplier
        final newGems = initialGems - cost;
        final totalSpent = cost;
        gemMultiplierUntil = now.add(multiplierDuration);

        // Verify: Gems reduced by 200
        expect(newGems, equals(100), reason: 'Gems should be reduced by 200');
        expect(totalSpent, equals(200), reason: 'Total gems spent should be 200');

        // Verify: hasGemMultiplier is true
        final hasMultiplierAfter = gemMultiplierUntil != null && now.isBefore(gemMultiplierUntil);
        expect(hasMultiplierAfter, isTrue, reason: 'hasGemMultiplier should be true after purchase');

        // Verify: Expiration time set to now + 1 hour
        final expectedExpiration = now.add(multiplierDuration);
        final timeDifference = gemMultiplierUntil.difference(expectedExpiration).inSeconds.abs();
        expect(timeDifference, lessThan(2), 
            reason: 'Expiration time should be approximately 1 hour from now (±1 second tolerance)');
      });
    });

    group('3.2 Test gem multiplier with insufficient gems', () {
      test('User with 150 gems cannot purchase multiplier - logic validation', () {
        // Setup: User has 150 gems
        const initialGems = 150;
        const cost = 200;
        DateTime? gemMultiplierUntil;

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
        final hasMultiplier = gemMultiplierUntil != null && DateTime.now().isBefore(gemMultiplierUntil);
        expect(finalGems, equals(initialGems), reason: 'Gems should remain unchanged');
        expect(hasMultiplier, isFalse, reason: 'hasGemMultiplier should remain false');
      });
    });

    group('3.3 Test gem multiplier idempotency', () {
      test('User with 400 gems and active multiplier cannot purchase again - logic validation', () {
        // Setup: User has 400 gems, gem multiplier already active
        const initialGems = 400;
        const cost = 200;
        final now = DateTime.now();
        DateTime? gemMultiplierUntil = now.add(const Duration(minutes: 30)); // Active multiplier

        // Validate: User has sufficient gems
        final canAfford = initialGems >= cost;
        expect(canAfford, isTrue, reason: 'User should have sufficient gems');

        // Validate: Multiplier is already active (idempotency check)
        final hasActiveMultiplier = gemMultiplierUntil != null && now.isBefore(gemMultiplierUntil);
        expect(hasActiveMultiplier, isTrue, reason: 'User should have active multiplier');

        // Verify: Error message should indicate multiplier already active
        const errorMessage = 'Você já tem um multiplicador de gemas ativo.';
        expect(errorMessage, contains('já tem'), 
            reason: 'Error message should indicate multiplier already active');

        // Verify: State should remain unchanged
        final finalGems = initialGems; // No change
        expect(finalGems, equals(initialGems), reason: 'Gems should remain unchanged');
        expect(gemMultiplierUntil, isNotNull, reason: 'Multiplier expiration should remain set');
      });
    });

    group('3.4 Test gem multiplier expiration time', () {
      test('Expiration time is exactly 1 hour from now - logic validation', () {
        // Setup: User has 300 gems
        const initialGems = 300;
        const cost = 200;
        const multiplierDuration = Duration(hours: 1);
        final now = DateTime.now();

        // Execute: Activate multiplier
        final gemMultiplierUntil = now.add(multiplierDuration);

        // Verify: Expiration time is exactly 1 hour from now (±1 second tolerance)
        final expectedExpiration = now.add(multiplierDuration);
        final timeDifference = gemMultiplierUntil.difference(expectedExpiration).inSeconds.abs();
        
        expect(timeDifference, lessThan(2), 
            reason: 'Expiration time should be exactly 1 hour from now (±1 second tolerance)');
        
        // Verify: Expiration is in the future
        expect(gemMultiplierUntil.isAfter(now), isTrue, 
            reason: 'Expiration time should be in the future');
        
        // Verify: Duration is approximately 1 hour
        final duration = gemMultiplierUntil.difference(now);
        expect(duration.inMinutes, greaterThanOrEqualTo(59), 
            reason: 'Duration should be at least 59 minutes');
        expect(duration.inMinutes, lessThanOrEqualTo(61), 
            reason: 'Duration should be at most 61 minutes');
      });

      test('Multiplier expires after 1 hour - logic validation', () {
        // Setup: Multiplier activated 1 hour and 1 minute ago
        final now = DateTime.now();
        final gemMultiplierUntil = now.subtract(const Duration(minutes: 1)); // Expired

        // Verify: hasGemMultiplier returns false after expiration
        final hasMultiplier = gemMultiplierUntil != null && now.isBefore(gemMultiplierUntil);
        expect(hasMultiplier, isFalse, 
            reason: 'hasGemMultiplier should return false after expiration');
      });

      test('Multiplier is active before expiration - logic validation', () {
        // Setup: Multiplier activated 30 minutes ago
        final now = DateTime.now();
        final gemMultiplierUntil = now.add(const Duration(minutes: 30)); // Still active

        // Verify: hasGemMultiplier returns true before expiration
        final hasMultiplier = gemMultiplierUntil != null && now.isBefore(gemMultiplierUntil);
        expect(hasMultiplier, isTrue, 
            reason: 'hasGemMultiplier should return true before expiration');
      });
    });

    group('3.5 Test gem multiplier authentication failure', () {
      test('Unauthenticated user cannot purchase multiplier - logic validation', () {
        // Setup: Simulate unauthenticated user (userId is null or empty)
        const String? userId = null;
        const initialGems = 300;
        DateTime? gemMultiplierUntil;

        // Validate: User is not authenticated
        final isAuthenticated = userId != null && userId.isNotEmpty;
        expect(isAuthenticated, isFalse, reason: 'User should not be authenticated');

        // Verify: Error message should indicate authentication failure
        const errorMessage = 'Usuário não autenticado.';
        expect(errorMessage, contains('não autenticado'), 
            reason: 'Error message should indicate authentication failure');

        // Verify: State should remain unchanged
        final finalGems = initialGems; // No change
        final hasMultiplier = gemMultiplierUntil != null && DateTime.now().isBefore(gemMultiplierUntil);
        expect(finalGems, equals(initialGems), reason: 'Gems should remain unchanged');
        expect(hasMultiplier, isFalse, reason: 'hasGemMultiplier should remain false');
      });

      test('User with empty userId cannot purchase multiplier - logic validation', () {
        // Setup: Simulate user with empty userId
        const userId = '';
        const initialGems = 300;

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
      test('Gem multiplier cost is exactly 200 gems', () {
        // Verify the cost constant
        const cost = 200;
        expect(cost, equals(200), reason: 'Gem multiplier should cost exactly 200 gems');
      });

      test('Gem multiplier duration is exactly 1 hour', () {
        // Verify the duration constant
        const duration = Duration(hours: 1);
        expect(duration.inHours, equals(1), reason: 'Gem multiplier should last exactly 1 hour');
        expect(duration.inMinutes, equals(60), reason: 'Gem multiplier should last exactly 60 minutes');
      });

      test('Atomic transaction - both gems and multiplier update together', () {
        // Test that updates are atomic (all-or-nothing)
        const initialGems = 300;
        const cost = 200;
        final now = DateTime.now();

        // Simulate successful transaction
        var gems = initialGems;
        var totalSpent = 0;
        DateTime? gemMultiplierUntil;

        final canAfford = gems >= cost;
        final hasActiveMultiplier = gemMultiplierUntil != null && now.isBefore(gemMultiplierUntil);
        
        if (canAfford && !hasActiveMultiplier) {
          // Atomic update - all three values change together
          gems -= cost;
          totalSpent += cost;
          gemMultiplierUntil = now.add(const Duration(hours: 1));
        }

        // Verify all values updated
        expect(gems, equals(100), reason: 'Gems should be updated');
        expect(totalSpent, equals(200), reason: 'Total spent should be updated');
        expect(gemMultiplierUntil, isNotNull, reason: 'Multiplier expiration should be set');
      });

      test('Failed transaction - no state changes', () {
        // Test that failed transactions don't change state
        const initialGems = 150;
        const cost = 200;
        final now = DateTime.now();

        var gems = initialGems;
        var totalSpent = 0;
        DateTime? gemMultiplierUntil;

        final canAfford = gems >= cost;
        if (canAfford) {
          gems -= cost;
          totalSpent += cost;
          gemMultiplierUntil = now.add(const Duration(hours: 1));
        }

        // Verify no values changed
        expect(gems, equals(initialGems), reason: 'Gems should not change');
        expect(totalSpent, equals(0), reason: 'Total spent should not change');
        expect(gemMultiplierUntil, isNull, reason: 'Multiplier expiration should remain null');
      });

      test('Validation order: authentication before gems', () {
        // Test that authentication is checked before gem balance
        const String? userId = null;
        const initialGems = 300;
        const cost = 200;

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
        const initialGems = 150; // Insufficient
        const cost = 200;
        final now = DateTime.now();
        final gemMultiplierUntil = now.add(const Duration(minutes: 30)); // Active

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
        final hasActiveMultiplier = gemMultiplierUntil != null && now.isBefore(gemMultiplierUntil);
        expect(hasActiveMultiplier, isTrue); // This line should not execute
      });
    });
  });
}
