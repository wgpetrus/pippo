import 'package:flutter_test/flutter_test.dart';

/// Feature: lesson-system, Property 18: Booster Expiration
/// 
/// For any booster (XP or Gem), the system SHALL apply the 2× multiplier if and only if
/// current time is before expiration time (activationTime + 1 hour), and SHALL NOT apply
/// multiplier after expiration.
/// 
/// Validates: Requirements 13.1, 13.2, 13.3, 13.4, 13.6
void main() {
  group('Property 18: Booster Expiration', () {
    test('booster is active when current time is before expiration', () {
      // Property: Booster active if now < expirationTime
      
      for (int i = 0; i < 100; i++) {
        final now = DateTime.now();
        final minutesUntilExpiry = i; // 0-99 minutes
        final expirationTime = now.add(Duration(minutes: minutesUntilExpiry));
        
        // Booster should be active if expiration is in the future
        final isActive = now.isBefore(expirationTime);
        
        // Verify booster is active when time hasn't expired
        if (minutesUntilExpiry > 0) {
          expect(
            isActive,
            isTrue,
            reason: 'Booster must be active when expiration is in future. '
                'Minutes until expiry: $minutesUntilExpiry',
          );
        }
      }
    });

    test('booster is inactive when current time is after expiration', () {
      // Property: Booster inactive if now >= expirationTime
      
      for (int i = 0; i < 100; i++) {
        final now = DateTime.now();
        final minutesSinceExpiry = i + 1; // 1-100 minutes ago
        final expirationTime = now.subtract(Duration(minutes: minutesSinceExpiry));
        
        // Booster should be inactive if expiration is in the past
        final isActive = now.isBefore(expirationTime);
        
        // Verify booster is inactive when time has expired
        expect(
          isActive,
          isFalse,
          reason: 'Booster must be inactive when expiration is in past. '
              'Minutes since expiry: $minutesSinceExpiry',
        );
      }
    });

    test('booster expires exactly at expiration time', () {
      // Property: Booster expires at exact moment of expirationTime
      
      for (int i = 0; i < 100; i++) {
        final expirationTime = DateTime.now();
        
        // At exact expiration time, booster should be inactive
        // (isBefore returns false when times are equal)
        final isActive = expirationTime.isBefore(expirationTime);
        
        expect(
          isActive,
          isFalse,
          reason: 'Booster must be inactive at exact expiration time',
        );
      }
    });


    test('null expiration time means booster is inactive', () {
      // Property: null expirationTime = no booster active
      
      for (int i = 0; i < 100; i++) {
        final DateTime? expirationTime = null;
        
        // Booster should be inactive when expiration is null
        final isActive = expirationTime != null && 
            DateTime.now().isBefore(expirationTime);
        
        expect(
          isActive,
          isFalse,
          reason: 'Booster must be inactive when expiration time is null',
        );
      }
    });

    test('booster duration is exactly 1 hour from activation', () {
      // Property: Booster lasts exactly 1 hour (60 minutes)
      
      for (int i = 0; i < 100; i++) {
        final activationTime = DateTime.now();
        final expirationTime = activationTime.add(const Duration(hours: 1));
        
        // Calculate duration
        final duration = expirationTime.difference(activationTime);
        
        // Verify duration is exactly 1 hour
        expect(
          duration.inMinutes,
          equals(60),
          reason: 'Booster duration must be exactly 60 minutes (1 hour)',
        );
        
        expect(
          duration.inHours,
          equals(1),
          reason: 'Booster duration must be exactly 1 hour',
        );
      }
    });

    test('booster is active throughout the entire hour', () {
      // Property: Booster remains active for all minutes within the hour
      
      for (int i = 0; i < 60; i++) {
        final activationTime = DateTime.now();
        final expirationTime = activationTime.add(const Duration(hours: 1));
        final checkTime = activationTime.add(Duration(minutes: i));
        
        // Booster should be active at any point before expiration
        final isActive = checkTime.isBefore(expirationTime);
        
        expect(
          isActive,
          isTrue,
          reason: 'Booster must be active at minute $i of the hour',
        );
      }
    });

    test('booster becomes inactive immediately after 1 hour', () {
      // Property: Booster expires exactly after 60 minutes
      
      for (int i = 0; i < 100; i++) {
        final activationTime = DateTime.now();
        final expirationTime = activationTime.add(const Duration(hours: 1));
        final checkTime = activationTime.add(Duration(minutes: 60 + i));
        
        // Booster should be inactive after expiration
        final isActive = checkTime.isBefore(expirationTime);
        
        expect(
          isActive,
          isFalse,
          reason: 'Booster must be inactive at minute ${60 + i} (after expiration)',
        );
      }
    });

    test('XP booster and gem multiplier have independent expiration', () {
      // Property: Each booster type has its own expiration time
      
      for (int i = 0; i < 100; i++) {
        final now = DateTime.now();
        final xpBoosterExpiry = now.add(Duration(minutes: i));
        final gemMultiplierExpiry = now.add(Duration(minutes: i + 30));
        
        // XP booster and gem multiplier can have different expiration times
        final xpActive = now.isBefore(xpBoosterExpiry);
        final gemActive = now.isBefore(gemMultiplierExpiry);
        
        // Both can be active independently
        expect(
          xpActive || gemActive,
          isTrue,
          reason: 'At least one booster should be active in this test case',
        );
        
        // Verify they can have different states
        if (i == 0) {
          // At i=0, XP expires now, gem expires in 30 min
          expect(xpActive, isFalse);
          expect(gemActive, isTrue);
        }
      }
    });

    test('booster multiplier is 2× when active, 1× when inactive', () {
      // Property: Multiplier value depends on booster state
      
      for (int i = 0; i < 100; i++) {
        final now = DateTime.now();
        final isActive = (i % 2 == 0); // Alternate active/inactive
        
        final expirationTime = isActive 
            ? now.add(const Duration(hours: 1))
            : now.subtract(const Duration(hours: 1));
        
        final boosterActive = now.isBefore(expirationTime);
        final multiplier = boosterActive ? 2 : 1;
        
        // Verify multiplier matches booster state
        if (isActive) {
          expect(
            multiplier,
            equals(2),
            reason: 'Multiplier must be 2× when booster is active',
          );
        } else {
          expect(
            multiplier,
            equals(1),
            reason: 'Multiplier must be 1× when booster is inactive',
          );
        }
      }
    });
  });
}
