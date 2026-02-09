# Spec: Correção de Bugs - Fevereiro 2026

> Correção sistemática de 28 categorias de bugs identificados no projeto Pippo

---

## Objetivo

Corrigir todos os bugs identificados no `BUG_REPORT.md`, priorizando:
1. **URGENTE**: Bugs que podem crashar o app
2. **Alta**: Duplicação de código e handlers
3. **Média**: Traduções e UX
4. **Baixa**: Melhorias de infraestrutura

---

## Escopo

- **28 categorias de bugs**
- **20+ arquivos para modificar**
- **60+ instâncias de texto hardcoded**
- **18 wrappers desnecessários**
- **3 handlers duplicados completos**

---

## Tasks

### 🔥 URGENTE - Bugs Críticos (Podem Crashar)

#### Task 1: Corrigir Null Pointer em Splash Controller
**Arquivo:** `lib/features/inners/splash/controllers/splash_controller.dart`  
**Linha:** 77  
**Problema:** Uso de `!` sem verificação pode crashar app

**Ação:**
```dart
// ANTES
final userId = _auth.currentUser!.uid;

// DEPOIS
final user = _auth.currentUser;
if (user == null) {
  errorMessage.value = 'error_unauthenticated'.tr;
  _navigateToAuth();
  return;
}
final userId = user.uid;
```

**Critério de Aceite:**
- [ ] Remover uso de `!` operator
- [ ] Adicionar verificação de null
- [ ] Navegar para auth se não autenticado
- [ ] Usar mensagem traduzida

---

#### Task 2: Refatorar Verificação de Auth em Lesson Flow
**Arquivo:** `lib/features/core/lesson/controllers/lesson_flow_controller.dart`  
**Problema:** Race condition com múltiplas verificações de auth + delays artificiais

**Ação:**
1. Criar método helper `_getAuthenticatedUser()`
2. Remover delays de 100ms
3. Usar helper em todos os métodos
4. Adicionar verificação no `onInit()`

**Critério de Aceite:**
- [ ] Criar método `_getAuthenticatedUser()` que retorna `User?`
- [ ] Remover todos os `Future.delayed(Duration(milliseconds: 100))`
- [ ] Substituir todas as verificações inline por chamada ao helper
- [ ] Adicionar verificação no `onInit()` para garantir auth antes de qualquer operação
- [ ] Testar que não há mais erro "Usuário não autenticado" ao clicar rapidamente

---

#### Task 3: Adicionar Try-Catch em Operações Firestore
**Arquivos Afetados:**
- `profile_data_controller.dart` (linha 149)
- `profile_social_controller.dart` (linha 55)
- `profile_auth_controller.dart` (linha 139)
- Todos os controllers com operações Firestore

**Ação:**
Envolver TODAS as operações Firestore em try-catch:
```dart
try {
  await _firestore.collection('users').doc(userId).update(updates);
} on FirebaseException catch (e) {
  errorMessage.value = ErrorHandler.getFirestoreErrorMessage(e);
} catch (e) {
  errorMessage.value = 'error_generic'.tr;
}
```

**Critério de Aceite:**
- [ ] Identificar todas as operações Firestore sem try-catch
- [ ] Adicionar try-catch com handler padronizado
- [ ] Usar `ErrorHandler.getFirestoreErrorMessage(e)` para FirebaseException
- [ ] Usar `'error_generic'.tr` para outros erros
- [ ] Testar que app não crasha em caso de erro de rede

---

#### Task 4: Implementar onClose() em Todos Controllers
**Arquivos Afetados:**
- `HomeNavigationController`
- `ProfileSocialController`
- `TreasureChallengesController`
- Todos os controllers de gamificação
- Todos os controllers sem `onClose()`

**Ação:**
```dart
@override
void onClose() {
  // Limpar listas observáveis
  challenges.clear();
  searchResults.clear();
  
  // Resetar estados
  currentNavIndex.value = 0;
  isLoading.value = false;
  errorMessage.value = '';
  
  super.onClose();
}
```

**Critério de Aceite:**
- [ ] Identificar todos os controllers sem `onClose()`
- [ ] Implementar `onClose()` em cada um
- [ ] Limpar listas observáveis
- [ ] Resetar estados
- [ ] Testar que não há memory leaks ao navegar entre telas

