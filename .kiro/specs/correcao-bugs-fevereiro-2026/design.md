# Design Document

## Overview

Este documento descreve o design técnico para correção de 28 categorias de bugs no aplicativo Pippo, incluindo 8 bugs críticos que podem crashar o app, 4 categorias de duplicação de código e 16 categorias de textos hardcoded. A solução segue os padrões estabelecidos no steering (.kiro/steering/) e mantém consistência com a arquitetura GetX do projeto.

### Escopo

- Correção de bugs críticos de autenticação e null safety
- Implementação de tratamento de erros em operações Firestore
- Prevenção de memory leaks com implementação de onClose()
- Uso de transactions para operações concorrentes
- Remoção de código duplicado (handlers)
- Substituição de 60+ textos hardcoded por traduções
- Otimização de navegação entre tabs
- Melhoria de validação de dados

### Fora do Escopo

- Refatoração completa da arquitetura
- Mudanças em UI/UX
- Novos recursos ou funcionalidades
- Migração de packages

## Architecture

### Componentes Afetados

```
lib/
├── features/
│   ├── core/
│   │   ├── auth/
│   │   │   └── controllers/
│   │   │       └── auth_credentials_controller.dart  [MODIFICAR]
│   │   ├── lesson/
│   │   │   └── controllers/
│   │   │       └── lesson_flow_controller.dart       [MODIFICAR]
│   │   └── onboarding/
│   │       └── controllers/
│   │           ├── onboarding_data_controller.dart   [MODIFICAR]
│   │           └── onboarding_validation_controller.dart [MODIFICAR]
│   │
│   └── inners/
│       ├── splash/
│       │   └── controllers/
│       │       └── splash_controller.dart             [MODIFICAR - CRÍTICO]
│       ├── home/
│       │   └── controllers/
│       │       ├── home_navigation_controller.dart    [MODIFICAR]
│       │       └── home_stats_controller.dart         [MODIFICAR]
│       ├── gamification/
│       │   └── controllers/
│       │       ├── energy_controller.dart             [MODIFICAR]
│       │       ├── gems_controller.dart               [MODIFICAR]
│       │       ├── streak_controller.dart             [MODIFICAR]
│       │       └── xp_level_controller.dart           [MODIFICAR]
│       ├── leaderboard/
│       │   └── controllers/
│       │       └── leaderboard_controller.dart        [MODIFICAR]
│       ├── shop/
│       │   └── controllers/
│       │       └── shop_controller.dart               [MODIFICAR]
│       ├── treasure/
│       │   └── controllers/
│       │       ├── treasure_challenges_controller.dart [MODIFICAR]
│       │       └── treasure_rewards_controller.dart   [MODIFICAR]
│       └── profile/
│           ├── views/
│           │   ├── search_users_page.dart             [MODIFICAR]
│           │   └── learning_controls_page.dart        [MODIFICAR]
│           └── controllers/
│               ├── profile_auth_controller.dart       [MODIFICAR]
│               ├── profile_data_controller.dart       [MODIFICAR]
│               ├── profile_search_controller.dart     [MODIFICAR]
│               ├── profile_settings_controller.dart   [MODIFICAR]
│               ├── profile_courses_controller.dart    [MODIFICAR]
│               └── profile_social_controller.dart     [MODIFICAR]
│
└── shared/
    ├── utils/
    │   ├── error_handler.dart                         [JÁ EXISTE]
    │   ├── auth_helper.dart                           [CRIAR]
    │   └── translation_keys.dart                      [CRIAR]
    └── translations/
        ├── pt_br.dart                                 [MODIFICAR]
        └── en_us.dart                                 [MODIFICAR]
```

### Padrões de Design

1. **Error Handling Centralizado**: Usar `ErrorHandler` de `shared/utils/error_handler.dart`
2. **Auth Verification Helper**: Criar `AuthHelper` para verificação consistente
3. **Translation Keys**: Centralizar keys em constantes para evitar typos
4. **Atomic Operations**: Usar Firestore Transactions para operações concorrentes
5. **Resource Cleanup**: Implementar `onClose()` em todos os controllers

## Components and Interfaces

### 1. AuthHelper (Novo)

Helper centralizado para verificação de autenticação.

