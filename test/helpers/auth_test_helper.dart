import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

/// Helper para simular operações de autenticação em testes
/// 
/// Uso:
/// ```dart
/// final auth = AuthTestHelper.createMockAuthWithUser('user-123', 'test@example.com');
/// await AuthTestHelper.simulateLogin(auth, 'test@example.com', 'password123');
/// await AuthTestHelper.simulateLogout(auth);
/// ```
class AuthTestHelper {
  /// Cria MockFirebaseAuth com usuário mockado
  /// 
  /// Parâmetros:
  /// - uid: ID único do usuário
  /// - email: Email do usuário
  /// 
  /// Retorna instância de MockFirebaseAuth configurada
  static MockFirebaseAuth createMockAuthWithUser(
    String uid,
    String email, {
    String? displayName,
    bool isEmailVerified = true,
  }) {
    return MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(
        uid: uid,
        email: email,
        displayName: displayName ?? 'Test User',
        isEmailVerified: isEmailVerified,
      ),
    );
  }

  /// Simula login com email e senha
  /// 
  /// Nota: MockFirebaseAuth criado com signedIn: false não atualiza currentUser
  /// ao chamar signInWithEmailAndPassword. Para testes de login, use
  /// createMockAuthWithUser diretamente ou verifique apenas o UserCredential retornado.
  /// 
  /// Parâmetros:
  /// - auth: instância de MockFirebaseAuth
  /// - email: email do usuário
  /// - password: senha do usuário
  /// 
  /// Retorna UserCredential mockado
  static Future<UserCredential> simulateLogin(
    MockFirebaseAuth auth,
    String email,
    String password,
  ) async {
    // MockFirebaseAuth já simula signInWithEmailAndPassword
    // Retorna UserCredential, mas não atualiza currentUser se criado com signedIn: false
    return await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Simula logout do usuário
  /// 
  /// Realiza signOut e limpa o estado do usuário autenticado.
  /// 
  /// Parâmetros:
  /// - auth: instância de MockFirebaseAuth
  static Future<void> simulateLogout(MockFirebaseAuth auth) async {
    await auth.signOut();
  }

  /// Cria MockFirebaseAuth sem usuário autenticado
  /// 
  /// Útil para testar fluxos de login quando o usuário não está autenticado.
  /// 
  /// Retorna instância de MockFirebaseAuth sem usuário
  static MockFirebaseAuth createMockAuthWithoutUser() {
    return MockFirebaseAuth(signedIn: false);
  }

  /// Simula registro de novo usuário
  /// 
  /// Cria um UserCredential mockado simulando registro bem-sucedido.
  /// 
  /// Parâmetros:
  /// - auth: instância de MockFirebaseAuth
  /// - email: email do novo usuário
  /// - password: senha do novo usuário
  /// 
  /// Retorna UserCredential mockado
  static Future<UserCredential> simulateRegister(
    MockFirebaseAuth auth,
    String email,
    String password,
  ) async {
    return await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
