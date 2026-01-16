# Gems - Moeda Virtual

> Sistema de moeda do jogo

---

## Como Ganhar Gems

| Ação | Gems Ganhas |
|------|-------------|
| Completar lição | 1-3 gems (varia por lição) |
| Completar unidade inteira | 10 gems |
| Streak de 7 dias | 5 gems |
| Completar desafio diário | 5-15 gems |
| Subir de liga no ranking | 20 gems |
| Posição no ranking semanal | 5-50 gems |
| Level up | 10 gems |

---

## Como Gastar Gems

| Item | Custo |
|------|-------|
| Recarregar energia (+5) | 100 gems |
| Streak Freeze (1 uso) | 200 gems |
| XP Booster (1 hora) | 150 gems |
| Gem Multiplier (1 hora) | 200 gems |
| Avatares especiais | 500-1000 gems |

---

## Packs de Compra (IAP)

### Pack Pequeno
- 100 gems
- Preço: R$ 9,90

### Pack Médio (DESTAQUE)
- 500 gems
- Preço: R$ 39,90 (era R$ 49,90)
- Badge: "DESCONTO"
- Background rosa

### Pack Grande
- 1500 gems
- Preço: R$ 99,90

---

## Lógica de Compra IAP

```dart
// 1. Usuário clica em pack
// 2. Processar pagamento via plataforma
final result = await InAppPurchase.instance.buyConsumable(
  purchaseParam: PurchaseParam(productDetails: product),
);

// 3. Se pagamento aprovado
if (result.status == PurchaseStatus.purchased) {
  // Adicionar gems ao saldo
  gems += packAmount;
  totalGemsEarned += packAmount;
  
  // Salvar no Firestore
  await saveGems();
  
  // Mostrar feedback de sucesso
  showSuccessMessage();
}
```

---

## Controle de Gastos

```dart
Future<bool> spendGems(int amount) async {
  // 1. Verificar saldo
  if (gems < amount) {
    // Mostrar modal "Gems Insuficientes"
    showInsufficientGemsModal();
    return false;
  }
  
  // 2. Deduzir do saldo
  gems -= amount;
  totalGemsSpent += amount;
  
  // 3. Salvar no Firestore
  await saveGems();
  
  return true;
}
```

---

## Gem Multiplier

### Características
- Multiplica por 2 todas gems ganhas
- Duração: 1 hora
- Custo: 200 gems

### Lógica

```dart
// Ao ganhar gems
if (hasActiveGemMultiplier()) {
  gemsGained *= 2;
}
```
