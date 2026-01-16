# UI Onboarding - Pippo

> Fluxo de onboarding para novos usuários

---

## Telas

| Tela | Arquivo | Status |
|------|---------|--------|
| Welcome | welcome_view.dart | ✅ UI Completa |
| Select Language | select_language_page.dart | ✅ UI Completa |
| Language Level | language_level_page.dart | ✅ UI Completa |
| Learning Reason | learning_reason_page.dart | ✅ UI Completa |
| Intro | intro_page.dart | ✅ UI Completa |
| Study Time | study_time_page.dart | ✅ UI Completa |
| Pause One | pause_one_page.dart | ✅ UI Completa |
| User Name | user_name_page.dart | ✅ UI Completa |
| User Age | user_age_page.dart | ✅ UI Completa |
| Pause Two | pause_two_page.dart | ✅ UI Completa |
| User Email | user_email_page.dart | ✅ UI Completa |
| User Password | user_password_page.dart | ✅ UI Completa |
| Verify Code | verify_code_page.dart | ✅ UI Completa |
| Conclusion | conclusion_page.dart | ✅ UI Completa |

---

## welcome_view.dart

### Componentes
- BouncingMascot (animação)
- Título "Welcome to Pippo!"
- Subtítulo
- AppButton "Get Started"
- Link "I already have an account"

---

## select_language_page.dart

### Componentes
- OnboardingHeader (progress bar)
- Título "What do you want to learn?"
- Grid de OptionCard (bandeiras + idiomas)
- AppButton "Continue"

---

## language_level_page.dart

### Componentes
- OnboardingHeader
- Título "What's your [language] level?"
- Lista de OptionCard (níveis)
- AppButton "Continue"

---

## learning_reason_page.dart

### Componentes
- OnboardingHeader
- Título "Why are you learning [language]?"
- Lista de OptionCard (motivos)
- AppButton "Continue"

---

## intro_page.dart

### Componentes
- Mascote animado
- Texto motivacional
- AppButton "Continue"

---

## study_time_page.dart

### Componentes
- OnboardingHeader
- Título "How much time can you study daily?"
- Lista de OptionCard (tempos)
- AppButton "Continue"

---

## pause_one_page.dart / pause_two_page.dart

### Componentes
- Mascote com pose diferente
- Texto motivacional
- AppButton "Continue"

---

## user_name_page.dart

### Componentes
- OnboardingHeader
- Título "What's your name?"
- OnboardingTextField
- AppButton "Continue"

---

## user_age_page.dart

### Componentes
- OnboardingHeader
- Título "How old are you?"
- Lista de OptionCard (faixas etárias)
- AppButton "Continue"

---

## user_email_page.dart

### Componentes
- OnboardingHeader
- Título "What's your email?"
- OnboardingTextField (email)
- AppButton "Continue"

---

## user_password_page.dart

### Componentes
- OnboardingHeader
- Título "Create a password"
- OnboardingTextField (password)
- Requisitos de senha
- AppButton "Continue"

---

## verify_code_page.dart

### Componentes
- OnboardingHeader
- Título "Verify your email"
- AppPinput (6 dígitos)
- AppResendCode
- AppButton "Verify"

---

## conclusion_page.dart

### Componentes
- Mascote celebrando
- Título "You're all set!"
- Estatísticas iniciais
- AppButton "Start Learning"

---

## Widgets da Feature

### bouncing_mascot.dart
Mascote com animação de bounce.

### onboarding_header.dart
Header com botão voltar e progress bar.

### onboarding_text_field.dart
Input customizado para onboarding.

### option_card.dart
Card selecionável com ícone/imagem e texto.

### progress_bar.dart
Barra de progresso do onboarding.
