# XP e Níveis

> Sistema de experiência e progressão

---

## Como Ganhar XP

### Por exercício
- Exercício correto: 1-2 XP
- Exercício errado: 0 XP

### Por lição
- Lição completa: 10-15 XP (base)
- Lição perfeita (100% acertos): +5 XP bônus
- Primeira lição do dia: +5 XP bônus
- Com XP Booster ativo: 2× todo XP

---

## Exemplo de Cálculo

```dart
// Lição com 8 exercícios, 7 corretos
int xp = 12; // XP base da lição
xp += 7 * 1; // 7 acertos × 1 XP
// Total: 19 XP

// Se for primeira do dia
if (isFirstLessonToday) {
  xp += 5; // 19 + 5 = 24 XP
}

// Se tiver XP Booster ativo
if (hasActiveXpBooster) {
  xp *= 2; // 24 × 2 = 48 XP
}
```

---

## Sistema de Níveis

### Cálculo de XP necessário

```dart
int xpForNextLevel(int currentLevel) {
  return currentLevel * 100;
}

// Exemplos:
// Nível 1: 100 XP
// Nível 2: 200 XP
// Nível 10: 1000 XP
// Nível 50: 5000 XP
```

---

## Verificação de Level Up

```dart
// Após ganhar XP
totalXp += xpGained;

while (totalXp >= xpToNextLevel) {
  // Subir de nível
  level++;
  
  // Recalcular XP necessário para próximo
  xpToNextLevel = level * 100;
  
  // Dar recompensa
  gems += 10;
  
  // Mostrar animação/notificação
  showLevelUpAnimation();
}

// Salvar no Firestore
```

---

## Tipos de XP

- **totalXp**: XP total desde sempre (nunca diminui)
- **weeklyXp**: XP da semana (reseta toda segunda 00:00)
- **todayXp**: XP de hoje (reseta à meia-noite)

---

## XP Booster

### Características
- Multiplica por 2 todo XP ganho
- Duração: 1 hora
- Custo: 150 gems

### Lógica

```dart
// Ao comprar
final expiresAt = DateTime.now().add(Duration(hours: 1));
await saveBoosterExpiration('xp', expiresAt);

// Ao ganhar XP
bool hasActiveXpBooster() {
  if (xpBoosterExpiresAt == null) return false;
  return DateTime.now().isBefore(xpBoosterExpiresAt);
}

if (hasActiveXpBooster()) {
  xp *= 2;
}
```

### Indicador visual
- Badge "2× XP" no header durante efeito
- Mostrar tempo restante ao clicar