```dart
// shared/utils/auth_helper.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthHelper {
  static final _auth = FirebaseAuth.instance;
  
  /// Retorna o usuário autenticado ou null se não autenticado.
  /// Atualiza errorMessage automaticamente se não autenticado.
  static User? getAuthenticatedUser(RxString errorMessage) {
    final user = _auth.currentUser;
    if (user == null || user.uid.isEmpty) {
      errorMessage.value = 'error_unauthenticated'.tr;
      return null;
    }
    return user;
  }
  
  /// Verifica se há usuário autenticado (sem atualizar errorMessage).
  static bool isAuthenticated() {
    final user = _auth.currentUser;
    return user != null && user.uid.isNotEmpty;
  }
  
  /// Retorna o UID do usuário autenticado ou null.
  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}
```

### 2. TranslationKeys (Novo)

Constantes para keys de tradução, evitando typos.

```dart
// shared/utils/translation_keys.dart
class TranslationKeys {
  // Erros comuns
  static const errorUnauthenticated = 'error_unauthenticated';
  static const errorGeneric = 'error_generic';
  static const errorInsufficientGems = 'error_insufficient_gems';
  static const errorNoActiveC course = 'error_no_active_course';
  
  // Profile Search
  static const profileSearchTitle = 'profile_search_title';
  static const profileSearchHint = 'profile_search_hint';
  static const profileSearchEmptyState = 'profile_search_empty_state';
  static const profileSearchNoResults = 'profile_search_no_results';
  
  // Learning Controls
  static const learningControlsMinutesFormat = 'learning_controls_minutes_format';
  
  // Weekdays
  static const commonWeekdayMon = 'common_weekday_mon';
  static const commonWeekdayTue = 'common_weekday_tue';
  static const commonWeekdayWed = 'common_weekday_wed';
  static const commonWeekdayThu = 'common_weekday_thu';
  static const commonWeekdayFri = 'common_weekday_fri';
  static const commonWeekdaySat = 'common_weekday_sat';
  static const commonWeekdaySun = 'common_weekday_sun';
  
  // Time
  static const commonTimeMinutesRemaining = 'common_time_minutes_remaining';
  static const commonTimeHoursRemaining = 'common_time_hours_remaining';
  
  // Lesson Buttons
  static const homeLessonButtonContinue = 'home_lesson_button_continue';
  static const homeLessonButtonStart = 'home_lesson_button_start';
  
  // Treasure Challenges
  static const errorProgressNegative = 'error_progress_negative';
  static const errorChallengeUpdate = 'error_challenge_update';
  static const errorChallengeNotFound = 'error_challenge_not_found';
  static const errorChallengeCompletionCheck = 'error_challenge_completion_check';
  static const errorValidationRequiredFields = 'error_validation_required_fields';
  static const errorValidationGoalPositive = 'error_validation_goal_positive';
  static const errorValidationRewardPositive = 'error_validation_reward_positive';
  static const errorValidationRewardType = 'error_validation_reward_type';
  static const errorValidationProgressZero = 'error_validation_progress_zero';
  
  // Shop
  static const errorRewardAlreadyClaimed = 'error_reward_already_claimed_free';
  
  // Profile
  static const errorProfileNotFound = 'error_profile_not_found';
  static const errorUserNotFound = 'error_user_not_found';
  static const errorNoUsersFound = 'error_no_users_found';
}
```

### 3. Padrão de Controller Atualizado

Todos os controllers devem seguir este padrão:

```dart
class ExampleController extends GetxController {
  // Dependências
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  
  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  
  // Estados específicos
  final data = <String>[].obs;
  
  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    _loadData();
  }
  
  @override
  void onClose() {
    // Limpar listas
    data.clear();
    
    // Resetar estados
    isLoading.value = false;
    errorMessage.value = '';
    
    super.onClose();
  }
  
  // Métodos públicos
  Future<void> performAction() async {
    // Verificar autenticação
    final user = AuthHelper.getAuthenticatedUser(errorMessage);
    if (user == null) return;
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      // Operação Firestore
      await _firestore.collection('users').doc(user.uid).update({...});
      
    } on FirebaseException catch (e) {
      errorMessage.value = ErrorHandler.getFirestoreErrorMessage(e);
    } catch (e) {
      errorMessage.value = TranslationKeys.errorGeneric.tr;
    } finally {
      isLoading.value = false;
    }
  }
}
```

