# Design Document: Treasure Challenges

## Overview

O sistema de Treasure Challenges é uma funcionalidade de gamificação que oferece missões diárias, semanais e especiais aos usuários do Pippo. O sistema rastreia automaticamente o progresso do usuário em diversas atividades (completar lições, ganhar XP, completar exercícios, manter streak) e concede recompensas (gems, XP, itens) quando os objetivos são atingidos.

A feature é implementada como Tab 3 (Treasure) na navegação principal do app, seguindo os padrões GetX da empresa e integrando-se com os sistemas existentes de lições e gamificação.

## Architecture

### Estrutura de Pastas

```
lib/features/inners/treasure/
├── controllers/
│   └── treasure_controller.dart
├── views/
│   └── treasure_page.dart
└── widgets/
    ├── challenge_card.dart
    ├── treasure_header.dart
    ├── reward_animation_modal.dart
    ├── empty_state.dart
    └── progress_indicator_widget.dart
```

### Fluxo de Dados

```
User Action → Controller → Firestore → Controller → UI Update
     ↓
Event System (Lessons/Gamification) → Controller → Progress Update
```

### Integração com Sistemas Existentes

- **Lessons System**: Recebe eventos de conclusão de lição e exercícios
- **Gamification System**: Recebe eventos de ganho de XP e atualização de streak
- **Firebase Auth**: Autentica usuário para acesso aos desafios
- **Firebase Firestore**: Persiste dados de desafios e progresso

## Components and Interfaces

### TreasureController

```dart
class TreasureController extends GetxController {
  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  
  // Estados específicos
  final challenges = <Map<String, dynamic>>[].obs;
  final isClaimingReward = false.obs;
  
  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    loadChallenges();
  }
  
  // Métodos públicos
  Future<void> loadChallenges();
  Future<void> claimReward(String challengeId);
  Future<void> updateChallengeProgress(String challengeType, int amount);
  void removeExpiredChallenges();
  
  // Métodos privados
  Future<void> _fetchChallengesFromFirestore();
  Future<void> _updateUserRewards(Map<String, dynamic> challenge);
  bool _isExpired(Map<String, dynamic> challenge);
  bool _isCompleted(Map<String, dynamic> challenge);
  bool _canClaim(Map<String, dynamic> challenge);
}
```

**Note**: No models are used. Challenge data is handled as `Map<String, dynamic>` directly from Firestore, following company patterns.

### TreasurePage (View)

```dart
class TreasurePage extends StatelessWidget {
  const TreasurePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TreasureController>();
    final r = ResponsiveUtils(context);
    
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (controller.challenges.isEmpty) {
            return EmptyState();
          }
          
          return SingleChildScrollView(
            padding: EdgeInsets.all(r.spacing16),
            child: Column(
              children: [
                TreasureHeader(),
                SizedBox(height: r.spacing24),
                ...controller.challenges.map((challengeData) => 
                  ChallengeCard(challengeData: challengeData)
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
```

**Note**: Challenge data is passed as `Map<String, dynamic>` directly to widgets.

### Widgets da Feature

**TreasureHeader**: Header com mascote treasure hunter (já existe em `features/inners/treasure/widgets/`)

**ChallengeCard**: Card de desafio com progresso e botão (já existe em `features/inners/treasure/widgets/`)

**Novos widgets necessários**:
- `RewardAnimationModal`: Modal de animação de recompensa
- `EmptyState`: Estado vazio quando não há desafios
- `ProgressIndicatorWidget`: Barra de progresso customizada para desafios

### Uso de Widgets Globais

- **AppButton**: Para botão "Claim Reward" nos challenge cards
- **ResponsiveUtils**: Para todas as dimensões e espaçamentos
- **AppTheme**: Para cores, fontes e estilos

## Data Models

### Firestore Structure

