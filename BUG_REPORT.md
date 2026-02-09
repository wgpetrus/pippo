# Bug Report - Pippo App

> Análise completa de bugs identificados no projeto

---

## 🐛 Bugs Críticos

### 1. **Progress Display Bug - Section Card**
**Localização:** `lib/features/core/lesson/widgets/section_card.dart` (linha 252-256)

**Problema:** O progresso está sendo exibido como texto literal `{current}/{total}` ao invés dos valores reais.

**Causa:** O método `.trParams()` está sendo usado corretamente, mas pode haver um problema com a implementação ou os valores não estão sendo substituídos.

**Código Atual:**
```dart
Text(
  'lesson_section_progress_format'.trParams({
    'current': currentProgress.toString(),
    'total': totalProgress.toString(),
  }),
  style: AppTheme.textSmBold.copyWith(color: AppTheme.white),
),
```

**Status:** ✅ O código está correto. O bug pode estar na implementação do GetX ou nos valores sendo passados.

**Solução Recomendada:** Verificar se os valores `currentProgress` e `totalProgress` estão sendo passados corretamente ao widget.

---

## 🌐 Bugs de Tradução (Hardcoded Text)

### 2. **Search Users Page - Hardcoded Text**
**Localização:** `lib/features/inners/profile/views/search_users_page.dart`

**Textos Hardcoded:**
- Linha 42: `'Buscar usuários'` (AppBar title)
- Linha 51: `'Digite username ou nome'` (hintText)
- Linha 128: `'Busque por username ou nome'` (empty state)
- Linha 162: `'Nenhum usuário encontrado'` (no results)

**Solução:**
```dart
// Adicionar às traduções:
'profile_search_title': 'Buscar usuários',
'profile_search_hint': 'Digite username ou nome',
'profile_search_empty_state': 'Busque por username ou nome',
'profile_search_no_results': 'Nenhum usuário encontrado',

// Atualizar código:
appBar: AppAppbar(title: 'profile_search_title'.tr),
hintText: 'profile_search_hint'.tr,
Text('profile_search_empty_state'.tr, ...),
Text('profile_search_no_results'.tr, ...),
```

---

### 3. **Learning Controls Page - Hardcoded Minutes**
**Localização:** `lib/features/inners/profile/views/learning_controls_page.dart` (linha 195)

**Problema:**
```dart
title: Text('$minutes minutos'),
```

**Solução:**
```dart
// Adicionar à tradução:
'learning_controls_minutes_format': '{minutes} minutos',

// Atualizar código:
title: Text('learning_controls_minutes_format'.trParams({
  'minutes': minutes.toString(),
})),
```

---

### 4. **Controllers - Hardcoded Error Messages**

#### 4.1 Treasure Challenges Controller
**Localização:** `lib/features/inners/treasure/controllers/treasure_challenges_controller.dart`

**Mensagens Hardcoded:**
- Linha 37: `'Usuário não autenticado. Faça login novamente.'`
- Linha 60: `'O progresso não pode ser negativo.'`
- Linha 66: `'Usuário não autenticado. Faça login novamente.'`
- Linha 119: `'Erro ao atualizar progresso do desafio.'`
- Linha 132: `'Desafio não encontrado.'`
- Linha 141: `'Erro ao verificar conclusão do desafio.'`
- Linhas 209-231: Mensagens de validação

**Solução:** Adicionar keys de tradução:
```dart
'error_unauthenticated': 'Usuário não autenticado. Faça login novamente.',
'error_progress_negative': 'O progresso não pode ser negativo.',
'error_challenge_update': 'Erro ao atualizar progresso do desafio.',
'error_challenge_not_found': 'Desafio não encontrado.',
'error_challenge_completion_check': 'Erro ao verificar conclusão do desafio.',
'error_validation_required_fields': 'Todos os campos obrigatórios devem ser preenchidos.',
'error_validation_goal_positive': 'O objetivo deve ser um número positivo.',
'error_validation_reward_positive': 'A recompensa deve ser um valor positivo.',
'error_validation_reward_type': 'Tipo de recompensa inválido.',
'error_validation_progress_zero': 'O progresso inicial deve ser zero.',
```

#### 4.2 Shop Controller
**Localização:** `lib/features/inners/shop/controllers/shop_controller.dart`