### 4. Padrão de Transaction para Gamificação

Para operações que atualizam múltiplos campos de stats:

```dart
Future<void> updateGamificationStats({
  int? energyDelta,
  int? gemsDelta,
  int? xpDelta,
}) async {
  final user = AuthHelper.getAuthenticatedUser(errorMessage);
  if (user == null) return;
  
  isLoading.value = true;
  errorMessage.value = '';
  
  try {
    final statsRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('stats')
        .doc('gamification');
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(statsRef);
      
      if (!snapshot.exists) {
        throw Exception('Stats document not found');
      }
      
      final updates = <String, dynamic>{};
      
      if (energyDelta != null) {
        updates['energy.currentEnergy'] = FieldValue.increment(energyDelta);
      }
      
      if (gemsDelta != null) {
        updates['gems.gems'] = FieldValue.increment(gemsDelta);
      }
      
      if (xpDelta != null) {
        updates['xp.totalXp'] = FieldValue.increment(xpDelta);
      }
      
      transaction.update(statsRef, updates);
    });
    
  } on FirebaseException catch (e) {
    errorMessage.value = ErrorHandler.getFirestoreErrorMessage(e);
  } catch (e) {
    errorMessage.value = TranslationKeys.errorGeneric.tr;
  } finally {
    isLoading.value = false;
  }
}
```

## Data Models

### Translation Keys Structure

Estrutura das keys de tradução a serem adicionadas:

```dart
// pt_br.dart
final Map<String, String> ptBR = {
  // Erros comuns
  'error_unauthenticated': 'Usuário não autenticado. Faça login novamente.',
  'error_generic': 'Ocorreu um erro. Tente novamente.',
  'error_insufficient_gems': 'Você não tem gemas suficientes.',
  'error_no_active_course': 'Nenhum curso ativo encontrado.',
  'error_profile_not_found': 'Perfil não encontrado.',
  'error_user_not_found': 'Usuário não encontrado.',
  'error_no_users_found': 'Nenhum usuário encontrado.',
  
  // Profile Search
  'profile_search_title': 'Buscar usuários',
  'profile_search_hint': 'Digite username ou nome',
  'profile_search_empty_state': 'Busque por username ou nome',
  'profile_search_no_results': 'Nenhum usuário encontrado',
  
  // Learning Controls
  'learning_controls_minutes_format': '{minutes} minutos',
  
  // Weekdays
  'common_weekday_mon': 'Seg',
  'common_weekday_tue': 'Ter',
  'common_weekday_wed': 'Qua',
  'common_weekday_thu': 'Qui',
  'common_weekday_fri': 'Sex',
  'common_weekday_sat': 'Sáb',
  'common_weekday_sun': 'Dom',
  
  // Time
  'common_time_minutes_remaining': '{minutes}min restantes',
  'common_time_hours_remaining': '{hours}h restantes',
  
  // Lesson Buttons
  'home_lesson_button_continue': 'Continuar',
  'home_lesson_button_start': 'Começar',
  
  // Treasure Challenges
  'error_progress_negative': 'O progresso não pode ser negativo.',
  'error_challenge_update': 'Erro ao atualizar progresso do desafio.',
  'error_challenge_not_found': 'Desafio não encontrado.',
  'error_challenge_completion_check': 'Erro ao verificar conclusão do desafio.',
  'error_validation_required_fields': 'Todos os campos obrigatórios devem ser preenchidos.',
  'error_validation_goal_positive': 'O objetivo deve ser um número positivo.',
  'error_validation_reward_positive': 'A recompensa deve ser um valor positivo.',
  'error_validation_reward_type': 'Tipo de recompensa inválido.',
  'error_validation_progress_zero': 'O progresso inicial deve ser zero.',
  
  // Shop
  'error_reward_already_claimed_free': 'Você já reivindicou esta recompensa.',
};

// en_us.dart
final Map<String, String> enUS = {
  // Erros comuns
  'error_unauthenticated': 'User not authenticated. Please log in again.',
  'error_generic': 'An error occurred. Please try again.',
  'error_insufficient_gems': 'You don\'t have enough gems.',
  'error_no_active_course': 'No active course found.',
  'error_profile_not_found': 'Profile not found.',
  'error_user_not_found': 'User not found.',
  'error_no_users_found': 'No users found.',
  
  // Profile Search
  'profile_search_title': 'Search users',
  'profile_search_hint': 'Type username or name',
  'profile_search_empty_state': 'Search by username or name',
  'profile_search_no_results': 'No users found',
  
  // Learning Controls
  'learning_controls_minutes_format': '{minutes} minutes',
  
  // Weekdays
  'common_weekday_mon': 'Mon',
  'common_weekday_tue': 'Tue',
  'common_weekday_wed': 'Wed',
  'common_weekday_thu': 'Thu',
  'common_weekday_fri': 'Fri',
  'common_weekday_sat': 'Sat',
  'common_weekday_sun': 'Sun',
  
  // Time
  'common_time_minutes_remaining': '{minutes}min remaining',
  'common_time_hours_remaining': '{hours}h remaining',
  
  // Lesson Buttons
  'home_lesson_button_continue': 'Continue',
  'home_lesson_button_start': 'Start',
  
  // Treasure Challenges
  'error_progress_negative': 'Progress cannot be negative.',
  'error_challenge_update': 'Error updating challenge progress.',
  'error_challenge_not_found': 'Challenge not found.',
  'error_challenge_completion_check': 'Error checking challenge completion.',
  'error_validation_required_fields': 'All required fields must be filled.',
  'error_validation_goal_positive': 'Goal must be a positive number.',
  'error_validation_reward_positive': 'Reward must be a positive value.',
  'error_validation_reward_type': 'Invalid reward type.',
  'error_validation_progress_zero': 'Initial progress must be zero.',
  
  // Shop
  'error_reward_already_claimed_free': 'You have already claimed this reward.',
};
```

