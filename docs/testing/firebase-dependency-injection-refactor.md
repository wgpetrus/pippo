# Refatoração Global: Injeção de Dependências para Testabilidade

> **Status:** Planejado para spec futura  
> **Prioridade:** Média (melhoria de qualidade)  
> **Impacto:** ZERO breaking changes - 100% retrocompatível

---

## 📋 Índice

1. [Problema Atual](#problema-atual)
2. [Solução Proposta](#solução-proposta)
3. [Controllers Afetados](#controllers-afetados)
4. [Padrão de Implementação](#padrão-de-implementação)
5. [Mudanças Detalhadas por Controller](#mudanças-detalhadas-por-controller)
6. [Bindings](#bindings)
7. [Exemplo de Uso em Testes](#exemplo-de-uso-em-testes)
8. [Checklist de Implementação](#checklist-de-implementação)
9. [Benefícios](#benefícios)

---

## 🔴 Problema Atual

Atualmente, **TODOS** os controllers instanciam dependências externas diretamente:

```dart
// ❌ Problema: instanciação direta
final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
final _googleSignIn = GoogleSignIn(...);
final _secureStorage = const FlutterSecureStorage();
```

**Consequências:**
- ❌ Impossível criar testes de integração com mocks
- ❌ Dificulta testes unitários isolados
- ❌ Acoplamento forte com Firebase
- ❌ Não permite diferentes configurações (dev/staging/prod)

---

## ✅ Solução Proposta

Adicionar **injeção de dependências opcional** via construtor, mantendo 100% de compatibilidade:

```dart
// ✅ Solução: injeção opcional com fallback
class MyController extends GetxController {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  
  MyController({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;
}
```

**Vantagens:**
- ✅ Código existente continua funcionando EXATAMENTE igual
- ✅ Permite injetar mocks em testes
- ✅ Flexibilidade para diferentes ambientes
- ✅ Melhor testabilidade e manutenibilidade

---

## 📦 Controllers Afetados

### Controllers com Firebase

| Controller | Firestore | Auth | GoogleSignIn | SecureStorage | Prioridade |
|------------|-----------|------|--------------|---------------|------------|
| **LessonController** | ✅ | ✅ | ❌ | ❌ | 🔴 Alta |
| **GamificationController** | ✅ | ⚠️ Inline | ❌ | ❌ | 🔴 Alta |
| **AuthController** | ✅ | ✅ | ✅ | ✅ | 🔴 Alta |
| **OnboardingController** | ✅ | ✅ | ❌ | ❌ | 🟡 Média |
| **SplashController** | ✅ | ✅ | ❌ | ❌ | 🟡 Média |
| **HomeController** | ❌ | ❌ | ❌ | ❌ | ⚪ Não precisa |

**Legenda:**
- ✅ = Usa como field
- ⚠️ = Usa inline (FirebaseAuth.instance.currentUser)
- ❌ = Não usa

---

## 🎯 Padrão de Implementação

### Template Geral

```dart
class MyController extends GetxController {
  // 1. Declarar como final (não mais inicializado diretamente)
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn? _googleSignIn;
  final FlutterSecureStorage _secureStorage;
  
  // 2. Construtor com parâmetros opcionais
  MyController({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FlutterSecureStorage? secureStorage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn,
       _secureStorage = secureStorage ?? const FlutterSecureStorage();
  
  // 3. Resto do código permanece EXATAMENTE igual
  // ...
}
```

### Regras Importantes

1. **Parâmetros sempre opcionais** (`?`) - permite uso sem argumentos
2. **Fallback para instance** - se não fornecido, usa `.instance`
3. **Manter nomes privados** - `_firestore`, `_auth`, etc.
4. **Não mudar lógica** - apenas a forma de inicialização

---

## 📝 Mudanças Detalhadas por Controller

### 1. LessonController 🔴 ALTA PRIORIDADE

**Arquivo:** `lib/features/core/lesson/controllers/lesson_controller.dart`

**Linhas 9-12 (ANTES):**
```dart
class LessonController extends GetxController {
  // Firebase instances
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  
  // Dependências
  late final GamificationController _gamificationController;
```

**Linhas 9-20 (DEPOIS):**
```dart
class LessonController extends GetxController {
  // Firebase instances
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  
  // Dependências
  late final GamificationController _gamificationController;
  
  // Construtor com injeção de dependências
  LessonController({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;
```

**Impacto:** ZERO - código existente funciona igual

---

### 2. GamificationController 🔴 ALTA PRIORIDADE

**Arquivo:** `lib/features/inners/gamification/controllers/gamification_controller.dart`

**Problema adicional:** Usa `FirebaseAuth.instance.currentUser` inline em vários lugares

**Linhas 17-18 (ANTES):**
```dart
class GamificationController extends GetxController {
  // Firebase instances
  final _firestore = FirebaseFirestore.instance;
```

**Linhas 17-25 (DEPOIS):**
```dart
class GamificationController extends GetxController {
  // Firebase instances
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  
  // Construtor com injeção de dependências
  GamificationController({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;
```

**Mudanças adicionais necessárias:**

Substituir todas as ocorrências de `FirebaseAuth.instance.currentUser` por `_auth.currentUser`:

```dart
// ANTES (linha 82, 287, 337, 384, 431, 550, 632, 672)
final userId = FirebaseAuth.instance.currentUser?.uid;

// DEPOIS
final userId = _auth.currentUser?.uid;
```

**Total de substituições:** ~8 ocorrências

---

### 3. AuthController 🔴 ALTA PRIORIDADE

**Arquivo:** `lib/features/core/auth/controllers/auth_controller.dart`

**Linhas 38-44 (ANTES):**
```dart
  // Firebase instances
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _secureStorage = const FlutterSecureStorage();
  final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
```

**Linhas 38-55 (DEPOIS):**
```dart
  // Firebase instances
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FlutterSecureStorage _secureStorage;
  final GoogleSignIn _googleSignIn;
  
  // Construtor com injeção de dependências
  AuthController({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FlutterSecureStorage? secureStorage,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _googleSignIn = googleSignIn ?? GoogleSignIn(
         scopes: ['email', 'profile'],
       );
```

**Impacto:** ZERO - código existente funciona igual

---

### 4. OnboardingController 🟡 MÉDIA PRIORIDADE

**Arquivo:** `lib/features/core/onboarding/controllers/onboarding_controller.dart`

**Linhas 33-35 (ANTES):**
```dart
  // Firebase
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
```

**Linhas 33-42 (DEPOIS):**
```dart
  // Firebase
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  
  // Construtor com injeção de dependências
  OnboardingController({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;
```

**Impacto:** ZERO - código existente funciona igual

---

### 5. SplashController 🟡 MÉDIA PRIORIDADE

**Arquivo:** `lib/features/inners/splash/controllers/splash_controller.dart`

**Linhas 16-19 (ANTES):**
```dart
class SplashController extends GetxController {
  // Instâncias Firebase
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
```

**Linhas 16-26 (DEPOIS):**
```dart
class SplashController extends GetxController {
  // Instâncias Firebase
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  
  // Construtor com injeção de dependências
  SplashController({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;
```

**Impacto:** ZERO - código existente funciona igual

---

## 🔗 Bindings

Se os controllers forem registrados via Bindings, os bindings também precisam suportar injeção opcional.

### Padrão para Bindings

```dart
class MyBinding extends Bindings {
  // Dependências opcionais para testes
  final FirebaseFirestore? firestore;
  final FirebaseAuth? auth;
  final GoogleSignIn? googleSignIn;
  final FlutterSecureStorage? secureStorage;
  
  // Construtor opcional
  MyBinding({
    this.firestore,
    this.auth,
    this.googleSignIn,
    this.secureStorage,
  });
  
  @override
  void dependencies() {
    Get.lazyPut<MyController>(
      () => MyController(
        firestore: firestore,
        auth: auth,
        googleSignIn: googleSignIn,
        secureStorage: secureStorage,
      ),
    );
  }
}
```

### Bindings Afetados

#### 1. LessonBinding

**Arquivo:** `lib/features/core/lesson/bindings/lesson_binding.dart` (se existir)

```dart
class LessonBinding extends Bindings {
  final FirebaseFirestore? firestore;
  final FirebaseAuth? auth;
  
  LessonBinding({this.firestore, this.auth});
  
  @override
  void dependencies() {
    Get.lazyPut<LessonController>(
      () => LessonController(
        firestore: firestore,
        auth: auth,
      ),
    );
  }
}
```

#### 2. AuthBinding

**Arquivo:** `lib/features/core/auth/bindings/auth_binding.dart`

```dart
class AuthBinding extends Bindings {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;
  final GoogleSignIn? googleSignIn;
  final FlutterSecureStorage? secureStorage;
  
  AuthBinding({
    this.auth,
    this.firestore,
    this.googleSignIn,
    this.secureStorage,
  });
  
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(
      () => AuthController(
        auth: auth,
        firestore: firestore,
        googleSignIn: googleSignIn,
        secureStorage: secureStorage,
      ),
    );
  }
}
```

#### 3. OnboardingBinding

**Arquivo:** `lib/features/core/onboarding/bindings/onboarding_binding.dart`

```dart
class OnboardingBinding extends Bindings {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;
  
  OnboardingBinding({this.auth, this.firestore});
  
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(
      () => OnboardingController(
        auth: auth,
        firestore: firestore,
      ),
    );
  }
}
```

#### 4. SplashBinding

**Arquivo:** `lib/features/inners/splash/bindings/splash_binding.dart`

```dart
class SplashBinding extends Bindings {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;
  
  SplashBinding({this.auth, this.firestore});
  
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
      () => SplashController(
        auth: auth,
        firestore: firestore,
      ),
    );
  }
}
```

#### 5. HomeBinding

**Arquivo:** `lib/features/inners/home/bindings/home_binding.dart`

```dart
class HomeBinding extends Bindings {
  // HomeController não precisa de injeção (não usa Firebase diretamente)
  
  @override
  void dependencies() {
    // Garantir que GamificationController está disponível
    if (!Get.isRegistered<GamificationController>()) {
      Get.put<GamificationController>(GamificationController());
    }
    
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
```

---

## 🧪 Exemplo de Uso em Testes

### Setup Completo de Teste

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockGoogleSignIn mockGoogleSignIn;
  late FlutterSecureStorage mockSecureStorage;

  setUp(() async {
    // Initialize mocks
    fakeFirestore = FakeFirebaseFirestore();
    mockUser = MockUser(
      uid: 'test-user-id',
      email: 'test@example.com',
      displayName: 'Test User',
    );
    mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    mockGoogleSignIn = MockGoogleSignIn();
    mockSecureStorage = MockSecureStorage(); // Criar mock se necessário

    // Setup Firebase test helper
    await FirebaseTestHelper.setupFirebase();

    // Initialize GetX
    Get.testMode = true;

    // Setup initial data
    await _setupUserData(fakeFirestore, mockUser.uid);

    // Initialize controllers with mocks
    final gamificationController = GamificationController(
      firestore: fakeFirestore,
      auth: mockAuth,
    );
    Get.put<GamificationController>(gamificationController);

    final lessonController = LessonController(
      firestore: fakeFirestore,
      auth: mockAuth,
    );
    Get.put<LessonController>(lessonController);

    final authController = AuthController(
      auth: mockAuth,
      firestore: fakeFirestore,
      googleSignIn: mockGoogleSignIn,
      secureStorage: mockSecureStorage,
    );
    Get.put<AuthController>(authController);

    // Wait for controllers to initialize
    await Future.delayed(const Duration(milliseconds: 100));
  });

  tearDown(() {
    Get.reset();
  });

  group('Integration Tests', () {
    test('should complete full lesson flow', () async {
      // Arrange
      await _setupLessonData(fakeFirestore, 'course1', '1');

      // Act
      await lessonController.startLesson('course1', '1');

      // Assert
      expect(lessonController.isLoading.value, false);
      expect(lessonController.errorMessage.value, isEmpty);
      expect(lessonController.hearts.value, 3);
    });

    test('should authenticate with Google', () async {
      // Arrange
      mockGoogleSignIn.setIsCanceled(false);

      // Act
      await authController.signInWithGoogle();

      // Assert
      expect(authController.errorMessage.value, isEmpty);
      expect(mockAuth.currentUser, isNotNull);
    });
  });
}

Future<void> _setupUserData(FakeFirebaseFirestore firestore, String userId) async {
  await firestore
      .collection('users')
      .doc(userId)
      .collection('stats')
      .doc('gamification')
      .set({
    'currentEnergy': 5,
    'xp': {'totalXp': 0, 'level': 1},
    'gems': {'totalGems': 0},
    'streak': {'currentStreak': 0},
  });
}

Future<void> _setupLessonData(
  FakeFirebaseFirestore firestore,
  String courseId,
  String lessonId,
) async {
  await firestore
      .collection('courses')
      .doc(courseId)
      .collection('lessons')
      .doc(lessonId)
      .set({
    'id': lessonId,
    'xpReward': 10,
    'gemsReward': 1,
  });
}
```

### Teste com Binding

```dart
test('should work with binding', () async {
  // Arrange
  final binding = LessonBinding(
    firestore: fakeFirestore,
    auth: mockAuth,
  );
  binding.dependencies();

  // Act
  final controller = Get.find<LessonController>();

  // Assert
  expect(controller, isNotNull);
});
```

---

## ✅ Checklist de Implementação

### Fase 1: Controllers Core (Alta Prioridade)

- [ ] **LessonController**
  - [ ] Adicionar construtor com injeção de dependências
  - [ ] Testar que código existente funciona
  - [ ] Criar testes de integração com mocks
  - [ ] Atualizar LessonBinding (se existir)

- [ ] **GamificationController**
  - [ ] Adicionar construtor com injeção de dependências
  - [ ] Substituir `FirebaseAuth.instance.currentUser` por `_auth.currentUser` (~8 ocorrências)
  - [ ] Testar que código existente funciona
  - [ ] Criar testes de integração com mocks
  - [ ] Atualizar binding (se existir)

- [ ] **AuthController**
  - [ ] Adicionar construtor com injeção de dependências
  - [ ] Incluir GoogleSignIn e FlutterSecureStorage
  - [ ] Testar que código existente funciona
  - [ ] Criar testes de integração com mocks
  - [ ] Atualizar AuthBinding

### Fase 2: Controllers Secundários (Média Prioridade)

- [ ] **OnboardingController**
  - [ ] Adicionar construtor com injeção de dependências
  - [ ] Testar que código existente funciona
  - [ ] Criar testes de integração com mocks
  - [ ] Atualizar OnboardingBinding

- [ ] **SplashController**
  - [ ] Adicionar construtor com injeção de dependências
  - [ ] Testar que código existente funciona
  - [ ] Criar testes de integração com mocks
  - [ ] Atualizar SplashBinding

### Fase 3: Testes

- [ ] **Criar helper de teste global**
  - [ ] Função para setup de mocks Firebase
  - [ ] Função para setup de dados iniciais
  - [ ] Função para criar controllers com mocks

- [ ] **Testes de integração end-to-end**
  - [ ] Fluxo completo de lição
  - [ ] Fluxo de autenticação
  - [ ] Fluxo de onboarding
  - [ ] Fluxo de gamificação

- [ ] **Testes unitários isolados**
  - [ ] Validações de exercícios
  - [ ] Cálculos de recompensas
  - [ ] Lógica de streak
  - [ ] Lógica de energia

### Fase 4: Documentação

- [ ] Atualizar README com padrão de injeção
- [ ] Documentar como criar novos controllers
- [ ] Documentar como criar testes com mocks
- [ ] Adicionar exemplos de testes

---

## 🎁 Benefícios

### Para Desenvolvimento

1. **Testabilidade Completa**
   - Testes de integração com Firebase mockado
   - Testes unitários isolados
   - Testes de fluxos completos end-to-end

2. **Flexibilidade**
   - Diferentes configurações por ambiente (dev/staging/prod)
   - Fácil trocar implementações
   - Suporte a feature flags

3. **Debugging**
   - Mais fácil isolar problemas
   - Logs mais claros
   - Reprodução de bugs em testes

### Para Qualidade

1. **Cobertura de Testes**
   - Aumenta cobertura de testes significativamente
   - Testes mais confiáveis
   - Menos bugs em produção

2. **Manutenibilidade**
   - Código mais desacoplado
   - Mais fácil refatorar
   - Menos efeitos colaterais

3. **Confiança**
   - Testes garantem que mudanças não quebram funcionalidades
   - CI/CD mais robusto
   - Deploy mais seguro

### Para Time

1. **Produtividade**
   - Testes mais rápidos (não precisam de Firebase real)
   - Desenvolvimento paralelo facilitado
   - Onboarding de novos devs mais fácil

2. **Padrão Consistente**
   - Todos os controllers seguem mesmo padrão
   - Fácil entender código de outros
   - Menos discussões sobre arquitetura

---

## 📊 Estimativa de Esforço

| Fase | Tempo Estimado | Complexidade |
|------|----------------|--------------|
| Fase 1: Controllers Core | 4-6 horas | Média |
| Fase 2: Controllers Secundários | 2-3 horas | Baixa |
| Fase 3: Testes | 6-8 horas | Alta |
| Fase 4: Documentação | 2-3 horas | Baixa |
| **TOTAL** | **14-20 horas** | **Média** |

**Nota:** Tempo pode variar dependendo da familiaridade com testes e mocks.

---

## 🚨 Riscos e Mitigações

### Risco 1: Breaking Changes Acidentais

**Mitigação:**
- Testar TUDO após cada mudança
- Manter fallback para `.instance`
- Fazer em PRs pequenos e isolados
- Code review rigoroso

### Risco 2: Testes Complexos

**Mitigação:**
- Começar com testes simples
- Criar helpers reutilizáveis
- Documentar bem os exemplos
- Pair programming nos primeiros testes

### Risco 3: Tempo de Implementação

**Mitigação:**
- Fazer em fases (não tudo de uma vez)
- Priorizar controllers mais críticos
- Pode ser feito incrementalmente
- Não bloqueia desenvolvimento de features

---

## 🎯 Próximos Passos

1. **Criar spec detalhada** para implementação
2. **Definir prioridade** de controllers
3. **Alocar tempo** no sprint
4. **Começar pela Fase 1** (controllers core)
5. **Iterar** baseado em feedback

---

## 📚 Referências

- [GetX Dependency Injection](https://github.com/jonataslaw/getx#dependency-management)
- [Firebase Testing Best Practices](https://firebase.google.com/docs/rules/unit-tests)
- [Fake Cloud Firestore](https://pub.dev/packages/fake_cloud_firestore)
- [Firebase Auth Mocks](https://pub.dev/packages/firebase_auth_mocks)
- [Google Sign In Mocks](https://pub.dev/packages/google_sign_in_mocks)

---

## 💡 Notas Importantes

1. **Esta refatoração é OPCIONAL** - o app funciona perfeitamente sem ela
2. **ZERO breaking changes** - código existente continua funcionando
3. **Pode ser feito incrementalmente** - não precisa fazer tudo de uma vez
4. **Foco em qualidade** - objetivo é melhorar testes, não adicionar features
5. **Documentação é chave** - manter este documento atualizado

---

**Última atualização:** 2026-01-23  
**Autor:** Kiro AI  
**Status:** Aguardando aprovação para spec futura