---

#### Task 5: Implementar Transactions para Gamificação
**Arquivos Afetados:**
- `energy_controller.dart`
- `gems_controller.dart`
- `xp_level_controller.dart`

**Problema:** Múltiplos controllers atualizam o mesmo documento simultaneamente

**Ação:**
```dart
// Usar transaction atômica
await _firestore.runTransaction((transaction) async {
  final statsRef = _firestore
      .collection('users')
      .doc(userId)
      .collection('stats')
      .doc('gamification');
  
  transaction.update(statsRef, {
    'energy.currentEnergy': newEnergy,
    'gems.gems': newGems,
    'xp.totalXp': newXp,
  });
});
```

**Critério de Aceite:**
- [ ] Identificar todas as atualizações concorrentes
- [ ] Refatorar para usar transactions
- [ ] Testar que não há perda de dados
- [ ] Verificar consistência entre UI e Firestore

---

### 🔄 ALTA PRIORIDADE - Duplicação de Código

#### Task 6: Remover Handlers Duplicados em auth_credentials_controller
**Arquivo:** `lib/features/core/auth/controllers/auth_credentials_controller.dart`  
**Linhas:** 230-270

**Problema:** Métodos `_handleFirebaseLoginError` e `_handleFirebaseRegisterError` são duplicatas completas do `ErrorHandler`

**Ação:**
1. Remover método `_handleFirebaseLoginError` (linhas 230-249)
2. Remover método `_handleFirebaseRegisterError` (linhas 252-270)
3. Substituir chamadas por `ErrorHandler.getLoginErrorMessage(e)`
4. Substituir chamadas por `ErrorHandler.getRegisterErrorMessage(e)`

**Critério de Aceite:**
- [ ] Remover ambos os métodos duplicados
- [ ] Substituir todas as chamadas por ErrorHandler
- [ ] Verificar que mensagens de erro continuam funcionando
- [ ] Testar login e registro com erros diversos

---

#### Task 7: Remover 18 Wrappers Desnecessários de _handleFirestoreError
**Arquivos Afetados:**
1. `treasure_rewards_controller.dart`
2. `treasure_challenges_controller.dart`
3. `profile_settings_controller.dart`
4. `profile_social_controller.dart`
5. `profile_search_controller.dart`
6. `profile_data_controller.dart`
7. `profile_courses_controller.dart`
8. `shop_controller.dart`
9. `splash_controller.dart`
10. `leaderboard_controller.dart`
11. `energy_controller.dart`
12. `gems_controller.dart`
13. `streak_controller.dart`
14. `xp_level_controller.dart`
15. `onboarding_data_controller.dart`
16. `onboarding_validation_controller.dart`
17. `auth_providers_controller.dart`
18. (verificar se há mais)

**Ação:**
```dart
// REMOVER este método de todos os controllers:
String _handleFirestoreError(FirebaseException e) {
  return ErrorHandler.getFirestoreErrorMessage(e);
}

// SUBSTITUIR chamadas:
// ANTES
errorMessage.value = _handleFirestoreError(e);

// DEPOIS
errorMessage.value = ErrorHandler.getFirestoreErrorMessage(e);
```

**Critério de Aceite:**
- [ ] Identificar todos os controllers com wrapper
- [ ] Remover método `_handleFirestoreError` de cada um
- [ ] Substituir todas as chamadas por `ErrorHandler.getFirestoreErrorMessage(e)`
- [ ] Verificar que não quebrou nenhum error handling
- [ ] Testar que mensagens de erro continuam aparecendo

---

#### Task 8: Refatorar Handlers em profile_auth_controller
**Arquivo:** `lib/features/inners/profile/controllers/profile_auth_controller.dart`  
**Linhas:** 375-403

**Problema:** Handler `_handleFirebaseAuthError` com mensagens hardcoded

**Ação:**
1. Verificar se `ErrorHandler` tem método para esses erros
2. Se sim: remover método e usar ErrorHandler
3. Se não: adicionar keys de tradução e usar `.tr`

**Critério de Aceite:**
- [ ] Remover ou refatorar `_handleFirebaseAuthError`
- [ ] Usar ErrorHandler ou traduções
- [ ] Testar mudança de senha com erros diversos
- [ ] Verificar que mensagens estão traduzidas