### Cache Strategy for Navigation

Estrutura de cache para otimizar navegação:

```dart
class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final Duration maxAge;
  
  CacheEntry({
    required this.data,
    required this.timestamp,
    this.maxAge = const Duration(minutes: 5),
  });
  
  bool get isStale {
    return DateTime.now().difference(timestamp) > maxAge;
  }
}

class NavigationCache {
  final _treasureCache = Rx<CacheEntry<List<Challenge>>?>(null);
  final _profileCache = Rx<CacheEntry<UserProfile>?>(null);
  
  void cacheTreasure(List<Challenge> challenges) {
    _treasureCache.value = CacheEntry(
      data: challenges,
      timestamp: DateTime.now(),
    );
  }
  
  List<Challenge>? getTreasure() {
    final cache = _treasureCache.value;
    if (cache == null || cache.isStale) return null;
    return cache.data;
  }
  
  void invalidateTreasure() {
    _treasureCache.value = null;
  }
}
```

## Correctness Properties

*Uma propriedade é uma característica ou comportamento que deve ser verdadeiro em todas as execuções válidas do sistema - essencialmente, uma declaração formal sobre o que o sistema deve fazer. Propriedades servem como ponte entre especificações legíveis por humanos e garantias de correção verificáveis por máquina.*

Antes de definir as propriedades, vou realizar a análise de prework dos acceptance criteria:


### Property Reflection

Após análise do prework, identifiquei as seguintes propriedades testáveis:

**Propriedades de Autenticação:**
- 1.1: Null safety em verificação de usuário
- 1.3: Mensagens de erro traduzidas
- 1.5: Prevenção de operações sem autenticação
- 15.3: ErrorMessage traduzido quando não autenticado

**Análise de Redundância:** 
- Propriedades 1.3 e 15.3 são redundantes - ambas testam que mensagens de erro de autenticação usam .tr
- **Decisão:** Combinar em uma única propriedade abrangente

**Propriedades de Error Handling:**
- 2.2: Uso de ErrorHandler para FirebaseException
- 2.3: Mensagem genérica traduzida para erros não-Firebase
- 2.4: ErrorMessage sempre preenchido após erro
- 4.5: Mensagem de erro para falha de transaction

**Análise de Redundância:**
- Propriedades 2.2, 2.3 e 4.5 são casos específicos de 2.4
- **Decisão:** Manter 2.4 como propriedade principal e 2.2/2.3 como sub-propriedades específicas

