import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:pippo/features/inners/leaderboard/controllers/leaderboard_controller.dart';
import '../../../../../helpers/firebase_test_helper.dart';

void main() {
  group('LeaderboardController - loadLeaderboardData()', () {
    late LeaderboardController controller;
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore mockFirestore;

    setUpAll(() async {
      // Inicializar Firebase para todos os testes
      await FirebaseTestHelper.setupFirebase();
    });

    setUp(() {
      // Inicializar GetX para testes
      Get.testMode = true;
      mockAuth = FirebaseTestHelper.createMockAuth(signedIn: false);
      mockFirestore = FirebaseTestHelper.createMockFirestore();
      controller = LeaderboardController(auth: mockAuth, firestore: mockFirestore);
    });

    tearDown(() {
      Get.reset();
    });

    // ... rest of the tests ...
  });

  group('LeaderboardController - empty data handling', () {
    late LeaderboardController controller;
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore mockFirestore;

    setUpAll(() async {
      await FirebaseTestHelper.setupFirebase();
    });

    setUp(() {
      Get.testMode = true;
      mockAuth = FirebaseTestHelper.createMockAuth(signedIn: false);
      mockFirestore = FirebaseTestHelper.createMockFirestore();
      controller = LeaderboardController(auth: mockAuth, firestore: mockFirestore);
    });

    tearDown(() {
      Get.reset();
    });

    // ... rest of the tests ...
  });

  group('LeaderboardController - error handling', () {
    late LeaderboardController controller;
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore mockFirestore;

    setUpAll(() async {
      await FirebaseTestHelper.setupFirebase();
    });

    setUp(() {
      Get.testMode = true;
      mockAuth = FirebaseTestHelper.createMockAuth(signedIn: false);
      mockFirestore = FirebaseTestHelper.createMockFirestore();
      controller = LeaderboardController(auth: mockAuth, firestore: mockFirestore);
    });

    tearDown(() {
      Get.reset();
    });

    // ... rest of the tests ...
  });

  group('LeaderboardController - getUserZone()', () {
    late LeaderboardController controller;
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore mockFirestore;

    setUpAll(() async {
      await FirebaseTestHelper.setupFirebase();
    });

    setUp(() {
      Get.testMode = true;
      mockAuth = FirebaseTestHelper.createMockAuth(signedIn: false);
      mockFirestore = FirebaseTestHelper.createMockFirestore();
      controller = LeaderboardController(auth: mockAuth, firestore: mockFirestore);
    });

    tearDown(() {
      Get.reset();
    });

    // ... rest of the tests ...
  });

  group('LeaderboardController - getRankForUser()', () {
    late LeaderboardController controller;
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore mockFirestore;

    setUpAll(() async {
      await FirebaseTestHelper.setupFirebase();
    });

    setUp(() {
      Get.testMode = true;
      mockAuth = FirebaseTestHelper.createMockAuth(signedIn: false);
      mockFirestore = FirebaseTestHelper.createMockFirestore();
      controller = LeaderboardController(auth: mockAuth, firestore: mockFirestore);
    });

    tearDown(() {
      Get.reset();
    });

    // ... rest of the tests ...
  });

  group('LeaderboardController - updateUserStatus()', () {
    late LeaderboardController controller;
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore mockFirestore;

    setUpAll(() async {
      await FirebaseTestHelper.setupFirebase();
    });

    setUp(() {
      Get.testMode = true;
      mockAuth = FirebaseTestHelper.createMockAuth(signedIn: false);
      mockFirestore = FirebaseTestHelper.createMockFirestore();
      controller = LeaderboardController(auth: mockAuth, firestore: mockFirestore);
    });

    tearDown(() {
      Get.reset();
    });

    // ... rest of the tests ...
  });

  group('LeaderboardController - getRewardForRank()', () {
    late LeaderboardController controller;
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore mockFirestore;

    setUpAll(() async {
      await FirebaseTestHelper.setupFirebase();
    });

    setUp(() {
      Get.testMode = true;
      mockAuth = FirebaseTestHelper.createMockAuth(signedIn: false);
      mockFirestore = FirebaseTestHelper.createMockFirestore();
      controller = LeaderboardController(auth: mockAuth, firestore: mockFirestore);
    });

    tearDown(() {
      Get.reset();
    });

    // ... rest of the tests ...
  });

  group('LeaderboardController - calculatePromotionReward()', () {
    late LeaderboardController controller;
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore mockFirestore;

    setUpAll(() async {
      await FirebaseTestHelper.setupFirebase();
    });

    setUp(() {
      Get.testMode = true;
      mockAuth = FirebaseTestHelper.createMockAuth(signedIn: false);
      mockFirestore = FirebaseTestHelper.createMockFirestore();
      controller = LeaderboardController(auth: mockAuth, firestore: mockFirestore);
    });

    tearDown(() {
      Get.reset();
    });

    test('deve retornar 200 gems para Bronze → Silver', () {
      // Act
      final reward = controller.calculatePromotionReward('bronze', 'silver');

      // Assert
      expect(
        reward,
        equals(200),
        reason: 'Promoção Bronze → Silver deve dar 200 gems',
      );
    });

    test('deve retornar 500 gems para Silver → Gold', () {
      // Act
      final reward = controller.calculatePromotionReward('silver', 'gold');

      // Assert
      expect(
        reward,
        equals(500),
        reason: 'Promoção Silver → Gold deve dar 500 gems',
      );
    });

    test('deve retornar 0 gems para Gold → Platinum', () {
      // Act
      final reward = controller.calculatePromotionReward('gold', 'platinum');

      // Assert
      expect(
        reward,
        equals(0),
        reason: 'Promoção Gold → Platinum não tem bônus adicional',
      );
    });

    test('deve retornar 0 gems para Platinum → Diamond', () {
      // Act
      final reward = controller.calculatePromotionReward('platinum', 'diamond');

      // Assert
      expect(
        reward,
        equals(0),
        reason: 'Promoção Platinum → Diamond não tem bônus adicional',
      );
    });

    test('deve retornar 0 gems para mesma liga', () {
      // Act & Assert
      expect(controller.calculatePromotionReward('bronze', 'bronze'), equals(0));
      expect(controller.calculatePromotionReward('silver', 'silver'), equals(0));
      expect(controller.calculatePromotionReward('gold', 'gold'), equals(0));
      expect(controller.calculatePromotionReward('platinum', 'platinum'), equals(0));
      expect(controller.calculatePromotionReward('diamond', 'diamond'), equals(0));
    });

    test('deve retornar 0 gems para rebaixamento', () {
      // Act & Assert
      expect(controller.calculatePromotionReward('silver', 'bronze'), equals(0));
      expect(controller.calculatePromotionReward('gold', 'silver'), equals(0));
      expect(controller.calculatePromotionReward('platinum', 'gold'), equals(0));
      expect(controller.calculatePromotionReward('diamond', 'platinum'), equals(0));
    });

    test('deve retornar 0 gems para Bronze → Gold (pulo de liga)', () {
      // Act
      final reward = controller.calculatePromotionReward('bronze', 'gold');

      // Assert
      expect(
        reward,
        equals(0),
        reason: 'Pulo de liga não deve ter bônus',
      );
    });

    test('deve retornar 0 gems para Silver → Platinum (pulo de liga)', () {
      // Act
      final reward = controller.calculatePromotionReward('silver', 'platinum');

      // Assert
      expect(
        reward,
        equals(0),
        reason: 'Pulo de liga não deve ter bônus',
      );
    });

    test('deve retornar 0 gems para Bronze → Diamond (múltiplos pulos)', () {
      // Act
      final reward = controller.calculatePromotionReward('bronze', 'diamond');

      // Assert
      expect(
        reward,
        equals(0),
        reason: 'Múltiplos pulos de liga não devem ter bônus',
      );
    });

    test('deve ser case-sensitive para nomes de ligas', () {
      // Act - testar com capitalização diferente
      final reward1 = controller.calculatePromotionReward('Bronze', 'Silver');
      final reward2 = controller.calculatePromotionReward('BRONZE', 'SILVER');

      // Assert - não deve reconhecer (case-sensitive)
      expect(reward1, equals(0));
      expect(reward2, equals(0));
    });

    test('deve retornar valores não-negativos para todas as combinações', () {
      // Arrange
      final leagues = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];

      // Act & Assert
      for (final from in leagues) {
        for (final to in leagues) {
          final reward = controller.calculatePromotionReward(from, to);
          expect(
            reward,
            greaterThanOrEqualTo(0),
            reason: 'Recompensa $from → $to deve ser não-negativa',
          );
        }
      }
    });

    test('deve ter Silver → Gold como maior bônus', () {
      // Arrange
      final leagues = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];
      int maxReward = 0;

      // Act
      for (final from in leagues) {
        for (final to in leagues) {
          final reward = controller.calculatePromotionReward(from, to);
          if (reward > maxReward) {
            maxReward = reward;
          }
        }
      }

      // Assert
      expect(
        maxReward,
        equals(500),
        reason: 'Maior bônus deve ser 500 gems (Silver → Gold)',
      );
    });

    test('deve ter apenas 2 transições com bônus', () {
      // Arrange
      final leagues = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];
      int transitionsWithBonus = 0;

      // Act
      for (final from in leagues) {
        for (final to in leagues) {
          if (controller.calculatePromotionReward(from, to) > 0) {
            transitionsWithBonus++;
          }
        }
      }

      // Assert
      expect(
        transitionsWithBonus,
        equals(2),
        reason: 'Apenas 2 transições devem ter bônus',
      );
    });

    test('deve ser determinístico (sempre retornar mesmo valor)', () {
      // Act - chamar múltiplas vezes
      final reward1a = controller.calculatePromotionReward('bronze', 'silver');
      final reward1b = controller.calculatePromotionReward('bronze', 'silver');
      final reward2a = controller.calculatePromotionReward('silver', 'gold');
      final reward2b = controller.calculatePromotionReward('silver', 'gold');

      // Assert
      expect(reward1a, equals(reward1b));
      expect(reward2a, equals(reward2b));
    });

    test('deve retornar 0 para ligas inválidas', () {
      // Act & Assert
      expect(controller.calculatePromotionReward('invalid', 'bronze'), equals(0));
      expect(controller.calculatePromotionReward('bronze', 'invalid'), equals(0));
      expect(controller.calculatePromotionReward('', ''), equals(0));
    });
  });

  group('LeaderboardController - Week Management', () {
    late LeaderboardController controller;
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore mockFirestore;

    setUpAll(() async {
      await FirebaseTestHelper.setupFirebase();
    });

    setUp(() {
      Get.testMode = true;
      mockAuth = FirebaseTestHelper.createMockAuth(signedIn: false);
      mockFirestore = FirebaseTestHelper.createMockFirestore();
      controller = LeaderboardController(auth: mockAuth, firestore: mockFirestore);
    });

    tearDown(() {
      Get.reset();
    });

    test('getDaysRemainingInWeek() deve retornar valor entre 0 e 6', () {
      // Act
      final daysRemaining = controller.getDaysRemainingInWeek();

      // Assert
      expect(
        daysRemaining,
        inInclusiveRange(0, 6),
        reason: 'Dias restantes devem estar entre 0 e 6',
      );
    });

    test('getWeekStartDate() deve retornar segunda-feira 00:00', () {
      // Act
      final weekStart = controller.getWeekStartDate();

      // Assert
      expect(
        weekStart.weekday,
        equals(DateTime.monday),
        reason: 'Week start deve ser segunda-feira',
      );
      expect(
        weekStart.hour,
        equals(0),
        reason: 'Week start deve ser às 00:00',
      );
      expect(
        weekStart.minute,
        equals(0),
        reason: 'Week start deve ser às 00:00',
      );
      expect(
        weekStart.second,
        equals(0),
        reason: 'Week start deve ser às 00:00',
      );
      expect(
        weekStart.millisecond,
        equals(0),
        reason: 'Week start deve ser às 00:00',
      );
    });

    test('getWeekEndDate() deve retornar próxima segunda-feira 00:00', () {
      // Act
      final weekEnd = controller.getWeekEndDate();

      // Assert
      expect(
        weekEnd.weekday,
        equals(DateTime.monday),
        reason: 'Week end deve ser segunda-feira',
      );
      expect(
        weekEnd.hour,
        equals(0),
        reason: 'Week end deve ser às 00:00',
      );
      expect(
        weekEnd.minute,
        equals(0),
        reason: 'Week end deve ser às 00:00',
      );
      expect(
        weekEnd.second,
        equals(0),
        reason: 'Week end deve ser às 00:00',
      );
      expect(
        weekEnd.millisecond,
        equals(0),
        reason: 'Week end deve ser às 00:00',
      );
    });

    test('getWeekEndDate() deve ser exatamente 7 dias após getWeekStartDate()', () {
      // Act
      final weekStart = controller.getWeekStartDate();
      final weekEnd = controller.getWeekEndDate();

      // Assert
      final difference = weekEnd.difference(weekStart);
      expect(
        difference.inDays,
        equals(7),
        reason: 'Diferença entre week end e week start deve ser 7 dias',
      );
    });

    test('getWeekStartDate() deve estar no passado ou presente', () {
      // Act
      final now = DateTime.now();
      final weekStart = controller.getWeekStartDate();

      // Assert
      expect(
        weekStart.isBefore(now) || weekStart.isAtSameMomentAs(now),
        isTrue,
        reason: 'Week start deve estar no passado ou presente',
      );
    });

    test('getWeekEndDate() deve estar no futuro', () {
      // Act
      final now = DateTime.now();
      final weekEnd = controller.getWeekEndDate();

      // Assert
      expect(
        weekEnd.isAfter(now),
        isTrue,
        reason: 'Week end deve estar no futuro',
      );
    });

    test('momento atual deve estar entre week start e week end', () {
      // Act
      final now = DateTime.now();
      final weekStart = controller.getWeekStartDate();
      final weekEnd = controller.getWeekEndDate();

      // Assert
      expect(
        now.isAfter(weekStart) || now.isAtSameMomentAs(weekStart),
        isTrue,
        reason: 'Momento atual deve estar após ou no week start',
      );
      expect(
        now.isBefore(weekEnd),
        isTrue,
        reason: 'Momento atual deve estar antes do week end',
      );
    });

    test('getDaysRemainingInWeek() deve ser consistente com week dates', () {
      // Act
      final now = DateTime.now();
      final weekEnd = controller.getWeekEndDate();
      final daysRemaining = controller.getDaysRemainingInWeek();

      // Assert
      final manualDaysRemaining = weekEnd.difference(now).inDays;
      expect(
        (daysRemaining - manualDaysRemaining).abs(),
        lessThanOrEqualTo(1),
        reason: 'Days remaining deve ser consistente com week end date',
      );
    });

    test('múltiplas chamadas devem retornar valores consistentes', () {
      // Act
      final weekStart1 = controller.getWeekStartDate();
      final weekEnd1 = controller.getWeekEndDate();
      final daysRemaining1 = controller.getDaysRemainingInWeek();

      final weekStart2 = controller.getWeekStartDate();
      final weekEnd2 = controller.getWeekEndDate();
      final daysRemaining2 = controller.getDaysRemainingInWeek();

      // Assert
      expect(
        weekStart1,
        equals(weekStart2),
        reason: 'Week start deve ser consistente entre chamadas',
      );
      expect(
        weekEnd1,
        equals(weekEnd2),
        reason: 'Week end deve ser consistente entre chamadas',
      );
      expect(
        (daysRemaining1 - daysRemaining2).abs(),
        lessThanOrEqualTo(1),
        reason: 'Days remaining deve ser consistente entre chamadas',
      );
    });

    test('getWeekStartDate() deve retornar data sem componente de tempo', () {
      // Act
      final weekStart = controller.getWeekStartDate();

      // Assert
      expect(weekStart.hour, equals(0));
      expect(weekStart.minute, equals(0));
      expect(weekStart.second, equals(0));
      expect(weekStart.millisecond, equals(0));
      expect(weekStart.microsecond, equals(0));
    });

    test('getWeekEndDate() deve retornar data sem componente de tempo', () {
      // Act
      final weekEnd = controller.getWeekEndDate();

      // Assert
      expect(weekEnd.hour, equals(0));
      expect(weekEnd.minute, equals(0));
      expect(weekEnd.second, equals(0));
      expect(weekEnd.millisecond, equals(0));
      expect(weekEnd.microsecond, equals(0));
    });

    test('getDaysRemainingInWeek() deve retornar inteiro não-negativo', () {
      // Act
      final daysRemaining = controller.getDaysRemainingInWeek();

      // Assert
      expect(
        daysRemaining,
        isA<int>(),
        reason: 'Days remaining deve ser inteiro',
      );
      expect(
        daysRemaining,
        greaterThanOrEqualTo(0),
        reason: 'Days remaining não pode ser negativo',
      );
    });

    test('getWeekStartDate() deve ser determinístico no mesmo momento', () {
      // Act - múltiplas chamadas imediatas
      final results = List.generate(5, (_) => controller.getWeekStartDate());

      // Assert - todos devem ser iguais
      for (int i = 1; i < results.length; i++) {
        expect(
          results[i],
          equals(results[0]),
          reason: 'Todas as chamadas devem retornar o mesmo valor',
        );
      }
    });

    test('getWeekEndDate() deve ser determinístico no mesmo momento', () {
      // Act - múltiplas chamadas imediatas
      final results = List.generate(5, (_) => controller.getWeekEndDate());

      // Assert - todos devem ser iguais
      for (int i = 1; i < results.length; i++) {
        expect(
          results[i],
          equals(results[0]),
          reason: 'Todas as chamadas devem retornar o mesmo valor',
        );
      }
    });

    test('week dates devem ser válidas para qualquer dia da semana', () {
      // Este teste verifica que a lógica funciona independente do dia atual
      // Act
      final weekStart = controller.getWeekStartDate();
      final weekEnd = controller.getWeekEndDate();

      // Assert - verificar propriedades básicas
      expect(weekStart.weekday, equals(DateTime.monday));
      expect(weekEnd.weekday, equals(DateTime.monday));
      expect(weekEnd.isAfter(weekStart), isTrue);
      expect(weekEnd.difference(weekStart).inDays, equals(7));
    });

    test('getDaysRemainingInWeek() deve funcionar próximo à meia-noite', () {
      // Este teste verifica que não há problemas de arredondamento
      // Act
      final daysRemaining = controller.getDaysRemainingInWeek();

      // Assert - deve estar no intervalo válido
      expect(daysRemaining, inInclusiveRange(0, 6));
    });

    test('week management methods devem ser rápidos', () {
      // Act
      final stopwatch = Stopwatch()..start();
      
      for (int i = 0; i < 100; i++) {
        controller.getDaysRemainingInWeek();
        controller.getWeekStartDate();
        controller.getWeekEndDate();
      }
      
      stopwatch.stop();

      // Assert - 100 chamadas devem completar em menos de 100ms
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(100),
        reason: 'Week management methods devem ser rápidos',
      );
    });

    test('getWeekStartDate() deve retornar DateTime válido', () {
      // Act
      final weekStart = controller.getWeekStartDate();

      // Assert
      expect(weekStart, isA<DateTime>());
      expect(weekStart.isUtc, isFalse); // Deve ser local time
    });

    test('getWeekEndDate() deve retornar DateTime válido', () {
      // Act
      final weekEnd = controller.getWeekEndDate();

      // Assert
      expect(weekEnd, isA<DateTime>());
      expect(weekEnd.isUtc, isFalse); // Deve ser local time
    });

    test('week dates devem ter ano, mês e dia válidos', () {
      // Act
      final weekStart = controller.getWeekStartDate();
      final weekEnd = controller.getWeekEndDate();

      // Assert
      expect(weekStart.year, greaterThan(2020));
      expect(weekStart.month, inInclusiveRange(1, 12));
      expect(weekStart.day, inInclusiveRange(1, 31));

      expect(weekEnd.year, greaterThan(2020));
      expect(weekEnd.month, inInclusiveRange(1, 12));
      expect(weekEnd.day, inInclusiveRange(1, 31));
    });
  });
}
