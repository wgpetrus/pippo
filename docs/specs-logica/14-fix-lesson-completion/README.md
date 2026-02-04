# Fix: Erro ao Salvar Progresso ao Completar Lição

> **Status:** ✅ Completo
>
> **Data:** 2026-02-04

---

## Problemas Resolvidos

### Problema 1: Erro ao Salvar Progresso

Ao completar uma lição e receber recompensas, ocorriam dois erros:

#### Erro 1.1: "Dados do usuário não encontrados" (Tentativa 1)

```
📝 Step 2: Distribuindo XP...
❌ Exception na tentativa 1: Exception: Dados do usuário não encontrados
```

**Causa:** Métodos do `LessonController` buscavam stats em `users/{userId}/stats/gamification` (estrutura antiga), mas a estrutura correta é `users/{userId}/courses/{courseId}/stats/gamification` (por curso).

#### Erro 1.2: "Bad state: Future already completed" (Tentativas 2-3)

```
E/flutter: Bad state: Future already completed
❌ Exception na tentativa 2: Exception: Erro ao distribuir XP: null
```

**Causa:** Transação do Firestore sendo completada múltiplas vezes devido ao retry mechanism tentando executar transação já completada.

### Problema 2: Label de Avaliação Incorreto

Ao completar lição com 50% de acerto, o card mostrava "Excelente" embaixo da porcentagem.

**Causa:** Label estava fixo como `isPerfect ? 'Perfeito!' : 'Excelente'`, sem considerar faixas intermediárias de accuracy.

---

## Soluções Implementadas

### Solução 1: Atualização da Estrutura de Stats

Após a migração da gamificação para estrutura por curso (Task 4), 4 métodos do `LessonController` foram atualizados para usar a estrutura correta:

```dart
// ❌ ESTRUTURA ANTIGA (INCORRETA)
final statsRef = _firestore
    .collection('users')
    .doc(userId)
    .collection('stats')
    .doc('gamification');

// ✅ ESTRUTURA NOVA (CORRETA)
final statsRef = _firestore
    .collection('users')
    .doc(userId)
    .collection('courses')
    .doc(courseId)  // ← curso ativo
    .collection('stats')
    .doc('gamification');
```

### Solução 2: Sistema de Avaliação por Faixas

Criado método `getAccuracyLabel()` no `LessonController` que retorna label baseado na porcentagem:

```dart
/// Retorna o label de avaliação baseado na accuracy
/// 
/// Faixas:
/// - 100%: Perfeito!
/// - 90-99%: Excelente
/// - 70-89%: Muito Bom
/// - 50-69%: Bom
/// - <50%: Continue Praticando
String getAccuracyLabel() {
  if (accuracy == 100.0) return 'Perfeito!';
  if (accuracy >= 90.0) return 'Excelente';
  if (accuracy >= 70.0) return 'Muito Bom';
  if (accuracy >= 50.0) return 'Bom';
  return 'Continue Praticando';
}
```

---

## Métodos Corrigidos

### 1. `_distributeXP()` (linha ~1092)

**Antes:**
```dart
Future<void> _distributeXP(int xpAmount) async {
  final userId = _auth.currentUser?.uid;
  if (userId == null) throw Exception('Usuário não autenticado');
  
  final statsRef = _firestore
      .collection('users')
      .doc(userId)
      .collection('stats')  // ❌ ERRADO
      .doc('gamification');
  // ...
}
```

**Depois:**
```dart
Future<void> _distributeXP(int xpAmount) async {
  final userId = _auth.currentUser?.uid;
  if (userId == null) throw Exception('Usuário não autenticado');
  
  // Buscar curso ativo
  final coursesSnapshot = await _firestore
      .collection('users')
      .doc(userId)
      .collection('courses')
      .where('isActive', isEqualTo: true)
      .limit(1)
      .get();

  if (coursesSnapshot.docs.isEmpty) {
    throw Exception('Nenhum curso ativo encontrado');
  }

  final courseId = coursesSnapshot.docs.first.id;
  
  final statsRef = _firestore
      .collection('users')
      .doc(userId)
      .collection('courses')
      .doc(courseId)  // ✅ CORRETO
      .collection('stats')
      .doc('gamification');
  // ...
}
```