**Propriedades de Resource Cleanup:**
- 3.2: Listas vazias após onClose()
- 3.3: Estados resetados após onClose()

**Análise de Redundância:**
- Ambas testam limpeza de recursos, mas aspectos diferentes
- **Decisão:** Combinar em uma única propriedade de "estado limpo"

**Propriedades de Atomicidade:**
- 4.2: Atomicidade de transactions

**Análise de Redundância:**
- Propriedade única, sem redundância

**Propriedades de Tradução:**
- 7.1: Formato de minutos com .trParams()
- 8.1: Mensagens de erro com .tr
- 8.5: Consistência de nomenclatura de keys
- 9.1: Dias da semana com .tr
- 10.1: Tempo restante < 60min com .trParams()
- 10.2: Tempo restante >= 60min com .trParams()
- 11.1: Botão continuar com .tr
- 11.2: Botão começar com .tr

**Análise de Redundância:**
- Propriedades 10.1 e 10.2 podem ser combinadas em uma única propriedade condicional
- Propriedades 11.1 e 11.2 podem ser combinadas em uma única propriedade condicional
- **Decisão:** Combinar pares condicionais

**Propriedades de Cache:**
- 12.2: Uso de cache quando válido

**Análise de Redundância:**
- Propriedade única, sem redundância

**Propriedades de Validação:**
- 13.1: Rejeição de type null
- 13.2: Rejeição de type inválido
- 13.3: Rejeição de order inválido
- 13.4: Validação de estrutura por tipo
- 13.5: Retorno false e errorMessage para dados inválidos

**Análise de Redundância:**
- Propriedades 13.1-13.4 são casos específicos de validação
- Propriedade 13.5 é consequência das anteriores
- **Decisão:** Combinar em uma propriedade abrangente de validação

**Propriedades de Display:**
- 14.1: Substituição de placeholders

**Análise de Redundância:**
- Propriedade única, sem redundância

**Resumo de Propriedades Finais:**
1. Null safety e autenticação (combina 1.1, 1.3, 1.5, 15.3)
2. Error handling consistente (combina 2.2, 2.3, 2.4, 4.5)
3. Resource cleanup completo (combina 3.2, 3.3)
4. Atomicidade de transactions (4.2)
5. Traduções com .tr e .trParams() (combina 7.1, 8.1, 9.1)
6. Consistência de translation keys (8.5)
7. Tempo restante formatado (combina 10.1, 10.2)
8. Botões de lição formatados (combina 11.1, 11.2)
9. Cache válido evita requisições (12.2)
10. Validação completa de exercícios (combina 13.1-13.5)
11. Substituição de placeholders (14.1)

### Correctness Properties

Property 1: Null Safety em Verificação de Autenticação
*Para qualquer* operação que requer autenticação, o sistema deve verificar se o usuário existe antes de acessar suas propriedades, e se o usuário não está autenticado, deve exibir mensagem traduzida e prevenir a operação.
**Validates: Requirements 1.1, 1.3, 1.5, 15.3**

Property 2: Error Handling Consistente
*Para qualquer* erro capturado (FirebaseException, erro genérico, ou falha de transaction), o sistema deve sempre atualizar errorMessage.value com uma mensagem não-vazia, usando ErrorHandler para erros Firebase e translation keys para todos os erros.
**Validates: Requirements 2.2, 2.3, 2.4, 4.5**

Property 3: Resource Cleanup Completo
*Para qualquer* controller, quando onClose() é chamado, todas as listas observáveis devem estar vazias e todos os estados (isLoading, errorMessage) devem estar resetados para valores iniciais.
**Validates: Requirements 3.2, 3.3**

Property 4: Atomicidade de Transactions
*Para qualquer* transaction do Firestore que atualiza múltiplos campos, ou todos os campos são atualizados com sucesso ou nenhum campo é modificado (atomicidade).
**Validates: Requirements 4.2**

Property 5: Traduções Consistentes
*Para qualquer* texto exibido ao usuário (mensagens de erro, labels, hints, dias da semana), o sistema deve usar translation keys com .tr ou .trParams(), nunca strings hardcoded em português.
**Validates: Requirements 7.1, 8.1, 9.1**

