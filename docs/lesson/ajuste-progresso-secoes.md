# Ajuste - Indicador de Progresso nas Seções

> Correção do bug onde o indicador de progresso não aparecia nos cards das seções 2 e 3

---

## Problema Identificado

**Sintoma:**
- Card da Seção 1 mostrava indicador de progresso (0/3, 1/3, etc.)
- Cards das Seções 2 e 3 não mostravam indicador mesmo após completar lições

**Causa Raiz:**
1. **Lógica de status incorreta:** A função `getSectionsWithProgress()` calculava o status em uma única passagem, causando conflito entre:
   - Determinar status baseado no progresso (`in_progress` se `completedCount > 0`)
   - Desbloquear seção baseado na anterior (mudava `locked` para `not_started`)
   
2. **Condição de exibição restritiva:** O `SectionCard` só mostrava a barra de progresso em casos específicos, não cobrindo todos os cenários.

---

## Solução Implementada

### 1. Refatoração da Lógica de Status (`lesson_mocks.dart`)

**Antes:**
```dart
// Calculava status e desbloqueava em uma única passagem
if (completedCount == 0) {
  section['status'] = section['id'] == '1' ? 'in_progress' : 'locked';
} else if (completedCount == lessons.length) {
  section['status'] = 'completed';
} else {
  section['status'] = 'in_progress';
}

// Depois tentava desbloquear, mas podia sobrescrever in_progress
if (previousSection['status'] == 'completed') {
  if (section['status'] == 'locked') {
    section['status'] = 'not_started';
  }
}
```

**Depois:**
```dart
// Primeiro passo: calcular status baseado no progresso
if (completedCount == lessons.length) {
  section['status'] = 'completed';
} else if (completedCount > 0) {
  section['status'] = 'in_progress';
} else {
  section['status'] = section['id'] == '1' ? 'in_progress' : 'locked';
}

// Segundo passo: desbloquear seções (em loop separado)
for (int i = 1; i < sections.length; i++) {
  if (previousSection['status'] == 'completed') {
    if (currentSection['status'] == 'locked') {
      currentSection['status'] = 'not_started';
    }
  }
}
```

**Benefícios:**
- Separação clara de responsabilidades
- Status `in_progress` nunca é sobrescrito
- Lógica mais fácil de entender e manter

### 2. Simplificação da Condição de Exibição (`section_card.dart`)

**Antes:**
```dart
if (status == SectionStatus.completed ||
    status == SectionStatus.inProgress ||
    (status == SectionStatus.notStarted && currentProgress > 0))
  _buildProgressBar(r),
```

**Depois:**
```dart
// Mostra sempre que não estiver locked
if (!isLocked)
  _buildProgressBar(r),
```

**Benefícios:**
- Condição mais simples e direta
- Cobre todos os casos (completed, in_progress, not_started)
- Mais fácil de manter

---

## Fluxo de Status das Seções

### Seção 1 (Primeira)
```
Inicial: in_progress (0/3)
  ↓ (completa 1 lição)
in_progress (1/3)
  ↓ (completa 2 lições)
in_progress (2/3)
  ↓ (completa 3 lições)
completed (3/3)
```

### Seção 2 (Segunda)
```
Inicial: locked (0/3) - não mostra barra
  ↓ (Seção 1 completada)
not_started (0/3) - mostra barra 0/3
  ↓ (completa 1 lição)
in_progress (1/3) - mostra barra 1/3
  ↓ (completa 2 lições)
in_progress (2/3) - mostra barra 2/3
  ↓ (completa 3 lições)
completed (3/3) - mostra barra 3/3
```

### Seção 3 (Terceira)
```
Inicial: locked (0/3) - não mostra barra
  ↓ (Seção 2 completada)
not_started (0/3) - mostra barra 0/3
  ↓ (completa 1 lição)
in_progress (1/3) - mostra barra 1/3
  ↓ (completa 2 lições)
in_progress (2/3) - mostra barra 2/3
  ↓ (completa 3 lições)
completed (3/3) - mostra barra 3/3
```

---

## Estados Possíveis

| Status | Descrição | Mostra Barra? | Progresso |
|--------|-----------|---------------|-----------|
| `locked` | Seção bloqueada | ❌ Não | - |
| `not_started` | Desbloqueada, sem progresso | ✅ Sim | 0/N |
| `in_progress` | Tem progresso, não completou | ✅ Sim | X/N (0 < X < N) |
| `completed` | Todas as lições completadas | ✅ Sim | N/N |

---

## Testes Recomendados

### Cenário 1: Progresso Linear
1. Completar Lição 1 da Seção 1
   - ✅ Seção 1 deve mostrar 1/3
2. Completar Lição 2 da Seção 1
   - ✅ Seção 1 deve mostrar 2/3
3. Completar Lição 3 da Seção 1
   - ✅ Seção 1 deve mostrar 3/3 (completed)
   - ✅ Seção 2 deve desbloquear e mostrar 0/3

### Cenário 2: Progresso na Seção 2
1. Completar Seção 1 inteira
2. Completar Lição 4 da Seção 2
   - ✅ Seção 2 deve mostrar 1/3
3. Completar Lição 5 da Seção 2
   - ✅ Seção 2 deve mostrar 2/3
4. Completar Lição 6 da Seção 2
   - ✅ Seção 2 deve mostrar 3/3 (completed)
   - ✅ Seção 3 deve desbloquear e mostrar 0/3

### Cenário 3: Recarregamento
1. Completar algumas lições
2. Fechar e reabrir o app
   - ✅ Progresso deve persistir
   - ✅ Barras devem mostrar valores corretos

---

## Arquivos Modificados

- ✅ `lib/shared/mocks/lesson_mocks.dart` - Lógica de cálculo de progresso
- ✅ `lib/features/core/lesson/widgets/section_card.dart` - Condição de exibição

---

## Logs de Debug

A função `getSectionsWithProgress()` agora imprime logs detalhados:

```
🔍 Carregando progresso das seções para userId=..., courseId=...
📊 Encontrados X documentos de progresso
  - Lição 1: completed
  - Lição 2: completed
  - Lição 3: in_progress
📈 Seção 1: 2/3 lições completadas
  Status calculado: in_progress
📈 Seção 2: 0/3 lições completadas
  Status calculado: locked
  Seção 2 desbloqueada (anterior completada)
  Status final seção 2: not_started
✅ Seções carregadas com sucesso
```

Use esses logs para debugar problemas de progresso.

---

## Observações

### Performance
- A função faz duas passagens sobre as seções (cálculo + desbloqueio)
- Isso é aceitável pois o número de seções é pequeno (tipicamente 3-10)
- Complexidade: O(n) onde n = número de seções

### Manutenibilidade
- Lógica mais clara e separada
- Fácil adicionar novos estados no futuro
- Logs detalhados facilitam debug

### Escalabilidade
- Se o número de seções crescer muito (>100), considerar otimização
- Atualmente não é um problema
