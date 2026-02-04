# Correção: Gamificação por Curso

## 🎯 Objetivo

Fazer com que os dados de gamificação (XP, streak, gems, energy) sejam **por curso** ao invés de globais.

## ❌ Problema Atual

**Estrutura Atual (INCORRETA):**
```
users/{userId}/
├── stats/
│   └── gamification/  ← GLOBAL (errado!)
│       ├── xp: 20
│       ├── streak: 1
│       ├── gems: 0
│       └── energy: 5
│
└── courses/
    ├── {courseId1}/ (Chinês - ativo)
    │   └── progress/ (1 lição completada)
    │
    └── {courseId2}/ (Alemão - novo)
        └── progress/ (vazio)
```

**Comportamento Atual:**
- ✅ Bandeira atualiza para Alemão
- ❌ XP continua 20 (do Chinês)
- ❌ Streak continua 1 (do Chinês)
- ❌ Gems continuam 0 (do Chinês)
- ❌ Energy continua 5 (do Chinês)

## ✅ Solução

**Estrutura Nova (CORRETA):**
```
users/{userId}/
└── courses/
    ├── {courseId1}/ (Chinês)
    │   ├── language: "zh"
    │   ├── isActive: false
    │   ├── progress/ (1 lição completada)
    │   └── stats/  ← POR CURSO (correto!)
    │       └── gamification/
    │           ├── xp: 20
    │           ├── streak: 1
    │           ├── gems: 0
    │           └── energy: 5
    │
    └── {courseId2}/ (Alemão)
        ├── language: "de"
        ├── isActive: true
        ├── progress/ (vazio)
        └── stats/  ← POR CURSO (correto!)
            └── gamification/
                ├── xp: 0  ← Começa do zero!
                ├── streak: 0
                ├── gems: 0
                └── energy: 5
```

**Comportamento Esperado:**
- ✅ Bandeira atualiza para Alemão
- ✅ XP reseta para 0 (curso novo)
- ✅ Streak reseta para 0 (curso novo)
- ✅ Gems resetam para 0 (curso novo)
- ✅ Energy reseta para 5 (curso novo)
- ✅ Ao voltar para Chinês, XP volta para 20 (mantido)

## 📝 Mudanças Necessárias

### 1. Migrar Estrutura do Firestore

**Arquivo:** Script de migração (criar novo)
**Ação:** Mover `users/{userId}/stats/gamification` para `users/{userId}/courses/{courseId}/stats/gamification`

### 2. Atualizar OnboardingController

**Arquivo:** `lib/features/core/onboarding/controllers/onboarding_controller.dart`

**Método `finalizeAccount()` (linha ~850):**
```dart
// ANTES (errado):
final statsRef = userRef.collection('stats').doc('gamification');

// DEPOIS (correto):
final statsRef = courseRef.collection('stats').doc('gamification');
```

**Método `addNewCourse()` (linha ~897):**
```dart
// ADICIONAR após criar curso:
// Criar stats iniciais do novo curso
final statsRef = courseRef.collection('stats').doc('gamification');
batch.set(statsRef, {
  'xp': 0,
  'level': 1,
  'streak': 0,
  'energy': 5,
  'gems': 0,
  'hearts': 5,
  'lastActiveAt': FieldValue.serverTimestamp(),
});
```

### 3. Atualizar GamificationController

**Arquivo:** `lib/features/inners/gamification/controllers/gamification_controller.dart`

**Método `loadStats()` (linha ~120):**
```dart
// ANTES (errado):
final doc = await _firestore
    .collection('users')
    .doc(userId)
    .collection('stats')
    .doc('gamification')
    .get();

// DEPOIS (correto):
// 1. Buscar curso ativo
final coursesSnapshot = await _firestore
    .collection('users')
    .doc(userId)
    .collection('courses')
    .where('isActive', isEqualTo: true)
    .limit(1)
    .get();

if (coursesSnapshot.docs.isEmpty) {
  errorMessage.value = 'Nenhum curso ativo encontrado.';
  return;
}

final courseId = coursesSnapshot.docs.first.id;

// 2. Buscar stats do curso ativo
final doc = await _firestore
    .collection('users')
    .doc(userId)
    .collection('courses')
    .doc(courseId)
    .collection('stats')
    .doc('gamification')
    .get();
```

**Método `_saveStats()` (linha ~200):**
```dart
// ANTES (errado):
await _firestore
    .collection('users')
    .doc(userId)
    .collection('stats')
    .doc('gamification')
    .set({...});

// DEPOIS (correto):
// 1. Buscar curso ativo
final coursesSnapshot = await _firestore
    .collection('users')
    .doc(userId)
    .collection('courses')
    .where('isActive', isEqualTo: true)
    .limit(1)
    .get();

if (coursesSnapshot.docs.isEmpty) {
  throw Exception('Nenhum curso ativo encontrado.');
}

final courseId = coursesSnapshot.docs.first.id;

// 2. Salvar stats no curso ativo
await _firestore
    .collection('users')
    .doc(userId)
    .collection('courses')
    .doc(courseId)
    .collection('stats')
    .doc('gamification')
    .set({...});
```

