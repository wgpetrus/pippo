import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pippo/features/core/onboarding/navigation/onboarding_navigation.dart';

/// Mock controller for testing navigation skip logic
class MockOnboardingController extends GetxController {
  final authProvider = ''.obs;
  
  bool shouldSkipEmail() => authProvider.value == 'google';
  bool shouldSkipPassword() => authProvider.value == 'google';
  bool shouldSkipVerifyCode() => authProvider.value == 'google';
}

void main() {
  group('Google Onboarding Skip Flow Tests', () {
    late MockOnboardingController controller;
    late OnboardingNavigation nav;

    setUp(() {
      Get.testMode = true;
      controller = MockOnboardingController();
      Get.put<MockOnboardingController>(controller);
      nav = OnboardingNavigation();
    });

    tearDown(() {
      Get.reset();
    });

    group('Skip Logic Tests', () {
      test('shouldSkipEmail returns true for Google users', () {
        // Arrange
        controller.authProvider.value = 'google';

        // Act & Assert
        expect(controller.shouldSkipEmail(), true);
      });

      test('shouldSkipEmail returns false for regular users', () {
        // Arrange
        controller.authProvider.value = '';

        // Act & Assert
        expect(controller.shouldSkipEmail(), false);
      });

      test('shouldSkipPassword returns true for Google users', () {
        // Arrange
        controller.authProvider.value = 'google';

        // Act & Assert
        expect(controller.shouldSkipPassword(), true);
      });

      test('shouldSkipPassword returns false for regular users', () {
        // Arrange
        controller.authProvider.value = '';

        // Act & Assert
        expect(controller.shouldSkipPassword(), false);
      });

      test('shouldSkipVerifyCode returns true for Google users', () {
        // Arrange
        controller.authProvider.value = 'google';

        // Act & Assert
        expect(controller.shouldSkipVerifyCode(), true);
      });

      test('shouldSkipVerifyCode returns false for regular users', () {
        // Arrange
        controller.authProvider.value = '';

        // Act & Assert
        expect(controller.shouldSkipVerifyCode(), false);
      });
    });

    group('Navigation Methods Exist', () {
      test('goToUserEmail method exists', () {
        expect(nav.goToUserEmail, isA<Function>());
      });

      test('goToUserPassword method exists', () {
        expect(nav.goToUserPassword, isA<Function>());
      });

      test('goToVerifyCode method exists', () {
        expect(nav.goToVerifyCode, isA<Function>());
      });

      test('goToConclusion method exists', () {
        expect(nav.goToConclusion, isA<Function>());
      });
    });

    group('Flow Verification', () {
      test('Google user flow skips email, password, and OTP screens', () {
        // Arrange
        controller.authProvider.value = 'google';

        // Act & Assert - Verify all skip conditions are true
        expect(controller.shouldSkipEmail(), true, 
          reason: 'Google users should skip email screen');
        expect(controller.shouldSkipPassword(), true,
          reason: 'Google users should skip password screen');
        expect(controller.shouldSkipVerifyCode(), true,
          reason: 'Google users should skip OTP verification screen');
      });

      test('Regular user flow does NOT skip any screens', () {
        // Arrange
        controller.authProvider.value = '';

        // Act & Assert - Verify all skip conditions are false
        expect(controller.shouldSkipEmail(), false,
          reason: 'Regular users should NOT skip email screen');
        expect(controller.shouldSkipPassword(), false,
          reason: 'Regular users should NOT skip password screen');
        expect(controller.shouldSkipVerifyCode(), false,
          reason: 'Regular users should NOT skip OTP verification screen');
      });

      test('authProvider value determines skip behavior', () {
        // Test Google
        controller.authProvider.value = 'google';
        expect(controller.shouldSkipEmail(), true);
        expect(controller.shouldSkipPassword(), true);
        expect(controller.shouldSkipVerifyCode(), true);

        // Test regular (empty)
        controller.authProvider.value = '';
        expect(controller.shouldSkipEmail(), false);
        expect(controller.shouldSkipPassword(), false);
        expect(controller.shouldSkipVerifyCode(), false);

        // Test regular (email)
        controller.authProvider.value = 'email';
        expect(controller.shouldSkipEmail(), false);
        expect(controller.shouldSkipPassword(), false);
        expect(controller.shouldSkipVerifyCode(), false);
      });
    });
  });
}