Property 6: Nomenclatura Consistente de Translation Keys
*Para todas* as translation keys, o sistema deve seguir o padrão snake_case com prefixos consistentes (error_, common_, profile_, home_, etc).
**Validates: Requirements 8.5**

Property 7: Formatação de Tempo Restante
*Para qualquer* tempo restante de booster, se o tempo é menor que 60 minutos, o sistema deve usar 'common_time_minutes_remaining'.trParams(), caso contrário deve usar 'common_time_hours_remaining'.trParams().
**Validates: Requirements 10.1, 10.2**

Property 8: Formatação de Botões de Lição
*Para qualquer* lição, se a lição tem progresso maior que zero, o botão deve usar 'home_lesson_button_continue'.tr, caso contrário deve usar 'home_lesson_button_start'.tr.
**Validates: Requirements 11.1, 11.2**

Property 9: Cache Evita Requisições Desnecessárias
*Para qualquer* navegação para uma tab, se os dados estão em cache e não estão desatualizados (stale), o sistema não deve fazer requisição ao Firestore.
**Validates: Requirements 12.2**

Property 10: Validação Completa de Exercícios
*Para qualquer* dado de exercício, a validação deve rejeitar (retornar false e preencher errorMessage) se: type é null, type não está na lista válida, order não é número válido, ou estrutura não corresponde ao tipo.
**Validates: Requirements 13.1, 13.2, 13.3, 13.4, 13.5**

Property 11: Substituição de Placeholders
*Para qualquer* exibição de progresso, o texto nunca deve conter os literais "{current}" ou "{total}", devendo sempre substituí-los pelos valores reais ou exibir "0/0" quando valores não disponíveis.
**Validates: Requirements 14.1**

## Error Handling

### Estratégia de Error Handling

1. **Hierarquia de Tratamento**:
   - FirebaseAuthException → ErrorHandler.getLoginErrorMessage() ou getRegisterErrorMessage()
   - FirebaseException → ErrorHandler.getFirestoreErrorMessage()
   - Exception genérica → TranslationKeys.errorGeneric.tr

2. **Padrão de Try-Catch**:
```dart
try {
  // Operação
} on FirebaseAuthException catch (e) {
  errorMessage.value = ErrorHandler.getLoginErrorMessage(e);
} on FirebaseException catch (e) {
  errorMessage.value = ErrorHandler.getFirestoreErrorMessage(e);
} catch (e) {
  errorMessage.value = TranslationKeys.errorGeneric.tr;
} finally {
  isLoading.value = false;
}
```

3. **Logging de Erros**:
   - Erros críticos devem ser logados com contexto
   - Usar debugPrint() em desenvolvimento
   - Considerar Firebase Crashlytics em produção

4. **Recovery de Erros**:
   - Transactions têm retry automático do Firestore
   - Operações de leitura podem usar cache como fallback
   - Operações de escrita devem informar usuário e permitir retry manual

### Casos de Erro Específicos

1. **Usuário Não Autenticado**:
   - Exibir TranslationKeys.errorUnauthenticated.tr
   - Navegar para tela de auth
   - Limpar dados sensíveis do cache

2. **Erro de Rede**:
   - Exibir mensagem do ErrorHandler
   - Manter dados em cache se disponíveis
   - Permitir retry manual

3. **Erro de Permissão Firestore**:
   - Exibir mensagem do ErrorHandler
   - Verificar se usuário ainda está autenticado
   - Considerar refresh de token

4. **Erro de Validação**:
   - Exibir mensagem específica traduzida
   - Destacar campo com erro (se aplicável)
   - Prevenir submissão até correção

## Testing Strategy

### Abordagem Dual de Testes

O projeto utilizará duas abordagens complementares:

1. **Unit Tests** (`test/unit/`): Exemplos específicos, edge cases, validações pontuais
2. **Property Tests** (`test/property/`): Propriedades universais que devem valer para qualquer input

### Unit Tests

**Foco**: Casos específicos e edge cases identificados no bug report.

