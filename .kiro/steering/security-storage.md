# Segurança e Armazenamento

> Referência: [code-rules.md](code-rules.md)

---

## Armazenamento Local

### SharedPreferences (Padrão)

Usar `SharedPreferences` para dados não sensíveis:

```dart
// Preferências do usuário
await prefs.setBool('darkMode', true);
await prefs.setString('language', 'pt-BR');

// Cache de dados públicos
await prefs.setString('cachedData', jsonEncode(data));
```

### SecureStorage (Dados Sensíveis)

Usar `flutter_secure_storage` **apenas** para dados sensíveis:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _storage = FlutterSecureStorage();

// Tokens de autenticação
await _storage.write(key: 'auth_token', value: token);

// Dados sensíveis do usuário
await _storage.write(key: 'user_cpf', value: cpf);
```

### Quando Usar Cada Um

| Tipo de Dado | Onde Armazenar |
|--------------|----------------|
| Preferências do usuário | SharedPreferences |
| Configurações do app | SharedPreferences |
| Cache de dados públicos | SharedPreferences |
| Tokens de autenticação | SecureStorage |
| CPF, senhas, dados pessoais | SecureStorage |

---

## Segurança

### Nunca Logar Dados Sensíveis

```dart
// ❌ ERRADO
debugPrint('Login: $email, senha: $password');
debugPrint('CPF do usuário: $cpf');

// ✅ CORRETO
debugPrint('Tentativa de login');
debugPrint('Validando documento do usuário');
```

### Mascarar Dados na UI

```dart
// ❌ ERRADO - exibe completo
Text('CPF: $cpf')  // 123.456.789-00

// ✅ CORRETO - mascara
Text('CPF: ***.***.***-${cpf.substring(cpf.length - 2)}')
```

### Não Expor Chaves no Código

```dart
// ❌ ERRADO - chave no código
const apiKey = 'sk_live_abc123xyz';

// ✅ CORRETO - variável de ambiente
const apiKey = String.fromEnvironment('API_KEY');
```

### Logout Seguro

```dart
Future<void> logout() async {
  // Limpar tokens
  await FlutterSecureStorage().deleteAll();
  
  // Limpar cache
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  
  // Logout do Firebase
  await FirebaseAuth.instance.signOut();
  
  // Navegar para auth
  Get.offAllNamed('/auth');
}
```

### Regras Básicas

- ✅ Sempre usar HTTPS
- ✅ Validar inputs antes de usar
- ✅ Limpar dados sensíveis no logout
- ❌ Nunca logar senhas, tokens, CPF
- ❌ Nunca hardcodar chaves de API
