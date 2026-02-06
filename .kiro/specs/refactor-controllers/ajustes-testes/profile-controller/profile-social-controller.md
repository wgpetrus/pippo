# Ajustes de Testes - ProfileSocialController

## Controller Refatorado

**Arquivo**: `lib/features/inners/profile/controllers/profile_social_controller.dart`

**Responsabilidade**: Gerenciar funcionalidades sociais (seguir, seguidores, busca de usuários)

## Estados Migrados

- `following`, `followers`, `followingCount`, `followersCount`
- `viewedUserId`, `viewedUserData`, `isFollowingViewedUser`
- `searchQuery`, `searchResults`, `isSearching`, `searchErrorMessage`
- `weeklyProgress`, `viewedUserWeeklyProgress`, `isLoadingProgress`
- `isLoading`, `errorMessage`

## Métodos Migrados

- `loadUserProfile(String userId)`
- `followUser(String targetUserId)`
- `unfollowUser(String targetUserId)`
- `loadFollowing()`
- `loadFollowers()`
- `loadUserFollowing(String userId)`
- `loadUserFollowers(String userId)`
- `isUserFollowed(String targetUserId)`
- `searchUsers(String query)`
- `clearSearch()`
- `loadWeeklyProgress()`
- `loadUserWeeklyProgress(String userId)`
- `_loadSocialCounts(String userId)`
- `_checkIfFollowing(String currentUserId, String targetUserId)`
- `_getDayAbbreviation(int weekday)`

## Testes que Precisam Ser Atualizados

### Testes Unitários

**Arquivo**: `test/unit/features/inners/profile/controllers/profile_controller_test.dart`

**Grupos de teste afetados**:

1. **Social Features Tests**
   - `20.1 Test followUser() success`
   - `20.2 Test followUser() self-follow prevention`
   - `20.3 Test unfollowUser() success`
   - `20.4 Test loadFollowing() success`
   - `20.5 Test loadFollowers() success`

**Arquivo**: `test/unit/features/inners/profile/controllers/profile_controller_search_test.dart`

**Todos os testes de busca**:
- `searchUsers retorna resultados por username`
- `searchUsers não retorna o próprio usuário`
- `searchUsers remove duplicatas`
- `searchUsers limpa resultados quando query vazia`
- `clearSearch limpa resultados`
- `searchUsers mostra erro quando não autenticado`
- `searchUsers mostra mensagem quando nenhum resultado`
- `searchUsers converte query para lowercase`
- `searchUsers define isSearching durante busca`
- `searchUsers limita resultados a 20`

**Mudanças necessárias**:
```dart
// ANTES
import 'package:pippo/features/inners/profile/controllers/profile_controller.dart';
controller = ProfileController();

// DEPOIS
import 'package:pippo/features/inners/profile/controllers/profile_social_controller.dart';
controller = ProfileSocialController();
```

### Testes de Propriedade

**Arquivo**: `test/property/features/inners/profile/controllers/profile_controller_property_test.dart`

**Propriedades afetadas**:

1. **Property 3: Follow/Unfollow Atomicity**
   - Property 3a: Follow operation uses batch with exactly 2 writes
   - Property 3b: Unfollow operation uses batch with exactly 2 deletes
   - Property 3c: User cannot follow themselves
   - Property 3d: Follow operation requires authenticated user
   - Property 3e: Batch commit ensures all-or-nothing for follow
   - Property 3f: Batch commit ensures all-or-nothing for unfollow
   - Property 3g: Follow state is consistent after successful operation
   - Property 3h: Unfollow state is consistent after successful operation

**Mudanças necessárias**:
```dart
// ANTES
import 'package:pippo/features/inners/profile/controllers/profile_controller.dart';
final controller = ProfileController();

// DEPOIS
import 'package:pippo/features/inners/profile/controllers/profile_social_controller.dart';
final controller = ProfileSocialController();
```

### Testes de Integração

**Arquivos afetados**:
- `test/integration/social_features_flow_integration_test.dart`
- `test/integration/search_users_flow_integration_test.dart`

**Mudanças necessárias**:
- Atualizar imports para `ProfileSocialController`
- Atualizar `Get.find<ProfileController>()` para `Get.find<ProfileSocialController>()`
- Verificar que os métodos de follow/unfollow funcionam
- Verificar que a busca de usuários funciona

## Dependências

Este controller **DEPENDE** de:
- `ProfileDataController` (para acessar `userId` do usuário atual)

**Inicialização da dependência**:
```dart
@override
void onInit() {
  super.onInit();
  _dataController = Get.find<ProfileDataController>();
}
```

## Validações Necessárias

Após atualizar os testes:

1. ✅ Follow cria 2 documentos atomicamente (following + followers)
2. ✅ Unfollow remove 2 documentos atomicamente (following + followers)
3. ✅ Self-follow é prevenido
4. ✅ Busca de usuários funciona por username e name
5. ✅ Busca não retorna o próprio usuário
6. ✅ Busca remove duplicatas
7. ✅ Busca limita resultados a 20
8. ✅ Estados locais são atualizados após follow/unfollow
9. ✅ Contadores (followingCount, followersCount) são corretos

## Operações Batch (Atomicidade)

### Follow Operation
```dart
final batch = _firestore.batch();
batch.set(followingRef, data);  // Operação 1
batch.set(followerRef, data);   // Operação 2
await batch.commit();           // Commit atômico
```

### Unfollow Operation
```dart
final batch = _firestore.batch();
batch.delete(followingRef);     // Operação 1
batch.delete(followerRef);      // Operação 2
await batch.commit();           // Commit atômico
```

## Notas Importantes

- Este controller **DEPENDE** de `ProfileDataController`
- Operações de follow/unfollow usam batch writes para atomicidade
- Busca de usuários é case-insensitive
- Busca limita resultados a 20 usuários
- Self-follow é prevenido antes de qualquer operação no Firestore

## Checklist de Atualização

- [ ] Atualizar imports nos testes unitários
- [ ] Atualizar imports nos testes de propriedade
- [ ] Atualizar imports nos testes de integração
- [ ] Mockar dependência de ProfileDataController nos testes
- [ ] Executar testes unitários e verificar que passam
- [ ] Executar testes de propriedade e verificar que passam
- [ ] Executar testes de integração e verificar que passam
- [ ] Verificar atomicidade das operações batch
- [ ] Verificar prevenção de self-follow
- [ ] Verificar busca de usuários funciona corretamente
