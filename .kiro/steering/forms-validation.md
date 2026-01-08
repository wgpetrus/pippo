# Validação de Forms

> Referência: [code-rules.md](code-rules.md)

---

## Padrão (simples e direto)

- `TextEditingController` para capturar texto
- `validator` do `TextFormField` para mostrar erros
- Validar tudo no submit com `_formKey.currentState!.validate()`

---

## Proibido (adiciona complexidade)

- Variáveis reativas por campo (`emailError.obs`, `passwordError.obs`)
- Validação em tempo real com `onChanged`
- Sets, managers, ou qualquer abstração extra

---

## Exemplo Completo

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

## Validadores no Controller

Validadores ficam no controller, mas são simples (retornam `String?`, sem side effects):

```dart
class AuthController extends GetxController {
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'E-mail é obrigatório';
    if (!GetUtils.isEmail(value)) return 'E-mail inválido';
    return null;
  }
  
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Senha é obrigatória';
    if (value.length < 6) return 'Senha deve ter pelo menos 6 caracteres';
    return null;
  }
}
```
