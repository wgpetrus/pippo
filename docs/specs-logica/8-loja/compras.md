# Loja - Sistema de Compras

> Lógica de compra de itens e boosts

---

## Verificação Antes de Comprar

```dart
Future<bool> canPurchase(int cost) async {
  // Verificar saldo de gems
  if (gems < cost) {
    // Mostrar modal "Gems Insuficientes"
    showInsufficientGemsModal();
    return false;
  }
  
  return true;
}
```

---

## Processo de Compra

```dart
Future<void> purchaseItem(ShopItem item) async {
  // 1. Verificar saldo
  if (!await canPurchase(item.cost)) return;
  
  // 2. Deduzir gems
  gems -= item.cost;
  totalGemsSpent += item.cost;
  
  // 3. Aplicar efeito do item
  switch (item.type) {
    case ItemType.xpBooster:
      await activateXpBooster();
      break;
      
    case ItemType.gemMultiplier:
      await activateGemMultiplier();
      break;
      
    case ItemType.streakFreeze:
      streakFreezeAvailable++;
      break;
      
    case ItemType.energyRefill:
      currentEnergy = maxEnergy;
      break;
      
    case ItemType.avatar:
      unlockedAvatars.add(item.avatarId);
      break;
  }
  
  // 4. Salvar no Firestore
  await saveGems();
  await saveItemEffect(item);
  
  // 5. Mostrar feedback de sucesso
  showSuccessMessage('Item comprado com sucesso!');
  
  // 6. Atualizar UI
  update();
}
```

---

## Boosts Temporários

### XP Booster

```dart
Future<void> activateXpBooster() async {
  final expiresAt = DateTime.now().add(Duration(hours: 1));
  
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({
    'xpBoosterExpiresAt': Timestamp.fromDate(expiresAt),
  });
  
  xpBoosterExpiresAt = expiresAt;
}

bool hasActiveXpBooster() {
  if (xpBoosterExpiresAt == null) return false;
  return DateTime.now().isBefore(xpBoosterExpiresAt!);
}
```

### Gem Multiplier

```dart
Future<void> activateGemMultiplier() async {
  final expiresAt = DateTime.now().add(Duration(hours: 1));
  
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({
    'gemMultiplierExpiresAt': Timestamp.fromDate(expiresAt),
  });
  
  gemMultiplierExpiresAt = expiresAt;
}

bool hasActiveGemMultiplier() {
  if (gemMultiplierExpiresAt == null) return false;
  return DateTime.now().isBefore(gemMultiplierExpiresAt!);
}
```

---

## Ofertas Especiais

### Verificação de Expiração

```dart
List<SpecialOffer> getActiveOffers() {
  final now = DateTime.now();
  
  return specialOffers.where((offer) {
    return offer.expiresAt.isAfter(now);
  }).toList();
}
```

### Contador Regressivo

```dart
String getTimeRemaining(DateTime expiresAt) {
  final now = DateTime.now();
  final diff = expiresAt.difference(now);
  
  if (diff.inDays > 0) {
    return '${diff.inDays}d restantes';
  } else if (diff.inHours > 0) {
    return '${diff.inHours}h restantes';
  } else if (diff.inMinutes > 0) {
    return '${diff.inMinutes}min restantes';
  } else {
    return 'Expirando...';
  }
}
```

---

## Packs de Compra (IAP)

### Estrutura

```dart
class GemPack {
  final String id;
  final int gems;
  final double price;
  final bool isHighlighted;
  final String? badge; // "DESCONTO"
  
  // Pack Pequeno
  static const small = GemPack(
    id: 'gems_100',
    gems: 100,
    price: 9.90,
  );
  
  // Pack Médio (DESTAQUE)
  static const medium = GemPack(
    id: 'gems_500',
    gems: 500,
    price: 39.90,
    isHighlighted: true,
    badge: 'DESCONTO',
  );
  
  // Pack Grande
  static const large = GemPack(
    id: 'gems_1500',
    gems: 1500,
    price: 99.90,
  );
}
```

### Processo de Compra IAP

```dart
Future<void> purchaseGemPack(GemPack pack) async {
  // 1. Processar pagamento via plataforma
  final result = await InAppPurchase.instance.buyConsumable(
    purchaseParam: PurchaseParam(
      productDetails: getProductDetails(pack.id),
    ),
  );
  
  // 2. Verificar resultado
  if (result.status == PurchaseStatus.purchased) {
    // 3. Adicionar gems
    gems += pack.gems;
    totalGemsEarned += pack.gems;
    
    // 4. Salvar no Firestore
    await saveGems();
    
    // 5. Mostrar feedback
    showSuccessMessage('${pack.gems} gems adicionadas!');
  } else {
    // 6. Mostrar erro
    showErrorMessage('Não foi possível completar a compra');
  }
}
```