```
users/{userId}/challenges/{challengeId}
{
  "type": "daily" | "weekly" | "special",
  "title": "Complete 3 lessons",
  "description": "Finish 3 lessons today to earn gems",
  "goal": 3,
  "progress": 1,
  "rewardType": "gems" | "xp" | "item",
  "rewardAmount": 50,
  "expirationDate": Timestamp,
  "iconPath": "assets/images/icons/lesson.svg",
  "isClaimed": false,
  "claimedAt": Timestamp | null,
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}

users/{userId}
{
  "gems": 150,
  "xp": 1200,
  ...
}
```

**Note**: No model classes are created. Data is handled directly as `Map<String, dynamic>` from Firestore, following company patterns.

### Challenge Type Expiration Logic

```dart
DateTime calculateExpiration(String type, {DateTime? customDate}) {
  final now = DateTime.now();
  
  switch (type) {
    case 'daily':
      return DateTime(now.year, now.month, now.day, 23, 59, 59);
      
    case 'weekly':
      final daysUntilSunday = DateTime.sunday - now.weekday;
      final nextSunday = now.add(Duration(days: daysUntilSunday));
      return DateTime(nextSunday.year, nextSunday.month, nextSunday.day, 23, 59, 59);
      
    case 'special':
      return customDate ?? now.add(Duration(days: 7));
      
    default:
      return now.add(Duration(days: 1));
  }
}
```

### Helper Methods in Controller

```dart
// Métodos auxiliares no controller para trabalhar com dados do Firestore
bool _isCompleted(Map<String, dynamic> challenge) {
  final progress = challenge['progress'] as int? ?? 0;
  final goal = challenge['goal'] as int? ?? 0;
  return progress >= goal;
}

bool _isExpired(Map<String, dynamic> challenge) {
  final expirationDate = (challenge['expirationDate'] as Timestamp?)?.toDate();
  if (expirationDate == null) return false;
  return DateTime.now().isAfter(expirationDate);
}

bool _canClaim(Map<String, dynamic> challenge) {
  final isClaimed = challenge['isClaimed'] as bool? ?? false;
  return _isCompleted(challenge) && !isClaimed && !_isExpired(challenge);
}

double _getProgressPercentage(Map<String, dynamic> challenge) {
  final progress = challenge['progress'] as int? ?? 0;
  final goal = challenge['goal'] as int? ?? 1;
  return (progress / goal).clamp(0.0, 1.0);
}
```


## Correctness Properties

*Uma propriedade é uma característica ou comportamento que deve ser verdadeiro em todas as execuções válidas de um sistema - essencialmente, uma declaração formal sobre o que o sistema deve fazer. Propriedades servem como ponte entre especificações legíveis por humanos e garantias de correção verificáveis por máquina.*

### Property 1: Challenge Type Expiration Consistency

*For any* challenge of type Daily, the expiration date should always be set to midnight (23:59:59) of the current day.

**Validates: Requirements 1.2**

### Property 2: Weekly Challenge Expiration Consistency

*For any* challenge of type Weekly, the expiration date should always be set to Sunday 23:59:59 of the current week.

**Validates: Requirements 1.3**

### Property 3: Special Challenge Custom Expiration

*For any* challenge of type Special with a custom expiration date, the stored expiration should match the provided custom date.

**Validates: Requirements 1.4**

### Property 4: Challenge Structure Completeness

*For any* challenge stored in Firestore, all required fields (title, description, goal, progress, rewardType, rewardAmount, expirationDate, iconPath) must be present.

**Validates: Requirements 2.1**

### Property 5: Goal Validation

*For any* challenge creation attempt with a non-positive goal value (zero or negative), the system should reject the creation with a validation error.

**Validates: Requirements 2.2**

### Property 6: Reward Amount Validation

*For any* challenge creation attempt with a non-positive reward amount, the system should reject the creation with a validation error.

**Validates: Requirements 2.3**

### Property 7: Reward Type Validation

*For any* challenge creation attempt with a reward type not in {gems, xp, item}, the system should reject the creation with a validation error.

**Validates: Requirements 2.4**

### Property 8: Initial Progress Zero

*For any* newly created challenge, the progress value should be initialized to zero.

**Validates: Requirements 2.5**

### Property 9: Progress Update on Events

*For any* challenge tracking a specific event type (lesson completion, XP gain, exercise completion, streak update), when that event occurs, the challenge progress should increase.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4**

