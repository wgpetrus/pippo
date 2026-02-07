# Design Document - Correção de Testes de Integração

## Overview

A Correção de Testes de Integração é um projeto de qualidade que visa resolver problemas identificados na suite de testes após a refatoração de controllers. O projeto foca em três áreas principais:

1. **Corrigir testes com @Skip** - Adicionar setup adequado de mocks e registro de controllers
2. **Converter testes de documentação em testes reais** - Implementar testes funcionais que validam comportamento
3. **Atualizar testes para novos controllers** - Adaptar testes para usar controllers refatorados

### Key Design Decisions

1. **Usar FirebaseTestHelper Consistentemente**: Todos os testes devem usar o helper existente para setup de Firebase, garantindo consistência e reduzindo código duplicado.

2. **Padrão de Setup/Teardown**: Estabelecer padrão claro de setUp() e tearDown() para todos os testes, incluindo registro de controllers GetX e limpeza de estado.

3. **Mocks ao Invés de Emulador**: Usar fake_cloud_firestore e firebase_auth_mocks ao invés de Firebase Emulator, permitindo testes rápidos e determinísticos.

4. **Testes Funcionais, Não Documentação**: Converter todos os testes de documentação em testes que validam comportamento real, não apenas existência de código.

5. **Priorização por Criticidade**: Corrigir primeiro testes com @Skip (bloqueiam CI/CD), depois converter testes de documentação, depois atualizar para novos controllers.

## Architecture

### Estrutura de Testes Atual

```
test/
├── helpers/
│   └── firebase_test_helper.dart (✅ já existe e funciona)
│
├── integration/
│   ├── auth/
│   │   ├── auth_flow_integration_test.dart (🔴 comentado)
│   │   └── auth_changes_flow_integration_test.dart (✅ funcional)
│   │
│   ├── shop/
│   │   ├── shop_purchase_flow_integration_test.dart (🟡 documentação)
│   │   ├── shop_boost_application_integration_test.dart (🟡 mocks parciais)
│   │   ├── shop_error_handling_integration_test.dart (🔴 @Skip)
│   │   └── shop_confirmation_dialog_integration_test.dart (✅ funcional)
│   │
│   ├── social/
│   │   └── friends_placeholder_test.dart (🔴 @Skip)
│   │
│   ├── profile/
│   │   ├── settings_logout_integration_test.dart (🔴 @Skip)
│   │   └── ... (outros funcionais)
│   │
│   ├── gamification/
│   │   └── ... (precisam atualização para novos controllers)
│   │
│   └── ... (outros)
│
├── unit/
│   └── features/
│       ├── core/
│       └── inners/
│
└── property/
    └── features/
        ├── core/
        └── inners/
```

### Padrão de Teste de Integração

Todos os testes de integração devem seguir este padrão:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import '../../helpers/firebase_test_helper.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late MockUser user;
  late MyController controller;

  setUp(() async {
    // 1. Setup Firebase
    await FirebaseTestHelper.setupFirebase();
    
    // 2. Create mocks
    firestore = FirebaseTestHelper.createMockFirestore();
    auth = FirebaseTestHelper.createMockAuth();
    user = auth.currentUser as MockUser;
    
    // 3. Setup GetX
    Get.testMode = true;
    
    // 4. Populate test data
    await FirebaseTestHelper.populateGamificationData(
      firestore,
      user.uid,
      currentEnergy: 5,
      totalGems: 100,
    );
    
    // 5. Initialize controller with mocks
    controller = MyController(
      firestore: firestore,
      auth: auth,
    );
    
    // 6. Register controller
    Get.put<MyController>(controller);
    
    // 7. Wait for initialization
    await Future.delayed(const Duration(milliseconds: 100));
  });

  tearDown(() {
    // Clean up GetX
    Get.reset();
  });

  group('Feature Tests', () {
    test('should do something', () async {
      // Arrange
      // Act
      // Assert
    });
  });
}
```

## Components and Interfaces

### FirebaseTestHelper (Já Existe)

```dart
class FirebaseTestHelper {
  /// Inicializa Firebase para testes
  static Future<void> setupFirebase() async

  /// Cria um MockFirebaseAuth com usuário logado
  static MockFirebaseAuth createMockAuth({
    bool signedIn = true,
    String uid = 'test-user-id',
    String email = 'test@example.com',
  })

