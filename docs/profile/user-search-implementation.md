# Implementação: Busca de Usuários

> Feature para permitir que usuários encontrem e visualizem perfis de outros usuários

---

## Visão Geral

Adicionar funcionalidade de busca de usuários ao sistema de perfil, permitindo que usuários encontrem outros usuários por username ou nome e visualizem seus perfis.

**Acesso:** Card "Encontrar amigos" na ProfilePage → SearchUsersPage

---

## Estrutura de Arquivos

```
lib/features/inners/profile/
├── controllers/
│   └── profile_controller.dart (adicionar método searchUsers)
├── views/
│   ├── profile_page.dart (adicionar FindFriendsCard)
│   └── search_users_page.dart (NOVO)
└── widgets/
    ├── find_friends_card.dart (NOVO)
    └── user_search_item.dart (NOVO)
```

---

## 1. Adicionar Método de Busca no ProfileController

### Localização
`lib/features/inners/profile/controllers/profile_controller.dart`

### Estados Observáveis (adicionar)
```dart
// Search States
final searchQuery = ''.obs;
final searchResults = <Map<String, dynamic>>[].obs;
final isSearching = false.obs;
final searchErrorMessage = ''.obs;
```

### Método searchUsers()
```dart
/// Busca usuários por username ou nome
Future<void> searchUsers(String query) async {
  if (query.trim().isEmpty) {
    searchResults.clear();
    return;
  }

  isSearching.value = true;
  searchErrorMessage.value = '';
  searchQuery.value = query.trim().toLowerCase();

  try {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null || currentUserId.isEmpty) {
      searchErrorMessage.value = 'Usuário não autenticado.';
      return;
    }

    // Buscar por username (exato ou começa com)
    final usernameQuery = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: searchQuery.value)
        .where('username', isLessThan: '${searchQuery.value}z')
        .limit(20)
        .get();

    // Buscar por nome (case-insensitive via campo searchName)
    final nameQuery = await _firestore
        .collection('users')
        .where('searchName', isGreaterThanOrEqualTo: searchQuery.value)
        .where('searchName', isLessThan: '${searchQuery.value}z')
        .limit(20)
        .get();

    // Combinar resultados e remover duplicatas
    final results = <String, Map<String, dynamic>>{};
    
    for (var doc in usernameQuery.docs) {
      if (doc.id != currentUserId) {
        results[doc.id] = {
          'userId': doc.id,
          ...doc.data(),
        };
      }
    }
    
    for (var doc in nameQuery.docs) {
      if (doc.id != currentUserId && !results.containsKey(doc.id)) {
        results[doc.id] = {
          'userId': doc.id,
          ...doc.data(),
        };
      }
    }

    searchResults.value = results.values.toList();

    if (searchResults.isEmpty) {
      searchErrorMessage.value = 'Nenhum usuário encontrado.';
    }
  } on FirebaseException catch (e) {
    searchErrorMessage.value = _handleFirestoreError(e);
  } catch (e) {
    searchErrorMessage.value = 'Erro ao buscar usuários. Tente novamente.';
  } finally {
    isSearching.value = false;
  }
}

/// Limpa resultados da busca
void clearSearch() {
  searchQuery.value = '';
  searchResults.clear();
  searchErrorMessage.value = '';
}
```

---

## 2. Widget FindFriendsCard

### Localização
`lib/features/inners/profile/widgets/find_friends_card.dart`