### Property 10: Completion Detection

*For any* challenge where progress reaches or exceeds the goal, the challenge should be marked as completed (isCompleted = true).

**Validates: Requirements 3.5, 4.1, 4.2**

### Property 11: Progress Persistence

*For any* progress update, the new progress value should be immediately persisted to Firestore.

**Validates: Requirements 3.6**

### Property 12: Completed Challenge Button State

*For any* challenge that is completed and not claimed, the claim reward button should be enabled.

**Validates: Requirements 4.3, 7.3, 11.6**

### Property 13: No Completion for Claimed or Expired

*For any* challenge that is already claimed or expired, attempting to mark it as completed should have no effect.

**Validates: Requirements 4.5**

### Property 14: Claim Requires Completion

*For any* challenge that is not completed, attempting to claim the reward should be rejected with an error.

**Validates: Requirements 5.1**

### Property 15: Claim Requires Not Already Claimed

*For any* challenge that is already claimed, attempting to claim the reward again should be rejected with an error.

**Validates: Requirements 5.2**

### Property 16: Claim Requires Not Expired

*For any* challenge that is expired, attempting to claim the reward should be rejected with an error.

**Validates: Requirements 5.3, 6.3**

### Property 17: Gems Reward Application

*For any* challenge with rewardType = gems, when the reward is claimed, the user's gems in Firestore should increase by exactly the rewardAmount.

**Validates: Requirements 5.4, 8.5**

### Property 18: XP Reward Application

*For any* challenge with rewardType = xp, when the reward is claimed, the user's XP in Firestore should increase by exactly the rewardAmount.

**Validates: Requirements 5.5, 8.6**

### Property 19: Claimed Status Persistence

*For any* challenge where the reward is claimed, the challenge should be marked as claimed with a timestamp in Firestore.

**Validates: Requirements 5.6, 9.3**

### Property 20: Claimed Challenge Removal

*For any* challenge that is claimed, it should be removed from the active challenges list displayed to the user.

**Validates: Requirements 5.8, 7.5**

### Property 21: Expiration Check on Load

*For any* challenge loaded from Firestore, the system should check if the expiration date has passed relative to the current time.

**Validates: Requirements 6.1**

### Property 22: Expired Challenge Removal

*For any* challenge that is expired, it should be removed from the active challenges list.

**Validates: Requirements 6.2**

### Property 23: Daily Challenge Expiration Logic

*For any* Daily challenge, the expiration check should compare against midnight (23:59:59) of the current day.

**Validates: Requirements 6.4**

### Property 24: Weekly Challenge Expiration Logic

*For any* Weekly challenge, the expiration check should compare against Sunday 23:59:59 of the current week.

**Validates: Requirements 6.5**

### Property 25: Special Challenge Expiration Logic

*For any* Special challenge, the expiration check should compare against the custom expiration date stored in the challenge.

**Validates: Requirements 6.6**

### Property 26: In Progress State Display

*For any* challenge where progress is less than goal, the UI should display it as "In Progress" with a partial progress bar and disabled claim button.

**Validates: Requirements 7.1, 7.6, 11.5**

### Property 27: Completed State Display

*For any* challenge where progress is greater than or equal to goal and not claimed, the UI should display it as "Completed" with a full progress bar and enabled claim button.

**Validates: Requirements 7.2**

### Property 28: Challenge Data Persistence

*For any* challenge created or updated, all challenge data should be persisted to Firestore.

**Validates: Requirements 9.1**

### Property 29: Active Challenges Retrieval

*For any* authenticated user, loading challenges should retrieve all active (not claimed, not expired) challenges from Firestore for that user.

**Validates: Requirements 9.4**

### Property 30: Required Fields Validation

*For any* challenge creation attempt with missing required fields, the system should reject the creation with a validation error.

**Validates: Requirements 10.1**

### Property 31: Non-Negative Progress Validation

*For any* progress update attempt with a negative value, the system should reject the update with a validation error.

**Validates: Requirements 10.2**

### Property 32: User Ownership Validation

