# Firebase - Padrões

---

## Error Handlers

Os handlers abaixo são **padrão fixo da empresa**. Usar exatamente como definido.

### Handler de Login

```dart
String _handleFirebaseLoginError(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return 'Não encontramos uma conta com este e-mail.';
    case 'wrong-password':
      return 'Senha incorreta. Verifique e tente novamente.';
    case 'invalid-email':
      return 'Por favor, insira um e-mail válido.';
    case 'user-disabled':
      return 'Esta conta foi desativada. Entre em contato com o suporte.';
    case 'too-many-requests':
      return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
    case 'network-request-failed':
      return 'Verifique sua conexão com a internet.';
    case 'invalid-credential':
      return 'E-mail ou senha incorretos.';
    default:
      return 'Não foi possível fazer login. Tente novamente.';
  }
}
```

### Handler de Registro

```dart
String _handleFirebaseRegisterError(FirebaseAuthException e) {
  switch (e.code) {
    case 'email-already-in-use':
      return 'Este e-mail já está sendo usado por outra conta.';
    case 'invalid-email':
      return 'Por favor, insira um e-mail válido.';
    case 'operation-not-allowed':
      return 'Operação não permitida no momento.';
    case 'weak-password':
      return 'A senha deve ter pelo menos 6 caracteres.';
    case 'network-request-failed':
      return 'Verifique sua conexão com a internet.';
    case 'too-many-requests':
      return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
    default:
      return 'Não foi possível criar sua conta. Tente novamente.';
  }
}
```

### Handler de Reset de Senha

```dart
String _handleFirebaseResetPasswordError(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return 'Não encontramos uma conta com este e-mail.';
    case 'invalid-email':
      return 'Por favor, insira um e-mail válido.';
    case 'too-many-requests':
      return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
    case 'network-request-failed':
      return 'Verifique sua conexão com a internet.';
    default:
      return 'Não foi possível enviar o e-mail de recuperação. Tente novamente.';
  }
}
```

### Handler de Firestore

```dart
String _handleFirestoreError(FirebaseException e) {
  switch (e.code) {
    case 'permission-denied':
      return 'Erro de permissão. Verifique as configurações do Firestore ou tente novamente em alguns instantes.';
    case 'unavailable':
      return 'Serviço temporariamente indisponível. Tente novamente em alguns instantes.';
    case 'deadline-exceeded':
      return 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    case 'resource-exhausted':
      return 'Muitas requisições. Aguarde alguns minutos e tente novamente.';
    case 'failed-precondition':
      return 'Operação não permitida no estado atual. Tente novamente.';
    case 'aborted':
      return 'Operação cancelada. Tente novamente.';
    case 'out-of-range':
      return 'Valor fora do intervalo permitido.';
    case 'unimplemented':
      return 'Operação não implementada.';
    case 'internal':
      return 'Erro interno do servidor. Tente novamente em alguns instantes.';
    case 'unauthenticated':
      return 'Usuário não autenticado. Faça login novamente.';
    case 'not-found':
      return 'Recurso não encontrado.';
    case 'already-exists':
      return 'Recurso já existe.';
    case 'cancelled':
      return 'Operação cancelada.';
    case 'data-loss':
      return 'Erro de integridade de dados.';
    case 'invalid-argument':
      return 'Argumento inválido.';
    default:
      return 'Erro ao salvar dados. Verifique sua conexão e tente novamente.';
  }
}
```

---

## Uso dos Handlers

```dart
// No controller
Future<void> login(String email, String password) async {
  try {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  } on FirebaseAuthException catch (e) {
    errorMessage.value = _handleFirebaseLoginError(e);
  }
}

Future<void> saveData(Map<String, dynamic> data) async {
  try {
    await _firestore.collection('users').doc(userId).set(data);
  } on FirebaseException catch (e) {
    errorMessage.value = _handleFirestoreError(e);
  }
}
```

---

## Centralização (Opcional)

Para projetos maiores, criar `shared/utils/error_handler.dart`:

```dart
class ErrorHandler {
  static String getLoginErrorMessage(FirebaseAuthException e) { ... }
  static String getRegisterErrorMessage(FirebaseAuthException e) { ... }
  static String getResetPasswordErrorMessage(FirebaseAuthException e) { ... }
  static String getFirestoreErrorMessage(FirebaseException e) { ... }
}
```

---

## Conversão de Datas

**Cuidado:** Firestore usa `Timestamp`, Flutter usa `DateTime`.

### Lendo do Firestore

```dart
// ❌ ERRADO - vai dar erro
final DateTime date = data['birthDate'];

// ✅ CORRETO - converter explicitamente
final Timestamp timestamp = data['birthDate'];
final DateTime date = timestamp.toDate();

// Ou com helper
DateTime? timestampToDateTime(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}
```

### Salvando no Firestore

```dart
// Para data atual do servidor
await doc.set({
  'createdAt': FieldValue.serverTimestamp(),
  'updatedAt': FieldValue.serverTimestamp(),
});

// Para data específica
await doc.set({
  'birthDate': Timestamp.fromDate(dateTime),
});
```

### Helper Completo (Recomendado)

```dart
class FirebaseDateHelper {
  /// Converte Timestamp do Firestore para DateTime
  static DateTime? toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
  
  /// Converte DateTime para Timestamp do Firestore
  static Timestamp? toTimestamp(DateTime? date) {
    if (date == null) return null;
    return Timestamp.fromDate(date);
  }
  
  /// Formata data para exibição (DD/MM/YYYY)
  static String formatDisplay(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }
}
```

---

## Regra Importante

**Sempre converter datas explicitamente.** Nunca assumir que o valor já é `DateTime`.
