# Convenções

> Referência: [code-rules.md](code-rules.md)

---

## Código Limpo

- **Nomes de arquivos curtos** — evitar nomes extensos
- **Espaçamentos corretos** — separar blocos lógicos com linha em branco para facilitar leitura
- **Comentários organizacionais** — usar comentários para separar seções do código (// Lifecycle, // Métodos, // Widgets, etc.)
- **Código enxuto** — mínimo possível sem perder funcionalidade

### Padrão de Espaçamento

```dart
// ✅ CORRETO - com espaçamentos e comentários organizacionais
class MeuController extends GetxController {
  // Estados
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  // Métodos públicos
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    // lógica...
  }

  // Métodos privados
  void _loadData() {
    // lógica...
  }
}
```

```dart
// ❌ ERRADO - sem espaçamentos, difícil de ler
class MeuController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  @override
  void onInit() {
    super.onInit();
    _loadData();
  }
  Future<void> login(String email, String password) async {
    isLoading.value = true;
  }
  void _loadData() {
  }
}
```

### Comentários Organizacionais

Usar para separar seções em arquivos maiores:

- `// Estados` — variáveis observáveis
- `// Lifecycle` — onInit, onClose, initState, dispose
- `// Métodos públicos` — métodos acessíveis externamente
- `// Métodos privados` — métodos internos
- `// Widgets` — métodos que retornam Widget
- `// Validadores` — métodos de validação
- `// Handlers` — métodos de tratamento de eventos

---

## Comentários e Mensagens

- **Comentários**: em português, objetivos
- **Mensagens de erro para usuário**: em português e amigáveis

```dart
// ✅ CORRETO
errorMessage.value = 'Não foi possível fazer login. Verifique seus dados.';

// ❌ ERRADO - técnico demais
errorMessage.value = 'FirebaseAuthException: user-not-found';
```

---

## Formatação de Dados

Dados do usuário devem ser formatados corretamente conforme o projeto:

EXEMPLOS:
- **CPF**: formatar para exibição, armazenar só números
- **Telefone**: formatar para exibição, armazenar só números
- **Datas**: formato brasileiro (DD/MM/YYYY) para exibição

Criar helpers em `shared/utils/` conforme necessidade.