**Mensagens Hardcoded:**
- Linha 112: `'Você não tem gemas suficientes.'`
- Linha 133: `'Erro ao comprar recarga de energia. Tente novamente.'`
- Linha 146: `'Você não tem gemas suficientes.'`
- Linha 162: `'Erro ao comprar XP booster. Tente novamente.'`
- Linha 181: `'Você não tem gemas suficientes.'`
- Linha 199: `'Erro ao comprar multiplicador de gemas. Tente novamente.'`
- Linha 220: `'Você não tem gemas suficientes.'`
- Linha 238: `'Erro ao comprar proteção de streak. Tente novamente.'`
- Linha 254: `'Usuário não autenticado.'`
- Linha 259: `'Você já reivindicou esta recompensa.'`
- Linha 274: `'Nenhum curso ativo encontrado.'`
- Linha 314: `'Erro ao reivindicar recompensa. Tente novamente.'`
- Linha 318: `'Erro ao reivindicar recompensa. Tente novamente.'`

**Nota:** Algumas dessas mensagens já têm keys de tradução disponíveis (`error_insufficient_gems`, `error_no_active_course`, `error_reward_already_claimed_free`), mas não estão sendo usadas.

#### 4.3 Profile Auth Controller
**Localização:** `lib/features/inners/profile/controllers/profile_auth_controller.dart`

**Mensagens Hardcoded:**
- Linha 43: `'Usuário não autenticado.'`
- Linha 68: `'Erro ao alterar senha. Tente novamente.'`
- Linha 85: `'Usuário não autenticado.'`
- Linha 115: `'Erro ao vincular telefone. Tente novamente.'`
- Linha 129: `'Usuário não autenticado.'`
- Linha 177: `'Erro ao deletar conta. Tente novamente.'`
- Linhas 378-401: Mensagens de erro Firebase (devem usar handler padronizado)

#### 4.4 Profile Search Controller
**Localização:** `lib/features/inners/profile/controllers/profile_search_controller.dart`

**Mensagens Hardcoded:**
- Linha 40: `'Usuário não autenticado.'`
- Linha 78: `'Nenhum usuário encontrado.'`
- Linha 83: `'Erro ao buscar usuários. Tente novamente.'`

#### 4.5 Profile Settings Controller
**Localização:** `lib/features/inners/profile/controllers/profile_settings_controller.dart`

**Mensagens Hardcoded:**
- Linha 46: `'Usuário não autenticado.'`
- Linha 77: `'Erro ao carregar configurações. Tente novamente.'`
- Linha 88: `'Usuário não autenticado.'`
- Linha 129: `'Erro ao atualizar configuração. Tente novamente.'`

#### 4.6 Profile Data Controller
**Localização:** `lib/features/inners/profile/controllers/profile_data_controller.dart`

**Mensagens Hardcoded:**
- Linha 59: `'Usuário não autenticado.'`
- Linha 71: `'Perfil não encontrado.'`
- Linha 122: `'Erro ao carregar perfil. Tente novamente.'`
- Linha 136: `'Usuário não autenticado.'`
- Linha 176: `'Erro ao atualizar perfil. Tente novamente.'`

#### 4.7 Profile Courses Controller
**Localização:** `lib/features/inners/profile/controllers/profile_courses_controller.dart`

**Mensagens Hardcoded:**
- Linha 48: `'Usuário não autenticado.'`
- Linha 86: `'Erro ao carregar cursos. Tente novamente.'`

---

### 5. **Profile Social Controller - Hardcoded Weekday Names**
**Localização:** `lib/features/inners/profile/controllers/profile_social_controller.dart` (linhas 576-593)

**Problema:**
```dart
switch (weekday) {
  case 1: return 'Seg';
  case 2: return 'Ter';
  case 3: return 'Qua';
  case 4: return 'Qui';
  case 5: return 'Sex';
  case 6: return 'Sáb';
  case 7: return 'Dom';
  default: return '';
}
```

**Solução:**
```dart
// Adicionar às traduções:
'common_weekday_mon': 'Seg',
'common_weekday_tue': 'Ter',
'common_weekday_wed': 'Qua',
'common_weekday_thu': 'Qui',
'common_weekday_fri': 'Sex',
'common_weekday_sat': 'Sáb',
'common_weekday_sun': 'Dom',

// Atualizar código:
String _getWeekdayLabel(int weekday) {
  final keys = [
    'common_weekday_mon',
    'common_weekday_tue',
    'common_weekday_wed',
    'common_weekday_thu',
    'common_weekday_fri',
    'common_weekday_sat',
    'common_weekday_sun',
  ];
  if (weekday >= 1 && weekday <= 7) {
    return keys[weekday - 1].tr;
  }
  return '';
}
```

