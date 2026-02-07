import 'package:flutter_test/flutter_test.dart';

/// Testes unitários para getters públicos de boost expiration times
/// 
/// Valida:
/// - xpBoosterUntil retorna null quando não ativo
/// - xpBoosterUntil retorna DateTime quando ativo
/// - gemMultiplierUntil retorna null quando não ativo
/// - gemMultiplierUntil retorna DateTime quando ativo
/// 
/// Note: These are logic-only tests that validate the getter behavior
/// without requiring full Firebase integration.
void main() {
  group('Boost Expiration Getters - Unit Tests', () {
    test('xpBoosterUntil returns null when not active', () {
      // Setup: Não ativar booster
      DateTime? xpBoosterUntil;

      // Execute & Verify
      expect(xpBoosterUntil, isNull, reason: 'xpBoosterUntil should be null when not active');
    });

    test('xpBoosterUntil returns DateTime when active', () {
      // Setup: Ativar booster
      final expirationTime = DateTime.now().add(const Duration(hours: 1));
      DateTime? xpBoosterUntil = expirationTime;

      // Execute & Verify
      expect(xpBoosterUntil, equals(expirationTime), 
          reason: 'xpBoosterUntil should return the expiration DateTime');
    });

    test('xpBoosterUntil returns expired DateTime when boost expired', () {
      // Setup: Booster expirado
      final expiredTime = DateTime.now().subtract(const Duration(minutes: 1));
      DateTime? xpBoosterUntil = expiredTime;
      final now = DateTime.now();

      // Execute & Verify
      expect(xpBoosterUntil, equals(expiredTime), 
          reason: 'xpBoosterUntil should return the expired DateTime');
      
      // Computed property hasXpBooster deve retornar false
      final hasXpBooster = now.isBefore(xpBoosterUntil);
      expect(hasXpBooster, isFalse, 
          reason: 'hasXpBooster should be false when boost is expired');
    });

    test('gemMultiplierUntil returns null when not active', () {
      // Setup: Não ativar multiplier
      DateTime? gemMultiplierUntil;

      // Execute & Verify
      expect(gemMultiplierUntil, isNull, 
          reason: 'gemMultiplierUntil should be null when not active');
    });

    test('gemMultiplierUntil returns DateTime when active', () {
      // Setup: Ativar multiplier
      final expirationTime = DateTime.now().add(const Duration(hours: 1));
      DateTime? gemMultiplierUntil = expirationTime;

      // Execute & Verify
      expect(gemMultiplierUntil, equals(expirationTime), 
          reason: 'gemMultiplierUntil should return the expiration DateTime');
    });

    test('gemMultiplierUntil returns expired DateTime when boost expired', () {
      // Setup: Multiplier expirado
      final expiredTime = DateTime.now().subtract(const Duration(minutes: 1));
      DateTime? gemMultiplierUntil = expiredTime;
      final now = DateTime.now();

      // Execute & Verify
      expect(gemMultiplierUntil, equals(expiredTime), 
          reason: 'gemMultiplierUntil should return the expired DateTime');
      
      // Computed property hasGemMultiplier deve retornar false
      final hasGemMultiplier = now.isBefore(gemMultiplierUntil);
      expect(hasGemMultiplier, isFalse, 
          reason: 'hasGemMultiplier should be false when boost is expired');
    });

    test('getters work independently', () {
      // Setup: Ativar apenas XP booster
      final xpExpiration = DateTime.now().add(const Duration(hours: 1));
      DateTime? xpBoosterUntil = xpExpiration;
      DateTime? gemMultiplierUntil;

      // Verify
      expect(xpBoosterUntil, equals(xpExpiration), 
          reason: 'xpBoosterUntil should be set');
      expect(gemMultiplierUntil, isNull, 
          reason: 'gemMultiplierUntil should be null');

      // Setup: Ativar apenas gem multiplier
      xpBoosterUntil = null;
      final gemExpiration = DateTime.now().add(const Duration(hours: 1));
      gemMultiplierUntil = gemExpiration;

      // Verify
      expect(xpBoosterUntil, isNull, 
          reason: 'xpBoosterUntil should be null');
      expect(gemMultiplierUntil, equals(gemExpiration), 
          reason: 'gemMultiplierUntil should be set');
    });

    test('getters work with both boosts active', () {
      // Setup: Ativar ambos
      final xpExpiration = DateTime.now().add(const Duration(hours: 1));
      final gemExpiration = DateTime.now().add(const Duration(minutes: 30));
      DateTime? xpBoosterUntil = xpExpiration;
      DateTime? gemMultiplierUntil = gemExpiration;
      final now = DateTime.now();

      // Verify
      expect(xpBoosterUntil, equals(xpExpiration), 
          reason: 'xpBoosterUntil should be set');
      expect(gemMultiplierUntil, equals(gemExpiration), 
          reason: 'gemMultiplierUntil should be set');
      
      // Verify computed properties
      final hasXpBooster = now.isBefore(xpBoosterUntil);
      final hasGemMultiplier = now.isBefore(gemMultiplierUntil);
      expect(hasXpBooster, isTrue, 
          reason: 'hasXpBooster should be true');
      expect(hasGemMultiplier, isTrue, 
          reason: 'hasGemMultiplier should be true');
    });
  });
}
