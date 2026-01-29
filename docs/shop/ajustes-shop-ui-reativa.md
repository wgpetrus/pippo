# Ajustes - Shop UI Reativa

> Correção da atualização da UI e cor de fundo de itens esgotados

---

## Problemas Identificados

### 1. UI não atualiza após receber recompensa

Ao clicar na oferta gratuita e receber 100 gemas, a UI não atualizava para mostrar "RESGATADO". O usuário precisava sair e voltar para ver a mudança.

**Causa:** Uso de `FutureBuilder` que não é reativo. O `FutureBuilder` só executa uma vez quando o widget é construído.

### 2. Cor de fundo feia quando item esgotado

Quando a oferta gratuita era resgatada, o fundo ficava cinza escuro (`AppTheme.gray100`), deixando a UI feia e com baixo contraste.

---

## Soluções Implementadas

### 1. Tornar UI Reativa com Obx()

**Mudanças no Controller:**

Adicionado estado reativo para recompensas reivindicadas:

```dart
// Estados reativos - Recompensas reivindicadas
final claimedRewards = <String>[].obs;
```

Adicionado método para carregar recompensas no `onInit()`:

```dart
@override
void onInit() {
  super.onInit();
  _gamification = Get.find<GamificationController>();
  loadOwnedPacks();
  loadClaimedRewards(); // ✅ NOVO
}

/// Carrega recompensas reivindicadas do Firestore
Future<void> loadClaimedRewards() async {
  try {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('shop')
        .doc('claimed_rewards')
        .get();

    if (doc.exists) {
      claimedRewards.value = List<String>.from(doc.data()?['rewards'] ?? []);
    }
  } on FirebaseException catch (e) {
    errorMessage.value = _handleFirestoreError(e);
  }
}
```

Método reativo para verificar se recompensa foi reivindicada:

```dart
/// Verifica se recompensa já foi reivindicada (reativo)
bool isRewardClaimedReactive(String rewardId) {
  return claimedRewards.contains(rewardId);
}
```

Atualizado método `claimFreeReward()` para usar lista reativa:

```dart
// Verificar se já reivindicou (usando lista reativa)
if (claimedRewards.contains(rewardId)) {
  errorMessage.value = 'Você já reivindicou esta recompensa.';
  _showErrorSnackbar(errorMessage.value);
  return;
}

// ... adicionar gems ...

// Marcar como reivindicado (atualiza lista reativa)
claimedRewards.add(rewardId);
await _firestore
    .collection('users')
    .doc(userId)
    .collection('shop')
    .doc('claimed_rewards')
    .set({'rewards': claimedRewards});

// Recarregar stats do GamificationController
await _gamification.loadStats();
```

**Mudanças na View:**

Substituído `FutureBuilder` por `Obx()`:

```dart
// ❌ ANTES - FutureBuilder (não reativo)
FutureBuilder<bool>(
  future: controller.isRewardClaimed('free_chest_100'),
  builder: (context, snapshot) {
    final isClaimed = snapshot.data ?? false;
    return ShopItemCard(...);
  },
)

// ✅ DEPOIS - Obx (reativo)
Obx(() {
  final isClaimed = controller.isRewardClaimedReactive('free_chest_100');
  return ShopItemCard(...);
})
```

### 2. Melhorar Cor de Fundo de Item Esgotado

Mudado de cinza escuro para branco com borda cinza clara:

```dart
// ❌ ANTES - cinza escuro (feia)
backgroundColor: isClaimed ? AppTheme.gray100 : AppTheme.green100,
borderColor: isClaimed ? AppTheme.gray400 : AppTheme.green,

// ✅ DEPOIS - branco com borda clara (limpa)
backgroundColor: isClaimed ? AppTheme.white : AppTheme.green100,
borderColor: isClaimed ? AppTheme.gray300 : AppTheme.green,
```

**Resultado Visual:**

| Estado | Fundo | Borda | Texto |
|--------|-------|-------|-------|
| Disponível | Verde claro | Verde | Verde |
| Resgatado | Branco | Cinza claro | Cinza |

---

## Fluxo Completo

### Antes (Problema)

1. Usuário clica em "$ GRÁTIS"
2. Recebe 100 gemas
3. UI **não atualiza** - ainda mostra "$ GRÁTIS"
4. Usuário precisa sair e voltar para ver "RESGATADO"
5. Quando atualiza, fundo fica cinza escuro (feio)

### Depois (Solução)

1. Usuário clica em "$ GRÁTIS"
2. Recebe 100 gemas
3. `claimedRewards.add(rewardId)` atualiza lista reativa
4. `Obx()` detecta mudança e reconstrói widget
5. UI **atualiza instantaneamente** para "RESGATADO"
6. Fundo muda para branco com borda cinza clara (limpo)
7. Contador de gemas no AppBar também atualiza (já era reativo)

---

## Benefícios

1. **UI sempre sincronizada** - Mudanças refletem instantaneamente
2. **Melhor UX** - Usuário vê feedback imediato
3. **Visual limpo** - Cor de fundo clara para itens esgotados
4. **Código mais simples** - `Obx()` é mais direto que `FutureBuilder`
5. **Consistência** - Mesmo padrão usado em outras partes do app

---

## Padrão Reativo GetX

Este ajuste segue o padrão reativo do GetX usado em todo o app:

```dart
// 1. Estado reativo no controller
final claimedRewards = <String>[].obs;

// 2. Método que modifica o estado
claimedRewards.add(rewardId);

// 3. UI reage automaticamente com Obx()
Obx(() {
  final isClaimed = controller.isRewardClaimedReactive('free_chest_100');
  return ShopItemCard(...);
})
```

**Importante:** Sempre usar `Obx()` para widgets que dependem de estados reativos (`.obs`).

---

## Arquivos Modificados

- `lib/features/inners/shop/controllers/shop_controller.dart`
  - Adicionado `claimedRewards` reativo
  - Adicionado `loadClaimedRewards()`
  - Adicionado `isRewardClaimedReactive()`
  - Atualizado `claimFreeReward()` para usar lista reativa
  - Removido `isRewardClaimed()` antigo (não reativo)

- `lib/features/inners/shop/views/shop_page.dart`
  - Substituído `FutureBuilder` por `Obx()`
  - Mudado cor de fundo de `gray100` para `white`
  - Mudado cor de borda de `gray400` para `gray300`

---

## Testes Necessários

1. ✅ Clicar em oferta gratuita
2. ✅ Verificar que UI atualiza instantaneamente para "RESGATADO"
3. ✅ Verificar que contador de gemas aumenta
4. ✅ Verificar que cor de fundo fica branca (não cinza escuro)
5. ✅ Verificar que não é possível resgatar novamente
6. ✅ Sair e voltar - verificar que estado persiste
