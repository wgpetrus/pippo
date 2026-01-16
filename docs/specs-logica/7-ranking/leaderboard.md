# Leaderboard - Ranking Semanal

> Competição semanal entre usuários da mesma liga

---

## Ligas

**Hierarquia (da menor para maior):**
1. Bronze - Liga inicial
2. Silver - Prata
3. Gold - Ouro
4. Platinum - Platina
5. Diamond - Diamante

---

## Regras do Ranking

### Duração
- 1 semana (segunda 00:00 até domingo 23:59)
- Reset toda segunda-feira à meia-noite

### Participantes
- 30 usuários por grupo
- Agrupados por liga
- Ordenados por `weeklyXp` (maior para menor)

### Zonas

**Promoção (Top 10):**
- Sobem para liga superior
- Exceção: Diamond não tem promoção (é a máxima)

**Zona Segura (11-25):**
- Permanecem na mesma liga

**Rebaixamento (Bottom 5):**
- Descem para liga inferior
- Exceção: Bronze não tem rebaixamento (é a mínima)

---

## Lógica de Atualização Durante a Semana

```dart
// Ao ganhar XP
weeklyXp += xpGained;

// Atualizar posição no ranking
await updateLeaderboardPosition();

// Verificar zonas
final rank = await getMyRank();
promotionZone = (rank <= 10);
demotionZone = (rank >= 26);

// Salvar no Firestore
```

---

## Reset Semanal (Cloud Function)

```dart
// Executar toda segunda-feira à meia-noite

// 1. Processar todos os grupos de todas as ligas
for (final group in allGroups) {
  // 2. Promover top 10
  for (final user in group.top10) {
    if (user.league != 'diamond') {
      promoteUser(user);
      user.gems += 20; // bônus de promoção
    }
  }
  
  // 3. Rebaixar bottom 5
  for (final user in group.bottom5) {
    if (user.league != 'bronze') {
      demoteUser(user);
    }
  }
  
  // 4. Distribuir recompensas por posição
  distributeRewards(group);
  
  // 5. Resetar weeklyXp de todos
  for (final user in group.users) {
    user.weeklyXp = 0;
  }
}

// 6. Formar novos grupos aleatórios
formNewGroups();

// 7. Enviar notificações de resultado
sendNotifications();
```

---

## Recompensas Semanais

| Posição | Gems |
|---------|------|
| 1º lugar | 50 gems |
| 2º lugar | 30 gems |
| 3º lugar | 20 gems |
| 4º-10º | 10 gems |
| 11º-30º | 5 gems (participação) |

**Bônus de promoção:**
- Subir de liga: +20 gems extras

---

## Modal de Status

Ao clicar no próprio ranking:

```dart
showStatusModal(
  position: leagueRank,
  weeklyXp: weeklyXp,
  zone: getZone(), // promoção/segura/rebaixamento
  daysRemaining: getDaysUntilReset(),
  nextLeague: getNextLeague(),
  previousLeague: getPreviousLeague(),
);
```
