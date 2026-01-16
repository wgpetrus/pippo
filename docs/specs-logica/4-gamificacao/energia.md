# Energia - Sistema de Sparks/Flashes

> Limita quantas lições o usuário pode fazer

---

## Valores

- **Energia máxima**: 5
- **Custo por lição**: 1 energia
- **Regeneração**: 1 energia a cada 30 minutos
- **Tempo para recarga completa**: 2h30 (se vazio)

---

## Quando Consumir

- Ao **INICIAR** uma lição (não ao completar)
- Se tiver energia ilimitada (premium), não consome

---

## Lógica de Regeneração

```dart
// 1. Pegar timestamp atual
final now = DateTime.now();

// 2. Calcular minutos passados desde última regeneração
final minutesPassed = now.difference(lastEnergyRegenAt).inMinutes;

// 3. Calcular energias regeneradas (1 a cada 30 min)
final energiesToAdd = minutesPassed ~/ 30;

if (energiesToAdd > 0) {
  // 4. Adicionar energias (máximo 5)
  currentEnergy = min(currentEnergy + energiesToAdd, maxEnergy);
  
  // 5. Atualizar timestamp
  lastEnergyRegenAt = now.subtract(Duration(minutes: minutesPassed % 30));
  
  // 6. Salvar no Firestore
}
```

---

## Cálculo de Próxima Energia

Para mostrar "Próxima energia em X min":

```dart
final minutesPassed = DateTime.now().difference(lastEnergyRegenAt).inMinutes;
final minutesUntilNext = 30 - (minutesPassed % 30);

// Exemplo: Se passaram 45 minutos
// 45 % 30 = 15 (já passaram 15 min do ciclo atual)
// 30 - 15 = 15 (faltam 15 min para próxima)
```

---

## Estados do Modal

### Energia cheia (5/5)
- Mensagem: "Totalmente carregado ⚡ Pronto para começar?"
- Mostrar 5 raios preenchidos
- Não mostrar tempo de próxima energia

### Energia baixa (1/5)
- Mensagem: "Apenas um raio restante... use com sabedoria!"
- Mostrar 1 raio preenchido, 4 vazios
- Mostrar tempo para próxima

### Energia vazia (0/5)
- Mensagem: "Sem raios; Faça uma pausa..."
- Mostrar 5 raios vazios
- Mostrar tempo para próxima
- Destacar botão de recarga

---

## Opções de Recarga

### Recarregar (+5 energia)
- Custo: 100 gems
- Efeito: Energia volta para 5 imediatamente

### Energia Ilimitada
- Disponível via Premium ou Trial gratuito
- Não consome energia ao fazer lições
- Mostrar badge "Ilimitado" no header

---

## Verificação Antes de Iniciar Lição

```dart
// 1. Verificar energia ilimitada
if (unlimitedEnergyUntil != null && 
    DateTime.now().isBefore(unlimitedEnergyUntil)) {
  // Permitir iniciar
  return true;
}

// 2. Verificar energia disponível
if (currentEnergy > 0) {
  // Consumir 1 energia
  currentEnergy--;
  // Salvar no Firestore
  return true;
}

// 3. Sem energia
// Mostrar modal de energia baixa
return false;
```
