# Padrões GetX

> Referência: [code-rules.md](code-rules.md)

---

## GetX

GetX é o padrão da empresa para:
- State management (`.obs` e `Obx()`)
- Navegação (`Get.toNamed()`, `Get.offAllNamed()`)
- Injeção de dependência (`Get.put()`, `Get.lazyPut()`, `Get.find()`)

---

## Controllers

### Estados Obrigatórios

Todo controller DEVE ter:

```dart
class MeuController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  
  // outros estados...
}
```

### Proibições

❌ **NUNCA** colocar no controller:
- `TextEditingController` — fica na View
- `Stream`, `StreamController`, `StreamSubscription` — usar `.obs`
- Lógica complexa de validação
- `Set<String>` para tracking
- Classes tipo `ValidationManager`, `FormManager`
- Qualquer coisa que adicione complexidade

### Padrão Simples

```dart
class AuthController extends GetxController {
  // Estados obrigatórios
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  
  // Validadores simples (retornam String?, sem side effects)
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'E-mail é obrigatório.';
    if (!GetUtils.isEmail(value)) return 'Por favor, insira um e-mail válido.';
    return null;
  }
  
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Senha é obrigatória.';
    if (value.length < 6) return 'A senha deve ter pelo menos 6 caracteres.';
    return null;
  }
  
  // Métodos de ação
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      // lógica...
    } catch (e) {
      errorMessage.value = 'Mensagem amigável';
    } finally {
      isLoading.value = false;
    }
  }
}
```

> **Nota:** Para erros de Firebase (Auth, Firestore), usar os handlers padronizados em [firebase.md](firebase.md).

---

## Views

### Regra Principal

> **⚠️ Views NÃO devem conter lógica de negócio.**
>
> A View é apenas para exibição. Toda lógica fica no Controller.

### Etapa 7 (UI) vs Etapa 8 (Lógica)

Na **etapa 7**, a view é 100% visual — sem `Get.find()`, sem `Obx()`, sem controller:

```dart
// Etapa 7 - UI pura
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            validator: (value) {
              // TODO: [etapa 8] mover para controller.validateEmail()
              if (value == null || value.isEmpty) return 'E-mail é obrigatório.';
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: [etapa 8] conectar com controller.login()
              if (_formKey.currentState!.validate()) {
                // ação temporária
              }
            },
            child: Text('Entrar'),
          ),
        ],
      ),
    );
  }
}
```

Na **etapa 8**, conecta com controller:

```dart
// Etapa 8 - Com controller
class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  late final AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AuthController>();
  }
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            validator: _controller.validateEmail,
          ),
          Obx(() => ElevatedButton(
            onPressed: _controller.isLoading.value ? null : () {
              if (_formKey.currentState!.validate()) {
                _controller.login(_emailController.text, _passwordController.text);
              }
            },
            child: _controller.isLoading.value
                ? CircularProgressIndicator()
                : Text('Entrar'),
          )),
        ],
      ),
    );
  }
}
```

### O que PODE na View
- `TextEditingController` (para forms)
- Estados visuais simples (`_obscurePassword`, `_selectedIndex`)
- Chamadas ao controller (`controller.login()`, `controller.validateEmail()`) — apenas na etapa 8

### O que NÃO PODE na View
- Chamadas diretas ao Firebase/API
- Manipulação de dados
- Regras de negócio
- Validações complexas

### Padrão: StatelessWidget

Todas as telas são StatelessWidget por padrão.

```dart
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    
    return Scaffold(
      body: Column(
        children: [
          const Text('Título estático'),
          // Obx APENAS onde precisa ser reativo
          Obx(() => Text('Valor: ${controller.valor.value}')),
        ],
      ),
    );
  }
}
```

### Exceção: StatefulWidget para Forms

Forms **sempre** usam StatefulWidget com TextEditingController. Isso é o padrão simples, não complexidade.

```dart
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  
  late final AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AuthController>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            validator: _controller.validateEmail,
          ),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            validator: _controller.validatePassword,
          ),
          Obx(() => ElevatedButton(
            onPressed: _controller.isLoading.value ? null : () {
              if (_formKey.currentState!.validate()) {
                _controller.login(
                  _emailController.text,
                  _passwordController.text,
                );
              }
            },
            child: _controller.isLoading.value
                ? CircularProgressIndicator()
                : Text('Entrar'),
          )),
        ],
      ),
    );
  }
}
```

---

## Obx() - Apenas Onde Necessário

Envolver **APENAS** o widget que precisa ser reativo:

```dart
// ✅ CORRETO - Obx só no que é reativo
Column(
  children: [
    const Text('Título estático'),
    Obx(() => Text('Valor: ${controller.valor.value}')),
    const SizedBox(height: 16),
    Obx(() => controller.isLoading.value
        ? CircularProgressIndicator()
        : ElevatedButton(onPressed: () {}, child: Text('Enviar')),
    ),
  ],
)

// ❌ ERRADO - Obx envolvendo tudo
Obx(() => Column(
  children: [
    Text('Título estático'),  // não precisa rebuild
    Text('Valor: ${controller.valor.value}'),
  ],
))
```

---

## Navegação

### Quando Usar Cada Tipo

| Método | Quando Usar | Exemplo |
|--------|-------------|---------|
| `Get.to()` | Navegação interna (permite voltar) | Páginas dentro de uma feature |
| `Get.toNamed()` | Navegação para rota (permite voltar) | Ir para `/auth` do onboarding |
| `Get.offAllNamed()` | Limpar stack (sem voltar) | Após login/logout bem sucedido |
| `Get.back()` | Voltar para tela anterior | Botão voltar padrão |

### Após Login/Logout (Limpar Stack)

Usar `Get.offAllNamed()` **apenas** após ações definitivas:

```dart
// ✅ Após login bem sucedido → limpa stack
Get.offAllNamed('/home');

// ✅ Após logout → limpa stack
Get.offAllNamed('/auth');

// ✅ Após completar onboarding → limpa stack
Get.offAllNamed('/home');
```

### Navegação com Possibilidade de Voltar

Usar `Get.toNamed()` ou `Get.to()` quando o usuário pode querer voltar:

```dart
// ✅ Ir para auth do onboarding (pode voltar para welcome)
Get.toNamed('/auth');

// ✅ Navegação interna entre páginas
Get.to(() => SettingsPage());

// ❌ ERRADO - usar offAllNamed quando usuário pode querer voltar
Get.offAllNamed('/auth');  // Não permite voltar!
```

### Regra Importante

> **⚠️ `Get.offAllNamed()` limpa TODO o stack de navegação.**
> 
> Use apenas quando o usuário NÃO deve poder voltar (após login, logout, completar onboarding).
> Para navegação normal onde o botão voltar deve funcionar, use `Get.toNamed()` ou `Get.to()`.