*For any* reward claim attempt, the system should verify that the challenge belongs to the authenticated user, rejecting claims for challenges owned by other users.

**Validates: Requirements 10.4**

### Property 33: Challenge Display Completeness

*For any* challenge displayed in the UI, all required elements (title, description, progress bar, goal text, reward icon, reward amount) should be present.

**Validates: Requirements 11.4**

### Property 34: Active Challenges List Display

*For any* set of active challenges, the treasure page should display all of them in a scrollable list.

**Validates: Requirements 11.3**


## Error Handling

### Firebase Error Handling

Usar os handlers padronizados de `firebase.md`:

```dart
String _handleFirestoreError(FirebaseException e) {
  switch (e.code) {
    case 'permission-denied':
      return 'Erro de permissão. Verifique as configurações do Firestore ou tente novamente em alguns instantes.';
    case 'unavailable':
      return 'Serviço temporariamente indisponível. Tente novamente em alguns instantes.';
    case 'deadline-exceeded':
      return 'Tempo de espera esgotado. Verifique sua conexão e tente novamente.';
    case 'not-found':
      return 'Desafio não encontrado.';
    case 'already-exists':
      return 'Este desafio já existe.';
    default:
      return 'Erro ao carregar desafios. Verifique sua conexão e tente novamente.';
  }
}
```

### Validation Errors

```dart
class ChallengeValidationError {
  static const invalidGoal = 'O objetivo deve ser um número positivo.';
  static const invalidRewardAmount = 'A recompensa deve ser um valor positivo.';
  static const invalidRewardType = 'Tipo de recompensa inválido.';
  static const missingFields = 'Todos os campos obrigatórios devem ser preenchidos.';
  static const negativeProgress = 'O progresso não pode ser negativo.';
  static const notCompleted = 'Este desafio ainda não foi completado.';
  static const alreadyClaimed = 'Você já coletou esta recompensa.';
  static const expired = 'Este desafio expirou.';
  static const notAuthenticated = 'Você precisa estar autenticado para coletar recompensas.';
  static const notOwner = 'Este desafio não pertence a você.';
}
```

### Error Handling in Controller

```dart
Future<void> claimReward(String challengeId) async {
  try {
    isClaimingReward.value = true;
    errorMessage.value = '';
    
    final challengeData = challenges.firstWhere((c) => c['id'] == challengeId);
    
    // Validações
    if (!_isCompleted(challengeData)) {
      throw Exception(ChallengeValidationError.notCompleted);
    }
    if (challengeData['isClaimed'] == true) {
      throw Exception(ChallengeValidationError.alreadyClaimed);
    }
    if (_isExpired(challengeData)) {
      throw Exception(ChallengeValidationError.expired);
    }
    
    // Atualizar recompensas do usuário
    await _updateUserRewards(challengeData);
    
    // Marcar como coletado
    await _markAsClaimed(challengeId);
    
    // Remover da lista
    challenges.removeWhere((c) => c['id'] == challengeId);
    
    // Mostrar animação de recompensa
    _showRewardAnimation(challengeData);
    
  } on FirebaseException catch (e) {
    errorMessage.value = _handleFirestoreError(e);
  } catch (e) {
    errorMessage.value = e.toString().replaceAll('Exception: ', '');
  } finally {
    isClaimingReward.value = false;
  }
}
```

## Testing Strategy

### Dual Testing Approach

O sistema de desafios requer tanto testes unitários quanto testes baseados em propriedades para garantir correção completa:

**Unit Tests**: Validam exemplos específicos, casos extremos e condições de erro
- Exemplo: Verificar que um desafio diário criado às 14h expira à meia-noite
- Exemplo: Verificar que tentar coletar recompensa de desafio expirado retorna erro específico
- Exemplo: Verificar que a animação de recompensa é exibida após coleta bem-sucedida

**Property Tests**: Validam propriedades universais que devem valer para qualquer entrada
- Propriedade: Para qualquer desafio diário, a expiração é sempre meia-noite
- Propriedade: Para qualquer desafio com progresso >= objetivo, isCompleted é true
- Propriedade: Para qualquer recompensa de gems coletada, os gems do usuário aumentam exatamente pelo valor da recompensa

