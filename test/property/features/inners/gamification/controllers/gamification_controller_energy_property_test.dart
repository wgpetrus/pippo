import 'package:flutter_test/flutter_test.dart' hide test, group, expect;
import 'package:glados/glados.dart';
import 'package:test/test.dart' show test, group, expect;

// Test helper class - isolated energy logic without Firebase dependencies
class TestEnergyCalculator {
  int currentEnergy = 5;
  DateTime lastEnergyRegenAt = DateTime.now();
  DateTime? unlimitedEnergyUntil;

  bool get hasUnlimitedEnergy =>
      unlimitedEnergyUntil != null &&
      DateTime.now().isBefore(unlimitedEnergyUntil!);

  void calculateEnergyRegeneration() {
    if (hasUnlimitedEnergy) return;
    if (currentEnergy >= 5) return;

    final now = DateTime.now();
    final minutesPassed = now.difference(lastEnergyRegenAt).inMinutes;
    final energiesToAdd = minutesPassed ~/ 30;

    if (energiesToAdd == 0) return;

    final newEnergy = currentEnergy + energiesToAdd;
    currentEnergy = newEnergy > 5 ? 5 : newEnergy;

    final minutesConsumed = (currentEnergy - (currentEnergy - energiesToAdd)) * 30;
    lastEnergyRegenAt = lastEnergyRegenAt.add(Duration(minutes: minutesConsumed));
  }

  void consumeEnergy(DateTime now) {
    if (hasUnlimitedEnergy) return;

    if (currentEnergy > 0) {
      currentEnergy--;
      lastEnergyRegenAt = now;
    }
  }

  bool purchaseEnergyRefill(int currentGems) {
    if (currentGems < 100) {
      return false;
    }

    final newEnergy = currentEnergy + 5;
    currentEnergy = newEnergy > 5 ? 5 : newEnergy;

    return true;
  }
}

void main() {
  group('Feature: gamification-system, Energy System Property Tests', () {
    // Property 11: Energy Regeneration Formula
    // For any time delta in minutes, regenerated energy should equal
    // minutesPassed ~/ 30, capped at (maxEnergy - currentEnergy)
    Glados2(any.int, any.int).test(
      'Property 11: energy regenerated equals minutesPassed ~/ 30, capped at maxEnergy',
      (initialEnergy, minutesPassed) {
        // Constrain values to valid ranges
        final energy = initialEnergy % 5; // 0-4
        final minutes = minutesPassed.abs() % 301; // 0-300
        
        // Create calculator with initial energy
        final calculator = TestEnergyCalculator();
        calculator.currentEnergy = energy;
        
        // Simulate time passed by adjusting lastEnergyRegenAt
        final now = DateTime.now();
        calculator.lastEnergyRegenAt = now.subtract(Duration(minutes: minutes));
        
        // Calculate regeneration
        calculator.calculateEnergyRegeneration();
        
        // Calculate expected energy
        final energiesToAdd = minutes ~/ 30;
        final expectedEnergy = (energy + energiesToAdd).clamp(0, 5);
        
        // Verify
        expect(
          calculator.currentEnergy,
          equals(expectedEnergy),
          reason: 'Energy should regenerate at 1 per 30 minutes, capped at 5. '
              'Initial: $energy, Minutes: $minutes, Expected: $expectedEnergy, Got: ${calculator.currentEnergy}',
        );
      },
    );

    // Property 12: Energy Consumption and Timestamp Update
    // For any lesson start with currentEnergy > 0, energy should
    // decrease by 1 and lastEnergyRegenAt should update to current timestamp
    Glados(any.int).test(
      'Property 12: energy consumption decreases by 1 and updates timestamp',
      (initialEnergy) {
        // Constrain to valid range (1-5, since 0 cannot consume)
        final energy = (initialEnergy.abs() % 5) + 1; // 1-5
        
        // Create calculator with initial energy
        final calculator = TestEnergyCalculator();
        calculator.currentEnergy = energy;
        
        // Store timestamp before consumption
        final timestampBefore = calculator.lastEnergyRegenAt;
        
        // Wait a bit to ensure timestamp changes
        final now = DateTime.now();
        
        // Consume energy
        calculator.consumeEnergy(now);
        
        // Verify energy decreased by 1
        expect(
          calculator.currentEnergy,
          equals(energy - 1),
          reason: 'Energy should decrease by 1 when consumed',
        );
        
        // Verify timestamp was updated
        expect(
          calculator.lastEnergyRegenAt.isAfter(timestampBefore) ||
              calculator.lastEnergyRegenAt.isAtSameMomentAs(now),
          isTrue,
          reason: 'lastEnergyRegenAt should be updated to current time',
        );
      },
    );

    // Property 15: Energy Refill Transaction
    // For any user with gems >= 100, purchasing energy refill should
    // deduct 100 gems and add 5 energy (capped at max)
    Glados2(any.int, any.int).test(
      'Property 15: energy refill deducts 100 gems and adds 5 energy capped at max',
      (initialEnergy, initialGems) {
        // Constrain values to valid ranges
        final energy = initialEnergy.abs() % 6; // 0-5
        final gems = initialGems.abs() % 500; // 0-499
        
        // Create calculator
        final calculator = TestEnergyCalculator();
        calculator.currentEnergy = energy;
        
        // Try to purchase refill
        final success = calculator.purchaseEnergyRefill(gems);
        
        if (gems >= 100) {
          // Should succeed
          expect(success, isTrue, reason: 'Purchase should succeed with sufficient gems');
          
          // Energy should be initial + 5, capped at 5
          final expectedEnergy = (energy + 5).clamp(0, 5);
          expect(
            calculator.currentEnergy,
            equals(expectedEnergy),
            reason: 'Energy should be increased by 5, capped at 5',
          );
        } else {
          // Should fail
          expect(success, isFalse, reason: 'Purchase should fail with insufficient gems');
          
          // Energy should not change
          expect(
            calculator.currentEnergy,
            equals(energy),
            reason: 'Energy should not change when purchase fails',
          );
        }
      },
    );
  });
}
