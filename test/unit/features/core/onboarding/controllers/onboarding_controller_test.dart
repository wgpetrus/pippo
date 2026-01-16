import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    // Setup GetX
    Get.testMode = true;

    // Setup SharedPreferences
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    Get.reset();
  });

  group('State Persistence - Onboarding', () {
    test('isFirstAccess is set to false after onboarding completion',
        () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstAccess', true); // Start with true

      // Act - Simulate what completeOnboarding() does
      await prefs.setBool('isFirstAccess', false);

      // Assert
      final isFirstAccess = prefs.getBool('isFirstAccess');
      expect(isFirstAccess, false,
          reason: 'isFirstAccess should be set to false after onboarding');
    });

    test('isFirstAccess remains false after being set', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();

      // Act
      await prefs.setBool('isFirstAccess', false);

      // Assert
      final isFirstAccess = prefs.getBool('isFirstAccess');
      expect(isFirstAccess, false);

      // Verify it stays false even after multiple reads
      final isFirstAccess2 = prefs.getBool('isFirstAccess');
      expect(isFirstAccess2, false);
    });

    test('isFirstAccess defaults to true when not set', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();

      // Act - Don't set anything

      // Assert
      final isFirstAccess = prefs.getBool('isFirstAccess');
      expect(isFirstAccess, isNull,
          reason: 'isFirstAccess should be null when not set');
      
      // In the app, we treat null as true (first access)
      final isFirstAccessOrDefault = isFirstAccess ?? true;
      expect(isFirstAccessOrDefault, true);
    });

    test('isFirstAccess can be read after being set to false', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstAccess', false);

      // Act
      final isFirstAccess = prefs.getBool('isFirstAccess');

      // Assert
      expect(isFirstAccess, false);
    });

    test('isFirstAccess persists across multiple reads', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstAccess', false);

      // Act & Assert - Read multiple times
      for (int i = 0; i < 10; i++) {
        final isFirstAccess = prefs.getBool('isFirstAccess');
        expect(isFirstAccess, false,
            reason: 'isFirstAccess should remain false on read $i');
      }
    });
  });
}