---

### 6. **Home Stats Controller - Hardcoded Button Text**
**Localização:** `lib/features/inners/home/controllers/home_stats_controller.dart` (linhas 528-533)

**Problema:**
```dart
if (completedCountInButton > 0) {
  return 'Continuar';
}
return 'Começar';
```

**Solução:**
```dart
// Adicionar às traduções:
'home_lesson_button_continue': 'Continuar',
'home_lesson_button_start': 'Começar',

// Atualizar código:
if (completedCountInButton > 0) {
  return 'home_lesson_button_continue'.tr;
}
return 'home_lesson_button_start'.tr;
```

---

### 7. **Gamification Controllers - Hardcoded Time Remaining**

#### 7.1 XP Level Controller
**Localização:** `lib/features/inners/gamification/controllers/xp_level_controller.dart` (linhas 44-56)

**Problema:**
```dart
if (diff.inMinutes < 60) {
  return '${diff.inMinutes}min restantes';
} else {
  return '${diff.inHours}h restantes';
}
```

**Solução:**
```dart
// Adicionar às traduções:
'common_time_minutes_remaining': '{minutes}min restantes',
'common_time_hours_remaining': '{hours}h restantes',

// Atualizar código:
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

#### 7.2 Gems Controller
**Localização:** `lib/features/inners/gamification/controllers/gems_controller.dart` (linhas 45-55)

**Mesmo problema e solução do XP Level Controller.**

---

### 8. **Leaderboard Controller - Hardcoded Error Messages**
**Localização:** `lib/features/inners/leaderboard/controllers/leaderboard_controller.dart` (linhas 397-405)

**Mensagens Hardcoded:**
- Linha 397: `'Usuário não encontrado.'`
- Linha 399: `'Verifique sua conexão com a internet.'`
- Linha 401: `'Muitas tentativas. Aguarde alguns minutos e tente novamente.'`
- Linha 403: `'Erro de autenticação. Faça login novamente.'`

**Nota:** Essas mensagens devem usar o handler padronizado de Firebase Auth definido em `firebase.md`.

---

## � BUGS CRÍTICOS ADICIONAeIS

### 16. **CRÍTICO: Null Pointer Exception em Splash Controller**
**Localização:** `lib/features/inners/splash/controllers/splash_controller.dart` (linha 77)

**Problema:**
```dart
final userId = _auth.currentUser!.uid;  // ❌ Uso de ! sem verificação
```

**Impacto:** App pode crashar no splash se o Firebase Auth não estiver pronto.

**Solução:**
```dart
final user = _auth.currentUser;
if (user == null) {
  errorMessage.value = 'error_unauthenticated'.tr;
  _navigateToAuth();
  return;
}
final userId = user.uid;
```

---

### 17. **CRÍTICO: Race Condition ao Iniciar Lição**
**Localização:** `lib/features/core/lesson/controllers/lesson_flow_controller.dart`

**Problema:** Múltiplas verificações de `_auth.currentUser` com delays de 100ms podem causar race conditions se o usuário clicar rapidamente.

**Código Problemático:**
```dart
// Linha 69-70
await Future.delayed(const Duration(milliseconds: 100));
final user = _auth.currentUser;
if (user == null) {
  errorMessage.value = 'Usuário não autenticado.';
  return;
}
```

**Impacto:** 
- Usuário pode clicar em uma lição e receber erro "Usuário não autenticado" mesmo estando logado
- Delay artificial de 100ms em cada verificação degrada performance
- Flag `_isLessonStarting` não previne completamente race conditions

**Solução:**
1. Verificar autenticação UMA VEZ no início do método
2. Remover delays artificiais
3. Usar `authStateChanges()` stream para garantir estado consistente
4. Adicionar verificação no binding/onInit ao invés de em cada método

---

### 18. **CRÍTICO: Falta de Tratamento de Erros em Operações Firestore**
**Localização:** Múltiplos controllers

**Problema:** Operações Firestore sem try-catch podem crashar o app.

**Exemplos:**
```dart
// profile_data_controller.dart (linha 149)
await _firestore.collection('users').doc(userId).update(updates);  // ❌ Sem try-catch

// profile_social_controller.dart (linha 55)
final userDoc = await _firestore.collection('users').doc(userId).get();  // ❌ Sem try-catch

