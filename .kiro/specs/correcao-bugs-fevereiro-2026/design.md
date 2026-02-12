# Design Document

## Overview

Este documento descreve o design técnico SIMPLIFICADO para correção de bugs críticos no aplicativo Pippo. Foco em soluções diretas sem adicionar complexidade desnecessária.

### Escopo

- Correção de bugs críticos de autenticação e null safety
- Implementação de tratamento de erros em operações Firestore
- Prevenção de memory leaks com implementação de onClose()
- Remoção de código duplicado (handlers)
- Substituição de textos hardcoded por traduções

### Fora do Escopo

- Refatoração completa da arquitetura
- Mudanças em UI/UX
- Novos recursos ou funcionalidades
- Helpers complexos (AuthHelper, TranslationKeys)
- Cache e otimizações de navegação
- Transactions para gamificação (correção futura se necessário)
- Property-based tests (unit tests simples são suficientes)

## Architecture

### Componentes Afetados

```
lib/
├── features/
│   ├── core/
│   │   ├── auth/
│   │   │   └── controllers/
│   │   │       └── auth_credentials_controller.dart  [MODIFICAR - Remover handlers]
│   │   └── lesson/
│   │       └── controllers/
│   │           └── lesson_flow_controller.dart       [MODIFICAR - CRÍTICO]
│   │
│   └── inners/
│       ├── splash/
│       │   └── controllers/
│       │       └── splash_controller.dart             [MODIFICAR - CRÍTICO]
│       ├── profile/
│       │   ├── views/
│       │   │   ├── search_users_page.dart             [MODIFICAR - Traduções]
│       │   │   └── learning_controls_page.dart        [MODIFICAR - Traduções]
│       │   └── controllers/
│       │       ├── profile_auth_controller.dart       [MODIFICAR]
│       │       ├── profile_data_controller.dart       [MODIFICAR]
│       │       ├── profile_search_controller.dart     [MODIFICAR]
│       │       ├── profile_settings_controller.dart   [MODIFICAR]
│       │       ├── profile_courses_controller.dart    [MODIFICAR]
│       │       └── profile_social_controller.dart     [MODIFICAR]
│       ├── home/
│       │   └── controllers/
│       │       └── home_stats_controller.dart         [MODIFICAR - Traduções]
│       ├── gamification/
│       │   └── controllers/
│       │       ├── xp_level_controller.dart           [MODIFICAR - Traduções]
│       │       └── gems_controller.dart               [MODIFICAR - Traduções]
│       ├── shop/
│       │   └── controllers/
│       │       └── shop_controller.dart               [MODIFICAR - Traduções]
│       ├── treasure/
│       │   └── controllers/
│       │       └── treasure_challenges_controller.dart [MODIFICAR - Traduções]
│       └── leaderboard/
│           └── controllers/
│               └── leaderboard_controller.dart        [MODIFICAR]
│
└── shared/
    ├── utils/
    │   └── error_handler.dart                         [JÁ EXISTE]
    └── translations/
        ├── pt_BR.dart                                 [MODIFICAR - Adicionar keys]
        ├── en_US.dart                                 [MODIFICAR - Adicionar keys]
        └── es_ES.dart                                 [MODIFICAR - Adicionar keys]
```

### Padrões de Design

1. **Error Handling Centralizado**: Usar `ErrorHandler` de `shared/utils/error_handler.dart`
2. **Verificação de Auth Simples**: `final user = _auth.currentUser; if (user == null) return;`
3. **Translation Keys Diretas**: Usar strings com `.tr` diretamente, sem classe de constantes
4. **Resource Cleanup**: Implementar `onClose()` em todos os controllers

## Components and Interfaces

### Padrão de Verificação de Autenticação

```dart
// Padrão simples e direto
Future<void> performAction() async {
  final user = _auth.currentUser;
  if (user == null) {
    errorMessage.value = 'error_unauthenticated'.tr;
    return;
  }
  
  final userId = user.uid;
  // ... resto do código
}
```

