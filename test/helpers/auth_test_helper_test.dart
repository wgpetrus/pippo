import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'auth_test_helper.dart';
import 'firebase_test_helper.dart';

void main() {
  setUp(() async {
    await FirebaseTestHelper.setupFirebase();
  });

  group('AuthTestHelper', () {
    test('createMockAuthWithUser cria auth com usuário autenticado', () {
      // Act
      final auth = AuthTestHelper.createMockAuthWithUser(
        'user-123',
        'test@example.com',
        displayName: 'John Doe',
      );

      // Assert
      expect(auth.currentUser, isNotNull);
      expect(auth.currentUser!.uid, 'user-123');
      expect(auth.currentUser!.email, 'test@example.com');
      expect(auth.currentUser!.displayName, 'John Doe');
      expect(auth.currentUser!.emailVerified, isTrue);
    });

    test('createMockAuthWithUser usa valores padrão', () {
      // Act
      final auth = AuthTestHelper.createMockAuthWithUser(
        'user-456',
        'another@example.com',
      );

      // Assert
      expect(auth.currentUser, isNotNull);
      expect(auth.currentUser!.displayName, 'Test User');
      expect(auth.currentUser!.emailVerified, isTrue);
    });

    test('createMockAuthWithoutUser cria auth sem usuário', () {
      // Act
      final auth = AuthTestHelper.createMockAuthWithoutUser();

      // Assert
      expect(auth.currentUser, isNull);
    });

    test('simulateLogin retorna UserCredential', () async {
      // Arrange
      final auth = AuthTestHelper.createMockAuthWithoutUser();
      expect(auth.currentUser, isNull);

      // Act
      final credential = await AuthTestHelper.simulateLogin(
        auth,
        'test@example.com',
        'password123',
      );

      // Assert - Verifica que UserCredential foi retornado
      expect(credential, isNotNull);
      // Nota: MockFirebaseAuth com signedIn: false pode retornar user null
      // Para testes que precisam de currentUser, use createMockAuthWithUser
    });

    test('simulateLogout remove usuário autenticado', () async {
      // Arrange
      final auth = AuthTestHelper.createMockAuthWithUser(
        'user-789',
        'logout@example.com',
      );
      expect(auth.currentUser, isNotNull);

      // Act
      await AuthTestHelper.simulateLogout(auth);

      // Assert
      expect(auth.currentUser, isNull);
    });

    test('simulateRegister retorna UserCredential', () async {
      // Arrange
      final auth = AuthTestHelper.createMockAuthWithoutUser();
      expect(auth.currentUser, isNull);

      // Act
      final credential = await AuthTestHelper.simulateRegister(
        auth,
        'newuser@example.com',
        'password123',
      );

      // Assert - Verifica que UserCredential foi retornado
      expect(credential, isNotNull);
      // Nota: MockFirebaseAuth com signedIn: false pode retornar user null
    });

    test('fluxo completo: createMockAuthWithUser e logout', () async {
      // Arrange - Criar auth com usuário já autenticado
      final auth = AuthTestHelper.createMockAuthWithUser(
        'user-123',
        'flow@example.com',
      );
      
      // Assert - Usuário está autenticado
      expect(auth.currentUser, isNotNull);
      expect(auth.currentUser!.email, 'flow@example.com');
      final registeredUid = auth.currentUser!.uid;

      // Act - Logout
      await AuthTestHelper.simulateLogout(auth);
      
      // Assert - Usuário foi deslogado
      expect(auth.currentUser, isNull);
    });

    test('createMockAuthWithUser permite múltiplos usuários', () async {
      // Arrange & Act - Primeiro usuário
      final auth1 = AuthTestHelper.createMockAuthWithUser(
        'user-1',
        'user1@example.com',
      );
      expect(auth1.currentUser, isNotNull);
      expect(auth1.currentUser!.email, 'user1@example.com');

      // Act - Logout primeiro usuário
      await AuthTestHelper.simulateLogout(auth1);
      expect(auth1.currentUser, isNull);

      // Arrange & Act - Segundo usuário (nova instância)
      final auth2 = AuthTestHelper.createMockAuthWithUser(
        'user-2',
        'user2@example.com',
      );
      expect(auth2.currentUser, isNotNull);
      expect(auth2.currentUser!.email, 'user2@example.com');

      // Act - Logout segundo usuário
      await AuthTestHelper.simulateLogout(auth2);
      expect(auth2.currentUser, isNull);
    });
  });
}
