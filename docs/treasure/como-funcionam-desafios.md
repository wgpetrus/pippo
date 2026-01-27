# Como Funcionam os Desafios (Treasure)

> Sistema de desafios diários, semanais e especiais do Pippo

---

## Visão Geral

Os desafios aparecem automaticamente na aba **Treasure** (Tab 3) e são atualizados conforme você usa o app.

---

## Como os Desafios Aparecem

### 1. Geração Automática

Os desafios são gerados automaticamente pelo sistema:

- **Desafios Diários**: Renovam todo dia à meia-noite
- **Desafios Semanais**: Renovam todo domingo à meia-noite
- **Desafios Especiais**: Criados manualmente para eventos

### 2. Onde Ver os Desafios

1. Abra o app
2. Vá para a aba **Treasure** (ícone do baú, Tab 3)
3. Você verá todos os desafios ativos agrupados por tipo

---

## Como Completar Desafios

### Progresso Automático

Os desafios são atualizados **automaticamente** quando você:

#### 1. Completa Lições
```
Desafio: "Complete 3 lições"
↓
Você completa uma lição
↓
Progresso: 1/3 ✅
```

#### 2. Acerta Exercícios
```
Desafio: "Acerte 10 exercícios"
↓
Você acerta 5 exercícios em uma lição
↓
Progresso: 5/10 ✅
```

#### 3. Ganha XP
```
Desafio: "Ganhe 50 XP"
↓
Você ganha 15 XP em uma lição
↓
Progresso: 15/50 ✅
```

#### 4. Mantém Streak
```
Desafio: "Mantenha 7 dias de streak"
↓
Você estuda por 3 dias seguidos
↓
Progresso: 3/7 ✅
```

### Integração com Lições

O sistema está integrado no `LessonController`:

```dart
// Quando você completa uma lição, o sistema automaticamente:
await controller.updateChallengeProgress('lessons', 1);
await controller.updateChallengeProgress('correct_exercises', correctAnswers.value);
```

---

## Estados dos Desafios

### 1. Em Progresso (In Progress)
- Progresso < Meta
- Botão "Claim" desabilitado (cinza)
- Barra de progresso parcial

```
┌─────────────────────────────┐
│ Complete 3 lições           │
│ Ganhe 5 gems                │
│                             │
│ ▓▓▓▓▓░░░░░░░░░░ 1/3        │
│                             │
│ [  Claim  ] (desabilitado)  │
└─────────────────────────────┘
```

### 2. Completado (Completed)
- Progresso >= Meta
- Botão "Claim" habilitado (verde)
- Barra de progresso cheia
- Animação de brilho

```
┌─────────────────────────────┐
│ Complete 3 lições     ✨    │
│ Ganhe 5 gems                │
│                             │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ 3/3 ✅     │
│                             │
│ [  Claim  ] (habilitado)    │
└─────────────────────────────┘
```

### 3. Reivindicado (Claimed)
- Recompensa já coletada
- Desafio removido da lista
- Não aparece mais na tela

### 4. Expirado (Expired)
- Prazo passou
- Removido automaticamente
- Não aparece mais na tela

---

## Reivindicar Recompensas

### Passo a Passo

1. Complete o desafio (progresso = meta)
2. Vá para a aba **Treasure**
3. Toque no botão **Claim** do desafio completado
4. Veja a animação de recompensa
5. Gems/XP são adicionados automaticamente

### Validações

O sistema valida antes de dar a recompensa:

- ✅ Desafio está completo?
- ✅ Recompensa não foi reivindicada antes?
- ✅ Desafio não expirou?
- ✅ Usuário está autenticado?

Se alguma validação falhar, você verá uma mensagem de erro.

---

## Tipos de Desafios

### Desafios Diários (Daily)
- Renovam todo dia à meia-noite
- Exemplos:
  - "Complete 3 lições"
  - "Acerte 10 exercícios"
  - "Ganhe 50 XP"

### Desafios Semanais (Weekly)
- Renovam todo domingo à meia-noite
- Exemplos:
  - "Complete 15 lições esta semana"
  - "Mantenha 7 dias de streak"
  - "Ganhe 500 XP esta semana"

### Desafios Especiais (Special)
- Criados para eventos
- Prazo customizado
- Exemplos:
  - "Evento de Natal: Complete 10 lições"
  - "Desafio de Ano Novo: Ganhe 1000 XP"

---

## Recompensas

### Tipos de Recompensa

| Tipo | Descrição |
|------|-----------|
| Gems | Moedas do jogo (para comprar itens) |
| XP | Experiência (para subir de nível) |
| Item | Itens especiais (futuro) |

### Distribuição Atômica

As recompensas são distribuídas de forma **atômica** (tudo ou nada):

```dart
// Transação Firestore garante que:
// - Gems são adicionadas
// - XP é adicionado
// - Desafio é marcado como reivindicado
// Tudo acontece junto ou nada acontece
```

---

## Atualização em Tempo Real

### Pull-to-Refresh

Arraste a tela para baixo para atualizar os desafios:

```
↓ Arraste para baixo
↓
🔄 Carregando...
↓
✅ Desafios atualizados
```

### Atualização Automática

Os desafios são atualizados automaticamente quando:

- Você abre o app
- Você volta para a aba Treasure
- Você completa uma lição

---

## Troubleshooting

### "Não vejo nenhum desafio"

1. Verifique se está na aba **Treasure** (Tab 3)
2. Arraste para baixo para atualizar
3. Verifique sua conexão com a internet
4. Os desafios podem ter expirado (serão renovados automaticamente)

### "Completei o desafio mas não consigo reivindicar"

1. Verifique se o progresso está completo (ex: 3/3)
2. Verifique se o desafio não expirou
3. Tente atualizar a página (pull-to-refresh)
4. Verifique sua conexão com a internet

### "Reivindicei mas não recebi a recompensa"

1. Verifique seu saldo de gems/XP na home
2. Pode haver um atraso de sincronização
3. Feche e abra o app novamente
4. Se o problema persistir, contate o suporte

---

## Integração com Outros Módulos

### Gamification
- Gems e XP das recompensas são adicionados ao `GamificationController`
- Streak é rastreado para desafios de streak

### Lessons
- Progresso de lições é rastreado automaticamente
- Exercícios corretos são contados
- XP ganho é rastreado

### Profile (Futuro)
- Estatísticas de desafios completados
- Histórico de recompensas
- Conquistas relacionadas a desafios

---

## Código Relevante

### TreasureController
```dart
// Carregar desafios
await controller.loadChallenges();

// Atualizar progresso (automático)
await controller.updateChallengeProgress('lessons', 1);

// Reivindicar recompensa
await controller.claimReward(challengeId);
```

### LessonController (Integração)
```dart
// Ao completar lição, atualiza desafios automaticamente
try {
  final controller = Get.find<TreasureController>();
  await controller.updateChallengeProgress('lessons', 1);
  await controller.updateChallengeProgress('correct_exercises', correctAnswers.value);
} catch (e) {
  // TreasureController não registrado - não é crítico
}
```

---

## Próximas Features

- [ ] Desafios de amigos (competir com amigos)
- [ ] Desafios de tempo (completar em X minutos)
- [ ] Desafios de perfeição (100% de acurácia)
- [ ] Desafios de combo (X lições seguidas sem erros)
- [ ] Notificações de desafios próximos de expirar
- [ ] Histórico de desafios completados