### Implementação
```dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../views/search_users_page.dart';

/// Card para navegar para busca de usuários
class FindFriendsCard extends StatelessWidget {
  const FindFriendsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);

    return GestureDetector(
      onTap: () => Get.to(() => const SearchUsersPage()),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: r.spacing20),
        padding: EdgeInsets.all(r.spacing16),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Ícone
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.magnifyingGlass,
                  color: AppTheme.white,
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: r.spacing12),

            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Encontrar amigos',
                    style: AppTheme.textMdBold.copyWith(
                      color: AppTheme.gray900,
                    ),
                  ),
                  SizedBox(height: r.spacing4),
                  Text(
                    'Busque por username ou nome',
                    style: AppTheme.textSm.copyWith(
                      color: AppTheme.gray600,
                    ),
                  ),
                ],
              ),
            ),

            // Chevron
            FaIcon(
              FontAwesomeIcons.chevronRight,
              color: AppTheme.gray400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 3. Widget UserSearchItem

### Localização
`lib/features/inners/profile/widgets/user_search_item.dart`

### Implementação
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/app_assets.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../views/user_profile_page.dart';

/// Item de resultado de busca de usuário
class UserSearchItem extends StatelessWidget {
  final String userId;
  final String name;
  final String username;
  final String avatarId;
  final String? country;

  const UserSearchItem({
    super.key,
    required this.userId,
    required this.name,
    required this.username,
    required this.avatarId,
    this.country,
  });

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);

    return InkWell(
      onTap: () => Get.to(() => UserProfilePage(userId: userId)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: r.spacing20,
          vertical: r.spacing12,
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage(_getAvatarAsset(avatarId)),
            ),
            SizedBox(width: r.spacing12),

            // Nome e username
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTheme.textMdBold.copyWith(
                      color: AppTheme.gray900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: r.spacing4),
                  Text(
                    '@$username',
                    style: AppTheme.textSm.copyWith(
                      color: AppTheme.gray600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Bandeira do país (se disponível)
            if (country != null) ...[
              SizedBox(width: r.spacing8),
              Image.asset(
                _getCountryFlag(country!),
                width: 24,
                height: 24,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helpers

  String _getAvatarAsset(String avatarId) {
    switch (avatarId) {
      case 'avatar_01':
        return AppAssets.charMara;
      case 'avatar_02':
        return AppAssets.charDafny;
      case 'avatar_03':
        return AppAssets.charDiogo;
      case 'avatar_04':
        return AppAssets.charFrancilene;
      case 'avatar_05':
        return AppAssets.charGlauciane;
      case 'avatar_06':
        return AppAssets.charLindoedson;
      case 'avatar_07':
        return AppAssets.charRenner;
      default:
        return AppAssets.charMara;
    }
  }

  String _getCountryFlag(String countryCode) {
    switch (countryCode) {
      case 'BR':
        return AppAssets.flagBrazil;
      case 'US':
        return AppAssets.flagUsa;
      case 'FR':
        return AppAssets.flagFrance;
      case 'ES':
        return AppAssets.flagSpain;
      case 'DE':
        return AppAssets.flagGermany;
      case 'CN':
        return AppAssets.flagChina;
      case 'JP':
        return AppAssets.flagJapan;
      case 'SA':
        return AppAssets.flagSaudit;
      default:
        return AppAssets.flagBrazil;
    }
  }
}
```

---

## 4. SearchUsersPage

### Localização
`lib/features/inners/profile/views/search_users_page.dart`

### Implementação
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/app_appbar.dart';
import '../controllers/profile_controller.dart';
import '../widgets/user_search_item.dart';

/// Página de busca de usuários
class SearchUsersPage extends StatefulWidget {
  const SearchUsersPage({super.key});