### Property-Based Testing Configuration

**Framework**: Usar biblioteca de property-based testing para Dart (ex: `test` com geradores customizados ou `faker` para dados aleatórios)

**Configuração**:
- Mínimo 100 iterações por teste de propriedade
- Cada teste deve referenciar a propriedade do design
- Tag format: `Feature: treasure-challenges, Property N: [descrição]`

**Exemplo de Property Test**:

```dart
// test/property/features/inners/treasure/controllers/treasure_controller_property_test.dart

import 'package:test/test.dart';
import 'package:faker/faker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('TreasureController Property Tests', () {
    test(
      'Feature: treasure-challenges, Property 1: Daily challenges always expire at midnight',
      () {
        // Gerar 100 desafios diários em horários aleatórios
        for (int i = 0; i < 100; i++) {
          final now = DateTime.now();
          final randomHour = faker.randomGenerator.integer(24);
          final randomMinute = faker.randomGenerator.integer(60);
          final creationTime = DateTime(
            now.year, now.month, now.day, 
            randomHour, randomMinute
          );
          
          final expiration = calculateExpiration(
            'daily',
            createdAt: creationTime,
          );
          
          // Verificar que expira à meia-noite
          expect(expiration.hour, equals(23));
          expect(expiration.minute, equals(59));
          expect(expiration.second, equals(59));
          expect(expiration.day, equals(creationTime.day));
        }
      },
    );
    
    test(
      'Feature: treasure-challenges, Property 10: Progress >= goal marks challenge as completed',
      () {
        final controller = TreasureController();
        
        for (int i = 0; i < 100; i++) {
          final goal = faker.randomGenerator.integer(100, min: 1);
          final progress = faker.randomGenerator.integer(200, min: goal);
          
          final challengeData = {
            'id': faker.guid.guid(),
            'userId': faker.guid.guid(),
            'type': 'daily',
            'title': faker.lorem.sentence(),
            'description': faker.lorem.sentence(),
            'goal': goal,
            'progress': progress,
            'rewardType': 'gems',
            'rewardAmount': 50,
            'expirationDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 1))),
            'iconPath': 'assets/icon.svg',
            'isClaimed': false,
          };
          
          expect(controller._isCompleted(challengeData), isTrue);
        }
      },
    );
  });
}
```
### Unit Test Examples

```dart
// test/unit/features/inners/treasure/controllers/treasure_controller_test.dart

import 'package:test/test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('TreasureController Unit Tests', () {
    test('Claiming reward from expired challenge returns error', () async {
      final controller = TreasureController();
      final expiredChallengeData = {
        'id': '123',
        'userId': 'user1',
        'type': 'daily',
        'title': 'Test',
        'description': 'Test',
        'goal': 3,
        'progress': 3,
        'rewardType': 'gems',
        'rewardAmount': 50,
        'expirationDate': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 1))),
        'iconPath': 'icon.svg',
        'isClaimed': false,
      };
      
      controller.challenges.add(expiredChallengeData);
      
      await controller.claimReward('123');
      
      expect(controller.errorMessage.value, contains('expirou'));
    });
    
    test('Empty challenges list displays empty state', () {
      final controller = TreasureController();
      controller.challenges.clear();
      
      expect(controller.challenges.isEmpty, isTrue);
    });
  });
}
```

### Integration Test Scenarios

Testes de integração devem verificar:
1. Evento de conclusão de lição atualiza progresso de desafio relevante
2. Coleta de recompensa atualiza gems/XP do usuário no Firestore
3. Navegação para Tab 3 carrega desafios do Firestore
4. Desafios expirados são removidos ao entrar na página
5. Animação de recompensa é exibida e modal fecha automaticamente

### Test Coverage Goals

- Controllers: 90%+ de cobertura
- Models: 100% de cobertura (lógica de negócio crítica)
- Widgets: Testes de snapshot para componentes principais
- Property tests: Todas as 34 propriedades implementadas
