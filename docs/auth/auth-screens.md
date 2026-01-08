# Telas de Autenticação

> Documentação das telas de entrada do app Pippo

---

## Visão Geral

O app possui dois fluxos de entrada:
1. **Onboarding** — Primeiro acesso (cadastro completo)
2. **Auth** — Usuários que já têm conta (login)

---

## Fluxo de Decisão (Splash)

```
Splash
  │
  ├─► Primeiro acesso? ──► Onboarding ──► Home
  │
  ├─► Já conhece o app? ──► Auth (Sign In) ──► Home
  │
  └─► Já logado? ──► Home
```

---

## 1. Onboarding (`features/core/onboarding/`)

Fluxo completo de primeiro acesso com cadastro.

### Estrutura

```
onboarding/
├── views/
│   ├── welcome_view.dart
│   ├── intro_page.dart
│   ├── select_language_page.dart
│   ├── language_level_page.dart
│   ├── learning_reason_page.dart
│   ├── pause_one_page.dart
│   ├── study_time_page.dart
│   ├── pause_two_page.dart
│   ├── user_name_page.dart
│   ├── user_age_page.dart
│   ├── user_email_page.dart
│   ├── user_password_page.dart
│   ├── verify_code_page.dart
│   └── conclusion_page.dart
├── widgets/
│   ├── bouncing_mascot.dart
│   ├── onboarding_header.dart
│   └── option_card.dart
├── controllers/
│   └── onboarding_controller.dart
└── bindings/
    └── onboarding_binding.dart
```

### Fluxo de Telas

| # | Tela | Arquivo | Progresso | Tipo |
|---|------|---------|-----------|------|
| 1 | Welcome | `welcome_view.dart` | - | Entrada |
| 2 | Intro | `intro_page.dart` | - | Pausa |
| 3 | Select Language | `select_language_page.dart` | 8% | Opções |
| 4 | Language Level | `language_level_page.dart` | 16% | Opções |
| 5 | Learning Reason | `learning_reason_page.dart` | 24% | Opções |
| 6 | Pause 1 | `pause_one_page.dart` | - | Pausa |
| 7 | Study Time | `study_time_page.dart` | 32% | Opções |
| 8 | Pause 2 | `pause_two_page.dart` | - | Pausa |
| 9 | User Name | `user_name_page.dart` | 40% | Input |
| 10 | User Age | `user_age_page.dart` | 48% | Input |
| 11 | User Email | `user_email_page.dart` | 56% | Input |
| 12 | User Password | `user_password_page.dart` | 64% | Input |
| 13 | Verify Code | `verify_code_page.dart` | 72% | Input |
| 14 | Conclusion | `conclusion_page.dart` | 100% | Pausa |

### Tipos de Tela

- **Opções**: Seleção com `OptionCard` e `OnboardingHeader`
- **Input**: Formulário com `TextEditingController` (StatefulWidget)
- **Pausa**: Transição com mascote animado

### Dados Coletados

```dart
// No OnboardingController
final selectedLanguage = ''.obs;  // Idioma escolhido
final languageLevel = ''.obs;     // Nível de conhecimento
final learningReason = ''.obs;    // Motivo de aprender
final studyTime = ''.obs;         // Tempo diário
final userName = ''.obs;          // Nome
final userAge = ''.obs;           // Idade
final userEmail = ''.obs;         // Email
final userPassword = ''.obs;      // Senha
```

---

## 2. Auth (`features/core/auth/`)

Autenticação para usuários existentes.

### Estrutura

```
auth/
├── views/
│   ├── signin_view.dart
│   ├── forgot_password_view.dart
│   ├── verify_code_view.dart
│   └── new_password_view.dart
├── controllers/
│   └── auth_controller.dart
└── bindings/
    └── auth_binding.dart
```

### Fluxo de Telas

| Tela | Arquivo | Descrição |
|------|---------|-----------|
| Sign In | `signin_view.dart` | Login com email/senha |
| Forgot Password | `forgot_password_view.dart` | Solicitar reset de senha |
| Verify Code | `verify_code_view.dart` | Código de 5 dígitos |
| New Password | `new_password_view.dart` | Criar nova senha |

### Fluxo de Recuperação de Senha

```
Sign In ──► Forgot Password ──► Verify Code ──► New Password ──► Sign In
```

---

## Rotas

| Rota | Feature | Descrição |
|------|---------|-----------|
| `/splash` | splash | Tela inicial |
| `/onboarding` | onboarding | Primeiro acesso |
| `/auth` | auth | Login |
| `/home` | home | Tela principal |

---

## Navegação

```dart
// Após onboarding/login bem sucedido
Get.offAllNamed('/home');

// Após logout
Get.offAllNamed('/auth');
```

---

## Widgets Reutilizáveis

### OnboardingHeader
Header com mascote, título, balão de fala e barra de progresso.

### OptionCard
Card de seleção com ícone e label.

### Pinput (5 dígitos)
Input de código de verificação usado em:
- `onboarding/views/verify_code_page.dart`
- `auth/views/verify_code_view.dart`

---

## Observações

- Onboarding usa navegação por `Get.to()` entre telas
- Auth usa navegação por `Get.to()` e `Get.toNamed()`
- Ambos finalizam com `Get.offAllNamed('/home')`
