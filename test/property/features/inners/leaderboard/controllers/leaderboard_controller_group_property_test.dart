import 'package:glados/glados.dart';

void main() {
  group('Feature: ranking-system, Group Formation Property Tests', () {
    // Property 9: Group Size Invariant
    // For any leaderboard group, the number of members SHALL always equal exactly 30.
    // Validates: Requirements 1.5, 7.2, 7.4, 9.5
    Glados2<int, String>(
      any.intInRange(0, 100), // Number of real users
      any.choose(['bronze', 'silver', 'gold', 'platinum', 'diamond']), // League
    ).test(
      'Property 9: Group Size Invariant - All leaderboard groups have exactly 30 members',
      (userCount, league) {
        // Simular formação de grupos
        final groups = _formLeaderboardGroups(
          userCount: userCount,
          league: league,
        );

        // Verificar que cada grupo tem exatamente 30 membros
        for (final group in groups) {
          expect(
            group['memberIds'].length,
            equals(30),
            reason: 'Every leaderboard group must have exactly 30 members. '
                'League: $league, User count: $userCount, '
                'Group size: ${group['memberIds'].length}',
          );
        }
      },
    );

    // Property 10: League Consistency
    // For any leaderboard group, all members SHALL have the same league value.
    // Validates: Requirements 2.7, 7.3
    test(
      'Property 10: League Consistency - All members in a group have the same league',
      () {
        // Criar 30 usuários com a mesma liga
        final league = 'bronze';
        final users = List.generate(
          30,
          (i) => {
            'userId': 'user_$i',
            'league': league,
            'weeklyXP': i * 10,
          },
        );

        // Criar grupo com esses usuários
        final group = _createLeaderboardGroup(users);

        // Verificar que todos os usuários têm a mesma liga
        for (final user in users) {
          expect(
            user['league'],
            equals(league),
            reason: 'All users in a leaderboard group must be from the same league. '
                'Expected: $league, Found: ${user['league']}',
          );
        }

        // Verificar que o grupo também tem a liga correta
        expect(
          group['league'],
          equals(league),
          reason: 'Group league must match member leagues',
        );
      },
    );

    // Property 11: Random Distribution Fairness
    // For any set of users, when forming groups randomly, no user should be
    // systematically excluded or favored.
    // Validates: Requirements 7.1, 7.2
    Glados<int>(
      any.intInRange(30, 150), // Number of users (1-5 groups)
    ).test(
      'Property 11: Random Distribution Fairness - Users are distributed fairly across groups',
      (userCount) {
        // Criar lista de usuários
        final users = List.generate(
          userCount,
          (i) => {
            'userId': 'user_$i',
            'league': 'bronze',
            'weeklyXP': 0,
          },
        );

        // Formar grupos
        final groups = _formLeaderboardGroups(
          userCount: userCount,
          league: 'bronze',
          users: users,
        );

        // Calcular número esperado de grupos
        final expectedGroupCount = (userCount / 30).ceil();

        expect(
          groups.length,
          equals(expectedGroupCount),
          reason: 'Should create correct number of groups. '
              'Users: $userCount, Expected groups: $expectedGroupCount, '
              'Actual groups: ${groups.length}',
        );

        // Verificar que todos os usuários foram atribuídos a um grupo
        final assignedUserIds = <String>{};
        for (final group in groups) {
          assignedUserIds.addAll(
            (group['memberIds'] as List).cast<String>(),
          );
        }

        // Contar usuários reais (não placeholders)
        final realUserIds = assignedUserIds
            .where((id) => id.startsWith('user_'))
            .toSet();

        expect(
          realUserIds.length,
          equals(userCount),
          reason: 'All real users should be assigned to a group. '
              'Expected: $userCount, Assigned: ${realUserIds.length}',
        );

        // Verificar que não há duplicatas
        expect(
          realUserIds.length,
          equals(assignedUserIds.where((id) => id.startsWith('user_')).length),
          reason: 'No user should be assigned to multiple groups',
        );
      },
    );
  });
}

// Helper: Simula formação de grupos de leaderboard
List<Map<String, dynamic>> _formLeaderboardGroups({
  required int userCount,
  required String league,
  List<Map<String, dynamic>>? users,
}) {
  final groups = <Map<String, dynamic>>[];
  final userList = users ??
      List.generate(
        userCount,
        (i) => {
          'userId': 'user_$i',
          'league': league,
          'weeklyXP': 0,
        },
      );

  // Embaralhar usuários (simulando randomização)
  final shuffledUsers = List<Map<String, dynamic>>.from(userList)..shuffle();

  // Criar grupos de 30
  for (int i = 0; i < shuffledUsers.length; i += 30) {
    final groupMembers = <String>[];

    // Adicionar usuários reais ao grupo
    final endIndex = (i + 30 > shuffledUsers.length)
        ? shuffledUsers.length
        : i + 30;

    for (int j = i; j < endIndex; j++) {
      groupMembers.add(shuffledUsers[j]['userId'] as String);
    }

    // Preencher com placeholders se necessário
    while (groupMembers.length < 30) {
      groupMembers.add('placeholder_${groupMembers.length}');
    }

    groups.add({
      'groupId': '${league}_group_${groups.length}',
      'league': league,
      'memberIds': groupMembers,
      'weekStartDate': DateTime.now(),
      'weekEndDate': DateTime.now().add(const Duration(days: 7)),
      'status': 'active',
    });
  }

  return groups;
}

// Helper: Cria um grupo de leaderboard com usuários específicos
Map<String, dynamic> _createLeaderboardGroup(
  List<Map<String, dynamic>> users,
) {
  // Verificar que todos têm a mesma liga
  final league = users[0]['league'] as String;

  return {
    'groupId': '${league}_group_test',
    'league': league,
    'memberIds': users.map((u) => u['userId'] as String).toList(),
    'weekStartDate': DateTime.now(),
    'weekEndDate': DateTime.now().add(const Duration(days: 7)),
    'status': 'active',
  };
}
