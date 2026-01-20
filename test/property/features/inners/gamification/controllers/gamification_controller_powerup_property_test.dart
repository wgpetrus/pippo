import 'package:flutter_test/flutter_test.dart' hide test, group, expect;
import 'package:glados/glados.dart';
import 'package:test/test.dart' show test, group, expect;

// Test helper class - isolated power-up logic without Firebase dependencies
class TestPowerUpManager {
  DateTime? xpBoosterUntil;
  DateTime? gemMultiplierUntil;

  bool get hasXpBooster =>
      xpBoosterUntil != null && DateTime.now().isBefore(xpBoosterUntil!);

  bool get hasGemMultiplier =>
      gemMultiplierUntil != null && DateTime.now().isBefore(gemMultiplierUntil!);

  bool purchaseXpBooster(int currentGems) {
    if (currentGems < 150) return false;
    if (hasXpBooster) return false;

    xpBoosterUntil = DateTime.now().add(const Duration(hours: 1));
    return true;
  }

  bool purchaseGemMultiplier(int currentGems) {
    if (currentGems < 200) return false;
    if (hasGemMultiplier) return false;

    gemMultiplierUntil = DateTime.now().add(const Duration(hours: 1));
    return true;
  }
}

void main() {
  group('Feature: gamification-system, Power-Up Property Tests', () {
    // Property 31: Power-Up Activation Timestamp
    // For any power-up activation, expiration timestamp should be
    // set to exactly current time + 1 hour
    Glados(any.int).test(
      'Property 31: power-up expiration is set to current time + 1 hour',
      (initialGems) {
        // Constrain gems to valid range (200-699, enough for both power-ups)
        final gems = initialGems.abs() % 500 + 200;

        // Test XP booster
        final manager1 = TestPowerUpManager();
        final beforeXpBooster = DateTime.now();
        final xpSuccess = manager1.purchaseXpBooster(gems);
        final afterXpBooster = DateTime.now();

        expect(xpSuccess, isTrue, reason: 'XP booster purchase should succeed');
        expect(manager1.xpBoosterUntil, isNotNull);

        // Verify expiration is approximately 1 hour in the future
        final xpDuration = manager1.xpBoosterUntil!.difference(beforeXpBooster);
        expect(
          xpDuration.inMinutes,
          greaterThanOrEqualTo(59),
          reason: 'XP booster should expire in at least 59 minutes',
        );
        expect(
          xpDuration.inMinutes,
          lessThanOrEqualTo(61),
          reason: 'XP booster should expire in at most 61 minutes',
        );

        // Test gem multiplier
        final manager2 = TestPowerUpManager();
        final beforeGemMultiplier = DateTime.now();
        final gemSuccess = manager2.purchaseGemMultiplier(gems);
        final afterGemMultiplier = DateTime.now();

        expect(gemSuccess, isTrue,
            reason: 'Gem multiplier purchase should succeed');
        expect(manager2.gemMultiplierUntil, isNotNull);

        // Verify expiration is approximately 1 hour in the future
        final gemDuration =
            manager2.gemMultiplierUntil!.difference(beforeGemMultiplier);
        expect(
          gemDuration.inMinutes,
          greaterThanOrEqualTo(59),
          reason: 'Gem multiplier should expire in at least 59 minutes',
        );
        expect(
          gemDuration.inMinutes,
          lessThanOrEqualTo(61),
          reason: 'Gem multiplier should expire in at most 61 minutes',
        );
      },
    );

    // Property 32: Power-Up Expiration Check
    // For any power-up state, the power-up should be considered active
    // if and only if current time < expiration timestamp
    Glados(any.int).test(
      'Property 32: power-up is active iff current time < expiration',
      (minutesOffset) {
        // Constrain offset to reasonable range (-60 to +60 minutes)
        final offset = (minutesOffset % 121) - 60; // -60 to +60

        // Test XP booster
        final manager = TestPowerUpManager();
        final expiration = DateTime.now().add(Duration(minutes: offset));
        manager.xpBoosterUntil = expiration;

        final isActive = manager.hasXpBooster;

        if (offset > 0) {
          expect(
            isActive,
            isTrue,
            reason:
                'Power-up should be active when expiration is $offset minutes in the future',
          );
        } else {
          expect(
            isActive,
            isFalse,
            reason:
                'Power-up should be inactive when expiration is ${offset.abs()} minutes in the past',
          );
        }
      },
    );

    // Property 33: Power-Up Purchase Idempotence
    // Attempting to purchase a power-up when it's already active
    // should fail and not modify state
    Glados2(any.int, any.int).test(
      'Property 33: cannot purchase power-up when already active',
      (initialGems, secondPurchaseGems) {
        // Constrain gems to valid ranges
        final gems1 = initialGems.abs() % 500 + 200; // 200-699
        final gems2 = secondPurchaseGems.abs() % 500 + 200; // 200-699

        // Test XP booster idempotence
        final manager1 = TestPowerUpManager();
        final firstPurchase = manager1.purchaseXpBooster(gems1);
        expect(firstPurchase, isTrue, reason: 'First purchase should succeed');

        final expirationAfterFirst = manager1.xpBoosterUntil;
        expect(expirationAfterFirst, isNotNull);

        // Attempt second purchase while active
        final secondPurchase = manager1.purchaseXpBooster(gems2);
        expect(secondPurchase, isFalse,
            reason: 'Second purchase should fail when power-up is active');

        // Verify expiration timestamp unchanged
        expect(
          manager1.xpBoosterUntil,
          equals(expirationAfterFirst),
          reason: 'Expiration timestamp should not change on failed purchase',
        );

        // Test gem multiplier idempotence
        final manager2 = TestPowerUpManager();
        final firstGemPurchase = manager2.purchaseGemMultiplier(gems1);
        expect(firstGemPurchase, isTrue,
            reason: 'First gem multiplier purchase should succeed');

        final gemExpirationAfterFirst = manager2.gemMultiplierUntil;
        expect(gemExpirationAfterFirst, isNotNull);

        // Attempt second purchase while active
        final secondGemPurchase = manager2.purchaseGemMultiplier(gems2);
        expect(secondGemPurchase, isFalse,
            reason:
                'Second gem multiplier purchase should fail when power-up is active');

        // Verify expiration timestamp unchanged
        expect(
          manager2.gemMultiplierUntil,
          equals(gemExpirationAfterFirst),
          reason:
              'Gem multiplier expiration timestamp should not change on failed purchase',
        );
      },
    );
  });
}
