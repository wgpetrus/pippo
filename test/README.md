# Documentação de Testes - Pippo

> Guia completo para escrever e manter testes no projeto Pippo

---

## Estrutura de Testes

```
test/
├── helpers/                 # Helpers compartilhados entre testes
│   ├── firebase_test_helper.dart
│   ├── auth_test_helper.dart
│   ├── profile_test_helper.dart
│   └── shop_test_helper.dart
│
├── integration/             # Testes de integração (múltiplos componentes)
│   ├── auth/
│   ├── gamification/
│   ├── leaderboard/
│   ├── onboarding/
│   ├── profile/
│   ├── shop/
│   └── ...
│
├── unit/                    # Testes unitários (componentes isolados)
│   ├── features/
│   └── shared/
│
└── property/                # Property-based tests (propriedades universais)
    └── features/
```

---

## Padrão de Teste de Integração

### Estrutura Básica

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
    
    // 5. Initialize controller with DI
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

### Componentes Essenciais

#### 1. Setup Firebase

```dart
await FirebaseTestHelper.setupFirebase();
```

Inicializa o Firebase para testes. **Sempre** chamar no início do `setUp()`.

#### 2. Create Mocks

```dart
firestore = FirebaseTestHelper.createMockFirestore();
auth = FirebaseTestHelper.createMockAuth();
user = auth.currentUser as MockUser;
```

Cria instâncias mockadas do Firebase Auth e Firestore.

**Opções do `createMockAuth()`:**
- `signedIn: bool` - Se o usuário está logado (default: true)
- `uid: String` - ID do usuário (default: 'test-user-id')
- `email: String` - Email do usuário (default: 'test@example.com')

#### 3. Setup GetX

```dart
Get.testMode = true;
```

Habilita modo de teste do GetX. **Sempre** necessário antes de usar controllers.

#### 4. Populate Test Data

Use os métodos do `FirebaseTestHelper` para popular dados de teste:

```dart
// Dados de gamificação
await FirebaseTestHelper.populateGamificationData(
  firestore,
  user.uid,
  currentEnergy: 5,
  totalGems: 100,
  totalXp: 0,
  currentLevel: 1,
  hasXpBooster: false,
  hasGemMultiplier: false,
  hasUnlimitedEnergy: false,
);

// Dados de perfil
await FirebaseTestHelper.populateProfileData(
  firestore,
  user.uid,
  userName: 'Test User',
  username: 'testuser',
  bio: 'Test bio',
  avatarId: 1,
  country: 'BR',
);

// Dados sociais
await FirebaseTestHelper.populateSocialData(
  firestore,
  user.uid,
  following: ['user2', 'user3'],
  followers: ['user4', 'user5'],
);

// Configurações
await FirebaseTestHelper.populateSettings(
  firestore,
  user.uid,
  soundEffects: true,
  listeningExercises: true,
  speakingExercises: true,
  practiceReminders: true,
  reminderTime: '09:00',
  dailyGoal: 20,
);

// Itens da loja
await FirebaseTestHelper.populateShopItems(firestore);
```

#### 5. Initialize Controller com DI

**IMPORTANTE:** Todos os controllers agora suportam Dependency Injection (DI).

```dart
controller = MyController(
  firestore: firestore,
  auth: auth,
);
```

**Nunca** instanciar controllers sem passar os mocks:

```dart
// ❌ ERRADO - usa instâncias reais do Firebase
controller = MyController();

// ✅ CORRETO - passa mocks via construtor
controller = MyController(
  firestore: firestore,
  auth: auth,
);
```

#### 6. Register Controller

```dart
Get.put<MyController>(controller);
```

Registra o controller no GetX para que possa ser acessado via `Get.find()`.

**Ordem de Registro (Importante!):**

Quando há dependências entre controllers, registre na ordem correta:

```dart
// 1. Controllers sem dependências primeiro
final gemsController = GemsController(firestore: firestore, auth: auth);
Get.put<GemsController>(gemsController);

final energyController = EnergyController(firestore: firestore, auth: auth);
Get.put<EnergyController>(energyController);

// 2. Controllers que dependem de outros depois
final shopController = ShopController(firestore: firestore, auth: auth);
Get.put<ShopController>(shopController);
```

#### 7. Wait for Initialization

```dart
await Future.delayed(const Duration(milliseconds: 100));
```

Aguarda inicialização assíncrona dos controllers. Ajuste o tempo se necessário.

#### 8. TearDown

```dart
tearDown(() {
  Get.reset();
});
```

**Sempre** limpar o estado do GetX no `tearDown()` para evitar interferência entre testes.

---

## Como Usar FirebaseTestHelper

### Métodos Disponíveis

#### setupFirebase()

```dart
await FirebaseTestHelper.setupFirebase();
```

Inicializa Firebase para testes. Chame no início do `setUp()`.

#### createMockAuth()

```dart
final auth = FirebaseTestHelper.createMockAuth(
  signedIn: true,
  uid: 'test-user-id',
  email: 'test@example.com',
);
```

Cria um `MockFirebaseAuth` com usuário logado.

#### createMockFirestore()

```dart
final firestore = FirebaseTestHelper.createMockFirestore();
```

Cria um `FakeFirebaseFirestore` para testes.

#### populateGamificationData()

```dart
await FirebaseTestHelper.populateGamificationData(
  firestore,
  userId,
  currentEnergy: 5,
  totalGems: 100,
  totalXp: 0,
  currentLevel: 1,
  hasXpBooster: false,
  hasGemMultiplier: false,
  hasUnlimitedEnergy: false,
);
```

Popula dados de gamificação no Firestore mockado.

#### populateProfileData()

```dart
await FirebaseTestHelper.populateProfileData(
  firestore,
  userId,
  userName: 'Test User',
  username: 'testuser',
  bio: 'Test bio',
  avatarId: 1,
  country: 'BR',
);
```

Popula dados de perfil no Firestore mockado.

#### populateSocialData()

```dart
await FirebaseTestHelper.populateSocialData(
  firestore,
  userId,
  following: ['user2', 'user3'],
  followers: ['user4', 'user5'],
);
```

Popula dados sociais (seguindo/seguidores) no Firestore mockado.

#### populateSettings()

```dart
await FirebaseTestHelper.populateSettings(
  firestore,
  userId,
  soundEffects: true,
  listeningExercises: true,
  speakingExercises: true,
  practiceReminders: true,
  reminderTime: '09:00',
  dailyGoal: 20,
);
```

Popula configurações do usuário no Firestore mockado.

#### populateShopItems()

```dart
await FirebaseTestHelper.populateShopItems(firestore);
```

Popula itens da loja no Firestore mockado.

---

## Como Registrar Controllers GetX

### Registro Simples

```dart
final controller = MyController(
  firestore: firestore,
  auth: auth,
);
Get.put<MyController>(controller);
```

### Registro com Dependências

Quando um controller depende de outro, registre na ordem correta:

```dart
// 1. Dependências primeiro
final gemsController = GemsController(firestore: firestore, auth: auth);
Get.put<GemsController>(gemsController);

// 2. Controller que depende depois
final shopController = ShopController(firestore: firestore, auth: auth);
Get.put<ShopController>(shopController);
```

### Múltiplos Controllers

```dart
// Gamification controllers
final gemsController = GemsController(firestore: firestore, auth: auth);
Get.put<GemsController>(gemsController);

final energyController = EnergyController(firestore: firestore, auth: auth);
Get.put<EnergyController>(energyController);

final xpController = XpLevelController(firestore: firestore, auth: auth);
Get.put<XpLevelController>(xpController);

final streakController = StreakController(firestore: firestore, auth: auth);
Get.put<StreakController>(streakController);
```

### Limpeza

**Sempre** limpar no `tearDown()`:

