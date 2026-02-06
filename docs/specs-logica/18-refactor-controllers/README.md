# Spec: Refatoração de Controllers

## 🎯 Objetivo

Reduzir todos os controllers para **≤500 linhas**, seguindo o princípio de responsabilidade única (SRP).

---

## ⚠️ IMPORTANTE: Migração, NÃO Reescrita

Esta refatoração é uma **MIGRAÇÃO de código existente**, não uma reescrita.

### ✅ FAZER
- Copiar e colar métodos existentes
- Mover estados observáveis
- Atualizar referências entre controllers
- Manter lógica intacta

### ❌ NÃO FAZER
- Reescrever lógica existente
- Alterar comportamento dos métodos
- Refatorar código durante migração

---

## 📊 Controllers a Refatorar

| Controller | Linhas | Dividir em | Status |
|------------|--------|------------|--------|
| ProfileController | 2045 | 5 controllers | [ ] |
| LessonController | 1810 | 4 controllers | [ ] |
| GamificationController | 1367 | 4 controllers | [ ] |
| OnboardingController | 1228 | 3 controllers | [ ] |
| TreasureController | 897 | 2 controllers | [ ] |
| HomeController | 764 | 2 controllers | [ ] |
| AuthController | 718 | 2 controllers | [ ] |

**Consulte [lista-controllers.md](lista-controllers.md) para mapeamento completo de métodos e estados.**

---

## 🔄 Processo de Refatoração

### Passo a Passo

1. **Criar Controllers Novos**
   - Criar arquivo para cada controller novo
   - Copiar estados observáveis do controller antigo
   - Copiar métodos listados em lista-controllers.md
   - Adicionar `isLoading` e `errorMessage` obrigatórios

2. **Atualizar Referências**
   - Identificar dependências entre controllers
   - Adicionar `Get.find()` onde necessário
   - Testar comunicação entre controllers

3. **Atualizar Binding**
   - Adicionar `Get.lazyPut()` para cada controller novo
   - Remover registro do controller antigo

4. **Atualizar Views**
   - Listar todas as views que usam o controller
   - Atualizar `Get.find()` para controllers corretos
   - Verificar se todos os estados estão acessíveis

5. **Validar**
   - Executar testes existentes
   - Testar manualmente funcionalidades
   - Confirmar que todos têm ≤500 linhas

6. **Limpar**
   - Deletar controller antigo
   - Marcar como concluído em lista-controllers.md
   - Commit das mudanças

---

## 📋 Padrão de Controller

Todos os controllers devem seguir este padrão:

```dart
class NomeController extends GetxController {
  // Firebase instances (se necessário)
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Estados específicos
  // ...

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    // inicialização
  }

  // Métodos públicos
  // ...

  // Métodos privados
  // ...

  // Handlers de erro
  // ...
}
```

---

## � Comunicação Entre Controllers

```dart
class ProfileDataController extends GetxController {
  late final GamificationController _gamificationController;

  @override
  void onInit() {
    super.onInit();
    try {
      _gamificationController = Get.find<GamificationController>();
    } catch (e) {
      // Controller não disponível, funcionalidade opcional
    }
  }

  Future<void> loadStats() async {
    // Usar _gamificationController se disponível
    if (_gamificationController != null) {
      totalXp.value = _gamificationController.totalXp.value;
    }
  }
}
```

---

## 📦 Atualização de Bindings

```dart
// ANTES
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileController());
  }
}

// DEPOIS
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileDataController());
    Get.lazyPut(() => ProfileSettingsController());
    Get.lazyPut(() => ProfileSocialController());
    Get.lazyPut(() => ProfileCoursesController());
    Get.lazyPut(() => ProfileAuthController());
  }
}
```

---

## 🎨 Atualização de Views

```dart
// ANTES
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    
    return Scaffold(
      body: Obx(() => Text(controller.userName.value)),
    );
  }
}

// DEPOIS
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dataController = Get.find<ProfileDataController>();
    final socialController = Get.find<ProfileSocialController>();
    
    return Scaffold(
      body: Obx(() => Text(dataController.userName.value)),
    );
  }
}
```

---

## ✅ Checklist de Validação

Após cada refatoração:

- [ ] Todos os controllers novos criados
- [ ] Binding atualizado
- [ ] Views atualizadas
- [ ] Testes passando
- [ ] Funcionalidades validadas manualmente
- [ ] Todos os controllers com ≤500 linhas
- [ ] Controller antigo deletado
- [ ] lista-controllers.md atualizado (marcado como concluído)

---

## 💾 Mensagem de Commit

```
refactor: divide [NomeController] em [N] controllers menores

- Cria [Controller1] (~XXX linhas)
- Cria [Controller2] (~XXX linhas)
...
- Atualiza [Feature]Binding
- Atualiza views para usar controllers corretos
- Remove [NomeController] antigo (XXXX linhas)

Ref: spec 18-refactor-controllers
```

**Exemplo:**
```
refactor: divide ProfileController em 5 controllers menores

- Cria ProfileDataController (~400 linhas)
- Cria ProfileSettingsController (~400 linhas)
- Cria ProfileSocialController (~400 linhas)
- Cria ProfileCoursesController (~400 linhas)
- Cria ProfileAuthController (~400 linhas)
- Atualiza ProfileBinding
- Atualiza views para usar controllers corretos
- Remove ProfileController antigo (2045 linhas)

Ref: spec 18-refactor-controllers
```

---

## 📈 Resultado Esperado

### Antes
- 10 controllers
- 7 acima do limite (70%)
- Maior: 2045 linhas

### Depois
- 31 controllers
- 0 acima do limite (0%)
- Maior: ≤500 linhas

---

Consulte [lista-controllers.md](lista-controllers.md) para ver o mapeamento completo de métodos e estados de cada controller.
