# Como Testar Desafios (Treasure)

> Guia rápido para testar o sistema de desafios durante o desenvolvimento

---

## 🎯 Botão "Gerar Desafios"

Um botão flutuante foi adicionado na aba **Treasure** para facilitar os testes durante o desenvolvimento.

### Localização

```
Home → Tab 3 (Treasure) → Botão flutuante verde no canto inferior direito
```

### O Que Faz

Ao clicar no botão **"Gerar Desafios"**, o sistema:

1. ✅ Gera 3 desafios diários
2. ✅ Gera 3 desafios semanais
3. ✅ Salva no Firestore
4. ✅ Atualiza a lista automaticamente
5. ✅ Mostra mensagem de sucesso

---

## 📋 Desafios Gerados

### Desafios Diários (3)

| Desafio | Meta | Recompensa | Tipo |
|---------|------|------------|------|
| Complete 3 lições | 3 | 50 gems | lessons |
| Ganhe 100 XP | 100 | 30 gems | xp |
| Acerte 10 exercícios | 10 | 50 XP | correct_exercises |

**Expiração:** Meia-noite (23:59:59) do dia atual

### Desafios Semanais (3)

| Desafio | Meta | Recompensa | Tipo |
|---------|------|------------|------|
| Complete 15 lições esta semana | 15 | 200 gems | lessons |
| Mantenha streak de 7 dias | 7 | 300 XP | streak |
| Ganhe 500 XP esta semana | 500 | 150 gems | xp |

**Expiração:** Domingo 23:59:59 da semana atual

---

## 🧪 Fluxo de Teste Completo

### 1. Gerar Desafios

```
1. Abra o app
2. Vá para Tab 3 (Treasure)
3. Clique no botão verde "Gerar Desafios"
4. Aguarde a mensagem de sucesso
5. Veja os 6 desafios aparecerem na lista
```

### 2. Testar Progresso Automático

```
1. Vá para Tab 0 (Home)
2. Complete uma lição
3. Volte para Tab 3 (Treasure)
4. Veja o progresso atualizado:
   - "Complete 3 lições": 1/3 ✅
   - "Complete 15 lições esta semana": 1/15 ✅
   - "Acerte 10 exercícios": +N exercícios ✅
   - "Ganhe 100 XP": +XP ✅
   - "Ganhe 500 XP esta semana": +XP ✅
```

### 3. Testar Conclusão de Desafio

```
1. Complete 3 lições
2. Vá para Tab 3 (Treasure)
3. Veja o desafio "Complete 3 lições" com:
   - Progresso: 3/3 ✅
   - Barra cheia (verde)
   - Botão "Claim" habilitado (verde)
   - Animação de brilho ✨
4. Clique em "Claim"
5. Veja a animação de recompensa
6. Verifique que 50 gems foram adicionadas
7. Desafio desaparece da lista
```

### 4. Testar Pull-to-Refresh

```
1. Na Tab 3 (Treasure)
2. Arraste a tela para baixo
3. Veja o indicador de loading
4. Lista é atualizada
```

### 5. Testar Expiração

```
1. Gere desafios
2. Mude a data do sistema para o dia seguinte
3. Abra o app
4. Desafios diários expirados são removidos automaticamente
5. Desafios semanais permanecem (se ainda na mesma semana)
```

---

## 🐛 Troubleshooting

### "Botão não aparece"

- ✅ Verifique se está na Tab 3 (Treasure)
- ✅ Verifique se o `TreasureChallengesController` e `TreasureRewardsController` estão registrados no `HomeBinding`

### "Erro ao gerar desafios"

- ✅ Verifique sua conexão com a internet
- ✅ Verifique se está autenticado (Firebase Auth)
- ✅ Verifique as regras do Firestore (permissões)
- ✅ Veja o console para logs de erro

### "Desafios não aparecem após gerar"

- ✅ Aguarde alguns segundos (sincronização com Firestore)
- ✅ Arraste para baixo (pull-to-refresh)
- ✅ Feche e abra o app novamente
- ✅ Verifique o Firestore Console: `users/{userId}/challenges`

### "Progresso não atualiza ao completar lição"

- ✅ Verifique se a integração está ativa no `LessonRewardsController`
- ✅ Veja os logs do console para mensagens de erro
- ✅ Verifique se o tipo do desafio corresponde ('lessons', 'xp', etc)

