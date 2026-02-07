# Firebase Mock Setup para Testes

> Solução para problema de inicialização do Firebase em testes

---

## Status

✅ **Firebase Core inicializa corretamente**  
⚠️ **Firebase Auth e Firestore requerem mocks adicionais para testes completos**

---

## Problema Original

Testes que usam Firebase (Auth, Firestore) falhavam com erro de inicialização:
```
Firebase not initialized
```

## Solução Implementada

Criado helper centralizado em `test/helpers/firebase_test_helper.dart` que:

1. ✅ Inicializa Firebase Core com mocks customizados
2. ✅ Cria MockFirebaseAuth configurável
3. ✅ Cria FakeFirebaseFirestore
4. ✅ Popula dados de teste (gamification, lessons, exercises)

### Limitação Atual

Os controllers usam instâncias singleton do Firebase (`FirebaseAuth.instance`, `FirebaseFirestore.instance`), o que dificulta o mock completo em testes.

**Solução temporária:** Testar métodos puros que não dependem de Firebase.

**Solução futura:** Refatorar controllers para aceitar Firebase instances via dependency injection.

---

## Como Usar (Para Métodos Puros)

### Setup Básico

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pippo/features/core/lesson/controllers/lesson_flow_controller.dart';

import '../../../../helpers/firebase_test_helper.dart';

void main() {
  setUpAll(() async {
    // Inicializa Firebase Core
    await FirebaseTestHelper.setupFirebase();
  });

  test('test pure method', () {
    Get.testMode = true;
    
    // Nota: Controllers tentarão acessar Firebase Auth
    // Isso causará erro, mas o teste pode prosseguir se testar apenas métodos puros
    
    final controller = LessonFlowController();
    
    // Testar método puro
    expect(controller.somePublicMethod(), equals(expectedValue));
    
    Get.reset();
  });
}
```

---

## Métodos Disponíveis

### setupFirebase()
Inicializa Firebase Core com mocks. Chamar em `setUpAll()`.

### createMockAuth()
Cria MockFirebaseAuth com usuário logado.

**Parâmetros:**
- `signedIn` (bool) - default: true
- `uid` (String) - default: 'test-user-id'
- `email` (String) - default: 'test@example.com'

### createMockFirestore()
Cria FakeFirebaseFirestore vazio.

### populateGamificationData()
Popula dados de gamification no Firestore.

**Parâmetros:**
- `firestore` (FakeFirebaseFirestore) - instância do Firestore
- `userId` (String) - ID do usuário
- `currentEnergy` (int) - default: 5
- `totalGems` (int) - default: 100
- `totalXp` (int) - default: 0
- `currentLevel` (int) - default: 1
- `hasXpBooster` (bool) - default: false
- `hasGemMultiplier` (bool) - default: false
- `hasUnlimitedEnergy` (bool) - default: false

### populateLessonData()
Popula dados de lição no Firestore.

**Parâmetros:**
- `firestore` (FakeFirebaseFirestore)
- `courseId` (String)
- `lessonId` (String)
- `xpReward` (int) - default: 10
- `gemsReward` (int) - default: 1

### populateExercises()
Popula exercícios de uma lição.

**Parâmetros:**
- `firestore` (FakeFirebaseFirestore)
- `courseId` (String)
- `lessonId` (String)
- `exercises` (List<Map<String, dynamic>>)

### populateLessonProgress()
Popula progresso de lições do usuário.

**Parâmetros:**
- `firestore` (FakeFirebaseFirestore)
- `userId` (String)
- `courseId` (String)
- `lessonId` (String)
- `status` (String) - default: 'completed'

---

## Testes Funcionando

✅ `test/unit/features/core/lesson/lesson_xp_calculation_test.dart` - Testa métodos puros de cálculo de XP

**Testes que precisam de refatoração:**
- `test/property/features/core/lesson/xp_distribution_property_test.dart` - Requer mock completo de Firebase Auth
- Outros testes em `test/_disabled/` - Requerem refatoração dos controllers

---

## Próximos Passos

1. **Refatorar Controllers** - Aceitar Firebase instances via dependency injection
2. **Criar Mocks Completos** - Mock completo de Firebase Auth e Firestore
3. **Atualizar Testes Desabilitados** - Mover testes de `test/_disabled/` de volta para pastas ativas

---

## Troubleshooting

### Erro: "Firebase not initialized"
**Solução:** Adicionar `await FirebaseTestHelper.setupFirebase()` em `setUpAll()`

### Erro: "Unable to establish connection on channel"
**Causa:** Controller tentando acessar Firebase Auth/Firestore singleton  
**Solução:** Testar apenas métodos puros que não dependem de Firebase, ou refatorar controller para dependency injection

### Erro: "User not authenticated"
**Causa:** Firebase Auth não está mockado completamente  
**Solução:** Aguardar refatoração dos controllers para dependency injection

### Erro: "Document not found"
**Causa:** Dados não populados no Firestore mockado  
**Solução:** Popular dados necessários com `populateGamificationData()`, `populateLessonData()`, etc.

---

## Regras

1. ✅ Sempre chamar `FirebaseTestHelper.setupFirebase()` em `setUpAll()`
2. ✅ Sempre chamar `Get.reset()` em `tearDown()`
3. ✅ Usar `Get.testMode = true` em `setUp()`
4. ⚠️ Testar apenas métodos puros até refatoração dos controllers
5. ⚠️ Controllers que acessam Firebase singleton causarão erros em `onInit()`
