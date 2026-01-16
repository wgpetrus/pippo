# Regras Críticas - Pippo

> Regras que NUNCA devem ser quebradas

---

## 1. Ordem de Verificações (CRÍTICO!)

### Ao Abrir o App (Splash)

**Ordem EXATA - NUNCA inverter:**

```
1. Verificar se está logado (Firebase Auth)
   ↓
2. Se NÃO logado: verificar primeiro acesso
   ↓
3. Se logado: verificar onboarding completo
   ↓
4. Navegar para tela correta
```

---

### Ao Iniciar Lição

**Ordem EXATA:**

```
1. Verificar se lição está desbloqueada
   ↓
2. Verificar energia disponível
   ↓
3. Consumir energia
   ↓
4. Carregar exercícios
   ↓
5. Iniciar lição
```

---

### Ao Completar Lição

**Ordem EXATA:**

```
1. Calcular recompensas
   ↓
2. Adicionar XP (com bônus)
   ↓
3. Adicionar gems
   ↓
4. Salvar progresso
   ↓
5. Atualizar streak (se primeira do dia)
   ↓
6. Atualizar desafios
   ↓
7. Verificar level up
   ↓
8. Salvar histórico
```

---

## 2. Fórmulas Exatas

### XP para Próximo Nível

```dart
int xpForNextLevel(int currentLevel) {
  return currentLevel * 100;
}
```

**Exemplos:**
- Nível 1: 100 XP
- Nível 2: 200 XP
- Nível 10: 1000 XP

---

### Regeneração de Energia

```dart
// 1 energia a cada 30 minutos
final minutesPassed = now.difference(lastRegenAt).inMinutes;
final energiesToAdd = minutesPassed ~/ 30;
```

---

### Próxima Energia

```dart
// Tempo até próxima energia
final minutesPassed = now.difference(lastRegenAt).inMinutes;
final minutesUntilNext = 30 - (minutesPassed % 30);
```

---

### Accuracy

```dart
final accuracy = (correctAnswers / totalAnswers) * 100;
```

---

## 3. Formatos de Data

### Streak e Histórico

```dart
// Formato: "YYYY-MM-DD"
final today = DateFormat('yyyy-MM-DD').format(DateTime.now());
```

---

### Timestamps

```dart
// Sempre usar serverTimestamp
'createdAt': FieldValue.serverTimestamp()
```

---

### Fuso Horário

**SEMPRE usar fuso do dispositivo do usuário:**

```dart
final now = DateTime.now(); // fuso local
```

**NUNCA usar UTC para streak/histórico:**

```dart
// ❌ ERRADO
final now = DateTime.now().toUtc();
```

---

## 4. Consumo de Energia

### Quando Consumir

**Ao INICIAR a lição, não ao completar:**

```dart
// ✅ CORRETO
Future<void> startLesson() async {
  if (!hasUnlimitedEnergy()) {
    currentEnergy--;
    await saveEnergy();
  }
  // ... carregar exercícios
}

// ❌ ERRADO
Future<void> completeLesson() async {
  currentEnergy--; // NÃO consumir aqui!
}
```

---

## 5. Streak

### Atualizar Apenas na Primeira Lição do Dia

```dart
// ✅ CORRETO
if (isFirstLessonToday) {
  await updateStreak();
}

// ❌ ERRADO - atualizar em toda lição
await updateStreak(); // NÃO fazer isso!
```

---

### Reset à Meia-Noite

**Usar fuso do usuário, não UTC:**

```dart
// ✅ CORRETO
final today = DateFormat('yyyy-MM-DD').format(DateTime.now());

// ❌ ERRADO
final today = DateFormat('yyyy-MM-DD').format(DateTime.now().toUtc());
```

---

## 6. Tipos de XP

### Três Tipos Diferentes

```dart
// totalXp - NUNCA diminui
totalXp += xpGained;

// weeklyXp - Reseta toda segunda 00:00
weeklyXp += xpGained;

// todayXp - Reseta à meia-noite
todayXp += xpGained;
```

**NUNCA resetar `totalXp`!**

---

## 7. Ranking

### Zonas

```dart
// Promoção: Top 10
promotionZone = (rank <= 10);

// Rebaixamento: Bottom 5
demotionZone = (rank >= 26);
```

### Exceções

- **Diamond**: não tem promoção (é a máxima)
- **Bronze**: não tem rebaixamento (é a mínima)

---

## 8. Curso Primário

### Apenas 1 Pode Ser Primário

```dart
// Ao marcar curso como primário
// 1. Desmarcar TODOS os outros
for (final course in courses) {
  course.isPrimary = false;
}

// 2. Marcar apenas o selecionado
selectedCourse.isPrimary = true;
```

---

## 9. Sincronização Firestore

### Quando Salvar Imediatamente

- Completar lição
- Comprar item
- Editar perfil
- Seguir usuário
- Coletar recompensa

### Quando Usar Batch

Múltiplas atualizações relacionadas:

```dart
final batch = FirebaseFirestore.instance.batch();

// Atualizar múltiplos documentos
batch.update(ref1, data1);
batch.update(ref2, data2);
batch.update(ref3, data3);

await batch.commit();
```

---

## 10. Validações

### Username Único

**SEMPRE verificar no Firestore:**

```dart
Future<bool> isUsernameAvailable(String username) async {
  final query = await FirebaseFirestore.instance
      .collection('users')
      .where('username', isEqualTo: username)
      .get();
  
  return query.docs.isEmpty;
}
```

---

## 11. Boosts Temporários

### Verificar Expiração

```dart
bool hasActiveBooster() {
  if (boosterExpiresAt == null) return false;
  return DateTime.now().isBefore(boosterExpiresAt!);
}
```

**NUNCA assumir que está ativo sem verificar timestamp!**

---

## 12. Desafios

### Atualizar Após Ações

```dart
// Após completar lição
await updateChallenges(type: 'lessons', amount: 1);

// Após ganhar XP
await updateChallenges(type: 'xp', amount: xpGained);

// Após acertar exercício
await updateChallenges(type: 'correct_exercises', amount: 1);
```

---

## 13. Histórico Diário

### Formato da Data como ID

```dart
// ID do documento = data no formato "YYYY-MM-DD"
final dateId = DateFormat('yyyy-MM-DD').format(DateTime.now());

await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('history')
    .doc(dateId) // usar data como ID
    .set(data, SetOptions(merge: true));
```

---

## Resumo

**Regras que NUNCA devem ser quebradas:**

1. ✅ Ordem exata de verificações
2. ✅ Fórmulas exatas de cálculo
3. ✅ Formatos corretos de data
4. ✅ Consumir energia ao INICIAR lição
5. ✅ Atualizar streak apenas na primeira do dia
6. ✅ Usar fuso do usuário, não UTC
7. ✅ Três tipos de XP (total, weekly, today)
8. ✅ Apenas 1 curso primário
9. ✅ Verificar username único
10. ✅ Verificar expiração de boosts
11. ✅ Atualizar desafios após ações
12. ✅ Usar data como ID no histórico