  /// Cria um FakeFirebaseFirestore
  static FakeFirebaseFirestore createMockFirestore()

  /// Popula Firestore com dados de teste para gamification
  static Future<void> populateGamificationData(
    FakeFirebaseFirestore firestore,
    String userId, {
    int currentEnergy = 5,
    int totalGems = 100,
    int totalXp = 0,
    int currentLevel = 1,
    bool hasXpBooster = false,
    bool hasGemMultiplier = false,
    bool hasUnlimitedEnergy = false,
  })

  /// Popula Firestore com dados de teste para lições
  static Future<void> populateLessonData(...)

  /// Popula Firestore com exercícios de teste
  static Future<void> populateExercises(...)

  /// Popula progresso de lições
  static Future<void> populateLessonProgress(...)
}
```

### Novos Helpers Necessários

#### ShopTestHelper

```dart
class ShopTestHelper {
  /// Popula Firestore com itens da loja
  static Future<void> populateShopItems(
    FakeFirebaseFirestore firestore,
  ) async {
    await firestore.collection('shop').doc('boosts').set({
      'energy_refill': {'cost': 50, 'name': 'Energy Refill'},
      'xp_booster': {'cost': 100, 'name': 'XP Booster'},
      'gem_multiplier': {'cost': 150, 'name': 'Gem Multiplier'},
      'streak_freeze': {'cost': 75, 'name': 'Streak Freeze'},
    });
  }