// profile_auth_controller.dart (linha 139)
await _firestore.collection('users').doc(userId).delete();  // ❌ Sem try-catch
```

**Impacto:** App pode crashar silenciosamente em caso de erro de rede ou permissão.

**Solução:** Envolver TODAS as operações Firestore em try-catch com handler padronizado.

---

### 19. **Memory Leak: Controllers Não Limpam Recursos**
**Localização:** Múltiplos controllers

**Problema:** Controllers não implementam `onClose()` para limpar recursos.

**Impacto:**
- Memory leaks ao navegar entre telas
- Listeners ativos mesmo após controller ser destruído
- Performance degradada ao longo do tempo

**Controllers Afetados:**
- `HomeNavigationController` - não limpa estados
- `ProfileSocialController` - não limpa listas
- `TreasureChallengesController` - não limpa challenges
- Todos os controllers de gamificação

**Solução:**
```dart
@override
void onClose() {
  // Limpar listas observáveis
  challenges.clear();
  
  // Resetar estados
  currentNavIndex.value = 0;
  
  // Cancelar timers/listeners se houver
  
  super.onClose();
}
```

---

### 20. **Concurrency Issue: Múltiplas Atualizações Simultâneas**
**Localização:** Controllers de gamificação

**Problema:** Múltiplos controllers podem atualizar o mesmo documento Firestore simultaneamente, causando perda de dados.

**Exemplo:**
```dart
// energy_controller.dart atualiza stats/gamification
await _firestore.collection('users').doc(userId).collection('stats').doc('gamification').update({...});

// gems_controller.dart atualiza o MESMO documento
await _firestore.collection('users').doc(userId).collection('stats').doc('gamification').update({...});

// xp_level_controller.dart atualiza o MESMO documento
await _firestore.collection('users').doc(userId).collection('stats').doc('gamification').update({...});
```

**Impacto:** 
- Última atualização sobrescreve as anteriores
- Perda de dados de energia/gems/xp
- Inconsistência entre UI e Firestore

**Solução:** Usar Firestore Transactions ou FieldValue.increment() para operações atômicas.

---

### 21. **Bug de Navegação: Refresh Desnecessário**
**Localização:** `lib/features/inners/home/controllers/home_navigation_controller.dart` (linhas 28-37)

**Problema:**
```dart
void onNavTap(int index) {
  final previousIndex = currentNavIndex.value;
  currentNavIndex.value = index;
  
  // Se navegando para a tab Treasure (index 3), recarregar desafios
  if (index == 3 && previousIndex != 3) {
    _refreshTreasurePage();  // ❌ Reload desnecessário
  }
  
  // Se navegando para a tab Profile (index 4), recarregar perfil
  if (index == 4 && previousIndex != 4) {
    _refreshProfilePage();  // ❌ Reload desnecessário
  }
}
```

**Impacto:**
- Performance ruim ao trocar de tabs
- Requisições Firestore desnecessárias
- Usuário vê loading toda vez que troca de tab

**Solução:** Usar cache e apenas recarregar quando dados estiverem desatualizados (stale-while-revalidate pattern).

---

### 22. **Bug de Validação: Dados de Exercício Não Validados**
**Localização:** `lib/features/core/lesson/controllers/lesson_flow_controller.dart` (linha 265)

**Problema:** Validação de exercícios é muito permissiva e pode aceitar dados inválidos.

**Código:**
```dart
bool _validateExerciseData() {
  if (currentExercises.isEmpty) return false;
  
  for (final exercise in currentExercises) {
    final type = exercise['type'] as String?;
    final order = exercise['order'] as int?;
    
    // ❌ Não valida se 'type' é null antes de usar contains()
    if (type == null || !['image', 'translation', 'word_order', 'match'].contains(type)) {
      return false;
    }
    
    // ❌ Não valida estrutura completa dos dados
  }
  
  return true;
}
```

**Impacto:** App pode crashar ao tentar renderizar exercício com dados inválidos.

---

### 23. **Bug de Estado: Flag de Concorrência Não Resetada em Erro**
**Localização:** `lib/features/core/lesson/controllers/lesson_flow_controller.dart` (linha 244)

**Problema:** Flag `_isLessonStarting` pode ficar travada em `true` se houver erro.

**Código Original:**
```dart
Future<void> startLesson(String courseId, String lessonId) async {
  if (_isLessonStarting) {
    errorMessage.value = 'Uma lição já está sendo iniciada. Aguarde.';
    return;
  }

  _isLessonStarting = true;
  // ... código ...
  
  // ✅ CORREÇÃO JÁ APLICADA: finally sempre reseta flag
  finally {
    _isLessonStarting = false;
    isLoading.value = false;
  }
}
```

**Status:** ✅ **JÁ CORRIGIDO** no código atual.

---

## 📋 Resumo de Bugs por Categoria

### Críticos (Funcionalidade Quebrada)
1. ✅ Progress display mostrando `{current}/{total}` - **VERIFICAR IMPLEMENTAÇÃO**
2. 🔥 **Null pointer exception em Splash Controller** - linha 77
3. 🔥 **Race condition ao iniciar lição** - múltiplas verificações de auth
4. 🔥 **Falta de tratamento de erros Firestore** - múltiplos controllers
5. 🔥 **Memory leaks** - controllers não limpam recursos
6. 🔥 **Concurrency issues** - múltiplas atualizações simultâneas
7. ⚠️ **Refresh desnecessário** - reload em cada troca de tab
8. ⚠️ **Validação fraca de exercícios** - pode aceitar dados inválidos

### Tradução (Hardcoded Text)
9. Search Users Page - 4 textos hardcoded
10. Learning Controls Page - formato de minutos
11. Treasure Challenges Controller - 11+ mensagens
12. Shop Controller - 13+ mensagens
13. Profile Auth Controller - 6+ mensagens + handler Firebase
14. Profile Search Controller - 3 mensagens
15. Profile Settings Controller - 4 mensagens
16. Profile Data Controller - 5 mensagens
17. Profile Courses Controller - 2 mensagens
18. Profile Social Controller - dias da semana
19. Home Stats Controller - botões "Continuar"/"Começar"
20. XP Level Controller - tempo restante
21. Gems Controller - tempo restante
22. Leaderboard Controller - mensagens de erro Firebase

### Total de Bugs Identificados: **23 categorias** (8 críticos + 15 tradução)

---

## 🔄 BUGS ADICIONAIS IDENTIFICADOS

### 24. **Handlers Duplicados em auth_credentials_controller.dart**
**Localização:** `lib/features/core/auth/controllers/auth_credentials_controller.dart` (linhas 230-270)

**Problema:** O controller define handlers `_handleFirebaseLoginError` e `_handleFirebaseRegisterError` que são **DUPLICATAS** dos handlers já existentes no `ErrorHandler` centralizado.

**Código Duplicado:**
```dart
// ❌ DUPLICADO - linhas 230-249
String _handleFirebaseLoginError(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return 'Não encontramos uma conta com este e-mail.';
    case 'wrong-password':
      return 'Senha incorreta. Verifique e tente novamente.';
    // ... mais casos
  }
}