**Exemplos**:
```dart
// test/unit/features/inners/splash/controllers/splash_controller_test.dart
test('deve navegar para auth quando usuário é null', () {
  // Arrange
  when(() => mockAuth.currentUser).thenReturn(null);
  
  // Act
  controller.onInit();
  
  // Assert
  verify(() => Get.offAllNamed('/auth')).called(1);
  expect(controller.errorMessage.value, TranslationKeys.errorUnauthenticated.tr);
});

test('não deve crashar com null pointer ao verificar usuário', () {
  // Arrange
  when(() => mockAuth.currentUser).thenReturn(null);
  
  // Act & Assert
  expect(() => controller.onInit(), returnsNormally);
});
```

**Cobertura de Unit Tests**:
- Splash Controller: verificação de null, navegação correta
- Lesson Flow Controller: verificação única de auth, prevenção de race condition
- Auth Credentials Controller: uso correto de ErrorHandler
- Profile Controllers: mensagens traduzidas, try-catch em Firestore
- Gamification Controllers: transactions, onClose()
- Views: uso correto de translation keys

### Property-Based Tests

**Foco**: Propriedades universais que devem ser verdadeiras para qualquer input válido.

**Configuração**:
- Mínimo 100 iterações por teste
- Tag: `Feature: correcao-bugs-fevereiro-2026, Property N: [descrição]`
- Usar package `test` com generators customizados

**Exemplos**:
```dart
// test/property/features/core/auth/controllers/auth_credentials_controller_property_test.dart
group('Feature: correcao-bugs-fevereiro-2026, Property 2: Error Handling Consistente', () {
  test('qualquer erro deve resultar em errorMessage não-vazio', () {
    // Property: Para qualquer erro, errorMessage nunca está vazio
    final errors = [
      FirebaseAuthException(code: 'user-not-found'),
      FirebaseAuthException(code: 'wrong-password'),
      FirebaseException(plugin: 'firestore', code: 'permission-denied'),
      Exception('erro genérico'),
    ];
    
    for (final error in errors) {
      // Arrange
      controller.errorMessage.value = '';
      
      // Act
      controller.handleError(error);
      
      // Assert
      expect(controller.errorMessage.value, isNotEmpty);
      expect(controller.errorMessage.value, contains('.tr') || contains('ErrorHandler'));
    }
  });
});

// test/property/features/inners/gamification/controllers/energy_controller_property_test.dart
group('Feature: correcao-bugs-fevereiro-2026, Property 3: Resource Cleanup Completo', () {
  test('onClose() deve limpar todos os recursos', () {
    // Property: Para qualquer estado do controller, onClose() limpa tudo
    final testStates = [
      {'isLoading': true, 'errorMessage': 'erro', 'data': [1, 2, 3]},
      {'isLoading': false, 'errorMessage': '', 'data': []},
      {'isLoading': true, 'errorMessage': 'outro erro', 'data': [4, 5]},
    ];
    
    for (final state in testStates) {
      // Arrange
      controller.isLoading.value = state['isLoading'] as bool;
      controller.errorMessage.value = state['errorMessage'] as String;
      controller.data.value = state['data'] as List<int>;
      
      // Act
      controller.onClose();
      
      // Assert
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, '');
      expect(controller.data, isEmpty);
    }
  });
});
```

**Cobertura de Property Tests**:
- Property 1: Null safety (100 iterações com estados aleatórios de auth)
- Property 2: Error handling (100 iterações com erros aleatórios)
- Property 3: Resource cleanup (100 iterações com estados aleatórios)
- Property 4: Atomicidade (50 iterações com updates concorrentes)
- Property 5: Traduções (100 iterações verificando ausência de hardcoded text)
- Property 6: Nomenclatura (verificar todas as keys existentes)
- Property 7-8: Formatação condicional (100 iterações com valores aleatórios)
- Property 9: Cache (50 iterações com diferentes estados de cache)
- Property 10: Validação (100 iterações com dados aleatórios)
- Property 11: Placeholders (100 iterações com valores aleatórios)

### Testes de Integração

**Foco**: Fluxos completos que envolvem múltiplos controllers.

**Exemplos**:
- Fluxo de login → navegação → operação protegida
- Fluxo de iniciar lição → completar exercício → atualizar stats
- Fluxo de comprar item → atualizar gems → verificar saldo

### Testes de Regressão

**Foco**: Garantir que bugs corrigidos não retornem.

