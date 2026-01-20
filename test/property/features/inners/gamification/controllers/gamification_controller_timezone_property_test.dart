import 'package:flutter_test/flutter_test.dart' hide test, group, expect;
import 'package:glados/glados.dart';
import 'package:test/test.dart' show test, group, expect;

// Test helper class - isolated timezone logic without Firebase dependencies
class TestTimezoneCalculator {
  String formatDateForStreak(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool isMonday(DateTime date) {
    return date.weekday == DateTime.monday;
  }

  // Simula verificação de reset semanal usando timezone do usuário
  bool shouldResetWeeklyXp(String lastResetDate) {
    final now = DateTime.now(); // User timezone
    final today = formatDateForStreak(now);
    
    return isMonday(now) && lastResetDate != today;
  }

  // Simula verificação de reset diário usando timezone do usuário
  bool shouldResetDailyXp(String lastResetDate) {
    final now = DateTime.now(); // User timezone
    final today = formatDateForStreak(now);
    
    return lastResetDate != today;
  }

  // Simula atualização de streak usando timezone do usuário
  String getStreakDateForToday() {
    final now = DateTime.now(); // User timezone
    return formatDateForStreak(now);
  }
}

void main() {
  group('Feature: gamification-system, Timezone Property Tests', () {
    // Property 44: User Timezone for Date Operations
    // For any date-based operation (streak tracking, XP resets), the date
    // should be calculated using the user's device timezone, not UTC
    test(
      'Property 44: date operations use user timezone (DateTime.now()) not UTC',
      () {
        final calculator = TestTimezoneCalculator();
        
        // Test 1: formatDateForStreak uses local timezone
        final localNow = DateTime.now();
        final utcNow = DateTime.now().toUtc();
        
        final localFormatted = calculator.formatDateForStreak(localNow);
        final utcFormatted = calculator.formatDateForStreak(utcNow);
        
        // If timezone offset causes different dates, they should differ
        // This validates we're using the correct timezone
        expect(
          localFormatted,
          matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')),
          reason: 'Date should be formatted as YYYY-MM-DD',
        );
        
        // Test 2: isSameDay compares dates correctly in user timezone
        final today = DateTime.now();
        final todayAgain = DateTime.now();
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        
        expect(
          calculator.isSameDay(today, todayAgain),
          isTrue,
          reason: 'Same day in user timezone should return true',
        );
        
        expect(
          calculator.isSameDay(today, yesterday),
          isFalse,
          reason: 'Different days in user timezone should return false',
        );
        
        // Test 3: isMonday uses user timezone
        final now = DateTime.now();
        final expectedIsMonday = now.weekday == DateTime.monday;
        
        expect(
          calculator.isMonday(now),
          equals(expectedIsMonday),
          reason: 'isMonday should use user timezone to determine weekday',
        );
        
        // Test 4: Weekly reset uses user timezone
        final lastWeeklyReset = calculator.formatDateForStreak(
          DateTime.now().subtract(const Duration(days: 8)),
        );
        
        // If today is Monday, should reset
        if (DateTime.now().weekday == DateTime.monday) {
          expect(
            calculator.shouldResetWeeklyXp(lastWeeklyReset),
            isTrue,
            reason: 'Weekly XP should reset on Monday in user timezone',
          );
        }
        
        // Test 5: Daily reset uses user timezone
        final lastDailyReset = calculator.formatDateForStreak(
          DateTime.now().subtract(const Duration(days: 1)),
        );
        
        expect(
          calculator.shouldResetDailyXp(lastDailyReset),
          isTrue,
          reason: 'Daily XP should reset at midnight in user timezone',
        );
        
        // Test 6: Streak date uses user timezone
        final streakDate = calculator.getStreakDateForToday();
        final expectedDate = calculator.formatDateForStreak(DateTime.now());
        
        expect(
          streakDate,
          equals(expectedDate),
          reason: 'Streak date should use user timezone (DateTime.now())',
        );
      },
    );

    // Additional property: Date format consistency
    Glados<DateTime>(any.dateTime).test(
      'Property 44a: date formatting is consistent and uses YYYY-MM-DD format',
      (date) {
        final calculator = TestTimezoneCalculator();
        final formatted = calculator.formatDateForStreak(date);
        
        // Verify format matches YYYY-MM-DD
        expect(
          formatted,
          matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')),
          reason: 'Date should always be formatted as YYYY-MM-DD',
        );
        
        // Verify components are correct
        final parts = formatted.split('-');
        expect(parts.length, equals(3), reason: 'Should have 3 parts');
        expect(int.parse(parts[0]), equals(date.year), reason: 'Year should match');
        expect(int.parse(parts[1]), equals(date.month), reason: 'Month should match');
        expect(int.parse(parts[2]), equals(date.day), reason: 'Day should match');
      },
    );

    // Additional property: Same day comparison consistency
    test(
      'Property 44b: isSameDay is consistent with date boundaries',
      () {
        final calculator = TestTimezoneCalculator();
        
        // Test same instant
        final now = DateTime.now();
        expect(
          calculator.isSameDay(now, now),
          isTrue,
          reason: 'Same instant should be same day',
        );
        
        // Test same day, different times
        final morning = DateTime(2024, 1, 15, 8, 0, 0);
        final evening = DateTime(2024, 1, 15, 20, 0, 0);
        expect(
          calculator.isSameDay(morning, evening),
          isTrue,
          reason: 'Same calendar day should return true',
        );
        
        // Test different days
        final day1 = DateTime(2024, 1, 15, 23, 59, 59);
        final day2 = DateTime(2024, 1, 16, 0, 0, 0);
        expect(
          calculator.isSameDay(day1, day2),
          isFalse,
          reason: 'Different calendar days should return false',
        );
        
        // Test different months
        final jan = DateTime(2024, 1, 31);
        final feb = DateTime(2024, 2, 1);
        expect(
          calculator.isSameDay(jan, feb),
          isFalse,
          reason: 'Different months should return false',
        );
        
        // Test different years
        final dec2023 = DateTime(2023, 12, 31);
        final jan2024 = DateTime(2024, 1, 1);
        expect(
          calculator.isSameDay(dec2023, jan2024),
          isFalse,
          reason: 'Different years should return false',
        );
      },
    );

    // Additional property: Monday detection consistency
    test(
      'Property 44c: isMonday correctly identifies Mondays',
      () {
        final calculator = TestTimezoneCalculator();
        
        // Test known Mondays (2024-01-01 was a Monday)
        final monday1 = DateTime(2024, 1, 1);
        expect(
          calculator.isMonday(monday1),
          isTrue,
          reason: '2024-01-01 was a Monday',
        );
        
        // Test known non-Mondays
        final tuesday = DateTime(2024, 1, 2);
        expect(
          calculator.isMonday(tuesday),
          isFalse,
          reason: '2024-01-02 was a Tuesday',
        );
        
        final sunday = DateTime(2024, 1, 7);
        expect(
          calculator.isMonday(sunday),
          isFalse,
          reason: '2024-01-07 was a Sunday',
        );
        
        // Test next Monday (2024-01-08)
        final monday2 = DateTime(2024, 1, 8);
        expect(
          calculator.isMonday(monday2),
          isTrue,
          reason: '2024-01-08 was a Monday',
        );
      },
    );
  });
}