  /// Simula compra de boost
  static Future<void> simulatePurchase(
    FakeFirebaseFirestore firestore,
    String userId,
    String boostId,
    int cost,
  ) async {
    // Deduz gems
    final userDoc = firestore.collection('users').doc(userId);
    final statsDoc = userDoc.collection('stats').doc('gamification');
    
    final snapshot = await statsDoc.get();
    final currentGems = snapshot.data()?['totalGems'] ?? 0;
    
    await statsDoc.update({
      'totalGems': currentGems - cost,
      'totalGemsSpent': FieldValue.increment(cost),
    });
    
    // Ativa boost
    await statsDoc.update({
      'boosters.$boostId': {
        'active': true,
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(hours: 1)),
        ),
      },
    });
  }
}
```

#### ProfileTestHelper

```dart
class ProfileTestHelper {
  /// Popula Firestore com dados de perfil
  static Future<void> populateProfileData(
    FakeFirebaseFirestore firestore,
    String userId, {
    String userName = 'Test User',
    String username = 'testuser',
    String bio = 'Test bio',
    int avatarId = 1,
    String country = 'BR',
  }) async {
    await firestore.collection('users').doc(userId).set({
      'userName': userName,
      'username': username,
      'bio': bio,
      'avatarId': avatarId,
      'country': country,
      'email': 'test@example.com',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Popula dados sociais (seguindo/seguidores)
  static Future<void> populateSocialData(
    FakeFirebaseFirestore firestore,
    String userId,
    List<String> following,
    List<String> followers,
  ) async {
    // Adiciona seguindo
    for (final targetId in following) {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('following')
          .doc(targetId)
          .set({'followedAt': FieldValue.serverTimestamp()});
    }
    
    // Adiciona seguidores
    for (final followerId in followers) {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('followers')
          .doc(followerId)
          .set({'followedAt': FieldValue.serverTimestamp()});
    }
  }

  /// Popula configurações de perfil
  static Future<void> populateSettings(
    FakeFirebaseFirestore firestore,
    String userId, {
    bool soundEffects = true,
    bool listeningExercises = true,
    bool speakingExercises = true,
    bool practiceReminders = true,
    String reminderTime = '09:00',
    int dailyGoal = 20,
  }) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('preferences')
        .set({
      'soundEffects': soundEffects,
      'listeningExercises': listeningExercises,
      'speakingExercises': speakingExercises,
      'practiceReminders': practiceReminders,
      'reminderTime': reminderTime,
      'dailyGoal': dailyGoal,
    });
  }
}
```

## Correções Específicas

### 1. friends_placeholder_test.dart

**Problema**: ProfileSocialController não está registrado

**Solução**:
```dart
setUp(() async {
  await FirebaseTestHelper.setupFirebase();
  
  firestore = FirebaseTestHelper.createMockFirestore();
  auth = FirebaseTestHelper.createMockAuth();
  user = auth.currentUser as MockUser;
  
  Get.testMode = true;
  
  // Populate data
  await ProfileTestHelper.populateProfileData(firestore, user.uid);
  await ProfileTestHelper.populateSocialData(
    firestore,
    user.uid,
    ['user2', 'user3'],
    ['user4', 'user5'],
  );
  
  // Register controllers
  final dataController = ProfileDataController(
    firestore: firestore,
    auth: auth,
  );
  Get.put<ProfileDataController>(dataController);
  
  final socialController = ProfileSocialController(
    firestore: firestore,
    auth: auth,
  );
  Get.put<ProfileSocialController>(socialController);
  
  await Future.delayed(const Duration(milliseconds: 100));
});
```

### 2. shop_error_handling_integration_test.dart

**Problema**: Requer Firebase Emulator ou mocks avançados

**Solução**: Usar FakeFirebaseFirestore com simulação de erros

```dart
test('should handle permission-denied error', () async {
  // Arrange: Criar Firestore que lança erro
  final errorFirestore = FakeFirebaseFirestore();
  
  // Simular erro de permissão removendo documento
  await errorFirestore.collection('users').doc(user.uid).delete();
  
  final controller = GemsController(
    firestore: errorFirestore,
    auth: auth,
  );
  
  // Act
  await controller.spendGems(50);
  
  // Assert
  expect(controller.errorMessage.value, contains('permissão'));
});
```

### 3. settings_logout_integration_test.dart

**Problema**: Depende de platform channels

**Solução**: Usar firebase_auth_mocks

```dart
test('should logout and clear data', () async {
  // Arrange
  final auth = FirebaseTestHelper.createMockAuth(signedIn: true);
  final controller = ProfileAuthController(
    firestore: firestore,
    auth: auth,
  );
  
  // Act
  await controller.logout();
  
  // Assert
  expect(auth.currentUser, isNull);
  expect(Get.currentRoute, '/auth');
});
```

### 4. auth_flow_integration_test.dart

**Problema**: Todos os testes comentados

**Solução**: Descomentar e adicionar setup adequado

```dart
setUp(() async {
  await FirebaseTestHelper.setupFirebase();
  
  firestore = FirebaseTestHelper.createMockFirestore();
  auth = FirebaseTestHelper.createMockAuth(signedIn: false);
  
  Get.testMode = true;
  
  credentialsController = AuthCredentialsController(
    firestore: firestore,
    auth: auth,
  );
  Get.put<AuthCredentialsController>(credentialsController);
  
  providersController = AuthProvidersController(
    firestore: firestore,
    auth: auth,
  );
  Get.put<AuthProvidersController>(providersController);
});

test('should login with valid credentials', () async {
  // Arrange
  const email = 'test@example.com';
  const password = 'password123';
  
  // Act
  await credentialsController.login(email, password);
  
  // Assert
  expect(auth.currentUser, isNotNull);
  expect(auth.currentUser!.email, email);
  expect(credentialsController.errorMessage.value, isEmpty);
});
```

### 5. shop_purchase_flow_integration_test.dart

**Problema**: Teste de documentação, não testa código real

**Solução**: Implementar teste funcional completo

```dart
test('should complete purchase flow successfully', () async {
  // Arrange
  await ShopTestHelper.populateShopItems(firestore);
  await FirebaseTestHelper.populateGamificationData(
    firestore,
    user.uid,
    totalGems: 200,
  );
  
  final gemsController = GemsController(
    firestore: firestore,
    auth: auth,
  );
  Get.put<GemsController>(gemsController);
  
  final energyController = EnergyController(
    firestore: firestore,
    auth: auth,
  );
  Get.put<EnergyController>(energyController);
  
  await gemsController.loadGems();
  await energyController.loadEnergy();
  
  final initialGems = gemsController.gems.value;
  final initialEnergy = energyController.currentEnergy.value;
  
  // Act: Comprar energy refill (50 gems)
  await ShopTestHelper.simulatePurchase(
    firestore,
    user.uid,
    'energy_refill',
    50,
  );
  
  await gemsController.loadGems();
  await energyController.refillEnergy();
  
  // Assert
  expect(gemsController.gems.value, initialGems - 50);
  expect(energyController.currentEnergy.value, 5); // Max energy
  expect(gemsController.errorMessage.value, isEmpty);
});

test('should show error when insufficient gems', () async {
  // Arrange
  await ShopTestHelper.populateShopItems(firestore);
  await FirebaseTestHelper.populateGamificationData(
    firestore,
    user.uid,
    totalGems: 25, // Menos que o custo
  );
  
  final gemsController = GemsController(
    firestore: firestore,
    auth: auth,
  );
  Get.put<GemsController>(gemsController);
  
  await gemsController.loadGems();
  
  // Act
  final result = await gemsController.spendGems(50);
  
  // Assert
  expect(result, isFalse);
  expect(gemsController.errorMessage.value, contains('insuficientes'));
});
```

## Atualização para Novos Controllers

### Gamification Tests

**Antes** (usando GamificationController):
```dart
final controller = GamificationController();
Get.put<GamificationController>(controller);

await controller.loadGamificationData();
expect(controller.currentEnergy.value, 5);
expect(controller.gems.value, 100);
```

**Depois** (usando controllers específicos):
```dart
final energyController = EnergyController(
  firestore: firestore,
  auth: auth,
);
Get.put<EnergyController>(energyController);

final gemsController = GemsController(
  firestore: firestore,
  auth: auth,
);
Get.put<GemsController>(gemsController);

await energyController.loadEnergy();
await gemsController.loadGems();

expect(energyController.currentEnergy.value, 5);
expect(gemsController.gems.value, 100);
```

### Profile Tests

**Antes** (usando ProfileController):
```dart
final controller = ProfileController();
Get.put<ProfileController>(controller);

await controller.loadProfile();
expect(controller.userName.value, 'Test User');
```

**Depois** (usando controllers específicos):
```dart
final dataController = ProfileDataController(
  firestore: firestore,
  auth: auth,
);
Get.put<ProfileDataController>(dataController);

await dataController.loadOwnProfile();
expect(dataController.userName.value, 'Test User');
```

## Testing Strategy

### Priorização de Correções

**Fase 1: Crítico (Testes com @Skip)**
1. friends_placeholder_test.dart
2. shop_error_handling_integration_test.dart
3. settings_logout_integration_test.dart

**Fase 2: Alta Prioridade (Testes Comentados)**
4. auth_flow_integration_test.dart

**Fase 3: Média Prioridade (Testes de Documentação)**
5. shop_purchase_flow_integration_test.dart
6. shop_boost_application_integration_test.dart

**Fase 4: Atualização (Novos Controllers)**
7. Atualizar testes de gamification
8. Atualizar testes de profile
9. Atualizar testes de lesson
10. Atualizar testes de onboarding
11. Atualizar testes de treasure
12. Atualizar testes de home
13. Atualizar testes de auth

### Validação

Após cada correção:
1. Executar teste específico: `flutter test test/integration/{feature}/{test_file}.dart`
2. Verificar que teste passa
3. Executar suite completa: `flutter test test/integration/`
4. Verificar que nenhum teste foi quebrado
5. Commit com mensagem descritiva

## Success Criteria

O projeto é considerado bem-sucedido quando:

- [ ] ZERO testes com @Skip
- [ ] ZERO testes comentados (exceto TODOs documentados)
- [ ] Todos os testes de integração passam
- [ ] Todos os testes unitários passam
- [ ] Todos os testes de propriedade passam
- [ ] TEST_ISSUES_MAP.md atualizado
- [ ] Documentação de padrões de teste criada
- [ ] Helpers de teste criados e documentados
- [ ] Cobertura de testes mantida ou melhorada

## Risk Mitigation

| Risco | Mitigação |
|-------|-----------|
| Quebrar testes funcionais ao corrigir outros | Executar suite completa após cada correção |
| Mocks não simulam comportamento real | Validar mocks contra comportamento esperado |
| Testes flaky (intermitentes) | Usar await adequadamente, adicionar delays quando necessário |
| Dependências entre testes | Garantir que cada teste seja independente |
| Controllers não registrados | Documentar dependências claramente |
| Circular dependencies | Registrar controllers na ordem correta |
