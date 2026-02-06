# Ajustes de Testes - ProfileAuthController

## Controller Refatorado

**Arquivo**: `lib/features/inners/profile/controllers/profile_auth_controller.dart`

**Responsabilidade**: Gerenciar ações de autenticação (senha, telefone, deletar conta)

## Estados Migrados

- `phone`, `phoneVerified`, `verificationId`
- `isLoading`, `errorMessage`

## Métodos Migrados

- `changePassword(String currentPassword, String newPassword)`
- `linkPhoneNumber(String phoneNumber, String verificationCode)`
- `deleteAccount()`
- `_deleteUserSubcollections(String userId)`
- `_deleteCoursesWithSubcollections(String userId)`
- `_deleteCourseSubcollection(String userId, String courseId, String subcollectionName)`
- `_deleteCourseStatsSubcollection(String userId, String courseId)`
- `_deleteSubcollection(String userId, String subcollectionName)`
- `_deleteStatsSubcollection(String userId)`
- `_reauthenticateForDeletion()`
- `_handleFirebaseAuthError(FirebaseAuthException e)`

## Testes que Precisam Ser Atualizados

### Testes Unitários

**Arquivo**: `test/unit/features/inners/profile/controllers/profile_controller_test.dart`

**Grupos de teste afetados**:

1. **Authentication Changes Tests**
   - `19.1 Test changePassword() success`
   - `19.2 Test changePassword() wrong current password`
   - `19.3 Test linkPhoneNumber() success`
   - `19.4 Test linkPhoneNumber() invalid code`

**Mudanças necessárias**:
```dart
// ANTES
import 'package:pippo/features/inners/profile/controllers/profile_controller.dart';
controller = ProfileController();

// DEPOIS
import 'package:pippo/features/inners/profile/controllers/profile_auth_controller.dart';
controller = ProfileAuthController();
```

### Testes de Integração

**Arquivos afetados**:
- `test/integration/account_deletion_flow_integration_test.dart`
- `test/integration/link_phone_number_flow_integration_test.dart`
- `test/integration/auth_changes_flow_integration_test.dart`

**Mudanças necessárias**:
- Atualizar imports para `ProfileAuthController`
- Atualizar `Get.find<ProfileController>()` para `Get.find<ProfileAuthController>()`
- Verificar que mudança de senha funciona
- Verificar que vinculação de telefone funciona
- Verificar que exclusão de conta funciona

## Validações Necessárias

Após atualizar os testes:

1. ✅ Mudança de senha requer reautenticação
2. ✅ Mudança de senha atualiza senha no Firebase Auth
3. ✅ Erro de senha incorreta é tratado corretamente
4. ✅ Vinculação de telefone funciona com código válido
5. ✅ Vinculação de telefone falha com código inválido
6. ✅ Vinculação de telefone atualiza Firestore
7. ✅ Exclusão de conta remove todos os dados do usuário
8. ✅ Exclusão de conta remove subcoleções
9. ✅ Exclusão de conta requer reautenticação

## Fluxo de Mudança de Senha

```dart
1. Usuário fornece senha atual e nova senha
2. Sistema reautentica usuário com senha atual
3. Se reautenticação falhar → erro "senha incorreta"
4. Se reautenticação suceder → atualiza senha
5. Mostra mensagem de sucesso
6. Navega de volta
```

## Fluxo de Vinculação de Telefone

```dart
1. Usuário fornece número de telefone
2. Sistema envia código de verificação (SMS)
3. Usuário fornece código recebido
4. Sistema verifica código
5. Se código inválido → erro
6. Se código válido → vincula telefone ao Firebase Auth
7. Atualiza Firestore com phone e phoneVerified = true
8. Mostra tela de sucesso
```

## Fluxo de Exclusão de Conta

```dart
1. Usuário confirma exclusão
2. Sistema reautentica usuário
3. Sistema deleta subcoleções:
   - users/{userId}/courses (com subcoleções)
   - users/{userId}/stats
   - users/{userId}/settings
   - users/{userId}/following
   - users/{userId}/followers
4. Sistema deleta documento do usuário
5. Sistema deleta conta do Firebase Auth
6. Limpa dados locais (SharedPreferences, SecureStorage)
7. Navega para tela de auth
```

## Subcoleções a Deletar

```
users/{userId}/
├── courses/
│   └── {courseId}/
│       ├── lessons/
│       └── stats/
├── stats/
├── settings/
├── following/
└── followers/
```

## Error Handlers

### Firebase Auth Errors
```dart
String _handleFirebaseAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'wrong-password':
      return 'Senha incorreta. Verifique e tente novamente.';
    case 'requires-recent-login':
      return 'Por segurança, faça login novamente.';
    case 'invalid-verification-code':
      return 'Código de verificação inválido.';
    case 'invalid-verification-id':
      return 'Sessão de verificação expirada. Tente novamente.';
    default:
      return 'Erro ao processar solicitação. Tente novamente.';
  }
}
```

## Notas Importantes

- Este controller **NÃO** tem dependências de outros controllers
- Mudança de senha e exclusão de conta requerem reautenticação
- Exclusão de conta deve remover TODAS as subcoleções
- Vinculação de telefone usa Firebase Phone Auth
- Todos os erros do Firebase Auth devem ser tratados

## Checklist de Atualização

- [ ] Atualizar imports nos testes unitários
- [ ] Atualizar imports nos testes de integração
- [ ] Mockar Firebase Auth para testes
- [ ] Mockar Firebase Phone Auth para testes
- [ ] Executar testes unitários e verificar que passam
- [ ] Executar testes de integração e verificar que passam
- [ ] Verificar que reautenticação funciona
- [ ] Verificar que exclusão remove todas subcoleções
- [ ] Verificar que vinculação de telefone funciona
- [ ] Verificar tratamento de erros do Firebase Auth