```dart
tearDown(() {
  Get.reset();
});
```

---

## Como Mockar Firebase Auth

### Usuário Logado

```dart
final auth = FirebaseTestHelper.createMockAuth(
  signedIn: true,
  uid: 'test-user-id',
  email: 'test@example.com',
);
```

### Usuário Não Logado

```dart
final auth = FirebaseTestHelper.createMockAuth(signedIn: false);
```

### Acessar Usuário Atual

```dart
final user = auth.currentUser as MockUser;
print(user.uid);    // 'test-user-id'
print(user.email);  // 'test@example.com'
```

### Simular Login

```dart
// O mock já vem com usuário logado por padrão
// Para testar login, use signedIn: false e depois:
await auth.signInWithEmailAndPassword(
  email: 'test@example.com',
  password: 'password123',
);
```

### Simular Logout

```dart
await auth.signOut();
expect(auth.currentUser, isNull);
```

---

## Como Mockar Firestore

### Criar Instância

```dart
final firestore = FirebaseTestHelper.createMockFirestore();
```

### Adicionar Dados

```dart
await firestore.collection('users').doc('user-id').set({
  'userName': 'Test User',
  'email': 'test@example.com',
  'createdAt': FieldValue.serverTimestamp(),
});
```

### Ler Dados

```dart
final doc = await firestore.collection('users').doc('user-id').get();
expect(doc.exists, isTrue);
expect(doc.data()?['userName'], 'Test User');
```

### Atualizar Dados

```dart
await firestore.collection('users').doc('user-id').update({
  'userName': 'Updated Name',
});
```

### Deletar Dados

```dart
await firestore.collection('users').doc('user-id').delete();
```

### Queries

```dart
final snapshot = await firestore
    .collection('users')
    .where('country', isEqualTo: 'BR')
    .get();

expect(snapshot.docs.length, greaterThan(0));
```

---

## Como Testar Fluxos Assíncronos

### Aguardar Operações

```dart
test('should load data asynchronously', () async {
  // Arrange
  await FirebaseTestHelper.populateGamificationData(firestore, user.uid);
  
  // Act
  await controller.loadGems();
  
  // Assert
  expect(controller.gems.value, 100);
});
```

### Aguardar Múltiplas Operações

```dart
test('should perform multiple async operations', () async {
  // Arrange
  await FirebaseTestHelper.populateGamificationData(firestore, user.uid);
  
  // Act
  await Future.wait([
    controller.loadGems(),
    controller.loadEnergy(),
    controller.loadXp(),
  ]);
  
  // Assert
  expect(controller.gems.value, 100);
  expect(controller.currentEnergy.value, 5);
  expect(controller.totalXp.value, 0);
});
```

### Aguardar Estados Reativos

```dart
test('should update reactive state', () async {
  // Arrange
  expect(controller.isLoading.value, isFalse);
  
  // Act
  final future = controller.loadData();
  
  // Assert - durante carregamento
  expect(controller.isLoading.value, isTrue);
  
  await future;
  
  // Assert - após carregamento
  expect(controller.isLoading.value, isFalse);
});
```

### Timeout em Testes

```dart
test('should complete within timeout', () async {
  await controller.loadData().timeout(
    const Duration(seconds: 5),
    onTimeout: () => throw TimeoutException('Test timed out'),
  );
});
```

---

## Exemplos de Testes Bem Escritos

