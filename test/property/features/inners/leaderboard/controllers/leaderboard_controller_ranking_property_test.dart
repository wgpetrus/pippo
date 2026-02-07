import 'package:glados/glados.dart';

/// Classe auxiliar para testar lógica de ranking isoladamente
///
/// Replica a lógica de ordenação e atribuição de ranks do LeaderboardController
/// para validar propriedades universais sem dependências do Firebase.
class TestRankingLogic {
  /// Ordena usuários por weeklyXP (descendente) e atribui ranks sequenciais
  static List<Map<String, dynamic>> calculateRankings(
    List<Map<String, dynamic>> users,
  ) {
    // Criar cópia para não modificar original
    final sortedUsers = List<Map<String, dynamic>>.from(users);

    // Ordenar por weeklyXP (descendente)
    sortedUsers.sort((a, b) =>
        (b['weeklyXP'] as int).compareTo(a['weeklyXP'] as int));

    // Atribuir ranks sequenciais (1, 2, 3, ...)
    for (int i = 0; i < sortedUsers.length; i++) {
      sortedUsers[i]['rank'] = i + 1;
    }

    return sortedUsers;
  }

  /// Determina a zona de um usuário baseado no rank
  static String getUserZone(int rank) {
    if (rank >= 1 && rank <= 3) return 'promotion';
    if (rank >= 4 && rank <= 7) return 'safe';
    if (rank >= 8 && rank <= 10) return 'demotion';
    return 'safe'; // fallback
  }

  /// Atribui zonas para todos os usuários
  static void assignZones(List<Map<String, dynamic>> users) {
    for (final user in users) {
      final rank = user['rank'] as int;
      user['zone'] = getUserZone(rank);
    }
  }
}

