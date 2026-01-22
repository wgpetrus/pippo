import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pippo/features/inners/leaderboard/views/leaderboard_page.dart';
import 'package:pippo/shared/theme/theme.dart';

/// Integration test to verify leaderboard shows clear placeholder for test data
void main() {
  group('Leaderboard Placeholder Tests', () {
    testWidgets('Leaderboard page renders successfully with mock data',
        (WidgetTester tester) async {
      // Arrange: Build the leaderboard page
      await tester.pumpWidget(
        GetMaterialApp(
          home: const LeaderboardPage(),
          theme: ThemeData(
            fontFamily: 'Nunito',
            scaffoldBackgroundColor: AppTheme.white,
          ),
        ),
      );

      // Wait for animations
      await tester.pumpAndSettle();

      // Assert: The page renders successfully
      expect(
        find.byType(LeaderboardPage),
        findsOneWidget,
        reason: 'LeaderboardPage should render successfully',
      );

      // Assert: Verify the page has a CustomScrollView (main structure)
      expect(
        find.byType(CustomScrollView),
        findsOneWidget,
        reason: 'LeaderboardPage should have CustomScrollView structure',
      );
    });

    testWidgets('Leaderboard shows test data placeholder text',
        (WidgetTester tester) async {
      // Arrange: Build the leaderboard page
      await tester.pumpWidget(
        GetMaterialApp(
          home: const LeaderboardPage(),
          theme: ThemeData(
            fontFamily: 'Nunito',
            scaffoldBackgroundColor: AppTheme.white,
          ),
        ),
      );

      // Wait for animations
      await tester.pumpAndSettle();

      // Assert: Verify test data banner text is present
      expect(
        find.textContaining('Test data'),
        findsOneWidget,
        reason: 'Test data placeholder text should be visible',
      );

      expect(
        find.textContaining('Firestore'),
        findsOneWidget,
        reason: 'Reference to Firestore should be in placeholder text',
      );
    });
  });
}
