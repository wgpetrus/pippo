import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pippo/features/inners/treasure/controllers/treasure_challenges_controller.dart';
import 'package:pippo/features/inners/treasure/controllers/treasure_rewards_controller.dart';
import 'package:pippo/features/inners/treasure/views/treasure_page.dart';
import 'package:pippo/features/inners/treasure/widgets/challenge_card.dart';
import 'package:pippo/features/inners/treasure/widgets/empty_state.dart';
import 'package:pippo/features/inners/treasure/widgets/treasure_header.dart';
import 'package:pippo/shared/theme/theme.dart';

import '../helpers/firebase_test_helper.dart';

/// Integration tests for Treasure UI components
/// 
/// Verifies:
/// - TreasurePage displays correctly
/// - Loading state is shown
/// - Empty state is displayed when no challenges
/// - Challenge cards are displayed when challenges exist
/// - Error state is handled properly
/// 
/// **Note**: These tests use mock controllers to avoid Firebase initialization
/// issues in test environment. The controllers' onInit is bypassed by manually
/// setting states instead of relying on automatic loading.
void main() {
  group('Treasure UI Integration Tests', () {
    late TreasureChallengesController challengesController;
    late TreasureRewardsController rewardsController;

    setUpAll(() async {
      // Initialize Firebase for tests
      await FirebaseTestHelper.setupFirebase();
    });

    setUp(() async {
      // Initialize GetX
      Get.testMode = true;
      
      // Create and register controllers
      // Note: onInit() will be called but we'll override the states immediately after
      challengesController = TreasureChallengesController();
      rewardsController = TreasureRewardsController();
      
      Get.put<TreasureChallengesController>(challengesController);
      Get.put<TreasureRewardsController>(rewardsController);
      
      // Wait a bit for onInit to complete (or fail)
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Manually set initial state to override any Firebase loading
      challengesController.isLoading.value = false;
      challengesController.errorMessage.value = '';
      challengesController.challenges.clear();
      
      rewardsController.isLoading.value = false;
      rewardsController.errorMessage.value = '';
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('TreasurePage displays loading state initially',
        (WidgetTester tester) async {
      // Set loading state
      challengesController.isLoading.value = true;

      await tester.pumpWidget(
        GetMaterialApp(
          theme: ThemeData(
            fontFamily: 'Nunito',
            colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.primary),
          ),
          home: const TreasurePage(),
        ),
      );

      // Verify loading indicator is displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(EmptyState), findsNothing);
      expect(find.byType(ChallengeCard), findsNothing);
    });

    testWidgets('TreasurePage displays empty state when no challenges',
        (WidgetTester tester) async {
      // Set empty state
      challengesController.isLoading.value = false;
      challengesController.challenges.clear();

      await tester.pumpWidget(
        GetMaterialApp(
          theme: ThemeData(
            fontFamily: 'Nunito',
            colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.primary),
          ),
          home: const TreasurePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify empty state is displayed
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('Nenhum desafio disponível'), findsOneWidget);
      expect(find.byType(ChallengeCard), findsNothing);
    });

    testWidgets('TreasurePage displays challenges when available',
        (WidgetTester tester) async {
      // Add mock challenges
      challengesController.isLoading.value = false;
      challengesController.challenges.value = [
        {
          'id': 'challenge_1',
          'type': 'daily',
          'title': 'Complete 3 lições',
          'description': 'Termine 3 lições hoje',
          'goal': 3,
          'progress': 1,
          'rewardType': 'gems',
          'rewardAmount': 50,
          'iconPath': 'assets/images/icons/icons-treasure-page/livro.png',
          'expirationDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))),
          'isClaimed': false,
        },
      ];

      await tester.pumpWidget(
        GetMaterialApp(
          theme: ThemeData(
            fontFamily: 'Nunito',
            colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.primary),
          ),
          home: const TreasurePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify treasure header is displayed
      expect(find.byType(TreasureHeader), findsOneWidget);
      
      // Verify challenge card is displayed
      expect(find.byType(ChallengeCard), findsOneWidget);
      expect(find.text('Complete 3 lições'), findsOneWidget);
      
      // Verify empty state is not displayed
      expect(find.byType(EmptyState), findsNothing);
    });

    testWidgets('TreasurePage displays error state correctly',
        (WidgetTester tester) async {
      // Set error state
      challengesController.isLoading.value = false;
      challengesController.errorMessage.value = 'Erro ao carregar desafios';

      await tester.pumpWidget(
        GetMaterialApp(
          theme: ThemeData(
            fontFamily: 'Nunito',
            colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.primary),
          ),
          home: const TreasurePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify error message is displayed
      expect(find.text('Erro ao carregar desafios'), findsOneWidget);
      
      // Verify retry button is displayed
      expect(find.text('Tentar novamente'), findsOneWidget);
      
      // Verify other states are not displayed
      expect(find.byType(EmptyState), findsNothing);
      expect(find.byType(ChallengeCard), findsNothing);
    });

    testWidgets('TreasurePage groups challenges by type',
        (WidgetTester tester) async {
      // Add challenges of different types
      challengesController.isLoading.value = false;
      challengesController.challenges.value = [
        {
          'id': 'daily_1',
          'type': 'daily',
          'title': 'Desafio Diário 1',
          'description': 'Descrição',
          'goal': 3,
          'progress': 1,
          'rewardType': 'gems',
          'rewardAmount': 50,
          'iconPath': 'assets/images/icons/icons-treasure-page/livro.png',
          'expirationDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))),
          'isClaimed': false,
        },
        {
          'id': 'weekly_1',
          'type': 'weekly',
          'title': 'Missão Semanal 1',
          'description': 'Descrição',
          'goal': 15,
          'progress': 5,
          'rewardType': 'gems',
          'rewardAmount': 200,
          'iconPath': 'assets/images/icons/icons-treasure-page/bau-gemado.png',
          'expirationDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
          'isClaimed': false,
        },
      ];

      await tester.pumpWidget(
        GetMaterialApp(
          theme: ThemeData(
            fontFamily: 'Nunito',
            colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.primary),
          ),
          home: const TreasurePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify section titles are displayed
      expect(find.text('Desafios Diários'), findsOneWidget);
      expect(find.text('Missões Semanais'), findsOneWidget);
      
      // Verify both challenges are displayed
      expect(find.text('Desafio Diário 1'), findsOneWidget);
      expect(find.text('Missão Semanal 1'), findsOneWidget);
      
      // Verify correct number of challenge cards
      expect(find.byType(ChallengeCard), findsNWidgets(2));
    });

    testWidgets('TreasurePage supports pull-to-refresh',
        (WidgetTester tester) async {
      // Set initial state with challenges
      challengesController.isLoading.value = false;
      challengesController.challenges.value = [
        {
          'id': 'challenge_1',
          'type': 'daily',
          'title': 'Complete 3 lições',
          'description': 'Termine 3 lições hoje',
          'goal': 3,
          'progress': 1,
          'rewardType': 'gems',
          'rewardAmount': 50,
          'iconPath': 'assets/images/icons/icons-treasure-page/livro.png',
          'expirationDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))),
          'isClaimed': false,
        },
      ];

      await tester.pumpWidget(
        GetMaterialApp(
          theme: ThemeData(
            fontFamily: 'Nunito',
            colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.primary),
          ),
          home: const TreasurePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify RefreshIndicator exists
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}