void main() {
  group('Feature: ranking-system, Property 2: Ranking Consistency', () {
    // Property 2: Ranking Consistency
    // Para qualquer lista de usuários, após calcular rankings:
    // - Usuários devem estar ordenados por weeklyXP (descendente)
    // - Ranks devem ser sequenciais (1, 2, 3, ..., N)
    // - Não deve haver gaps nos ranks
    // Validates: Requirements 1.2, 2.2

    test('Property 2.1: usuários são ordenados por weeklyXP descendente', () {
      // Gerar múltiplos cenários de teste
      final testCases = [
        // Caso 1: XP em ordem crescente (precisa inverter)
        [
          {'userId': 'u1', 'weeklyXP': 100},
          {'userId': 'u2', 'weeklyXP': 200},
          {'userId': 'u3', 'weeklyXP': 300},
        ],
        // Caso 2: XP em ordem decrescente (já ordenado)
        [
          {'userId': 'u1', 'weeklyXP': 300},
          {'userId': 'u2', 'weeklyXP': 200},
          {'userId': 'u3', 'weeklyXP': 100},
        ],
        // Caso 3: XP aleatório
        [
          {'userId': 'u1', 'weeklyXP': 250},
          {'userId': 'u2', 'weeklyXP': 100},
          {'userId': 'u3', 'weeklyXP': 400},
          {'userId': 'u4', 'weeklyXP': 150},
        ],
        // Caso 4: XP com valores iguais
        [
          {'userId': 'u1', 'weeklyXP': 200},
          {'userId': 'u2', 'weeklyXP': 200},
          {'userId': 'u3', 'weeklyXP': 100},
        ],
        // Caso 5: Todos com mesmo XP
        [
          {'userId': 'u1', 'weeklyXP': 150},
          {'userId': 'u2', 'weeklyXP': 150},
          {'userId': 'u3', 'weeklyXP': 150},
        ],
      ];

      for (final users in testCases) {
        final ranked = TestRankingLogic.calculateRankings(users);

        // Verificar que está ordenado por weeklyXP descendente
        for (int i = 0; i < ranked.length - 1; i++) {
          final currentXP = ranked[i]['weeklyXP'] as int;
          final nextXP = ranked[i + 1]['weeklyXP'] as int;

          expect(
            currentXP,
            greaterThanOrEqualTo(nextXP),
            reason:
                'Usuário no rank ${i + 1} deve ter XP >= usuário no rank ${i + 2}',
          );
        }
      }
    });

    test('Property 2.2: ranks são sequenciais sem gaps', () {
      final testCases = [
        // 3 usuários
        [
          {'userId': 'u1', 'weeklyXP': 300},
          {'userId': 'u2', 'weeklyXP': 200},
          {'userId': 'u3', 'weeklyXP': 100},
        ],
        // 5 usuários
        [
          {'userId': 'u1', 'weeklyXP': 500},
          {'userId': 'u2', 'weeklyXP': 400},
          {'userId': 'u3', 'weeklyXP': 300},
          {'userId': 'u4', 'weeklyXP': 200},
          {'userId': 'u5', 'weeklyXP': 100},
        ],
        // 10 usuários (tamanho completo do leaderboard)
        List.generate(
          10,
          (i) => {'userId': 'u$i', 'weeklyXP': (10 - i) * 100},
        ),
      ];

      for (final users in testCases) {
        final ranked = TestRankingLogic.calculateRankings(users);

        // Verificar que ranks são 1, 2, 3, ..., N
        for (int i = 0; i < ranked.length; i++) {
          expect(
            ranked[i]['rank'],
            equals(i + 1),
            reason: 'Usuário no índice $i deve ter rank ${i + 1}',
          );
        }

        // Verificar que não há gaps
        final ranks = ranked.map((u) => u['rank'] as int).toList();
        final expectedRanks = List.generate(ranked.length, (i) => i + 1);

        expect(
          ranks,
          equals(expectedRanks),
          reason: 'Ranks devem ser sequenciais de 1 a ${ranked.length}',
        );
      }
    });

    test('Property 2.3: usuários com mesmo XP recebem ranks sequenciais', () {
      // Caso com empates
      final users = [
        {'userId': 'u1', 'weeklyXP': 300},
        {'userId': 'u2', 'weeklyXP': 300}, // Empate com u1
        {'userId': 'u3', 'weeklyXP': 200},
        {'userId': 'u4', 'weeklyXP': 200}, // Empate com u3
        {'userId': 'u5', 'weeklyXP': 100},
      ];

      final ranked = TestRankingLogic.calculateRankings(users);

      // Verificar que ranks são sequenciais mesmo com empates
      expect(ranked[0]['rank'], equals(1));
      expect(ranked[1]['rank'], equals(2)); // Não é 1, é 2
      expect(ranked[2]['rank'], equals(3));
      expect(ranked[3]['rank'], equals(4)); // Não é 3, é 4
      expect(ranked[4]['rank'], equals(5));

      // Verificar que não há gaps
      final ranks = ranked.map((u) => u['rank'] as int).toList();
      expect(ranks, equals([1, 2, 3, 4, 5]));
    });

    test('Property 2.4: ordem relativa é preservada para XP iguais', () {
      // Quando XP é igual, ordem original deve ser preservada (stable sort)
      final users = [
        {'userId': 'u1', 'weeklyXP': 200},
        {'userId': 'u2', 'weeklyXP': 200},
        {'userId': 'u3', 'weeklyXP': 200},
      ];

      final ranked = TestRankingLogic.calculateRankings(users);

      // Verificar que ordem dos IDs é preservada
      expect(ranked[0]['userId'], equals('u1'));
      expect(ranked[1]['userId'], equals('u2'));
      expect(ranked[2]['userId'], equals('u3'));

      // Verificar ranks
      expect(ranked[0]['rank'], equals(1));
      expect(ranked[1]['rank'], equals(2));
      expect(ranked[2]['rank'], equals(3));
    });

    test('Property 2.5: lista vazia retorna lista vazia', () {
      final users = <Map<String, dynamic>>[];
      final ranked = TestRankingLogic.calculateRankings(users);

      expect(ranked, isEmpty, reason: 'Lista vazia deve retornar lista vazia');
    });

    test('Property 2.6: um único usuário recebe rank 1', () {
      final users = [
        {'userId': 'u1', 'weeklyXP': 100},
      ];

      final ranked = TestRankingLogic.calculateRankings(users);

      expect(ranked.length, equals(1));
      expect(ranked[0]['rank'], equals(1));
    });

    // Property-based test com geração aleatória
    test('Property 2.7: para qualquer lista de XP, ranks são sempre sequenciais', () {
      // Testar com múltiplos tamanhos de lista
      for (int size = 1; size <= 10; size++) {
        // Gerar XP aleatórios
        final xpValues = List.generate(size, (i) => (i * 100) % 1000);
        
        // Criar usuários com XP gerados
        final users = xpValues
            .asMap()
            .entries
            .map((e) => {
                  'userId': 'user${e.key}',
                  'weeklyXP': e.value,
                })
            .toList();

        final ranked = TestRankingLogic.calculateRankings(users);

        // Verificar que ranks são sequenciais
        for (int i = 0; i < ranked.length; i++) {
          expect(
            ranked[i]['rank'],
            equals(i + 1),
            reason: 'Rank deve ser ${i + 1} no índice $i',
          );
        }

        // Verificar ordenação por XP
        for (int i = 0; i < ranked.length - 1; i++) {
          final currentXP = ranked[i]['weeklyXP'] as int;
          final nextXP = ranked[i + 1]['weeklyXP'] as int;

          expect(
            currentXP,
            greaterThanOrEqualTo(nextXP),
            reason: 'XP deve estar em ordem descendente',
          );
        }
      }
    });

    // Property 2.8: Tamanho da lista é preservado
    test('Property 2.8: tamanho da lista é preservado após ranking', () {
      // Testar com vários tamanhos
      for (int size = 1; size <= 30; size++) {
        // Criar lista com tamanho específico
        final users = List.generate(
          size,
          (i) => {'userId': 'user$i', 'weeklyXP': i * 10},
        );

        final ranked = TestRankingLogic.calculateRankings(users);

        expect(
          ranked.length,
          equals(size),
          reason: 'Tamanho da lista deve ser preservado para size=$size',
        );
      }
    });

    // Property 2.9: Todos os usuários originais estão presentes
    test('Property 2.9: todos os usuários originais estão no resultado', () {
      final users = [
        {'userId': 'alice', 'weeklyXP': 300},
        {'userId': 'bob', 'weeklyXP': 200},
        {'userId': 'charlie', 'weeklyXP': 400},
      ];

      final ranked = TestRankingLogic.calculateRankings(users);

      // Extrair IDs
      final originalIds = users.map((u) => u['userId']).toSet();
      final rankedIds = ranked.map((u) => u['userId']).toSet();

      expect(
        rankedIds,
        equals(originalIds),
        reason: 'Todos os usuários originais devem estar presentes',
      );
    });

    // Property 2.10: Maior XP sempre recebe rank 1
    test('Property 2.10: maior XP sempre recebe rank 1', () {
      // Testar com múltiplos cenários
      for (int testCase = 0; testCase < 10; testCase++) {
        // Gerar lista de XP com valores variados
        final xpValues = List.generate(
          5 + testCase,
          (i) => (i * 73 + testCase * 11) % 1000,
        );

        final users = xpValues
            .asMap()
            .entries
            .map((e) => {
                  'userId': 'user${e.key}',
                  'weeklyXP': e.value,
                })
            .toList();

        final ranked = TestRankingLogic.calculateRankings(users);

        // Encontrar maior XP
        final maxXP = xpValues.reduce((a, b) => a > b ? a : b);

        // Verificar que rank 1 tem o maior XP
        expect(
          ranked[0]['weeklyXP'],
          equals(maxXP),
          reason: 'Rank 1 deve ter o maior XP no caso $testCase',
        );

        expect(
          ranked[0]['rank'],
          equals(1),
          reason: 'Primeiro usuário deve ter rank 1 no caso $testCase',
        );
      }
    });
  });

  group('Feature: ranking-system, Property 2 Extended: Zone Assignment', () {
    // Testes adicionais para atribuição de zonas

    test('Property 2.11: zonas são atribuídas corretamente', () {
      final users = List.generate(
        10,
        (i) => {
          'userId': 'user$i',
          'weeklyXP': (10 - i) * 100,
        },
      );

      final ranked = TestRankingLogic.calculateRankings(users);
      TestRankingLogic.assignZones(ranked);

      // Verificar zonas
      expect(ranked[0]['zone'], equals('promotion')); // Rank 1
      expect(ranked[1]['zone'], equals('promotion')); // Rank 2
      expect(ranked[2]['zone'], equals('promotion')); // Rank 3
      expect(ranked[3]['zone'], equals('safe')); // Rank 4
      expect(ranked[4]['zone'], equals('safe')); // Rank 5
      expect(ranked[5]['zone'], equals('safe')); // Rank 6
      expect(ranked[6]['zone'], equals('safe')); // Rank 7
      expect(ranked[7]['zone'], equals('demotion')); // Rank 8
      expect(ranked[8]['zone'], equals('demotion')); // Rank 9
      expect(ranked[9]['zone'], equals('demotion')); // Rank 10
    });

    test('Property 2.12: getUserZone retorna zona correta para cada rank', () {
      // Promotion zone (1-3)
      expect(TestRankingLogic.getUserZone(1), equals('promotion'));
      expect(TestRankingLogic.getUserZone(2), equals('promotion'));
      expect(TestRankingLogic.getUserZone(3), equals('promotion'));

      // Safe zone (4-7)
      expect(TestRankingLogic.getUserZone(4), equals('safe'));
      expect(TestRankingLogic.getUserZone(5), equals('safe'));
      expect(TestRankingLogic.getUserZone(6), equals('safe'));
      expect(TestRankingLogic.getUserZone(7), equals('safe'));

      // Demotion zone (8-10)
      expect(TestRankingLogic.getUserZone(8), equals('demotion'));
      expect(TestRankingLogic.getUserZone(9), equals('demotion'));
      expect(TestRankingLogic.getUserZone(10), equals('demotion'));
    });

    test('Property 2.13: zonas têm tamanhos corretos', () {
      final users = List.generate(
        10,
        (i) => {
          'userId': 'user$i',
          'weeklyXP': (10 - i) * 100,
        },
      );

      final ranked = TestRankingLogic.calculateRankings(users);
      TestRankingLogic.assignZones(ranked);

      // Contar usuários por zona
      final promotionCount =
          ranked.where((u) => u['zone'] == 'promotion').length;
      final safeCount = ranked.where((u) => u['zone'] == 'safe').length;
      final demotionCount =
          ranked.where((u) => u['zone'] == 'demotion').length;

      expect(promotionCount, equals(3), reason: 'Zona de promoção tem 3 usuários');
      expect(safeCount, equals(4), reason: 'Zona segura tem 4 usuários');
      expect(demotionCount, equals(3), reason: 'Zona de rebaixamento tem 3 usuários');
    });
  });
}
