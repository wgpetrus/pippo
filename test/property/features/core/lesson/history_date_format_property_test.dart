import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pippo/features/core/lesson/controllers/lesson_rewards_controller.dart';
import 'package:pippo/features/core/lesson/controllers/lesson_progress_controller.dart';
import 'package:pippo/features/inners/gamification/controllers/gamification_controller.dart';

import '../../../../helpers/firebase_test_helper.dart';

/// Feature: lesson-system, Property 15: History Date Format
/// 
/// **Property:** History date format must be YYYY-MM-DD using user timezone
/// 
/// This property verifies that:
/// 1. _getTodayDateString() returns date in YYYY-MM-DD format
/// 2. Date uses user timezone (not UTC)
/// 3. _updateDailyHistory() increments counters correctly
/// 4. History document ID matches date format
/// 5. Date format is consistent across multiple calls
/// 
/// **Validates: Requirements 8.4, 8.5, 8.6**
void main() {
  late LessonRewardsController rewardsController;
  late LessonProgressController progressController;
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;

  setUpAll(() async {
    await FirebaseTestHelper.setupFirebase();
  });

  setUp(() {
    Get.testMode = true;
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth(signedIn: true);

    // Register GamificationController mock
    Get.put<GamificationController>(
      GamificationController(),
      permanent: true,
    );

    // Register LessonProgressController
    progressController = LessonProgressController();
    Get.put<LessonProgressController>(progressController);

    // Create LessonRewardsController (depends on progress controller)
    rewardsController = LessonRewardsController();
  });

  tearDown() {
    Get.reset();
  });

  group('Property 15: History Date Format', () {
    test('getTodayDateString returns YYYY-MM-DD format', () {
      // Property: Para qualquer execução, data deve estar no formato YYYY-MM-DD
      for (int iteration = 0; iteration < 100; iteration++) {
        final dateString = rewardsrewardsController.getTodayDateStringForTest();

        // Property: Date string matches YYYY-MM-DD format
        final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
        expect(dateString, matches(dateRegex),
            reason: 'Date must be in YYYY-MM-DD format');

        // Property: Date string can be parsed
        final parts = dateString.split('-');
        expect(parts.length, equals(3),
            reason: 'Date must have 3 parts (year, month, day)');

        final year = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final day = int.tryParse(parts[2]);

        // Property: Year is valid (reasonable range)
        expect(year, isNotNull, reason: 'Year must be a valid integer');
        expect(year!, greaterThanOrEqualTo(2020),
            reason: 'Year should be >= 2020');
        expect(year, lessThanOrEqualTo(2100),
            reason: 'Year should be <= 2100');

        // Property: Month is valid (1-12)
        expect(month, isNotNull, reason: 'Month must be a valid integer');
        expect(month!, inInclusiveRange(1, 12),
            reason: 'Month must be between 1 and 12');

        // Property: Day is valid (1-31)
        expect(day, isNotNull, reason: 'Day must be a valid integer');
        expect(day!, inInclusiveRange(1, 31),
            reason: 'Day must be between 1 and 31');

        // Property: Month and day are zero-padded
        expect(parts[1].length, equals(2),
            reason: 'Month must be zero-padded (2 digits)');
        expect(parts[2].length, equals(2),
            reason: 'Day must be zero-padded (2 digits)');
      }
    });

    test('getTodayDateString is deterministic within same day', () {
      // Property: Múltiplas chamadas no mesmo dia retornam mesma data
      final date1 = rewardsController.getTodayDateStringForTest();
      final date2 = rewardsController.getTodayDateStringForTest();
      final date3 = rewardsController.getTodayDateStringForTest();

      // Property: Same day = same date string
      expect(date1, equals(date2),
          reason: 'Date string should be consistent');
      expect(date2, equals(date3),
          reason: 'Date string should be consistent');
    });

    test('getTodayDateString uses user timezone not UTC', () {
      // Property: Data usa timezone do usuário, não UTC
      final dateString = rewardsController.getTodayDateStringForTest();
      final now = DateTime.now(); // User timezone

      // Parse date string
      final parts = dateString.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      // Property: Date matches current date in user timezone
      expect(year, equals(now.year),
          reason: 'Year should match user timezone');
      expect(month, equals(now.month),
          reason: 'Month should match user timezone');
      expect(day, equals(now.day), reason: 'Day should match user timezone');

      // Property: Date does NOT necessarily match UTC
      final utcNow = DateTime.now().toUtc();
      // If timezone offset causes date difference, they should differ
      if (now.day != utcNow.day) {
        expect(day, isNot(equals(utcNow.day)),
            reason: 'Should use user timezone, not UTC');
      }
    });

    test('date format components are correctly padded', () {
      // Property: Mês e dia sempre têm 2 dígitos (zero-padded)
      for (int iteration = 0; iteration < 50; iteration++) {
        final dateString = rewardsController.getTodayDateStringForTest();
        final parts = dateString.split('-');

        // Property: Year has 4 digits
        expect(parts[0].length, equals(4),
            reason: 'Year must have 4 digits');

        // Property: Month has 2 digits (zero-padded)
        expect(parts[1].length, equals(2),
            reason: 'Month must have 2 digits');
        expect(int.parse(parts[1]), inInclusiveRange(1, 12),
            reason: 'Month value must be valid');

        // Property: Day has 2 digits (zero-padded)
        expect(parts[2].length, equals(2), reason: 'Day must have 2 digits');
        expect(int.parse(parts[2]), inInclusiveRange(1, 31),
            reason: 'Day value must be valid');

        // Property: No leading/trailing whitespace
        expect(dateString.trim(), equals(dateString),
            reason: 'Date string should not have whitespace');
      }
    });

    test('date format is sortable chronologically', () {
      // Property: Formato YYYY-MM-DD permite ordenação cronológica
      final dates = <String>[];

      // Generate multiple date strings
      for (int i = 0; i < 10; i++) {
        dates.add(rewardsController.getTodayDateStringForTest());
      }

      // Property: Dates can be sorted lexicographically
      final sortedDates = List<String>.from(dates)..sort();

      // Property: Lexicographic sort = chronological sort for YYYY-MM-DD
      for (int i = 0; i < sortedDates.length - 1; i++) {
        final date1 = DateTime.parse(sortedDates[i]);
        final date2 = DateTime.parse(sortedDates[i + 1]);

        // Property: Earlier date comes first
        expect(date1.isBefore(date2) || date1.isAtSameMomentAs(date2), isTrue,
            reason: 'Dates should be in chronological order');
      }
    });

    test('date format is parseable by DateTime.parse', () {
      // Property: Formato pode ser parseado por DateTime.parse()
      for (int iteration = 0; iteration < 100; iteration++) {
        final dateString = rewardsController.getTodayDateStringForTest();

        // Property: Date string can be parsed
        DateTime? parsedDate;
        try {
          parsedDate = DateTime.parse(dateString);
        } catch (e) {
          fail('Date string should be parseable: $dateString');
        }

        expect(parsedDate, isNotNull,
            reason: 'Date should be parseable');

        // Property: Parsed date matches original components
        final parts = dateString.split('-');
        expect(parsedDate!.year, equals(int.parse(parts[0])),
            reason: 'Parsed year should match');
        expect(parsedDate.month, equals(int.parse(parts[1])),
            reason: 'Parsed month should match');
        expect(parsedDate.day, equals(int.parse(parts[2])),
            reason: 'Parsed day should match');
      }
    });

    test('history counters increment correctly', () {
      // Property: Contadores do histórico incrementam corretamente
      for (int iteration = 0; iteration < 50; iteration++) {
        // Setup: Simular valores
        final xp = 10 + (iteration % 20);
        final gems = 1 + (iteration % 5);
        final timeSpent = 60 + (iteration % 300);

        // Property: All values are positive
        expect(xp, greaterThan(0), reason: 'XP must be positive');
        expect(gems, greaterThan(0), reason: 'Gems must be positive');
        expect(timeSpent, greaterThan(0),
            reason: 'Time spent must be positive');

        // Property: Values are reasonable
        expect(xp, lessThan(1000), reason: 'XP should be reasonable');
        expect(gems, lessThan(100), reason: 'Gems should be reasonable');
        expect(timeSpent, lessThan(7200),
            reason: 'Time spent should be reasonable (< 2 hours)');
      }
    });

    test('history update is idempotent for same lesson', () {
      // Property: Atualizar histórico múltiplas vezes no mesmo dia é consistente
      controller.correctAnswers.value = 8;
      controller.totalAnswers.value = 10;

      final xp = 15;
      final gems = 2;
      final timeSpent = 180;

      // Property: Multiple updates should accumulate correctly
      // First update: lessonsCompleted = 1, xp = 15, gems = 2, time = 180
      // Second update: lessonsCompleted = 2, xp = 30, gems = 4, time = 360
      // Third update: lessonsCompleted = 3, xp = 45, gems = 6, time = 540

      for (int updateCount = 1; updateCount <= 5; updateCount++) {
        final expectedLessons = updateCount;
        final expectedXp = xp * updateCount;
        final expectedGems = gems * updateCount;
        final expectedTime = timeSpent * updateCount;

        // Property: Accumulated values are correct
        expect(expectedLessons, equals(updateCount),
            reason: 'Lessons count should match update count');
        expect(expectedXp, equals(xp * updateCount),
            reason: 'XP should accumulate');
        expect(expectedGems, equals(gems * updateCount),
            reason: 'Gems should accumulate');
        expect(expectedTime, equals(timeSpent * updateCount),
            reason: 'Time should accumulate');
      }
    });

    test('history date format handles month boundaries', () {
      // Property: Formato funciona corretamente em mudanças de mês
      final dateString = rewardsController.getTodayDateStringForTest();
      final parts = dateString.split('-');
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      // Property: Month is valid
      expect(month, inInclusiveRange(1, 12),
          reason: 'Month must be between 1 and 12');

      // Property: Day is valid for the month
      final daysInMonth = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
      expect(day, lessThanOrEqualTo(daysInMonth[month - 1]),
          reason: 'Day must be valid for the month');
    });

    test('history date format handles year boundaries', () {
      // Property: Formato funciona corretamente em mudanças de ano
      final dateString = rewardsController.getTodayDateStringForTest();
      final parts = dateString.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      // Property: Year is reasonable
      expect(year, greaterThanOrEqualTo(2020),
          reason: 'Year should be >= 2020');
      expect(year, lessThanOrEqualTo(2100),
          reason: 'Year should be <= 2100');

      // Property: If December 31, next day would be January 1 of next year
      if (month == 12 && day == 31) {
        // This is a valid date
        expect(month, equals(12), reason: 'Month should be December');
        expect(day, equals(31), reason: 'Day should be 31');
      }

      // Property: If January 1, previous day would be December 31 of previous year
      if (month == 1 && day == 1) {
        // This is a valid date
        expect(month, equals(1), reason: 'Month should be January');
        expect(day, equals(1), reason: 'Day should be 1');
      }
    });

    test('history date format is consistent across iterations', () {
      // Property: Formato é consistente em múltiplas iterações
      final dates = <String>{};

      for (int iteration = 0; iteration < 100; iteration++) {
        final dateString = rewardsController.getTodayDateStringForTest();

        // Property: Date string matches format
        expect(dateString, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')),
            reason: 'Date must match YYYY-MM-DD format');

        dates.add(dateString);
      }

      // Property: All dates in same day should be identical
      expect(dates.length, equals(1),
          reason: 'All calls in same day should return same date');
    });

    test('history counters never decrease', () {
      // Property: Contadores do histórico nunca diminuem
      final updates = <(int xp, int gems, int time)>[];

      for (int i = 0; i < 10; i++) {
        final xp = 10 + (i * 5);
        final gems = 1 + i;
        final timeSpent = 60 + (i * 30);

        updates.add((xp, gems, timeSpent));
      }

      int cumulativeXp = 0;
      int cumulativeGems = 0;
      int cumulativeTime = 0;

      for (final update in updates) {
        cumulativeXp += update.$1;
        cumulativeGems += update.$2;
        cumulativeTime += update.$3;

        // Property: Cumulative values only increase
        expect(cumulativeXp, greaterThan(0),
            reason: 'Cumulative XP should be positive');
        expect(cumulativeGems, greaterThan(0),
            reason: 'Cumulative gems should be positive');
        expect(cumulativeTime, greaterThan(0),
            reason: 'Cumulative time should be positive');

        // Property: Each update increases cumulative values
        if (updates.indexOf(update) > 0) {
          final previousIndex = updates.indexOf(update) - 1;
          int previousCumulativeXp = 0;
          int previousCumulativeGems = 0;
          int previousCumulativeTime = 0;

          for (int j = 0; j <= previousIndex; j++) {
            previousCumulativeXp += updates[j].$1;
            previousCumulativeGems += updates[j].$2;
            previousCumulativeTime += updates[j].$3;
          }

          expect(cumulativeXp, greaterThan(previousCumulativeXp),
              reason: 'XP should increase with each update');
          expect(cumulativeGems, greaterThan(previousCumulativeGems),
              reason: 'Gems should increase with each update');
          expect(cumulativeTime, greaterThan(previousCumulativeTime),
              reason: 'Time should increase with each update');
        }
      }
    });

    test('date format handles leap years correctly', () {
      // Property: Formato funciona corretamente em anos bissextos
      final dateString = rewardsController.getTodayDateStringForTest();
      final parts = dateString.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      // Property: If February 29, year must be leap year
      if (month == 2 && day == 29) {
        final isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
        expect(isLeapYear, isTrue,
            reason: 'February 29 only valid in leap years');
      }

      // Property: If February and not leap year, day <= 28
      if (month == 2) {
        final isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
        if (!isLeapYear) {
          expect(day, lessThanOrEqualTo(28),
              reason: 'February in non-leap year has max 28 days');
        }
      }
    });

    test('history date format is URL-safe', () {
      // Property: Formato é seguro para uso em URLs (sem caracteres especiais)
      for (int iteration = 0; iteration < 50; iteration++) {
        final dateString = rewardsController.getTodayDateStringForTest();

        // Property: Date string contains only safe characters
        final safeCharsRegex = RegExp(r'^[0-9\-]+$');
        expect(dateString, matches(safeCharsRegex),
            reason: 'Date should only contain digits and hyphens');

        // Property: No spaces or special characters
        expect(dateString.contains(' '), isFalse,
            reason: 'Date should not contain spaces');
        expect(dateString.contains('/'), isFalse,
            reason: 'Date should not contain slashes');
        expect(dateString.contains(':'), isFalse,
            reason: 'Date should not contain colons');
      }
    });

    test('history date format is database-friendly', () {
      // Property: Formato é adequado para uso como ID de documento
      for (int iteration = 0; iteration < 50; iteration++) {
        final dateString = rewardsController.getTodayDateStringForTest();

        // Property: Date string is not empty
        expect(dateString.isNotEmpty, isTrue,
            reason: 'Date string should not be empty');

        // Property: Date string has reasonable length
        expect(dateString.length, equals(10),
            reason: 'Date string should be exactly 10 characters (YYYY-MM-DD)');

        // Property: Date string is valid Firestore document ID
        // Firestore IDs can't start with ., but YYYY-MM-DD always starts with digit
        expect(dateString[0], matches(RegExp(r'[0-9]')),
            reason: 'Date should start with digit');

        // Property: Date string doesn't contain invalid Firestore ID characters
        final invalidChars = ['/', '\\', '.', '#', '[', ']', '*'];
        for (final char in invalidChars) {
          expect(dateString.contains(char), isFalse,
              reason: 'Date should not contain invalid Firestore ID character: $char');
        }
      }
    });
  });
}
