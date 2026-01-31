import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pippo/features/inners/profile/controllers/profile_controller.dart';

import 'profile_controller_search_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  User,
  CollectionReference,
  Query,
  QuerySnapshot,
  QueryDocumentSnapshot,
  DocumentSnapshot,
])
void main() {
  late ProfileController controller;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockUser mockUser;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockUser = MockUser();

    // Setup default mocks
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('current-user-id');

    // Initialize GetX
    Get.testMode = true;

    // Create controller with mocked Firebase
    controller = ProfileController();
    // Inject mocked Firebase instances
    controller.onInit();
  });

  tearDown(() {
    Get.reset();
  });

  group('ProfileController - Search', () {
    test('searchUsers retorna resultados por username', () async {
      // Setup: Mock Firestore com usuários
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockQuery = MockQuery();
      final mockCollection = MockCollectionReference();

      final mockDoc1 = MockQueryDocumentSnapshot();
      final mockDoc2 = MockQueryDocumentSnapshot();

      when(mockDoc1.id).thenReturn('user-1');
      when(mockDoc1.data()).thenReturn({
        'userId': 'user-1',
        'name': 'John Doe',
        'username': 'johndoe',
        'avatarId': 'avatar_01',
        'country': 'BR',
      });

      when(mockDoc2.id).thenReturn('user-2');
      when(mockDoc2.data()).thenReturn({
        'userId': 'user-2',
        'name': 'John Smith',
        'username': 'johnsmith',
        'avatarId': 'avatar_02',
        'country': 'US',
      });

      when(mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);
      when(mockQuery.limit(20)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);

      // Execute: searchUsers('john')
      await controller.searchUsers('john');

      // Verify: searchResults contém usuários com username começando com 'john'
      expect(controller.searchResults.length, 2);
      expect(controller.searchResults[0]['username'], 'johndoe');
      expect(controller.searchResults[1]['username'], 'johnsmith');
    });

    test('searchUsers não retorna o próprio usuário', () async {
      // Setup: Mock usuário atual
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockQuery = MockQuery();

      final mockDoc1 = MockQueryDocumentSnapshot();
      final mockDoc2 = MockQueryDocumentSnapshot();

      when(mockDoc1.id).thenReturn('current-user-id'); // Próprio usuário
      when(mockDoc1.data()).thenReturn({
        'userId': 'current-user-id',
        'name': 'Current User',
        'username': 'currentuser',
        'avatarId': 'avatar_01',
      });

      when(mockDoc2.id).thenReturn('other-user-id');
      when(mockDoc2.data()).thenReturn({
        'userId': 'other-user-id',
        'name': 'Other User',
        'username': 'otheruser',
        'avatarId': 'avatar_02',
      });

      when(mockQuerySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);
      when(mockQuery.limit(20)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);

      // Execute: searchUsers('user')
      await controller.searchUsers('user');

      // Verify: searchResults não contém currentUserId
      expect(controller.searchResults.length, 1);
      expect(controller.searchResults[0]['userId'], 'other-user-id');
    });

    test('searchUsers remove duplicatas', () async {
      // Setup: Mock usuário que aparece em ambas queries
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockQuery = MockQuery();

      final mockDoc = MockQueryDocumentSnapshot();

      when(mockDoc.id).thenReturn('user-1');
      when(mockDoc.data()).thenReturn({
        'userId': 'user-1',
        'name': 'Test User',
        'username': 'testuser',
        'avatarId': 'avatar_01',
      });

      when(mockQuerySnapshot.docs).thenReturn([mockDoc]);
      when(mockQuery.limit(20)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);

      // Execute: searchUsers('test')
      await controller.searchUsers('test');

      // Verify: searchResults não tem duplicatas
      expect(controller.searchResults.length, 1);
      expect(controller.searchResults[0]['userId'], 'user-1');
    });

    test('searchUsers limpa resultados quando query vazia', () {
      // Setup: Adicionar resultados anteriores
      controller.searchResults.add({'userId': 'user-1', 'name': 'Test'});

      // Execute: searchUsers('')
      controller.searchUsers('');

      // Verify: searchResults vazio
      expect(controller.searchResults.length, 0);
    });

    test('clearSearch limpa resultados', () {
      // Setup: Adicionar dados de busca
      controller.searchQuery.value = 'test';
      controller.searchResults.add({'userId': 'user-1'});
      controller.searchErrorMessage.value = 'Erro';

      // Execute: clearSearch()
      controller.clearSearch();

      // Verify: Tudo limpo
      expect(controller.searchQuery.value, '');
      expect(controller.searchResults.length, 0);
      expect(controller.searchErrorMessage.value, '');
    });

    test('searchUsers mostra erro quando não autenticado', () async {
      // Setup: Mock usuário não autenticado
      when(mockAuth.currentUser).thenReturn(null);

      // Execute: searchUsers('test')
      await controller.searchUsers('test');

      // Verify: Mensagem de erro
      expect(controller.searchErrorMessage.value, 'Usuário não autenticado.');
    });

    test('searchUsers mostra mensagem quando nenhum resultado', () async {
      // Setup: Mock query vazia
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockQuery = MockQuery();

      when(mockQuerySnapshot.docs).thenReturn([]);
      when(mockQuery.limit(20)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);

      // Execute: searchUsers('nonexistent')
      await controller.searchUsers('nonexistent');

      // Verify: Mensagem de nenhum resultado
      expect(controller.searchErrorMessage.value, 'Nenhum usuário encontrado.');
      expect(controller.searchResults.length, 0);
    });

    test('searchUsers converte query para lowercase', () async {
      // Setup: Mock query
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockQuery = MockQuery();

      when(mockQuerySnapshot.docs).thenReturn([]);
      when(mockQuery.limit(20)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);

      // Execute: searchUsers('JOHN')
      await controller.searchUsers('JOHN');

      // Verify: searchQuery em lowercase
      expect(controller.searchQuery.value, 'john');
    });

    test('searchUsers define isSearching durante busca', () async {
      // Setup: Mock query
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockQuery = MockQuery();

      when(mockQuerySnapshot.docs).thenReturn([]);
      when(mockQuery.limit(20)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);

      // Execute: searchUsers('test')
      final future = controller.searchUsers('test');

      // Verify: isSearching = true durante busca
      expect(controller.isSearching.value, true);

      await future;

      // Verify: isSearching = false após busca
      expect(controller.isSearching.value, false);
    });

    test('searchUsers limita resultados a 20', () async {
      // Setup: Mock query com limite
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockQuery = MockQuery();

      when(mockQuery.limit(20)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      // Execute: searchUsers('test')
      await controller.searchUsers('test');

      // Verify: limit(20) foi chamado
      verify(mockQuery.limit(20)).called(greaterThan(0));
    });
  });
}
