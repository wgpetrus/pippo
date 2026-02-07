import 'package:glados/glados.dart';

/// Classe auxiliar para testar lógica de recompensas isoladamente
///
/// Replica a lógica de cálculo de recompensas do LeaderboardController
/// para validar propriedades universais sem dependências do Firebase.
class TestRewardLogic {
  /// Calcula a recompensa em gems baseada no rank final
  ///
  /// Retorna:
  /// - 100 gems para rank 1
  /// - 50 gems para rank 2
  /// - 25 gems para rank 3
  /// - 0 gems para outros ranks
  static int getRewardForRank(int rank) {
    if (rank == 1) return 100;
    if (rank == 2) return 50;
    if (rank == 3) return 25;
    return 0;
  }

  /// Calcula a recompensa de promoção baseada na mudança de liga
  ///
  /// Retorna:
  /// - 200 gems para Bronze → Silver
  /// - 500 gems para Silver → Gold
  /// - 0 gems para outras transições
  static int calculatePromotionReward(String fromLeague, String toLeague) {
    // Bronze → Silver
    if (fromLeague == 'bronze' && toLeague == 'silver') {
      return 200;
    }

    // Silver → Gold
    if (fromLeague == 'silver' && toLeague == 'gold') {
      return 500;
    }

    // Outras transições não têm recompensa adicional
    return 0;
  }

  /// Calcula a recompensa total (rank + promoção)
  static int calculateTotalReward({
    required int rank,
    String? fromLeague,
    String? toLeague,
  }) {
    final rankReward = getRewardForRank(rank);
    final promotionReward = (fromLeague != null && toLeague != null)
        ? calculatePromotionReward(fromLeague, toLeague)
        : 0;

    return rankReward + promotionReward;
  }
}