  @override
  State<SearchUsersPage> createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  late final ProfileController _controller;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ProfileController>();
    _controller.clearSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveUtils(context);

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: const AppAppbar(title: 'Buscar usuários'),
      body: Column(
        children: [
          // Campo de busca
          Padding(
            padding: EdgeInsets.all(r.spacing20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Digite username ou nome',
                hintStyle: AppTheme.textMd.copyWith(color: AppTheme.gray400),
                prefixIcon: const Icon(Icons.search, color: AppTheme.gray400),
                suffixIcon: Obx(() {
                  if (_controller.searchQuery.value.isEmpty) return const SizedBox();
                  return IconButton(
                    icon: const Icon(Icons.clear, color: AppTheme.gray400),
                    onPressed: () {
                      _searchController.clear();
                      _controller.clearSearch();
                    },
                  );
                }),
                filled: true,
                fillColor: AppTheme.gray100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: r.spacing16,
                  vertical: r.spacing12,
                ),
              ),
              onChanged: (value) {
                // Debounce de 500ms
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _controller.searchUsers(value);
                  }
                });
              },
            ),
          ),

          // Resultados
          Expanded(
            child: Obx(() {
              // Loading
              if (_controller.isSearching.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                );
              }

              // Estado inicial (sem busca)
              if (_controller.searchQuery.value.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        size: 64,
                        color: AppTheme.gray300,
                      ),
                      SizedBox(height: r.spacing16),
                      Text(
                        'Busque por username ou nome',
                        style: AppTheme.textMd.copyWith(
                          color: AppTheme.gray600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Erro
              if (_controller.searchErrorMessage.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(r.spacing20),
                    child: Text(
                      _controller.searchErrorMessage.value,
                      style: AppTheme.textMd.copyWith(
                        color: _controller.searchResults.isEmpty
                            ? AppTheme.gray600
                            : AppTheme.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              // Resultados
              if (_controller.searchResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off,
                        size: 64,
                        color: AppTheme.gray300,
                      ),
                      SizedBox(height: r.spacing16),
                      Text(
                        'Nenhum usuário encontrado',
                        style: AppTheme.textMd.copyWith(
                          color: AppTheme.gray600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: _controller.searchResults.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: AppTheme.gray200,
                  indent: r.spacing20 + 48 + r.spacing12,
                ),
                itemBuilder: (context, index) {
                  final user = _controller.searchResults[index];
                  return UserSearchItem(
                    userId: user['userId'] ?? '',
                    name: user['name'] ?? '',
                    username: user['username'] ?? '',
                    avatarId: user['avatarId'] ?? 'avatar_01',
                    country: user['country'],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
```

---

## 5. Atualizar ProfilePage

### Localização
`lib/features/inners/profile/views/profile_page.dart`

### Modificação
Adicionar o `FindFriendsCard` após o `ProfileHeader` ou `CompleteProfileCard`:

```dart
// Importar no topo
import '../widgets/find_friends_card.dart';

// No build(), adicionar após ProfileHeader:
Column(
  children: [
    ProfileHeader(...),
    SizedBox(height: r.spacing16),
    
    // 🆕 ADICIONAR AQUI
    const FindFriendsCard(),
    SizedBox(height: r.spacing24),
    
    // Resto do conteúdo...
    OverviewSection(...),
    // ...
  ],
)
```

---

## 6. Firestore: Campo searchName

### Problema
Firestore não suporta busca case-insensitive nativamente.

### Solução
Adicionar campo `searchName` (lowercase) ao criar/atualizar perfil:

```dart
// No ProfileController.updateProfile()
Future<void> updateProfile(Map<String, dynamic> updates) async {
  // ...
  
  // Se atualizando o nome, adicionar searchName
  if (updates.containsKey('name')) {
    updates['searchName'] = (updates['name'] as String).toLowerCase();
  }
  
  await _firestore.collection('users').doc(userId).update(updates);
  
  // ...
}
```

### Migração de Dados Existentes
Criar script ou Cloud Function para adicionar `searchName` aos usuários existentes:

```dart
// Script de migração (executar uma vez)
Future<void> migrateSearchNames() async {
  final users = await FirebaseFirestore.instance.collection('users').get();
  
  final batch = FirebaseFirestore.instance.batch();
  
  for (var doc in users.docs) {
    final name = doc.data()['name'] as String?;
    if (name != null) {
      batch.update(doc.reference, {
        'searchName': name.toLowerCase(),
      });
    }
  }
  
  await batch.commit();
}
```

---

## 7. Firestore - Configuração

As regras de segurança do Firestore já estão configuradas no arquivo `firestore.rules` local. Essa configuração é responsabilidade da equipe de DevOps/Backend.

---

## 8. Firestore Indexes

### ⚠️ AÇÃO NECESSÁRIA: Criar Índices Compostos

Para que as queries de busca funcionem, é necessário criar índices compostos no Firebase Console.

**Como criar:**

1. Acessar Firebase Console > Firestore Database > Indexes
2. Clicar em "Create Index"
3. Criar os seguintes índices:

#### Índice 1: Busca por Username
- **Collection ID:** `users`
- **Fields indexed:**
  - `username` - Ascending
  - `__name__` - Ascending
- **Query scope:** Collection

#### Índice 2: Busca por Nome (searchName)
- **Collection ID:** `users`
- **Fields indexed:**
  - `searchName` - Ascending
  - `__name__` - Ascending
- **Query scope:** Collection

**Alternativa:** Os índices serão sugeridos automaticamente pelo Firebase quando você executar as queries pela primeira vez. O erro incluirá um link direto para criar o índice.

### Verificação

Após criar os índices, aguardar alguns minutos para que fiquem ativos (status: "Enabled").

---

## 9. Campo searchName - Migração de Dados

### Unit Tests
```dart
// test/unit/features/inners/profile/controllers/profile_controller_search_test.dart

group('ProfileController - Search', () {
  test('searchUsers retorna resultados por username', () async {
    // Setup: Mock Firestore com usuários
    // Execute: searchUsers('john')
    // Verify: searchResults contém usuários com username começando com 'john'
  });

  test('searchUsers retorna resultados por nome', () async {
    // Setup: Mock Firestore com usuários
    // Execute: searchUsers('maria')
    // Verify: searchResults contém usuários com nome começando com 'maria'
  });

  test('searchUsers remove duplicatas', () async {
    // Setup: Mock usuário que aparece em ambas queries
    // Execute: searchUsers('test')
    // Verify: searchResults não tem duplicatas
  });

  test('searchUsers não retorna o próprio usuário', () async {
    // Setup: Mock usuário atual
    // Execute: searchUsers(currentUsername)
    // Verify: searchResults não contém currentUserId
  });

  test('clearSearch limpa resultados', () {
    // Execute: clearSearch()
    // Verify: searchQuery vazio, searchResults vazio
  });
});
```

### Integration Tests
```dart
// test/integration/search_users_flow_integration_test.dart

testWidgets('Fluxo completo de busca de usuários', (tester) async {
  // 1. Navegar para ProfilePage
  // 2. Tap em FindFriendsCard
  // 3. Verificar SearchUsersPage abriu
  // 4. Digitar query no campo de busca
  // 5. Aguardar resultados
  // 6. Tap em um resultado
  // 7. Verificar UserProfilePage abriu com userId correto
});
```

---

## Checklist de Implementação

### Implementação do Código
- [ ] 1. Adicionar estados observáveis no ProfileController
- [ ] 2. Implementar método searchUsers() no ProfileController
- [ ] 3. Implementar método clearSearch() no ProfileController
- [ ] 4. Criar widget FindFriendsCard
- [ ] 5. Criar widget UserSearchItem
- [ ] 6. Criar SearchUsersPage
- [ ] 7. Adicionar FindFriendsCard na ProfilePage
- [ ] 8. Adicionar campo searchName ao updateProfile()
- [ ] 9. Migrar dados existentes (adicionar searchName)

### Testes
- [ ] 10. Criar unit tests para searchUsers
- [ ] 11. Criar integration test para fluxo completo
- [ ] 12. Testar manualmente no app

---

## ⚠️ RESUMO: Requisitos Firebase

### 1. Índices Compostos - CRIAR MANUALMENTE
**Status:** Não existem  
**Ação:** Criar 2 índices no Firebase Console (ou aguardar sugestão automática)  
**Urgência:** ALTA - Queries falharão sem os índices

### 2. Campo searchName - MIGRAÇÃO OPCIONAL
**Status:** Usuários existentes não têm o campo  
**Ação:** Executar script de migração OU aguardar atualização lazy  
**Urgência:** BAIXA - Funciona sem migração (usuários aparecem ao atualizar perfil)

---

## Notas Importantes

### Performance
- Limite de 20 resultados por query
- Debounce de 500ms no campo de busca
- Queries otimizadas com índices Firestore

### UX
- Estado inicial mostra ícone e mensagem
- Loading durante busca
- Mensagem quando não encontra resultados
- Botão clear para limpar busca
- Navegação direta para perfil ao clicar

### Firestore Indexes
Criar índices compostos no Firebase Console:
- Collection: `users`
  - Fields: `username` (Ascending), `__name__` (Ascending)
  - Fields: `searchName` (Ascending), `__name__` (Ascending)

### Limitações
- Busca por prefixo apenas (não busca no meio do texto)
- Case-insensitive via campo separado (searchName)
- Máximo 20 resultados por busca

### Melhorias Futuras
- Algolia ou ElasticSearch para busca full-text
- Sugestões de usuários populares
- Histórico de buscas
- Filtros (país, nível, etc)
