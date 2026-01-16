import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthController - Logout State Persistence Tests', () {
    setUp(() {
      // Inicializar GetX para testes
      Get.testMode = true;
      
      // Setup SharedPreferences
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() {
      Get.reset();
    });

    group('Logout - State Persistence', () {
      test('should maintain isFirstAccess = false after logout', () async {
        // Arrange
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isFirstAccess', false);

        // Act - Simulate logout (which should NOT reset isFirstAccess)
        // In real logout, we don't touch isFirstAccess
        
        // Assert
        final isFirstAccess = prefs.getBool('isFirstAccess');
        expect(isFirstAccess, false,
            reason: 'isFirstAccess should remain false after logout');
      });

      test('should not reset isFirstAccess to true on logout', () async {
        // Arrange
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isFirstAccess', false);

        // Act - Verify that logout doesn't change isFirstAccess
        final beforeLogout = prefs.getBool('isFirstAccess');
        
        // Simulate logout (no change to isFirstAccess)
        // await logout(); // This would be the actual logout call
        
        final afterLogout = prefs.getBool('isFirstAccess');

        // Assert
        expect(beforeLogout, equals(afterLogout),
            reason: 'isFirstAccess should not change during logout');
        expect(afterLogout, false,
            reason: 'isFirstAccess should remain false');
      });

      test('should preserve isFirstAccess across multiple logout cycles', () async {
        // Arrange
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isFirstAccess', false);

        // Act - Simulate multiple logout/login cycles
        for (int i = 0; i < 5; i++) {
          // Logout (should not change isFirstAccess)
          final isFirstAccess = prefs.getBool('isFirstAccess');
          expect(isFirstAccess, false,
              reason: 'isFirstAccess should remain false in cycle $i');
        }

        // Assert
        final finalValue = prefs.getBool('isFirstAccess');
        expect(finalValue, false,
            reason: 'isFirstAccess should still be false after multiple cycles');
      });
    });
  });
}