**Checklist**:
- [ ] Splash não crasha com usuário null
- [ ] Lesson Flow não tem race condition
- [ ] Nenhum controller tem handler duplicado
- [ ] Nenhuma view tem texto hardcoded
- [ ] Todos os controllers implementam onClose()
- [ ] Todas as operações Firestore têm try-catch
- [ ] Gamification usa transactions

### Ferramentas de Teste

1. **test**: Package padrão do Flutter
2. **mocktail**: Para mocking de dependências
3. **fake_cloud_firestore**: Para testar operações Firestore
4. **firebase_auth_mocks**: Para testar autenticação

### Métricas de Qualidade

- **Cobertura de Código**: Mínimo 80% nos controllers modificados
- **Cobertura de Bugs**: 100% dos 28 bugs devem ter teste de regressão
- **Property Tests**: Mínimo 100 iterações cada
- **Tempo de Execução**: Máximo 5 minutos para suite completa

### Estratégia de Execução

1. **Desenvolvimento**: Rodar unit tests afetados
2. **Pre-commit**: Rodar todos os unit tests
3. **CI/CD**: Rodar unit + property + integration tests
4. **Release**: Rodar suite completa + testes manuais de smoke

## Implementation Notes

### Ordem de Implementação

1. **Fase 1 - Infraestrutura** (Crítico):
   - Criar AuthHelper
   - Criar TranslationKeys
   - Adicionar translation keys aos arquivos pt_br.dart e en_us.dart

2. **Fase 2 - Bugs Críticos** (Urgente):
   - Corrigir Splash Controller (null safety)
   - Refatorar Lesson Flow Controller (auth verification)
   - Adicionar try-catch em Profile Controllers
   - Implementar transactions em Gamification Controllers

3. **Fase 3 - Remoção de Duplicação** (Alta):
   - Remover handlers duplicados em auth_credentials_controller
   - Remover 18 wrappers de _handleFirestoreError
   - Remover handlers em profile_auth_controller e leaderboard_controller

4. **Fase 4 - Traduções** (Média):
   - Atualizar Search Users Page
   - Atualizar Learning Controls Page
   - Atualizar controllers com mensagens hardcoded
   - Atualizar formatação de dias da semana e tempo restante

5. **Fase 5 - Otimizações** (Baixa):
   - Implementar cache em HomeNavigationController
   - Melhorar validação de exercícios
   - Corrigir progress display

6. **Fase 6 - Testes e Documentação**:
   - Implementar unit tests
   - Implementar property tests
   - Atualizar documentação

### Considerações de Performance

1. **Transactions**: Usar apenas quando necessário (operações concorrentes)
2. **Cache**: Implementar com TTL de 5 minutos
3. **Traduções**: Keys são carregadas uma vez no início
4. **Error Handling**: Overhead mínimo do try-catch

### Considerações de Manutenibilidade

1. **Centralização**: ErrorHandler e AuthHelper facilitam manutenção
2. **Consistência**: TranslationKeys previne typos
3. **Testabilidade**: Padrões consistentes facilitam testes
4. **Documentação**: Exemplos claros de uso correto

### Riscos e Mitigações

| Risco | Impacto | Probabilidade | Mitigação |
|-------|---------|---------------|-----------|
| Quebrar funcionalidade existente | Alto | Média | Testes de regressão abrangentes |
| Esquecer algum texto hardcoded | Médio | Alta | Property test para detectar |
| Performance degradada por transactions | Médio | Baixa | Usar apenas onde necessário |
| Conflito de merge | Baixo | Média | Implementar em ordem, commits pequenos |

### Checklist de Validação

Antes de considerar a correção completa:

- [ ] Todos os 28 bugs identificados foram corrigidos
- [ ] Nenhum handler duplicado no código
- [ ] Nenhum texto hardcoded (exceto constantes técnicas)
- [ ] Todos os controllers implementam onClose()
- [ ] Todas as operações Firestore têm try-catch
- [ ] Todas as translation keys adicionadas (pt_br e en_us)
- [ ] AuthHelper criado e usado consistentemente
- [ ] TranslationKeys criado e usado consistentemente
- [ ] Transactions implementadas em gamification
- [ ] Cache implementado em navegação
- [ ] Unit tests passando (80%+ cobertura)
- [ ] Property tests passando (100 iterações cada)
- [ ] Testes de regressão passando
- [ ] Documentação atualizada
- [ ] Code review aprovado