---

#### Task 9: Refatorar Handlers em leaderboard_controller
**Arquivo:** `lib/features/inners/leaderboard/controllers/leaderboard_controller.dart`  
**Linhas:** 394-406

**Problema:** Handler `_handleAuthError` com mensagens hardcoded

**Ação:**
Usar `ErrorHandler.getLoginErrorMessage(e)` ou criar método específico no ErrorHandler

**Critério de Aceite:**
- [ ] Remover método `_handleAuthError`
- [ ] Usar ErrorHandler centralizado
- [ ] Testar leaderboard com erros de auth
- [ ] Verificar que mensagens estão traduzidas

---

### 📝 MÉDIA PRIORIDADE - Traduções

#### Task 10: Adicionar Keys de Tradução Faltantes
**Arquivo:** `lib/shared/translations/pt_BR.dart` (e outros idiomas)

**Keys a Adicionar:**
```dart
// Profile Search
'profile_search_title': 'Buscar usuários',
'profile_search_hint': 'Digite username ou nome',
'profile_search_empty_state': 'Busque por username ou nome',
'profile_search_no_results': 'Nenhum usuário encontrado',

// Learning Controls
'learning_controls_minutes_format': '{minutes} minutos',

// Common
'common_weekday_mon': 'Seg',
'common_weekday_tue': 'Ter',
'common_weekday_wed': 'Qua',
'common_weekday_thu': 'Qui',
'common_weekday_fri': 'Sex',
'common_weekday_sat': 'Sáb',
'common_weekday_sun': 'Dom',
'common_time_minutes_remaining': '{minutes}min restantes',
'common_time_hours_remaining': '{hours}h restantes',

// Home
'home_lesson_button_continue': 'Continuar',
'home_lesson_button_start': 'Começar',

// Errors (verificar se já existem)
'error_unauthenticated': 'Usuário não autenticado. Faça login novamente.',
'error_progress_negative': 'O progresso não pode ser negativo.',
'error_challenge_update': 'Erro ao atualizar progresso do desafio.',
'error_challenge_not_found': 'Desafio não encontrado.',
'error_challenge_completion_check': 'Erro ao verificar conclusão do desafio.',
'error_insufficient_gems': 'Você não tem gemas suficientes.',
'error_no_active_course': 'Nenhum curso ativo encontrado.',
'error_reward_already_claimed_free': 'Você já reivindicou esta recompensa.',
'error_generic': 'Ocorreu um erro. Tente novamente.',
```

**Critério de Aceite:**
- [ ] Adicionar todas as keys em pt_BR.dart
- [ ] Adicionar traduções em en_US.dart
- [ ] Adicionar traduções em es_ES.dart
- [ ] Verificar que não há keys duplicadas
- [ ] Testar que todas as keys funcionam

---

#### Task 11: Atualizar Search Users Page
**Arquivo:** `lib/features/inners/profile/views/search_users_page.dart`

**Substituir:**
- Linha 42: `'Buscar usuários'` → `'profile_search_title'.tr`
- Linha 51: `'Digite username ou nome'` → `'profile_search_hint'.tr`
- Linha 128: `'Busque por username ou nome'` → `'profile_search_empty_state'.tr`
- Linha 162: `'Nenhum usuário encontrado'` → `'profile_search_no_results'.tr`

**Critério de Aceite:**
- [ ] Substituir todos os textos hardcoded
- [ ] Verificar que import de GetX está presente
- [ ] Testar que traduções funcionam
- [ ] Testar em múltiplos idiomas

---

#### Task 12: Atualizar Learning Controls Page
**Arquivo:** `lib/features/inners/profile/views/learning_controls_page.dart`  
**Linha:** 195

**Substituir:**
```dart
// ANTES
title: Text('$minutes minutos'),

// DEPOIS
title: Text('learning_controls_minutes_format'.trParams({
  'minutes': minutes.toString(),
})),
```

**Critério de Aceite:**
- [ ] Substituir texto hardcoded
- [ ] Testar que formato funciona
- [ ] Testar em múltiplos idiomas

---

