# Treasure - Sistema de Missões e Desafios

> Desafios temporários com recompensas extras

---

## Tipos de Desafios

### Diários (renovam todo dia)
- Complete 3 lições
- Ganhe 50 XP
- Acerte 20 exercícios
- Mantenha seu streak

### Semanais (renovam toda semana)
- Complete 15 lições
- Ganhe 500 XP
- Suba 3 níveis
- Complete 5 unidades

### Especiais (eventos temporários)
- Desafios temáticos
- Eventos de fim de semana
- Competições especiais

---

## Estrutura de Desafio

Cada desafio tem:
- Título e descrição
- Meta numérica (ex: 3 lições)
- Progresso atual (ex: 1/3)
- Tipo de recompensa (gems, xp, item)
- Quantidade da recompensa
- Data de expiração
- Ícone visual

---

## Lógica de Progresso

### Quando atualizar

```dart
// Após completar lição
await updateChallenges(type: 'lessons', amount: 1);

// Após ganhar XP
await updateChallenges(type: 'xp', amount: xpGained);

// Após acertar exercício
await updateChallenges(type: 'correct_exercises', amount: 1);

// Após atualizar streak
await updateChallenges(type: 'streak', amount: 1);
```

### Como atualizar

```dart
Future<void> updateChallenges({
  required String type,
  required int amount,
}) async {
  // 1. Buscar desafios ativos do usuário
  final challenges = await getActiveChallenges();
  
  // 2. Filtrar por tipo relevante
  final relevantChallenges = challenges.where((c) => c.type == type);
  
  for (final challenge in relevantChallenges) {
    // 3. Incrementar progresso
    challenge.current += amount;
    
    // 4. Verificar se atingiu meta
    if (challenge.current >= challenge.target) {
      challenge.completed = true;
      
      // 5. Notificar usuário
      showChallengeCompletedNotification(challenge);
    }
    
    // 6. Salvar no Firestore
    await saveChallenge(challenge);
  }
}
```

---

## Coleta de Recompensa

```dart
Future<void> claimReward(String challengeId) async {
  final challenge = await getChallenge(challengeId);
  
  // 1. Verificar se completou
  if (!challenge.completed) return;
  
  // 2. Verificar se já coletou
  if (challenge.claimedAt != null) return;
  
  // 3. Adicionar recompensa
  if (challenge.rewardType == 'gems') {
    gems += challenge.rewardAmount;
  } else if (challenge.rewardType == 'xp') {
    totalXp += challenge.rewardAmount;
  }
  
  // 4. Marcar como coletado
  challenge.claimedAt = DateTime.now();
  
  // 5. Salvar no Firestore
  await saveChallenge(challenge);
  
  // 6. Mostrar animação de recompensa
  showRewardAnimation(challenge);
  
  // 7. Remover da lista de ativos
  activeChallenges.remove(challenge);
}
```

---

## Estados do Card

### Em progresso
- Barra parcial
- Botão desabilitado
- Mostrar progresso (ex: 1/3)

### Completo
- Barra cheia (100%)
- Botão "Coletar Recompensa" ativo
- Animação de brilho

### Coletado
- Card some da lista

---

## Expiração

```dart
// Verificar ao carregar desafios
final now = DateTime.now();

for (final challenge in challenges) {
  if (challenge.expiresAt.isBefore(now)) {
    // Remover da lista de ativos
    await removeChallenge(challenge.id);
  }
}

// Horários de expiração:
// - Diários: à meia-noite
// - Semanais: domingo 23:59
// - Especiais: data definida
```