### Exemplo 1: Teste de Controller Simples

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import '../../helpers/firebase_test_helper.dart';
import '../../../lib/features/inners/gamification/controllers/gems_controller.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late MockUser user;
  late GemsController controller;

  setUp(() async {
    await FirebaseTestHelper.setupFirebase();
    
    firestore = FirebaseTestHelper.createMockFirestore();
    auth = FirebaseTestHelper.createMockAuth();
    user = auth.currentUser as MockUser;
    
    Get.testMode = true;
    
    await FirebaseTestHelper.populateGamificationData(
      firestore,
      user.uid,
      totalGems: 100,
    );
    
    controller = GemsController(
      firestore: firestore,
      auth: auth,
    );
    
    Get.put<GemsController>(controller);
    
    await Future.delayed(const Duration(milliseconds: 100));
  });

  tearDown(() {
    Get.reset();
  });

  group('GemsController', () {
    test('should load gems from Firestore', () async {
      // Act
      await controller.loadGems();
      
      // Assert
      expect(controller.gems.value, 100);
      expect(controller.isLoading.value, isFalse);
      expect(controller.errorMessage.value, isEmpty);
    });

    test('should add gems to balance', () async {
      // Arrange
      await controller.loadGems();
      final initialGems = controller.gems.value;
      
      // Act
      await controller.addGems(50);
      
      // Assert
      expect(controller.gems.value, initialGems + 50);
    });

    test('should spend gems when balance is sufficient', () async {
      // Arrange
      await controller.loadGems();
      
      // Act
      final result = await controller.spendGems(50);
      
      // Assert
      expect(result, isTrue);
      expect(controller.gems.value, 50);
    });

    test('should not spend gems when balance is insufficient', () async {
      // Arrange
      await controller.loadGems();
      
      // Act
      final result = await controller.spendGems(150);
      
      // Assert
      expect(result, isFalse);
      expect(controller.gems.value, 100); // Unchanged
      expect(controller.errorMessage.value, isNotEmpty);
    });
  });
}
```

### Exemplo 2: Teste com Múltiplos Controllers

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import '../../helpers/firebase_test_helper.dart';
import '../../../lib/features/inners/gamification/controllers/gems_controller.dart';
import '../../../lib/features/inners/gamification/controllers/energy_controller.dart';
import '../../../lib/features/inners/shop/controllers/shop_controller.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late MockUser user;
  late GemsController gemsController;
  late EnergyController energyController;
  late ShopController shopController;

  setUp(() async {
    await FirebaseTestHelper.setupFirebase();
    
    firestore = FirebaseTestHelper.createMockFirestore();
    auth = FirebaseTestHelper.createMockAuth();
    user = auth.currentUser as MockUser;
    
    Get.testMode = true;
    
    await FirebaseTestHelper.populateGamificationData(
      firestore,
      user.uid,
      currentEnergy: 3,
      totalGems: 200,
    );
    
    await FirebaseTestHelper.populateShopItems(firestore);
    
    // Register controllers in order
    gemsController = GemsController(firestore: firestore, auth: auth);
    Get.put<GemsController>(gemsController);
    
    energyController = EnergyController(firestore: firestore, auth: auth);
    Get.put<EnergyController>(energyController);
    
    shopController = ShopController(firestore: firestore, auth: auth);
    Get.put<ShopController>(shopController);
    
    await Future.delayed(const Duration(milliseconds: 100));
  });

  tearDown(() {
    Get.reset();
  });

  group('Shop Purchase Flow', () {
    test('should complete energy refill purchase successfully', () async {
      // Arrange
      await gemsController.loadGems();
      await energyController.loadEnergy();
      
      final initialGems = gemsController.gems.value;
      final initialEnergy = energyController.currentEnergy.value;
      
      // Act
      await shopController.purchaseItem('energy_refill', 50);
      await energyController.refillEnergy();
      
      // Assert
      expect(gemsController.gems.value, initialGems - 50);
      expect(energyController.currentEnergy.value, 5); // Max energy
    });

    test('should show error when insufficient gems', () async {
      // Arrange
      await gemsController.loadGems();
      
      // Spend most gems
      await gemsController.spendGems(180);
      
      // Act
      final result = await shopController.purchaseItem('xp_booster', 100);
      
      // Assert
      expect(result, isFalse);
      expect(shopController.errorMessage.value, contains('insuficientes'));
    });
  });
}
```