### Padrão de Controller Atualizado

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
    final user = _auth.currentUser;
    if (user == null) {
      errorMessage.value = 'error_unauthenticated'.tr;
      return;
    }
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      // Operação Firestore
      await _firestore.collection('users').doc(user.uid).update({...});
      
    } on FirebaseException catch (e) {
      errorMessage.value = ErrorHandler.getFirestoreErrorMessage(e);
    } catch (e) {
      errorMessage.value = 'error_generic'.tr;
    } finally {
      isLoading.value = false;
    }
  }
}
```

## Data Models

### Translation Keys Structure

Keys de tradução a serem adicionadas (usar strings diretas, sem classe de constantes):

```dart
// pt_BR.dart
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
  'error_reward_already_claimed': 'Você já reivindicou esta recompensa.',
};

// en_US.dart e es_ES.dart seguem a mesma estrutura
```

## Error Handling

### Estratégia de Error Handling

1. **Hierarquia de Tratamento**:
   - FirebaseAuthException → ErrorHandler.getLoginErrorMessage() ou getRegisterErrorMessage()
   - FirebaseException → ErrorHandler.getFirestoreErrorMessage()
   - Exception genérica → 'error_generic'.tr

2. **Padrão de Try-Catch**:
```dart
try {
  // Operação
} on FirebaseAuthException catch (e) {
  errorMessage.value = ErrorHandler.getLoginErrorMessage(e);
} on FirebaseException catch (e) {
  errorMessage.value = ErrorHandler.getFirestoreErrorMessage(e);
} catch (e) {
  errorMessage.value = 'error_generic'.tr;
} finally {
  isLoading.value = false;
}
```

## Testing Strategy

### Unit Tests Simples

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
  expect(controller.errorMessage.value, 'error_unauthenticated'.tr);
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
- Lesson Flow Controller: verificação única de auth, sem race condition
- Auth Credentials Controller: uso correto de ErrorHandler
- Profile Controllers: mensagens traduzidas, try-catch em Firestore
- Views: uso correto de translation keys

### Testes de Regressão

**Checklist**:
- [ ] Splash não crasha com usuário null
- [ ] Lesson Flow não tem race condition
- [ ] Nenhum controller tem handler duplicado
- [ ] Nenhuma view tem texto hardcoded
- [ ] Todos os controllers implementam onClose()
- [ ] Todas as operações Firestore têm try-catch

### Ferramentas de Teste

1. **test**: Package padrão do Flutter
2. **mocktail**: Para mocking de dependências
3. **fake_cloud_firestore**: Para testar operações Firestore
4. **firebase_auth_mocks**: Para testar autenticação

### Métricas de Qualidade

- **Cobertura de Código**: Mínimo 70% nos controllers modificados
- **Cobertura de Bugs**: 100% dos bugs críticos devem ter teste de regressão

## Implementation Notes (SIMPLIFICADO)

### Ordem de Implementação

Seguir a ordem definida em `tasks.md`:

1. **Fase 1 - Bugs Críticos** (3-4h):
   - Corrigir Lesson Flow Controller (race condition)
   - Corrigir Splash Controller (null pointer)
   - Adicionar try-catch em Profile Controllers

2. **Fase 2 - Remoção de Duplicação** (2-3h):
   - Remover handlers duplicados em auth_credentials_controller
   - Remover 18 wrappers de _handleFirestoreError
   - Remover handlers em leaderboard_controller

3. **Fase 3 - Traduções** (3-4h):
   - Adicionar translation keys aos arquivos
   - Atualizar Search Users Page
   - Atualizar Learning Controls Page
   - Atualizar controllers com mensagens hardcoded

4. **Fase 4 - Validação Final** (1h):
   - Implementar onClose() em controllers restantes
   - Executar suite completa de testes
   - Validar checklist de correção

### Checklist de Validação

Antes de considerar a correção completa:

- [ ] Splash não crasha com usuário null
- [ ] Lesson Flow não tem race condition
- [ ] Nenhum controller tem handler duplicado
- [ ] Nenhuma view tem texto hardcoded
- [ ] Todos os controllers implementam onClose()
- [ ] Todas as operações Firestore têm try-catch
- [ ] Todas as translation keys adicionadas (pt_BR, en_US, es_ES)
- [ ] Unit tests passando (70%+ cobertura)
- [ ] Testes de regressão passando
- [ ] Code review aprovado