---

## 📊 Verificar no Firestore

### Estrutura Esperada

```
users/
  └── {userId}/
      └── challenges/
          ├── {challengeId1}
          │   ├── title: "Complete 3 lições"
          │   ├── description: "Termine 3 lições hoje..."
          │   ├── goal: 3
          │   ├── progress: 0
          │   ├── rewardType: "gems"
          │   ├── rewardAmount: 50
          │   ├── type: "lessons"
          │   ├── expirationDate: Timestamp
          │   ├── isClaimed: false
          │   ├── isCompleted: false
          │   ├── createdAt: Timestamp
          │   └── updatedAt: Timestamp
          │
          ├── {challengeId2}
          └── ...
```

### Como Verificar

1. Abra o Firebase Console
2. Vá para **Firestore Database**
3. Navegue até: `users/{seu_user_id}/challenges`
4. Veja todos os desafios gerados
5. Verifique os campos e valores

---

## 🔧 Código do Botão

### Localização

```
lib/features/inners/treasure/views/treasure_page.dart
```

### Implementação

```dart
// No Scaffold
floatingActionButton: FloatingActionButton.extended(
  onPressed: () => _generateChallenges(controller),
  backgroundColor: AppTheme.primary,
  foregroundColor: AppTheme.white,
  icon: const Icon(Icons.add_task),
  label: const Text('Gerar Desafios'),
),

// Método privado
Future<void> _generateChallenges(TreasureChallengesController controller) async {
  try {
    // Mostrar loading
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      ),
      barrierDismissible: false,
    );

    // Gerar desafios
    await controller.generateDailyChallenges();
    await controller.generateWeeklyChallenges();

    // Fechar loading
    Get.back();

    // Mostrar sucesso
    Get.snackbar(
      'Sucesso! 🎉',
      'Desafios diários e semanais foram gerados.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.green,
      colorText: AppTheme.white,
      duration: const Duration(seconds: 3),
    );
  } catch (e) {
    // Fechar loading e mostrar erro
    Get.back();
    Get.snackbar(
      'Erro',
      'Não foi possível gerar desafios. Tente novamente.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.error,
      colorText: AppTheme.white,
      duration: const Duration(seconds: 3),
    );
  }
}
```

---

## ⚠️ Importante

### Remover em Produção

Este botão é **apenas para desenvolvimento**. Antes de fazer deploy:

1. ❌ Remover o `floatingActionButton` do Scaffold
2. ❌ Remover o método `_generateChallenges()`
3. ✅ Implementar geração automática via Cloud Functions

### Geração Automática (Futuro)

Em produção, os desafios devem ser gerados automaticamente:

- **Cloud Functions**: Gerar desafios à meia-noite (diários) e domingo (semanais)
- **Scheduled Functions**: Executar automaticamente sem intervenção manual
- **Personalização**: Desafios baseados no nível e progresso do usuário

---

## 📝 Checklist de Testes

Antes de considerar o sistema completo, teste:

- [ ] Gerar desafios via botão
- [ ] Ver desafios na lista (6 total)
- [ ] Completar uma lição
- [ ] Ver progresso atualizado automaticamente
- [ ] Completar um desafio (3/3)
- [ ] Ver botão "Claim" habilitado
- [ ] Clicar em "Claim"
- [ ] Ver animação de recompensa (TODO)
- [ ] Verificar gems/XP adicionados
- [ ] Ver desafio removido da lista
- [ ] Pull-to-refresh funciona
- [ ] Desafios expirados são removidos
- [ ] Empty state aparece quando sem desafios
- [ ] Error state aparece em caso de erro
- [ ] Loading state aparece ao carregar

---

## 🎮 Comandos Úteis

```bash
# Rodar app
flutter run

# Ver logs
flutter logs

# Limpar cache
flutter clean

# Rebuild
flutter pub get
flutter run
```

---

## 📚 Documentação Relacionada

- [Como Funcionam os Desafios](./como-funcionam-desafios.md)
- [Spec de Treasure Challenges](../../.kiro/specs/treasure-challenges/tasks.md)
- [TreasureChallengesController](../../lib/features/inners/treasure/controllers/treasure_challenges_controller.dart)
- [TreasureRewardsController](../../lib/features/inners/treasure/controllers/treasure_rewards_controller.dart)
