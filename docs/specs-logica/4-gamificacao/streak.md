# Streak - Sequência de Dias

> Sistema de dias consecutivos de estudo

---

## Regras de Manutenção

**Para manter:**
- Completar pelo menos 1 lição por dia
- Reset: meia-noite no fuso horário do usuário

**Para perder:**
- Não estudar em um dia completo
- Streak volta para 0

---

## Lógica de Atualização

**Quando**: Ao completar a primeira lição do dia

### Algoritmo

```dart
// 1. Pegar data de hoje
final today = DateFormat('yyyy-MM-DD').format(DateTime.now());

// 2. Comparar com lastStreakDate
if (lastStreakDate == today) {
  // Já estudou hoje, não faz nada
  return;
}

// 3. Calcular diferença de dias
final lastDate = DateTime.parse(lastStreakDate);
final todayDate = DateTime.parse(today);
final daysDiff = todayDate.difference(lastDate).inDays;

if (daysDiff == 1) {
  // 4. Data de ontem: incrementar streak
  currentStreak++;
  
} else if (daysDiff > 1) {
  // 5. Data anterior a ontem: verificar Streak Freeze
  if (streakFreezeAvailable > 0) {
    // Consumir 1 freeze, manter streak
    streakFreezeAvailable--;
    streakFreezeUsedToday = true;
  } else {
    // Resetar streak para 1
    currentStreak = 1;
  }
}

// 6. Atualizar lastStreakDate
lastStreakDate = today;

// 7. Verificar recorde
if (currentStreak > longestStreak) {
  longestStreak = currentStreak;
}

// 8. Salvar no Firestore
```

---

## Streak Freeze (Proteção)

**Características:**
- Custo: 200 gems
- Protege streak por 1 dia sem estudar
- Usuário pode ter múltiplos freezes
- Consome automaticamente quando necessário

---

## Níveis Visuais do Modal

### Nível 0 (0 dias)
- Background: Cinza
- Borda: Branca
- Mascote: mascot0 (triste)
- Decoração: Círculos cinzas

### Nível 1 (1 dia)
- Background: Azul claro
- Borda: Azul
- Mascote: mascot1 (normal)
- Decoração: Estrela desenhada

### Nível 2 (2-3 dias)
- Background: Laranja
- Borda: Branca
- Mascote: warrior4 (guerreiro)
- Decoração: Padrão zebra

### Nível 3 (4-6 dias)
- Background: Azul escuro
- Borda: Azul
- Mascote: warrior2 (guerreiro forte)
- Decoração: Padrão zebra

### Nível 4 (7+ dias)
- Background: Laranja
- Borda: Branca
- Mascote: warrior5 (guerreiro épico)
- Decoração: Estrelas SVG

---

## Recompensas por Streak

| Dias | Recompensa |
|------|------------|
| 7 | +5 gems |
| 14 | +10 gems |
| 30 | +20 gems + badge especial |
| 100 | +50 gems + badge lendário |

**Lógica:**
```dart
if (currentStreak == 7 || currentStreak == 14 || 
    currentStreak == 30 || currentStreak == 100) {
  // Dar recompensa
  // Mostrar notificação
}
```