void main() {
  group('Feature: ranking-system, Property 7: Reward Monotonicity', () {
    // Property 7: Reward Monotonicity
    // Para qualquer rank de 1 a 30, as recompensas devem seguir a tabela:
    // - Rank 1: 100 gems
    // - Rank 2: 50 gems
    // - Rank 3: 25 gems
    // - Outros ranks: 0 gems
    // Validates: Requirements 3.1, 3.2, 3.3, 3.4

    test('Property 7.1: rank 1 sempre recebe 100 gems', () {
      final reward = TestRewardLogic.getRewardForRank(1);
      expect(reward, equals(100), reason: 'Rank 1 deve receber 100 gems');
    });

    test('Property 7.2: rank 2 sempre recebe 50 gems', () {
      final reward = TestRewardLogic.getRewardForRank(2);
      expect(reward, equals(50), reason: 'Rank 2 deve receber 50 gems');
    });

    test('Property 7.3: rank 3 sempre recebe 25 gems', () {
      final reward = TestRewardLogic.getRewardForRank(3);
      expect(reward, equals(25), reason: 'Rank 3 deve receber 25 gems');
    });

    test('Property 7.4: ranks 4-30 recebem 0 gems', () {
      for (int rank = 4; rank <= 30; rank++) {
        final reward = TestRewardLogic.getRewardForRank(rank);
        expect(
          reward,
          equals(0),
          reason: 'Rank $rank deve receber 0 gems',
        );
      }
    });

    test('Property 7.5: recompensas são monotonicamente decrescentes para top 3', () {
      final reward1 = TestRewardLogic.getRewardForRank(1);
      final reward2 = TestRewardLogic.getRewardForRank(2);
      final reward3 = TestRewardLogic.getRewardForRank(3);

      expect(
        reward1,
        greaterThan(reward2),
        reason: 'Rank 1 deve ter recompensa maior que rank 2',
      );

      expect(
        reward2,
        greaterThan(reward3),
        reason: 'Rank 2 deve ter recompensa maior que rank 3',
      );

      expect(
        reward3,
        greaterThan(0),
        reason: 'Rank 3 deve ter recompensa maior que 0',
      );
    });

    test('Property 7.6: recompensas são não-negativas para todos os ranks', () {
      for (int rank = 1; rank <= 30; rank++) {
        final reward = TestRewardLogic.getRewardForRank(rank);
        expect(
          reward,
          greaterThanOrEqualTo(0),
          reason: 'Recompensa do rank $rank deve ser não-negativa',
        );
      }
    });

    test('Property 7.7: ranks fora do intervalo 1-30 retornam 0', () {
      // Ranks inválidos (< 1)
      expect(TestRewardLogic.getRewardForRank(0), equals(0));
      expect(TestRewardLogic.getRewardForRank(-1), equals(0));
      expect(TestRewardLogic.getRewardForRank(-10), equals(0));

      // Ranks inválidos (> 30)
      expect(TestRewardLogic.getRewardForRank(31), equals(0));
      expect(TestRewardLogic.getRewardForRank(50), equals(0));
      expect(TestRewardLogic.getRewardForRank(100), equals(0));
    });

    test('Property 7.8: soma total de recompensas para top 3 é 175 gems', () {
      final total = TestRewardLogic.getRewardForRank(1) +
          TestRewardLogic.getRewardForRank(2) +
          TestRewardLogic.getRewardForRank(3);

      expect(
        total,
        equals(175),
        reason: 'Soma das recompensas do top 3 deve ser 175 gems (100+50+25)',
      );
    });

    test('Property 7.9: apenas top 3 recebem recompensas de rank', () {
      // Contar quantos ranks têm recompensa > 0
      int ranksWithReward = 0;
      for (int rank = 1; rank <= 30; rank++) {
        if (TestRewardLogic.getRewardForRank(rank) > 0) {
          ranksWithReward++;
        }
      }

      expect(
        ranksWithReward,
        equals(3),
        reason: 'Apenas 3 ranks devem ter recompensa > 0',
      );
    });

    test('Property 7.10: recompensa é determinística para mesmo rank', () {
      // Chamar múltiplas vezes para mesmo rank
      for (int rank = 1; rank <= 30; rank++) {
        final reward1 = TestRewardLogic.getRewardForRank(rank);
        final reward2 = TestRewardLogic.getRewardForRank(rank);
        final reward3 = TestRewardLogic.getRewardForRank(rank);

        expect(
          reward1,
          equals(reward2),
          reason: 'Recompensa deve ser consistente para rank $rank',
        );

        expect(
          reward2,
          equals(reward3),
          reason: 'Recompensa deve ser consistente para rank $rank',
        );
      }
    });
  });

  group('Feature: ranking-system, Property 7 Extended: Promotion Rewards', () {
    // Testes para recompensas de promoção
    // Validates: Requirements 3.5

    test('Property 7.11: Bronze → Silver recebe 200 gems de bônus', () {
      final reward = TestRewardLogic.calculatePromotionReward('bronze', 'silver');
      expect(
        reward,
        equals(200),
        reason: 'Promoção Bronze → Silver deve dar 200 gems',
      );
    });

    test('Property 7.12: Silver → Gold recebe 500 gems de bônus', () {
      final reward = TestRewardLogic.calculatePromotionReward('silver', 'gold');
      expect(
        reward,
        equals(500),
        reason: 'Promoção Silver → Gold deve dar 500 gems',
      );
    });

    test('Property 7.13: outras transições não recebem bônus', () {
      // Testar todas as outras combinações possíveis
      final leagues = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];

      for (final from in leagues) {
        for (final to in leagues) {
          // Pular as transições que têm bônus
          if ((from == 'bronze' && to == 'silver') ||
              (from == 'silver' && to == 'gold')) {
            continue;
          }

          final reward = TestRewardLogic.calculatePromotionReward(from, to);
          expect(
            reward,
            equals(0),
            reason: 'Transição $from → $to não deve ter bônus',
          );
        }
      }
    });

    test('Property 7.14: mesma liga não recebe bônus', () {
      final leagues = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];

      for (final league in leagues) {
        final reward = TestRewardLogic.calculatePromotionReward(league, league);
        expect(
          reward,
          equals(0),
          reason: 'Permanecer em $league não deve dar bônus',
        );
      }
    });

    test('Property 7.15: rebaixamento não recebe bônus', () {
      // Testar rebaixamentos
      expect(
        TestRewardLogic.calculatePromotionReward('silver', 'bronze'),
        equals(0),
        reason: 'Rebaixamento Silver → Bronze não deve dar bônus',
      );

      expect(
        TestRewardLogic.calculatePromotionReward('gold', 'silver'),
        equals(0),
        reason: 'Rebaixamento Gold → Silver não deve dar bônus',
      );

      expect(
        TestRewardLogic.calculatePromotionReward('platinum', 'gold'),
        equals(0),
        reason: 'Rebaixamento Platinum → Gold não deve dar bônus',
      );

      expect(
        TestRewardLogic.calculatePromotionReward('diamond', 'platinum'),
        equals(0),
        reason: 'Rebaixamento Diamond → Platinum não deve dar bônus',
      );
    });

    test('Property 7.16: bônus de promoção é sempre não-negativo', () {
      final leagues = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];

      for (final from in leagues) {
        for (final to in leagues) {
          final reward = TestRewardLogic.calculatePromotionReward(from, to);
          expect(
            reward,
            greaterThanOrEqualTo(0),
            reason: 'Bônus de promoção $from → $to deve ser não-negativo',
          );
        }
      }
    });

    test('Property 7.17: bônus Silver → Gold é maior que Bronze → Silver', () {
      final bronzeToSilver =
          TestRewardLogic.calculatePromotionReward('bronze', 'silver');
      final silverToGold =
          TestRewardLogic.calculatePromotionReward('silver', 'gold');

      expect(
        silverToGold,
        greaterThan(bronzeToSilver),
        reason: 'Bônus Silver → Gold deve ser maior que Bronze → Silver',
      );
    });
  });

  group('Feature: ranking-system, Property 7 Extended: Total Rewards', () {
    // Testes para recompensa total (rank + promoção)

    test('Property 7.18: recompensa total = rank + promoção', () {
      // Rank 1 com promoção Bronze → Silver
      final total1 = TestRewardLogic.calculateTotalReward(
        rank: 1,
        fromLeague: 'bronze',
        toLeague: 'silver',
      );
      expect(
        total1,
        equals(300),
        reason: 'Rank 1 (100) + Bronze→Silver (200) = 300',
      );

      // Rank 2 com promoção Silver → Gold
      final total2 = TestRewardLogic.calculateTotalReward(
        rank: 2,
        fromLeague: 'silver',
        toLeague: 'gold',
      );
      expect(
        total2,
        equals(550),
        reason: 'Rank 2 (50) + Silver→Gold (500) = 550',
      );

      // Rank 3 sem promoção
      final total3 = TestRewardLogic.calculateTotalReward(
        rank: 3,
        fromLeague: 'gold',
        toLeague: 'gold',
      );
      expect(
        total3,
        equals(25),
        reason: 'Rank 3 (25) + sem promoção (0) = 25',
      );
    });

    test('Property 7.19: recompensa total sem promoção = recompensa de rank', () {
      for (int rank = 1; rank <= 30; rank++) {
        final rankReward = TestRewardLogic.getRewardForRank(rank);
        final totalReward = TestRewardLogic.calculateTotalReward(
          rank: rank,
          fromLeague: 'gold',
          toLeague: 'gold',
        );

        expect(
          totalReward,
          equals(rankReward),
          reason: 'Sem promoção, total deve ser igual à recompensa de rank',
        );
      }
    });

    test('Property 7.20: recompensa total é sempre não-negativa', () {
      final leagues = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];

      for (int rank = 1; rank <= 30; rank++) {
        for (final from in leagues) {
          for (final to in leagues) {
            final total = TestRewardLogic.calculateTotalReward(
              rank: rank,
              fromLeague: from,
              toLeague: to,
            );

            expect(
              total,
              greaterThanOrEqualTo(0),
              reason: 'Recompensa total deve ser não-negativa',
            );
          }
        }
      }
    });

    test('Property 7.21: maior recompensa possível é rank 1 + Silver→Gold', () {
      // Calcular todas as combinações possíveis
      final leagues = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];
      int maxReward = 0;

      for (int rank = 1; rank <= 30; rank++) {
        for (final from in leagues) {
          for (final to in leagues) {
            final total = TestRewardLogic.calculateTotalReward(
              rank: rank,
              fromLeague: from,
              toLeague: to,
            );

            if (total > maxReward) {
              maxReward = total;
            }
          }
        }
      }

      // Maior recompensa = Rank 1 (100) + Silver→Gold (500) = 600
      expect(
        maxReward,
        equals(600),
        reason: 'Maior recompensa possível é 600 gems (rank 1 + Silver→Gold)',
      );
    });

    test('Property 7.22: menor recompensa possível é 0 gems', () {
      // Rank 4+ sem promoção
      final minReward = TestRewardLogic.calculateTotalReward(
        rank: 4,
        fromLeague: 'gold',
        toLeague: 'gold',
      );

      expect(
        minReward,
        equals(0),
        reason: 'Menor recompensa possível é 0 gems',
      );
    });

    test('Property 7.23: recompensa total com promoção > sem promoção', () {
      // Para ranks que recebem recompensa de rank
      for (int rank = 1; rank <= 3; rank++) {
        final withoutPromotion = TestRewardLogic.calculateTotalReward(
          rank: rank,
          fromLeague: 'gold',
          toLeague: 'gold',
        );

        final withPromotion = TestRewardLogic.calculateTotalReward(
          rank: rank,
          fromLeague: 'bronze',
          toLeague: 'silver',
        );

        expect(
          withPromotion,
          greaterThan(withoutPromotion),
          reason: 'Recompensa com promoção deve ser maior para rank $rank',
        );
      }
    });
  });

  group('Feature: ranking-system, Property 15: Reward Distribution Correctness', () {
    // Property 15: Reward Distribution Correctness
    // Para qualquer combinação de rank (1-30) e status de promoção,
    // o sistema deve distribuir recompensas corretamente seguindo as regras:
    // - Recompensas de rank: 100 (1º), 50 (2º), 25 (3º), 0 (outros)
    // - Bônus de promoção: 200 (Bronze→Silver), 500 (Silver→Gold)
    // - Recompensa total = recompensa de rank + bônus de promoção
    // Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 6.1, 6.2

    test('Property 15.1: distribuição de recompensas segue tabela de ranks', () {
      // Validar que cada rank recebe a recompensa correta
      final expectedRewards = {
        1: 100,
        2: 50,
        3: 25,
      };

      for (int rank = 1; rank <= 30; rank++) {
        final reward = TestRewardLogic.getRewardForRank(rank);
        final expected = expectedRewards[rank] ?? 0;

        expect(
          reward,
          equals(expected),
          reason: 'Rank $rank deve receber $expected gems',
        );
      }
    });

    test('Property 15.2: distribuição de bônus de promoção é consistente', () {
      // Validar todas as transições de liga
      final promotionRewards = {
        'bronze->silver': 200,
        'silver->gold': 500,
      };

      final leagues = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];

      for (final from in leagues) {
        for (final to in leagues) {
          final key = '$from->$to';
          final expected = promotionRewards[key] ?? 0;
          final actual = TestRewardLogic.calculatePromotionReward(from, to);

          expect(
            actual,
            equals(expected),
            reason: 'Transição $from → $to deve dar $expected gems de bônus',
          );
        }
      }
    });

    test('Property 15.3: recompensa total é soma correta de rank + promoção', () {
      // Testar várias combinações
      final testCases = [
        // (rank, fromLeague, toLeague, expectedTotal)
        (1, 'bronze', 'silver', 300), // 100 + 200
        (2, 'bronze', 'silver', 250), // 50 + 200
        (3, 'bronze', 'silver', 225), // 25 + 200
        (1, 'silver', 'gold', 600), // 100 + 500
        (2, 'silver', 'gold', 550), // 50 + 500
        (3, 'silver', 'gold', 525), // 25 + 500
        (1, 'gold', 'gold', 100), // 100 + 0
        (2, 'gold', 'gold', 50), // 50 + 0
        (3, 'gold', 'gold', 25), // 25 + 0
        (4, 'bronze', 'silver', 200), // 0 + 200
        (10, 'silver', 'gold', 500), // 0 + 500
        (15, 'gold', 'gold', 0), // 0 + 0
      ];

      for (final testCase in testCases) {
        final (rank, from, to, expected) = testCase;
        final actual = TestRewardLogic.calculateTotalReward(
          rank: rank,
          fromLeague: from,
          toLeague: to,
        );

        expect(
          actual,
          equals(expected),
          reason: 'Rank $rank com $from→$to deve dar $expected gems total',
        );
      }
    });

    test('Property 15.4: distribuição é determinística para mesmos inputs', () {
      // Validar que múltiplas chamadas retornam mesmo resultado
      final testCases = [
        (1, 'bronze', 'silver'),
        (2, 'silver', 'gold'),
        (3, 'gold', 'gold'),
        (10, 'bronze', 'bronze'),
      ];

      for (final testCase in testCases) {
        final (rank, from, to) = testCase;

        final result1 = TestRewardLogic.calculateTotalReward(
          rank: rank,
          fromLeague: from,
          toLeague: to,
        );

        final result2 = TestRewardLogic.calculateTotalReward(
          rank: rank,
          fromLeague: from,
          toLeague: to,
        );

        final result3 = TestRewardLogic.calculateTotalReward(
          rank: rank,
          fromLeague: from,
          toLeague: to,
        );

        expect(
          result1,
          equals(result2),
          reason: 'Distribuição deve ser determinística',
        );

        expect(
          result2,
          equals(result3),
          reason: 'Distribuição deve ser determinística',
        );
      }
    });

    test('Property 15.5: apenas top 3 recebem recompensa de rank', () {
      // Validar que apenas ranks 1-3 têm recompensa > 0
      int ranksWithReward = 0;
      int totalRankReward = 0;

      for (int rank = 1; rank <= 30; rank++) {
        final reward = TestRewardLogic.getRewardForRank(rank);
        if (reward > 0) {
          ranksWithReward++;
          totalRankReward += reward;
        }
      }

      expect(
        ranksWithReward,
        equals(3),
        reason: 'Apenas 3 ranks devem receber recompensa de rank',
      );

      expect(
        totalRankReward,
        equals(175),
        reason: 'Total de recompensas de rank deve ser 175 gems',
      );
    });

    test('Property 15.6: apenas 2 transições recebem bônus de promoção', () {
      // Validar que apenas Bronze→Silver e Silver→Gold têm bônus
      final leagues = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];
      int transitionsWithBonus = 0;
      int totalPromotionBonus = 0;

      for (final from in leagues) {
        for (final to in leagues) {
          final bonus = TestRewardLogic.calculatePromotionReward(from, to);
          if (bonus > 0) {
            transitionsWithBonus++;
            totalPromotionBonus += bonus;
          }
        }
      }

      expect(
        transitionsWithBonus,
        equals(2),
        reason: 'Apenas 2 transições devem ter bônus de promoção',
      );

      expect(
        totalPromotionBonus,
        equals(700),
        reason: 'Total de bônus de promoção deve ser 700 gems (200+500)',
      );
    });

    test('Property 15.7: recompensa máxima é rank 1 com Silver→Gold', () {
      // Encontrar a maior recompensa possível
      final leagues = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];
      int maxReward = 0;
      int maxRank = 0;
      String maxFrom = '';
      String maxTo = '';

      for (int rank = 1; rank <= 30; rank++) {
        for (final from in leagues) {
          for (final to in leagues) {
            final total = TestRewardLogic.calculateTotalReward(
              rank: rank,
              fromLeague: from,
              toLeague: to,
            );

            if (total > maxReward) {
              maxReward = total;
              maxRank = rank;
              maxFrom = from;
              maxTo = to;
            }
          }
        }
      }

      expect(maxReward, equals(600), reason: 'Recompensa máxima deve ser 600 gems');
      expect(maxRank, equals(1), reason: 'Recompensa máxima é com rank 1');
      expect(maxFrom, equals('silver'), reason: 'Recompensa máxima é com Silver→Gold');
      expect(maxTo, equals('gold'), reason: 'Recompensa máxima é com Silver→Gold');
    });

    test('Property 15.8: recompensa mínima é 0 gems', () {
      // Encontrar a menor recompensa possível
      final leagues = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];
      int minReward = 999999;

      for (int rank = 1; rank <= 30; rank++) {
        for (final from in leagues) {
          for (final to in leagues) {
            final total = TestRewardLogic.calculateTotalReward(
              rank: rank,
              fromLeague: from,
              toLeague: to,
            );

            if (total < minReward) {
              minReward = total;
            }
          }
        }
      }

      expect(
        minReward,
        equals(0),
        reason: 'Recompensa mínima deve ser 0 gems',
      );
    });

    test('Property 15.9: todas as recompensas são não-negativas', () {
      // Validar que nenhuma combinação resulta em recompensa negativa
      final leagues = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];

      for (int rank = 1; rank <= 30; rank++) {
        for (final from in leagues) {
          for (final to in leagues) {
            final total = TestRewardLogic.calculateTotalReward(
              rank: rank,
              fromLeague: from,
              toLeague: to,
            );

            expect(
              total,
              greaterThanOrEqualTo(0),
              reason: 'Recompensa deve ser não-negativa para rank $rank, $from→$to',
            );
          }
        }
      }
    });

    test('Property 15.10: distribuição preserva ordem de ranks no top 3', () {
      // Validar que rank 1 sempre recebe mais que rank 2, que recebe mais que rank 3
      final leagues = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];

      for (final from in leagues) {
        for (final to in leagues) {
          final reward1 = TestRewardLogic.calculateTotalReward(
            rank: 1,
            fromLeague: from,
            toLeague: to,
          );

          final reward2 = TestRewardLogic.calculateTotalReward(
            rank: 2,
            fromLeague: from,
            toLeague: to,
          );

          final reward3 = TestRewardLogic.calculateTotalReward(
            rank: 3,
            fromLeague: from,
            toLeague: to,
          );

          expect(
            reward1,
            greaterThanOrEqualTo(reward2),
            reason: 'Rank 1 deve receber >= rank 2 para $from→$to',
          );

          expect(
            reward2,
            greaterThanOrEqualTo(reward3),
            reason: 'Rank 2 deve receber >= rank 3 para $from→$to',
          );
        }
      }
    });

    test('Property 15.11: bônus de promoção não depende do rank', () {
      // Validar que o bônus de promoção é o mesmo independente do rank
      final promotions = [
        ('bronze', 'silver', 200),
        ('silver', 'gold', 500),
      ];

      for (final (from, to, expectedBonus) in promotions) {
        // Testar para vários ranks
        for (int rank = 1; rank <= 30; rank++) {
          final totalReward = TestRewardLogic.calculateTotalReward(
            rank: rank,
            fromLeague: from,
            toLeague: to,
          );

          final rankReward = TestRewardLogic.getRewardForRank(rank);
          final actualBonus = totalReward - rankReward;

          expect(
            actualBonus,
            equals(expectedBonus),
            reason: 'Bônus $from→$to deve ser $expectedBonus para qualquer rank',
          );
        }
      }
    });

    test('Property 15.12: recompensa de rank não depende da liga', () {
      // Validar que a recompensa de rank é a mesma independente da liga
      final leagues = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];

      for (int rank = 1; rank <= 30; rank++) {
        final expectedRankReward = TestRewardLogic.getRewardForRank(rank);

        // Testar para todas as ligas (sem promoção)
        for (final league in leagues) {
          final totalReward = TestRewardLogic.calculateTotalReward(
            rank: rank,
            fromLeague: league,
            toLeague: league,
          );

          expect(
            totalReward,
            equals(expectedRankReward),
            reason: 'Recompensa de rank $rank deve ser $expectedRankReward em qualquer liga',
          );
        }
      }
    });

    test('Property 15.13: soma de todas as recompensas possíveis é finita', () {
      // Calcular soma total de todas as recompensas possíveis
      final leagues = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];
      int totalRewards = 0;

      for (int rank = 1; rank <= 30; rank++) {
        for (final from in leagues) {
          for (final to in leagues) {
            final reward = TestRewardLogic.calculateTotalReward(
              rank: rank,
              fromLeague: from,
              toLeague: to,
            );
            totalRewards += reward;
          }
        }
      }

      // Verificar que a soma é finita e positiva
      expect(
        totalRewards,
        greaterThan(0),
        reason: 'Soma total de recompensas deve ser positiva',
      );

      expect(
        totalRewards,
        lessThan(1000000),
        reason: 'Soma total de recompensas deve ser finita',
      );

      // Valor esperado: 30 ranks * 25 transições = 750 combinações
      // Recompensas de rank: 100 + 50 + 25 = 175 por transição = 175 * 25 = 4375
      // Bônus de promoção: (200 * 30) + (500 * 30) = 6000 + 15000 = 21000
      // Total esperado: 4375 + 21000 = 25375
      expect(
        totalRewards,
        equals(25375),
        reason: 'Soma total de recompensas deve ser 25375 gems',
      );
    });

    test('Property 15.14: distribuição é justa entre ligas equivalentes', () {
      // Validar que ligas do mesmo nível (sem promoção) recebem mesmas recompensas
      final leagues = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];

      for (int rank = 1; rank <= 30; rank++) {
        final rewards = <int>[];

        for (final league in leagues) {
          final reward = TestRewardLogic.calculateTotalReward(
            rank: rank,
            fromLeague: league,
            toLeague: league,
          );
          rewards.add(reward);
        }

        // Todas as recompensas devem ser iguais (sem promoção)
        final firstReward = rewards.first;
        for (final reward in rewards) {
          expect(
            reward,
            equals(firstReward),
            reason: 'Rank $rank deve receber mesma recompensa em todas as ligas',
          );
        }
      }
    });

    test('Property 15.15: promoção sempre aumenta recompensa total', () {
      // Validar que ter promoção sempre resulta em recompensa maior
      final promotions = [
        ('bronze', 'silver'),
        ('silver', 'gold'),
      ];

      for (int rank = 1; rank <= 30; rank++) {
        for (final (from, to) in promotions) {
          final withPromotion = TestRewardLogic.calculateTotalReward(
            rank: rank,
            fromLeague: from,
            toLeague: to,
          );

          final withoutPromotion = TestRewardLogic.calculateTotalReward(
            rank: rank,
            fromLeague: from,
            toLeague: from,
          );

          expect(
            withPromotion,
            greaterThan(withoutPromotion),
            reason: 'Promoção $from→$to deve aumentar recompensa para rank $rank',
          );
        }
      }
    });
  });
}