#### Task 13: Refatorar Treasure Challenges Controller
**Arquivo:** `lib/features/inners/treasure/controllers/treasure_challenges_controller.dart`

**Substituir 11+ mensagens hardcoded:**
- Linha 37, 66: `'Usuário não autenticado...'` → `'error_unauthenticated'.tr`
- Linha 60: `'O progresso não pode ser negativo.'` → `'error_progress_negative'.tr`
- Linha 119: `'Erro ao atualizar...'` → `'error_challenge_update'.tr`
- Linha 132: `'Desafio não encontrado.'` → `'error_challenge_not_found'.tr`
- Linha 141: `'Erro ao verificar...'` → `'error_challenge_completion_check'.tr`
- Linhas 209-231: Mensagens de validação → usar keys de tradução

**Critério de Aceite:**
- [ ] Substituir todas as mensagens hardcoded
- [ ] Adicionar keys de tradução necessárias
- [ ] Testar todos os fluxos de erro
- [ ] Verificar traduções em múltiplos idiomas

---

#### Task 14: Refatorar Shop Controller
**Arquivo:** `lib/features/inners/shop/controllers/shop_controller.dart`

**Substituir 13+ mensagens hardcoded:**
- Linhas 112, 146, 181, 220: `'Você não tem gemas suficientes.'` → `'error_insufficient_gems'.tr`
- Linha 254: `'Usuário não autenticado.'` → `'error_unauthenticated'.tr`
- Linha 259: `'Você já reivindicou...'` → `'error_reward_already_claimed_free'.tr`
- Linha 274: `'Nenhum curso ativo...'` → `'error_no_active_course'.tr`
- Outras mensagens de erro → usar keys apropriadas

**Critério de Aceite:**
- [ ] Substituir todas as mensagens hardcoded
- [ ] Verificar que keys já existem ou adicionar
- [ ] Testar todos os fluxos de compra
- [ ] Testar erros diversos

---

#### Task 15: Refatorar Profile Controllers (6 arquivos)
**Arquivos:**
1. `profile_auth_controller.dart` - 6+ mensagens
2. `profile_search_controller.dart` - 3 mensagens
3. `profile_settings_controller.dart` - 4 mensagens
4. `profile_data_controller.dart` - 5 mensagens
5. `profile_courses_controller.dart` - 2 mensagens
6. `profile_social_controller.dart` - weekdays

**Ação:** Substituir todas as mensagens hardcoded por keys de tradução

**Critério de Aceite:**
- [ ] Refatorar profile_auth_controller
- [ ] Refatorar profile_search_controller
- [ ] Refatorar profile_settings_controller
- [ ] Refatorar profile_data_controller
- [ ] Refatorar profile_courses_controller
- [ ] Refatorar profile_social_controller (weekdays)
- [ ] Testar todos os fluxos de perfil
- [ ] Verificar traduções

---

#### Task 16: Refatorar Home Stats Controller
**Arquivo:** `lib/features/inners/home/controllers/home_stats_controller.dart`  
**Linhas:** 528-533

**Substituir:**
```dart
// ANTES
if (completedCountInButton > 0) {
  return 'Continuar';
}
return 'Começar';

// DEPOIS
if (completedCountInButton > 0) {
  return 'home_lesson_button_continue'.tr;
}
return 'home_lesson_button_start'.tr;
```

**Critério de Aceite:**
- [ ] Substituir textos hardcoded
- [ ] Testar botões de lição
- [ ] Verificar traduções

---

#### Task 17: Refatorar Gamification Controllers (2 arquivos)
**Arquivos:**
1. `xp_level_controller.dart` (linhas 44-56)
2. `gems_controller.dart` (linhas 45-55)

**Substituir:**
```dart
// ANTES
if (diff.inMinutes < 60) {
  return '${diff.inMinutes}min restantes';
} else {
  return '${diff.inHours}h restantes';
}

// DEPOIS
if (diff.inMinutes < 60) {
  return 'common_time_minutes_remaining'.trParams({
    'minutes': diff.inMinutes.toString(),
  });
} else {
  return 'common_time_hours_remaining'.trParams({
    'hours': diff.inHours.toString(),
  });
}
```