// ❌ DUPLICADO - linhas 252-270
String _handleFirebaseRegisterError(FirebaseAuthException e) {
  switch (e.code) {
    case 'email-already-in-use':
      return 'Este e-mail já está sendo usado por outra conta.';
    // ... mais casos
  }
}
```

**Impacto:**
- Código duplicado e difícil de manter
- Mensagens hardcoded ao invés de usar traduções
- Inconsistência com o padrão centralizado

**Solução:**
```dart
// ✅ CORRETO - usar ErrorHandler centralizado
} on FirebaseAuthException catch (e) {
  errorMessage.value = ErrorHandler.getLoginErrorMessage(e);
}

// ✅ CORRETO - para registro
} on FirebaseAuthException catch (e) {
  errorMessage.value = ErrorHandler.getRegisterErrorMessage(e);
}

// REMOVER os métodos _handleFirebaseLoginError e _handleFirebaseRegisterError
```

---

### 25. **Handlers Duplicados em profile_auth_controller.dart**
**Localização:** `lib/features/inners/profile/controllers/profile_auth_controller.dart` (linhas 375-403)

**Problema:** Handler `_handleFirebaseAuthError` com mensagens hardcoded.

**Código Problemático:**
```dart
// ❌ MENSAGENS HARDCODED
String _handleFirebaseAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'wrong-password':
      return 'Senha atual incorreta.';
    case 'weak-password':
      return 'A nova senha é muito fraca. Use pelo menos 6 caracteres.';
    case 'network-request-failed':
      return 'Verifique sua conexão com a internet.';
    case 'too-many-requests':
      return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
    // ... mais casos hardcoded
  }
}
```

**Solução:** Usar `ErrorHandler` centralizado ou adicionar keys de tradução.

---

### 26. **Handlers Duplicados em leaderboard_controller.dart**
**Localização:** `lib/features/inners/leaderboard/controllers/leaderboard_controller.dart` (linhas 394-406)

**Problema:** Handler `_handleAuthError` com mensagens hardcoded.

**Código Problemático:**
```dart
String _handleAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return 'Usuário não encontrado.';
    case 'network-request-failed':
      return 'Verifique sua conexão com a internet.';
    case 'too-many-requests':
      return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
    default:
      return 'Erro de autenticação. Faça login novamente.';
  }
}
```

**Solução:** Usar `ErrorHandler.getLoginErrorMessage(e)` ou criar método específico no ErrorHandler.

---

### 27. **Handlers Wrapper Desnecessários**
**Localização:** Múltiplos controllers

**Problema:** 18 controllers definem métodos `_handleFirestoreError` que apenas chamam `ErrorHandler.getFirestoreErrorMessage(e)`.

**Código Desnecessário:**
```dart
// ❌ WRAPPER DESNECESSÁRIO
String _handleFirestoreError(FirebaseException e) {
  return ErrorHandler.getFirestoreErrorMessage(e);
}
```

**Controllers Afetados:**
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

**Solução:** Chamar `ErrorHandler.getFirestoreErrorMessage(e)` diretamente.

```dart
// ANTES
} on FirebaseException catch (e) {
  errorMessage.value = _handleFirestoreError(e);
}