### Exemplo 3: Teste de Fluxo Assíncrono

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import '../../helpers/firebase_test_helper.dart';
import '../../../lib/features/core/auth/controllers/auth_credentials_controller.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late AuthCredentialsController controller;

  setUp(() async {
    await FirebaseTestHelper.setupFirebase();
    
    firestore = FirebaseTestHelper.createMockFirestore();
    auth = FirebaseTestHelper.createMockAuth(signedIn: false);
    
    Get.testMode = true;
    
    controller = AuthCredentialsController(
      firestore: firestore,
      auth: auth,
    );
    
    Get.put<AuthCredentialsController>(controller);
    
    await Future.delayed(const Duration(milliseconds: 100));
  });

  tearDown(() {
    Get.reset();
  });

  group('AuthCredentialsController', () {
    test('should set loading state during login', () async {
      // Arrange
      expect(controller.isLoading.value, isFalse);
      
      // Act
      final future = controller.login('test@example.com', 'password123');
      
      // Assert - during loading
      expect(controller.isLoading.value, isTrue);
      
      await future;
      
      // Assert - after loading
      expect(controller.isLoading.value, isFalse);
    });

    test('should login successfully with valid credentials', () async {
      // Act
      await controller.login('test@example.com', 'password123');
      
      // Assert
      expect(auth.currentUser, isNotNull);
      expect(auth.currentUser!.email, 'test@example.com');
      expect(controller.errorMessage.value, isEmpty);
    });

    test('should handle login error gracefully', () async {
      // Act
      await controller.login('invalid@example.com', 'wrong');
      
      // Assert
      expect(auth.currentUser, isNull);
      expect(controller.errorMessage.value, isNotEmpty);
    });
  });
}
```

---

## Boas Práticas

### ✅ DO

- Sempre usar `FirebaseTestHelper` para setup
- Passar mocks via construtor (DI)
- Registrar controllers na ordem correta
- Limpar estado com `Get.reset()` no tearDown
- Usar `await` para operações assíncronas
- Testar estados de loading e erro
- Usar nomes descritivos para testes
- Agrupar testes relacionados com `group()`
- Testar um comportamento por teste

### ❌ DON'T

- Não usar instâncias reais do Firebase
- Não esquecer `Get.testMode = true`
- Não esquecer `Get.reset()` no tearDown
- Não testar múltiplos comportamentos no mesmo teste
- Não usar valores hardcoded (usar constantes)
- Não ignorar erros assíncronos
- Não criar testes flaky (intermitentes)
- Não duplicar código de setup (usar helpers)

---

## Troubleshooting

### Erro: "Bad state: Cannot add new events after calling close"

**Causa:** Controller não foi limpo corretamente.

**Solução:** Adicionar `Get.reset()` no tearDown.

### Erro: "type 'Null' is not a subtype of type 'User'"

**Causa:** Usuário não está logado no mock.

**Solução:** Usar `createMockAuth(signedIn: true)`.

### Erro: "MissingPluginException"

**Causa:** Firebase não foi inicializado.

**Solução:** Adicionar `await FirebaseTestHelper.setupFirebase()` no setUp.

### Erro: Teste passa isoladamente mas falha em suite

**Causa:** Estado compartilhado entre testes.

**Solução:** Garantir que `Get.reset()` está no tearDown e que cada teste é independente.

### Erro: "A controller with tag 'null' is already registered"

**Causa:** Controller não foi limpo entre testes.

**Solução:** Adicionar `Get.reset()` no tearDown.

---

## Recursos Adicionais

- [fake_cloud_firestore](https://pub.dev/packages/fake_cloud_firestore)
- [firebase_auth_mocks](https://pub.dev/packages/firebase_auth_mocks)
- [GetX Testing](https://github.com/jonataslaw/getx#testing)
- [Flutter Testing](https://docs.flutter.dev/testing)

---

## Contato

Para dúvidas ou sugestões sobre testes, consulte a equipe de desenvolvimento.
