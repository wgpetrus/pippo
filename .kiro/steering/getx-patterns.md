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
    if (value == null || value.isEmpty) return 'E-mail é obrigatório';
    if (!GetUtils.isEmail(value)) return 'E-mail inválido';
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

---

## Views

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

### Após Login/Logout

Usar `Get.offAllNamed()` para limpar stack:

```dart
// Após login bem sucedido
Get.offAllNamed('/home');

// Após logout
Get.offAllNamed('/auth');
```