String _handleFirestoreError(FirebaseException e) {
  return ErrorHandler.getFirestoreErrorMessage(e);
}

// DEPOIS
} on FirebaseException catch (e) {
  errorMessage.value = ErrorHandler.getFirestoreErrorMessage(e);
}

// REMOVER o método _handleFirestoreError
```

---

### 28. **Imports de GetX Verificados**
**Status:** ✅ **TODOS OS ARQUIVOS TÊM IMPORT CORRETO**

**Verificação Realizada:**
- Todos os arquivos que usam `.tr` já têm `import 'package:get/get.dart';`
- `error_handler.dart` ✅ tem import
- `validation_helper.dart` ✅ tem import
- Todas as views e pages ✅ têm import

**Nenhuma ação necessária para imports.**

---

## 📋 Resumo Atualizado de Bugs por Categoria

### Críticos (Funcionalidade Quebrada)
1. ✅ Progress display mostrando `{current}/{total}` - **VERIFICAR IMPLEMENTAÇÃO**
2. 🔥 **Null pointer exception em Splash Controller** - linha 77
3. 🔥 **Race condition ao iniciar lição** - múltiplas verificações de auth
4. 🔥 **Falta de tratamento de erros Firestore** - múltiplos controllers
5. 🔥 **Memory leaks** - controllers não limpam recursos
6. 🔥 **Concurrency issues** - múltiplas atualizações simultâneas
7. ⚠️ **Refresh desnecessário** - reload em cada troca de tab
8. ⚠️ **Validação fraca de exercícios** - pode aceitar dados inválidos

### Código Duplicado / Manutenibilidade
9. 🔄 **Handlers duplicados em auth_credentials_controller** - 2 métodos completos
10. 🔄 **Handlers com mensagens hardcoded em profile_auth_controller**
11. 🔄 **Handlers com mensagens hardcoded em leaderboard_controller**
12. 🔄 **18 wrappers desnecessários de _handleFirestoreError**

### Tradução (Hardcoded Text)
13. Search Users Page - 4 textos hardcoded
14. Learning Controls Page - formato de minutos
15. Treasure Challenges Controller - 11+ mensagens
16. Shop Controller - 13+ mensagens
17. Profile Auth Controller - 6+ mensagens + handler Firebase
18. Profile Search Controller - 3 mensagens
19. Profile Settings Controller - 4 mensagens
20. Profile Data Controller - 5 mensagens
21. Profile Courses Controller - 2 mensagens
22. Profile Social Controller - dias da semana
23. Home Stats Controller - botões "Continuar"/"Começar"
24. XP Level Controller - tempo restante
25. Gems Controller - tempo restante
26. Leaderboard Controller - mensagens de erro Firebase
27. Auth Credentials Controller - handlers duplicados com mensagens hardcoded

### Total de Bugs Identificados: **28 categorias** (8 críticos + 4 duplicação + 16 tradução)

---

## 🔧 Prioridade de Correção

### 🔥 URGENTE (Podem Crashar o App)
1. **Null pointer exception em Splash** - Linha 77, uso de `!` sem verificação
2. **Race condition ao iniciar lição** - Usuário não autenticado mesmo logado
3. **Falta de try-catch em Firestore** - App pode crashar silenciosamente
4. **Concurrency issues** - Perda de dados por atualizações simultâneas

### Alta Prioridade
5. **Memory leaks** - Performance degrada ao longo do tempo
6. **Handlers duplicados em auth_credentials_controller** - Remover duplicatas
7. **18 wrappers desnecessários** - Chamar ErrorHandler diretamente
8. **Handlers hardcoded em profile_auth_controller** - Usar ErrorHandler ou .tr
9. **Handlers hardcoded em leaderboard_controller** - Usar ErrorHandler
10. **Progress Display Bug** - Afeta UX diretamente
11. **Controllers com mensagens hardcoded** - Quebra internacionalização
12. **Search Users Page** - Página completamente sem tradução

### Média Prioridade
13. **Refresh desnecessário** - Performance ruim ao trocar tabs
14. **Validação fraca de exercícios** - Pode aceitar dados inválidos
15. **Learning Controls** - Formato de minutos
16. **Weekday names** - Dias da semana
17. **Time remaining** - Tempo restante de boosters

### Baixa Prioridade
18. **Button text** - "Continuar"/"Começar" (menos visível)

---

## 📝 Recomendações

### Correções Imediatas (Urgentes)

1. **Corrigir Splash Controller**
```dart
// ANTES (linha 77)
final userId = _auth.currentUser!.uid;  // ❌ CRASHAR SE NULL

