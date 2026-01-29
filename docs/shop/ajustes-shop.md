# Ajustes da Loja - Pippo

> Implementação dos ajustes solicitados no sistema de loja

---

## Resumo das Mudanças

### 1. Aviso de Compras In-App

**Implementado:** Modal de aviso para itens com preço real

**Arquivo:** `lib/features/inners/shop/widgets/iap_notice_dialog.dart`

**Funcionalidade:**
- Exibe aviso informando que compras in-app serão implementadas futuramente
- Sugere ao usuário adquirir gemas completando lições e desafios
- Usa `wolt_modal_sheet` para consistência visual
- Ícone de informação (FontAwesome) com cor laranja

**Uso:**
```dart
IapNoticeDialog.show(
  context,
  onContinue: () {
    // Ação após usuário clicar "Entendi"
  },
);
```

---

### 2. Sistema de Pacotes Funcional

**Implementado:** Sistema completo de gerenciamento de pacotes adquiridos

**Arquivos Modificados:**
- `lib/features/inners/shop/controllers/shop_controller.dart`
- `lib/features/inners/shop/views/shop_page.dart`

**Funcionalidades:**

#### Controller (`shop_controller.dart`)
- `ownedPacks`: Observable que armazena pacotes adquiridos `{packId: quantity}`
- `loadOwnedPacks()`: Carrega pacotes do Firestore
- `_saveOwnedPacks()`: Salva pacotes no Firestore
- `_addPack(packId, quantity)`: Adiciona pacote ao inventário
- `getPackQuantity(packId)`: Retorna quantidade de um pacote

#### View (`shop_page.dart`)
- Seção "Seus pacotes" agora é reativa (usa `Obx()`)
- Mostra mensagem quando não há pacotes adquiridos
- Exibe pacotes com quantidade atualizada dinamicamente
- Pacotes disponíveis:
  - `xp_boost`: Boost de XP
  - `skip_lesson`: Pular Lição

**Estrutura Firestore:**
```
users/{userId}/shop/packs
{
  "xp_boost": 10,
  "skip_lesson": 5
}
```

---

### 3. Recompensas Gratuitas Funcionais

**Implementado:** Sistema de reivindicação de recompensas gratuitas

**Arquivos Modificados:**
- `lib/features/inners/shop/controllers/shop_controller.dart`
- `lib/features/inners/shop/views/shop_page.dart`

**Funcionalidades:**

#### Controller
- `claimFreeReward(context, rewardId, gemsAmount)`: Reivindica recompensa gratuita
- `isRewardClaimed(rewardId)`: Verifica se recompensa já foi reivindicada
- Adiciona gems diretamente no Firestore usando `FieldValue.increment()`
- Marca recompensa como reivindicada para evitar duplicação
- Recarrega stats de gamificação após reivindicar

#### View
- Usa `FutureBuilder` para verificar status da recompensa
- Muda visual quando recompensa já foi resgatada:
  - Texto: "RESGATADO" (cinza)
  - Background: cinza claro
  - Borda: cinza
  - Desabilita clique
- Recompensa ativa:
  - Texto: "$ GRÁTIS" (verde)
  - Background: verde claro
  - Borda: verde
  - Clicável

**Estrutura Firestore:**
```
users/{userId}/shop/claimed_rewards
{
  "rewards": ["free_chest_100", "free_gems_50"]
}
```

---

## Integração com Compras In-App

**Métodos Preparados:**

### `purchaseGemPack(context, packId, gemsAmount, price)`
- Mostra aviso de IAP
- Preparado para integração futura com sistema de pagamento
- Parâmetros prontos para API de compras

### `purchaseCollectible(context, itemId, price)`
- Mostra aviso de IAP
- Preparado para integração futura
- Aplicado em:
  - Skins do Mascote
  - Pacotes de Emblemas

**TODO Futuro:**
```dart
// Substituir por integração real com in_app_purchase
await InAppPurchase.instance.buyConsumable(
  purchaseParam: PurchaseParam(
    productDetails: productDetails,
  ),
);
```

---

## Fluxo de Uso

### 1. Recompensa Gratuita
```
Usuário clica em oferta gratuita
  ↓
Verifica se já reivindicou
  ↓
Se não reivindicou:
  - Adiciona gems
  - Marca como reivindicado
  - Mostra snackbar de sucesso
  - Recarrega stats
  ↓
Se já reivindicou:
  - Mostra erro
```

### 2. Compra com Dinheiro Real
```
Usuário clica em item pago
  ↓
Mostra IapNoticeDialog
  ↓
Usuário clica "Entendi"
  ↓
Mostra snackbar informando que será implementado
```

### 3. Visualizar Pacotes
```
Usuário abre loja
  ↓
Controller carrega pacotes do Firestore
  ↓
Se tem pacotes:
  - Mostra cards com quantidade
Se não tem:
  - Mostra mensagem incentivando compra
```

---

## Testes Recomendados

### Manual
1. Abrir loja e verificar seção "Seus pacotes"
2. Clicar em recompensa gratuita e verificar:
   - Gems adicionadas
   - Status muda para "RESGATADO"
   - Não pode reivindicar novamente
3. Clicar em item pago e verificar:
   - Modal de aviso aparece
   - Mensagem clara sobre implementação futura
4. Verificar persistência:
   - Fechar e reabrir app
   - Pacotes e recompensas devem manter estado

### Firestore
1. Verificar estrutura de dados:
   - `users/{userId}/shop/packs`
   - `users/{userId}/shop/claimed_rewards`
2. Verificar incremento de gems em:
   - `users/{userId}/stats/gamification`

---

## Observações

### Segurança
- Recompensas gratuitas são validadas no Firestore
- Não é possível reivindicar múltiplas vezes
- Gems são incrementadas atomicamente com `FieldValue.increment()`

### Performance
- `FutureBuilder` usado para verificação assíncrona
- Carregamento de pacotes feito no `onInit()` do controller
- Operações Firestore com timeout de 30s

### UX
- Feedback visual claro (cores, textos)
- Snackbars para sucesso/erro
- Loading states durante operações
- Mensagem amigável quando não há pacotes

---

## Próximos Passos

1. **Integração com in_app_purchase:**
   - Adicionar package `in_app_purchase`
   - Configurar produtos no Google Play / App Store
   - Implementar fluxo de compra real
   - Validar recibos no backend

2. **Sistema de uso de pacotes:**
   - Implementar consumo de "Boost de XP"
   - Implementar "Pular Lição"
   - Adicionar confirmação antes de usar
   - Atualizar quantidade após uso

3. **Mais ofertas especiais:**
   - Rotação de ofertas diárias
   - Ofertas por tempo limitado
   - Pacotes promocionais

4. **Analytics:**
   - Rastrear cliques em ofertas
   - Monitorar taxa de conversão
   - Identificar ofertas mais populares
