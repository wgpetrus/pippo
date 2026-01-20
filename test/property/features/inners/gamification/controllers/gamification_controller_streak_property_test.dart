import 'package:flutter_test/flutter_test.dart' hide test, group, expect;
import 'package:glados/glados.dart';
import 'package:test/test.dart' show test, group, expect;

// Test helper class - isolated streak logic without Firebase dependencies
class TestStreakCalculator {
  int currentStreak = 0;
  int longestStreak = 0;
  String lastStreakDate = '';
  bool streakFreezeAvailable = false;

  String formatDateForStreak(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void updateStreak(DateTime now) {
    final today = formatDateForStreak(now);

    // Primeiro caso: primeira lição ever
    if (lastStreakDate.isEmpty) {
      currentStreak = 1;
      longestStreak = 1;
      lastStreakDate = today;
      return;
    }

    // Segundo caso: já completou hoje
    if (lastStreakDate == today) {
      return;
    }

    // Calcular diferença de dias
    final lastDateTime = DateTime.parse(lastStreakDate);
    final daysDifference = now.difference(lastDateTime).inDays;

    // Terceiro caso: dia consecutivo
    if (daysDifference == 1) {
      currentStreak++;
      longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
      lastStreakDate = today;
      return;
    }

    // Quarto caso: perdeu um dia mas tem freeze
    if (daysDifference == 2 && streakFreezeAvailable) {
      lastStreakDate = today;
      streakFreezeAvailable = false;
      return;
    }

    // Quinto caso: streak quebrado - reset
    currentStreak = 1;
    lastStreakDate = today;
  }
}

void main() {
  group('Feature: gamification-system, Streak System Property Tests', () {
    // Property 5: First Lesson Increments Streak
    // For any user completing their first lesson of a day, currentStreak
    // should increment by exactly 1 and lastStreakDate should update to
    // today's date in "YYYY-MM-DD" format
    test(
      'Property 5: first lesson increments streak by 1 and updates date',
      () {
        // Test first lesson ever
        final calculator1 = TestStreakCalculator();
        final now1 = DateTime.now();
        
        calculator1.updateStreak(now1);
        
        expect(
          calculator1.currentStreak,
          equals(1),
          reason: 'First lesson ever should set streak to 1',
        );
        expect(
          calculator1.lastStreakDate,
          equals(calculator1.formatDateForStreak(now1)),
          reason: 'lastStreakDate should be set to today in YYYY-MM-DD format',
        );
        expect(
          calculator1.longestStreak,
          equals(1),
          reason: 'longestStreak should be set to 1 on first lesson',
        );

        // Test consecutive day
        final calculator2 = TestStreakCalculator();
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        calculator2.lastStreakDate = calculator2.formatDateForStreak(yesterday);
        calculator2.currentStreak = 5;
        calculator2.longestStreak = 5;
        
        final now2 = DateTime.now();
        calculator2.updateStreak(now2);
        
        expect(
          calculator2.currentStreak,
          equals(6),
          reason: 'Consecutive day should increment streak by 1',
        );
        expect(
          calculator2.lastStreakDate,
          equals(calculator2.formatDateForStreak(now2)),
          reason: 'lastStreakDate should update to today',
        );
        expect(
          calculator2.longestStreak,
          equals(6),
          reason: 'longestStreak should update when current exceeds it',
        );
      },
    );

    // Property 6: Missed Day Resets Streak
    // For any streak state where last lesson was more than 1 day ago
    // and no streak freeze is available, currentStreak should reset to 1
    Glados(any.int).test(
      'Property 6: missed day without freeze resets streak to 1',
      (initialStreak) {
        // Constrain to valid range (1-365)
        final streak = (initialStreak.abs() % 365) + 1;
        
        // Create calculator with existing streak
        final calculator = TestStreakCalculator();
        calculator.currentStreak = streak;
        calculator.longestStreak = streak;
        
        // Set last streak date to 3+ days ago (missed more than 1 day)
        final daysAgo = 3;
        final lastDate = DateTime.now().subtract(Duration(days: daysAgo));
        calculator.lastStreakDate = calculator.formatDateForStreak(lastDate);
        
        // No freeze available
        calculator.streakFreezeAvailable = false;
        
        // Update streak
        final now = DateTime.now();
        calculator.updateStreak(now);
        
        // Verify streak reset to 1
        expect(
          calculator.currentStreak,
          equals(1),
          reason: 'Streak should reset to 1 when more than 1 day is missed without freeze',
        );
        
        // Verify date updated
        expect(
          calculator.lastStreakDate,
          equals(calculator.formatDateForStreak(now)),
          reason: 'lastStreakDate should update to today',
        );
        
        // Verify longest streak unchanged
        expect(
          calculator.longestStreak,
          equals(streak),
          reason: 'longestStreak should not change when streak breaks',
        );
      },
    );

    // Property 7: Multiple Lessons Same Day
    // For any user completing N lessons in the same day (N > 1),
    // streak should increment only once regardless of N
    Glados(any.int).test(
      'Property 7: multiple lessons same day only increment streak once',
      (lessonsCount) {
        // Constrain to valid range (2-10 lessons)
        final n = (lessonsCount.abs() % 9) + 2; // 2-10
        
        // Create calculator with existing streak
        final calculator = TestStreakCalculator();
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        calculator.lastStreakDate = calculator.formatDateForStreak(yesterday);
        calculator.currentStreak = 5;
        calculator.longestStreak = 5;
        
        // Complete N lessons on the same day
        final now = DateTime.now();
        for (int i = 0; i < n; i++) {
          calculator.updateStreak(now);
        }
        
        // Verify streak only incremented once
        expect(
          calculator.currentStreak,
          equals(6),
          reason: 'Streak should only increment once regardless of lessons completed on same day',
        );
        
        // Verify date is today
        expect(
          calculator.lastStreakDate,
          equals(calculator.formatDateForStreak(now)),
          reason: 'lastStreakDate should be today',
        );
      },
    );

    // Property 8: Streak Freeze Consumption
    // For any streak state with streakFreezeAvailable=true, when a day
    // is missed, streak should be maintained and freeze should be consumed
    Glados(any.int).test(
      'Property 8: streak freeze maintains streak and gets consumed',
      (initialStreak) {
        // Constrain to valid range (1-365)
        final streak = (initialStreak.abs() % 365) + 1;
        
        // Create calculator with existing streak and freeze
        final calculator = TestStreakCalculator();
        calculator.currentStreak = streak;
        calculator.longestStreak = streak;
        calculator.streakFreezeAvailable = true;
        
        // Set last streak date to 2 days ago (missed exactly 1 day)
        final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
        calculator.lastStreakDate = calculator.formatDateForStreak(twoDaysAgo);
        
        // Update streak
        final now = DateTime.now();
        calculator.updateStreak(now);
        
        // Verify streak maintained
        expect(
          calculator.currentStreak,
          equals(streak),
          reason: 'Streak should be maintained when freeze is available',
        );
        
        // Verify freeze consumed
        expect(
          calculator.streakFreezeAvailable,
          isFalse,
          reason: 'Streak freeze should be consumed after use',
        );
        
        // Verify date updated
        expect(
          calculator.lastStreakDate,
          equals(calculator.formatDateForStreak(now)),
          reason: 'lastStreakDate should update to today',
        );
      },
    );
  });
}