// DEPOIS
final user = _auth.currentUser;
if (user == null) {
  errorMessage.value = 'error_unauthenticated'.tr;
  _navigateToAuth();
  return;
}
final userId = user.uid;
```

2. **Refatorar Verificação de Autenticação em Lesson Flow**
```dart
// Criar método helper no início da classe
User? _getAuthenticatedUser() {
  final user = _auth.currentUser;
  if (user == null || user.uid.isEmpty) {
    errorMessage.value = 'error_unauthenticated'.tr;
    return null;
  }
  return user;
}

// Usar em todos os métodos
Future<void> startLesson(String courseId, String lessonId) async {
  final user = _getAuthenticatedUser();
  if (user == null) return;
  
  final userId = user.uid;
  // ... resto do código
}
```

3. **Adicionar Try-Catch em TODAS Operações Firestore**
```dart
// Padrão obrigatório
try {
  await _firestore.collection('users').doc(userId).update(updates);
} on FirebaseException catch (e) {
  errorMessage.value = _handleFirestoreError(e);
} catch (e) {
  errorMessage.value = 'error_generic'.tr;
}
```

4. **Implementar onClose() em Todos Controllers**
```dart
@override
void onClose() {
  // Limpar listas
  challenges.clear();
  searchResults.clear();
  
  // Resetar estados
  currentNavIndex.value = 0;
  isLoading.value = false;
  errorMessage.value = '';
  
  super.onClose();
}
```

5. **Usar Transactions para Atualizações Concorrentes**
```dart
// ANTES - múltiplos updates podem conflitar
await energyDoc.update({'currentEnergy': newValue});
await gemsDoc.update({'gems': newGems});

// DEPOIS - transaction atômica
await _firestore.runTransaction((transaction) async {
  transaction.update(statsDoc, {
    'energy.currentEnergy': newEnergy,
    'gems.gems': newGems,
    'xp.totalXp': newXp,
  });
});
```

### Melhorias de Arquitetura

6. **Criar arquivo de error messages padronizado** em `shared/utils/error_handler.dart` com todas as mensagens traduzidas
7. **Usar handlers Firebase padronizados** conforme definido em `.kiro/steering/firebase.md`
8. **Implementar cache com stale-while-revalidate** para evitar reloads desnecessários
9. **Adicionar hook de validação** para detectar texto hardcoded em PRs
10. **Revisar todos os controllers** sistematicamente para garantir uso de `.tr`
11. **Criar constantes para keys de tradução** para evitar typos
12. **Implementar AuthStateListener** para garantir estado consistente de autenticação

### Padrões a Seguir

13. **Verificação de Autenticação**
```dart
// ✅ CORRETO
final user = _auth.currentUser;
if (user == null) {
  errorMessage.value = 'error_unauthenticated'.tr;
  return;
}
final userId = user.uid;

