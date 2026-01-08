# Arquitetura e Estrutura

---

## Estrutura Principal

```
lib/
├── main.dart
├── firebase_options.dart
│
├── assets/                   # Recursos estáticos
│   ├── fonts/
│   └── images/
│
├── features/                 # Funcionalidades do app
│   ├── core/                 # Features principais de negócio
│   ├── inners/               # Features internas/suporte (home, setup, settings)
│   └── borders/              # Reservado (analytics, integrações futuras)
│
└── shared/                   # Código compartilhado
    ├── routes/               # app_routes.dart
    ├── theme/                # theme.dart (cores, fontes, estilos)
    ├── utils/                # validators, helpers, formatters
    └── widgets/              # Widgets globais (prefixo app_)
```

---

## Estrutura de Feature

Cada feature deve ter:

```
feature_name/
├── views/           # Telas da feature
├── controllers/     # Lógica da feature
├── bindings/        # Injeção de dependência (se tiver rota própria)
└── widgets/         # Widgets específicos desta feature (opcional)
```

**Regras:**
- `bindings/` só é necessário se a feature tem rota própria no `app_routes.dart`
- Features que são páginas internas (via estado) não precisam de binding próprio

---

## Nomenclatura

### Código

| Tipo | Padrão | Exemplo |
|------|--------|---------|
| Arquivos/Pastas | snake_case | `login_view.dart`, `user_profile/` |
| Classes | PascalCase | `LoginView`, `AuthController` |
| Variáveis/Métodos | camelCase | `isLoading`, `getUserData()` |
| Constantes | UPPER_SNAKE_CASE | `API_BASE_URL`, `MAX_RETRY` |

### Arquivos

| Tipo | Sufixo | Exemplo |
|------|--------|---------|
| View principal | `_view.dart` | `login_view.dart` |
| Página interna | `_page.dart` | `favorites_page.dart` |
| Controller | `_controller.dart` | `auth_controller.dart` |
| Binding | `_binding.dart` | `auth_binding.dart` |
| Widget global | `app_[nome].dart` | `app_button.dart` |

**Importante:** Nomenclatura é `_view`, não `_screen`.

---

## Widgets

### Widgets Globais (`shared/widgets/`)
- Usados em várias features
- Prefixo `app_` obrigatório
- Exemplos: `app_button.dart`, `app_text_field.dart`, `app_snackbar.dart`

### Widgets Específicos (`feature/widgets/`)
- Usados apenas naquela feature
- Ficam dentro da pasta da feature
- Sem prefixo especial

---

## Navegação

### Rotas
- Formato **kebab-case**: `/auth`, `/home`, `/item-details`
- Definidas em `shared/routes/app_routes.dart`

### Após Login/Logout
- Usar `Get.offAllNamed()` para limpar stack de navegação

### Páginas Internas (Home)
- Navegação por **estado**, não por rotas
- Usar `IndexedStack` ou similar
- Controlado por `currentIndex.obs` no controller

---

## Wrapper Pattern (Splash)

O Wrapper é a primeira tela do app e decide para onde navegar.

### Visual
```
┌─────────────────────────┐
│                         │
│                         │
│         [LOGO]          │  ← Centralizado
│                         │
│                         │
│                         │
│    ○ (loading)          │  ← 48px do bottom
└─────────────────────────┘
```

### Código Padrão da Splash

```dart
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Image.asset(
          AppAssets.logoName,  // ou AppAssets.logo
          width: 200,
          fit: BoxFit.contain,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 48),
          child: SizedBox(
            width: Get.height * 0.075,
            height: Get.height * 0.075,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppTheme.secondaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### Lógica de Decisão (ordem importante!)
```
1. Não autenticado? → /auth (ou /onboarding se primeiro acesso)
2. Autenticado, setup incompleto? → /setup
3. Autenticado, setup completo? → /home
```

**A ordem das verificações é crítica!** Sempre do mais restritivo para o menos.

---

## Assets

Sempre em `lib/assets/`:
```
lib/assets/
├── fonts/
│   └── Poppins/
│       ├── Poppins-Regular.ttf
│       ├── Poppins-Medium.ttf
│       └── ...
└── images/
    ├── logo.png
    └── ...
```