### 2. `_checkAndLevelUp()` (linha ~1130)

**Antes:**
```dart
Future<bool> _checkAndLevelUp() async {
  final userId = _auth.currentUser?.uid;
  if (userId == null) throw Exception('Usuário não autenticado');
  
  final statsRef = _firestore
      .collection('users')
      .doc(userId)
      .collection('stats')  // ❌ ERRADO
      .doc('gamification');
  // ...
}
```

**Depois:**
```dart
Future<bool> _checkAndLevelUp() async {
  final userId = _auth.currentUser?.uid;
  if (userId == null) throw Exception('Usuário não autenticado');
  
  // Buscar curso ativo
  final coursesSnapshot = await _firestore
      .collection('users')
      .doc(userId)
      .collection('courses')
      .where('isActive', isEqualTo: true)
      .limit(1)
      .get();

  if (coursesSnapshot.docs.isEmpty) {
    throw Exception('Nenhum curso ativo encontrado');
  }

  final courseId = coursesSnapshot.docs.first.id;
  
  final statsRef = _firestore
      .collection('users')
      .doc(userId)
      .collection('courses')
      .doc(courseId)  // ✅ CORRETO
      .collection('stats')
      .doc('gamification');
  // ...
}
```

### 3. `_addGems()` (linha ~1200)

**Antes:**
```dart
Future<void> _addGems(int gemsAmount) async {
  final userId = _auth.currentUser?.uid;
  if (userId == null) throw Exception('Usuário não autenticado');
  
  final statsRef = _firestore
      .collection('users')
      .doc(userId)
      .collection('stats')  // ❌ ERRADO
      .doc('gamification');
  // ...
}
```

**Depois:**
```dart
Future<void> _addGems(int gemsAmount) async {
  final userId = _auth.currentUser?.uid;
  if (userId == null) throw Exception('Usuário não autenticado');
  
  // Buscar curso ativo
  final coursesSnapshot = await _firestore
      .collection('users')
      .doc(userId)
      .collection('courses')
      .where('isActive', isEqualTo: true)
      .limit(1)
      .get();

  if (coursesSnapshot.docs.isEmpty) {
    throw Exception('Nenhum curso ativo encontrado');
  }

  final courseId = coursesSnapshot.docs.first.id;
  
  final statsRef = _firestore
      .collection('users')
      .doc(userId)
      .collection('courses')
      .doc(courseId)  // ✅ CORRETO
      .collection('stats')
      .doc('gamification');
  // ...
}
```

### 4. `_updateStreak()` (linha ~1000)

**Antes:**
```dart
Future<void> _updateStreak() async {
  final userId = _auth.currentUser?.uid;
  if (userId == null) throw Exception('Usuário não autenticado');
  
  final statsRef = _firestore
      .collection('users')
      .doc(userId)
      .collection('stats')  // ❌ ERRADO
      .doc('gamification');
  // ...
}
```

**Depois:**
```dart
Future<void> _updateStreak() async {
  final userId = _auth.currentUser?.uid;
  if (userId == null) throw Exception('Usuário não autenticado');
  
  // Buscar curso ativo
  final coursesSnapshot = await _firestore
      .collection('users')
      .doc(userId)
      .collection('courses')
      .where('isActive', isEqualTo: true)
      .limit(1)
      .get();

  if (coursesSnapshot.docs.isEmpty) {
    throw Exception('Nenhum curso ativo encontrado');
  }

  final courseId = coursesSnapshot.docs.first.id;
  
  final statsRef = _firestore
      .collection('users')
      .doc(userId)
      .collection('courses')
      .doc(courseId)  // ✅ CORRETO
      .collection('stats')
      .doc('gamification');
  // ...
}
```

### 5. `getAccuracyLabel()` (NOVO)

Método criado para retornar label de avaliação baseado na accuracy:

```dart
String getAccuracyLabel() {
  if (accuracy == 100.0) return 'Perfeito!';
  if (accuracy >= 90.0) return 'Excelente';
  if (accuracy >= 70.0) return 'Muito Bom';
  if (accuracy >= 50.0) return 'Bom';
  return 'Continue Praticando';
}
```

