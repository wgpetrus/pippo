# Segurança e Armazenamento

> Referência: [code-rules.md](code-rules.md)
>
> Para error handlers do Firebase, ver [firebase.md](firebase.md).

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

---

## Arquivos Sensíveis e .gitignore

### Nunca Commitar Arquivos Sensíveis

**CRÍTICO:** Arquivos com informações sensíveis **NUNCA** devem ser commitados no repositório.

### Arquivos Sensíveis Comuns

| Arquivo | Conteúdo Sensível |
|---------|-------------------|
| `firebase_options.dart` | Chaves de API do Firebase |
| `google-services.json` | Configuração Android Firebase |
| `GoogleService-Info.plist` | Configuração iOS Firebase |
| `.env` | Variáveis de ambiente |
| `local.properties` | Configurações locais Android |
| Arquivos com `_secret`, `_key`, `_token` | Credenciais diversas |

### Padrão .gitignore

Sempre verificar se o `.gitignore` contém:

```gitignore
# Firebase
firebase_options.dart
google-services.json
GoogleService-Info.plist

# Variáveis de ambiente
.env
.env.*
!.env.example

# Android
android/local.properties
android/key.properties
*.keystore
*.jks

# iOS
ios/Runner/GoogleService-Info.plist
ios/firebase_app_id_file.json

# Secrets
*_secret.*
*_key.*
*_token.*
*.pem
*.p12

# IDE
.idea/
.vscode/
*.iml
```

### Checklist Antes de Commitar

- [ ] Verificar se não há chaves de API no código
- [ ] Confirmar que arquivos de configuração Firebase estão no `.gitignore`
- [ ] Validar que não há tokens ou senhas hardcodados
- [ ] Revisar arquivos novos antes de adicionar ao git
- [ ] Usar `git status` para verificar o que será commitado

### Se Commitou Acidentalmente

```bash
# Remover arquivo do histórico (CUIDADO!)
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch caminho/do/arquivo" \
  --prune-empty --tag-name-filter cat -- --all

# Forçar push (apenas se necessário e com cuidado)
git push origin --force --all

# Melhor: Invalidar as credenciais expostas
# - Regenerar chaves de API
# - Rotacionar tokens
# - Atualizar senhas
```

### Boas Práticas

- ✅ Usar `.env.example` com valores placeholder
- ✅ Documentar variáveis necessárias no README
- ✅ Revisar `.gitignore` no início do projeto
- ✅ Usar secrets do CI/CD para deploy
- ❌ Nunca commitar arquivos de configuração com valores reais
- ❌ Nunca compartilhar credenciais por chat/email
