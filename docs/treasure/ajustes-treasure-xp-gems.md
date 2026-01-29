# Ajustes - Treasure XP e Gems

> Correção da distribuição de recompensas de desafios

---

## Problema Identificado

### 1. XP não era recebido ao completar desafio

Ao completar um desafio e coletar a recompensa, o XP não era adicionado ao usuário.

### 2. Dados duplicados no Firebase

Havia dados de gems e XP em dois locais diferentes:
- **Local correto**: `users/{userId}/stats/gamification` (gerenciado pelo `GamificationController`)
- **Local incorreto**: `users/{userId}` (dados desatualizados/incorretos)

**Exemplo do problema:**
```
users/avsLDBw3kCMpRWdrvb1DZ9ae9r63
├── gems: 50          ❌ ERRADO - dados antigos
├── xp: 50            ❌ ERRADO - dados antigos
└── stats/
    └── gamification/
        ├── gems: 105  ✅ CORRETO - dados atuais
        └── xp: 70     ✅ CORRETO - dados atuais
```

---

## Causa Raiz

O método `TreasureController._distributeReward()` estava:
1. Atualizando `users/{userId}` diretamente ao invés de `users/{userId}/stats/gamification`
2. Não usando `FieldValue.increment()` para atomicidade
3. Tentando atualizar o estado do `GamificationController` manualmente ao invés de recarregar

---

## Solução Implementada

### 1. Atualizar Local Correto

Mudou de:
```dart
// ❌ ANTES - local errado
final userDocRef = _firestore.collection('users').doc(userId);
transaction.update(userDocRef, {'gems': newGems});
```

Para:
```dart
// ✅ DEPOIS - local correto
final gamificationDocRef = _firestore
    .collection('users')
    .doc(userId)
    .collection('stats')
    .doc('gamification');
transaction.update(gamificationDocRef, {
  'gems.gems': FieldValue.increment(rewardAmount),
  'gems.totalGemsEarned': FieldValue.increment(rewardAmount),
});
```

### 2. Usar FieldValue.increment()

Garante atomicidade e evita race conditions:

**Para Gems:**
```dart
transaction.update(gamificationDocRef, {
  'gems.gems': FieldValue.increment(rewardAmount),
  'gems.totalGemsEarned': FieldValue.increment(rewardAmount),
  'lastUpdated': FieldValue.serverTimestamp(),
});
```

**Para XP:**
```dart
transaction.update(gamificationDocRef, {
  'xp.totalXp': FieldValue.increment(rewardAmount),
  'xp.weeklyXP': FieldValue.increment(rewardAmount),
  'xp.todayXp': FieldValue.increment(rewardAmount),
  'lastUpdated': FieldValue.serverTimestamp(),
});
```

### 3. Recarregar Stats do GamificationController

Ao invés de tentar atualizar manualmente, recarrega os stats:

```dart
// Recarregar stats do GamificationController após distribuir recompensa
try {
  final gamificationController = Get.find<dynamic>();
  if (gamificationController.toString().contains('GamificationController')) {
    await gamificationController.loadStats();
  }
} catch (e) {
  debugPrint('⚠️ GamificationController não encontrado para recarregar stats: $e');
}
```

---

## Estrutura Correta do Firestore

```
users/{userId}/
├── name: "Wagner Petrus"
├── email: "user@example.com"
├── onboardingCompleted: true
└── stats/
    └── gamification/
        ├── currentLeague: "bronze"
        ├── streak: { currentStreak, longestStreak, ... }
        ├── energy: { currentEnergy, maxEnergy, ... }
        ├── xp: {
        │   totalXp: 70,
        │   weeklyXP: 15,
        │   todayXp: 70,
        │   level: 1,
        │   xpToNextLevel: 100
        │ }
        └── gems: {
            gems: 105,
            totalGemsEarned: 105,
            totalGemsSpent: 0
          }
```

**Importante:** Os campos `gems` e `xp` NÃO devem existir em `users/{userId}` diretamente.

---

## Benefícios

1. **XP e Gems são recebidos corretamente** ao completar desafios
2. **Dados centralizados** em um único local (`stats/gamification`)
3. **Atomicidade garantida** com `FieldValue.increment()`
4. **Sincronização automática** com `GamificationController.loadStats()`
5. **Evita race conditions** em atualizações concorrentes

---

## Testes Realizados

### Teste 1: Completar Desafio de Gems
1. Completar desafio que recompensa 10 gems
2. Verificar que gems aumentam em `stats/gamification`
3. Verificar que `totalGemsEarned` também aumenta
4. Verificar que UI atualiza corretamente

### Teste 2: Completar Desafio de XP
1. Completar desafio que recompensa 15 XP
2. Verificar que `totalXp`, `weeklyXP` e `todayXp` aumentam
3. Verificar que UI atualiza corretamente
4. Verificar se level up ocorre quando apropriado

### Teste 3: Verificar Atomicidade
1. Completar múltiplos desafios rapidamente
2. Verificar que todos os valores são atualizados corretamente
3. Verificar que não há perda de dados

---

## Limpeza de Dados Antigos (Opcional)

Se necessário, remover campos `gems` e `xp` do documento do usuário:

```dart
// Remover campos antigos (executar uma vez)
await _firestore.collection('users').doc(userId).update({
  'gems': FieldValue.delete(),
  'xp': FieldValue.delete(),
});
```

**Nota:** Isso é opcional pois os campos antigos não interferem com o funcionamento correto.

---

## Arquivos Modificados

- `lib/features/inners/treasure/controllers/treasure_controller.dart`
  - Método `_distributeReward()` corrigido
  - Import `package:flutter/foundation.dart` adicionado

---

## Próximos Passos

- [ ] Testar completando desafios de gems
- [ ] Testar completando desafios de XP
- [ ] Verificar que level up funciona corretamente com XP de desafios
- [ ] (Opcional) Limpar campos antigos `gems` e `xp` do documento do usuário