---

## Métodos NÃO Alterados

### `_updateDailyHistory()`

**Mantido como está** porque o histórico diário é global (compartilhado entre todos os cursos):

```dart
// ✅ CORRETO - histórico diário é global
await _firestore
    .collection('users')
    .doc(userId)
    .collection('stats')
    .doc('dailyHistory')
    .collection('days')
    .doc(todayDate)
    .set(...);
```

---

## Padrão de Busca do Curso Ativo

Todos os métodos agora seguem o mesmo padrão usado pelo `GamificationController` e `HomeController`:

```dart
// Buscar curso ativo
final coursesSnapshot = await _firestore
    .collection('users')
    .doc(userId)
    .collection('courses')
    .where('isActive', isEqualTo: true)
    .limit(1)
    .get();

if (coursesSnapshot.docs.isEmpty) {
  throw Exception('Nenhum curso ativo encontrado');
}

final courseId = coursesSnapshot.docs.first.id;
```

---

## Comportamento Final

### Ao Completar Lição:

1. ✅ Busca curso ativo do usuário
2. ✅ Distribui XP para stats do curso ativo
3. ✅ Adiciona gems para stats do curso ativo
4. ✅ Verifica level up no curso ativo
5. ✅ Atualiza streak do curso ativo
6. ✅ Salva progresso da lição no curso ativo
7. ✅ Atualiza histórico diário (global)
8. ✅ Atualiza desafios
9. ✅ Desbloqueia próxima lição
10. ✅ Exibe label de avaliação correto baseado na accuracy

### Labels de Avaliação:

| Accuracy | Label |
|----------|-------|
| 100% | Perfeito! |
| 90-99% | Excelente |
| 70-89% | Muito Bom |
| 50-69% | Bom |
| <50% | Continue Praticando |

### Ao Trocar Curso:

- ✅ Stats do curso anterior são mantidas
- ✅ Stats do novo curso são carregadas
- ✅ Cada curso tem suas próprias recompensas independentes

---

## Arquivos Modificados

### LessonController
- `lib/features/core/lesson/controllers/lesson_controller.dart`
  - `_distributeXP()` - linha ~1092
  - `_checkAndLevelUp()` - linha ~1130
  - `_addGems()` - linha ~1200
  - `_updateStreak()` - linha ~1000
  - `getAccuracyLabel()` - NOVO método

### CompletePage
- `lib/features/core/lesson/views/complete_page.dart`
  - Linha 171: Alterado de `isPerfect ? 'Perfeito!' : 'Excelente'` para `_controller.getAccuracyLabel()`
  - Linha 216: Alterado de `isPerfect ? 'Perfeito!' : 'Excelente'` para `_controller.getAccuracyLabel()`

---

## Testes Necessários

### Fluxo Completo:

1. ✅ Completar lição no curso ativo
2. ✅ Verificar que XP, gems, streak são salvos no curso correto
3. ✅ Verificar label de avaliação correto para diferentes accuracies
4. ✅ Trocar para outro curso
5. ✅ Verificar que stats do curso anterior são mantidas
6. ✅ Completar lição no novo curso
7. ✅ Verificar que stats do novo curso são atualizadas independentemente

### Labels de Avaliação:

1. ✅ Completar lição com 100% → "Perfeito!"
2. ✅ Completar lição com 95% → "Excelente"
3. ✅ Completar lição com 75% → "Muito Bom"
4. ✅ Completar lição com 55% → "Bom"
5. ✅ Completar lição com 40% → "Continue Praticando"

### Edge Cases:

1. ✅ Completar lição sem curso ativo (deve dar erro)
2. ✅ Completar lição com múltiplos cursos (deve usar o ativo)
3. ✅ Completar lição e trocar curso imediatamente

---

## Conclusão

Todos os métodos do `LessonController` que acessam stats de gamificação agora usam a estrutura correta por curso. O erro "Dados do usuário não encontrados" foi resolvido e o sistema de recompensas funciona corretamente com a estrutura de gamificação por curso.

Além disso, o sistema de avaliação agora exibe labels corretos baseados na porcentagem de acerto, proporcionando feedback mais preciso ao usuário sobre seu desempenho na lição.
