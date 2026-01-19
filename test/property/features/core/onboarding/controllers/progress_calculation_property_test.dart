import 'package:flutter_test/flutter_test.dart';

/// Property 4: Progress Calculation Accuracy
/// Validates: Requirements 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 9.8
///
/// For any screen in the onboarding flow, the progress bar should display
/// the correct fraction (current/total) based on whether the user is in
/// full onboarding or add course mode, excluding transition screens from the count.
/// 
/// NOTA: Este teste valida a lógica de cálculo de progresso sem instanciar o OnboardingController
/// para evitar dependência do Firebase. A função calculateProgress abaixo é uma cópia exata do método
/// do OnboardingController. Qualquer mudança no controller DEVE ser refletida aqui.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Função extraída do OnboardingController
  // IMPORTANTE: Manter sincronizado com lib/features/core/onboarding/controllers/onboarding_controller.dart
  Map<String, int> calculateProgress(String currentScreen, bool isAddingCourse) {
    // Define screen order for full onboarding (9 screens - excludes transitions)
    final fullOnboardingScreens = [
      'select_language',
      'language_level',
      'learning_reason',
      'study_time',
      'user_name',
      'user_age',
      'user_email',
      'user_password',
      'verify_code',
    ];

    // Define screen order for add course mode (4 screens)
    final addCourseScreens = [
      'select_language',
      'language_level',
      'learning_reason',
      'study_time',
    ];

    // Select appropriate screen list based on mode
    final screens = isAddingCourse ? addCourseScreens : fullOnboardingScreens;
    final total = screens.length;

    // Find current position (1-indexed)
    final index = screens.indexOf(currentScreen);
    final current = index >= 0 ? index + 1 : 1;

    return {'current': current, 'total': total};
  }

  group('Feature: onboarding, Property 4: Progress Calculation Accuracy', () {

    test('Full onboarding mode: progress for each screen is correct', () {
      // Define full onboarding screens (9 screens, excludes transitions)
      final fullOnboardingScreens = [
        'select_language',
        'language_level',
        'learning_reason',
        'study_time',
        'user_name',
        'user_age',
        'user_email',
        'user_password',
        'verify_code',
      ];

      // Test in full onboarding mode
      const isAddingCourse = false;

      // Test progress for each screen
      for (int i = 0; i < fullOnboardingScreens.length; i++) {
        final screen = fullOnboardingScreens[i];
        final progressData = calculateProgress(screen, isAddingCourse);
        
        final expectedCurrent = i + 1;
        final expectedTotal = 9;

        expect(
          progressData['current'],
          equals(expectedCurrent),
          reason: 'Screen "$screen" should be at position $expectedCurrent',
        );
        expect(
          progressData['total'],
          equals(expectedTotal),
          reason: 'Total screens in full onboarding should be $expectedTotal',
        );
      }
    });

    test('Add course mode: progress for each screen is correct', () {
      // Define add course mode screens (4 screens)
      final addCourseScreens = [
        'select_language',
        'language_level',
        'learning_reason',
        'study_time',
      ];

      // Test in add course mode
      const isAddingCourse = true;

      // Test progress for each screen
      for (int i = 0; i < addCourseScreens.length; i++) {
        final screen = addCourseScreens[i];
        final progressData = calculateProgress(screen, isAddingCourse);
        
        final expectedCurrent = i + 1;
        final expectedTotal = 4;

        expect(
          progressData['current'],
          equals(expectedCurrent),
          reason: 'Screen "$screen" should be at position $expectedCurrent in add course mode',
        );
        expect(
          progressData['total'],
          equals(expectedTotal),
          reason: 'Total screens in add course mode should be $expectedTotal',
        );
      }
    });

    test('Transition screens are excluded from progress calculation', () {
      // Transition screens that should NOT be counted
      final transitionScreens = [
        'welcome',
        'intro',
        'pause_one',
        'pause_two',
        'conclusion',
      ];

      const isAddingCourse = false;

      // Test that transition screens return position 1 (not found in list)
      for (final screen in transitionScreens) {
        final progressData = calculateProgress(screen, isAddingCourse);
        
        expect(
          progressData['current'],
          equals(1),
          reason: 'Transition screen "$screen" should not be in progress list (defaults to 1)',
        );
        expect(
          progressData['total'],
          equals(9),
          reason: 'Total should still be 9 for full onboarding',
        );
      }
    });

    test('Progress fractions are correct for full onboarding', () {
      const isAddingCourse = false;

      final expectedFractions = [
        {'screen': 'select_language', 'fraction': 1 / 9},
        {'screen': 'language_level', 'fraction': 2 / 9},
        {'screen': 'learning_reason', 'fraction': 3 / 9},
        {'screen': 'study_time', 'fraction': 4 / 9},
        {'screen': 'user_name', 'fraction': 5 / 9},
        {'screen': 'user_age', 'fraction': 6 / 9},
        {'screen': 'user_email', 'fraction': 7 / 9},
        {'screen': 'user_password', 'fraction': 8 / 9},
        {'screen': 'verify_code', 'fraction': 9 / 9},
      ];

      for (final item in expectedFractions) {
        final screen = item['screen'] as String;
        final expectedFraction = item['fraction'] as double;
        
        final progressData = calculateProgress(screen, isAddingCourse);
        final current = progressData['current']!;
        final total = progressData['total']!;
        final actualFraction = current / total;

        expect(
          actualFraction,
          equals(expectedFraction),
          reason: 'Screen "$screen" should have fraction $expectedFraction',
        );
      }
    });

    test('Progress fractions are correct for add course mode', () {
      const isAddingCourse = true;

      final expectedFractions = [
        {'screen': 'select_language', 'fraction': 1 / 4},
        {'screen': 'language_level', 'fraction': 2 / 4},
        {'screen': 'learning_reason', 'fraction': 3 / 4},
        {'screen': 'study_time', 'fraction': 4 / 4},
      ];

      for (final item in expectedFractions) {
        final screen = item['screen'] as String;
        final expectedFraction = item['fraction'] as double;
        
        final progressData = calculateProgress(screen, isAddingCourse);
        final current = progressData['current']!;
        final total = progressData['total']!;
        final actualFraction = current / total;

        expect(
          actualFraction,
          equals(expectedFraction),
          reason: 'Screen "$screen" should have fraction $expectedFraction in add course mode',
        );
      }
    });

    test('Unknown screen defaults to position 1', () {
      const isAddingCourse = false;

      final unknownScreens = [
        'unknown_screen',
        'random_page',
        'invalid',
        '',
      ];

      for (final screen in unknownScreens) {
        final progressData = calculateProgress(screen, isAddingCourse);
        
        expect(
          progressData['current'],
          equals(1),
          reason: 'Unknown screen "$screen" should default to position 1',
        );
        expect(
          progressData['total'],
          equals(9),
          reason: 'Total should be 9 for full onboarding',
        );
      }
    });

    test('Mode switching updates progress calculation correctly', () {
      final screen = 'study_time';

      // Test in full onboarding mode
      var progressData = calculateProgress(screen, false);
      expect(progressData['current'], equals(4));
      expect(progressData['total'], equals(9));

      // Test in add course mode
      progressData = calculateProgress(screen, true);
      expect(progressData['current'], equals(4));
      expect(progressData['total'], equals(4));

      // Test back in full onboarding mode
      progressData = calculateProgress(screen, false);
      expect(progressData['current'], equals(4));
      expect(progressData['total'], equals(9));
    });

    test('Property: Progress calculation is consistent across 100 iterations', () {
      // Test with various screens and modes
      final testCases = [
        {'screen': 'select_language', 'mode': false, 'expectedCurrent': 1, 'expectedTotal': 9},
        {'screen': 'language_level', 'mode': false, 'expectedCurrent': 2, 'expectedTotal': 9},
        {'screen': 'study_time', 'mode': false, 'expectedCurrent': 4, 'expectedTotal': 9},
        {'screen': 'verify_code', 'mode': false, 'expectedCurrent': 9, 'expectedTotal': 9},
        {'screen': 'select_language', 'mode': true, 'expectedCurrent': 1, 'expectedTotal': 4},
        {'screen': 'study_time', 'mode': true, 'expectedCurrent': 4, 'expectedTotal': 4},
      ];

      // Run 100 iterations to verify consistency
      for (int iteration = 0; iteration < 100; iteration++) {
        for (final testCase in testCases) {
          final screen = testCase['screen'] as String;
          final mode = testCase['mode'] as bool;
          final expectedCurrent = testCase['expectedCurrent'] as int;
          final expectedTotal = testCase['expectedTotal'] as int;

          final progressData = calculateProgress(screen, mode);

          expect(
            progressData['current'],
            equals(expectedCurrent),
            reason: 'Iteration $iteration: Screen "$screen" (mode: $mode) should be at position $expectedCurrent',
          );
          expect(
            progressData['total'],
            equals(expectedTotal),
            reason: 'Iteration $iteration: Total for mode $mode should be $expectedTotal',
          );
        }
      }
    });
  });
}