**Método `_createInitialStats()` (linha ~280):**
```dart
// ANTES (errado):
await _firestore
    .collection('users')
    .doc(userId)
    .collection('stats')
    .doc('gamification')
    .set({...});

// DEPOIS (correto):
// 1. Buscar curso ativo
final coursesSnapshot = await _firestore
    .collection('users')
    .doc(userId)
    .collection('courses')
    .where('isActive', isEqualTo: true)
    .limit(1)
    .get();

if (coursesSnapshot.docs.isEmpty) {
  debugPrint('⚠️ Nenhum curso ativo. Aguardando onboarding.');
  return;
}

final courseId = coursesSnapshot.docs.first.id;

// 2. Criar stats no curso ativo
await _firestore
    .collection('users')
    .doc(userId)
    .collection('courses')
    .doc(courseId)
    .collection('stats')
    .doc('gamification')
    .set({...});
```

**Método `_recordLessonHistory()` (linha ~650):**
```dart
// ANTES (errado):
await _firestore
    .collection('users')
    .doc(userId)
    .collection('stats')
    .doc('gamification')
    .collection('history')
    .add({...});

// DEPOIS (correto):
// 1. Buscar curso ativo
final coursesSnapshot = await _firestore
    .collection('users')
    .doc(userId)
    .collection('courses')
    .where('isActive', isEqualTo: true)
    .limit(1)
    .get();

if (coursesSnapshot.docs.isEmpty) return;

final courseId = coursesSnapshot.docs.first.id;

// 2. Salvar histórico no curso ativo
await _firestore
    .collection('users')
    .doc(userId)
    .collection('courses')
    .doc(courseId)
    .collection('stats')
    .doc('gamification')
    .collection('history')
    .add({...});
```

### 4. Atualizar HomeController

**Arquivo:** `lib/features/inners/home/controllers/home_controller.dart`

**Método `switchActiveCourse()` (linha ~450):**
```dart
// ADICIONAR após batch.commit():
// Recarregar stats do novo curso
if (Get.isRegistered<GamificationController>()) {
  final gamificationController = Get.find<GamificationController>();
  await gamificationController.loadStats();
}
```

## 🧪 Testes Necessários

### Teste 1: Novo Usuário
1. [ ] Completar onboarding (Chinês)
2. [ ] Verificar Firestore: `users/{userId}/courses/{courseId}/stats/gamification` existe
3. [ ] Verificar stats: xp=0, streak=0, gems=0, energy=5

### Teste 2: Adicionar Curso
1. [ ] Ter curso Chinês com xp=20, streak=1
2. [ ] Adicionar curso Alemão
3. [ ] Verificar Firestore: Alemão tem `stats/gamification` com xp=0
4. [ ] Verificar UI: xp=0, streak=0, gems=0, energy=5

### Teste 3: Trocar Curso
1. [ ] Ter Chinês (xp=20) e Alemão (xp=0)
2. [ ] Trocar para Alemão
3. [ ] Verificar UI: xp=0, streak=0
4. [ ] Trocar para Chinês
5. [ ] Verificar UI: xp=20, streak=1 (mantido)

### Teste 4: Completar Lição
1. [ ] Estar em Alemão (xp=0)
2. [ ] Completar lição (+10 XP)
3. [ ] Verificar UI: xp=10
4. [ ] Trocar para Chinês
5. [ ] Verificar UI: xp=20 (não mudou)
6. [ ] Trocar para Alemão
7. [ ] Verificar UI: xp=10 (mantido)

## ⚠️ Cuidados

1. **Não quebrar usuários existentes:** Criar script de migração para mover stats antigas
2. **Manter progresso:** Cada curso mantém suas próprias stats
3. **Curso ativo:** Sempre buscar curso ativo antes de carregar/salvar stats
4. **Performance:** Cache do courseId ativo para evitar queries repetidas
5. **Histórico:** Histórico também deve ser por curso

## 📊 Ordem de Implementação

1. ✅ Atualizar `OnboardingController.finalizeAccount()` - criar stats no curso
2. ✅ Atualizar `OnboardingController.addNewCourse()` - criar stats no novo curso
3. ✅ Atualizar `GamificationController.loadStats()` - buscar stats do curso ativo
4. ✅ Atualizar `GamificationController._saveStats()` - salvar stats no curso ativo
5. ✅ Atualizar `GamificationController._createInitialStats()` - criar no curso ativo
6. ✅ Atualizar `GamificationController._recordLessonHistory()` - histórico no curso
7. ✅ Atualizar `HomeController.switchActiveCourse()` - recarregar stats ao trocar
8. ✅ Testar fluxo completo
9. ✅ Criar script de migração para usuários existentes

## 🎯 Resultado Final

**Ao adicionar novo curso:**
- ✅ Bandeira muda para novo idioma
- ✅ XP reseta para 0
- ✅ Streak reseta para 0
- ✅ Gems resetam para 0
- ✅ Energy reseta para 5
- ✅ Progresso do curso anterior mantido

**Ao voltar para curso anterior:**
- ✅ Bandeira volta para idioma anterior
- ✅ XP volta para valor anterior
- ✅ Streak volta para valor anterior
- ✅ Gems voltam para valor anterior
- ✅ Energy volta para valor anterior
- ✅ Progresso mantido