**Critério de Aceite:**
- [ ] Refatorar xp_level_controller
- [ ] Refatorar gems_controller
- [ ] Testar tempo restante de boosters
- [ ] Verificar traduções

---

### 🔧 BAIXA PRIORIDADE - Melhorias

#### Task 18: Implementar Cache para Evitar Refresh Desnecessário
**Arquivo:** `lib/features/inners/home/controllers/home_navigation_controller.dart`

**Problema:** Reload em cada troca de tab

**Ação:** Implementar stale-while-revalidate pattern

**Critério de Aceite:**
- [ ] Implementar cache com timestamp
- [ ] Apenas recarregar se dados estiverem stale (ex: > 5 minutos)
- [ ] Testar que não há reload desnecessário
- [ ] Verificar que dados são atualizados quando necessário

---

#### Task 19: Melhorar Validação de Dados de Exercícios
**Arquivo:** `lib/features/core/lesson/controllers/lesson_flow_controller.dart`  
**Linha:** 265

**Ação:** Validar estrutura completa dos dados de exercício

**Critério de Aceite:**
- [ ] Validar todos os campos obrigatórios
- [ ] Validar tipos de dados
- [ ] Adicionar logs para debug
- [ ] Testar com dados inválidos

---

#### Task 20: Corrigir Progress Display Bug
**Arquivo:** `lib/features/core/lesson/widgets/section_card.dart`  
**Linhas:** 252-256

**Problema:** Mostra `{current}/{total}` ao invés dos valores reais

**Ação:** Verificar implementação e valores sendo passados

**Critério de Aceite:**
- [ ] Identificar causa raiz
- [ ] Corrigir implementação
- [ ] Testar que valores corretos são exibidos
- [ ] Verificar em múltiplas seções

---

### 📚 INFRAESTRUTURA

#### Task 21: Documentar Padrão de ErrorHandler
**Arquivo:** Criar `docs/error-handling-pattern.md`

**Conteúdo:**
- Como usar ErrorHandler centralizado
- Quando criar novos métodos no ErrorHandler
- Padrão de try-catch obrigatório
- Exemplos de uso correto

**Critério de Aceite:**
- [ ] Criar documentação completa
- [ ] Adicionar exemplos de código
- [ ] Documentar anti-patterns
- [ ] Revisar com equipe

---

#### Task 22: Criar Auth Helper
**Arquivo:** Criar `lib/shared/utils/auth_helper.dart`

**Conteúdo:**
```dart
class AuthHelper {
  static User? getAuthenticatedUser(FirebaseAuth auth) {
    final user = auth.currentUser;
    if (user == null || user.uid.isEmpty) {
      return null;
    }
    return user;
  }
  
  static String getUserId(FirebaseAuth auth) {
    final user = getAuthenticatedUser(auth);
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }
}
```

**Critério de Aceite:**
- [ ] Criar helper com métodos úteis
- [ ] Adicionar testes unitários
- [ ] Documentar uso
- [ ] Refatorar controllers para usar helper

---

## Ordem de Execução

1. **Fase 1 - URGENTE** (Tasks 1-5): Corrigir bugs críticos
2. **Fase 2 - ALTA** (Tasks 6-9): Remover duplicação
3. **Fase 3 - MÉDIA** (Tasks 10-17): Traduções
4. **Fase 4 - BAIXA** (Tasks 18-20): Melhorias
5. **Fase 5 - INFRA** (Tasks 21-22): Infraestrutura

---

## Critérios de Sucesso

- [ ] Todos os bugs URGENTES corrigidos
- [ ] Nenhum handler duplicado no código
- [ ] Nenhum texto hardcoded (exceto constantes técnicas)
- [ ] Todos os controllers implementam `onClose()`
- [ ] Todas as operações Firestore têm try-catch
- [ ] App não crasha em cenários de erro
- [ ] Traduções funcionam em todos os idiomas
- [ ] Performance melhorada (sem reloads desnecessários)
- [ ] Documentação atualizada

---

## Notas

- Sempre testar após cada task
- Commitar após cada fase completa
- Revisar código antes de prosseguir
- Manter padrões da empresa (`.kiro/steering/`)
- Usar `getDiagnostics` para verificar erros
- Nunca usar `!` operator sem verificação
- Sempre usar `.tr` para textos do usuário