// ❌ ERRADO
final userId = _auth.currentUser!.uid;  // Pode crashar
final userId = _auth.currentUser?.uid;  // Pode ser null
```

14. **Operações Firestore**
```dart
// ✅ CORRETO
try {
  await _firestore.collection('users').doc(userId).update(data);
} on FirebaseException catch (e) {
  errorMessage.value = _handleFirestoreError(e);
} catch (e) {
  errorMessage.value = 'error_generic'.tr;
}

// ❌ ERRADO
await _firestore.collection('users').doc(userId).update(data);  // Sem try-catch
```

15. **Mensagens de Erro**
```dart
// ✅ CORRETO
errorMessage.value = 'error_unauthenticated'.tr;
errorMessage.value = 'error_insufficient_gems'.tr;

// ❌ ERRADO
errorMessage.value = 'Usuário não autenticado.';
errorMessage.value = 'Você não tem gemas suficientes.';
```

---

## ✅ Checklist de Correção

- [ ] Corrigir progress display bug
- [ ] Adicionar todas as keys de tradução faltantes
- [ ] Atualizar Search Users Page
- [ ] Atualizar Learning Controls Page
- [ ] Refatorar Treasure Challenges Controller
- [ ] Refatorar Shop Controller
- [ ] Refatorar Profile Auth Controller (usar handler Firebase)
- [ ] Refatorar Profile Search Controller
- [ ] Refatorar Profile Settings Controller
- [ ] Refatorar Profile Data Controller
- [ ] Refatorar Profile Courses Controller
- [ ] Refatorar Profile Social Controller (weekdays)
- [ ] Refatorar Home Stats Controller
- [ ] Refatorar XP Level Controller (time remaining)
- [ ] Refatorar Gems Controller (time remaining)
- [ ] Refatorar Leaderboard Controller (usar handler Firebase)
- [ ] Criar error_handler.dart centralizado
- [ ] Adicionar testes para validar uso de traduções
- [ ] Documentar padrão de error handling


## ✅ Checklist de Correção

### 🔥 Urgente (Fazer Primeiro)
- [ ] **Corrigir Splash Controller** - Remover uso de `!` na linha 77
- [ ] **Refatorar verificação de auth em LessonFlowController** - Criar método helper
- [ ] **Adicionar try-catch em operações Firestore** - Profile, Shop, Treasure controllers
- [ ] **Implementar transactions para gamificação** - Energy, Gems, XP controllers
- [ ] **Implementar onClose() em todos controllers** - Prevenir memory leaks
- [ ] **Remover handlers duplicados em auth_credentials_controller** - Usar ErrorHandler
- [ ] **Remover 18 wrappers desnecessários de _handleFirestoreError** - Chamar direto
- [ ] **Refatorar handlers em profile_auth_controller** - Usar ErrorHandler ou .tr
- [ ] **Refatorar handlers em leaderboard_controller** - Usar ErrorHandler

### Alta Prioridade
- [ ] Corrigir progress display bug
- [ ] Adicionar todas as keys de tradução faltantes
- [ ] Atualizar Search Users Page
- [ ] Atualizar Learning Controls Page
- [ ] Refatorar Treasure Challenges Controller
- [ ] Refatorar Shop Controller
- [ ] Refatorar Profile Search Controller
- [ ] Refatorar Profile Settings Controller
- [ ] Refatorar Profile Data Controller
- [ ] Refatorar Profile Courses Controller

### Média Prioridade
- [ ] Implementar cache para evitar refresh desnecessário
- [ ] Melhorar validação de dados de exercícios
- [ ] Refatorar Profile Social Controller (weekdays)
- [ ] Refatorar Home Stats Controller
- [ ] Refatorar XP Level Controller (time remaining)
- [ ] Refatorar Gems Controller (time remaining)

### Infraestrutura
- [ ] Documentar padrão de uso do ErrorHandler centralizado
- [ ] Criar auth_helper.dart com método de verificação
- [ ] Adicionar testes para validar uso de traduções
- [ ] Documentar padrão de error handling
- [ ] Implementar AuthStateListener global
- [ ] Criar hook de CI para detectar hardcoded text
- [ ] Criar hook de CI para detectar handlers duplicados
- [ ] Adicionar logging estruturado para debug

---
 
**Bugs Críticos Encontrados:** 8  
**Bugs de Duplicação Encontrados:** 4 (20+ instâncias)  
**Bugs de Tradução Encontrados:** 16  
**Total:** 28 categorias de bugs
