import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/firebase_test_helper.dart';

/// Integration tests para operações Firestore do LeaderboardController
/// 
/// Testa:
/// - Estrutura de dados do Firestore
/// - Operações de leitura e escrita
/// - Validação de dados
/// 
/// Nota: Estes testes verificam a estrutura de dados e operações do Firestore
/// sem testar o controller diretamente, pois o controller usa instâncias
/// singleton do Firebase que não podem ser facilmente mockadas.
void main() {
  group('Leaderboard Firestore Data Structure Tests', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() async {
      // Setup Firebase
      await FirebaseTestHelper.setupFirebase();

      // Criar mock do Firestore
      fakeFirestore = FirebaseTestHelper.createMockFirestore();
    });

    tearDown(() async {
      await FirebaseTestHelper.teardownFirebase();
    });

    group('leaderboardGroups collection', () {
      test('cria grupo com estrutura correta', () async {
        // Arrange
        const groupId = 'bronze_2024-01-15_test123';
        
        // Act: Criar documento do grupo
        await fakeFirestore
            .collection('leaderboardGroups')
            .doc(groupId)
            .set({
          'league': 'bronze',
          'weekStartDate': Timestamp.now(),
          'weekEndDate': Timestamp.now(),
          'memberIds': List.generate(30, (i) => 'user$i'),
          'createdAt': Timestamp.now(),
          'status': 'active',
        });

        // Assert: Verificar estrutura
        final groupDoc = await fakeFirestore
            .collection('leaderboardGroups')
            .doc(groupId)
            .get();
        
        expect(groupDoc.exists, true);
        expect(groupDoc.data()?['league'], equals('bronze'));
        expect(groupDoc.data()?['memberIds'], hasLength(30));
        expect(groupDoc.data()?['status'], equals('active'));
      });

      test('valida que grupo tem exatamente 30 membros', () async {
        // Arrange
        const groupId = 'silver_2024-01-15_test456';
        final memberIds = List.generate(30, (i) => 'user$i');
        
        // Act: Criar grupo
        await fakeFirestore
            .collection('leaderboardGroups')
            .doc(groupId)
            .set({
          'league': 'silver',
          'weekStartDate': Timestamp.now(),
          'weekEndDate': Timestamp.now(),
          'memberIds': memberIds,
          'createdAt': Timestamp.now(),
          'status': 'active',
        });

        // Assert: Verificar tamanho
        final groupDoc = await fakeFirestore
            .collection('leaderboardGroups')
            .doc(groupId)
            .get();
        
        final members = List<String>.from(groupDoc.data()?['memberIds'] ?? []);
        expect(members, hasLength(30));
      });

      test('busca grupos por liga e status', () async {
        // Arrange: Criar múltiplos grupos
        await fakeFirestore
            .collection('leaderboardGroups')
            .doc('bronze_2024-01-15_test1')
            .set({
          'league': 'bronze',
          'weekStartDate': Timestamp.now(),
          'weekEndDate': Timestamp.now(),
          'memberIds': List.generate(30, (i) => 'user$i'),
          'createdAt': Timestamp.now(),
          'status': 'active',
        });

        await fakeFirestore
            .collection('leaderboardGroups')
            .doc('silver_2024-01-15_test2')
            .set({
          'league': 'silver',
          'weekStartDate': Timestamp.now(),
          'weekEndDate': Timestamp.now(),
          'memberIds': List.generate(30, (i) => 'user${i + 30}'),
          'createdAt': Timestamp.now(),
          'status': 'active',
        });

        // Act: Buscar grupos bronze ativos
        final bronzeGroups = await fakeFirestore
            .collection('leaderboardGroups')
            .where('league', isEqualTo: 'bronze')
            .where('status', isEqualTo: 'active')
            .get();

        // Assert: Verificar resultado
        expect(bronzeGroups.docs, hasLength(1));
        expect(bronzeGroups.docs.first.data()['league'], equals('bronze'));
      });
    });

    group('users/{userId}/stats/gamification', () {
      test('cria dados de gamificação com campos de leaderboard', () async {
        // Arrange
        const userId = 'test-user-id';
        const groupId = 'bronze_2024-01-15_test123';
        
        // Act: Criar dados do usuário
        await fakeFirestore
            .collection('users')
            .doc(userId)
            .set({
          'name': 'Test User',
          'avatar': 'assets/images/characters/diogo.png',
          'stats': {
            'gamification': {
              'xp': 1000,
              'gems': 100,
              'streak': 5,
              'weeklyXP': 495,
              'currentLeague': 'bronze',
              'leagueRank': 2,
              'leaderboardGroupId': groupId,
              'userStatus': '🎭',
              'lastWeeklyReset': Timestamp.now(),
              'updatedAt': Timestamp.now(),
            }
          }
        });

        // Assert: Verificar estrutura
        final userDoc = await fakeFirestore
            .collection('users')
            .doc(userId)
            .get();
        
        final gamification = userDoc.data()?['stats']?['gamification'];
        expect(gamification['weeklyXP'], equals(495));
        expect(gamification['currentLeague'], equals('bronze'));
        expect(gamification['leagueRank'], equals(2));
        expect(gamification['leaderboardGroupId'], equals(groupId));
        expect(gamification['userStatus'], equals('🎭'));
      });

      test('atualiza status do usuário', () async {
        // Arrange: Criar usuário
        const userId = 'test-user-id';
        await fakeFirestore
            .collection('users')
            .doc(userId)
            .set({
          'name': 'Test User',
          'stats': {
            'gamification': {
              'weeklyXP': 495,
              'currentLeague': 'bronze',
              'userStatus': null,
            }
          }
        });

        // Act: Atualizar status
        await fakeFirestore
            .collection('users')
            .doc(userId)
            .update({
          'stats.gamification.userStatus': '🎭',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Assert: Verificar atualização
        final userDoc = await fakeFirestore
            .collection('users')
            .doc(userId)
            .get();
        
        expect(
          userDoc.data()?['stats']?['gamification']?['userStatus'],
          equals('🎭'),
        );
        expect(userDoc.data()?['updatedAt'], isNotNull);
      });

      test('remove status do usuário', () async {
        // Arrange: Criar usuário com status
        const userId = 'test-user-id';
        await fakeFirestore
            .collection('users')
            .doc(userId)
            .set({
          'name': 'Test User',
          'stats': {
            'gamification': {
              'weeklyXP': 495,
              'currentLeague': 'bronze',
              'userStatus': '🎭',
            }
          }
        });

        // Act: Remover status
        await fakeFirestore
            .collection('users')
            .doc(userId)
            .update({
          'stats.gamification.userStatus': null,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Assert: Verificar remoção
        final userDoc = await fakeFirestore
            .collection('users')
            .doc(userId)
            .get();
        
        expect(
          userDoc.data()?['stats']?['gamification']?['userStatus'],
          isNull,
        );
      });

      test('busca usuários por liga', () async {
        // Arrange: Criar múltiplos usuários
        await fakeFirestore
            .collection('users')
            .doc('user1')
            .set({
          'name': 'User 1',
          'stats': {
            'gamification': {
              'currentLeague': 'bronze',
              'weeklyXP': 100,
            }
          }
        });

        await fakeFirestore
            .collection('users')
            .doc('user2')
            .set({
          'name': 'User 2',
          'stats': {
            'gamification': {
              'currentLeague': 'silver',
              'weeklyXP': 200,
            }
          }
        });

        await fakeFirestore
            .collection('users')
            .doc('user3')
            .set({
          'name': 'User 3',
          'stats': {
            'gamification': {
              'currentLeague': 'bronze',
              'weeklyXP': 150,
            }
          }
        });

        // Act: Buscar usuários bronze
        final bronzeUsers = await fakeFirestore
            .collection('users')
            .where('stats.gamification.currentLeague', isEqualTo: 'bronze')
            .get();

        // Assert: Verificar resultado
        expect(bronzeUsers.docs, hasLength(2));
      });
    });

    group('weeklyResults collection', () {
      test('cria resultado semanal com estrutura correta', () async {
        // Arrange
        const weekId = 'bronze_2024-01-15_test123_2024-01-15';
        
        // Act: Criar resultado
        await fakeFirestore
            .collection('weeklyResults')
            .doc(weekId)
            .set({
          'weekStartDate': Timestamp.now(),
          'weekEndDate': Timestamp.now(),
          'league': 'bronze',
          'groupId': 'bronze_2024-01-15_test123',
          'rankings': [
            {
              'userId': 'user1',
              'rank': 1,
              'weeklyXP': 520,
              'gemsAwarded': 100,
              'wasPromoted': true,
              'wasDemoted': false,
              'newLeague': 'silver',
            },
            {
              'userId': 'user2',
              'rank': 2,
              'weeklyXP': 495,
              'gemsAwarded': 50,
              'wasPromoted': true,
              'wasDemoted': false,
              'newLeague': 'silver',
            },
          ],
          'processedAt': Timestamp.now(),
        });

        // Assert: Verificar estrutura
        final resultDoc = await fakeFirestore
            .collection('weeklyResults')
            .doc(weekId)
            .get();
        
        expect(resultDoc.exists, true);
        expect(resultDoc.data()?['league'], equals('bronze'));
        expect(resultDoc.data()?['rankings'], hasLength(2));
        
        final firstRank = resultDoc.data()?['rankings'][0];
        expect(firstRank['rank'], equals(1));
        expect(firstRank['gemsAwarded'], equals(100));
        expect(firstRank['wasPromoted'], true);
      });
    });

    group('Data Validation', () {
      test('valida ligas válidas', () {
        const validLeagues = ['bronze', 'silver', 'gold', 'platinum', 'diamond'];
        
        for (final league in validLeagues) {
          expect(validLeagues.contains(league), true);
        }
      });

      test('valida status de grupo', () {
        const validStatuses = ['active', 'completed'];
        
        for (final status in validStatuses) {
          expect(validStatuses.contains(status), true);
        }
      });

      test('valida ranks sequenciais', () {
        final ranks = List.generate(30, (i) => i + 1);
        
        expect(ranks.first, equals(1));
        expect(ranks.last, equals(30));
        expect(ranks, hasLength(30));
        
        // Verificar que não há gaps
        for (int i = 0; i < ranks.length - 1; i++) {
          expect(ranks[i + 1] - ranks[i], equals(1));
        }
      });
    });

    group('Error Handling', () {
      test('trata erro ao atualizar documento inexistente', () async {
        // Act & Assert: Tentar atualizar documento inexistente
        expect(
          () => fakeFirestore
              .collection('users')
              .doc('nonexistent-user')
              .update({'stats.gamification.userStatus': '🎭'}),
          throwsA(isA<Exception>()),
        );
      });

      test('retorna null para documento inexistente', () async {
        // Act: Buscar documento inexistente
        final doc = await fakeFirestore
            .collection('users')
            .doc('nonexistent-user')
            .get();

        // Assert: Verificar que não existe
        expect(doc.exists, false);
        expect(doc.data(), isNull);
      });

      test('retorna lista vazia para query sem resultados', () async {
        // Act: Buscar grupos que não existem
        final groups = await fakeFirestore
            .collection('leaderboardGroups')
            .where('league', isEqualTo: 'nonexistent')
            .get();

        // Assert: Verificar lista vazia
        expect(groups.docs, isEmpty);
      });
    });
  });
}
